/* Include files */

#include "blascompat32.h"
#include "MPC_gamecontroller_LiDAR2_sfun.h"
#include "c1_MPC_gamecontroller_LiDAR2.h"
#define CHARTINSTANCE_CHARTNUMBER      (chartInstance->chartNumber)
#define CHARTINSTANCE_INSTANCENUMBER   (chartInstance->instanceNumber)
#include "MPC_gamecontroller_LiDAR2_sfun_debug_macros.h"

/* Type Definitions */

/* Named Constants */

/* Variable Declarations */

/* Variable Definitions */
static const char *c1_debug_family_names[8] = { "nargin", "nargout", "direction",
  "throttle", "neutral", "kill", "last_state", "steer" };

/* Function Declarations */
static void initialize_c1_MPC_gamecontroller_LiDAR2
  (SFc1_MPC_gamecontroller_LiDAR2InstanceStruct *chartInstance);
static void initialize_params_c1_MPC_gamecontroller_LiDAR2
  (SFc1_MPC_gamecontroller_LiDAR2InstanceStruct *chartInstance);
static void enable_c1_MPC_gamecontroller_LiDAR2
  (SFc1_MPC_gamecontroller_LiDAR2InstanceStruct *chartInstance);
static void disable_c1_MPC_gamecontroller_LiDAR2
  (SFc1_MPC_gamecontroller_LiDAR2InstanceStruct *chartInstance);
static void c1_update_debugger_state_c1_MPC_gamecontroller_LiDAR2
  (SFc1_MPC_gamecontroller_LiDAR2InstanceStruct *chartInstance);
static const mxArray *get_sim_state_c1_MPC_gamecontroller_LiDAR2
  (SFc1_MPC_gamecontroller_LiDAR2InstanceStruct *chartInstance);
static void set_sim_state_c1_MPC_gamecontroller_LiDAR2
  (SFc1_MPC_gamecontroller_LiDAR2InstanceStruct *chartInstance, const mxArray
   *c1_st);
static void finalize_c1_MPC_gamecontroller_LiDAR2
  (SFc1_MPC_gamecontroller_LiDAR2InstanceStruct *chartInstance);
static void sf_c1_MPC_gamecontroller_LiDAR2
  (SFc1_MPC_gamecontroller_LiDAR2InstanceStruct *chartInstance);
static void compInitSubchartSimstructsFcn_c1_MPC_gamecontroller_LiDAR2
  (SFc1_MPC_gamecontroller_LiDAR2InstanceStruct *chartInstance);
static void init_script_number_translation(uint32_T c1_machineNumber, uint32_T
  c1_chartNumber);
static const mxArray *c1_sf_marshall(void *chartInstanceVoid, void *c1_u);
static const mxArray *c1_b_sf_marshall(void *chartInstanceVoid, void *c1_u);
static const mxArray *c1_c_sf_marshall(void *chartInstanceVoid, void *c1_u);
static void c1_emlrt_marshallIn(SFc1_MPC_gamecontroller_LiDAR2InstanceStruct
  *chartInstance, const mxArray *c1_steer, const char_T *c1_name, real_T c1_y[3]);
static uint8_T c1_b_emlrt_marshallIn
  (SFc1_MPC_gamecontroller_LiDAR2InstanceStruct *chartInstance, const mxArray
   *c1_b_is_active_c1_MPC_gamecontroller_LiDAR2, const char_T *c1_name);
static void init_dsm_address_info(SFc1_MPC_gamecontroller_LiDAR2InstanceStruct
  *chartInstance);

/* Function Definitions */
static void initialize_c1_MPC_gamecontroller_LiDAR2
  (SFc1_MPC_gamecontroller_LiDAR2InstanceStruct *chartInstance)
{
  _sfTime_ = (real_T)ssGetT(chartInstance->S);
  chartInstance->c1_is_active_c1_MPC_gamecontroller_LiDAR2 = 0U;
}

static void initialize_params_c1_MPC_gamecontroller_LiDAR2
  (SFc1_MPC_gamecontroller_LiDAR2InstanceStruct *chartInstance)
{
}

static void enable_c1_MPC_gamecontroller_LiDAR2
  (SFc1_MPC_gamecontroller_LiDAR2InstanceStruct *chartInstance)
{
  _sfTime_ = (real_T)ssGetT(chartInstance->S);
}

static void disable_c1_MPC_gamecontroller_LiDAR2
  (SFc1_MPC_gamecontroller_LiDAR2InstanceStruct *chartInstance)
{
  _sfTime_ = (real_T)ssGetT(chartInstance->S);
}

static void c1_update_debugger_state_c1_MPC_gamecontroller_LiDAR2
  (SFc1_MPC_gamecontroller_LiDAR2InstanceStruct *chartInstance)
{
}

static const mxArray *get_sim_state_c1_MPC_gamecontroller_LiDAR2
  (SFc1_MPC_gamecontroller_LiDAR2InstanceStruct *chartInstance)
{
  const mxArray *c1_st = NULL;
  const mxArray *c1_y = NULL;
  int32_T c1_i0;
  real_T c1_hoistedGlobal[3];
  int32_T c1_i1;
  real_T c1_u[3];
  const mxArray *c1_b_y = NULL;
  uint8_T c1_b_hoistedGlobal;
  uint8_T c1_b_u;
  const mxArray *c1_c_y = NULL;
  real_T (*c1_steer)[3];
  c1_steer = (real_T (*)[3])ssGetOutputPortSignal(chartInstance->S, 1);
  c1_st = NULL;
  c1_y = NULL;
  sf_mex_assign(&c1_y, sf_mex_createcellarray(2));
  for (c1_i0 = 0; c1_i0 < 3; c1_i0 = c1_i0 + 1) {
    c1_hoistedGlobal[c1_i0] = (*c1_steer)[c1_i0];
  }

  for (c1_i1 = 0; c1_i1 < 3; c1_i1 = c1_i1 + 1) {
    c1_u[c1_i1] = c1_hoistedGlobal[c1_i1];
  }

  c1_b_y = NULL;
  sf_mex_assign(&c1_b_y, sf_mex_create("y", c1_u, 0, 0U, 1U, 0U, 1, 3));
  sf_mex_setcell(c1_y, 0, c1_b_y);
  c1_b_hoistedGlobal = chartInstance->c1_is_active_c1_MPC_gamecontroller_LiDAR2;
  c1_b_u = c1_b_hoistedGlobal;
  c1_c_y = NULL;
  sf_mex_assign(&c1_c_y, sf_mex_create("y", &c1_b_u, 3, 0U, 0U, 0U, 0));
  sf_mex_setcell(c1_y, 1, c1_c_y);
  sf_mex_assign(&c1_st, c1_y);
  return c1_st;
}

static void set_sim_state_c1_MPC_gamecontroller_LiDAR2
  (SFc1_MPC_gamecontroller_LiDAR2InstanceStruct *chartInstance, const mxArray *
   c1_st)
{
  const mxArray *c1_u;
  real_T c1_dv0[3];
  int32_T c1_i2;
  real_T (*c1_steer)[3];
  c1_steer = (real_T (*)[3])ssGetOutputPortSignal(chartInstance->S, 1);
  chartInstance->c1_doneDoubleBufferReInit = TRUE;
  c1_u = sf_mex_dup(c1_st);
  c1_emlrt_marshallIn(chartInstance, sf_mex_dup(sf_mex_getcell(c1_u, 0)),
                      "steer", c1_dv0);
  for (c1_i2 = 0; c1_i2 < 3; c1_i2 = c1_i2 + 1) {
    (*c1_steer)[c1_i2] = c1_dv0[c1_i2];
  }

  chartInstance->c1_is_active_c1_MPC_gamecontroller_LiDAR2 =
    c1_b_emlrt_marshallIn(chartInstance, sf_mex_dup(sf_mex_getcell(c1_u, 1))
    , "is_active_c1_MPC_gamecontroller_LiDAR2");
  sf_mex_destroy(&c1_u);
  c1_update_debugger_state_c1_MPC_gamecontroller_LiDAR2(chartInstance);
  sf_mex_destroy(&c1_st);
}

static void finalize_c1_MPC_gamecontroller_LiDAR2
  (SFc1_MPC_gamecontroller_LiDAR2InstanceStruct *chartInstance)
{
}

static void sf_c1_MPC_gamecontroller_LiDAR2
  (SFc1_MPC_gamecontroller_LiDAR2InstanceStruct *chartInstance)
{
  int32_T c1_i3;
  int32_T c1_i4;
  int32_T c1_i5;
  int32_T c1_previousEvent;
  real_T c1_hoistedGlobal;
  real_T c1_b_hoistedGlobal;
  int32_T c1_i6;
  real_T c1_c_hoistedGlobal[3];
  boolean_T c1_d_hoistedGlobal;
  int32_T c1_i7;
  real_T c1_e_hoistedGlobal[3];
  real_T c1_direction;
  real_T c1_throttle;
  int32_T c1_i8;
  real_T c1_neutral[3];
  boolean_T c1_kill;
  int32_T c1_i9;
  real_T c1_last_state[3];
  uint32_T c1_debug_family_var_map[8];
  real_T c1_nargin = 5.0;
  real_T c1_nargout = 1.0;
  real_T c1_steer[3];
  int32_T c1_i10;
  int32_T c1_i11;
  int32_T c1_i12;
  real_T *c1_b_direction;
  real_T *c1_b_throttle;
  boolean_T *c1_b_kill;
  real_T (*c1_b_steer)[3];
  real_T (*c1_b_last_state)[3];
  real_T (*c1_b_neutral)[3];
  c1_b_last_state = (real_T (*)[3])ssGetInputPortSignal(chartInstance->S, 4);
  c1_b_kill = (boolean_T *)ssGetInputPortSignal(chartInstance->S, 3);
  c1_b_neutral = (real_T (*)[3])ssGetInputPortSignal(chartInstance->S, 2);
  c1_b_throttle = (real_T *)ssGetInputPortSignal(chartInstance->S, 1);
  c1_b_steer = (real_T (*)[3])ssGetOutputPortSignal(chartInstance->S, 1);
  c1_b_direction = (real_T *)ssGetInputPortSignal(chartInstance->S, 0);
  _sfTime_ = (real_T)ssGetT(chartInstance->S);
  _SFD_CC_CALL(CHART_ENTER_SFUNCTION_TAG, 0);
  _SFD_DATA_RANGE_CHECK(*c1_b_direction, 0U);
  for (c1_i3 = 0; c1_i3 < 3; c1_i3 = c1_i3 + 1) {
    _SFD_DATA_RANGE_CHECK((*c1_b_steer)[c1_i3], 1U);
  }

  _SFD_DATA_RANGE_CHECK(*c1_b_throttle, 2U);
  for (c1_i4 = 0; c1_i4 < 3; c1_i4 = c1_i4 + 1) {
    _SFD_DATA_RANGE_CHECK((*c1_b_neutral)[c1_i4], 3U);
  }

  _SFD_DATA_RANGE_CHECK((real_T)*c1_b_kill, 4U);
  for (c1_i5 = 0; c1_i5 < 3; c1_i5 = c1_i5 + 1) {
    _SFD_DATA_RANGE_CHECK((*c1_b_last_state)[c1_i5], 5U);
  }

  c1_previousEvent = _sfEvent_;
  _sfEvent_ = CALL_EVENT;
  _SFD_CC_CALL(CHART_ENTER_DURING_FUNCTION_TAG, 0);
  c1_hoistedGlobal = *c1_b_direction;
  c1_b_hoistedGlobal = *c1_b_throttle;
  for (c1_i6 = 0; c1_i6 < 3; c1_i6 = c1_i6 + 1) {
    c1_c_hoistedGlobal[c1_i6] = (*c1_b_neutral)[c1_i6];
  }

  c1_d_hoistedGlobal = *c1_b_kill;
  for (c1_i7 = 0; c1_i7 < 3; c1_i7 = c1_i7 + 1) {
    c1_e_hoistedGlobal[c1_i7] = (*c1_b_last_state)[c1_i7];
  }

  c1_direction = c1_hoistedGlobal;
  c1_throttle = c1_b_hoistedGlobal;
  for (c1_i8 = 0; c1_i8 < 3; c1_i8 = c1_i8 + 1) {
    c1_neutral[c1_i8] = c1_c_hoistedGlobal[c1_i8];
  }

  c1_kill = c1_d_hoistedGlobal;
  for (c1_i9 = 0; c1_i9 < 3; c1_i9 = c1_i9 + 1) {
    c1_last_state[c1_i9] = c1_e_hoistedGlobal[c1_i9];
  }

  sf_debug_symbol_scope_push_eml(0U, 8U, 8U, c1_debug_family_names,
    c1_debug_family_var_map);
  sf_debug_symbol_scope_add_eml(&c1_nargin, c1_c_sf_marshall, 0U);
  sf_debug_symbol_scope_add_eml(&c1_nargout, c1_c_sf_marshall, 1U);
  sf_debug_symbol_scope_add_eml(&c1_direction, c1_c_sf_marshall, 2U);
  sf_debug_symbol_scope_add_eml(&c1_throttle, c1_c_sf_marshall, 3U);
  sf_debug_symbol_scope_add_eml(c1_neutral, c1_sf_marshall, 4U);
  sf_debug_symbol_scope_add_eml(&c1_kill, c1_b_sf_marshall, 5U);
  sf_debug_symbol_scope_add_eml(c1_last_state, c1_sf_marshall, 6U);
  sf_debug_symbol_scope_add_eml(c1_steer, c1_sf_marshall, 7U);
  CV_EML_FCN(0, 0);

  /* #codegen */
  _SFD_EML_CALL(0, 3);
  if (CV_EML_IF(0, 0, c1_kill)) {
    _SFD_EML_CALL(0, 4);
    for (c1_i10 = 0; c1_i10 < 3; c1_i10 = c1_i10 + 1) {
      c1_steer[c1_i10] = c1_neutral[c1_i10];
    }
  } else {
    _SFD_EML_CALL(0, 6);
    for (c1_i11 = 0; c1_i11 < 3; c1_i11 = c1_i11 + 1) {
      c1_steer[c1_i11] = c1_last_state[c1_i11];
    }

    _SFD_EML_CALL(0, 7);
    c1_steer[1] = c1_direction;
    _SFD_EML_CALL(0, 8);
    c1_steer[2] = c1_throttle;
  }

  _SFD_EML_CALL(0, -8);
  sf_debug_symbol_scope_pop();
  for (c1_i12 = 0; c1_i12 < 3; c1_i12 = c1_i12 + 1) {
    (*c1_b_steer)[c1_i12] = c1_steer[c1_i12];
  }

  _SFD_CC_CALL(EXIT_OUT_OF_FUNCTION_TAG, 0);
  _sfEvent_ = c1_previousEvent;
  sf_debug_check_for_state_inconsistency
    (_MPC_gamecontroller_LiDAR2MachineNumber_, chartInstance->chartNumber,
     chartInstance->
     instanceNumber);
}

static void compInitSubchartSimstructsFcn_c1_MPC_gamecontroller_LiDAR2
  (SFc1_MPC_gamecontroller_LiDAR2InstanceStruct *chartInstance)
{
}

static void init_script_number_translation(uint32_T c1_machineNumber, uint32_T
  c1_chartNumber)
{
}

static const mxArray *c1_sf_marshall(void *chartInstanceVoid, void *c1_u)
{
  const mxArray *c1_y = NULL;
  int32_T c1_i13;
  real_T c1_b_u[3];
  int32_T c1_i14;
  real_T c1_c_u[3];
  const mxArray *c1_b_y = NULL;
  SFc1_MPC_gamecontroller_LiDAR2InstanceStruct *chartInstance;
  chartInstance = (SFc1_MPC_gamecontroller_LiDAR2InstanceStruct *)
    chartInstanceVoid;
  c1_y = NULL;
  for (c1_i13 = 0; c1_i13 < 3; c1_i13 = c1_i13 + 1) {
    c1_b_u[c1_i13] = (*((real_T (*)[3])c1_u))[c1_i13];
  }

  for (c1_i14 = 0; c1_i14 < 3; c1_i14 = c1_i14 + 1) {
    c1_c_u[c1_i14] = c1_b_u[c1_i14];
  }

  c1_b_y = NULL;
  sf_mex_assign(&c1_b_y, sf_mex_create("y", c1_c_u, 0, 0U, 1U, 0U, 1, 3));
  sf_mex_assign(&c1_y, c1_b_y);
  return c1_y;
}

static const mxArray *c1_b_sf_marshall(void *chartInstanceVoid, void *c1_u)
{
  const mxArray *c1_y = NULL;
  boolean_T c1_b_u;
  const mxArray *c1_b_y = NULL;
  SFc1_MPC_gamecontroller_LiDAR2InstanceStruct *chartInstance;
  chartInstance = (SFc1_MPC_gamecontroller_LiDAR2InstanceStruct *)
    chartInstanceVoid;
  c1_y = NULL;
  c1_b_u = *((boolean_T *)c1_u);
  c1_b_y = NULL;
  sf_mex_assign(&c1_b_y, sf_mex_create("y", &c1_b_u, 11, 0U, 0U, 0U, 0));
  sf_mex_assign(&c1_y, c1_b_y);
  return c1_y;
}

static const mxArray *c1_c_sf_marshall(void *chartInstanceVoid, void *c1_u)
{
  const mxArray *c1_y = NULL;
  real_T c1_b_u;
  const mxArray *c1_b_y = NULL;
  SFc1_MPC_gamecontroller_LiDAR2InstanceStruct *chartInstance;
  chartInstance = (SFc1_MPC_gamecontroller_LiDAR2InstanceStruct *)
    chartInstanceVoid;
  c1_y = NULL;
  c1_b_u = *((real_T *)c1_u);
  c1_b_y = NULL;
  sf_mex_assign(&c1_b_y, sf_mex_create("y", &c1_b_u, 0, 0U, 0U, 0U, 0));
  sf_mex_assign(&c1_y, c1_b_y);
  return c1_y;
}

const mxArray *sf_c1_MPC_gamecontroller_LiDAR2_get_eml_resolved_functions_info
  (void)
{
  const mxArray *c1_nameCaptureInfo = NULL;
  c1_nameCaptureInfo = NULL;
  sf_mex_assign(&c1_nameCaptureInfo, sf_mex_create("nameCaptureInfo", NULL, 0,
    0U, 1U, 0U, 2, 0, 1));
  return c1_nameCaptureInfo;
}

static void c1_emlrt_marshallIn(SFc1_MPC_gamecontroller_LiDAR2InstanceStruct
  *chartInstance, const mxArray *c1_steer, const char_T *
  c1_name, real_T c1_y[3])
{
  real_T c1_dv1[3];
  int32_T c1_i15;
  sf_mex_import(c1_name, sf_mex_dup(c1_steer), c1_dv1, 1, 0, 0U, 1, 0U, 1, 3);
  for (c1_i15 = 0; c1_i15 < 3; c1_i15 = c1_i15 + 1) {
    c1_y[c1_i15] = c1_dv1[c1_i15];
  }

  sf_mex_destroy(&c1_steer);
}

static uint8_T c1_b_emlrt_marshallIn
  (SFc1_MPC_gamecontroller_LiDAR2InstanceStruct *chartInstance, const mxArray *
   c1_b_is_active_c1_MPC_gamecontroller_LiDAR2, const char_T *c1_name)
{
  uint8_T c1_y;
  uint8_T c1_u0;
  sf_mex_import(c1_name, sf_mex_dup(c1_b_is_active_c1_MPC_gamecontroller_LiDAR2),
                &c1_u0, 1, 3, 0U, 0, 0U, 0);
  c1_y = c1_u0;
  sf_mex_destroy(&c1_b_is_active_c1_MPC_gamecontroller_LiDAR2);
  return c1_y;
}

static void init_dsm_address_info(SFc1_MPC_gamecontroller_LiDAR2InstanceStruct
  *chartInstance)
{
}

/* SFunction Glue Code */
void sf_c1_MPC_gamecontroller_LiDAR2_get_check_sum(mxArray *plhs[])
{
  ((real_T *)mxGetPr((plhs[0])))[0] = (real_T)(1142048441U);
  ((real_T *)mxGetPr((plhs[0])))[1] = (real_T)(1744090243U);
  ((real_T *)mxGetPr((plhs[0])))[2] = (real_T)(3507797465U);
  ((real_T *)mxGetPr((plhs[0])))[3] = (real_T)(3611325734U);
}

mxArray *sf_c1_MPC_gamecontroller_LiDAR2_get_autoinheritance_info(void)
{
  const char *autoinheritanceFields[] = { "checksum", "inputs", "parameters",
    "outputs" };

  mxArray *mxAutoinheritanceInfo = mxCreateStructMatrix(1,1,4,
    autoinheritanceFields);

  {
    mxArray *mxChecksum = mxCreateDoubleMatrix(4,1,mxREAL);
    double *pr = mxGetPr(mxChecksum);
    pr[0] = (double)(2050016041U);
    pr[1] = (double)(330744281U);
    pr[2] = (double)(2619954881U);
    pr[3] = (double)(3928456335U);
    mxSetField(mxAutoinheritanceInfo,0,"checksum",mxChecksum);
  }

  {
    const char *dataFields[] = { "size", "type", "complexity" };

    mxArray *mxData = mxCreateStructMatrix(1,5,3,dataFields);

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

    {
      mxArray *mxSize = mxCreateDoubleMatrix(1,2,mxREAL);
      double *pr = mxGetPr(mxSize);
      pr[0] = (double)(1);
      pr[1] = (double)(1);
      mxSetField(mxData,1,"size",mxSize);
    }

    {
      const char *typeFields[] = { "base", "fixpt" };

      mxArray *mxType = mxCreateStructMatrix(1,1,2,typeFields);
      mxSetField(mxType,0,"base",mxCreateDoubleScalar(10));
      mxSetField(mxType,0,"fixpt",mxCreateDoubleMatrix(0,0,mxREAL));
      mxSetField(mxData,1,"type",mxType);
    }

    mxSetField(mxData,1,"complexity",mxCreateDoubleScalar(0));

    {
      mxArray *mxSize = mxCreateDoubleMatrix(1,2,mxREAL);
      double *pr = mxGetPr(mxSize);
      pr[0] = (double)(3);
      pr[1] = (double)(1);
      mxSetField(mxData,2,"size",mxSize);
    }

    {
      const char *typeFields[] = { "base", "fixpt" };

      mxArray *mxType = mxCreateStructMatrix(1,1,2,typeFields);
      mxSetField(mxType,0,"base",mxCreateDoubleScalar(10));
      mxSetField(mxType,0,"fixpt",mxCreateDoubleMatrix(0,0,mxREAL));
      mxSetField(mxData,2,"type",mxType);
    }

    mxSetField(mxData,2,"complexity",mxCreateDoubleScalar(0));

    {
      mxArray *mxSize = mxCreateDoubleMatrix(1,2,mxREAL);
      double *pr = mxGetPr(mxSize);
      pr[0] = (double)(1);
      pr[1] = (double)(1);
      mxSetField(mxData,3,"size",mxSize);
    }

    {
      const char *typeFields[] = { "base", "fixpt" };

      mxArray *mxType = mxCreateStructMatrix(1,1,2,typeFields);
      mxSetField(mxType,0,"base",mxCreateDoubleScalar(1));
      mxSetField(mxType,0,"fixpt",mxCreateDoubleMatrix(0,0,mxREAL));
      mxSetField(mxData,3,"type",mxType);
    }

    mxSetField(mxData,3,"complexity",mxCreateDoubleScalar(0));

    {
      mxArray *mxSize = mxCreateDoubleMatrix(1,2,mxREAL);
      double *pr = mxGetPr(mxSize);
      pr[0] = (double)(3);
      pr[1] = (double)(1);
      mxSetField(mxData,4,"size",mxSize);
    }

    {
      const char *typeFields[] = { "base", "fixpt" };

      mxArray *mxType = mxCreateStructMatrix(1,1,2,typeFields);
      mxSetField(mxType,0,"base",mxCreateDoubleScalar(10));
      mxSetField(mxType,0,"fixpt",mxCreateDoubleMatrix(0,0,mxREAL));
      mxSetField(mxData,4,"type",mxType);
    }

    mxSetField(mxData,4,"complexity",mxCreateDoubleScalar(0));
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
      pr[0] = (double)(3);
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

static mxArray *sf_get_sim_state_info_c1_MPC_gamecontroller_LiDAR2(void)
{
  const char *infoFields[] = { "chartChecksum", "varInfo" };

  mxArray *mxInfo = mxCreateStructMatrix(1, 1, 2, infoFields);
  const char *infoEncStr[] = {
    "100 S1x2'type','srcId','name','auxInfo'{{M[1],M[5],T\"steer\",},{M[8],M[0],T\"is_active_c1_MPC_gamecontroller_LiDAR2\",}}"
  };

  mxArray *mxVarInfo = sf_mex_decode_encoded_mx_struct_array(infoEncStr, 2, 10);
  mxArray *mxChecksum = mxCreateDoubleMatrix(1, 4, mxREAL);
  sf_c1_MPC_gamecontroller_LiDAR2_get_check_sum(&mxChecksum);
  mxSetField(mxInfo, 0, infoFields[0], mxChecksum);
  mxSetField(mxInfo, 0, infoFields[1], mxVarInfo);
  return mxInfo;
}

static void chart_debug_initialization(SimStruct *S, unsigned int
  fullDebuggerInitialization)
{
  if (!sim_mode_is_rtw_gen(S)) {
    SFc1_MPC_gamecontroller_LiDAR2InstanceStruct *chartInstance;
    chartInstance = (SFc1_MPC_gamecontroller_LiDAR2InstanceStruct *)
      ((ChartInfoStruct *)(ssGetUserData(S)))->chartInstance;
    if (ssIsFirstInitCond(S) && fullDebuggerInitialization==1) {
      /* do this only if simulation is starting */
      {
        unsigned int chartAlreadyPresent;
        chartAlreadyPresent = sf_debug_initialize_chart
          (_MPC_gamecontroller_LiDAR2MachineNumber_,
           1,
           1,
           1,
           6,
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
          _SFD_SET_DATA_PROPS(0,1,1,0,"direction");
          _SFD_SET_DATA_PROPS(1,2,0,1,"steer");
          _SFD_SET_DATA_PROPS(2,1,1,0,"throttle");
          _SFD_SET_DATA_PROPS(3,1,1,0,"neutral");
          _SFD_SET_DATA_PROPS(4,1,1,0,"kill");
          _SFD_SET_DATA_PROPS(5,1,1,0,"last_state");
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
        _SFD_CV_INIT_EML(0,1,1,0,0,0,0,0,0);
        _SFD_CV_INIT_EML_FCN(0,0,"eML_blk_kernel",0,-1,200);
        _SFD_CV_INIT_EML_IF(0,0,91,99,120,198);
        _SFD_TRANS_COV_WTS(0,0,0,1,0);
        if (chartAlreadyPresent==0) {
          _SFD_TRANS_COV_MAPS(0,
                              0,NULL,NULL,
                              0,NULL,NULL,
                              1,NULL,NULL,
                              0,NULL,NULL);
        }

        _SFD_SET_DATA_COMPILED_PROPS(0,SF_DOUBLE,0,NULL,0,0,0,0.0,1.0,0,0,
          (MexFcnForType)c1_c_sf_marshall);

        {
          unsigned int dimVector[1];
          dimVector[0]= 3;
          _SFD_SET_DATA_COMPILED_PROPS(1,SF_DOUBLE,1,&(dimVector[0]),0,0,0,0.0,
            1.0,0,0,(MexFcnForType)c1_sf_marshall);
        }

        _SFD_SET_DATA_COMPILED_PROPS(2,SF_DOUBLE,0,NULL,0,0,0,0.0,1.0,0,0,
          (MexFcnForType)c1_c_sf_marshall);

        {
          unsigned int dimVector[1];
          dimVector[0]= 3;
          _SFD_SET_DATA_COMPILED_PROPS(3,SF_DOUBLE,1,&(dimVector[0]),0,0,0,0.0,
            1.0,0,0,(MexFcnForType)c1_sf_marshall);
        }

        _SFD_SET_DATA_COMPILED_PROPS(4,SF_UINT8,0,NULL,0,0,0,0.0,1.0,0,0,
          (MexFcnForType)c1_b_sf_marshall);

        {
          unsigned int dimVector[1];
          dimVector[0]= 3;
          _SFD_SET_DATA_COMPILED_PROPS(5,SF_DOUBLE,1,&(dimVector[0]),0,0,0,0.0,
            1.0,0,0,(MexFcnForType)c1_sf_marshall);
        }

        {
          real_T *c1_direction;
          real_T *c1_throttle;
          boolean_T *c1_kill;
          real_T (*c1_steer)[3];
          real_T (*c1_neutral)[3];
          real_T (*c1_last_state)[3];
          c1_last_state = (real_T (*)[3])ssGetInputPortSignal(chartInstance->S,
            4);
          c1_kill = (boolean_T *)ssGetInputPortSignal(chartInstance->S, 3);
          c1_neutral = (real_T (*)[3])ssGetInputPortSignal(chartInstance->S, 2);
          c1_throttle = (real_T *)ssGetInputPortSignal(chartInstance->S, 1);
          c1_steer = (real_T (*)[3])ssGetOutputPortSignal(chartInstance->S, 1);
          c1_direction = (real_T *)ssGetInputPortSignal(chartInstance->S, 0);
          _SFD_SET_DATA_VALUE_PTR(0U, c1_direction);
          _SFD_SET_DATA_VALUE_PTR(1U, *c1_steer);
          _SFD_SET_DATA_VALUE_PTR(2U, c1_throttle);
          _SFD_SET_DATA_VALUE_PTR(3U, *c1_neutral);
          _SFD_SET_DATA_VALUE_PTR(4U, c1_kill);
          _SFD_SET_DATA_VALUE_PTR(5U, *c1_last_state);
        }
      }
    } else {
      sf_debug_reset_current_state_configuration
        (_MPC_gamecontroller_LiDAR2MachineNumber_,chartInstance->chartNumber,
         chartInstance->instanceNumber);
    }
  }
}

static void sf_opaque_initialize_c1_MPC_gamecontroller_LiDAR2(void
  *chartInstanceVar)
{
  chart_debug_initialization(((SFc1_MPC_gamecontroller_LiDAR2InstanceStruct*)
    chartInstanceVar)->S,0);
  initialize_params_c1_MPC_gamecontroller_LiDAR2
    ((SFc1_MPC_gamecontroller_LiDAR2InstanceStruct*) chartInstanceVar);
  initialize_c1_MPC_gamecontroller_LiDAR2
    ((SFc1_MPC_gamecontroller_LiDAR2InstanceStruct*) chartInstanceVar);
}

static void sf_opaque_enable_c1_MPC_gamecontroller_LiDAR2(void *chartInstanceVar)
{
  enable_c1_MPC_gamecontroller_LiDAR2
    ((SFc1_MPC_gamecontroller_LiDAR2InstanceStruct*) chartInstanceVar);
}

static void sf_opaque_disable_c1_MPC_gamecontroller_LiDAR2(void
  *chartInstanceVar)
{
  disable_c1_MPC_gamecontroller_LiDAR2
    ((SFc1_MPC_gamecontroller_LiDAR2InstanceStruct*) chartInstanceVar);
}

static void sf_opaque_gateway_c1_MPC_gamecontroller_LiDAR2(void
  *chartInstanceVar)
{
  sf_c1_MPC_gamecontroller_LiDAR2((SFc1_MPC_gamecontroller_LiDAR2InstanceStruct*)
    chartInstanceVar);
}

static mxArray* sf_internal_get_sim_state_c1_MPC_gamecontroller_LiDAR2(SimStruct*
  S)
{
  ChartInfoStruct *chartInfo = (ChartInfoStruct*) ssGetUserData(S);
  mxArray *plhs[1] = { NULL };

  mxArray *prhs[4];
  int mxError = 0;
  prhs[0] = mxCreateString("chart_simctx_raw2high");
  prhs[1] = mxCreateDoubleScalar(ssGetSFuncBlockHandle(S));
  prhs[2] = (mxArray*) get_sim_state_c1_MPC_gamecontroller_LiDAR2
    ((SFc1_MPC_gamecontroller_LiDAR2InstanceStruct*)chartInfo->chartInstance);/* raw sim ctx */
  prhs[3] = sf_get_sim_state_info_c1_MPC_gamecontroller_LiDAR2();/* state var info */
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

static void sf_internal_set_sim_state_c1_MPC_gamecontroller_LiDAR2(SimStruct* S,
  const mxArray *st)
{
  ChartInfoStruct *chartInfo = (ChartInfoStruct*) ssGetUserData(S);
  mxArray *plhs[1] = { NULL };

  mxArray *prhs[4];
  int mxError = 0;
  prhs[0] = mxCreateString("chart_simctx_high2raw");
  prhs[1] = mxCreateDoubleScalar(ssGetSFuncBlockHandle(S));
  prhs[2] = mxDuplicateArray(st);      /* high level simctx */
  prhs[3] = (mxArray*) sf_get_sim_state_info_c1_MPC_gamecontroller_LiDAR2();/* state var info */
  mxError = sf_mex_call_matlab(1, plhs, 4, prhs, "sfprivate");
  mxDestroyArray(prhs[0]);
  mxDestroyArray(prhs[1]);
  mxDestroyArray(prhs[2]);
  mxDestroyArray(prhs[3]);
  if (mxError || plhs[0] == NULL) {
    sf_mex_error_message("Stateflow Internal Error: \nError calling 'chart_simctx_high2raw'.\n");
  }

  set_sim_state_c1_MPC_gamecontroller_LiDAR2
    ((SFc1_MPC_gamecontroller_LiDAR2InstanceStruct*)chartInfo->chartInstance,
     mxDuplicateArray(plhs[0]));
  mxDestroyArray(plhs[0]);
}

static mxArray* sf_opaque_get_sim_state_c1_MPC_gamecontroller_LiDAR2(SimStruct*
  S)
{
  return sf_internal_get_sim_state_c1_MPC_gamecontroller_LiDAR2(S);
}

static void sf_opaque_set_sim_state_c1_MPC_gamecontroller_LiDAR2(SimStruct* S,
  const mxArray *st)
{
  sf_internal_set_sim_state_c1_MPC_gamecontroller_LiDAR2(S, st);
}

static void sf_opaque_terminate_c1_MPC_gamecontroller_LiDAR2(void
  *chartInstanceVar)
{
  if (chartInstanceVar!=NULL) {
    SimStruct *S = ((SFc1_MPC_gamecontroller_LiDAR2InstanceStruct*)
                    chartInstanceVar)->S;
    if (sim_mode_is_rtw_gen(S) || sim_mode_is_external(S)) {
      sf_clear_rtw_identifier(S);
    }

    finalize_c1_MPC_gamecontroller_LiDAR2
      ((SFc1_MPC_gamecontroller_LiDAR2InstanceStruct*) chartInstanceVar);
    free((void *)chartInstanceVar);
    ssSetUserData(S,NULL);
  }
}

static void sf_opaque_init_subchart_simstructs(void *chartInstanceVar)
{
  compInitSubchartSimstructsFcn_c1_MPC_gamecontroller_LiDAR2
    ((SFc1_MPC_gamecontroller_LiDAR2InstanceStruct*) chartInstanceVar);
}

extern unsigned int sf_machine_global_initializer_called(void);
static void mdlProcessParameters_c1_MPC_gamecontroller_LiDAR2(SimStruct *S)
{
  int i;
  for (i=0;i<ssGetNumRunTimeParams(S);i++) {
    if (ssGetSFcnParamTunable(S,i)) {
      ssUpdateDlgParamAsRunTimeParam(S,i);
    }
  }

  if (sf_machine_global_initializer_called()) {
    initialize_params_c1_MPC_gamecontroller_LiDAR2
      ((SFc1_MPC_gamecontroller_LiDAR2InstanceStruct*)(((ChartInfoStruct *)
         ssGetUserData(S))->chartInstance));
  }
}

static void mdlSetWorkWidths_c1_MPC_gamecontroller_LiDAR2(SimStruct *S)
{
  if (sim_mode_is_rtw_gen(S) || sim_mode_is_external(S)) {
    int_T chartIsInlinable =
      (int_T)sf_is_chart_inlinable(S,"MPC_gamecontroller_LiDAR2",
      "MPC_gamecontroller_LiDAR2",1);
    ssSetStateflowIsInlinable(S,chartIsInlinable);
    ssSetRTWCG(S,sf_rtw_info_uint_prop(S,"MPC_gamecontroller_LiDAR2",
                "MPC_gamecontroller_LiDAR2",1,"RTWCG"));
    ssSetEnableFcnIsTrivial(S,1);
    ssSetDisableFcnIsTrivial(S,1);
    ssSetNotMultipleInlinable(S,sf_rtw_info_uint_prop(S,
      "MPC_gamecontroller_LiDAR2","MPC_gamecontroller_LiDAR2",1,
      "gatewayCannotBeInlinedMultipleTimes"));
    if (chartIsInlinable) {
      ssSetInputPortOptimOpts(S, 0, SS_REUSABLE_AND_LOCAL);
      ssSetInputPortOptimOpts(S, 1, SS_REUSABLE_AND_LOCAL);
      ssSetInputPortOptimOpts(S, 2, SS_REUSABLE_AND_LOCAL);
      ssSetInputPortOptimOpts(S, 3, SS_REUSABLE_AND_LOCAL);
      ssSetInputPortOptimOpts(S, 4, SS_REUSABLE_AND_LOCAL);
      sf_mark_chart_expressionable_inputs(S,"MPC_gamecontroller_LiDAR2",
        "MPC_gamecontroller_LiDAR2",1,5);
      sf_mark_chart_reusable_outputs(S,"MPC_gamecontroller_LiDAR2",
        "MPC_gamecontroller_LiDAR2",1,1);
    }

    sf_set_rtw_dwork_info(S,"MPC_gamecontroller_LiDAR2",
                          "MPC_gamecontroller_LiDAR2",1);
    ssSetHasSubFunctions(S,!(chartIsInlinable));
  } else {
  }

  ssSetOptions(S,ssGetOptions(S)|SS_OPTION_WORKS_WITH_CODE_REUSE);
  ssSetChecksum0(S,(3030888801U));
  ssSetChecksum1(S,(1367534193U));
  ssSetChecksum2(S,(2627526701U));
  ssSetChecksum3(S,(533223346U));
  ssSetmdlDerivatives(S, NULL);
  ssSetExplicitFCSSCtrl(S,1);
}

static void mdlRTW_c1_MPC_gamecontroller_LiDAR2(SimStruct *S)
{
  if (sim_mode_is_rtw_gen(S)) {
    sf_write_symbol_mapping(S, "MPC_gamecontroller_LiDAR2",
      "MPC_gamecontroller_LiDAR2",1);
    ssWriteRTWStrParam(S, "StateflowChartType", "Embedded MATLAB");
  }
}

static void mdlStart_c1_MPC_gamecontroller_LiDAR2(SimStruct *S)
{
  SFc1_MPC_gamecontroller_LiDAR2InstanceStruct *chartInstance;
  chartInstance = (SFc1_MPC_gamecontroller_LiDAR2InstanceStruct *)malloc(sizeof
    (SFc1_MPC_gamecontroller_LiDAR2InstanceStruct));
  memset(chartInstance, 0, sizeof(SFc1_MPC_gamecontroller_LiDAR2InstanceStruct));
  if (chartInstance==NULL) {
    sf_mex_error_message("Could not allocate memory for chart instance.");
  }

  chartInstance->chartInfo.chartInstance = chartInstance;
  chartInstance->chartInfo.isEMLChart = 1;
  chartInstance->chartInfo.chartInitialized = 0;
  chartInstance->chartInfo.sFunctionGateway =
    sf_opaque_gateway_c1_MPC_gamecontroller_LiDAR2;
  chartInstance->chartInfo.initializeChart =
    sf_opaque_initialize_c1_MPC_gamecontroller_LiDAR2;
  chartInstance->chartInfo.terminateChart =
    sf_opaque_terminate_c1_MPC_gamecontroller_LiDAR2;
  chartInstance->chartInfo.enableChart =
    sf_opaque_enable_c1_MPC_gamecontroller_LiDAR2;
  chartInstance->chartInfo.disableChart =
    sf_opaque_disable_c1_MPC_gamecontroller_LiDAR2;
  chartInstance->chartInfo.getSimState =
    sf_opaque_get_sim_state_c1_MPC_gamecontroller_LiDAR2;
  chartInstance->chartInfo.setSimState =
    sf_opaque_set_sim_state_c1_MPC_gamecontroller_LiDAR2;
  chartInstance->chartInfo.getSimStateInfo =
    sf_get_sim_state_info_c1_MPC_gamecontroller_LiDAR2;
  chartInstance->chartInfo.zeroCrossings = NULL;
  chartInstance->chartInfo.outputs = NULL;
  chartInstance->chartInfo.derivatives = NULL;
  chartInstance->chartInfo.mdlRTW = mdlRTW_c1_MPC_gamecontroller_LiDAR2;
  chartInstance->chartInfo.mdlStart = mdlStart_c1_MPC_gamecontroller_LiDAR2;
  chartInstance->chartInfo.mdlSetWorkWidths =
    mdlSetWorkWidths_c1_MPC_gamecontroller_LiDAR2;
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

void c1_MPC_gamecontroller_LiDAR2_method_dispatcher(SimStruct *S, int_T method,
  void *data)
{
  switch (method) {
   case SS_CALL_MDL_START:
    mdlStart_c1_MPC_gamecontroller_LiDAR2(S);
    break;

   case SS_CALL_MDL_SET_WORK_WIDTHS:
    mdlSetWorkWidths_c1_MPC_gamecontroller_LiDAR2(S);
    break;

   case SS_CALL_MDL_PROCESS_PARAMETERS:
    mdlProcessParameters_c1_MPC_gamecontroller_LiDAR2(S);
    break;

   default:
    /* Unhandled method */
    sf_mex_error_message("Stateflow Internal Error:\n"
                         "Error calling c1_MPC_gamecontroller_LiDAR2_method_dispatcher.\n"
                         "Can't handle method %d.\n", method);
    break;
  }
}
