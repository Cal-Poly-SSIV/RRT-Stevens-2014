/* Include files */

#include "RSC_RRT_LiDAR_No_USER_sfun.h"
#include "c2_RSC_RRT_LiDAR_No_USER.h"
#include "c6_RSC_RRT_LiDAR_No_USER.h"

/* Type Definitions */

/* Named Constants */

/* Variable Declarations */

/* Variable Definitions */
int32_T _sfEvent_;
uint32_T _RSC_RRT_LiDAR_No_USERMachineNumber_;
real_T _sfTime_;

/* Function Declarations */

/* Function Definitions */
void RSC_RRT_LiDAR_No_USER_initializer(void)
{
  _sfEvent_ = CALL_EVENT;
}

void RSC_RRT_LiDAR_No_USER_terminator(void)
{
}

/* SFunction Glue Code */
unsigned int sf_RSC_RRT_LiDAR_No_USER_method_dispatcher(SimStruct *simstructPtr,
  unsigned int chartFileNumber, const char* specsCksum, int_T method, void *data)
{
  if (chartFileNumber==2) {
    c2_RSC_RRT_LiDAR_No_USER_method_dispatcher(simstructPtr, method, data);
    return 1;
  }

  if (chartFileNumber==6) {
    c6_RSC_RRT_LiDAR_No_USER_method_dispatcher(simstructPtr, method, data);
    return 1;
  }

  return 0;
}

unsigned int sf_RSC_RRT_LiDAR_No_USER_process_check_sum_call( int nlhs, mxArray *
  plhs[], int nrhs, const mxArray * prhs[] )
{

#ifdef MATLAB_MEX_FILE

  char commandName[20];
  if (nrhs<1 || !mxIsChar(prhs[0]) )
    return 0;

  /* Possible call to get the checksum */
  mxGetString(prhs[0], commandName,sizeof(commandName)/sizeof(char));
  commandName[(sizeof(commandName)/sizeof(char)-1)] = '\0';
  if (strcmp(commandName,"sf_get_check_sum"))
    return 0;
  plhs[0] = mxCreateDoubleMatrix( 1,4,mxREAL);
  if (nrhs>1 && mxIsChar(prhs[1])) {
    mxGetString(prhs[1], commandName,sizeof(commandName)/sizeof(char));
    commandName[(sizeof(commandName)/sizeof(char)-1)] = '\0';
    if (!strcmp(commandName,"machine")) {
      ((real_T *)mxGetPr((plhs[0])))[0] = (real_T)(1885440617U);
      ((real_T *)mxGetPr((plhs[0])))[1] = (real_T)(3088269943U);
      ((real_T *)mxGetPr((plhs[0])))[2] = (real_T)(2034317993U);
      ((real_T *)mxGetPr((plhs[0])))[3] = (real_T)(1482871022U);
    } else if (!strcmp(commandName,"exportedFcn")) {
      ((real_T *)mxGetPr((plhs[0])))[0] = (real_T)(0U);
      ((real_T *)mxGetPr((plhs[0])))[1] = (real_T)(0U);
      ((real_T *)mxGetPr((plhs[0])))[2] = (real_T)(0U);
      ((real_T *)mxGetPr((plhs[0])))[3] = (real_T)(0U);
    } else if (!strcmp(commandName,"makefile")) {
      ((real_T *)mxGetPr((plhs[0])))[0] = (real_T)(3210991694U);
      ((real_T *)mxGetPr((plhs[0])))[1] = (real_T)(2767922078U);
      ((real_T *)mxGetPr((plhs[0])))[2] = (real_T)(2461384843U);
      ((real_T *)mxGetPr((plhs[0])))[3] = (real_T)(3892236483U);
    } else if (nrhs==3 && !strcmp(commandName,"chart")) {
      unsigned int chartFileNumber;
      chartFileNumber = (unsigned int)mxGetScalar(prhs[2]);
      switch (chartFileNumber) {
       case 2:
        {
          extern void sf_c2_RSC_RRT_LiDAR_No_USER_get_check_sum(mxArray *plhs[]);
          sf_c2_RSC_RRT_LiDAR_No_USER_get_check_sum(plhs);
          break;
        }

       case 6:
        {
          extern void sf_c6_RSC_RRT_LiDAR_No_USER_get_check_sum(mxArray *plhs[]);
          sf_c6_RSC_RRT_LiDAR_No_USER_get_check_sum(plhs);
          break;
        }

       default:
        ((real_T *)mxGetPr((plhs[0])))[0] = (real_T)(0.0);
        ((real_T *)mxGetPr((plhs[0])))[1] = (real_T)(0.0);
        ((real_T *)mxGetPr((plhs[0])))[2] = (real_T)(0.0);
        ((real_T *)mxGetPr((plhs[0])))[3] = (real_T)(0.0);
      }
    } else if (!strcmp(commandName,"target")) {
      ((real_T *)mxGetPr((plhs[0])))[0] = (real_T)(3176360410U);
      ((real_T *)mxGetPr((plhs[0])))[1] = (real_T)(1862911626U);
      ((real_T *)mxGetPr((plhs[0])))[2] = (real_T)(659157607U);
      ((real_T *)mxGetPr((plhs[0])))[3] = (real_T)(1884031890U);
    } else {
      return 0;
    }
  } else {
    ((real_T *)mxGetPr((plhs[0])))[0] = (real_T)(1209066698U);
    ((real_T *)mxGetPr((plhs[0])))[1] = (real_T)(3430049496U);
    ((real_T *)mxGetPr((plhs[0])))[2] = (real_T)(2725894622U);
    ((real_T *)mxGetPr((plhs[0])))[3] = (real_T)(498615677U);
  }

  return 1;

#else

  return 0;

#endif

}

unsigned int sf_RSC_RRT_LiDAR_No_USER_autoinheritance_info( int nlhs, mxArray *
  plhs[], int nrhs, const mxArray * prhs[] )
{

#ifdef MATLAB_MEX_FILE

  char commandName[32];
  if (nrhs<2 || !mxIsChar(prhs[0]) )
    return 0;

  /* Possible call to get the autoinheritance_info */
  mxGetString(prhs[0], commandName,sizeof(commandName)/sizeof(char));
  commandName[(sizeof(commandName)/sizeof(char)-1)] = '\0';
  if (strcmp(commandName,"get_autoinheritance_info"))
    return 0;

  {
    unsigned int chartFileNumber;
    chartFileNumber = (unsigned int)mxGetScalar(prhs[1]);
    switch (chartFileNumber) {
     case 2:
      {
        extern mxArray *sf_c2_RSC_RRT_LiDAR_No_USER_get_autoinheritance_info
          (void);
        plhs[0] = sf_c2_RSC_RRT_LiDAR_No_USER_get_autoinheritance_info();
        break;
      }

     case 6:
      {
        extern mxArray *sf_c6_RSC_RRT_LiDAR_No_USER_get_autoinheritance_info
          (void);
        plhs[0] = sf_c6_RSC_RRT_LiDAR_No_USER_get_autoinheritance_info();
        break;
      }

     default:
      plhs[0] = mxCreateDoubleMatrix(0,0,mxREAL);
    }
  }

  return 1;

#else

  return 0;

#endif

}

unsigned int sf_RSC_RRT_LiDAR_No_USER_get_eml_resolved_functions_info( int nlhs,
  mxArray * plhs[], int nrhs, const mxArray * prhs[] )
{

#ifdef MATLAB_MEX_FILE

  char commandName[64];
  if (nrhs<2 || !mxIsChar(prhs[0]))
    return 0;

  /* Possible call to get the get_eml_resolved_functions_info */
  mxGetString(prhs[0], commandName,sizeof(commandName)/sizeof(char));
  commandName[(sizeof(commandName)/sizeof(char)-1)] = '\0';
  if (strcmp(commandName,"get_eml_resolved_functions_info"))
    return 0;

  {
    unsigned int chartFileNumber;
    chartFileNumber = (unsigned int)mxGetScalar(prhs[1]);
    switch (chartFileNumber) {
     case 2:
      {
        extern const mxArray
          *sf_c2_RSC_RRT_LiDAR_No_USER_get_eml_resolved_functions_info(void);
        mxArray *persistentMxArray = (mxArray *)
          sf_c2_RSC_RRT_LiDAR_No_USER_get_eml_resolved_functions_info();
        plhs[0] = mxDuplicateArray(persistentMxArray);
        mxDestroyArray(persistentMxArray);
        break;
      }

     case 6:
      {
        extern const mxArray
          *sf_c6_RSC_RRT_LiDAR_No_USER_get_eml_resolved_functions_info(void);
        mxArray *persistentMxArray = (mxArray *)
          sf_c6_RSC_RRT_LiDAR_No_USER_get_eml_resolved_functions_info();
        plhs[0] = mxDuplicateArray(persistentMxArray);
        mxDestroyArray(persistentMxArray);
        break;
      }

     default:
      plhs[0] = mxCreateDoubleMatrix(0,0,mxREAL);
    }
  }

  return 1;

#else

  return 0;

#endif

}

void RSC_RRT_LiDAR_No_USER_debug_initialize(void)
{
  _RSC_RRT_LiDAR_No_USERMachineNumber_ = sf_debug_initialize_machine(
    "RSC_RRT_LiDAR_No_USER","sfun",0,2,0,0,0);
  sf_debug_set_machine_event_thresholds(_RSC_RRT_LiDAR_No_USERMachineNumber_,0,0);
  sf_debug_set_machine_data_thresholds(_RSC_RRT_LiDAR_No_USERMachineNumber_,0);
}

void RSC_RRT_LiDAR_No_USER_register_exported_symbols(SimStruct* S)
{
}
