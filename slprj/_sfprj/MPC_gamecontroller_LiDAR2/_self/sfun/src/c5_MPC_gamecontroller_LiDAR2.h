#ifndef __c5_MPC_gamecontroller_LiDAR2_h__
#define __c5_MPC_gamecontroller_LiDAR2_h__

/* Include files */
#include "sfc_sf.h"
#include "sfc_mex.h"
#include "rtwtypes.h"

/* Type Definitions */
typedef struct {
  const char *context;
  const char *name;
  const char *dominantType;
  const char *resolved;
  uint32_T fileLength;
  uint32_T fileTime1;
  uint32_T fileTime2;
} c5_ResolvedFunctionInfo;

typedef struct {
  SimStruct *S;
  uint32_T chartNumber;
  uint32_T instanceNumber;
  boolean_T c5_doneDoubleBufferReInit;
  boolean_T c5_isStable;
  uint8_T c5_is_active_c5_MPC_gamecontroller_LiDAR2;
  ChartInfoStruct chartInfo;
} SFc5_MPC_gamecontroller_LiDAR2InstanceStruct;

/* Named Constants */

/* Variable Declarations */

/* Variable Definitions */

/* Function Declarations */
extern const mxArray
  *sf_c5_MPC_gamecontroller_LiDAR2_get_eml_resolved_functions_info(void);

/* Function Definitions */
extern void sf_c5_MPC_gamecontroller_LiDAR2_get_check_sum(mxArray *plhs[]);
extern void c5_MPC_gamecontroller_LiDAR2_method_dispatcher(SimStruct *S, int_T
  method, void *data);

#endif
