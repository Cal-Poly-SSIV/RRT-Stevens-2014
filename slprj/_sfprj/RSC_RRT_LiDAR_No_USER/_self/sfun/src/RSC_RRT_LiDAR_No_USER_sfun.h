#ifndef __RSC_RRT_LiDAR_No_USER_sfun_h__
#define __RSC_RRT_LiDAR_No_USER_sfun_h__

/* Include files */
#define S_FUNCTION_NAME                sf_sfun
#include "sfc_sf.h"
#include "sfc_mex.h"
#include "rtwtypes.h"
#include "sfcdebug.h"
#define rtInf                          (mxGetInf())
#define rtMinusInf                     (-(mxGetInf()))
#define rtNaN                          (mxGetNaN())
#define rtIsNaN(X)                     ((int)mxIsNaN(X))
#define rtIsInf(X)                     ((int)mxIsInf(X))

/* Type Definitions */

/* Named Constants */
#define CALL_EVENT                     (-1)

/* Variable Declarations */
extern int32_T _sfEvent_;
extern uint32_T _RSC_RRT_LiDAR_No_USERMachineNumber_;
extern real_T _sfTime_;

/* Variable Definitions */

/* Function Declarations */
extern void RSC_RRT_LiDAR_No_USER_initializer(void);
extern void RSC_RRT_LiDAR_No_USER_terminator(void);

/* Function Definitions */
#endif
