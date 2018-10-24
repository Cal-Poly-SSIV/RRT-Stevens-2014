#ifndef __c1_MPC_gamecontroller_LiDAR2_h__
#define __c1_MPC_gamecontroller_LiDAR2_h__

/* Include files */
#include "sfc_sf.h"
#include "sfc_mex.h"
#include "rtwtypes.h"

/* Type Definitions */
typedef struct {
  SimStruct *S;
  uint32_T chartNumber;
  uint32_T instanceNumber;
  boolean_T c1_doneDoubleBufferReInit;
  boolean_T c1_isStable;
  uint8_T c1_is_active_c1_MPC_gamecontroller_LiDAR2;
  ChartInfoStruct chartInfo;
} SFc1_MPC_gamecontroller_LiDAR2InstanceStruct;

/* Named Constants */

/* Variable Declarations */

/* Variable Definitions */

/* Function Declarations */
extern const mxArray
  *sf_c1_MPC_gamecontroller_LiDAR2_get_eml_resolved_functions_info(void);

/* Function Definitions */
extern void sf_c1_MPC_gamecontroller_LiDAR2_get_check_sum(mxArray *plhs[]);
extern void c1_MPC_gamecontroller_LiDAR2_method_dispatcher(SimStruct *S, int_T
  method, void *data);

#endif
