/* mpcloop_engine.c: MPC simulation */
  
/*
        Syntax: [u,y,xp,xmpc]=mpcloop_engine(MPCstruct);
  
        Author: A. Bemporad
        Revised by: R. Chen
        Copyright 1986-2008 The MathWorks, Inc.
        $Revision: 1.1.10.7 $  $Date: 2009/08/08 01:11:25 $
 */

#include "mpcloop_engine.h"

/* Merge common source */
/*
// MPC_COMMON.C contains the following functions
//      dantzg
//      getrv
 */
#include "mpc_common.c"

/* MDLOUTPUT */
/* computeOtuputs(const mxArray *S, int_T tid, real_T *lastx, real_T *lastu, real_T *v, real_T *optimalseq, long int *lastt, real_T *md_t, real_T *my_t, real_T *u_out, boolean_T unconstr)*/
static void computeOtuputs(const mxArray *S, int_T tid, real_T *lastx, real_T *lastu, 
real_T *v, real_T *optimalseq, long int *lastt, real_T *md_t, real_T *my_t, 
real_T *u_out, boolean_T unconstr)
/* Note that tid = current time step.*/
{

    static real_T *ref_signal, *md_signal, *yoff, *voff, *myoff, *uoff;
    static real_T *M, *Cm, *Dvm;
    static int_T q, nvar, nxQP, p, degrees, PTYPE, useslack;
    static long int maxiter;
    static real_T *Kv, *Mv, *Kx, *Ku1, *Kut, *Kr, *KduINV;
    static real_T *Mx, *Mu1, *rhsc0, *rhsa0, *Mlim, *MuKduINV, *TAB, *zmin;
    static real_T *wtab;
    static real_T *utarget;
    static int_T nu, nx, nym, ny, nv;
    static boolean_T no_md, no_ref, no_ym;
    static boolean_T do_optimization;
    
    static boolean_T ref_from_ws, ref_preview, md_from_ws, md_preview;
    static int_T Nref_signal, Nmd_signal;
    static boolean_T isemptyKv;
    
    /* Counters */
    int_T i,j;
    int_T numc;
    
    /* Accumulator */
    real_T adder = 0;
    real_T cache = 0;
    
    /* Local work variables */
    /* mxMalloc is used to allocate memory to these pointers except "tab" */
    real_T *r = NULL;       /* Reference values extended over pred. hor. */
    real_T *ytilde = NULL;  /* Measurement update */
    real_T *vKv = NULL;
    real_T *Mvv = NULL;
    real_T *zopt = NULL;    /* Optimal sequence */
    real_T *zopx = NULL;
    real_T *ztemp = NULL;
    real_T *rhsc = NULL;
    real_T *rhsa = NULL;
    real_T *basis = NULL;   /* Basis vector for QP */
    long int *ib = NULL;    /* Index vector for QP */
    long int *il = NULL;    /* Index vector fo QP */
    real_T *duold = NULL;
    real_T *tab = NULL;     /* Tableau for QP */
    
    int nuc = 0;            /* number of unconstrained vars in DANTZGMP */
    int iret;               /* DANTZGMP return code */
    
    do_optimization=(boolean_T) 1;
    
    /* Get vars from structure S. In MPCLOOP_ENGINE, they are only initialized once,
    in MPC_SFUN every time, because there might be multiple blocks in the diagram
    sharing the same static variables */
    
    if (tid==0) {
        
        ref_signal=mxGetPr((real_T *)p_ref_signal(S));
        Nref_signal=mxGetN(p_ref_signal(S));
        md_signal=mxGetPr((real_T *)p_md_signal(S));
        Nmd_signal=mxGetN(p_md_signal(S));
        yoff=mxGetPr((real_T *)p_yoff(S));
        voff=mxGetPr((real_T *)p_voff(S));
        myoff=mxGetPr((real_T *)p_myoff(S));
        uoff=mxGetPr((real_T *)p_uoff(S));
        
        M=mxGetPr((real_T *)p_M(S));
        Cm=mxGetPr((real_T *)p_Cm(S));
        Dvm=mxGetPr((real_T *)p_Dvm(S));
        
        Kv=mxGetPr((real_T *)p_Kv(S));
        isemptyKv=mxIsEmpty(p_Kv(S));
        Mv=mxGetPr((real_T *)p_Mv(S));
        Kx=mxGetPr((real_T *)p_Kx(S));
        Ku1=mxGetPr((real_T *)p_Ku1(S));
        Kut=mxGetPr((real_T *)p_Kut(S));
        Kr=mxGetPr((real_T *)p_Kr(S));
        KduINV=mxGetPr((real_T *)p_KduINV(S));
        Mx=mxGetPr((real_T *)p_Mx(S));
        Mu1=mxGetPr((real_T *)p_Mu1(S));
        rhsc0=mxGetPr((real_T *)p_rhsc0(S));
        rhsa0=mxGetPr((real_T *)p_rhsa0(S));
        Mlim=mxGetPr((real_T *)p_Mlim(S));
        MuKduINV=mxGetPr((real_T *)p_MuKduINV(S));
        TAB=mxGetPr((real_T *)p_TAB(S));
        wtab=mxGetPr((real_T *)p_wtab(S));
        zmin=mxGetPr((real_T *)p_zmin(S));
        
        utarget=mxGetPr((real_T *)p_utarget(S));
        
        nxQP = (int_T)*mxGetPr(p_nxQP(S)); /* Size of state vector without Noise model states */
        nu = (int_T)*mxGetPr(p_nu(S));   /* Size of input vector */
        nx = (int_T)*mxGetPr(p_nx(S));   /* Size of extended state vector */
        nym = (int_T)*mxGetPr(p_nym(S)); /* Size of measured output vector */
        ny = (int_T)*mxGetPr(p_ny(S));   /* Size of current ref. vect. */
        nv = (int_T)*mxGetPr(p_nv(S));   /* Size of current meas. dist. vect. */
        
        ref_from_ws = (boolean_T) *mxGetPr(p_ref_from_ws(S)); /* reference signal comes from workspace */
        ref_preview = (boolean_T) *mxGetPr(p_ref_preview(S)); /* =TRUE means preview is on */
        md_from_ws = (boolean_T) *mxGetPr(p_md_from_ws(S));   /* meas. dist. signal comes from workspace */
        md_preview = (boolean_T) *mxGetPr(p_md_preview(S));   /* =TRUE means preview is on */
        
        q = mxGetM(p_Mlim(S));          /* Number of constraints in QP problem */
        p = (int_T)*mxGetPr(p_p(S));    /* Prediction horizon */
        degrees = (int_T)*mxGetPr(p_degrees(S));
        PTYPE = (int_T)*mxGetPr(p_PTYPE(S));
        
        maxiter = (int_T) *mxGetPr(p_maxiter(S)); /* Maxiter */
        
        if (PTYPE == SOFTCONSTR)
            useslack = 1;
        else
            useslack = 0;
        nvar=degrees+useslack; /* number of optimization variables */
        
        if (unconstr) PTYPE=UNCONSTR;  /* remove MPC constraints */
    }
    
       
    #ifdef DEBUG
    printf("lastx: ["); 
    for (i=0;i<nx;i++) 
        printf("%g,",lastx[i]); 
    printf("]\n");
    #endif

    r = mxMalloc(p*ny*sizeof(real_T)); /* reference signal vector r from workspace */

    if (do_optimization) {        

        if (!ref_from_ws) { /* ref. signal comes from Simulink diagram */
            /* Get output ref. from input port */
            for (i=0; i<p; i++) {
                for (j=0; j<ny; j++) {
                    if (no_ref) {
                        r[j+i*ny] = 0;  /* default: r=yoff */
                    }
                    else {
                        /*	r[j+i*ny] = ref_t[j]-yoff[j]; */ /*This can never happen! */
                        ;/* do nothing */
                    }
                }
            }
        }
        else { /* Reference signal is contained in ref_signal */
            if (!ref_preview) {
                getrv(r,ref_signal,*lastt,*lastt,ny,ny,Nref_signal);
                /* Repeat over prediction horizon */
                for (i=1; i<p; i++) {
                    for (j=0; j<ny; j++) {
                        r[j+i*ny] = r[j];
                    }
                }
            }
            else {
                getrv(r,ref_signal,*lastt,*lastt+p-1,ny,ny,Nref_signal);
            }
        }

        #ifdef DEBUG
        for (i=0; i<p; i++) {
            printf("r(:,%d): [",i);
            for (j=0; j<ny; j++)
                printf("%5.2f, ",r[ny*i+j]);
            printf("]'\n");
        }
        #endif
        /* printf("r: ["); for (i=0;i<ny;i++) printf("%g,",r[i]); printf("]\n"); */        

    } /* end of if (do_optimization) */            

    /* Set up measured disturbance vector v from *mdPtrs or from rv (file)
       as a one-component vector (even if no optimization is performed, 
       v is always needed by the state observer) */

    if (!md_from_ws) {/* measured disturbance comes from Simulink diagram */
        /* Get meas. dist. from input */
        for (i=0; i<p+1; i++) {
            for (j=0; j<nv-1; j++) {
                if (no_md) {
                    v[j+i*nv] = 0;  /* default: md=voff */
                }
                else {
                    v[j+i*nv] = md_t[j]-voff[j];
                }
            }
        }
    }
    else { /* Measured disturbance signal is contained in md_signal */
        if (!md_preview) {
            getrv(v,md_signal,*lastt,*lastt,nv-1,nv-1,Nmd_signal);
            /* Repeat over prediction horizon */
            for (i=1; i<p+1; i++) {
                for (j=0; j<nv; j++) {
                    v[j+i*nv] = v[j];
                }
            }
        }
        else {
            getrv(v,md_signal,*lastt,*lastt+p,nv-1,nv,Nmd_signal);
        }
    }

    #ifdef DEBUG
    for (i=0; i<p+1; i++) {
        printf("v(:,%d): [",i);
        for (j=0; j<nv; j++)
            printf("%5.2f, ",v[nv*i+j]);
        printf("]'\n");
    }
    #endif
    /* printf("v: ["); for (i=0;i<nv-1;i++) printf("%g,",v[i]); printf("]\n"); */        

    /* Measurement update of state observer */
    /* ytilde=y-myoff-(Cm*xk+Dvm*vk); */

    ytilde = mxMalloc(nym*sizeof(real_T));

    #ifdef DEBUG
    printf("ym[0]=%g\n",*ymPtrs[0]);
    #endif

    for (i=0; i<nym; i++) {
        CLR; /* i.e., adder = 0 */
        MVP(Cm, lastx, i, nym, nx);
        MVP(Dvm, v, i, nym, nv);
        /* printf("adder[%d]: %g\n",i,adder); */            
        ytilde[i]=my_t[i]-adder;
    }
    #ifdef DEBUG
    printf("ytilde: ["); 
    for (i=0;i<nym;i++) 
        printf("%g,",ytilde[i]); 
    printf("]\n");
    #endif

    /*   xk=xk+M*ytilde;  % (NOTE: what is called M here is also called M in KALMAN's help file) */

    #ifdef DEBUG
    printf("lastx[0]=%g\n",lastx[0]);
    #endif

    for (i=0; i<nx; i++) {
        CLR;
        MVP(M, ytilde, i, nx, nym);
        lastx[i] += adder;

        #ifdef DEBUG
        printf("Measurement update: x[%d]: %f\n",i,lastx[i]);
        #endif
    }

    /* Now ready for MPC optimization problem

        xQP=xk(1:nxQP)  only these first nx states are fed back to the QP problem
                  (i.e., multiplied by the Kx gain)
     */

    if (do_optimization) {

        #ifdef DEBUG
        printf("Starting MPC Optimization Problem ...\n");
        #endif

        vKv = mxMalloc(degrees*sizeof(real_T));

        if (isemptyKv) {
            for (j=0; j<degrees; j++) {
                vKv[j]=0.0;
            }

            if(PTYPE != UNCONSTR) {
                Mvv = mxMalloc(q*sizeof(real_T)); /* q=number of constraints */
                for(i=0; i<q; i++) {
                    Mvv[i]=0.0;
                }
            }
        }
        else {
            for (j=0; j<degrees; j++) {
                CLR;
                MVTP(Kv, v, j, (p+1)*nv);
                vKv[j]=adder;
            }
            if (PTYPE != UNCONSTR) {
                /*printf("N(Mv),M(Mv): %d,%d -- nvar: %d, (p+1)*nv: %d\n",mxGetN(p_Mv(S)),mxGetM(p_Mv(S)),q,(p+1)*nv); */
                Mvv = mxMalloc(q*sizeof(real_T));
                for (i=0; i<q; i++) {
                    CLR;
                    MVP(Mv, v, i, q, (p+1)*nv);
                    Mvv[i]=adder;
                }
            }
        }

        /* The equivalent of mpc2.m starts here */

        if (PTYPE == UNCONSTR) {

            /* Unconstrained problem, compute zopt */

            #ifdef DEBUG
            printf("UNCONSTRAINED!\n");
            #endif

            /* zopt=-KduINV*(Kx'*xk+Ku1'*uk1+Kut'*utarget+Kr'*r+vKv'); */

            ztemp = mxMalloc(degrees*sizeof(real_T)); /* stores linear term of the cost function */
            for (i=0; i<degrees; i++) {
                CLR;
                MTVP(Kx, lastx, i, nxQP);

                /* for (j=0; j<nxQP; j++) {
                printf("Kx[%d]: %7.5f, x[%d]: %7.5f\n",j,mxGetPr(p_Kx(S))[j],j,lastx[j]);
                } */

                MTVP(Ku1, lastu, i, nu);

                /*printf("N(Kut),M(Kut): %d,%d -- nvar: %d, p*nu: %d\n",mxGetN(p_Kut(S)),mxGetM(p_Kut(S)),nvar,p*nu); */
                MTVP(Kut, utarget, i, p*nu);
                /*printf("N(Kr),M(Kr): %d,%d -- nvar: %d, p*ny: %d\n",mxGetN(p_Kr(S)),mxGetM(p_Kr(S)),nvar,p*ny); */
                MTVP(Kr, r, i, p*ny);

                ztemp[i]=adder+vKv[i];
            }

            zopt = mxMalloc(degrees*sizeof(real_T));
            for (i=0; i<degrees; i++) {
                CLR;
                MVP(KduINV, ztemp, i, nvar, nvar);
                zopt[i] = -adder;
            }

        }
        else {

            /* Constrained, must solve QP */

            #ifdef DEBUG
            printf("CONSTRAINED!\n");
            #endif

            /* Set up matrices for QP */

            /* rhsc=rhsc0+Mlim+Mx*xk+Mu1*uk1+Mvv; */
            /* printf("N(rhsc0),M(rhsc0): %d,%d -- 1: %d, q: %d\n",mxGetN(p_rhsc0(S)),mxGetM(p_rhsc0(S)),1,q); */
            rhsc = mxMalloc(q*sizeof(real_T));

            for (i=0; i<q; i++) {
                CLR;
                MVP(Mx, lastx, i, q, nxQP);
                MVP(Mu1, lastu, i, q, nu);
                rhsc[i]=rhsc0[i]+Mlim[i]+Mvv[i]+adder;
            }

            /* rhsa=rhsa0-[(xk'*Kx+r'*Kr+uk1'*Ku1+vKv+utarget'*Kut),zeros(1,useslack)]'; */
            rhsa = mxMalloc(nvar*sizeof(real_T));
            rhsa[nvar-1] = 0.0; /* if useslack=1, then last entry of rhsa equals 0, otherwise is rewritten below */
            for (j=0; j<degrees; j++) {
                CLR;
                MVTP(Kx, lastx, j, nxQP);
                MVTP(Kr, r, j, p*ny);
                MVTP(Ku1, lastu, j, nu);
                MVTP(Kut, utarget, j, p*nu);
                /* rhsa[j]=mxGetPr(p_rhsa0(S))[j]-(adder+vKv[j]); */
                rhsa[j]=rhsa0[j]-(adder+vKv[j]);
            }

            /* basis=[KduINV*rhsa;rhsc-MuKduINV*rhsa]; */
            numc = nvar+q;
            basis = mxMalloc(numc*sizeof(real_T));

            #ifdef DEBUG
            printf("Basis is %d items\n", numc);
            #endif

            for(i=0; i<nvar; i++) {
                CLR;
                MVP(KduINV, rhsa, i, nvar, nvar);
                basis[i]=adder;

                #ifdef DEBUG
                printf("B %f\n",basis[i]);
                #endif
            }
            /* printf("N(MuKduINV),M(MuKduINV): %d,%d -- 1: %d, nvar: %d\n",mxGetN(p_MuKduINV(S)),mxGetM(p_MuKduINV(S)),nvar,q); */

            for(i=0; i<q; i++) {
                CLR;
                MVP(MuKduINV, rhsa, i, q, nvar);
                basis[i+nvar]=rhsc[i]-adder;

                #ifdef DEBUG
                printf("B %f\n",basis[i+mxGetM(p_KduINV(S))]);
                #endif
            }

            /* ibi=-[1:nvar+nc]'; */
            /* ili=-ibi; */
            ib = mxMalloc(numc*sizeof(long int));
            il = mxMalloc(numc*sizeof(long int));
            for(i=0; i<numc; i++) {
                il[i]=i+1;
                ib[i]=-il[i];
            }

            /* Initialize the tableau */

            tab = mxMalloc(numc*numc*sizeof(real_T));
            memcpy(tab, TAB, numc*numc*sizeof(real_T));

            #ifdef DEBUG
            printf("Tableau (is it modified?): %f",tab[0]);
            #endif

            /* Call QP optimizer and check if problem was feasible */
            iret = dantzg(tab, &numc, &numc, &nuc, basis, ib, il, &maxiter);
            if (iret > 0) {

                #ifdef MATLAB_MEX_FILE /* return error messages, unless code is compiled for RTW */
                if (iret > maxiter) {
                    printf("Warning: maximum number of iterations exceeded, solution is unreliable. Please augment Optimizer.MaxIter.");
                }
                #endif

                /* Feasible, extract the solution */

                #ifdef DEBUG
                printf("Feasible!\n");
                #endif

                /*
                   for j=1:nvar
                     if il(j) <= 0
                         zopt(j)=zmin(j);
                      else
                         zopt(j)=basis(il(j))+zmin(j);
                      end
                    end
                 */

                zopt = mxMalloc(nvar*sizeof(real_T));
                for (i=0; i<nvar; i++) {

                    #ifdef DEBUG
                    printf("IL %d\n",il[i]);
                    #endif

                    if (il[i] <= 0) {
                        zopt[i]=zmin[i];
                    }
                    else {
                        zopt[i]=basis[il[i]-1]+zmin[i];
                    }

                    #ifdef DEBUG
                    printf("Zopt %f\n",zopt[i]);
                    #endif

                }
            }
            else {

                /* Unfeasible, recall last optimal sequence
                   This should never happen
                 */

                #ifdef DEBUG
                printf("Unfeasible!\n");
                #endif

                #ifdef MATLAB_MEX_FILE /* return error messages, unless code is compiled for RTW */
                if (iret == numc * -3) {
                    printf("Warning: problems with QP solver -- Unable to delete a variable from basis");
                    #ifdef DEBUG
                    printf("basis=[");
                    for (i=0;i<numc;i++) {
                        printf("%g",basis[i]);
                        if (i<numc-1)
                            printf(",");
                    }
                    printf("]\n");
                    #endif
                    printf("Using previous optimal sequence ...\n");
                }
                else {
                    printf("Warning: QP problem infeasible, using previous optimal sequence ...\n");
                }
                #endif

                /* POSSIBLE OTHER DEFAULT: zopt=0, so that u(t)=last_u+0=last_u */
                /*  duold=Jm*optimalseq;
                    zopt=[duold(1+nu:nu*p);zeros(nu,1)]; % shifts

                    % Rebuilds optimalseq from zopt
                    %mxFree=find(kron(DUFree(:),ones(nu,1))); % Indices of mxFree moves
                    mxFree=find(DUFree(:));
                    epsslack=Inf; % Slack variable for soft output constraints
                    zopt=zopt(mxFree);
                */

                zopx = mxMalloc(nu*p*sizeof(real_T));
                zopt = mxMalloc(mxGetM(p_optimalseq(S))*sizeof(real_T));
                for (i=0; i<(int_T)mxGetM(p_optimalseq(S)); i++) {
                    zopt[i]=0.0;
                }
                duold = mxMalloc(mxGetM(p_Jm(S))*sizeof(real_T));
                for (i=0; i<(int_T)mxGetM(p_Jm(S)); i++) {
                    CLR;
                    MVP(mxGetPr(p_Jm(S)), optimalseq, i, (int_T)mxGetM(p_Jm(S)), (int_T)mxGetN(p_Jm(S)));
                    duold[i]=adder;
                }

                for (i=nu; i<nu*p; i++) {
                    zopx[i-nu]=duold[i];
                }
                for (i=nu*(p-1); i<nu*p; i++) {
                    zopx[i]=0.0;
                }

                /* Find mxFree moves */

                j=0;
                for (i=0; i<(int_T)mxGetM(p_DUFree(S)); i++) {
                    if ((int_T)(mxGetPr(p_DUFree(S))[i]) != 0) {
                        zopt[j++]=zopx[i];
                    }
                }

            }

            /* Rebuild optimalseq */
            /* printf("%d, %d\n",mxGetM(p_optimalseq(S)),degrees); */
            for (i=0; i<degrees; i++) {
                optimalseq[i]=zopt[i];
            }

        }
        #ifdef DEBUG
        printf("zopt[0] %f\n",zopt[0]);
        #endif

        /* Compute current input and update lastu */
        for (i=0; i<nu; i++){
            lastu[i] += zopt[i];
        }
    } /* End "if (do_optimization) ..." */
    else {
        /* Returns u=0. */
        for (i=0; i<nu; i++) {
            lastu[i] = -uoff[i];
        }
    }
    for (i=0; i<nu; i++){
        u_out[i] = lastu[i]+uoff[i];
        #ifdef DEBUG
        printf("Lastu %f\n",lastu[i]);
        #endif
    }

    if (ztemp != NULL) {mxFree(ztemp); ztemp = NULL;}
    if (zopx != NULL) {mxFree(zopx); zopx = NULL;}
    if (duold != NULL) {mxFree(duold); duold = NULL;}
    if (rhsc != NULL) {mxFree(rhsc); rhsc = NULL;}
    if (rhsa != NULL) {mxFree(rhsa); rhsa = NULL;}            
    if (basis != NULL) {mxFree(basis); basis = NULL;}            
    if (ib != NULL) {mxFree(ib); ib = NULL;}
    if (il != NULL) {mxFree(il); il = NULL;}
    if (r != NULL) {mxFree(r); r = NULL;}
    if (ytilde != NULL) {mxFree(ytilde); ytilde = NULL;}
    if (vKv != NULL) {mxFree(vKv); vKv = NULL;}
    if (Mvv != NULL) {mxFree(Mvv); Mvv = NULL;}       
    if (zopt != NULL) {mxFree(zopt); zopt = NULL;}        
    if (tab != NULL) {mxFree(tab); tab = NULL;}        
        
} /* End of MDL_OUTPUTS */

/* updateObserver(const mxArray *S, int_T tid, real_T *lastx, real_T *lastu, real_T *v, long int *lastt) */
/* MDLUPDATE */
static void updateObserver(const mxArray *S, int_T tid, real_T *lastx, real_T *lastu, real_T *v, long int *lastt)
{
    static int_T nu, nx, nv;
    static real_T *A, *Bu, *Bv;
    
    
    real_T *xk = NULL; /* Temporary state update */
    
    int_T i,j;
    real_T adder = 0;
    
    #ifdef DEBUG
    printf("UPDATE\n");
    #endif
    
    /* Initialize vars from structure S */
    if (tid==0) {
        nu = (int_T)*mxGetPr(p_nu(S));   /* Size of input vector */
        nx = (int_T)*mxGetPr(p_nx(S));   /* Size of extended state vector */
        nv = (int_T)*mxGetPr(p_nv(S));   /* Size of current meas. dist. vect. */
        A = mxGetPr((real_T *)p_A(S));
        Bu = mxGetPr((real_T *)p_Bu(S));
        Bv = mxGetPr((real_T *)p_Bv(S));
    }
    
    /* Time update of state observer */
    
    xk = mxMalloc(nx*sizeof(real_T));
    
    for (i=0; i<nx; i++) {
        CLR;
        MVP(A, lastx, i, nx, nx);
        MVP(Bu, lastu, i, nx, nu);
        MVP(Bv, v, i, nx, nv);
        xk[i]=adder;
        
        #ifdef DEBUG
        printf("Time update: xk[%d]: %f\n",i,xk[i]);
        #endif
        
    }
    
    memcpy(lastx, xk, nx*sizeof(real_T));
    
     /* update lastt */
    *lastt += 1;
    
    #ifdef DEBUG
    printf("Lastt: %d\n",*lastt);
    #endif
    
    if (xk != NULL) {mxFree(xk); xk = NULL;}            
}

static void mpcloop_engine( double *UU, double *YY, double *XP,  double *XMPC, const mxArray *S)

{
    int i,j;
    
    long int t; /* simulation time */
    
    /* Retrieve some useful constants */
    
    int nu = (int)*mxGetPr(p_nu(S));    /* Size of manipulated input vector */
    int nx = (int)*mxGetPr(p_nx(S));    /* Size of state vector */
    int ny = (int)*mxGetPr(p_ny(S));    /* Size of output vector*/
    int nym = (int)*mxGetPr(p_nym(S));  /* Size of measured output vector*/
    int nv = (int)*mxGetPr(p_nv(S));    /* Size of measured disturbance vector*/
    int ndp = (int)*mxGetPr(p_ndp(S));  /* Size of unmeasured disturbance vector to simulation model*/
    int nxp = (int)*mxGetPr(p_nxp(S));  /* Size of state vector of simulation model*/
    
    /* Define pointers to structure elements (to speed up simulation):*/
    real_T *xp0 = mxGetPr(p_xp0(S));    /* initial conditions */
    real_T *md_signal = mxGetPr(p_md_signal(S));  /* meas. dist. signal */
    real_T *ud_signal = mxGetPr(p_ud_signal(S));  /* unmeas. dist. signal*/
    real_T *mn_signal = mxGetPr(p_mn_signal(S));  /* Y meas. noise signal*/
    real_T *un_signal = mxGetPr(p_un_signal(S));  /* U noise signal*/
    int Nmd = mxGetN(p_md_signal(S));
    int Nud = mxGetN(p_ud_signal(S));
    int Nmn = mxGetN(p_mn_signal(S));
    int Nun = mxGetN(p_un_signal(S));
    real_T *Cp = mxGetPr(p_Cp(S));
    real_T *Dvp = mxGetPr(p_Dvp(S));
    real_T *Ddp = mxGetPr(p_Ddp(S));
    real_T *Ap = mxGetPr(p_Ap(S));
    real_T *Bup = mxGetPr(p_Bup(S));
    real_T *Bvp = mxGetPr(p_Bvp(S));
    real_T *Bdp = mxGetPr(p_Bdp(S));
    real_T *myindex = mxGetPr(p_myindex(S));
    real_T *xpoff = mxGetPr(p_xpoff(S));       /* plant state offset */
    real_T *dxpoff = mxGetPr(p_dxpoff(S));     /* plant state derivative/increment offset */
    real_T *xoff = mxGetPr(p_xoff(S));         /* state offset of MPC plant model */
    real_T *ypoff = mxGetPr(p_ypoff(S));       /* plant y-offset */
    
    int p = (int)*mxGetPr(p_p(S));             /* Prediction horizon */
    
    long int Tf = (long int) *mxGetPr(p_Tf(S));/* Total simulation time*/
    
    boolean_T unconstr = (boolean_T) *mxGetPr(p_unconstr(S)); /* =1 means remove MPC constraints */
    boolean_T openloop = (boolean_T) *mxGetPr(p_openloop(S)); /* =1 means do open-loop simulation */
    real_T *mv_signal = mxGetPr(p_mv_signal(S));  /* U signal (with offset) for open-loop simulation*/
    
    real_T adder;     /* Accumulator*/

    real_T *lastx, *lastu, *optimalseq, *v, *y, *r, *u, *ym, *v_t, *d_t, *yn_t, *un_t, *x_t;
    long int *lastt;
    real_T *deltayoff;   /* difference plant-nominal y.offset */
    real_T *deltauoff;   /* difference plant-nominal u.offset*/
    real_T *deltavoff;   /* difference plant-nominal v.offset*/
    real_T *xaux;     /* Temporary storage for state update*/
    real_T *vp_t, *up_t;
    /*real_T *mv_t;*/

    /*#ifdef WAITBAR*/
    mxArray *rhs[2];         /* waitbar handle and value. If handle=-1, then no bar is drawn*/
    real_T bar_time=0;


    /* Set vars for waitbar and counter*/
    rhs[0] =  mxCreateDoubleMatrix(1, 1, mxREAL); /*fraction of time*/
    rhs[1] = p_barhandle(S); /* get pointer to handle from structure*/
    /*#endif*/

    lastx = mxCalloc(nx,sizeof(real_T));
    lastu = mxCalloc(nu,sizeof(real_T));
    optimalseq = mxCalloc(mxGetM(p_optimalseq(S)),sizeof(real_T));
    v = mxCalloc((p+1)*nv,sizeof(real_T));  /* measured disturbance (sequence) given to MPC (w/out offsets)*/
    v_t = mxCalloc(nv,sizeof(real_T));      /* current meas. dist. (with nominal offset)*/
    d_t = mxCalloc(ndp,sizeof(real_T));     /* current unmeas. dist.*/
    yn_t = mxCalloc(nym,sizeof(real_T));    /* current meas. noise*/
    un_t = mxCalloc(nu,sizeof(real_T));     /* current noise on manipulated vars*/
    x_t = mxCalloc(nxp,sizeof(real_T));     /* plant state (without offsets)*/
    lastt = mxCalloc(1,sizeof(long int));
    vp_t = mxCalloc(nv,sizeof(real_T));     /* current meas. dist. (with plant offset)*/
    up_t = mxCalloc(nu,sizeof(real_T));     /* current input (with plant offset)*/
    xaux = mxCalloc(nxp,sizeof(real_T));    /* temporary storage for state update*/
    y = mxCalloc(ny,sizeof(real_T));
    r = mxCalloc(ny*p,sizeof(real_T));
    u = mxCalloc(nu,sizeof(real_T));
    ym = mxCalloc(nym,sizeof(real_T));
    deltayoff = mxCalloc(ny,sizeof(real_T));
    deltauoff = mxCalloc(nu,sizeof(real_T));
    if (nv-1>0) {
        deltavoff = mxCalloc(nv-1,sizeof(real_T));
    }

    /*printf(">>DEBUG 1: OK!!!\n");*/


    /* Initialize lastx, lastu, optimalseq, lastt to parameter values*/

    memcpy(lastx, mxGetPr(p_lastx(S)), nx*sizeof(real_T));
    memcpy(lastu, mxGetPr(p_lastu(S)), nu*sizeof(real_T));
    memcpy(optimalseq, mxGetPr(p_optimalseq(S)), mxGetM(p_optimalseq(S))*sizeof(real_T));

    memcpy(deltayoff, mxGetPr(p_ypoff(S)), ny*sizeof(real_T));
    memcpy(deltauoff, mxGetPr(p_upoff(S)), nu*sizeof(real_T));

    if (nv-1>0) {
        memcpy(deltavoff, mxGetPr(p_vpoff(S)), (nv-1)*sizeof(real_T));
    }

    for (i=0;i<ny;i++) {
        deltayoff[i]-=mxGetPr(p_yoff(S))[i];
    }
    for (i=0;i<nu;i++) {
        deltauoff[i]-=mxGetPr(p_uoff(S))[i];
    }
    for (i=0;i<nv-1;i++) {
        deltavoff[i]-=mxGetPr(p_voff(S))[i];
    }

    /*Initial Plant state*/
    for (i=0; i<nxp; i++) {
        x_t[i]=xp0[i]-xpoff[i];
    }

    /* additional measured disturbance due to offsets*/
    for (i=0; i<p+1; i++) {
        v[i*nv+nv-1]=1.0;
    }

    *lastt=0;

    for (t=0; t<Tf; t++) {

        for (i=0; i<nxp; i++) { /*save current Plant state*/
            XP[t*nxp+i]=x_t[i]+xpoff[i];
        }

        if (!openloop) {
            for (i=0; i<nx; i++) { /*save current MPC state*/
                XMPC[t*nx+i]=lastx[i]+xoff[i];
            }
        }

        /* get current disturbance signals*/
        getrv(v_t,md_signal,t,t,nv-1,nv-1,Nmd);
        getrv(d_t,ud_signal,t,t,ndp,ndp,Nud);
        getrv(yn_t,mn_signal,t,t,nym,nym,Nmn);
        getrv(un_t,un_signal,t,t,nu,nu,Nun);

        /* Compute current output and save it*/
        /*DISP_VEC(x_t,nxp,"x_t")*/
        /*printf(">>DEBUG: t=%d, v_t[0]=%5.2f\n",t,v_t[0]);*/
        for (i=0; i<nv-1; i++) { /* Adjust v-offsets to plant offsets*/
            vp_t[i]=v_t[i]+deltavoff[i];
        }
        for (i=0; i<ny; i++) {
            CLR; /* i.e., adder = 0*/
            MVP(Cp, x_t, i, ny, nxp);
            MVP(Dvp, vp_t, i, ny, nv-1);
            MVP(Ddp, d_t, i, ny, ndp);
            y[i]=adder;
            YY[t*ny+i]=y[i]+ypoff[i]; /*save current output*/
        }

        /*DISP_VEC(deltayoff,ny,"deltayoff");*/
        /*DISP_VEC(y,ny,"y");*/

        if (openloop) {      	/* get current MV signal (with offset)*/
            getrv(u,mv_signal,t,t,nu,nu,Nun);
        }
        else {
            for (i=0; i<nym; i++) {
                j=(int)(myindex[i])-1;
                ym[i]=y[j]+deltayoff[j]+yn_t[i];
            }           
            /* if yoff~=ypoff, ym is offset-mxFree. Otherwise it is affected by*/
            /* an offset error due to wrong estimation of output nominal*/
            /* operating point*/

            /* reference signal (or MV signal) is loaded inside computeOtuputs*/

            /* measurement update of state observer + MPC computation*/
            computeOtuputs(S,t,lastx,lastu,v,optimalseq,lastt,v_t,ym,u,unconstr);
        }
        /* Save current input (lastu is already updated by computeOtuputs)*/
        /* and add noise*/

        /*DISP_VEC(deltauoff,nu,"deltauoff");*/

        for (i=0; i<nu; i++) {
            /*          if (openloop) {*/
            up_t[i]=u[i]-mxGetPr(p_uoff(S))[i]+un_t[i];  /*add input noise*/
            /*            UU[t*nu+i]=u[i]+un_t[i];*/
            /*		  }*/
            /*		  else {*/
            /*            up_t[i]=u[i]+deltauoff[i]+un_t[i];*/
            /*                    Adjust u-offsets to plant offsets + noise*/
            /*                    Nominal input offset is already included in u[i]*/
            /*            UU[t*nu+i]=up_t[i];*/
            /*        }*/
            UU[t*nu+i]=up_t[i]+mxGetPr(p_upoff(S))[i];
        }
        /*DISP_VEC(up_t,nu,"up_t")*/


        if (!openloop) {
            updateObserver(S,t,lastx,lastu,v_t,lastt);  /* time-update of state observer*/
        }

        /* Plant update*/

        /*DISP_MAT(mxGetPr(p_Bup(S)),nxp,nu,"Bup")*/

        /*DISP_VEC(x_t,nxp,"x_t(before)")*/
        for (i=0; i<nxp; i++) {
            CLR; /* i.e., adder = 0*/
            MVP(Ap, x_t, i, nxp, nxp);
            MVP(Bup, up_t, i, nxp, nu);
            /*DISP_ADDER(i)*/
            MVP(Bvp, vp_t, i, nxp, nv-1);
            MVP(Bdp, d_t, i, nxp, ndp);
            xaux[i]=adder+dxpoff[i];
        }

        /*Update Plant state vector*/
        memcpy(x_t,xaux, nxp*sizeof(real_T));
        /*DISP_VEC(x_t,nxp,"x_t(after)")*/

        /*printf(">>DEBUG: OK!!!\n");*/

        /*#ifdef WAITBAR*/
        if (*mxGetPr(rhs[1])>-1) {
            /* Update progress bar*/
            adder=(real_T)(t+1)/Tf;
            /*if (adder-bar_time>=.004) */ /*only allows updating waitbar up to 250 times*/
            if (adder-bar_time>=.04) { /*only allows updating waitbar up to 25 times*/
            /*adder=(real_T)(t+1)/Tf*100;*/
            /*if (adder-bar_time>=4)  */ /*only allows updating waitbar up to 25 times*/
                bar_time=adder;
                *mxGetPr(rhs[0])=(double)adder;

                mexCallMATLAB(0,NULL, 2, rhs, "waitbar");
                /*mexCallMATLAB(0,NULL, 0, NULL, "drawnow");*/

                /*mexCallMATLAB(0,NULL, 1, rhs, "mpc_set_bar");*/

                /*adder=*mxGetPr(rhs[1]);*/
                /*printf("h=%5.2f, t=%d, timebar=%5.5f\n",adder,t,bar_time);*/
                /*mexCallMATLAB(0,NULL, 0, NULL, "keyboard");*/
                /*mexCallMATLAB(0,NULL, 0,NULL, "global progress_bar");*/
                /*mexCallMATLAB(0,NULL, 1, rhs, "progress_bar.setValue");*/
                /*printf("%5.2f\n",adder);*/
            }
        }
        /*#endif*/
    }

    /*Release allocated memory*/
    mxFree(lastx);
    mxFree(lastu);
    mxFree(optimalseq);
    mxFree(v);
    mxFree(v_t);
    mxFree(d_t);
    mxFree(yn_t);
    mxFree(un_t);
    mxFree(x_t);
    mxFree(lastt);
    mxFree(vp_t);
    mxFree(up_t);
    mxFree(xaux);
    mxFree(y);
    mxFree(r);
    mxFree(u);
    mxFree(ym);
    mxFree(deltayoff);
    mxFree(deltauoff);
    if (nv-1>0) {
        mxFree(deltavoff);
    }
    
    mxDestroyArray(rhs[0]);

    return;

}

void mexFunction( int nlhs, mxArray *plhs[],
	int nrhs, const mxArray *prhs[] )

{
    double *u, *y, *xp, *xmpc;
    int Tf = (int)*mxGetPr(p_Tf(MPCstruct_IN));

    int nu = (int)*mxGetPr(p_nu(MPCstruct_IN));    /* Size of manipulated input vector*/
    int nx = (int)*mxGetPr(p_nx(MPCstruct_IN));    /* Size of state vector*/
    int ny = (int)*mxGetPr(p_ny(MPCstruct_IN));    /* Size of output vector*/
    int nym = (int)*mxGetPr(p_nym(MPCstruct_IN));  /* Size of measured output vector*/
    int nv = (int)*mxGetPr(p_nv(MPCstruct_IN));    /* Size of measured disturbance vector*/
    int nxp = (int)*mxGetPr(p_nxp(MPCstruct_IN));  /* Size of state vector of simulation model*/
 
    /* Create a matrix for the return argument: vector dim=#rows, time-steps=#columns*/
    U_OUT = mxCreateDoubleMatrix(nu,Tf,mxREAL);
    Y_OUT = mxCreateDoubleMatrix(ny,Tf,mxREAL);
    XP_OUT = mxCreateDoubleMatrix(nxp,Tf,mxREAL);
    XMPC_OUT = mxCreateDoubleMatrix(nx,Tf,mxREAL);

    /* Assign pointers to the various parameters*/
    u = mxGetPr(U_OUT);
    y = mxGetPr(Y_OUT);
    xp = mxGetPr(XP_OUT);
    xmpc = mxGetPr(XMPC_OUT);

    
    /* Do the actual computations in a subroutine*/
    mpcloop_engine(u,y,xp,xmpc,MPCstruct_IN);

    /*printf("DEBUG: Type 'return' to continue (probably Matlab will crash !) \n");*/
    /*mexCallMATLAB(0,NULL, 0, NULL, "keyboard");*/
    return;
}
