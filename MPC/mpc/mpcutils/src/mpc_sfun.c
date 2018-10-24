/* mpc_sfun.c: Online MPC controller - Simulink/RTW S-Function */

/*
        Author: A. Bemporad
        Initial function prototype by G. Bianchini (2001-2002)
        Revised by: R. Chen
        Copyright 1986-2008 The MathWorks, Inc.
        $Revision: 1.1.10.19 $  $Date: 2009/11/09 16:28:24 $
 */

#define S_FUNCTION_NAME  mpc_sfun
#define S_FUNCTION_LEVEL 2

#include "mpc_sfun.h"

/* Merge common source */
/*
// MPC_COMMON.C contains the following functions
//      dantzg
//      getrv
 */
#include "mpc_common.c"

/* S-Function callback methods */
static void mdlInitializeSizes (SimStruct *S)   /*Initialise the sizes array */
{
    
    int_T TOTALPORTNUMBER = 9;
    int_T openloopflag;
    
    /*
    // The open-loop behavior is modelled by the state space "open circuit" system
    // (no direct feedthrough)
    //
    // x(k+1) = x(k)
    // y(k)   = x(k), where x(k),y(k) have dimension nu (=number of MVs)
    */
    
    int_T nu; /* Size of input vector */
    int_T nx; /* Size of state vector */
    int_T nym;
    int_T ny;
    int_T nv;
    int_T nxQP; /* Size of state vector without Noise model states */
    int_T i;
    int_T status;
    
    boolean_T no_md; /* no_md=1 means no MD connected */
    boolean_T no_ref; /* no_ref=1 means no reference connected */
    boolean_T no_ym; /* no_ym=1 means no measured output connected */
    boolean_T md_inport; /* md_inport=1 means MD port is enabled */
    boolean_T no_mv; /* no_mv=1 means no external MV connected */
    boolean_T mv_inport; /* mv_inport=1 means ext.MV port is enabled */
    boolean_T lims_inport; /* lims_inport=1 means ports for limits are enabled */
    boolean_T no_umin; /* no_umin=1 means no external UMIN signal connected */
    boolean_T no_umax; /* no_umax=1 means no external UMAX signal connected */
    boolean_T no_ymin; /* no_ymin=1 means no external YMIN signal connected */
    boolean_T no_ymax; /* no_ymax=1 means no external YMAX signal connected */
    
    openloopflag = (int_T)*mxGetPr(p_openloopflag(S));
    /* printf("%s: openloopflag=%d\n","mdlInitializeSizes",openloopflag); */
    
    nu = (int_T)*mxGetPr(p_nu(S)); /* Size of input vector */
    if (nu==0){
        ssSetErrorStatus(S, "MPC Block is empty. Open the MPC designer to create an MPC controller");
        return;
    }
    
    /* when openloopflag is 0, there is a @mpc object associated with the block */
    /* when openloopflag is 1, the block block is forced to one state*/
    if (openloopflag==0){
        nx = (int_T)*mxGetPr(p_nx(S)); /* Size of state vector */
        nym = (int_T)*mxGetPr(p_nym(S));
        ny = (int_T)*mxGetPr(p_ny(S));
        nv = (int_T)*mxGetPr(p_nv(S));
        nxQP = (int_T)*mxGetPr(p_nxQP(S)); /* Size of state vector without Noise model states */
        no_md = (boolean_T) *mxGetPr(p_no_md(S));   /* no_md=1 means no MD connected */
        no_ref =  (boolean_T) *mxGetPr(p_no_ref(S)); /* no_ref=1 means no reference connected */
        no_ym =  (boolean_T) *mxGetPr(p_no_ym(S)); /* no_ym=1 means no measured output connected */
        md_inport =  (boolean_T) *mxGetPr(p_md_inport(S)); /* md_inport=1 means no MD signal is enabled */
       
        no_mv = (boolean_T) *mxGetPr(p_no_mv(S));   /* no_mv=1 means no ext. MV connected */
        mv_inport =  (boolean_T) *mxGetPr(p_mv_inport(S)); /* mv_inport=1 means no ext. MV signal is enabled */
        
        lims_inport =  (boolean_T) *mxGetPr(p_lims_inport(S)); /* lims_inport=1 means I/O limits are enabled */
        no_umin = (boolean_T) *mxGetPr(p_no_umin(S));   /* no_umin=1 means no external UMIN signal connected */
        no_umax = (boolean_T) *mxGetPr(p_no_umax(S));   /* no_umax=1 means no external UMAX signal connected */
        no_ymin = (boolean_T) *mxGetPr(p_no_ymin(S));   /* no_ymin=1 means no external YMIN signal connected */
        no_ymax = (boolean_T) *mxGetPr(p_no_ymax(S));   /* no_ymax=1 means no external YMAX signal connected */
    }
    
    ssSetNumSFcnParams(S, NPARAMS);  /* Expected number of parameters */
    
    if (ssGetNumSFcnParams(S) == ssGetSFcnParamsCount(S)) {
        if (ssGetErrorStatus(S) != NULL) {
            return; /* Parameter type error */
        }
    }
    else {
        ssSetErrorStatus(S, param_MSG);
        return; /* Parameter number mismatch */
    }
    
    /* No continuous states */
    ssSetNumContStates(S, 0);
    
    if (openloopflag==0) {
        ssSetNumDiscStates(S, nx+nu); /* register lastx and lastu as states */
    }
    else {
        ssSetNumDiscStates(S, nu);   /* open-loop: x(k+1)=x(k), y(k)=x(k), dim(y)=dim(x)=nu */
    }
    
    /* Set up # of input ports */
    if (!ssSetNumInputPorts(S, TOTALPORTNUMBER)) {
        return;
    }
    
    /* Set up dimension of input ports */
    if (openloopflag==0){
        #ifdef DEBUG
        printf("%s\n","Closed loop port assignment");
        printf("ny=%d, nym=%d, nv=%d, nu=%d\n",ny,nym,nv,nu);
        printf("no_ref=%d, no_md=%d, no_ym=%d, md_inport=%d, no_mv=%d, mv_inport=%d\n",no_ref,no_md,no_ym,md_inport,no_mv,mv_inport);
        #endif
        status = ssSetInputPortVectorDimension(S,0,nym*(1-no_ym)+no_ym);
        status = ssSetInputPortVectorDimension(S,1,ny*(1-no_ref)+no_ref);
        status = ssSetInputPortVectorDimension(S,2,(nv-1)*(1-no_md)+no_md);
        status = ssSetInputPortVectorDimension(S,3,nu*(1-no_mv)+no_mv);
        status = ssSetInputPortVectorDimension(S,4,nu*(1-no_umin)+no_umin);
        status = ssSetInputPortVectorDimension(S,5,nu*(1-no_umax)+no_umax);
        status = ssSetInputPortVectorDimension(S,6,ny*(1-no_ymin)+no_ymin);
        status = ssSetInputPortVectorDimension(S,7,ny*(1-no_ymax)+no_ymax);
        status = ssSetInputPortVectorDimension(S,8,1);
    }
    else
    {
        #ifdef DEBUG
        printf("%s\n","Open loop port assignment");
        #endif
        for (i=0; i<TOTALPORTNUMBER-1; i++) {
            status = ssSetInputPortVectorDimension(S,i,DYNAMICALLY_SIZED);
        }
        status = ssSetInputPortVectorDimension(S,8,1);
    }
    
    /* Set up # of output ports */
    if (!ssSetNumOutputPorts(S,1)) { /* one output port */
        return;
    }
    
    /* Set up dimension of output ports */
    status = ssSetOutputPortVectorDimension(S, 0, nu);
    
    /* Set up direct feedthrough of input ports */
    if (openloopflag==0 ) {
        /* printf("%s\n","Direct feed through"); */
        
        /* u depends on current ym, ref, md signals */
        for (i=0; i<3; i++) {
            ssSetInputPortDirectFeedThrough(S,i,1);
        }
        /* u does not depend on ext.MV signal */
        ssSetInputPortDirectFeedThrough(S,3,0);
        /* u depends on current I/O bounds, and switch signal */
        for (i=4; i<TOTALPORTNUMBER; i++) {
            ssSetInputPortDirectFeedThrough(S,i,1);
        }
    }
    else{
        #ifdef DEBUG
        printf("%s\n","No direct feed through");
        #endif
        for (i=0; i<TOTALPORTNUMBER; i++) {
            ssSetInputPortDirectFeedThrough(S,i,0);
        }
    }
    
    /* One sample time */
    ssSetNumSampleTimes(S, 1);
    
    /*  Number of work dynamic variables */
    ssSetNumPWork(S,NPWORK);
    
    ssSetOptions(S, SS_OPTION_EXCEPTION_FREE_CODE);
}


static void mdlInitializeSampleTimes(SimStruct *S)
{
    real_T ts = (real_T)*mxGetPr(p_Ts(S));
    
    int_T openloopflag = (int_T)*mxGetPr(p_openloopflag(S));
    #ifdef DEBUG
    printf("%s\n","mdlInitializeSampleTimes");
    #endif
    
    /* when openloopflag is 0, there is a @mpc object associated with the block */
    /* when openloopflag is 1, the block block is forced to one state*/
    if (( openloopflag==0) & (ts > 0)) { /*AB: ts was set as the sampling time only if ts>0 */
        ssSetSampleTime(S, 0, ts);
    }
    else {
        ssSetSampleTime(S, 0, INHERITED_SAMPLE_TIME);
    }
    
    ssSetOffsetTime(S, 0, 0.0);
}

#define MDL_INITIALIZE_CONDITIONS
static void mdlInitializeConditions(SimStruct *S)

{
    /* NOTE: static variables would be shared by multiple MPC blocks ! */
    
    int_T i;
    
    real_T *states; /* pointer to s-function states, also used if openloopflag=1
                     When openloopflag=1, there are nu states. Otherwise, nx+nu states.
                     If RTW is used, then there're no states
                     */
    
    real_T *lastx;
    real_T *lastu;
    real_T *optimalseq;
    real_T *v;
    long int *lastt;
    
    real_T *tab;
    real_T *r;
    real_T *ytilde;
    real_T *vKv;
    real_T *Mvv;
    real_T *zopt1;
    real_T *zopt2;
    real_T *zopt3;
    real_T *zopx;
    real_T *ztemp;
    real_T *rhsc;
    real_T *rhsa;
    real_T *basis;
    long int *ib;
    long int *il;
    real_T *duold;
    real_T *umin;
    real_T *umax;
    real_T *ymin;
    real_T *ymax;
    real_T *xk;
    real_T *lastx_buf;
    real_T *lastu_buf;
    
    /* Retrieve some useful constants */
    int_T nu,nx,nv,ny,nym;
    int_T PTYPE,p,nvar,degrees,useslack,q,numc;
    
    int_T openloopflag = (int_T)*mxGetPr(p_openloopflag(S));
    
    /* printf("%s\n","mdlInitializeConditions"); */
    nu = (int_T)*mxGetPr(p_nu(S)); /* Size of input vector */
    nx = (int_T)*mxGetPr(p_nx(S)); /* Size of extended state vector */
    nv = (int_T)*mxGetPr(p_nv(S)); /* Size of current meas. dist. vect */
    ny = (int_T)*mxGetPr(p_ny(S)); /* Size of all outputs */
    nym = (int_T)*mxGetPr(p_nym(S)); /* Size of measured outputs */
    p = (int_T)*mxGetPr(p_p(S)); /* Prediction horizon */

    degrees = (int_T)*mxGetPr(p_degrees(S));
    PTYPE = (int_T)*mxGetPr(p_PTYPE(S));
    if (PTYPE == SOFTCONSTR)
        useslack = 1;
    else
        useslack = 0;
    q = mxGetM(p_Mlim(S));          
    nvar = degrees+useslack;
    numc = nvar + q;    
    
    states = ssGetRealDiscStates(S);
    /* printf("states: ["); for (i=0;i<nu+nx;i++) printf("%g,",states[i]); printf("]\n"); */
    
    /* when openloopflag is 1, the block block is forced to one state*/
    if (openloopflag==1) {
        #ifdef DEBUG
        printf("%s\n","initializing");
        #endif
       /* Initialize state vector and return */
       /*nu = ssGetOutputPortWidth(S, 0);*/   /* Size of input vector */
        for (i=0; i<nu; i++) {
            states[i]=0.0;
        }                   /* AB: SHOULDN'T THIS BE THE INPUT OFFSET uoff, */
                            /* OR EVEN BETTER lastu PASSED FROM THE MASK ? */
                            /* Yes but if there is no MPC obj we must assume 0 */
        #ifdef DEBUG
        printf("%s\n","initialized");
        #endif
        return;
    }
    
    /* Initialize lastx, lastu, optimalseq, lastt to parameter values */
    lastx = calloc(nx,sizeof(real_T));
    lastu = calloc(nu,sizeof(real_T));
    optimalseq = calloc(mxGetM(p_optimalseq(S)),sizeof(real_T));
    v = calloc((p+1)*nv,sizeof(real_T));
    lastt = calloc(1,sizeof(long int));
    
    tab = calloc(numc*numc,sizeof(real_T));
    r = calloc(p*ny,sizeof(real_T)); /* reference signal vector r from workspace */
    ytilde = calloc(nym,sizeof(real_T));
    vKv = calloc(degrees,sizeof(real_T));
    Mvv = calloc(q,sizeof(real_T)); /* q=number of constraints */
    ztemp = calloc(degrees,sizeof(real_T)); /* stores linear term of the cost function */
    zopt1 = calloc(degrees,sizeof(real_T));
    rhsc = calloc(q,sizeof(real_T));
    umin = calloc(nu,sizeof(real_T)); /* umin */
    umax = calloc(nu,sizeof(real_T)); /* umax */
    ymin = calloc(ny,sizeof(real_T)); /* ymin */
    ymax = calloc(ny,sizeof(real_T)); /* ymax */
    rhsa = calloc(nvar,sizeof(real_T));
    basis = calloc(numc,sizeof(real_T));
    ib = calloc(numc,sizeof(long int));
    il = calloc(numc,sizeof(long int));
    zopt2 = calloc(nvar,sizeof(real_T));
    zopx = calloc(nu*p,sizeof(real_T));
    zopt3 = calloc(mxGetM(p_optimalseq(S)),sizeof(real_T));
    duold = calloc(mxGetM(p_Jm(S)),sizeof(real_T));
    xk = calloc(nx,sizeof(real_T));    
    lastx_buf = calloc(nx,sizeof(real_T));
    lastu_buf = calloc(nu,sizeof(real_T));
    
    memcpy(lastx, mxGetPr(p_lastx(S)), nx*sizeof(real_T));
    memcpy(lastu, mxGetPr(p_lastu(S)), nu*sizeof(real_T));
    memcpy(optimalseq, mxGetPr(p_optimalseq(S)), mxGetM(p_optimalseq(S))*sizeof(real_T));
    for (i=0; i<p+1; i++) {
        v[i*nv+nv-1]=1.0; /* additional measured disturbance due to offsets */
    }
    
    ssSetPWorkValue(S, w_lastx, lastx);
    ssSetPWorkValue(S, w_lastu, lastu);
    ssSetPWorkValue(S, w_v, v);
    ssSetPWorkValue(S, w_optimalseq, optimalseq);
    ssSetPWorkValue(S, w_lastt, lastt);
    
    ssSetPWorkValue(S, w_r, r);
    ssSetPWorkValue(S, w_ytilde, ytilde);
    ssSetPWorkValue(S, w_vKv, vKv);
    ssSetPWorkValue(S, w_Mvv, Mvv);
    ssSetPWorkValue(S, w_zopt1, zopt1);
    ssSetPWorkValue(S, w_zopt2, zopt2);
    ssSetPWorkValue(S, w_zopt3, zopt3);
    ssSetPWorkValue(S, w_zopx, zopx);
    ssSetPWorkValue(S, w_ztemp, ztemp);
    ssSetPWorkValue(S, w_rhsc, rhsc);
    ssSetPWorkValue(S, w_rhsa, rhsa);
    ssSetPWorkValue(S, w_basis, basis);
    ssSetPWorkValue(S, w_ib, ib);
    ssSetPWorkValue(S, w_il, il);
    ssSetPWorkValue(S, w_duold, duold);
    ssSetPWorkValue(S, w_umin, umin);
    ssSetPWorkValue(S, w_umax, umax);
    ssSetPWorkValue(S, w_ymin, ymin);
    ssSetPWorkValue(S, w_ymax, ymax);
    ssSetPWorkValue(S, w_xk, xk);
    ssSetPWorkValue(S, w_lastx_buf, lastx_buf);
    ssSetPWorkValue(S, w_lastu_buf, lastu_buf);
    ssSetPWorkValue(S, w_tab, tab);

    for (i=0; i<nx; i++) {
        states[i]=lastx[i];
    }
    for (i=0; i<nu; i++) {
        states[nx+i]=lastu[i];
    }
    
}

/* MDLOUTPUT */
static void mdlOutputs(SimStruct *S, int_T tid)
/* Note that tid = Task ID */
{
    /* NOTE: static variables are shared by multiple MPC blocks ! */
    
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
    
    /* Variables for detecting if meas.dist, refs, and user-supplied MVs are connected to MPC block */
    static boolean_T md_inport, lims_inport, no_umin, no_umax, no_ymin, no_ymax;
    static boolean_T switch_inport, no_switch, is_multiple;
    static real_T enable_value;
    
    static boolean_T ref_from_ws, ref_preview, md_from_ws, md_preview;
    static int_T Nref_signal, Nmd_signal;
    static boolean_T isemptyKv;
    
    /* Counters */
    int_T i,j;
    int_T h;
    int_T numc;
    
    /* Accumulator */
    real_T adder = 0;
    real_T cache = 0;
    
    /* Local work variables */
    real_T *r;       
    real_T *ytilde;  
    real_T *vKv;
    real_T *Mvv;
    real_T *zopt;    
    real_T *zopx;
    real_T *ztemp;
    real_T *rhsc;
    real_T *rhsa;
    real_T *basis;
    long int *ib;
    long int *il;
    real_T *duold;
    real_T *tab;            /* Tableau for QP */
    real_T *umin;           /* local copy of umin for time-varying bounds */
    real_T *umax;           /* local copy of umax for time-varying bounds */
    real_T *ymin;           /* local copy of ymin for time-varying bounds */
    real_T *ymax;           /* local copy of ymax for time-varying bounds */

    int nuc = 0;            /* number of unconstrained vars in DANTZGMP */
    int iret;               /* DANTZGMP return code */
    
    /* Input and output vectors */
    
    real_T *openloopstates;
    #ifndef RT
        real_T *discstates;
    #endif

    real_T *u_out;
    real_T *optimalseq;
    real_T *v;
    long int *lastt;
    real_T *lastx;
    real_T *lastu;
    
    InputRealPtrsType ymPtrs;  /* pointers to input port signals */
    InputRealPtrsType refPtrs;
    InputRealPtrsType mdPtrs;
    InputRealPtrsType uminPtrs;
    InputRealPtrsType umaxPtrs;
    InputRealPtrsType yminPtrs;
    InputRealPtrsType ymaxPtrs;
    InputRealPtrsType switchPtrs;    
    
    real_T *wlastx;
    real_T *wlastu;
            
    int_T openloopflag = (int_T)*mxGetPr(p_openloopflag(S));
    
    #ifdef DEBUG
    printf("tid=%d\n",tid);
    printf("mdlout\n");
    #endif
    
    if (openloopflag==1) {
        #ifdef DEBUG
        printf("%s","get disc states");
        #endif
        u_out = ssGetOutputPortRealSignal(S,0);
        nu = ssGetOutputPortWidth(S, 0);   /* Size of input vector */

        openloopstates = ssGetDiscStates(S);
        #ifdef DEBUG
        printf("%f",openloopstates[0]);
        #endif
        for (i=0; i<nu; i++) {
            u_out[i] = openloopstates[i];
        }

        return;
    }
    
    /* (jgo) Copy 0:nx-1 of the disc states vector to lastx
       Copy nx:nx+nu-1 of the disc states vector or last u */
    nu = (int_T)*mxGetPr(p_nu(S));   /* Size of input vector */
    nx = (int_T)*mxGetPr(p_nx(S));   /* Size of extended state vector */
    lastx = ssGetPWorkValue(S,w_lastx_buf);
    lastu = ssGetPWorkValue(S,w_lastu_buf);
    #ifndef RT
    discstates = ssGetDiscStates(S);
    memcpy(lastx, discstates, nx*sizeof(real_T));
    memcpy(lastu, discstates+nx, nu*sizeof(real_T));
    #else
    memcpy(lastx, ssGetPWorkValue(S,w_lastx), nx*sizeof(real_T));
    memcpy(lastu, ssGetPWorkValue(S,w_lastu), nu*sizeof(real_T));
    #endif
    
    optimalseq = ssGetPWorkValue(S, w_optimalseq);
    v = ssGetPWorkValue(S,w_v);
    lastt = ssGetPWorkValue(S,w_lastt);
    
    do_optimization=(boolean_T) 1;
    
    is_multiple = (boolean_T) *mxGetPr(p_is_multiple(S));
    /* is_multiple distinguishes between stand-alone and multiple MPC blocks.
    is_multiple=1 means block belongs to a set of multiple MPC's.
    If is_multiple=1, then all signals are connected to the block, but
    MD / LIMS signals are meaningful only if md_inport / lims_inport are
    equal to 1 */
    
    /* Determine value of switching signal enabling the optimization (from 1 to N) */
    
    enable_value = (real_T) *mxGetPr(p_enable_value(S));
    
    switch_inport = (boolean_T) *mxGetPr(p_switch_inport(S));   /* switch_inport=TRUE means SWITCH inport exists */
    
    if (switch_inport) {
        no_switch = (boolean_T) *mxGetPr(p_no_switch(S));   /* no_switch=TRUE means no SWITCH connected */
        if (no_switch) {
            /* Don't do any optimization */
            do_optimization=(boolean_T) 0;
        }
        else
        {
            switchPtrs = ssGetInputPortRealSignalPtrs(S,8); /* get signal from inport #9 */
            if (!no_switch) {
                /* switching signal exists and is connected */
                if (!(*switchPtrs[0]==enable_value))
                    do_optimization=(boolean_T) 0;
            }
        }
    }
    
    /* Get vars from structure S. They are initialized every time, because there might be multiple blocks in the diagram sharing the same static variables */
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

    md_inport = (boolean_T) *mxGetPr(p_md_inport(S));   /* md_inport=TRUE means MD inport exists */
    lims_inport = (boolean_T) *mxGetPr(p_lims_inport(S));   /* lims_inport=TRUE means LIMS inports exist */
    no_md = (boolean_T) *mxGetPr(p_no_md(S));   /* no_md=TRUE means no MD connected */
    no_ref = (boolean_T) *mxGetPr(p_no_ref(S)); /* no_ref=TRUE means no reference connected */
    no_ym = (boolean_T) *mxGetPr(p_no_ym(S));   /* no_ym=TRUE means no meas. output connected */
    no_umin = (boolean_T) *mxGetPr(p_no_umin(S));   /* no_umin=TRUE means no UMIN connected */
    no_umax = (boolean_T) *mxGetPr(p_no_umax(S));   /* no_umax=TRUE means no UMAX connected */
    no_ymin = (boolean_T) *mxGetPr(p_no_ymin(S));   /* no_ymin=TRUE means no YMIN connected */
    no_ymax = (boolean_T) *mxGetPr(p_no_ymax(S));   /* no_ymax=TRUE means no YMAX connected */

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

    #ifdef DEBUG
    printf("lastx: ["); 
    for (i=0;i<nx;i++) 
        printf("%g,",lastx[i]); 
    printf("]\n");
    #endif

    r = ssGetPWorkValue(S,w_r); /* reference signal vector r from workspace */

    /* Retrieve pointers to input and output vectors */
    ymPtrs = ssGetInputPortRealSignalPtrs(S,0);
    refPtrs	= ssGetInputPortRealSignalPtrs(S,1);
    mdPtrs = ssGetInputPortRealSignalPtrs(S,2);
    uminPtrs = ssGetInputPortRealSignalPtrs(S,4); /* get signal from inport #5 */
    umaxPtrs = ssGetInputPortRealSignalPtrs(S,5); /* get signal from inport #6 */
    yminPtrs = ssGetInputPortRealSignalPtrs(S,6); /* get signal from inport #7 */
    ymaxPtrs = ssGetInputPortRealSignalPtrs(S,7); /* get signal from inport #8 */

    u_out = ssGetOutputPortRealSignal(S,0);    /* only (S,0), as there's only one output port ...*/

    if (do_optimization) {        

        if (!ref_from_ws) { /* ref. signal comes from Simulink diagram */
            /* Get output ref. from input port */
            for (i=0; i<p; i++) {
                for (j=0; j<ny; j++) {
                    if (no_ref) {
                        r[j+i*ny] = 0;  /* default: r=yoff */
                    }
                    else {
                        r[j+i*ny] = *refPtrs[j]-yoff[j];
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
                    v[j+i*nv] = *mdPtrs[j]-voff[j];
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

    ytilde = ssGetPWorkValue(S, w_ytilde);

    #ifdef DEBUG
    printf("ym[0]=%g\n",*ymPtrs[0]);
    #endif

    for (i=0; i<nym; i++) {
        CLR; /* i.e., adder = 0 */
        MVP(Cm, lastx, i, nym, nx);
        MVP(Dvm, v, i, nym, nv);
        /* printf("adder[%d]: %g\n",i,adder); */            

        if (no_ym) {
            ytilde[i]=0.0-myoff[i]-adder;
        }
        else {
            ytilde[i]=*ymPtrs[i]-myoff[i]-adder;
        }

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

        vKv = ssGetPWorkValue(S,w_vKv);

        if (isemptyKv) {
            for (j=0; j<degrees; j++) {
                vKv[j]=0.0;
            }

            if(PTYPE != UNCONSTR) {
                Mvv = ssGetPWorkValue(S,w_Mvv);
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
                Mvv = ssGetPWorkValue(S,w_Mvv);
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

            ztemp = ssGetPWorkValue(S,w_ztemp); /* stores linear term of the cost function */
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

            zopt = ssGetPWorkValue(S,w_zopt1);
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
            rhsc = ssGetPWorkValue(S,w_rhsc);

            for (i=0; i<q; i++) {
                CLR;
                MVP(Mx, lastx, i, q, nxQP);
                MVP(Mu1, lastu, i, q, nu);
                rhsc[i]=rhsc0[i]+Mlim[i]+Mvv[i]+adder;
            }

            /* Handle time varying limits */
            if (lims_inport) { /* time varying limits */
                if (!no_umin) {
                    umin = ssGetPWorkValue(S,w_umin); /* umin */
                    for (j=0; j<nu;j++) {
						cache=*uminPtrs[j];
						#ifdef MATLAB_MEX_FILE /* return error messages, unless code is compiled for RTW */
						if (utIsInf((double) cache))
							printf("Warning: lower bound on input #%d is infinite, results may be unreliable\n",j+1);
						#endif
						umin[j]=cache-uoff[j];
                    }
                }
                if (!no_umax) {
                    umax = ssGetPWorkValue(S,w_umax); /* umax */
                    for (j=0; j<nu;j++) {
						cache=*umaxPtrs[j];
						#ifdef MATLAB_MEX_FILE /* return error messages, unless code is compiled for RTW */
						if (utIsInf((double) cache))
							printf("Warning: upper bound on input #%d is infinite, results may be unreliable\n",j+1);
						#endif
                        umax[j]=cache-uoff[j]; 
                    }
                }
                if (!no_ymin) {
                    ymin = ssGetPWorkValue(S,w_ymin); /* ymin */
                    for (j=0; j<ny;j++) {
						cache=*yminPtrs[j];
						#ifdef MATLAB_MEX_FILE /* return error messages, unless code is compiled for RTW */
						if (utIsInf((double) cache))
							printf("Warning: lower bound on output #%d is infinite, results may be unreliable\n",j+1);
						#endif
						ymin[j]=cache-yoff[j];
                    }
                }
                if (!no_ymax) {
                    ymax = ssGetPWorkValue(S,w_ymax); /* ymax */
                    for (j=0; j<ny;j++) {
						cache=*ymaxPtrs[j];
						#ifdef MATLAB_MEX_FILE /* return error messages, unless code is compiled for RTW */
						if (utIsInf((double) cache))
							printf("Warning: upper bound on output #%d is infinite, results may be unreliable\n",j+1);
						#endif
                        ymax[j]=cache-yoff[j]; 
                    }
                }
                for (i=0; i<q; i++) {
                    rhsc[i]=rhsc[i]-Mlim[i]; /* remove MPC object's dummy limit */
                }

                /* Mlim=[ymax(:);-ymin(:);umax(:);-umin(:);dumax;-dumin]; (see MPC_BUILDMAT.M)
                   Note that ymin,ymax have length p*ny, while umin,umax,dumax,dumin have length of degrees,
                   as constraints on blocked inputs have been collapsed */
                h=0;                
                if (!no_ymax & !no_ymin) { /* Check that ymin, ymax are consistent and possibly adjust them */
                    for (j=0; j<ny; j++) {
                        if	(ymax[j] < ymin[j]) {
                            cache = ymin[j];
                            ymin[j] = ymax[j];
                            ymax[j] = cache;
                            #ifdef MATLAB_MEX_FILE /* return error messages, unless code is compiled for RTW */
                            printf("Warning: inverting bounds on y%d to [%f,%f]\n",j+1,ymin[j],ymax[j]);
                            #endif
                        }
                        if	(ymax[j] <= ymin[j] + CONSTR_TOL) {
                            ymax[j] += CONSTR_TOL; /* add some tolerance to avoid problems with QP */
                        }
                    }
                }
                if (!no_ymax) { /* Get upper bounds on ouputs from Simulink diagram */
                    for (i=0; i<p; i++) {
                        for (j=0; j<ny; j++) {
                            rhsc[h]=rhsc[h] + ymax[j];
                            h++;
                        }
                    }
                }
                if (!no_ymin) { /* Get lower bounds on ouputs from Simulink diagram */
                    for (i=0; i<p; i++) {
                        for (j=0; j<ny; j++) {
                            rhsc[h]=rhsc[h] - ymin[j];
                            h++;
                        }
                    }
                }

                if (!no_umax & !no_umin) { /* Check that umin, umax are consistent and possibly adjust them */
                    for (j=0; j<nu; j++) {
                        if	(umax[j] < umin[j]) {
                            cache = umin[j];
                            umin[j] = umax[j];
                            umax[j] = cache;
                            #ifdef MATLAB_MEX_FILE /* return error messages, unless code is compiled for RTW */
                            printf("Warning: inverting bounds on u%d to [%f,%f]\n",j+1,umin[j],umax[j]);
                            #endif
                        }
                        if	(umax[j] <= umin[j] + CONSTR_TOL) {
                            umax[j] += CONSTR_TOL; /* add some tolerance to avoid problems with QP */
                        }
                    }
                }
                if (!no_umax) { /* Get upper bounds on inputs from Simulink diagram */
                    for (i=0; i<degrees/nu; i++) {
                        for (j=0; j<nu; j++) {
                            rhsc[h]=rhsc[h] + umax[j];
                            h++;
                        }
                    }
                }
                if (!no_umin) { /* Get lower bounds on inputs from Simulink diagram */
                    for (i=0; i<degrees/nu; i++) {
                        for (j=0; j<nu; j++) {
                            rhsc[h]=rhsc[h] - umin[j];
                            h++;
                        }
                    }
                }

                /* Restore bounds on delta u */
                for (i=h; i<q; i++) {
                    rhsc[i]=rhsc[i]+Mlim[i]; /* restore MPC object's limits */
                }

            }

            /* rhsa=rhsa0-[(xk'*Kx+r'*Kr+uk1'*Ku1+vKv+utarget'*Kut),zeros(1,useslack)]'; */
            rhsa = ssGetPWorkValue(S,w_rhsa);
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
            basis = ssGetPWorkValue(S,w_basis);

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
            ib = ssGetPWorkValue(S,w_ib);
            il = ssGetPWorkValue(S,w_il);
            for(i=0; i<numc; i++) {
                il[i]=i+1;
                ib[i]=-il[i];
            }

            /* Initialize the tableau */
            tab = ssGetPWorkValue(S, w_tab);
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

                zopt = ssGetPWorkValue(S,w_zopt2);
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
                    %free=find(kron(DUFree(:),ones(nu,1))); % Indices of free moves
                    free=find(DUFree(:));
                    epsslack=Inf; % Slack variable for soft output constraints
                    zopt=zopt(free);
                 */

                zopx = ssGetPWorkValue(S,w_zopx);
                zopt = ssGetPWorkValue(S,w_zopt3);
                for (i=0; i<(int_T)mxGetM(p_optimalseq(S)); i++) {
                    zopt[i]=0.0;
                }
                duold = ssGetPWorkValue(S,w_duold);
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

                /* Find free moves */

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

            /* End of MPC2.M */
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

    /* (jgo) Copy the new "state" vector back to the work vector */
    wlastx = ssGetPWorkValue(S,w_lastx);
    wlastu = ssGetPWorkValue(S,w_lastu);
    memcpy(wlastx, lastx, nx*sizeof(real_T));
    memcpy(wlastu, lastu, nu*sizeof(real_T));

} /* End of MDL_OUTPUTS */

/* MDLUPDATE */
#define MDL_UPDATE
static void mdlUpdate(SimStruct *S, int_T tid)
{
    static int_T nu, nx, nv;
    static real_T *A, *Bu, *Bv;
    
    
    real_T *xk; /* Temporary state update */
    

    real_T *states;

    real_T *lastx = ssGetPWorkValue(S,w_lastx);
    real_T *lastu = ssGetPWorkValue(S,w_lastu);
    real_T *v = ssGetPWorkValue(S,w_v);
    long int *lastt = ssGetPWorkValue(S,w_lastt);
    int_T openloopflag = (int_T) *mxGetPr(p_openloopflag(S)); /* jgo */
    
    InputRealPtrsType mvPtrs;
    static boolean_T no_mv, mv_inport;
    static real_T *uoff;
    
    int_T i,j;
    real_T adder = 0;
    

    states = ssGetDiscStates(S);

    if (openloopflag==1) {
        return; /* don't change the state */
    }
    
    #ifdef DEBUG
    printf("UPDATE\n");
    #endif
    
    /* Initialize vars from structure S */
    nu = (int_T)*mxGetPr(p_nu(S));   /* Size of input vector */
    nx = (int_T)*mxGetPr(p_nx(S));   /* Size of extended state vector */
    nv = (int_T)*mxGetPr(p_nv(S));   /* Size of current meas. dist. vect. */
    A = mxGetPr((real_T *)p_A(S));
    Bu = mxGetPr((real_T *)p_Bu(S));
    Bv = mxGetPr((real_T *)p_Bv(S));
    
    no_mv = (boolean_T) *mxGetPr(p_no_mv(S));   /* no_mv=TRUE means no user-supplied MV signals connected */
    mv_inport = (boolean_T) *mxGetPr(p_mv_inport(S));   /* mv_inport=TRUE means ext. MV inport exists */
    uoff=mxGetPr((real_T *)p_uoff(S));
    mvPtrs = ssGetInputPortRealSignalPtrs(S,3); /* get signal from inport #4 */
    
    /* update lastu */
    /* If the user supplies his/her own MV signal, then the state observer must be updated
        with that signal */
    if (mv_inport)  { /* The user has supplied a MV signal */
        for (j=0; j<nu; j++) {
            if (!no_mv) {
                lastu[j] = *mvPtrs[j]-uoff[j]; /* otherwise ext_u=MPC's last u */
            }
        }
        /* printf("lastu: ["); for (i=0;i<nu;i++) printf("%g,",lastu[i]); printf("]\n"); */
    }
    
    /* update lastx */
    xk = ssGetPWorkValue(S,w_xk);
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
            
    for (i=0; i<nx; i++) {
        states[i]=lastx[i];
    }
    for (i=0; i<nu; i++) {
        states[nx+i]=lastu[i];
    }

}

static void mdlTerminate(SimStruct *S)
{
    int_T i;
    
    /* Free all work vectors */
    for (i = 0; i<ssGetNumPWork(S); i++) {
        if (ssGetPWorkValue(S,i) != NULL) {
            free(ssGetPWorkValue(S,i));
        }
    }

    #ifdef DEBUG
    printf("END\n");
    #endif
    
}

#ifdef MATLAB_MEX_FILE

# define MDL_SET_INPUT_PORT_DIMENSION_INFO
/* Function: mdlSetInputPortDimensionInfo ====================================
 * Abstract:
 *    This routine is called with the candidate dimensions for an input port
 *    with unknown dimensions. If the proposed dimensions are acceptable, the
 *    routine should go ahead and set the actual port dimensions.
 *    If they are unacceptable an error should be generated via
 *    ssSetErrorStatus.
 *    Note that any other input or output ports whose dimensions are
 *    implicitly defined by virtue of knowing the dimensions of the given port
 *    can also have their dimensions set.
 */
static void mdlSetInputPortDimensionInfo(SimStruct *S, int_T port, const DimsInfo_T *dimsInfo)
{
    /* Set input port dimension */
    if (!ssSetInputPortDimensionInfo(S, port, dimsInfo)) return;
    /* printf("mdlSetInputPortDimensionInfo Status: port(%d) status(%d)\n",port,status); */
} /* end mdlSetInputPortDimensionInfo */

# define MDL_SET_OUTPUT_PORT_DIMENSION_INFO
/* Function: mdlSetOutputPortDimensionInfo ===================================
 * Abstract:
 *    This routine is called with the candidate dimensions for an output port
 *    with unknown dimensions. If the proposed dimensions are acceptable, the
 *    routine should go ahead and set the actual port dimensions.
 *    If they are unacceptable an error should be generated via
 *    ssSetErrorStatus.
 *    Note that any other input or output ports whose dimensions are
 *    implicitly defined by virtue of knowing the dimensions of the given
 *    port can also have their dimensions set.
 */
static void mdlSetOutputPortDimensionInfo(SimStruct *S, int_T port, const DimsInfo_T *dimsInfo)
{
    if (!ssSetOutputPortDimensionInfo(S, port, dimsInfo)) return;
    /* printf("mdlSetOutputPortDimensionInfo Status: port(%d) status(%d)\n",port,status); */
} /* end mdlSetOutputPortDimensionInfo */

# define MDL_SET_DEFAULT_PORT_DIMENSION_INFO
/* Function: mdlSetDefaultPortDimensionInfo ====================================
 *    This routine is called when Simulink is not able to find dimension
 *    candidates for ports with unknown dimensions. This function must set the
 *    dimensions of all ports with unknown dimensions.
 */
static void mdlSetDefaultPortDimensionInfo(SimStruct *S)
{
    /* Set input port default dimension */
    int_T TOTALPORTNUMBER = 9;
    int_T i;
    for (i=0; i<TOTALPORTNUMBER; i++) {
        if (ssGetInputPortWidth(S, i) == DYNAMICALLY_SIZED) {
            if(!ssSetInputPortVectorDimension(S, i, 1)) return;
        }
    }
} /* end mdlSetDefaultPortDimensionInfo */

#endif /* end of MATLAB_MEX_FILE */

/* Statements Required at the Bottom of S-Functions */
#ifdef  MATLAB_MEX_FILE
#include "simulink.c"
#else
#include "cg_sfun.h"
#endif
