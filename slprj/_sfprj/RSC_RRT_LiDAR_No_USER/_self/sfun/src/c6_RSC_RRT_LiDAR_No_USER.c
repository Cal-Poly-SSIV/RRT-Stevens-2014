/* Include files */

#include "blascompat32.h"
#include "RSC_RRT_LiDAR_No_USER_sfun.h"
#include "c6_RSC_RRT_LiDAR_No_USER.h"
#define CHARTINSTANCE_CHARTNUMBER      (chartInstance->chartNumber)
#define CHARTINSTANCE_INSTANCENUMBER   (chartInstance->instanceNumber)
#include "RSC_RRT_LiDAR_No_USER_sfun_debug_macros.h"

/* Type Definitions */

/* Named Constants */

/* Variable Declarations */

/* Variable Definitions */
static const char *c6_debug_family_names[6] = { "nargin", "nargout", "steer",
  "kill", "neutral", "out" };

/* Function Declarations */
static void initialize_c6_RSC_RRT_LiDAR_No_USER
  (SFc6_RSC_RRT_LiDAR_No_USERInstanceStruct *chartInstance);
static void initialize_params_c6_RSC_RRT_LiDAR_No_USER
  (SFc6_RSC_RRT_LiDAR_No_USERInstanceStruct *chartInstance);
static void enable_c6_RSC_RRT_LiDAR_No_USER
  (SFc6_RSC_RRT_LiDAR_No_USERInstanceStruct *chartInstance);
static void disable_c6_RSC_RRT_LiDAR_No_USER
  (SFc6_RSC_RRT_LiDAR_No_USERInstanceStruct *chartInstance);
static void c6_update_debugger_state_c6_RSC_RRT_LiDAR_No_USER
  (SFc6_RSC_RRT_LiDAR_No_USERInstanceStruct *chartInstance);
static const mxArray *get_sim_state_c6_RSC_RRT_LiDAR_No_USER
  (SFc6_RSC_RRT_LiDAR_No_USERInstanceStruct *chartInstance);
static void set_sim_state_c6_RSC_RRT_LiDAR_No_USER
  (SFc6_RSC_RRT_LiDAR_No_USERInstanceStruct *chartInstance, const mxArray *c6_st);
static void finalize_c6_RSC_RRT_LiDAR_No_USER
  (SFc6_RSC_RRT_LiDAR_No_USERInstanceStruct *chartInstance);
static void sf_c6_RSC_RRT_LiDAR_No_USER(SFc6_RSC_RRT_LiDAR_No_USERInstanceStruct
  *chartInstance);
static void compInitSubchartSimstructsFcn_c6_RSC_RRT_LiDAR_No_USER
  (SFc6_RSC_RRT_LiDAR_No_USERInstanceStruct *chartInstance);
static void init_script_number_translation(uint32_T c6_machineNumber, uint32_T
  c6_chartNumber);
static const mxArray *c6_sf_marshall(void *chartInstanceVoid, void *c6_u);
static const mxArray *c6_b_sf_marshall(void *chartInstanceVoid, void *c6_u);
static const mxArray *c6_c_sf_marshall(void *chartInstanceVoid, void *c6_u);
static void c6_emlrt_marshallIn(SFc6_RSC_RRT_LiDAR_No_USERInstanceStruct
  *chartInstance, const mxArray *c6_out, const char_T *c6_name, real_T c6_y[3]);
static uint8_T c6_b_emlrt_marshallIn(SFc6_RSC_RRT_LiDAR_No_USERInstanceStruct
  *chartInstance, const mxArray *c6_b_is_active_c6_RSC_RRT_LiDAR_No_USER, const
  char_T *c6_name);
static void init_dsm_address_info(SFc6_RSC_RRT_LiDAR_No_USERInstanceStruct
  *chartInstance);

/* Function Definitions */
static void initialize_c6_RSC_RRT_LiDAR_No_USER
  (SFc6_RSC_RRT_LiDAR_No_USERInstanceStruct *chartInstance)
{
  _sfTime_ = (real_T)ssGetT(chartInstance->S);
  chartInstance->c6_is_active_c6_RSC_RRT_LiDAR_No_USER = 0U;
}

static void initialize_params_c6_RSC_RRT_LiDAR_No_USER
  (SFc6_RSC_RRT_LiDAR_No_USERInstanceStruct *chartInstance)
{
}

static void enable_c6_RSC_RRT_LiDAR_No_USER
  (SFc6_RSC_RRT_LiDAR_No_USERInstanceStruct *chartInstance)
{
  _sfTime_ = (real_T)ssGetT(chartInstance->S);
}

static void disable_c6_RSC_RRT_LiDAR_No_USER
  (SFc6_RSC_RRT_LiDAR_No_USERInstanceStruct *chartInstance)
{
  _sfTime_ = (real_T)ssGetT(chartInstance->S);
}

static void c6_update_debugger_state_c6_RSC_RRT_LiDAR_No_USER
  (SFc6_RSC_RRT_LiDAR_No_USERInstanceStruct *chartInstance)
{
}

static const mxArray *get_sim_state_c6_RSC_RRT_LiDAR_No_USER
  (SFc6_RSC_RRT_LiDAR_No_USERInstanceStruct *chartInstance)
{
  const mxArray *c6_st = NULL;
  const mxArray *c6_y = NULL;
  int32_T c6_i0;
  real_T c6_hoistedGlobal[3];
  int32_T c6_i1;
  real_T c6_u[3];
  const mxArray *c6_b_y = NULL;
  uint8_T c6_b_hoistedGlobal;
  uint8_T c6_b_u;
  const mxArray *c6_c_y = NULL;
  real_T (*c6_out)[3];
  c6_out = (real_T (*)[3])ssGetOutputPortSignal(chartInstance->S, 1);
  c6_st = NULL;
  c6_y = NULL;
  sf_mex_assign(&c6_y, sf_mex_createcellarray(2));
  for (c6_i0 = 0; c6_i0 < 3; c6_i0 = c6_i0 + 1) {
    c6_hoistedGlobal[c6_i0] = (*c6_out)[c6_i0];
  }

  for (c6_i1 = 0; c6_i1 < 3; c6_i1 = c6_i1 + 1) {
    c6_u[c6_i1] = c6_hoistedGlobal[c6_i1];
  }

  c6_b_y = NULL;
  sf_mex_assign(&c6_b_y, sf_mex_create("y", c6_u, 0, 0U, 1U, 0U, 1, 3));
  sf_mex_setcell(c6_y, 0, c6_b_y);
  c6_b_hoistedGlobal = chartInstance->c6_is_active_c6_RSC_RRT_LiDAR_No_USER;
  c6_b_u = c6_b_hoistedGlobal;
  c6_c_y = NULL;
  sf_mex_assign(&c6_c_y, sf_mex_create("y", &c6_b_u, 3, 0U, 0U, 0U, 0));
  sf_mex_setcell(c6_y, 1, c6_c_y);
  sf_mex_assign(&c6_st, c6_y);
  return c6_st;
}

static void set_sim_state_c6_RSC_RRT_LiDAR_No_USER
  (SFc6_RSC_RRT_LiDAR_No_USERInstanceStruct *chartInstance, const mxArray *c6_st)
{
  const mxArray *c6_u;
  real_T c6_dv0[3];
  int32_T c6_i2;
  real_T (*c6_out)[3];
  c6_out = (real_T (*)[3])ssGetOutputPortSignal(chartInstance->S, 1);
  chartInstance->c6_doneDoubleBufferReInit = TRUE;
  c6_u = sf_mex_dup(c6_st);
  c6_emlrt_marshallIn(chartInstance, sf_mex_dup(sf_mex_getcell(c6_u, 0)), "out",
                      c6_dv0);
  for (c6_i2 = 0; c6_i2 < 3; c6_i2 = c6_i2 + 1) {
    (*c6_out)[c6_i2] = c6_dv0[c6_i2];
  }

  chartInstance->c6_is_active_c6_RSC_RRT_LiDAR_No_USER = c6_b_emlrt_marshallIn
    (chartInstance, sf_mex_dup(sf_mex_getcell(c6_u, 1)),
     "is_active_c6_RSC_RRT_LiDAR_No_USER");
  sf_mex_destroy(&c6_u);
  c6_update_debugger_state_c6_RSC_RRT_LiDAR_No_USER(chartInstance);
  sf_mex_destroy(&c6_st);
}

static void finalize_c6_RSC_RRT_LiDAR_No_USER
  (SFc6_RSC_RRT_LiDAR_No_USERInstanceStruct *chartInstance)
{
}

static void sf_c6_RSC_RRT_LiDAR_No_USER(SFc6_RSC_RRT_LiDAR_No_USERInstanceStruct
  *chartInstance)
{
  int32_T c6_i3;
  int32_T c6_i4;
  int32_T c6_i5;
  int32_T c6_previousEvent;
  int32_T c6_i6;
  real_T c6_hoistedGlobal[3];
  real_T c6_b_hoistedGlobal;
  int32_T c6_i7;
  real_T c6_c_hoistedGlobal[3];
  int32_T c6_i8;
  real_T c6_steer[3];
  real_T c6_kill;
  int32_T c6_i9;
  real_T c6_neutral[3];
  uint32_T c6_debug_family_var_map[6];
  real_T c6_nargin = 3.0;
  real_T c6_nargout = 1.0;
  real_T c6_out[3];
  int32_T c6_i10;
  int32_T c6_i11;
  int32_T c6_i12;
  real_T *c6_b_kill;
  real_T (*c6_b_out)[3];
  real_T (*c6_b_neutral)[3];
  real_T (*c6_b_steer)[3];
  c6_b_neutral = (real_T (*)[3])ssGetInputPortSignal(chartInstance->S, 2);
  c6_b_out = (real_T (*)[3])ssGetOutputPortSignal(chartInstance->S, 1);
  c6_b_kill = (real_T *)ssGetInputPortSignal(chartInstance->S, 1);
  c6_b_steer = (real_T (*)[3])ssGetInputPortSignal(chartInstance->S, 0);
  _sfTime_ = (real_T)ssGetT(chartInstance->S);
  _SFD_CC_CALL(CHART_ENTER_SFUNCTION_TAG, 1);
  for (c6_i3 = 0; c6_i3 < 3; c6_i3 = c6_i3 + 1) {
    _SFD_DATA_RANGE_CHECK((*c6_b_steer)[c6_i3], 0U);
  }

  _SFD_DATA_RANGE_CHECK(*c6_b_kill, 1U);
  for (c6_i4 = 0; c6_i4 < 3; c6_i4 = c6_i4 + 1) {
    _SFD_DATA_RANGE_CHECK((*c6_b_out)[c6_i4], 2U);
  }

  for (c6_i5 = 0; c6_i5 < 3; c6_i5 = c6_i5 + 1) {
    _SFD_DATA_RANGE_CHECK((*c6_b_neutral)[c6_i5], 3U);
  }

  c6_previousEvent = _sfEvent_;
  _sfEvent_ = CALL_EVENT;
  _SFD_CC_CALL(CHART_ENTER_DURING_FUNCTION_TAG, 1);
  for (c6_i6 = 0; c6_i6 < 3; c6_i6 = c6_i6 + 1) {
    c6_hoistedGlobal[c6_i6] = (*c6_b_steer)[c6_i6];
  }

  c6_b_hoistedGlobal = *c6_b_kill;
  for (c6_i7 = 0; c6_i7 < 3; c6_i7 = c6_i7 + 1) {
    c6_c_hoistedGlobal[c6_i7] = (*c6_b_neutral)[c6_i7];
  }

  for (c6_i8 = 0; c6_i8 < 3; c6_i8 = c6_i8 + 1) {
    c6_steer[c6_i8] = c6_hoistedGlobal[c6_i8];
  }

  c6_kill = c6_b_hoistedGlobal;
  for (c6_i9 = 0; c6_i9 < 3; c6_i9 = c6_i9 + 1) {
    c6_neutral[c6_i9] = c6_c_hoistedGlobal[c6_i9];
  }

  sf_debug_symbol_scope_push_eml(0U, 6U, 6U, c6_debug_family_names,
    c6_debug_family_var_map);
  sf_debug_symbol_scope_add_eml(&c6_nargin, c6_b_sf_marshall, 0U);
  sf_debug_symbol_scope_add_eml(&c6_nargout, c6_b_sf_marshall, 1U);
  sf_debug_symbol_scope_add_eml(c6_steer, c6_sf_marshall, 2U);
  sf_debug_symbol_scope_add_eml(&c6_kill, c6_b_sf_marshall, 3U);
  sf_debug_symbol_scope_add_eml(c6_neutral, c6_sf_marshall, 4U);
  sf_debug_symbol_scope_add_eml(c6_out, c6_sf_marshall, 5U);
  CV_EML_FCN(0, 0);
  _SFD_EML_CALL(0, 4);
  if (CV_EML_IF(0, 0, c6_kill != 0.0) != 0.0) {
    _SFD_EML_CALL(0, 5);
    for (c6_i10 = 0; c6_i10 < 3; c6_i10 = c6_i10 + 1) {
      c6_out[c6_i10] = c6_neutral[c6_i10];
    }
  } else {
    _SFD_EML_CALL(0, 7);
    for (c6_i11 = 0; c6_i11 < 3; c6_i11 = c6_i11 + 1) {
      c6_out[c6_i11] = c6_steer[c6_i11];
    }
  }

  /* end */
  _SFD_EML_CALL(0, -7);
  sf_debug_symbol_scope_pop();
  for (c6_i12 = 0; c6_i12 < 3; c6_i12 = c6_i12 + 1) {
    (*c6_b_out)[c6_i12] = c6_out[c6_i12];
  }

  _SFD_CC_CALL(EXIT_OUT_OF_FUNCTION_TAG, 1);
  _sfEvent_ = c6_previousEvent;
  sf_debug_check_for_state_inconsistency(_RSC_RRT_LiDAR_No_USERMachineNumber_,
    chartInstance->chartNumber, chartInstance->
    instanceNumber);
}

static void compInitSubchartSimstructsFcn_c6_RSC_RRT_LiDAR_No_USER
  (SFc6_RSC_RRT_LiDAR_No_USERInstanceStruct *chartInstance)
{
}

static void init_script_number_translation(uint32_T c6_machineNumber, uint32_T
  c6_chartNumber)
{
}

static const mxArray *c6_sf_marshall(void *chartInstanceVoid, void *c6_u)
{
  const mxArray *c6_y = NULL;
  int32_T c6_i13;
  real_T c6_b_u[3];
  int32_T c6_i14;
  real_T c6_c_u[3];
  const mxArray *c6_b_y = NULL;
  SFc6_RSC_RRT_LiDAR_No_USERInstanceStruct *chartInstance;
  chartInstance = (SFc6_RSC_RRT_LiDAR_No_USERInstanceStruct *)chartInstanceVoid;
  c6_y = NULL;
  for (c6_i13 = 0; c6_i13 < 3; c6_i13 = c6_i13 + 1) {
    c6_b_u[c6_i13] = (*((real_T (*)[3])c6_u))[c6_i13];
  }

  for (c6_i14 = 0; c6_i14 < 3; c6_i14 = c6_i14 + 1) {
    c6_c_u[c6_i14] = c6_b_u[c6_i14];
  }

  c6_b_y = NULL;
  sf_mex_assign(&c6_b_y, sf_mex_create("y", c6_c_u, 0, 0U, 1U, 0U, 1, 3));
  sf_mex_assign(&c6_y, c6_b_y);
  return c6_y;
}

static const mxArray *c6_b_sf_marshall(void *chartInstanceVoid, void *c6_u)
{
  const mxArray *c6_y = NULL;
  real_T c6_b_u;
  const mxArray *c6_b_y = NULL;
  SFc6_RSC_RRT_LiDAR_No_USERInstanceStruct *chartInstance;
  chartInstance = (SFc6_RSC_RRT_LiDAR_No_USERInstanceStruct *)chartInstanceVoid;
  c6_y = NULL;
  c6_b_u = *((real_T *)c6_u);
  c6_b_y = NULL;
  sf_mex_assign(&c6_b_y, sf_mex_create("y", &c6_b_u, 0, 0U, 0U, 0U, 0));
  sf_mex_assign(&c6_y, c6_b_y);
  return c6_y;
}

const mxArray *sf_c6_RSC_RRT_LiDAR_No_USER_get_eml_resolved_functions_info(void)
{
  const mxArray *c6_nameCaptureInfo = NULL;
  c6_nameCaptureInfo = NULL;
  sf_mex_assign(&c6_nameCaptureInfo, sf_mex_create("nameCaptureInfo", NULL, 0,
    0U, 1U, 0U, 2, 0, 1));
  return c6_nameCaptureInfo;
}

static const mxArray *c6_c_sf_marshall(void *chartInstanceVoid, void *c6_u)
{
  const mxArray *c6_y = NULL;
  boolean_T c6_b_u;
  const mxArray *c6_b_y = NULL;
  SFc6_RSC_RRT_LiDAR_No_USERInstanceStruct *chartInstance;
  chartInstance = (SFc6_RSC_RRT_LiDAR_No_USERInstanceStruct *)chartInstanceVoid;
  c6_y = NULL;
  c6_b_u = *((boolean_T *)c6_u);
  c6_b_y = NULL;
  sf_mex_assign(&c6_b_y, sf_mex_create("y", &c6_b_u, 11, 0U, 0U, 0U, 0));
  sf_mex_assign(&c6_y, c6_b_y);
  return c6_y;
}

static void c6_emlrt_marshallIn(SFc6_RSC_RRT_LiDAR_No_USERInstanceStruct
  *chartInstance, const mxArray *c6_out, const char_T *
  c6_name, real_T c6_y[3])
{
  real_T c6_dv1[3];
  int32_T c6_i15;
  sf_mex_import(c6_name, sf_mex_dup(c6_out), c6_dv1, 1, 0, 0U, 1, 0U, 1, 3);
  for (c6_i15 = 0; c6_i15 < 3; c6_i15 = c6_i15 + 1) {
    c6_y[c6_i15] = c6_dv1[c6_i15];
  }

  sf_mex_destroy(&c6_out);
}

static uint8_T c6_b_emlrt_marshallIn(SFc6_RSC_RRT_LiDAR_No_USERInstanceStruct
  *chartInstance, const mxArray *
  c6_b_is_active_c6_RSC_RRT_LiDAR_No_USER, const char_T *c6_name)
{
  uint8_T c6_y;
  uint8_T c6_u0;
  sf_mex_import(c6_name, sf_mex_dup(c6_b_is_active_c6_RSC_RRT_LiDAR_No_USER),
                &c6_u0, 1, 3, 0U, 0, 0U, 0);
  c6_y = c6_u0;
  sf_mex_destroy(&c6_b_is_active_c6_RSC_RRT_LiDAR_No_USER);
  return c6_y;
}

static void init_dsm_address_info(SFc6_RSC_RRT_LiDAR_No_USERInstanceStruct
  *chartInstance)
{
}

/* SFunction Glue Code */
void sf_c6_RSC_RRT_LiDAR_No_USER_get_check_sum(mxArray *plhs[])
{
  ((real_T *)mxGetPr((plhs[0])))[0] = (real_T)(772418397U);
  ((real_T *)mxGetPr((plhs[0])))[1] = (real_T)(1681252635U);
  ((real_T *)mxGetPr((plhs[0])))[2] = (real_T)(2348487989U);
  ((real_T *)mxGetPr((plhs[0])))[3] = (real_T)(1885832167U);
}

mxArray *sf_c6_RSC_RRT_LiDAR_No_USER_get_autoinheritance_info(void)
{
  const char *autoinheritanceFields[] = { "checksum", "inputs", "parameters",
    "outputs" };

  mxArray *mxAutoinheritanceInfo = mxCreateStructMatrix(1,1,4,
    autoinheritanceFields);

  {
    mxArray *mxChecksum = mxCreateDoubleMatrix(4,1,mxREAL);
    double *pr = mxGetPr(mxChecksum);
    pr[0] = (double)(1548368385U);
    pr[1] = (double)(3903179142U);
    pr[2] = (double)(2073152806U);
    pr[3] = (double)(757545159U);
    mxSetField(mxAutoinheritanceInfo,0,"checksum",mxChecksum);
  }

  {
    const char *dataFields[] = { "size", "type", "complexity" };

    mxArray *mxData = mxCreateStructMatrix(1,3,3,dataFields);

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

static mxArray *sf_get_sim_state_info_c6_RSC_RRT_LiDAR_No_USER(void)
{
  const char *infoFields[] = { "chartChecksum", "varInfo" };

  mxArray *mxInfo = mxCreateStructMatrix(1, 1, 2, infoFields);
  const char *infoEncStr[] = {
    "100 S1x2'type','srcId','name','auxInfo'{{M[1],M[5],T\"out\",},{M[8],M[0],T\"is_active_c6_RSC_RRT_LiDAR_No_USER\",}}"
  };

  mxArray *mxVarInfo = sf_mex_decode_encoded_mx_struct_array(infoEncStr, 2, 10);
  mxArray *mxChecksum = mxCreateDoubleMatrix(1, 4, mxREAL);
  sf_c6_RSC_RRT_LiDAR_No_USER_get_check_sum(&mxChecksum);
  mxSetField(mxInfo, 0, infoFields[0], mxChecksum);
  mxSetField(mxInfo, 0, infoFields[1], mxVarInfo);
  return mxInfo;
}

static void chart_debug_initialization(SimStruct *S, unsigned int
  fullDebuggerInitialization)
{
  if (!sim_mode_is_rtw_gen(S)) {
    SFc6_RSC_RRT_LiDAR_No_USERInstanceStruct *chartInstance;
    chartInstance = (SFc6_RSC_RRT_LiDAR_No_USERInstanceStruct *)
      ((ChartInfoStruct *)(ssGetUserData(S)))->chartInstance;
    if (ssIsFirstInitCond(S) && fullDebuggerInitialization==1) {
      /* do this only if simulation is starting */
      {
        unsigned int chartAlreadyPresent;
        chartAlreadyPresent = sf_debug_initialize_chart
          (_RSC_RRT_LiDAR_No_USERMachineNumber_,
           6,
           1,
           1,
           4,
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
          init_script_number_translation(_RSC_RRT_LiDAR_No_USERMachineNumber_,
            chartInstance->chartNumber);
          sf_debug_set_chart_disable_implicit_casting
            (_RSC_RRT_LiDAR_No_USERMachineNumber_,chartInstance->chartNumber,1);
          sf_debug_set_chart_event_thresholds
            (_RSC_RRT_LiDAR_No_USERMachineNumber_,
             chartInstance->chartNumber,
             0,
             0,
             0);
          _SFD_SET_DATA_PROPS(0,1,1,0,"steer");
          _SFD_SET_DATA_PROPS(1,1,1,0,"kill");
          _SFD_SET_DATA_PROPS(2,2,0,1,"out");
          _SFD_SET_DATA_PROPS(3,1,1,0,"neutral");
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
        _SFD_CV_INIT_EML_FCN(0,0,"eML_blk_kernel",0,-1,101);
        _SFD_CV_INIT_EML_IF(0,0,46,54,74,99);
        _SFD_TRANS_COV_WTS(0,0,0,1,0);
        if (chartAlreadyPresent==0) {
          _SFD_TRANS_COV_MAPS(0,
                              0,NULL,NULL,
                              0,NULL,NULL,
                              1,NULL,NULL,
                              0,NULL,NULL);
        }

        {
          unsigned int dimVector[1];
          dimVector[0]= 3;
          _SFD_SET_DATA_COMPILED_PROPS(0,SF_DOUBLE,1,&(dimVector[0]),0,0,0,0.0,
            1.0,0,0,(MexFcnForType)c6_sf_marshall);
        }

        _SFD_SET_DATA_COMPILED_PROPS(1,SF_DOUBLE,0,NULL,0,0,0,0.0,1.0,0,0,
          (MexFcnForType)c6_b_sf_marshall);

        {
          unsigned int dimVector[1];
          dimVector[0]= 3;
          _SFD_SET_DATA_COMPILED_PROPS(2,SF_DOUBLE,1,&(dimVector[0]),0,0,0,0.0,
            1.0,0,0,(MexFcnForType)c6_sf_marshall);
        }

        {
          unsigned int dimVector[1];
          dimVector[0]= 3;
          _SFD_SET_DATA_COMPILED_PROPS(3,SF_DOUBLE,1,&(dimVector[0]),0,0,0,0.0,
            1.0,0,0,(MexFcnForType)c6_sf_marshall);
        }

        {
          real_T *c6_kill;
          real_T (*c6_steer)[3];
          real_T (*c6_out)[3];
          real_T (*c6_neutral)[3];
          c6_neutral = (real_T (*)[3])ssGetInputPortSignal(chartInstance->S, 2);
          c6_out = (real_T (*)[3])ssGetOutputPortSignal(chartInstance->S, 1);
          c6_kill = (real_T *)ssGetInputPortSignal(chartInstance->S, 1);
          c6_steer = (real_T (*)[3])ssGetInputPortSignal(chartInstance->S, 0);
          _SFD_SET_DATA_VALUE_PTR(0U, *c6_steer);
          _SFD_SET_DATA_VALUE_PTR(1U, c6_kill);
          _SFD_SET_DATA_VALUE_PTR(2U, *c6_out);
          _SFD_SET_DATA_VALUE_PTR(3U, *c6_neutral);
        }
      }
    } else {
      sf_debug_reset_current_state_configuration
        (_RSC_RRT_LiDAR_No_USERMachineNumber_,chartInstance->chartNumber,
         chartInstance->instanceNumber);
    }
  }
}

static void sf_opaque_initialize_c6_RSC_RRT_LiDAR_No_USER(void *chartInstanceVar)
{
  chart_debug_initialization(((SFc6_RSC_RRT_LiDAR_No_USERInstanceStruct*)
    chartInstanceVar)->S,0);
  initialize_params_c6_RSC_RRT_LiDAR_No_USER
    ((SFc6_RSC_RRT_LiDAR_No_USERInstanceStruct*) chartInstanceVar);
  initialize_c6_RSC_RRT_LiDAR_No_USER((SFc6_RSC_RRT_LiDAR_No_USERInstanceStruct*)
    chartInstanceVar);
}

static void sf_opaque_enable_c6_RSC_RRT_LiDAR_No_USER(void *chartInstanceVar)
{
  enable_c6_RSC_RRT_LiDAR_No_USER((SFc6_RSC_RRT_LiDAR_No_USERInstanceStruct*)
    chartInstanceVar);
}

static void sf_opaque_disable_c6_RSC_RRT_LiDAR_No_USER(void *chartInstanceVar)
{
  disable_c6_RSC_RRT_LiDAR_No_USER((SFc6_RSC_RRT_LiDAR_No_USERInstanceStruct*)
    chartInstanceVar);
}

static void sf_opaque_gateway_c6_RSC_RRT_LiDAR_No_USER(void *chartInstanceVar)
{
  sf_c6_RSC_RRT_LiDAR_No_USER((SFc6_RSC_RRT_LiDAR_No_USERInstanceStruct*)
    chartInstanceVar);
}

static mxArray* sf_internal_get_sim_state_c6_RSC_RRT_LiDAR_No_USER(SimStruct* S)
{
  ChartInfoStruct *chartInfo = (ChartInfoStruct*) ssGetUserData(S);
  mxArray *plhs[1] = { NULL };

  mxArray *prhs[4];
  int mxError = 0;
  prhs[0] = mxCreateString("chart_simctx_raw2high");
  prhs[1] = mxCreateDoubleScalar(ssGetSFuncBlockHandle(S));
  prhs[2] = (mxArray*) get_sim_state_c6_RSC_RRT_LiDAR_No_USER
    ((SFc6_RSC_RRT_LiDAR_No_USERInstanceStruct*)chartInfo->chartInstance);/* raw sim ctx */
  prhs[3] = sf_get_sim_state_info_c6_RSC_RRT_LiDAR_No_USER();/* state var info */
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

static void sf_internal_set_sim_state_c6_RSC_RRT_LiDAR_No_USER(SimStruct* S,
  const mxArray *st)
{
  ChartInfoStruct *chartInfo = (ChartInfoStruct*) ssGetUserData(S);
  mxArray *plhs[1] = { NULL };

  mxArray *prhs[4];
  int mxError = 0;
  prhs[0] = mxCreateString("chart_simctx_high2raw");
  prhs[1] = mxCreateDoubleScalar(ssGetSFuncBlockHandle(S));
  prhs[2] = mxDuplicateArray(st);      /* high level simctx */
  prhs[3] = (mxArray*) sf_get_sim_state_info_c6_RSC_RRT_LiDAR_No_USER();/* state var info */
  mxError = sf_mex_call_matlab(1, plhs, 4, prhs, "sfprivate");
  mxDestroyArray(prhs[0]);
  mxDestroyArray(prhs[1]);
  mxDestroyArray(prhs[2]);
  mxDestroyArray(prhs[3]);
  if (mxError || plhs[0] == NULL) {
    sf_mex_error_message("Stateflow Internal Error: \nError calling 'chart_simctx_high2raw'.\n");
  }

  set_sim_state_c6_RSC_RRT_LiDAR_No_USER
    ((SFc6_RSC_RRT_LiDAR_No_USERInstanceStruct*)chartInfo->chartInstance,
     mxDuplicateArray(plhs[0]));
  mxDestroyArray(plhs[0]);
}

static mxArray* sf_opaque_get_sim_state_c6_RSC_RRT_LiDAR_No_USER(SimStruct* S)
{
  return sf_internal_get_sim_state_c6_RSC_RRT_LiDAR_No_USER(S);
}

static void sf_opaque_set_sim_state_c6_RSC_RRT_LiDAR_No_USER(SimStruct* S, const
  mxArray *st)
{
  sf_internal_set_sim_state_c6_RSC_RRT_LiDAR_No_USER(S, st);
}

static void sf_opaque_terminate_c6_RSC_RRT_LiDAR_No_USER(void *chartInstanceVar)
{
  if (chartInstanceVar!=NULL) {
    SimStruct *S = ((SFc6_RSC_RRT_LiDAR_No_USERInstanceStruct*) chartInstanceVar)
      ->S;
    if (sim_mode_is_rtw_gen(S) || sim_mode_is_external(S)) {
      sf_clear_rtw_identifier(S);
    }

    finalize_c6_RSC_RRT_LiDAR_No_USER((SFc6_RSC_RRT_LiDAR_No_USERInstanceStruct*)
      chartInstanceVar);
    free((void *)chartInstanceVar);
    ssSetUserData(S,NULL);
  }
}

static void sf_opaque_init_subchart_simstructs(void *chartInstanceVar)
{
  compInitSubchartSimstructsFcn_c6_RSC_RRT_LiDAR_No_USER
    ((SFc6_RSC_RRT_LiDAR_No_USERInstanceStruct*) chartInstanceVar);
}

extern unsigned int sf_machine_global_initializer_called(void);
static void mdlProcessParameters_c6_RSC_RRT_LiDAR_No_USER(SimStruct *S)
{
  int i;
  for (i=0;i<ssGetNumRunTimeParams(S);i++) {
    if (ssGetSFcnParamTunable(S,i)) {
      ssUpdateDlgParamAsRunTimeParam(S,i);
    }
  }

  if (sf_machine_global_initializer_called()) {
    initialize_params_c6_RSC_RRT_LiDAR_No_USER
      ((SFc6_RSC_RRT_LiDAR_No_USERInstanceStruct*)(((ChartInfoStruct *)
         ssGetUserData(S))->chartInstance));
  }
}

static void mdlSetWorkWidths_c6_RSC_RRT_LiDAR_No_USER(SimStruct *S)
{
  if (sim_mode_is_rtw_gen(S) || sim_mode_is_external(S)) {
    int_T chartIsInlinable =
      (int_T)sf_is_chart_inlinable(S,"RSC_RRT_LiDAR_No_USER",
      "RSC_RRT_LiDAR_No_USER",6);
    ssSetStateflowIsInlinable(S,chartIsInlinable);
    ssSetRTWCG(S,sf_rtw_info_uint_prop(S,"RSC_RRT_LiDAR_No_USER",
                "RSC_RRT_LiDAR_No_USER",6,"RTWCG"));
    ssSetEnableFcnIsTrivial(S,1);
    ssSetDisableFcnIsTrivial(S,1);
    ssSetNotMultipleInlinable(S,sf_rtw_info_uint_prop(S,"RSC_RRT_LiDAR_No_USER",
      "RSC_RRT_LiDAR_No_USER",6,"gatewayCannotBeInlinedMultipleTimes"));
    if (chartIsInlinable) {
      ssSetInputPortOptimOpts(S, 0, SS_REUSABLE_AND_LOCAL);
      ssSetInputPortOptimOpts(S, 1, SS_REUSABLE_AND_LOCAL);
      ssSetInputPortOptimOpts(S, 2, SS_REUSABLE_AND_LOCAL);
      sf_mark_chart_expressionable_inputs(S,"RSC_RRT_LiDAR_No_USER",
        "RSC_RRT_LiDAR_No_USER",6,3);
      sf_mark_chart_reusable_outputs(S,"RSC_RRT_LiDAR_No_USER",
        "RSC_RRT_LiDAR_No_USER",6,1);
    }

    sf_set_rtw_dwork_info(S,"RSC_RRT_LiDAR_No_USER","RSC_RRT_LiDAR_No_USER",6);
    ssSetHasSubFunctions(S,!(chartIsInlinable));
  } else {
  }

  ssSetOptions(S,ssGetOptions(S)|SS_OPTION_WORKS_WITH_CODE_REUSE);
  ssSetChecksum0(S,(2972566816U));
  ssSetChecksum1(S,(2916766193U));
  ssSetChecksum2(S,(1940576328U));
  ssSetChecksum3(S,(673906248U));
  ssSetmdlDerivatives(S, NULL);
  ssSetExplicitFCSSCtrl(S,1);
}

static void mdlRTW_c6_RSC_RRT_LiDAR_No_USER(SimStruct *S)
{
  if (sim_mode_is_rtw_gen(S)) {
    sf_write_symbol_mapping(S, "RSC_RRT_LiDAR_No_USER", "RSC_RRT_LiDAR_No_USER",
      6);
    ssWriteRTWStrParam(S, "StateflowChartType", "Embedded MATLAB");
  }
}

static void mdlStart_c6_RSC_RRT_LiDAR_No_USER(SimStruct *S)
{
  SFc6_RSC_RRT_LiDAR_No_USERInstanceStruct *chartInstance;
  chartInstance = (SFc6_RSC_RRT_LiDAR_No_USERInstanceStruct *)malloc(sizeof
    (SFc6_RSC_RRT_LiDAR_No_USERInstanceStruct));
  memset(chartInstance, 0, sizeof(SFc6_RSC_RRT_LiDAR_No_USERInstanceStruct));
  if (chartInstance==NULL) {
    sf_mex_error_message("Could not allocate memory for chart instance.");
  }

  chartInstance->chartInfo.chartInstance = chartInstance;
  chartInstance->chartInfo.isEMLChart = 1;
  chartInstance->chartInfo.chartInitialized = 0;
  chartInstance->chartInfo.sFunctionGateway =
    sf_opaque_gateway_c6_RSC_RRT_LiDAR_No_USER;
  chartInstance->chartInfo.initializeChart =
    sf_opaque_initialize_c6_RSC_RRT_LiDAR_No_USER;
  chartInstance->chartInfo.terminateChart =
    sf_opaque_terminate_c6_RSC_RRT_LiDAR_No_USER;
  chartInstance->chartInfo.enableChart =
    sf_opaque_enable_c6_RSC_RRT_LiDAR_No_USER;
  chartInstance->chartInfo.disableChart =
    sf_opaque_disable_c6_RSC_RRT_LiDAR_No_USER;
  chartInstance->chartInfo.getSimState =
    sf_opaque_get_sim_state_c6_RSC_RRT_LiDAR_No_USER;
  chartInstance->chartInfo.setSimState =
    sf_opaque_set_sim_state_c6_RSC_RRT_LiDAR_No_USER;
  chartInstance->chartInfo.getSimStateInfo =
    sf_get_sim_state_info_c6_RSC_RRT_LiDAR_No_USER;
  chartInstance->chartInfo.zeroCrossings = NULL;
  chartInstance->chartInfo.outputs = NULL;
  chartInstance->chartInfo.derivatives = NULL;
  chartInstance->chartInfo.mdlRTW = mdlRTW_c6_RSC_RRT_LiDAR_No_USER;
  chartInstance->chartInfo.mdlStart = mdlStart_c6_RSC_RRT_LiDAR_No_USER;
  chartInstance->chartInfo.mdlSetWorkWidths =
    mdlSetWorkWidths_c6_RSC_RRT_LiDAR_No_USER;
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

void c6_RSC_RRT_LiDAR_No_USER_method_dispatcher(SimStruct *S, int_T method, void
  *data)
{
  switch (method) {
   case SS_CALL_MDL_START:
    mdlStart_c6_RSC_RRT_LiDAR_No_USER(S);
    break;

   case SS_CALL_MDL_SET_WORK_WIDTHS:
    mdlSetWorkWidths_c6_RSC_RRT_LiDAR_No_USER(S);
    break;

   case SS_CALL_MDL_PROCESS_PARAMETERS:
    mdlProcessParameters_c6_RSC_RRT_LiDAR_No_USER(S);
    break;

   default:
    /* Unhandled method */
    sf_mex_error_message("Stateflow Internal Error:\n"
                         "Error calling c6_RSC_RRT_LiDAR_No_USER_method_dispatcher.\n"
                         "Can't handle method %d.\n", method);
    break;
  }
}
