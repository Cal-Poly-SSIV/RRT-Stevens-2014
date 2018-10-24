/* Include files */

#include "blascompat32.h"
#include "MPC_gamecontroller_LiDAR2_sfun.h"
#include "c4_MPC_gamecontroller_LiDAR2.h"
#define CHARTINSTANCE_CHARTNUMBER      (chartInstance->chartNumber)
#define CHARTINSTANCE_INSTANCENUMBER   (chartInstance->instanceNumber)
#include "MPC_gamecontroller_LiDAR2_sfun_debug_macros.h"

/* Type Definitions */

/* Named Constants */

/* Variable Declarations */

/* Variable Definitions */
static const char *c4_debug_family_names[4] = { "nargin", "nargout", "angler",
  "turnangle" };

/* Function Declarations */
static void initialize_c4_MPC_gamecontroller_LiDAR2
  (SFc4_MPC_gamecontroller_LiDAR2InstanceStruct *chartInstance);
static void initialize_params_c4_MPC_gamecontroller_LiDAR2
  (SFc4_MPC_gamecontroller_LiDAR2InstanceStruct *chartInstance);
static void enable_c4_MPC_gamecontroller_LiDAR2
  (SFc4_MPC_gamecontroller_LiDAR2InstanceStruct *chartInstance);
static void disable_c4_MPC_gamecontroller_LiDAR2
  (SFc4_MPC_gamecontroller_LiDAR2InstanceStruct *chartInstance);
static void c4_update_debugger_state_c4_MPC_gamecontroller_LiDAR2
  (SFc4_MPC_gamecontroller_LiDAR2InstanceStruct *chartInstance);
static const mxArray *get_sim_state_c4_MPC_gamecontroller_LiDAR2
  (SFc4_MPC_gamecontroller_LiDAR2InstanceStruct *chartInstance);
static void set_sim_state_c4_MPC_gamecontroller_LiDAR2
  (SFc4_MPC_gamecontroller_LiDAR2InstanceStruct *chartInstance, const mxArray
   *c4_st);
static void finalize_c4_MPC_gamecontroller_LiDAR2
  (SFc4_MPC_gamecontroller_LiDAR2InstanceStruct *chartInstance);
static void sf_c4_MPC_gamecontroller_LiDAR2
  (SFc4_MPC_gamecontroller_LiDAR2InstanceStruct *chartInstance);
static void compInitSubchartSimstructsFcn_c4_MPC_gamecontroller_LiDAR2
  (SFc4_MPC_gamecontroller_LiDAR2InstanceStruct *chartInstance);
static void init_script_number_translation(uint32_T c4_machineNumber, uint32_T
  c4_chartNumber);
static const mxArray *c4_sf_marshall(void *chartInstanceVoid, void *c4_u);
static const mxArray *c4_b_sf_marshall(void *chartInstanceVoid, void *c4_u);
static real_T c4_emlrt_marshallIn(SFc4_MPC_gamecontroller_LiDAR2InstanceStruct
  *chartInstance, const mxArray *c4_turnangle, const char_T *c4_name);
static uint8_T c4_b_emlrt_marshallIn
  (SFc4_MPC_gamecontroller_LiDAR2InstanceStruct *chartInstance, const mxArray
   *c4_b_is_active_c4_MPC_gamecontroller_LiDAR2, const char_T *c4_name);
static void init_dsm_address_info(SFc4_MPC_gamecontroller_LiDAR2InstanceStruct
  *chartInstance);

/* Function Definitions */
static void initialize_c4_MPC_gamecontroller_LiDAR2
  (SFc4_MPC_gamecontroller_LiDAR2InstanceStruct *chartInstance)
{
  _sfTime_ = (real_T)ssGetT(chartInstance->S);
  chartInstance->c4_is_active_c4_MPC_gamecontroller_LiDAR2 = 0U;
}

static void initialize_params_c4_MPC_gamecontroller_LiDAR2
  (SFc4_MPC_gamecontroller_LiDAR2InstanceStruct *chartInstance)
{
}

static void enable_c4_MPC_gamecontroller_LiDAR2
  (SFc4_MPC_gamecontroller_LiDAR2InstanceStruct *chartInstance)
{
  _sfTime_ = (real_T)ssGetT(chartInstance->S);
}

static void disable_c4_MPC_gamecontroller_LiDAR2
  (SFc4_MPC_gamecontroller_LiDAR2InstanceStruct *chartInstance)
{
  _sfTime_ = (real_T)ssGetT(chartInstance->S);
}

static void c4_update_debugger_state_c4_MPC_gamecontroller_LiDAR2
  (SFc4_MPC_gamecontroller_LiDAR2InstanceStruct *chartInstance)
{
}

static const mxArray *get_sim_state_c4_MPC_gamecontroller_LiDAR2
  (SFc4_MPC_gamecontroller_LiDAR2InstanceStruct *chartInstance)
{
  const mxArray *c4_st = NULL;
  const mxArray *c4_y = NULL;
  real_T c4_hoistedGlobal;
  real_T c4_u;
  const mxArray *c4_b_y = NULL;
  uint8_T c4_b_hoistedGlobal;
  uint8_T c4_b_u;
  const mxArray *c4_c_y = NULL;
  real_T *c4_turnangle;
  c4_turnangle = (real_T *)ssGetOutputPortSignal(chartInstance->S, 1);
  c4_st = NULL;
  c4_y = NULL;
  sf_mex_assign(&c4_y, sf_mex_createcellarray(2));
  c4_hoistedGlobal = *c4_turnangle;
  c4_u = c4_hoistedGlobal;
  c4_b_y = NULL;
  sf_mex_assign(&c4_b_y, sf_mex_create("y", &c4_u, 0, 0U, 0U, 0U, 0));
  sf_mex_setcell(c4_y, 0, c4_b_y);
  c4_b_hoistedGlobal = chartInstance->c4_is_active_c4_MPC_gamecontroller_LiDAR2;
  c4_b_u = c4_b_hoistedGlobal;
  c4_c_y = NULL;
  sf_mex_assign(&c4_c_y, sf_mex_create("y", &c4_b_u, 3, 0U, 0U, 0U, 0));
  sf_mex_setcell(c4_y, 1, c4_c_y);
  sf_mex_assign(&c4_st, c4_y);
  return c4_st;
}

static void set_sim_state_c4_MPC_gamecontroller_LiDAR2
  (SFc4_MPC_gamecontroller_LiDAR2InstanceStruct *chartInstance, const mxArray *
   c4_st)
{
  const mxArray *c4_u;
  real_T *c4_turnangle;
  c4_turnangle = (real_T *)ssGetOutputPortSignal(chartInstance->S, 1);
  chartInstance->c4_doneDoubleBufferReInit = TRUE;
  c4_u = sf_mex_dup(c4_st);
  *c4_turnangle = c4_emlrt_marshallIn(chartInstance, sf_mex_dup(sf_mex_getcell
    (c4_u, 0)), "turnangle");
  chartInstance->c4_is_active_c4_MPC_gamecontroller_LiDAR2 =
    c4_b_emlrt_marshallIn(chartInstance, sf_mex_dup(sf_mex_getcell(c4_u, 1))
    , "is_active_c4_MPC_gamecontroller_LiDAR2");
  sf_mex_destroy(&c4_u);
  c4_update_debugger_state_c4_MPC_gamecontroller_LiDAR2(chartInstance);
  sf_mex_destroy(&c4_st);
}

static void finalize_c4_MPC_gamecontroller_LiDAR2
  (SFc4_MPC_gamecontroller_LiDAR2InstanceStruct *chartInstance)
{
}

static void sf_c4_MPC_gamecontroller_LiDAR2
  (SFc4_MPC_gamecontroller_LiDAR2InstanceStruct *chartInstance)
{
  int32_T c4_previousEvent;
  real_T c4_hoistedGlobal;
  real_T c4_angler;
  uint32_T c4_debug_family_var_map[4];
  real_T c4_nargin = 1.0;
  real_T c4_nargout = 1.0;
  real_T c4_turnangle;
  real_T c4_a;
  real_T c4_y;
  real_T c4_b_a;
  real_T c4_b_y;
  real_T *c4_b_angler;
  real_T *c4_b_turnangle;
  c4_b_turnangle = (real_T *)ssGetOutputPortSignal(chartInstance->S, 1);
  c4_b_angler = (real_T *)ssGetInputPortSignal(chartInstance->S, 0);
  _sfTime_ = (real_T)ssGetT(chartInstance->S);
  _SFD_CC_CALL(CHART_ENTER_SFUNCTION_TAG, 2);
  _SFD_DATA_RANGE_CHECK(*c4_b_angler, 0U);
  _SFD_DATA_RANGE_CHECK(*c4_b_turnangle, 1U);
  c4_previousEvent = _sfEvent_;
  _sfEvent_ = CALL_EVENT;
  _SFD_CC_CALL(CHART_ENTER_DURING_FUNCTION_TAG, 2);
  c4_hoistedGlobal = *c4_b_angler;
  c4_angler = c4_hoistedGlobal;
  sf_debug_symbol_scope_push_eml(0U, 4U, 4U, c4_debug_family_names,
    c4_debug_family_var_map);
  sf_debug_symbol_scope_add_eml(&c4_nargin, c4_sf_marshall, 0U);
  sf_debug_symbol_scope_add_eml(&c4_nargout, c4_sf_marshall, 1U);
  sf_debug_symbol_scope_add_eml(&c4_angler, c4_sf_marshall, 2U);
  sf_debug_symbol_scope_add_eml(&c4_turnangle, c4_sf_marshall, 3U);
  CV_EML_FCN(0, 0);

  /* #codegen */
  _SFD_EML_CALL(0, 3);
  if (CV_EML_IF(0, 0, c4_angler > 0.0)) {
    _SFD_EML_CALL(0, 4);
    c4_a = c4_angler;
    c4_y = c4_a * 155.0;
    c4_turnangle = 100.0 + c4_y;
  } else {
    _SFD_EML_CALL(0, 5);
    if (CV_EML_IF(0, 1, c4_angler < 0.0)) {
      _SFD_EML_CALL(0, 6);
      c4_b_a = c4_angler;
      c4_b_y = c4_b_a * 100.0;
      c4_turnangle = 100.0 + c4_b_y;
    } else {
      _SFD_EML_CALL(0, 8);
      c4_turnangle = 100.0;
    }
  }

  _SFD_EML_CALL(0, -8);
  sf_debug_symbol_scope_pop();
  *c4_b_turnangle = c4_turnangle;
  _SFD_CC_CALL(EXIT_OUT_OF_FUNCTION_TAG, 2);
  _sfEvent_ = c4_previousEvent;
  sf_debug_check_for_state_inconsistency
    (_MPC_gamecontroller_LiDAR2MachineNumber_, chartInstance->chartNumber,
     chartInstance->
     instanceNumber);
}

static void compInitSubchartSimstructsFcn_c4_MPC_gamecontroller_LiDAR2
  (SFc4_MPC_gamecontroller_LiDAR2InstanceStruct *chartInstance)
{
}

static void init_script_number_translation(uint32_T c4_machineNumber, uint32_T
  c4_chartNumber)
{
}

static const mxArray *c4_sf_marshall(void *chartInstanceVoid, void *c4_u)
{
  const mxArray *c4_y = NULL;
  real_T c4_b_u;
  const mxArray *c4_b_y = NULL;
  SFc4_MPC_gamecontroller_LiDAR2InstanceStruct *chartInstance;
  chartInstance = (SFc4_MPC_gamecontroller_LiDAR2InstanceStruct *)
    chartInstanceVoid;
  c4_y = NULL;
  c4_b_u = *((real_T *)c4_u);
  c4_b_y = NULL;
  sf_mex_assign(&c4_b_y, sf_mex_create("y", &c4_b_u, 0, 0U, 0U, 0U, 0));
  sf_mex_assign(&c4_y, c4_b_y);
  return c4_y;
}

const mxArray *sf_c4_MPC_gamecontroller_LiDAR2_get_eml_resolved_functions_info
  (void)
{
  const mxArray *c4_nameCaptureInfo = NULL;
  c4_ResolvedFunctionInfo c4_info[14];
  c4_ResolvedFunctionInfo (*c4_b_info)[14];
  const mxArray *c4_m0 = NULL;
  int32_T c4_i0;
  c4_ResolvedFunctionInfo *c4_r0;
  c4_nameCaptureInfo = NULL;
  c4_b_info = (c4_ResolvedFunctionInfo (*)[14])c4_info;
  (*c4_b_info)[0].context = "";
  (*c4_b_info)[0].name = "gt";
  (*c4_b_info)[0].dominantType = "double";
  (*c4_b_info)[0].resolved = "[B]gt";
  (*c4_b_info)[0].fileLength = 0U;
  (*c4_b_info)[0].fileTime1 = 0U;
  (*c4_b_info)[0].fileTime2 = 0U;
  (*c4_b_info)[1].context = "";
  (*c4_b_info)[1].name = "minus";
  (*c4_b_info)[1].dominantType = "double";
  (*c4_b_info)[1].resolved = "[B]minus";
  (*c4_b_info)[1].fileLength = 0U;
  (*c4_b_info)[1].fileTime1 = 0U;
  (*c4_b_info)[1].fileTime2 = 0U;
  (*c4_b_info)[2].context = "";
  (*c4_b_info)[2].name = "mtimes";
  (*c4_b_info)[2].dominantType = "double";
  (*c4_b_info)[2].resolved =
    "[ILXE]$matlabroot$/toolbox/eml/lib/matlab/ops/mtimes.m";
  (*c4_b_info)[2].fileLength = 3425U;
  (*c4_b_info)[2].fileTime1 = 1251064272U;
  (*c4_b_info)[2].fileTime2 = 0U;
  (*c4_b_info)[3].context =
    "[ILXE]$matlabroot$/toolbox/eml/lib/matlab/ops/mtimes.m";
  (*c4_b_info)[3].name = "nargin";
  (*c4_b_info)[3].dominantType = "";
  (*c4_b_info)[3].resolved = "[B]nargin";
  (*c4_b_info)[3].fileLength = 0U;
  (*c4_b_info)[3].fileTime1 = 0U;
  (*c4_b_info)[3].fileTime2 = 0U;
  (*c4_b_info)[4].context =
    "[ILXE]$matlabroot$/toolbox/eml/lib/matlab/ops/mtimes.m";
  (*c4_b_info)[4].name = "isa";
  (*c4_b_info)[4].dominantType = "double";
  (*c4_b_info)[4].resolved = "[B]isa";
  (*c4_b_info)[4].fileLength = 0U;
  (*c4_b_info)[4].fileTime1 = 0U;
  (*c4_b_info)[4].fileTime2 = 0U;
  (*c4_b_info)[5].context =
    "[ILXE]$matlabroot$/toolbox/eml/lib/matlab/ops/mtimes.m";
  (*c4_b_info)[5].name = "isinteger";
  (*c4_b_info)[5].dominantType = "double";
  (*c4_b_info)[5].resolved = "[B]isinteger";
  (*c4_b_info)[5].fileLength = 0U;
  (*c4_b_info)[5].fileTime1 = 0U;
  (*c4_b_info)[5].fileTime2 = 0U;
  (*c4_b_info)[6].context =
    "[ILXE]$matlabroot$/toolbox/eml/lib/matlab/ops/mtimes.m";
  (*c4_b_info)[6].name = "isscalar";
  (*c4_b_info)[6].dominantType = "double";
  (*c4_b_info)[6].resolved = "[B]isscalar";
  (*c4_b_info)[6].fileLength = 0U;
  (*c4_b_info)[6].fileTime1 = 0U;
  (*c4_b_info)[6].fileTime2 = 0U;
  (*c4_b_info)[7].context =
    "[ILXE]$matlabroot$/toolbox/eml/lib/matlab/ops/mtimes.m";
  (*c4_b_info)[7].name = "strcmp";
  (*c4_b_info)[7].dominantType = "char";
  (*c4_b_info)[7].resolved = "[B]strcmp";
  (*c4_b_info)[7].fileLength = 0U;
  (*c4_b_info)[7].fileTime1 = 0U;
  (*c4_b_info)[7].fileTime2 = 0U;
  (*c4_b_info)[8].context =
    "[ILXE]$matlabroot$/toolbox/eml/lib/matlab/ops/mtimes.m";
  (*c4_b_info)[8].name = "size";
  (*c4_b_info)[8].dominantType = "double";
  (*c4_b_info)[8].resolved = "[B]size";
  (*c4_b_info)[8].fileLength = 0U;
  (*c4_b_info)[8].fileTime1 = 0U;
  (*c4_b_info)[8].fileTime2 = 0U;
  (*c4_b_info)[9].context =
    "[ILXE]$matlabroot$/toolbox/eml/lib/matlab/ops/mtimes.m";
  (*c4_b_info)[9].name = "eq";
  (*c4_b_info)[9].dominantType = "double";
  (*c4_b_info)[9].resolved = "[B]eq";
  (*c4_b_info)[9].fileLength = 0U;
  (*c4_b_info)[9].fileTime1 = 0U;
  (*c4_b_info)[9].fileTime2 = 0U;
  (*c4_b_info)[10].context =
    "[ILXE]$matlabroot$/toolbox/eml/lib/matlab/ops/mtimes.m";
  (*c4_b_info)[10].name = "class";
  (*c4_b_info)[10].dominantType = "double";
  (*c4_b_info)[10].resolved = "[B]class";
  (*c4_b_info)[10].fileLength = 0U;
  (*c4_b_info)[10].fileTime1 = 0U;
  (*c4_b_info)[10].fileTime2 = 0U;
  (*c4_b_info)[11].context =
    "[ILXE]$matlabroot$/toolbox/eml/lib/matlab/ops/mtimes.m";
  (*c4_b_info)[11].name = "not";
  (*c4_b_info)[11].dominantType = "logical";
  (*c4_b_info)[11].resolved = "[B]not";
  (*c4_b_info)[11].fileLength = 0U;
  (*c4_b_info)[11].fileTime1 = 0U;
  (*c4_b_info)[11].fileTime2 = 0U;
  (*c4_b_info)[12].context = "";
  (*c4_b_info)[12].name = "plus";
  (*c4_b_info)[12].dominantType = "double";
  (*c4_b_info)[12].resolved = "[B]plus";
  (*c4_b_info)[12].fileLength = 0U;
  (*c4_b_info)[12].fileTime1 = 0U;
  (*c4_b_info)[12].fileTime2 = 0U;
  (*c4_b_info)[13].context = "";
  (*c4_b_info)[13].name = "lt";
  (*c4_b_info)[13].dominantType = "double";
  (*c4_b_info)[13].resolved = "[B]lt";
  (*c4_b_info)[13].fileLength = 0U;
  (*c4_b_info)[13].fileTime1 = 0U;
  (*c4_b_info)[13].fileTime2 = 0U;
  sf_mex_assign(&c4_m0, sf_mex_createstruct("nameCaptureInfo", 1, 14));
  for (c4_i0 = 0; c4_i0 < 14; c4_i0 = c4_i0 + 1) {
    c4_r0 = &c4_info[c4_i0];
    sf_mex_addfield(c4_m0, sf_mex_create("nameCaptureInfo", c4_r0->context, 15,
      0U, 0U, 0U, 2, 1, strlen(c4_r0->context)), "context",
                    "nameCaptureInfo", c4_i0);
    sf_mex_addfield(c4_m0, sf_mex_create("nameCaptureInfo", c4_r0->name, 15, 0U,
      0U, 0U, 2, 1, strlen(c4_r0->name)), "name",
                    "nameCaptureInfo", c4_i0);
    sf_mex_addfield(c4_m0, sf_mex_create("nameCaptureInfo", c4_r0->dominantType,
      15, 0U, 0U, 0U, 2, 1, strlen(c4_r0->dominantType)),
                    "dominantType", "nameCaptureInfo", c4_i0);
    sf_mex_addfield(c4_m0, sf_mex_create("nameCaptureInfo", c4_r0->resolved, 15,
      0U, 0U, 0U, 2, 1, strlen(c4_r0->resolved)), "resolved"
                    , "nameCaptureInfo", c4_i0);
    sf_mex_addfield(c4_m0, sf_mex_create("nameCaptureInfo", &c4_r0->fileLength,
      7, 0U, 0U, 0U, 0), "fileLength", "nameCaptureInfo",
                    c4_i0);
    sf_mex_addfield(c4_m0, sf_mex_create("nameCaptureInfo", &c4_r0->fileTime1, 7,
      0U, 0U, 0U, 0), "fileTime1", "nameCaptureInfo", c4_i0);
    sf_mex_addfield(c4_m0, sf_mex_create("nameCaptureInfo", &c4_r0->fileTime2, 7,
      0U, 0U, 0U, 0), "fileTime2", "nameCaptureInfo", c4_i0);
  }

  sf_mex_assign(&c4_nameCaptureInfo, c4_m0);
  return c4_nameCaptureInfo;
}

static const mxArray *c4_b_sf_marshall(void *chartInstanceVoid, void *c4_u)
{
  const mxArray *c4_y = NULL;
  boolean_T c4_b_u;
  const mxArray *c4_b_y = NULL;
  SFc4_MPC_gamecontroller_LiDAR2InstanceStruct *chartInstance;
  chartInstance = (SFc4_MPC_gamecontroller_LiDAR2InstanceStruct *)
    chartInstanceVoid;
  c4_y = NULL;
  c4_b_u = *((boolean_T *)c4_u);
  c4_b_y = NULL;
  sf_mex_assign(&c4_b_y, sf_mex_create("y", &c4_b_u, 11, 0U, 0U, 0U, 0));
  sf_mex_assign(&c4_y, c4_b_y);
  return c4_y;
}

static real_T c4_emlrt_marshallIn(SFc4_MPC_gamecontroller_LiDAR2InstanceStruct
  *chartInstance, const mxArray *c4_turnangle, const
  char_T *c4_name)
{
  real_T c4_y;
  real_T c4_d0;
  sf_mex_import(c4_name, sf_mex_dup(c4_turnangle), &c4_d0, 1, 0, 0U, 0, 0U, 0);
  c4_y = c4_d0;
  sf_mex_destroy(&c4_turnangle);
  return c4_y;
}

static uint8_T c4_b_emlrt_marshallIn
  (SFc4_MPC_gamecontroller_LiDAR2InstanceStruct *chartInstance, const mxArray *
   c4_b_is_active_c4_MPC_gamecontroller_LiDAR2, const char_T *c4_name)
{
  uint8_T c4_y;
  uint8_T c4_u0;
  sf_mex_import(c4_name, sf_mex_dup(c4_b_is_active_c4_MPC_gamecontroller_LiDAR2),
                &c4_u0, 1, 3, 0U, 0, 0U, 0);
  c4_y = c4_u0;
  sf_mex_destroy(&c4_b_is_active_c4_MPC_gamecontroller_LiDAR2);
  return c4_y;
}

static void init_dsm_address_info(SFc4_MPC_gamecontroller_LiDAR2InstanceStruct
  *chartInstance)
{
}

/* SFunction Glue Code */
void sf_c4_MPC_gamecontroller_LiDAR2_get_check_sum(mxArray *plhs[])
{
  ((real_T *)mxGetPr((plhs[0])))[0] = (real_T)(1782909447U);
  ((real_T *)mxGetPr((plhs[0])))[1] = (real_T)(3058006903U);
  ((real_T *)mxGetPr((plhs[0])))[2] = (real_T)(2635247593U);
  ((real_T *)mxGetPr((plhs[0])))[3] = (real_T)(3281816815U);
}

mxArray *sf_c4_MPC_gamecontroller_LiDAR2_get_autoinheritance_info(void)
{
  const char *autoinheritanceFields[] = { "checksum", "inputs", "parameters",
    "outputs" };

  mxArray *mxAutoinheritanceInfo = mxCreateStructMatrix(1,1,4,
    autoinheritanceFields);

  {
    mxArray *mxChecksum = mxCreateDoubleMatrix(4,1,mxREAL);
    double *pr = mxGetPr(mxChecksum);
    pr[0] = (double)(3721112673U);
    pr[1] = (double)(2305067683U);
    pr[2] = (double)(2622996367U);
    pr[3] = (double)(130636722U);
    mxSetField(mxAutoinheritanceInfo,0,"checksum",mxChecksum);
  }

  {
    const char *dataFields[] = { "size", "type", "complexity" };

    mxArray *mxData = mxCreateStructMatrix(1,1,3,dataFields);

    {
      mxArray *mxSize = mxCreateDoubleMatrix(1,2,mxREAL);
      double *pr = mxGetPr(mxSize);
      pr[0] = (double)(1);
      pr[1] = (double)(1);
      mxSetField(mxData,0,"size",mxSize);
    }

    {
      const char *typeFields[] = { "base", "fixpt" };

      mxArray *mxType = mxCreateStructMatrix(1,1,2,typeFields);
      mxSetField(mxType,0,"base",mxCreateDoubleScalar(10));
      mxSetField(mxType,0,"fixpt",mxCreateDoubleMatrix(0,0,mxREAL));
      mxSetField(mxData,0,"type",mxType);
    }

    mxSetField(mxData,0,"complexity",mxCreateDoubleScalar(0));
    mxSetField(mxAutoinheritanceInfo,0,"inputs",mxData);
  }

  {
    mxSetField(mxAutoinheritanceInfo,0,"parameters",mxCreateDoubleMatrix(0,0,
                mxREAL));
  }

  {
    const char *dataFields[] = { "size", "type", "complexity" };

    mxArray *mxData = mxCreateStructMatrix(1,1,3,dataFields);

    {
      mxArray *mxSize = mxCreateDoubleMatrix(1,2,mxREAL);
      double *pr = mxGetPr(mxSize);
      pr[0] = (double)(1);
      pr[1] = (double)(1);
      mxSetField(mxData,0,"size",mxSize);
    }

    {
      const char *typeFields[] = { "base", "fixpt" };

      mxArray *mxType = mxCreateStructMatrix(1,1,2,typeFields);
      mxSetField(mxType,0,"base",mxCreateDoubleScalar(10));
      mxSetField(mxType,0,"fixpt",mxCreateDoubleMatrix(0,0,mxREAL));
      mxSetField(mxData,0,"type",mxType);
    }

    mxSetField(mxData,0,"complexity",mxCreateDoubleScalar(0));
    mxSetField(mxAutoinheritanceInfo,0,"outputs",mxData);
  }

  return(mxAutoinheritanceInfo);
}

static mxArray *sf_get_sim_state_info_c4_MPC_gamecontroller_LiDAR2(void)
{
  const char *infoFields[] = { "chartChecksum", "varInfo" };

  mxArray *mxInfo = mxCreateStructMatrix(1, 1, 2, infoFields);
  const char *infoEncStr[] = {
    "100 S1x2'type','srcId','name','auxInfo'{{M[1],M[5],T\"turnangle\",},{M[8],M[0],T\"is_active_c4_MPC_gamecontroller_LiDAR2\",}}"
  };

  mxArray *mxVarInfo = sf_mex_decode_encoded_mx_struct_array(infoEncStr, 2, 10);
  mxArray *mxChecksum = mxCreateDoubleMatrix(1, 4, mxREAL);
  sf_c4_MPC_gamecontroller_LiDAR2_get_check_sum(&mxChecksum);
  mxSetField(mxInfo, 0, infoFields[0], mxChecksum);
  mxSetField(mxInfo, 0, infoFields[1], mxVarInfo);
  return mxInfo;
}

static void chart_debug_initialization(SimStruct *S, unsigned int
  fullDebuggerInitialization)
{
  if (!sim_mode_is_rtw_gen(S)) {
    SFc4_MPC_gamecontroller_LiDAR2InstanceStruct *chartInstance;
    chartInstance = (SFc4_MPC_gamecontroller_LiDAR2InstanceStruct *)
      ((ChartInfoStruct *)(ssGetUserData(S)))->chartInstance;
    if (ssIsFirstInitCond(S) && fullDebuggerInitialization==1) {
      /* do this only if simulation is starting */
      {
        unsigned int chartAlreadyPresent;
        chartAlreadyPresent = sf_debug_initialize_chart
          (_MPC_gamecontroller_LiDAR2MachineNumber_,
           4,
           1,
           1,
           2,
           0,
           0,
           0,
           0,
           0,
           &(chartInstance->chartNumber),
           &(chartInstance->instanceNumber),
           ssGetPath(S),
           (void *)S);
        if (chartAlreadyPresent==0) {
          /* this is the first instance */
          init_script_number_translation
            (_MPC_gamecontroller_LiDAR2MachineNumber_,chartInstance->chartNumber);
          sf_debug_set_chart_disable_implicit_casting
            (_MPC_gamecontroller_LiDAR2MachineNumber_,chartInstance->chartNumber,
             1);
          sf_debug_set_chart_event_thresholds
            (_MPC_gamecontroller_LiDAR2MachineNumber_,
             chartInstance->chartNumber,
             0,
             0,
             0);
          _SFD_SET_DATA_PROPS(0,1,1,0,"angler");
          _SFD_SET_DATA_PROPS(1,2,0,1,"turnangle");
          _SFD_STATE_INFO(0,0,2);
          _SFD_CH_SUBSTATE_COUNT(0);
          _SFD_CH_SUBSTATE_DECOMP(0);
        }

        _SFD_CV_INIT_CHART(0,0,0,0);

        {
          _SFD_CV_INIT_STATE(0,0,0,0,0,0,NULL,NULL);
        }

        _SFD_CV_INIT_TRANS(0,0,NULL,NULL,0,NULL);

        /* Initialization of EML Model Coverage */
        _SFD_CV_INIT_EML(0,1,2,0,0,0,0,0,0);
        _SFD_CV_INIT_EML_FCN(0,0,"eML_blk_kernel",0,-1,182);
        _SFD_CV_INIT_EML_IF(0,0,51,63,102,181);
        _SFD_CV_INIT_EML_IF(0,1,102,118,151,181);
        _SFD_TRANS_COV_WTS(0,0,0,1,0);
        if (chartAlreadyPresent==0) {
          _SFD_TRANS_COV_MAPS(0,
                              0,NULL,NULL,
                              0,NULL,NULL,
                              1,NULL,NULL,
                              0,NULL,NULL);
        }

        _SFD_SET_DATA_COMPILED_PROPS(0,SF_DOUBLE,0,NULL,0,0,0,0.0,1.0,0,0,
          (MexFcnForType)c4_sf_marshall);
        _SFD_SET_DATA_COMPILED_PROPS(1,SF_DOUBLE,0,NULL,0,0,0,0.0,1.0,0,0,
          (MexFcnForType)c4_sf_marshall);

        {
          real_T *c4_angler;
          real_T *c4_turnangle;
          c4_turnangle = (real_T *)ssGetOutputPortSignal(chartInstance->S, 1);
          c4_angler = (real_T *)ssGetInputPortSignal(chartInstance->S, 0);
          _SFD_SET_DATA_VALUE_PTR(0U, c4_angler);
          _SFD_SET_DATA_VALUE_PTR(1U, c4_turnangle);
        }
      }
    } else {
      sf_debug_reset_current_state_configuration
        (_MPC_gamecontroller_LiDAR2MachineNumber_,chartInstance->chartNumber,
         chartInstance->instanceNumber);
    }
  }
}

static void sf_opaque_initialize_c4_MPC_gamecontroller_LiDAR2(void
  *chartInstanceVar)
{
  chart_debug_initialization(((SFc4_MPC_gamecontroller_LiDAR2InstanceStruct*)
    chartInstanceVar)->S,0);
  initialize_params_c4_MPC_gamecontroller_LiDAR2
    ((SFc4_MPC_gamecontroller_LiDAR2InstanceStruct*) chartInstanceVar);
  initialize_c4_MPC_gamecontroller_LiDAR2
    ((SFc4_MPC_gamecontroller_LiDAR2InstanceStruct*) chartInstanceVar);
}

static void sf_opaque_enable_c4_MPC_gamecontroller_LiDAR2(void *chartInstanceVar)
{
  enable_c4_MPC_gamecontroller_LiDAR2
    ((SFc4_MPC_gamecontroller_LiDAR2InstanceStruct*) chartInstanceVar);
}

static void sf_opaque_disable_c4_MPC_gamecontroller_LiDAR2(void
  *chartInstanceVar)
{
  disable_c4_MPC_gamecontroller_LiDAR2
    ((SFc4_MPC_gamecontroller_LiDAR2InstanceStruct*) chartInstanceVar);
}

static void sf_opaque_gateway_c4_MPC_gamecontroller_LiDAR2(void
  *chartInstanceVar)
{
  sf_c4_MPC_gamecontroller_LiDAR2((SFc4_MPC_gamecontroller_LiDAR2InstanceStruct*)
    chartInstanceVar);
}

static mxArray* sf_internal_get_sim_state_c4_MPC_gamecontroller_LiDAR2(SimStruct*
  S)
{
  ChartInfoStruct *chartInfo = (ChartInfoStruct*) ssGetUserData(S);
  mxArray *plhs[1] = { NULL };

  mxArray *prhs[4];
  int mxError = 0;
  prhs[0] = mxCreateString("chart_simctx_raw2high");
  prhs[1] = mxCreateDoubleScalar(ssGetSFuncBlockHandle(S));
  prhs[2] = (mxArray*) get_sim_state_c4_MPC_gamecontroller_LiDAR2
    ((SFc4_MPC_gamecontroller_LiDAR2InstanceStruct*)chartInfo->chartInstance);/* raw sim ctx */
  prhs[3] = sf_get_sim_state_info_c4_MPC_gamecontroller_LiDAR2();/* state var info */
  mxError = sf_mex_call_matlab(1, plhs, 4, prhs, "sfprivate");
  mxDestroyArray(prhs[0]);
  mxDestroyArray(prhs[1]);
  mxDestroyArray(prhs[2]);
  mxDestroyArray(prhs[3]);
  if (mxError || plhs[0] == NULL) {
    sf_mex_error_message("Stateflow Internal Error: \nError calling 'chart_simctx_raw2high'.\n");
  }

  return plhs[0];
}

static void sf_internal_set_sim_state_c4_MPC_gamecontroller_LiDAR2(SimStruct* S,
  const mxArray *st)
{
  ChartInfoStruct *chartInfo = (ChartInfoStruct*) ssGetUserData(S);
  mxArray *plhs[1] = { NULL };

  mxArray *prhs[4];
  int mxError = 0;
  prhs[0] = mxCreateString("chart_simctx_high2raw");
  prhs[1] = mxCreateDoubleScalar(ssGetSFuncBlockHandle(S));
  prhs[2] = mxDuplicateArray(st);      /* high level simctx */
  prhs[3] = (mxArray*) sf_get_sim_state_info_c4_MPC_gamecontroller_LiDAR2();/* state var info */
  mxError = sf_mex_call_matlab(1, plhs, 4, prhs, "sfprivate");
  mxDestroyArray(prhs[0]);
  mxDestroyArray(prhs[1]);
  mxDestroyArray(prhs[2]);
  mxDestroyArray(prhs[3]);
  if (mxError || plhs[0] == NULL) {
    sf_mex_error_message("Stateflow Internal Error: \nError calling 'chart_simctx_high2raw'.\n");
  }

  set_sim_state_c4_MPC_gamecontroller_LiDAR2
    ((SFc4_MPC_gamecontroller_LiDAR2InstanceStruct*)chartInfo->chartInstance,
     mxDuplicateArray(plhs[0]));
  mxDestroyArray(plhs[0]);
}

static mxArray* sf_opaque_get_sim_state_c4_MPC_gamecontroller_LiDAR2(SimStruct*
  S)
{
  return sf_internal_get_sim_state_c4_MPC_gamecontroller_LiDAR2(S);
}

static void sf_opaque_set_sim_state_c4_MPC_gamecontroller_LiDAR2(SimStruct* S,
  const mxArray *st)
{
  sf_internal_set_sim_state_c4_MPC_gamecontroller_LiDAR2(S, st);
}

static void sf_opaque_terminate_c4_MPC_gamecontroller_LiDAR2(void
  *chartInstanceVar)
{
  if (chartInstanceVar!=NULL) {
    SimStruct *S = ((SFc4_MPC_gamecontroller_LiDAR2InstanceStruct*)
                    chartInstanceVar)->S;
    if (sim_mode_is_rtw_gen(S) || sim_mode_is_external(S)) {
      sf_clear_rtw_identifier(S);
    }

    finalize_c4_MPC_gamecontroller_LiDAR2
      ((SFc4_MPC_gamecontroller_LiDAR2InstanceStruct*) chartInstanceVar);
    free((void *)chartInstanceVar);
    ssSetUserData(S,NULL);
  }
}

static void sf_opaque_init_subchart_simstructs(void *chartInstanceVar)
{
  compInitSubchartSimstructsFcn_c4_MPC_gamecontroller_LiDAR2
    ((SFc4_MPC_gamecontroller_LiDAR2InstanceStruct*) chartInstanceVar);
}

extern unsigned int sf_machine_global_initializer_called(void);
static void mdlProcessParameters_c4_MPC_gamecontroller_LiDAR2(SimStruct *S)
{
  int i;
  for (i=0;i<ssGetNumRunTimeParams(S);i++) {
    if (ssGetSFcnParamTunable(S,i)) {
      ssUpdateDlgParamAsRunTimeParam(S,i);
    }
  }

  if (sf_machine_global_initializer_called()) {
    initialize_params_c4_MPC_gamecontroller_LiDAR2
      ((SFc4_MPC_gamecontroller_LiDAR2InstanceStruct*)(((ChartInfoStruct *)
         ssGetUserData(S))->chartInstance));
  }
}

static void mdlSetWorkWidths_c4_MPC_gamecontroller_LiDAR2(SimStruct *S)
{
  if (sim_mode_is_rtw_gen(S) || sim_mode_is_external(S)) {
    int_T chartIsInlinable =
      (int_T)sf_is_chart_inlinable(S,"MPC_gamecontroller_LiDAR2",
      "MPC_gamecontroller_LiDAR2",4);
    ssSetStateflowIsInlinable(S,chartIsInlinable);
    ssSetRTWCG(S,sf_rtw_info_uint_prop(S,"MPC_gamecontroller_LiDAR2",
                "MPC_gamecontroller_LiDAR2",4,"RTWCG"));
    ssSetEnableFcnIsTrivial(S,1);
    ssSetDisableFcnIsTrivial(S,1);
    ssSetNotMultipleInlinable(S,sf_rtw_info_uint_prop(S,
      "MPC_gamecontroller_LiDAR2","MPC_gamecontroller_LiDAR2",4,
      "gatewayCannotBeInlinedMultipleTimes"));
    if (chartIsInlinable) {
      ssSetInputPortOptimOpts(S, 0, SS_REUSABLE_AND_LOCAL);
      sf_mark_chart_expressionable_inputs(S,"MPC_gamecontroller_LiDAR2",
        "MPC_gamecontroller_LiDAR2",4,1);
      sf_mark_chart_reusable_outputs(S,"MPC_gamecontroller_LiDAR2",
        "MPC_gamecontroller_LiDAR2",4,1);
    }

    sf_set_rtw_dwork_info(S,"MPC_gamecontroller_LiDAR2",
                          "MPC_gamecontroller_LiDAR2",4);
    ssSetHasSubFunctions(S,!(chartIsInlinable));
  } else {
  }

  ssSetOptions(S,ssGetOptions(S)|SS_OPTION_WORKS_WITH_CODE_REUSE);
  ssSetChecksum0(S,(2904717035U));
  ssSetChecksum1(S,(4284428096U));
  ssSetChecksum2(S,(4221278222U));
  ssSetChecksum3(S,(2307567712U));
  ssSetmdlDerivatives(S, NULL);
  ssSetExplicitFCSSCtrl(S,1);
}

static void mdlRTW_c4_MPC_gamecontroller_LiDAR2(SimStruct *S)
{
  if (sim_mode_is_rtw_gen(S)) {
    sf_write_symbol_mapping(S, "MPC_gamecontroller_LiDAR2",
      "MPC_gamecontroller_LiDAR2",4);
    ssWriteRTWStrParam(S, "StateflowChartType", "Embedded MATLAB");
  }
}

static void mdlStart_c4_MPC_gamecontroller_LiDAR2(SimStruct *S)
{
  SFc4_MPC_gamecontroller_LiDAR2InstanceStruct *chartInstance;
  chartInstance = (SFc4_MPC_gamecontroller_LiDAR2InstanceStruct *)malloc(sizeof
    (SFc4_MPC_gamecontroller_LiDAR2InstanceStruct));
  memset(chartInstance, 0, sizeof(SFc4_MPC_gamecontroller_LiDAR2InstanceStruct));
  if (chartInstance==NULL) {
    sf_mex_error_message("Could not allocate memory for chart instance.");
  }

  chartInstance->chartInfo.chartInstance = chartInstance;
  chartInstance->chartInfo.isEMLChart = 1;
  chartInstance->chartInfo.chartInitialized = 0;
  chartInstance->chartInfo.sFunctionGateway =
    sf_opaque_gateway_c4_MPC_gamecontroller_LiDAR2;
  chartInstance->chartInfo.initializeChart =
    sf_opaque_initialize_c4_MPC_gamecontroller_LiDAR2;
  chartInstance->chartInfo.terminateChart =
    sf_opaque_terminate_c4_MPC_gamecontroller_LiDAR2;
  chartInstance->chartInfo.enableChart =
    sf_opaque_enable_c4_MPC_gamecontroller_LiDAR2;
  chartInstance->chartInfo.disableChart =
    sf_opaque_disable_c4_MPC_gamecontroller_LiDAR2;
  chartInstance->chartInfo.getSimState =
    sf_opaque_get_sim_state_c4_MPC_gamecontroller_LiDAR2;
  chartInstance->chartInfo.setSimState =
    sf_opaque_set_sim_state_c4_MPC_gamecontroller_LiDAR2;
  chartInstance->chartInfo.getSimStateInfo =
    sf_get_sim_state_info_c4_MPC_gamecontroller_LiDAR2;
  chartInstance->chartInfo.zeroCrossings = NULL;
  chartInstance->chartInfo.outputs = NULL;
  chartInstance->chartInfo.derivatives = NULL;
  chartInstance->chartInfo.mdlRTW = mdlRTW_c4_MPC_gamecontroller_LiDAR2;
  chartInstance->chartInfo.mdlStart = mdlStart_c4_MPC_gamecontroller_LiDAR2;
  chartInstance->chartInfo.mdlSetWorkWidths =
    mdlSetWorkWidths_c4_MPC_gamecontroller_LiDAR2;
  chartInstance->chartInfo.extModeExec = NULL;
  chartInstance->chartInfo.restoreLastMajorStepConfiguration = NULL;
  chartInstance->chartInfo.restoreBeforeLastMajorStepConfiguration = NULL;
  chartInstance->chartInfo.storeCurrentConfiguration = NULL;
  chartInstance->S = S;
  ssSetUserData(S,(void *)(&(chartInstance->chartInfo)));/* register the chart instance with simstruct */
  init_dsm_address_info(chartInstance);
  if (!sim_mode_is_rtw_gen(S)) {
  }

  sf_opaque_init_subchart_simstructs(chartInstance->chartInfo.chartInstance);
  chart_debug_initialization(S,1);
}

void c4_MPC_gamecontroller_LiDAR2_method_dispatcher(SimStruct *S, int_T method,
  void *data)
{
  switch (method) {
   case SS_CALL_MDL_START:
    mdlStart_c4_MPC_gamecontroller_LiDAR2(S);
    break;

   case SS_CALL_MDL_SET_WORK_WIDTHS:
    mdlSetWorkWidths_c4_MPC_gamecontroller_LiDAR2(S);
    break;

   case SS_CALL_MDL_PROCESS_PARAMETERS:
    mdlProcessParameters_c4_MPC_gamecontroller_LiDAR2(S);
    break;

   default:
    /* Unhandled method */
    sf_mex_error_message("Stateflow Internal Error:\n"
                         "Error calling c4_MPC_gamecontroller_LiDAR2_method_dispatcher.\n"
                         "Can't handle method %d.\n", method);
    break;
  }
}
