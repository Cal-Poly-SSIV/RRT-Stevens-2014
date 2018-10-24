/* mpc_common.c: Common C-code for MPC_SFUN.C and MPCLOOP_ENGINE.C */
 
/*
        Author: A. Bemporad
        Initial function prototype by G. Bianchini (2001-2002)
        Revised by: R. Chen
        Copyright 1986-2008 The MathWorks, Inc.
        $Revision: 1.1.10.17 $  $Date: 2009/08/08 01:11:22 $
 */

/* Merge dantzgmp source */
#include "dantzgmp_solver.c"

/* GETRV */
static void getrv(real_T *window, real_T *signal, int_T t1, int_T t2, int_T n, int_T m, int_T len)
{   /* function required for previewing reference and measured disturbance signals
     
       Defines window=signal(1:n,t1+1:t2+1), where [m,t2-t1+1]=size(window)
       if signal has enough columns, otherwise repeats the last column
       ([n,len]=size(signal))
     */
    
  /* Counters */
    int_T i,j;
    
    #ifdef DEBUG
    printf("t1: %d, t2: %d\n",t1,t2);
    #endif
    
    if (t1+1>len) { /* repeats the last one */
        /* window=signal(:,len)*ones(1,t2-t1+1); */
        for (i=0;i<t2-t1+1;i++) {
            for (j=0;j<n;j++) {
                window[i*m+j]=signal[n*(len-1)+j];
            }
        }
    }
    else if (t2+1>len) {
        /* window=[signal(:,t1+1:len),signal(:,len)*ones(1,t2+1-len)]; */
        for (i=0;i<len-t1+1;i++) {
            for (j=0;j<n;j++) {
                window[i*m+j]=signal[n*(t1+i)+j];
            }
        }
        for (i=len-t1;i<t2-t1+1;i++) {
            for (j=0;j<n;j++) {
                window[i*m+j]=signal[n*(len-1)+j];
            }
        }
    }
    else {
        /* window=signal(:,t1+1:t2+1); */
        for (i=0;i<t2-t1+1;i++) {
            for (j=0;j<n;j++) {
                window[i*m+j]=signal[n*(t1+i)+j];
            }
        }
    }
    #ifdef DEBUG
    for (i=0; i<t2-t1+1; i++)
        for (j=0; j<m; j++)
            printf("window(%d,%d): %5.2f\n",j,i,window[m*i+j]);
    #endif
}

