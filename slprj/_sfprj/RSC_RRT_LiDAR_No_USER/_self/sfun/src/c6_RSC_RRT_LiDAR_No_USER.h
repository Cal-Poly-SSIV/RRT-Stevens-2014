#ifndef __c6_RSC_RRT_LiDAR_No_USER_h__
#define __c6_RSC_RRT_LiDAR_No_USER_h__

/* Include files */
#include "sfc_sf.h"
#include "sfc_mex.h"
#include "rtwtypes.h"

/* Type Definitions */
typedef struct {
  SimStruct *S;
  uint32_T chartNumber;
  uint32_T instanceNumber;
  boolean_T c6_doneDoubleBufferReInit;
  boolean_T c6_isStable;
  uint8_T c6_is_active_c6_RSC_RRT_LiDAR_No_USER;
  ChartInfoStruct chartInfo;
} SFc6_RSC_RRT_LiDAR_No_USERInstanceStruct;

/* Named Constants */

/* Variable Declarations */

/* Variable Definitions */

/* Function Declarations */
extern const mxArray
  *sf_c6_RSC_RRT_LiDAR_No_USER_get_eml_resolved_functions_info(void);

/* Function Definitions */
extern void sf_c6_RSC_RRT_LiDAR_No_USER_get_check_sum(mxArray *plhs[]);
extern void c6_RSC_RRT_LiDAR_No_USER_method_dispatcher(SimStruct *S, int_T
  method, void *data);

#endif
