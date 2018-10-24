/* Include files */

#include "blascompat32.h"
#include "MPC_gamecontroller_LiDAR2_sfun.h"
#include "c2_MPC_gamecontroller_LiDAR2.h"
#define CHARTINSTANCE_CHARTNUMBER      (chartInstance->chartNumber)
#define CHARTINSTANCE_INSTANCENUMBER   (chartInstance->instanceNumber)
#include "MPC_gamecontroller_LiDAR2_sfun_debug_macros.h"

/* Type Definitions */

/* Named Constants */

/* Variable Declarations */

/* Variable Definitions */
static const char *c2_debug_family_names[14] = { "velocity", "Phi_d", "Phi",
  "Psi_d", "Psi", "Vy", "Vx", "nargin", "nargout", "roll", "wheel_speeds", "yaw",
  "RRT_state", "MPC_state" };

/* Function Declarations */
static void initialize_c2_MPC_gamecontroller_LiDAR2
  (SFc2_MPC_gamecontroller_LiDAR2InstanceStruct *chartInstance);
static void initialize_params_c2_MPC_gamecontroller_LiDAR2
  (SFc2_MPC_gamecontroller_LiDAR2InstanceStruct *chartInstance);
static void enable_c2_MPC_gamecontroller_LiDAR2
  (SFc2_MPC_gamecontroller_LiDAR2InstanceStruct *chartInstance);
static void disable_c2_MPC_gamecontroller_LiDAR2
  (SFc2_MPC_gamecontroller_LiDAR2InstanceStruct *chartInstance);
static void c2_update_debugger_state_c2_MPC_gamecontroller_LiDAR2
  (SFc2_MPC_gamecontroller_LiDAR2InstanceStruct *chartInstance);
static const mxArray *get_sim_state_c2_MPC_gamecontroller_LiDAR2
  (SFc2_MPC_gamecontroller_LiDAR2InstanceStruct *chartInstance);
static void set_sim_state_c2_MPC_gamecontroller_LiDAR2
  (SFc2_MPC_gamecontroller_LiDAR2InstanceStruct *chartInstance, const mxArray
   *c2_st);
static void finalize_c2_MPC_gamecontroller_LiDAR2
  (SFc2_MPC_gamecontroller_LiDAR2InstanceStruct *chartInstance);
static void sf_c2_MPC_gamecontroller_LiDAR2
  (SFc2_MPC_gamecontroller_LiDAR2InstanceStruct *chartInstance);
static void compInitSubchartSimstructsFcn_c2_MPC_gamecontroller_LiDAR2
  (SFc2_MPC_gamecontroller_LiDAR2InstanceStruct *chartInstance);
static void init_script_number_translation(uint32_T c2_machineNumber, uint32_T
  c2_chartNumber);
static const mxArray *c2_sf_marshall(void *chartInstanceVoid, void *c2_u);
static const mxArray *c2_b_sf_marshall(void *chartInstanceVoid, void *c2_u);
static const mxArray *c2_c_sf_marshall(void *chartInstanceVoid, void *c2_u);
static const mxArray *c2_d_sf_marshall(void *chartInstanceVoid, void *c2_u);
static void c2_info_helper(c2_ResolvedFunctionInfo c2_info[18]);
static const mxArray *c2_e_sf_marshall(void *chartInstanceVoid, void *c2_u);
static void c2_emlrt_marshallIn(SFc2_MPC_gamecontroller_LiDAR2InstanceStruct
  *chartInstance, const mxArray *c2_MPC_state, const char_T *c2_name, real_T
  c2_y[6]);
static void c2_b_emlrt_marshallIn(SFc2_MPC_gamecontroller_LiDAR2InstanceStruct
  *chartInstance, const mxArray *c2_RRT_state, const char_T *c2_name, real_T
  c2_y[4]);
static uint8_T c2_c_emlrt_marshallIn
  (SFc2_MPC_gamecontroller_LiDAR2InstanceStruct *chartInstance, const mxArray
   *c2_b_is_active_c2_MPC_gamecontroller_LiDAR2, const char_T *c2_name);
static void init_dsm_address_info(SFc2_MPC_gamecontroller_LiDAR2InstanceStruct
  *chartInstance);

/* Function Definitions */
static void initialize_c2_MPC_gamecontroller_LiDAR2
  (SFc2_MPC_gamecontroller_LiDAR2InstanceStruct *chartInstance)
{
  _sfTime_ = (real_T)ssGetT(chartInstance->S);
  chartInstance->c2_is_active_c2_MPC_gamecontroller_LiDAR2 = 0U;
}

static void initialize_params_c2_MPC_gamecontroller_LiDAR2
  (SFc2_MPC_gamecontroller_LiDAR2InstanceStruct *chartInstance)
{
}

static void enable_c2_MPC_gamecontroller_LiDAR2
  (SFc2_MPC_gamecontroller_LiDAR2InstanceStruct *chartInstance)
{
  _sfTime_ = (real_T)ssGetT(chartInstance->S);
}

static void disable_c2_MPC_gamecontroller_LiDAR2
  (SFc2_MPC_gamecontroller_LiDAR2InstanceStruct *chartInstance)
{
  _sfTime_ = (real_T)ssGetT(chartInstance->S);
}

static void c2_update_debugger_state_c2_MPC_gamecontroller_LiDAR2
  (SFc2_MPC_gamecontroller_LiDAR2InstanceStruct *chartInstance)
{
}

static const mxArray *get_sim_state_c2_MPC_gamecontroller_LiDAR2
  (SFc2_MPC_gamecontroller_LiDAR2InstanceStruct *chartInstance)
{
  const mxArray *c2_st = NULL;
  const mxArray *c2_y = NULL;
  int32_T c2_i0;
  real_T c2_hoistedGlobal[6];
  int32_T c2_i1;
  real_T c2_u[6];
  const mxArray *c2_b_y = NULL;
  int32_T c2_i2;
  real_T c2_b_hoistedGlobal[4];
  int32_T c2_i3;
  real_T c2_b_u[4];
  const mxArray *c2_c_y = NULL;
  uint8_T c2_c_hoistedGlobal;
  uint8_T c2_c_u;
  const mxArray *c2_d_y = NULL;
  real_T (*c2_RRT_state)[4];
  real_T (*c2_MPC_state)[6];
  c2_MPC_state = (real_T (*)[6])ssGetOutputPortSignal(chartInstance->S, 2);
  c2_RRT_state = (real_T (*)[4])ssGetOutputPortSignal(chartInstance->S, 1);
  c2_st = NULL;
  c2_y = NULL;
  sf_mex_assign(&c2_y, sf_mex_createcellarray(3));
  for (c2_i0 = 0; c2_i0 < 6; c2_i0 = c2_i0 + 1) {
    c2_hoistedGlobal[c2_i0] = (*c2_MPC_state)[c2_i0];
  }

  for (c2_i1 = 0; c2_i1 < 6; c2_i1 = c2_i1 + 1) {
    c2_u[c2_i1] = c2_hoistedGlobal[c2_i1];
  }

  c2_b_y = NULL;
  sf_mex_assign(&c2_b_y, sf_mex_create("y", c2_u, 0, 0U, 1U, 0U, 1, 6));
  sf_mex_setcell(c2_y, 0, c2_b_y);
  for (c2_i2 = 0; c2_i2 < 4; c2_i2 = c2_i2 + 1) {
    c2_b_hoistedGlobal[c2_i2] = (*c2_RRT_state)[c2_i2];
  }

  for (c2_i3 = 0; c2_i3 < 4; c2_i3 = c2_i3 + 1) {
    c2_b_u[c2_i3] = c2_b_hoistedGlobal[c2_i3];
  }

  c2_c_y = NULL;
  sf_mex_assign(&c2_c_y, sf_mex_create("y", c2_b_u, 0, 0U, 1U, 0U, 1, 4));
  sf_mex_setcell(c2_y, 1, c2_c_y);
  c2_c_hoistedGlobal = chartInstance->c2_is_active_c2_MPC_gamecontroller_LiDAR2;
  c2_c_u = c2_c_hoistedGlobal;
  c2_d_y = NULL;
  sf_mex_assign(&c2_d_y, sf_mex_create("y", &c2_c_u, 3, 0U, 0U, 0U, 0));
  sf_mex_setcell(c2_y, 2, c2_d_y);
  sf_mex_assign(&c2_st, c2_y);
  return c2_st;
}

static void set_sim_state_c2_MPC_gamecontroller_LiDAR2
  (SFc2_MPC_gamecontroller_LiDAR2InstanceStruct *chartInstance, const mxArray *
   c2_st)
{
  const mxArray *c2_u;
  real_T c2_dv0[6];
  int32_T c2_i4;
  real_T c2_dv1[4];
  int32_T c2_i5;
  real_T (*c2_MPC_state)[6];
  real_T (*c2_RRT_state)[4];
  c2_MPC_state = (real_T (*)[6])ssGetOutputPortSignal(chartInstance->S, 2);
  c2_RRT_state = (real_T (*)[4])ssGetOutputPortSignal(chartInstance->S, 1);
  chartInstance->c2_doneDoubleBufferReInit = TRUE;
  c2_u = sf_mex_dup(c2_st);
  c2_emlrt_marshallIn(chartInstance, sf_mex_dup(sf_mex_getcell(c2_u, 0)),
                      "MPC_state", c2_dv0);
  for (c2_i4 = 0; c2_i4 < 6; c2_i4 = c2_i4 + 1) {
    (*c2_MPC_state)[c2_i4] = c2_dv0[c2_i4];
  }

  c2_b_emlrt_marshallIn(chartInstance, sf_mex_dup(sf_mex_getcell(c2_u, 1)),
                        "RRT_state", c2_dv1);
  for (c2_i5 = 0; c2_i5 < 4; c2_i5 = c2_i5 + 1) {
    (*c2_RRT_state)[c2_i5] = c2_dv1[c2_i5];
  }

  chartInstance->c2_is_active_c2_MPC_gamecontroller_LiDAR2 =
    c2_c_emlrt_marshallIn(chartInstance, sf_mex_dup(sf_mex_getcell(c2_u, 2))
    , "is_active_c2_MPC_gamecontroller_LiDAR2");
  sf_mex_destroy(&c2_u);
  c2_update_debugger_state_c2_MPC_gamecontroller_LiDAR2(chartInstance);
  sf_mex_destroy(&c2_st);
}

static void finalize_c2_MPC_gamecontroller_LiDAR2
  (SFc2_MPC_gamecontroller_LiDAR2InstanceStruct *chartInstance)
{
}

static void sf_c2_MPC_gamecontroller_LiDAR2
  (SFc2_MPC_gamecontroller_LiDAR2InstanceStruct *chartInstance)
{
  int32_T c2_i6;
  int32_T c2_i7;
  int32_T c2_i8;
  int32_T c2_i9;
  int32_T c2_i10;
  int32_T c2_previousEvent;
  int32_T c2_i11;
  real_T c2_hoistedGlobal[2];
  int32_T c2_i12;
  real_T c2_b_hoistedGlobal[4];
  int32_T c2_i13;
  real_T c2_c_hoistedGlobal[2];
  int32_T c2_i14;
  real_T c2_roll[2];
  int32_T c2_i15;
  real_T c2_wheel_speeds[4];
  int32_T c2_i16;
  real_T c2_yaw[2];
  uint32_T c2_debug_family_var_map[14];
  real_T c2_velocity;
  real_T c2_Phi_d;
  real_T c2_Phi;
  real_T c2_Psi_d;
  real_T c2_Psi;
  real_T c2_Vy;
  real_T c2_Vx;
  real_T c2_nargin = 3.0;
  real_T c2_nargout = 2.0;
  real_T c2_RRT_state[4];
  real_T c2_MPC_state[6];
  real_T c2_A;
  real_T c2_x;
  real_T c2_b_x;
  real_T c2_c_x;
  real_T c2_a;
  real_T c2_y;
  real_T c2_b_y[6];
  int32_T c2_i17;
  real_T c2_dv2[4];
  int32_T c2_i18;
  int32_T c2_i19;
  int32_T c2_i20;
  real_T (*c2_b_RRT_state)[4];
  real_T (*c2_b_MPC_state)[6];
  real_T (*c2_b_yaw)[2];
  real_T (*c2_b_wheel_speeds)[4];
  real_T (*c2_b_roll)[2];
  c2_b_MPC_state = (real_T (*)[6])ssGetOutputPortSignal(chartInstance->S, 2);
  c2_b_RRT_state = (real_T (*)[4])ssGetOutputPortSignal(chartInstance->S, 1);
  c2_b_yaw = (real_T (*)[2])ssGetInputPortSignal(chartInstance->S, 2);
  c2_b_wheel_speeds = (real_T (*)[4])ssGetInputPortSignal(chartInstance->S, 1);
  c2_b_roll = (real_T (*)[2])ssGetInputPortSignal(chartInstance->S, 0);
  _sfTime_ = (real_T)ssGetT(chartInstance->S);
  _SFD_CC_CALL(CHART_ENTER_SFUNCTION_TAG, 1);
  for (c2_i6 = 0; c2_i6 < 2; c2_i6 = c2_i6 + 1) {
    _SFD_DATA_RANGE_CHECK((*c2_b_roll)[c2_i6], 0U);
  }

  for (c2_i7 = 0; c2_i7 < 4; c2_i7 = c2_i7 + 1) {
    _SFD_DATA_RANGE_CHECK((*c2_b_wheel_speeds)[c2_i7], 1U);
  }

  for (c2_i8 = 0; c2_i8 < 2; c2_i8 = c2_i8 + 1) {
    _SFD_DATA_RANGE_CHECK((*c2_b_yaw)[c2_i8], 2U);
  }

  for (c2_i9 = 0; c2_i9 < 4; c2_i9 = c2_i9 + 1) {
    _SFD_DATA_RANGE_CHECK((*c2_b_RRT_state)[c2_i9], 3U);
  }

  for (c2_i10 = 0; c2_i10 < 6; c2_i10 = c2_i10 + 1) {
    _SFD_DATA_RANGE_CHECK((*c2_b_MPC_state)[c2_i10], 4U);
  }

  c2_previousEvent = _sfEvent_;
  _sfEvent_ = CALL_EVENT;
  _SFD_CC_CALL(CHART_ENTER_DURING_FUNCTION_TAG, 1);
  for (c2_i11 = 0; c2_i11 < 2; c2_i11 = c2_i11 + 1) {
    c2_hoistedGlobal[c2_i11] = (*c2_b_roll)[c2_i11];
  }

  for (c2_i12 = 0; c2_i12 < 4; c2_i12 = c2_i12 + 1) {
    c2_b_hoistedGlobal[c2_i12] = (*c2_b_wheel_speeds)[c2_i12];
  }

  for (c2_i13 = 0; c2_i13 < 2; c2_i13 = c2_i13 + 1) {
    c2_c_hoistedGlobal[c2_i13] = (*c2_b_yaw)[c2_i13];
  }

  for (c2_i14 = 0; c2_i14 < 2; c2_i14 = c2_i14 + 1) {
    c2_roll[c2_i14] = c2_hoistedGlobal[c2_i14];
  }

  for (c2_i15 = 0; c2_i15 < 4; c2_i15 = c2_i15 + 1) {
    c2_wheel_speeds[c2_i15] = c2_b_hoistedGlobal[c2_i15];
  }

  for (c2_i16 = 0; c2_i16 < 2; c2_i16 = c2_i16 + 1) {
    c2_yaw[c2_i16] = c2_c_hoistedGlobal[c2_i16];
  }

  sf_debug_symbol_scope_push_eml(0U, 14U, 14U, c2_debug_family_names,
    c2_debug_family_var_map);
  sf_debug_symbol_scope_add_eml(&c2_velocity, c2_d_sf_marshall, 0U);
  sf_debug_symbol_scope_add_eml(&c2_Phi_d, c2_d_sf_marshall, 1U);
  sf_debug_symbol_scope_add_eml(&c2_Phi, c2_d_sf_marshall, 2U);
  sf_debug_symbol_scope_add_eml(&c2_Psi_d, c2_d_sf_marshall, 3U);
  sf_debug_symbol_scope_add_eml(&c2_Psi, c2_d_sf_marshall, 4U);
  sf_debug_symbol_scope_add_eml(&c2_Vy, c2_d_sf_marshall, 5U);
  sf_debug_symbol_scope_add_eml(&c2_Vx, c2_d_sf_marshall, 6U);
  sf_debug_symbol_scope_add_eml(&c2_nargin, c2_d_sf_marshall, 7U);
  sf_debug_symbol_scope_add_eml(&c2_nargout, c2_d_sf_marshall, 8U);
  sf_debug_symbol_scope_add_eml(c2_roll, c2_c_sf_marshall, 9U);
  sf_debug_symbol_scope_add_eml(c2_wheel_speeds, c2_b_sf_marshall, 10U);
  sf_debug_symbol_scope_add_eml(c2_yaw, c2_c_sf_marshall, 11U);
  sf_debug_symbol_scope_add_eml(c2_RRT_state, c2_b_sf_marshall, 12U);
  sf_debug_symbol_scope_add_eml(c2_MPC_state, c2_sf_marshall, 13U);
  CV_EML_FCN(0, 0);

  /*  Updated: May 5th, 2013 */
  /*  This function takes the scaled data from the IMU and uses it to determine */
  /*  the vehicle states for the RRT and the MPC.  Note that the state of the */
  /*  vehicle is always [0 0 Yaw V]  as the coordinate system is bases on the */
  /*  postion of the vehicle. */
  /* DATA SORTING */
  /* Calculate the vehicle velocity from the wheel encoder data.  this should */
  /* be replaced with a more robust method as this neglects the fact that the */
  /* vechicle may be turning as well as wheel slip */
  _SFD_EML_CALL(0, 14);
  c2_A = ((c2_wheel_speeds[0] + c2_wheel_speeds[1]) + c2_wheel_speeds[2]) +
    c2_wheel_speeds[3];
  c2_x = c2_A;
  c2_b_x = c2_x;
  c2_c_x = c2_b_x;
  c2_velocity = c2_c_x / 4.0;
  _SFD_EML_CALL(0, 17);
  c2_Phi_d = c2_roll[0];

  /*  Roll Rate */
  _SFD_EML_CALL(0, 18);
  c2_Phi = c2_roll[1];

  /*  Roll Angle   */
  _SFD_EML_CALL(0, 19);
  c2_Psi_d = c2_yaw[0];

  /*  Yaw Rate */
  _SFD_EML_CALL(0, 20);
  c2_Psi = c2_yaw[1];

  /*  Yaw angle of the road relative to the  */
  /*  centerline of the car */
  _SFD_EML_CALL(0, 23);
  c2_Vy = c2_velocity;

  /*  Velocity of the vehicle */
  _SFD_EML_CALL(0, 25);
  c2_Vx = 0.0;

  /*  Always 0 as the Coordinates are  */
  /*  determined by the direction of the car */
  _SFD_EML_CALL(0, 29);
  c2_a = c2_Vy;
  c2_y = c2_a * 0.3048780487804878;
  c2_b_y[0] = c2_y;
  c2_b_y[1] = 0.0;
  c2_b_y[2] = c2_Phi_d;
  c2_b_y[3] = c2_Phi;
  c2_b_y[4] = c2_Psi_d;
  c2_b_y[5] = c2_Psi;
  for (c2_i17 = 0; c2_i17 < 6; c2_i17 = c2_i17 + 1) {
    c2_MPC_state[c2_i17] = c2_b_y[c2_i17];
  }

  _SFD_EML_CALL(0, 30);
  c2_dv2[0] = 0.0;
  c2_dv2[1] = 0.0;
  c2_dv2[2] = c2_Psi;
  c2_dv2[3] = c2_velocity;
  for (c2_i18 = 0; c2_i18 < 4; c2_i18 = c2_i18 + 1) {
    c2_RRT_state[c2_i18] = c2_dv2[c2_i18];
  }

  _SFD_EML_CALL(0, -30);
  sf_debug_symbol_scope_pop();
  for (c2_i19 = 0; c2_i19 < 4; c2_i19 = c2_i19 + 1) {
    (*c2_b_RRT_state)[c2_i19] = c2_RRT_state[c2_i19];
  }

  for (c2_i20 = 0; c2_i20 < 6; c2_i20 = c2_i20 + 1) {
    (*c2_b_MPC_state)[c2_i20] = c2_MPC_state[c2_i20];
  }

  _SFD_CC_CALL(EXIT_OUT_OF_FUNCTION_TAG, 1);
  _sfEvent_ = c2_previousEvent;
  sf_debug_check_for_state_inconsistency
    (_MPC_gamecontroller_LiDAR2MachineNumber_, chartInstance->chartNumber,
     chartInstance->
     instanceNumber);
}

static void compInitSubchartSimstructsFcn_c2_MPC_gamecontroller_LiDAR2
  (SFc2_MPC_gamecontroller_LiDAR2InstanceStruct *chartInstance)
{
}

static void init_script_number_translation(uint32_T c2_machineNumber, uint32_T
  c2_chartNumber)
{
}

static const mxArray *c2_sf_marshall(void *chartInstanceVoid, void *c2_u)
{
  const mxArray *c2_y = NULL;
  int32_T c2_i21;
  real_T c2_b_u[6];
  int32_T c2_i22;
  real_T c2_c_u[6];
  const mxArray *c2_b_y = NULL;
  SFc2_MPC_gamecontroller_LiDAR2InstanceStruct *chartInstance;
  chartInstance = (SFc2_MPC_gamecontroller_LiDAR2InstanceStruct *)
    chartInstanceVoid;
  c2_y = NULL;
  for (c2_i21 = 0; c2_i21 < 6; c2_i21 = c2_i21 + 1) {
    c2_b_u[c2_i21] = (*((real_T (*)[6])c2_u))[c2_i21];
  }

  for (c2_i22 = 0; c2_i22 < 6; c2_i22 = c2_i22 + 1) {
    c2_c_u[c2_i22] = c2_b_u[c2_i22];
  }

  c2_b_y = NULL;
  sf_mex_assign(&c2_b_y, sf_mex_create("y", c2_c_u, 0, 0U, 1U, 0U, 1, 6));
  sf_mex_assign(&c2_y, c2_b_y);
  return c2_y;
}

static const mxArray *c2_b_sf_marshall(void *chartInstanceVoid, void *c2_u)
{
  const mxArray *c2_y = NULL;
  int32_T c2_i23;
  real_T c2_b_u[4];
  int32_T c2_i24;
  real_T c2_c_u[4];
  const mxArray *c2_b_y = NULL;
  SFc2_MPC_gamecontroller_LiDAR2InstanceStruct *chartInstance;
  chartInstance = (SFc2_MPC_gamecontroller_LiDAR2InstanceStruct *)
    chartInstanceVoid;
  c2_y = NULL;
  for (c2_i23 = 0; c2_i23 < 4; c2_i23 = c2_i23 + 1) {
    c2_b_u[c2_i23] = (*((real_T (*)[4])c2_u))[c2_i23];
  }

  for (c2_i24 = 0; c2_i24 < 4; c2_i24 = c2_i24 + 1) {
    c2_c_u[c2_i24] = c2_b_u[c2_i24];
  }

  c2_b_y = NULL;
  sf_mex_assign(&c2_b_y, sf_mex_create("y", c2_c_u, 0, 0U, 1U, 0U, 1, 4));
  sf_mex_assign(&c2_y, c2_b_y);
  return c2_y;
}

static const mxArray *c2_c_sf_marshall(void *chartInstanceVoid, void *c2_u)
{
  const mxArray *c2_y = NULL;
  int32_T c2_i25;
  real_T c2_b_u[2];
  int32_T c2_i26;
  real_T c2_c_u[2];
  const mxArray *c2_b_y = NULL;
  SFc2_MPC_gamecontroller_LiDAR2InstanceStruct *chartInstance;
  chartInstance = (SFc2_MPC_gamecontroller_LiDAR2InstanceStruct *)
    chartInstanceVoid;
  c2_y = NULL;
  for (c2_i25 = 0; c2_i25 < 2; c2_i25 = c2_i25 + 1) {
    c2_b_u[c2_i25] = (*((real_T (*)[2])c2_u))[c2_i25];
  }

  for (c2_i26 = 0; c2_i26 < 2; c2_i26 = c2_i26 + 1) {
    c2_c_u[c2_i26] = c2_b_u[c2_i26];
  }

  c2_b_y = NULL;
  sf_mex_assign(&c2_b_y, sf_mex_create("y", c2_c_u, 0, 0U, 1U, 0U, 1, 2));
  sf_mex_assign(&c2_y, c2_b_y);
  return c2_y;
}

static const mxArray *c2_d_sf_marshall(void *chartInstanceVoid, void *c2_u)
{
  const mxArray *c2_y = NULL;
  real_T c2_b_u;
  const mxArray *c2_b_y = NULL;
  SFc2_MPC_gamecontroller_LiDAR2InstanceStruct *chartInstance;
  chartInstance = (SFc2_MPC_gamecontroller_LiDAR2InstanceStruct *)
    chartInstanceVoid;
  c2_y = NULL;
  c2_b_u = *((real_T *)c2_u);
  c2_b_y = NULL;
  sf_mex_assign(&c2_b_y, sf_mex_create("y", &c2_b_u, 0, 0U, 0U, 0U, 0));
  sf_mex_assign(&c2_y, c2_b_y);
  return c2_y;
}

const mxArray *sf_c2_MPC_gamecontroller_LiDAR2_get_eml_resolved_functions_info
  (void)
{
  const mxArray *c2_nameCaptureInfo = NULL;
  c2_ResolvedFunctionInfo c2_info[18];
  const mxArray *c2_m0 = NULL;
  int32_T c2_i27;
  c2_ResolvedFunctionInfo *c2_r0;
  c2_nameCaptureInfo = NULL;
  c2_info_helper(c2_info);
  sf_mex_assign(&c2_m0, sf_mex_createstruct("nameCaptureInfo", 1, 18));
  for (c2_i27 = 0; c2_i27 < 18; c2_i27 = c2_i27 + 1) {
    c2_r0 = &c2_info[c2_i27];
    sf_mex_addfield(c2_m0, sf_mex_create("nameCaptureInfo", c2_r0->context, 15,
      0U, 0U, 0U, 2, 1, strlen(c2_r0->context)), "context",
                    "nameCaptureInfo", c2_i27);
    sf_mex_addfield(c2_m0, sf_mex_create("nameCaptureInfo", c2_r0->name, 15, 0U,
      0U, 0U, 2, 1, strlen(c2_r0->name)), "name",
                    "nameCaptureInfo", c2_i27);
    sf_mex_addfield(c2_m0, sf_mex_create("nameCaptureInfo", c2_r0->dominantType,
      15, 0U, 0U, 0U, 2, 1, strlen(c2_r0->dominantType)),
                    "dominantType", "nameCaptureInfo", c2_i27);
    sf_mex_addfield(c2_m0, sf_mex_create("nameCaptureInfo", c2_r0->resolved, 15,
      0U, 0U, 0U, 2, 1, strlen(c2_r0->resolved)), "resolved"
                    , "nameCaptureInfo", c2_i27);
    sf_mex_addfield(c2_m0, sf_mex_create("nameCaptureInfo", &c2_r0->fileLength,
      7, 0U, 0U, 0U, 0), "fileLength", "nameCaptureInfo",
                    c2_i27);
    sf_mex_addfield(c2_m0, sf_mex_create("nameCaptureInfo", &c2_r0->fileTime1, 7,
      0U, 0U, 0U, 0), "fileTime1", "nameCaptureInfo", c2_i27
                    );
    sf_mex_addfield(c2_m0, sf_mex_create("nameCaptureInfo", &c2_r0->fileTime2, 7,
      0U, 0U, 0U, 0), "fileTime2", "nameCaptureInfo", c2_i27
                    );
  }

  sf_mex_assign(&c2_nameCaptureInfo, c2_m0);
  return c2_nameCaptureInfo;
}

static void c2_info_helper(c2_ResolvedFunctionInfo c2_info[18])
{
  c2_info[0].context = "";
  c2_info[0].name = "plus";
  c2_info[0].dominantType = "double";
  c2_info[0].resolved = "[B]plus";
  c2_info[0].fileLength = 0U;
  c2_info[0].fileTime1 = 0U;
  c2_info[0].fileTime2 = 0U;
  c2_info[1].context = "";
  c2_info[1].name = "mrdivide";
  c2_info[1].dominantType = "double";
  c2_info[1].resolved =
    "[ILXE]$matlabroot$/toolbox/eml/lib/matlab/ops/mrdivide.p";
  c2_info[1].fileLength = 432U;
  c2_info[1].fileTime1 = 1277780622U;
  c2_info[1].fileTime2 = 0U;
  c2_info[2].context =
    "[ILXE]$matlabroot$/toolbox/eml/lib/matlab/ops/mrdivide.p";
  c2_info[2].name = "nargin";
  c2_info[2].dominantType = "";
  c2_info[2].resolved = "[B]nargin";
  c2_info[2].fileLength = 0U;
  c2_info[2].fileTime1 = 0U;
  c2_info[2].fileTime2 = 0U;
  c2_info[3].context =
    "[ILXE]$matlabroot$/toolbox/eml/lib/matlab/ops/mrdivide.p";
  c2_info[3].name = "ge";
  c2_info[3].dominantType = "double";
  c2_info[3].resolved = "[B]ge";
  c2_info[3].fileLength = 0U;
  c2_info[3].fileTime1 = 0U;
  c2_info[3].fileTime2 = 0U;
  c2_info[4].context =
    "[ILXE]$matlabroot$/toolbox/eml/lib/matlab/ops/mrdivide.p";
  c2_info[4].name = "isscalar";
  c2_info[4].dominantType = "double";
  c2_info[4].resolved = "[B]isscalar";
  c2_info[4].fileLength = 0U;
  c2_info[4].fileTime1 = 0U;
  c2_info[4].fileTime2 = 0U;
  c2_info[5].context =
    "[ILXE]$matlabroot$/toolbox/eml/lib/matlab/ops/mrdivide.p";
  c2_info[5].name = "rdivide";
  c2_info[5].dominantType = "double";
  c2_info[5].resolved =
    "[ILXE]$matlabroot$/toolbox/eml/lib/matlab/ops/rdivide.m";
  c2_info[5].fileLength = 403U;
  c2_info[5].fileTime1 = 1245134820U;
  c2_info[5].fileTime2 = 0U;
  c2_info[6].context = "[ILXE]$matlabroot$/toolbox/eml/lib/matlab/ops/rdivide.m";
  c2_info[6].name = "gt";
  c2_info[6].dominantType = "double";
  c2_info[6].resolved = "[B]gt";
  c2_info[6].fileLength = 0U;
  c2_info[6].fileTime1 = 0U;
  c2_info[6].fileTime2 = 0U;
  c2_info[7].context = "[ILXE]$matlabroot$/toolbox/eml/lib/matlab/ops/rdivide.m";
  c2_info[7].name = "isa";
  c2_info[7].dominantType = "double";
  c2_info[7].resolved = "[B]isa";
  c2_info[7].fileLength = 0U;
  c2_info[7].fileTime1 = 0U;
  c2_info[7].fileTime2 = 0U;
  c2_info[8].context = "[ILXE]$matlabroot$/toolbox/eml/lib/matlab/ops/rdivide.m";
  c2_info[8].name = "eml_div";
  c2_info[8].dominantType = "double";
  c2_info[8].resolved =
    "[ILXE]$matlabroot$/toolbox/eml/lib/matlab/eml/eml_div.m";
  c2_info[8].fileLength = 4918U;
  c2_info[8].fileTime1 = 1267095810U;
  c2_info[8].fileTime2 = 0U;
  c2_info[9].context = "[ILXE]$matlabroot$/toolbox/eml/lib/matlab/eml/eml_div.m";
  c2_info[9].name = "isinteger";
  c2_info[9].dominantType = "double";
  c2_info[9].resolved = "[B]isinteger";
  c2_info[9].fileLength = 0U;
  c2_info[9].fileTime1 = 0U;
  c2_info[9].fileTime2 = 0U;
  c2_info[10].context =
    "[ILXE]$matlabroot$/toolbox/eml/lib/matlab/eml/eml_div.m!eml_fldiv";
  c2_info[10].name = "isreal";
  c2_info[10].dominantType = "double";
  c2_info[10].resolved = "[B]isreal";
  c2_info[10].fileLength = 0U;
  c2_info[10].fileTime1 = 0U;
  c2_info[10].fileTime2 = 0U;
  c2_info[11].context = "";
  c2_info[11].name = "mtimes";
  c2_info[11].dominantType = "double";
  c2_info[11].resolved =
    "[ILXE]$matlabroot$/toolbox/eml/lib/matlab/ops/mtimes.m";
  c2_info[11].fileLength = 3425U;
  c2_info[11].fileTime1 = 1251064272U;
  c2_info[11].fileTime2 = 0U;
  c2_info[12].context = "[ILXE]$matlabroot$/toolbox/eml/lib/matlab/ops/mtimes.m";
  c2_info[12].name = "strcmp";
  c2_info[12].dominantType = "char";
  c2_info[12].resolved = "[B]strcmp";
  c2_info[12].fileLength = 0U;
  c2_info[12].fileTime1 = 0U;
  c2_info[12].fileTime2 = 0U;
  c2_info[13].context = "[ILXE]$matlabroot$/toolbox/eml/lib/matlab/ops/mtimes.m";
  c2_info[13].name = "size";
  c2_info[13].dominantType = "double";
  c2_info[13].resolved = "[B]size";
  c2_info[13].fileLength = 0U;
  c2_info[13].fileTime1 = 0U;
  c2_info[13].fileTime2 = 0U;
  c2_info[14].context = "[ILXE]$matlabroot$/toolbox/eml/lib/matlab/ops/mtimes.m";
  c2_info[14].name = "eq";
  c2_info[14].dominantType = "double";
  c2_info[14].resolved = "[B]eq";
  c2_info[14].fileLength = 0U;
  c2_info[14].fileTime1 = 0U;
  c2_info[14].fileTime2 = 0U;
  c2_info[15].context = "[ILXE]$matlabroot$/toolbox/eml/lib/matlab/ops/mtimes.m";
  c2_info[15].name = "class";
  c2_info[15].dominantType = "double";
  c2_info[15].resolved = "[B]class";
  c2_info[15].fileLength = 0U;
  c2_info[15].fileTime1 = 0U;
  c2_info[15].fileTime2 = 0U;
  c2_info[16].context = "[ILXE]$matlabroot$/toolbox/eml/lib/matlab/ops/mtimes.m";
  c2_info[16].name = "not";
  c2_info[16].dominantType = "logical";
  c2_info[16].resolved = "[B]not";
  c2_info[16].fileLength = 0U;
  c2_info[16].fileTime1 = 0U;
  c2_info[16].fileTime2 = 0U;
  c2_info[17].context = "";
  c2_info[17].name = "ctranspose";
  c2_info[17].dominantType = "double";
  c2_info[17].resolved = "[B]ctranspose";
  c2_info[17].fileLength = 0U;
  c2_info[17].fileTime1 = 0U;
  c2_info[17].fileTime2 = 0U;
}

static const mxArray *c2_e_sf_marshall(void *chartInstanceVoid, void *c2_u)
{
  const mxArray *c2_y = NULL;
  boolean_T c2_b_u;
  const mxArray *c2_b_y = NULL;
  SFc2_MPC_gamecontroller_LiDAR2InstanceStruct *chartInstance;
  chartInstance = (SFc2_MPC_gamecontroller_LiDAR2InstanceStruct *)
    chartInstanceVoid;
  c2_y = NULL;
  c2_b_u = *((boolean_T *)c2_u);
  c2_b_y = NULL;
  sf_mex_assign(&c2_b_y, sf_mex_create("y", &c2_b_u, 11, 0U, 0U, 0U, 0));
  sf_mex_assign(&c2_y, c2_b_y);
  return c2_y;
}

static void c2_emlrt_marshallIn(SFc2_MPC_gamecontroller_LiDAR2InstanceStruct
  *chartInstance, const mxArray *c2_MPC_state, const
  char_T *c2_name, real_T c2_y[6])
{
  real_T c2_dv3[6];
  int32_T c2_i28;
  sf_mex_import(c2_name, sf_mex_dup(c2_MPC_state), c2_dv3, 1, 0, 0U, 1, 0U, 1, 6);
  for (c2_i28 = 0; c2_i28 < 6; c2_i28 = c2_i28 + 1) {
    c2_y[c2_i28] = c2_dv3[c2_i28];
  }

  sf_mex_destroy(&c2_MPC_state);
}

static void c2_b_emlrt_marshallIn(SFc2_MPC_gamecontroller_LiDAR2InstanceStruct
  *chartInstance, const mxArray *c2_RRT_state, const
  char_T *c2_name, real_T c2_y[4])
{
  real_T c2_dv4[4];
  int32_T c2_i29;
  sf_mex_import(c2_name, sf_mex_dup(c2_RRT_state), c2_dv4, 1, 0, 0U, 1, 0U, 1, 4);
  for (c2_i29 = 0; c2_i29 < 4; c2_i29 = c2_i29 + 1) {
    c2_y[c2_i29] = c2_dv4[c2_i29];
  }

  sf_mex_destroy(&c2_RRT_state);
}

static uint8_T c2_c_emlrt_marshallIn
  (SFc2_MPC_gamecontroller_LiDAR2InstanceStruct *chartInstance, const mxArray *
   c2_b_is_active_c2_MPC_gamecontroller_LiDAR2, const char_T *c2_name)
{
  uint8_T c2_y;
  uint8_T c2_u0;
  sf_mex_import(c2_name, sf_mex_dup(c2_b_is_active_c2_MPC_gamecontroller_LiDAR2),
                &c2_u0, 1, 3, 0U, 0, 0U, 0);
  c2_y = c2_u0;
  sf_mex_destroy(&c2_b_is_active_c2_MPC_gamecontroller_LiDAR2);
  return c2_y;
}

static void init_dsm_address_info(SFc2_MPC_gamecontroller_LiDAR2InstanceStruct
  *chartInstance)
{
}

/* SFunction Glue Code */
void sf_c2_MPC_gamecontroller_LiDAR2_get_check_sum(mxArray *plhs[])
{
  ((real_T *)mxGetPr((plhs[0])))[0] = (real_T)(2440176204U);
  ((real_T *)mxGetPr((plhs[0])))[1] = (real_T)(3327541528U);
  ((real_T *)mxGetPr((plhs[0])))[2] = (real_T)(1087786879U);
  ((real_T *)mxGetPr((plhs[0])))[3] = (real_T)(2647905275U);
}

mxArray *sf_c2_MPC_gamecontroller_LiDAR2_get_autoinheritance_info(void)
{
  const char *autoinheritanceFields[] = { "checksum", "inputs", "parameters",
    "outputs" };

  mxArray *mxAutoinheritanceInfo = mxCreateStructMatrix(1,1,4,
    autoinheritanceFields);

  {
    mxArray *mxChecksum = mxCreateDoubleMatrix(4,1,mxREAL);
    double *pr = mxGetPr(mxChecksum);
    pr[0] = (double)(4009698539U);
    pr[1] = (double)(1240194229U);
    pr[2] = (double)(2547242664U);
    pr[3] = (double)(2186522232U);
    mxSetField(mxAutoinheritanceInfo,0,"checksum",mxChecksum);
  }

  {
    const char *dataFields[] = { "size", "type", "complexity" };

    mxArray *mxData = mxCreateStructMatrix(1,3,3,dataFields);

    {
      mxArray *mxSize = mxCreateDoubleMatrix(1,2,mxREAL);
      double *pr = mxGetPr(mxSize);
      pr[0] = (double)(2);
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
      pr[0] = (double)(4);
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
      pr[0] = (double)(2);
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

    mxArray *mxData = mxCreateStructMatrix(1,2,3,dataFields);

    {
      mxArray *mxSize = mxCreateDoubleMatrix(1,2,mxREAL);
      double *pr = mxGetPr(mxSize);
      pr[0] = (double)(4);
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
      pr[0] = (double)(6);
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
    mxSetField(mxAutoinheritanceInfo,0,"outputs",mxData);
  }

  return(mxAutoinheritanceInfo);
}

static mxArray *sf_get_sim_state_info_c2_MPC_gamecontroller_LiDAR2(void)
{
  const char *infoFields[] = { "chartChecksum", "varInfo" };

  mxArray *mxInfo = mxCreateStructMatrix(1, 1, 2, infoFields);
  const char *infoEncStr[] = {
    "100 S1x3'type','srcId','name','auxInfo'{{M[1],M[18],T\"MPC_state\",},{M[1],M[10],T\"RRT_state\",},{M[8],M[0],T\"is_active_c2_MPC_gamecontroller_LiDAR2\",}}"
  };

  mxArray *mxVarInfo = sf_mex_decode_encoded_mx_struct_array(infoEncStr, 3, 10);
  mxArray *mxChecksum = mxCreateDoubleMatrix(1, 4, mxREAL);
  sf_c2_MPC_gamecontroller_LiDAR2_get_check_sum(&mxChecksum);
  mxSetField(mxInfo, 0, infoFields[0], mxChecksum);
  mxSetField(mxInfo, 0, infoFields[1], mxVarInfo);
  return mxInfo;
}

static void chart_debug_initialization(SimStruct *S, unsigned int
  fullDebuggerInitialization)
{
  if (!sim_mode_is_rtw_gen(S)) {
    SFc2_MPC_gamecontroller_LiDAR2InstanceStruct *chartInstance;
    chartInstance = (SFc2_MPC_gamecontroller_LiDAR2InstanceStruct *)
      ((ChartInfoStruct *)(ssGetUserData(S)))->chartInstance;
    if (ssIsFirstInitCond(S) && fullDebuggerInitialization==1) {
      /* do this only if simulation is starting */
      {
        unsigned int chartAlreadyPresent;
        chartAlreadyPresent = sf_debug_initialize_chart
          (_MPC_gamecontroller_LiDAR2MachineNumber_,
           2,
           1,
           1,
           5,
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
          _SFD_SET_DATA_PROPS(0,1,1,0,"roll");
          _SFD_SET_DATA_PROPS(1,1,1,0,"wheel_speeds");
          _SFD_SET_DATA_PROPS(2,1,1,0,"yaw");
          _SFD_SET_DATA_PROPS(3,2,0,1,"RRT_state");
          _SFD_SET_DATA_PROPS(4,2,0,1,"MPC_state");
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
        _SFD_CV_INIT_EML(0,1,0,0,0,0,0,0,0);
        _SFD_CV_INIT_EML_FCN(0,0,"eML_blk_kernel",291,-1,1206);
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
          dimVector[0]= 2;
          _SFD_SET_DATA_COMPILED_PROPS(0,SF_DOUBLE,1,&(dimVector[0]),0,0,0,0.0,
            1.0,0,0,(MexFcnForType)c2_c_sf_marshall);
        }

        {
          unsigned int dimVector[1];
          dimVector[0]= 4;
          _SFD_SET_DATA_COMPILED_PROPS(1,SF_DOUBLE,1,&(dimVector[0]),0,0,0,0.0,
            1.0,0,0,(MexFcnForType)c2_b_sf_marshall);
        }

        {
          unsigned int dimVector[1];
          dimVector[0]= 2;
          _SFD_SET_DATA_COMPILED_PROPS(2,SF_DOUBLE,1,&(dimVector[0]),0,0,0,0.0,
            1.0,0,0,(MexFcnForType)c2_c_sf_marshall);
        }

        {
          unsigned int dimVector[1];
          dimVector[0]= 4;
          _SFD_SET_DATA_COMPILED_PROPS(3,SF_DOUBLE,1,&(dimVector[0]),0,0,0,0.0,
            1.0,0,0,(MexFcnForType)c2_b_sf_marshall);
        }

        {
          unsigned int dimVector[1];
          dimVector[0]= 6;
          _SFD_SET_DATA_COMPILED_PROPS(4,SF_DOUBLE,1,&(dimVector[0]),0,0,0,0.0,
            1.0,0,0,(MexFcnForType)c2_sf_marshall);
        }

        {
          real_T (*c2_roll)[2];
          real_T (*c2_wheel_speeds)[4];
          real_T (*c2_yaw)[2];
          real_T (*c2_RRT_state)[4];
          real_T (*c2_MPC_state)[6];
          c2_MPC_state = (real_T (*)[6])ssGetOutputPortSignal(chartInstance->S,
            2);
          c2_RRT_state = (real_T (*)[4])ssGetOutputPortSignal(chartInstance->S,
            1);
          c2_yaw = (real_T (*)[2])ssGetInputPortSignal(chartInstance->S, 2);
          c2_wheel_speeds = (real_T (*)[4])ssGetInputPortSignal(chartInstance->S,
            1);
          c2_roll = (real_T (*)[2])ssGetInputPortSignal(chartInstance->S, 0);
          _SFD_SET_DATA_VALUE_PTR(0U, *c2_roll);
          _SFD_SET_DATA_VALUE_PTR(1U, *c2_wheel_speeds);
          _SFD_SET_DATA_VALUE_PTR(2U, *c2_yaw);
          _SFD_SET_DATA_VALUE_PTR(3U, *c2_RRT_state);
          _SFD_SET_DATA_VALUE_PTR(4U, *c2_MPC_state);
        }
      }
    } else {
      sf_debug_reset_current_state_configuration
        (_MPC_gamecontroller_LiDAR2MachineNumber_,chartInstance->chartNumber,
         chartInstance->instanceNumber);
    }
  }
}

static void sf_opaque_initialize_c2_MPC_gamecontroller_LiDAR2(void
  *chartInstanceVar)
{
  chart_debug_initialization(((SFc2_MPC_gamecontroller_LiDAR2InstanceStruct*)
    chartInstanceVar)->S,0);
  initialize_params_c2_MPC_gamecontroller_LiDAR2
    ((SFc2_MPC_gamecontroller_LiDAR2InstanceStruct*) chartInstanceVar);
  initialize_c2_MPC_gamecontroller_LiDAR2
    ((SFc2_MPC_gamecontroller_LiDAR2InstanceStruct*) chartInstanceVar);
}

static void sf_opaque_enable_c2_MPC_gamecontroller_LiDAR2(void *chartInstanceVar)
{
  enable_c2_MPC_gamecontroller_LiDAR2
    ((SFc2_MPC_gamecontroller_LiDAR2InstanceStruct*) chartInstanceVar);
}

static void sf_opaque_disable_c2_MPC_gamecontroller_LiDAR2(void
  *chartInstanceVar)
{
  disable_c2_MPC_gamecontroller_LiDAR2
    ((SFc2_MPC_gamecontroller_LiDAR2InstanceStruct*) chartInstanceVar);
}

static void sf_opaque_gateway_c2_MPC_gamecontroller_LiDAR2(void
  *chartInstanceVar)
{
  sf_c2_MPC_gamecontroller_LiDAR2((SFc2_MPC_gamecontroller_LiDAR2InstanceStruct*)
    chartInstanceVar);
}

static mxArray* sf_internal_get_sim_state_c2_MPC_gamecontroller_LiDAR2(SimStruct*
  S)
{
  ChartInfoStruct *chartInfo = (ChartInfoStruct*) ssGetUserData(S);
  mxArray *plhs[1] = { NULL };

  mxArray *prhs[4];
  int mxError = 0;
  prhs[0] = mxCreateString("chart_simctx_raw2high");
  prhs[1] = mxCreateDoubleScalar(ssGetSFuncBlockHandle(S));
  prhs[2] = (mxArray*) get_sim_state_c2_MPC_gamecontroller_LiDAR2
    ((SFc2_MPC_gamecontroller_LiDAR2InstanceStruct*)chartInfo->chartInstance);/* raw sim ctx */
  prhs[3] = sf_get_sim_state_info_c2_MPC_gamecontroller_LiDAR2();/* state var info */
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

static void sf_internal_set_sim_state_c2_MPC_gamecontroller_LiDAR2(SimStruct* S,
  const mxArray *st)
{
  ChartInfoStruct *chartInfo = (ChartInfoStruct*) ssGetUserData(S);
  mxArray *plhs[1] = { NULL };

  mxArray *prhs[4];
  int mxError = 0;
  prhs[0] = mxCreateString("chart_simctx_high2raw");
  prhs[1] = mxCreateDoubleScalar(ssGetSFuncBlockHandle(S));
  prhs[2] = mxDuplicateArray(st);      /* high level simctx */
  prhs[3] = (mxArray*) sf_get_sim_state_info_c2_MPC_gamecontroller_LiDAR2();/* state var info */
  mxError = sf_mex_call_matlab(1, plhs, 4, prhs, "sfprivate");
  mxDestroyArray(prhs[0]);
  mxDestroyArray(prhs[1]);
  mxDestroyArray(prhs[2]);
  mxDestroyArray(prhs[3]);
  if (mxError || plhs[0] == NULL) {
    sf_mex_error_message("Stateflow Internal Error: \nError calling 'chart_simctx_high2raw'.\n");
  }

  set_sim_state_c2_MPC_gamecontroller_LiDAR2
    ((SFc2_MPC_gamecontroller_LiDAR2InstanceStruct*)chartInfo->chartInstance,
     mxDuplicateArray(plhs[0]));
  mxDestroyArray(plhs[0]);
}

static mxArray* sf_opaque_get_sim_state_c2_MPC_gamecontroller_LiDAR2(SimStruct*
  S)
{
  return sf_internal_get_sim_state_c2_MPC_gamecontroller_LiDAR2(S);
}

static void sf_opaque_set_sim_state_c2_MPC_gamecontroller_LiDAR2(SimStruct* S,
  const mxArray *st)
{
  sf_internal_set_sim_state_c2_MPC_gamecontroller_LiDAR2(S, st);
}

static void sf_opaque_terminate_c2_MPC_gamecontroller_LiDAR2(void
  *chartInstanceVar)
{
  if (chartInstanceVar!=NULL) {
    SimStruct *S = ((SFc2_MPC_gamecontroller_LiDAR2InstanceStruct*)
                    chartInstanceVar)->S;
    if (sim_mode_is_rtw_gen(S) || sim_mode_is_external(S)) {
      sf_clear_rtw_identifier(S);
    }

    finalize_c2_MPC_gamecontroller_LiDAR2
      ((SFc2_MPC_gamecontroller_LiDAR2InstanceStruct*) chartInstanceVar);
    free((void *)chartInstanceVar);
    ssSetUserData(S,NULL);
  }
}

static void sf_opaque_init_subchart_simstructs(void *chartInstanceVar)
{
  compInitSubchartSimstructsFcn_c2_MPC_gamecontroller_LiDAR2
    ((SFc2_MPC_gamecontroller_LiDAR2InstanceStruct*) chartInstanceVar);
}

extern unsigned int sf_machine_global_initializer_called(void);
static void mdlProcessParameters_c2_MPC_gamecontroller_LiDAR2(SimStruct *S)
{
  int i;
  for (i=0;i<ssGetNumRunTimeParams(S);i++) {
    if (ssGetSFcnParamTunable(S,i)) {
      ssUpdateDlgParamAsRunTimeParam(S,i);
    }
  }

  if (sf_machine_global_initializer_called()) {
    initialize_params_c2_MPC_gamecontroller_LiDAR2
      ((SFc2_MPC_gamecontroller_LiDAR2InstanceStruct*)(((ChartInfoStruct *)
         ssGetUserData(S))->chartInstance));
  }
}

static void mdlSetWorkWidths_c2_MPC_gamecontroller_LiDAR2(SimStruct *S)
{
  if (sim_mode_is_rtw_gen(S) || sim_mode_is_external(S)) {
    int_T chartIsInlinable =
      (int_T)sf_is_chart_inlinable(S,"MPC_gamecontroller_LiDAR2",
      "MPC_gamecontroller_LiDAR2",2);
    ssSetStateflowIsInlinable(S,chartIsInlinable);
    ssSetRTWCG(S,sf_rtw_info_uint_prop(S,"MPC_gamecontroller_LiDAR2",
                "MPC_gamecontroller_LiDAR2",2,"RTWCG"));
    ssSetEnableFcnIsTrivial(S,1);
    ssSetDisableFcnIsTrivial(S,1);
    ssSetNotMultipleInlinable(S,sf_rtw_info_uint_prop(S,
      "MPC_gamecontroller_LiDAR2","MPC_gamecontroller_LiDAR2",2,
      "gatewayCannotBeInlinedMultipleTimes"));
    if (chartIsInlinable) {
      ssSetInputPortOptimOpts(S, 0, SS_REUSABLE_AND_LOCAL);
      ssSetInputPortOptimOpts(S, 1, SS_REUSABLE_AND_LOCAL);
      ssSetInputPortOptimOpts(S, 2, SS_REUSABLE_AND_LOCAL);
      sf_mark_chart_expressionable_inputs(S,"MPC_gamecontroller_LiDAR2",
        "MPC_gamecontroller_LiDAR2",2,3);
      sf_mark_chart_reusable_outputs(S,"MPC_gamecontroller_LiDAR2",
        "MPC_gamecontroller_LiDAR2",2,2);
    }

    sf_set_rtw_dwork_info(S,"MPC_gamecontroller_LiDAR2",
                          "MPC_gamecontroller_LiDAR2",2);
    ssSetHasSubFunctions(S,!(chartIsInlinable));
  } else {
  }

  ssSetOptions(S,ssGetOptions(S)|SS_OPTION_WORKS_WITH_CODE_REUSE);
  ssSetChecksum0(S,(1486273194U));
  ssSetChecksum1(S,(37869009U));
  ssSetChecksum2(S,(1537629696U));
  ssSetChecksum3(S,(448221435U));
  ssSetmdlDerivatives(S, NULL);
  ssSetExplicitFCSSCtrl(S,1);
}

static void mdlRTW_c2_MPC_gamecontroller_LiDAR2(SimStruct *S)
{
  if (sim_mode_is_rtw_gen(S)) {
    sf_write_symbol_mapping(S, "MPC_gamecontroller_LiDAR2",
      "MPC_gamecontroller_LiDAR2",2);
    ssWriteRTWStrParam(S, "StateflowChartType", "Embedded MATLAB");
  }
}

static void mdlStart_c2_MPC_gamecontroller_LiDAR2(SimStruct *S)
{
  SFc2_MPC_gamecontroller_LiDAR2InstanceStruct *chartInstance;
  chartInstance = (SFc2_MPC_gamecontroller_LiDAR2InstanceStruct *)malloc(sizeof
    (SFc2_MPC_gamecontroller_LiDAR2InstanceStruct));
  memset(chartInstance, 0, sizeof(SFc2_MPC_gamecontroller_LiDAR2InstanceStruct));
  if (chartInstance==NULL) {
    sf_mex_error_message("Could not allocate memory for chart instance.");
  }

  chartInstance->chartInfo.chartInstance = chartInstance;
  chartInstance->chartInfo.isEMLChart = 1;
  chartInstance->chartInfo.chartInitialized = 0;
  chartInstance->chartInfo.sFunctionGateway =
    sf_opaque_gateway_c2_MPC_gamecontroller_LiDAR2;
  chartInstance->chartInfo.initializeChart =
    sf_opaque_initialize_c2_MPC_gamecontroller_LiDAR2;
  chartInstance->chartInfo.terminateChart =
    sf_opaque_terminate_c2_MPC_gamecontroller_LiDAR2;
  chartInstance->chartInfo.enableChart =
    sf_opaque_enable_c2_MPC_gamecontroller_LiDAR2;
  chartInstance->chartInfo.disableChart =
    sf_opaque_disable_c2_MPC_gamecontroller_LiDAR2;
  chartInstance->chartInfo.getSimState =
    sf_opaque_get_sim_state_c2_MPC_gamecontroller_LiDAR2;
  chartInstance->chartInfo.setSimState =
    sf_opaque_set_sim_state_c2_MPC_gamecontroller_LiDAR2;
  chartInstance->chartInfo.getSimStateInfo =
    sf_get_sim_state_info_c2_MPC_gamecontroller_LiDAR2;
  chartInstance->chartInfo.zeroCrossings = NULL;
  chartInstance->chartInfo.outputs = NULL;
  chartInstance->chartInfo.derivatives = NULL;
  chartInstance->chartInfo.mdlRTW = mdlRTW_c2_MPC_gamecontroller_LiDAR2;
  chartInstance->chartInfo.mdlStart = mdlStart_c2_MPC_gamecontroller_LiDAR2;
  chartInstance->chartInfo.mdlSetWorkWidths =
    mdlSetWorkWidths_c2_MPC_gamecontroller_LiDAR2;
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

void c2_MPC_gamecontroller_LiDAR2_method_dispatcher(SimStruct *S, int_T method,
  void *data)
{
  switch (method) {
   case SS_CALL_MDL_START:
    mdlStart_c2_MPC_gamecontroller_LiDAR2(S);
    break;

   case SS_CALL_MDL_SET_WORK_WIDTHS:
    mdlSetWorkWidths_c2_MPC_gamecontroller_LiDAR2(S);
    break;

   case SS_CALL_MDL_PROCESS_PARAMETERS:
    mdlProcessParameters_c2_MPC_gamecontroller_LiDAR2(S);
    break;

   default:
    /* Unhandled method */
    sf_mex_error_message("Stateflow Internal Error:\n"
                         "Error calling c2_MPC_gamecontroller_LiDAR2_method_dispatcher.\n"
                         "Can't handle method %d.\n", method);
    break;
  }
}
