;*****************************************************************************************
;
;  FUNCTION :   test_range_keys_4_fitvdf2sumof2funcs.pro
;  PURPOSE  :   This routine tests the range input keywords supplied by the user for
;                 format and compliance.
;
;  CALLED BY:   
;               get_default_pinfo_4_fitvdf2sumof2funcs.pro
;               wrapper_fit_vdf_2_sumof2funcs.pro
;
;  INCLUDES:
;               NA
;
;  CALLS:
;               is_a_number.pro
;
;  REQUIRES:    
;               1)  UMN Modified Wind/3DP IDL Libraries
;
;  INPUT:
;               NA
;
;  EXAMPLES:    
;               [calling sequence]
;               test = test_range_keys_4_fitvdf2sumof2funcs( [RKEY_IN=rkey_in]        $
;                                 [,DEF_RAN=def_ran] [,LIMS_OUT=lims_out]             $
;                                 [,LIMD_OUT=limd_out] [,RKEY_ON=rkey_on]             )
;
;  KEYWORDS:    
;               RKEY_IN   :  [4]-Element [numeric] array defining the range of allowed
;                               values to use for the parameter of interest where the
;                               first two elements specify whether to turn on the limits
;                               and the last two specify the values of said limits.
;               DEF_RAN   :  [2]-Element [numeric] array defining the default range to
;                               to use if RKEY_IN[2:3] are bad or the same value
;                               [ Default = [NaN, NaN] ]
;               LIMS_OUT  :  Set to a named variable to return the range of values to
;                               use in the LIMITS tag for the PARINFO structures
;               LIMD_OUT  :  Set to a named variable to return the boolean values to
;                               use in the LIMITED tag for the PARINFO structures
;               RKEY_ON   :  Set to a named variable to return a boolean value informing
;                               the user as to whether the input keyword was set and
;                               properly formatted
;
;   CHANGED:  1)  Cleaned up and updated Man. page
;                                                                   [04/24/2018   v1.0.1]
;             2)  Added keywords EMIN_CH and EMIN_B to main routine
;                                                                   [04/24/2018   v1.0.1]
;             3)  Fixed some minor things
;                                                                   [05/02/2018   v1.0.2]
;
;   NOTES:      
;               0)  Make sure to set RKEY_IN properly!!!
;                   [e.g., see Man. page of get_default_pinfo_4_fitvdf2sumof2funcs.pro]
;
;  REFERENCES:  
;               NA
;
;   CREATED:  04/23/2018
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  05/02/2018   v1.0.2
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************

FUNCTION test_range_keys_4_fitvdf2sumof2funcs,RKEY_IN=rkey_in,DEF_RAN=def_ran,          $
                                              LIMS_OUT=lims_out,LIMD_OUT=limd_out,      $
                                              RKEY_ON=rkey_on

;;----------------------------------------------------------------------------------------
;;  Constants
;;----------------------------------------------------------------------------------------
f                       = !VALUES.F_NAN
d                       = !VALUES.D_NAN
dumb0b                  = REPLICATE(0b,2)
dumb1b                  = REPLICATE(1b,2)
dumbd                   = REPLICATE(d,2)
rkey_on                 = 1b
lims_out                = dumbd
limd_out                = dumb0b
;;----------------------------------------------------------------------------------------
;;  Check keywords
;;----------------------------------------------------------------------------------------
;;  Check DEF_RAN
test                    = (N_ELEMENTS(def_ran) GE 2) AND is_a_number(def_ran,/NOMSSG)
IF (test[0]) THEN def_range = DOUBLE(REFORM(def_ran[0L:1L])) ELSE def_range = REPLICATE(d,2)
;;  Check RKEY_IN
test                    = (N_ELEMENTS(rkey_in) EQ 4) AND is_a_number(rkey_in,/NOMSSG)
IF (test[0]) THEN BEGIN
  ;;  So far so good, now check elements
  test                    = (TOTAL(rkey_in[0L:1L] EQ 0 OR rkey_in[0L:1L] EQ 1) EQ 2)
  IF (test[0]) THEN BEGIN
    limd_out                = BYTE(rkey_in[0L:1L])
  ENDIF ELSE BEGIN
    ;;  Check if default range is okay to use
    good                    = WHERE(FINITE(def_range) GT 0,gd)
    IF (gd[0] GT 0) THEN limd_out[good] = dumb1b[good] ELSE limd_out = REPLICATE(0b,2)
    rkey_on                 = 0b
  ENDELSE
  test                    = (TOTAL(FINITE(rkey_in[2L:3L])) EQ TOTAL(limd_out))
  IF (test[0]) THEN BEGIN
    ;;  RKEY_IN properly formatted --> define output range
    lims_out                = DOUBLE(rkey_in[2L:3L])
  ENDIF ELSE BEGIN
    ;;  Something is wrong, check if default range is okay to use
    good                    = WHERE((FINITE(def_range) GT 0) AND limd_out,gd)
    IF (gd[0] GT 0) THEN lims_out[good] = def_range[good] ELSE lims_out = REPLICATE(d,2)
    rkey_on                 = 0b
  ENDELSE
ENDIF ELSE BEGIN
  ;;  Check if default range is okay to use
  good                    = WHERE(FINITE(def_range) GT 0,gd)
  IF (gd[0] GT 0) THEN BEGIN
    ;;  Use default range
    limd_out[good]          = dumb1b[good]
    lims_out[good]          = def_range[good]
  ENDIF ELSE BEGIN
    ;;  Bad format --> do not limit parameter
    lims_out                = REPLICATE(d,2)
    limd_out                = REPLICATE(0b,2)
  ENDELSE
  rkey_on                 = 0b
ENDELSE
;;----------------------------------------------------------------------------------------
;;  Return to user
;;----------------------------------------------------------------------------------------

RETURN,1b
END


;*****************************************************************************************
;
;  FUNCTION :   get_default_pinfo_4_fitvdf2sumof2funcs.pro
;  PURPOSE  :   This is a subroutine of wrapper_fit_vdf_2_sumof2funcs.pro meant to return
;                 the PARINFO structure appropriate for the given input particle species.
;
;  CALLED BY:   
;               wrapper_fit_vdf_2_sumof2funcs.pro
;
;  INCLUDES:
;               NA
;
;  CALLS:
;               is_a_number.pro
;               test_range_keys_4_fitvdf2sumof2funcs.pro
;
;  REQUIRES:    
;               1)  UMN Modified Wind/3DP IDL Libraries
;
;  INPUT:
;               NA
;
;  EXAMPLES:    
;               [calling sequence]
;               test = get_default_pinfo_4_fitvdf2sumof2funcs(                                                  $
;                                          [,CFUNC=cfunc] [,HFUNC=hfunc] [,BFUNC=bfunc]                         $
;                                          [,/ELECTRONS] [,/IONS]                                               $
;                                          [,FIXED_C=fixed_c] [,FIXED_H=fixed_h] [,FIXED_B=fixed_b]             $
;                                          [,NCORE_RAN=ncore_ran] [,NHALO_RAN=nhalo_ran] [,NBEAM_RAN=nbeam_ran] $
;                                          [,VTACORERN=vtacorern] [,VTAHALORN=vtahalorn] [,VTABEAMRN=vtabeamrn] $
;                                          [,VTECORERN=vtecorern] [,VTEHALORN=vtehalorn] [,VTEBEAMRN=vtebeamrn] $
;                                          [,VOACORERN=voacorern] [,VOAHALORN=voahalorn] [,VOABEAMRN=voabeamrn] $
;                                          [,VOECORERN=voecorern] [,VOEHALORN=voehalorn] [,VOEBEAMRN=voebeamrn] $
;                                          [,EXPCORERN=expcorern] [,EXPHALORN=exphalorn] [,EXPBEAMRN=expbeamrn] $
;                                          [,FTOL=ftol] [,GTOL=gtol] [,XTOL=xtol] [,USE_MM=use_mm]              $
;                                          [,DEF_OFFST=def_offst] [,PARINFO=def_pinf]                           $
;                                          [,BARINFO=def_binf]                                                  )
;
;  KEYWORDS:    
;               ****************
;               ***  INPUTS  ***
;               ****************
;               CFUNC      :  Scalar [string] used to determine which model function to
;                               use for the core VDF
;                                 'MM'  :  bi-Maxwellian VDF
;                                 'KK'  :  bi-kappa VDF
;                                 'SS'  :  bi-self-similar VDF
;                               [Default = 'MM']
;               HFUNC      :  Scalar [string] used to determine which model function to
;                               use for the halo VDF
;                                 'MM'  :  bi-Maxwellian VDF
;                                 'KK'  :  bi-kappa VDF
;                                 'SS'  :  bi-self-similar VDF
;                               [Default = 'KK']
;               BFUNC      :  Scalar [string] used to determine which model function to
;                               use for the beam/strahl part of VDF
;                                 'MM'  :  bi-Maxwellian VDF
;                                 'KK'  :  bi-kappa VDF
;                                 'SS'  :  bi-self-similar VDF
;                               [Default = 'KK']
;               ELECTRONS  :  If set, routine uses parameters appropriate for non-
;                               relativistic electron velocity distributions
;                               [Default = TRUE]
;               IONS       :  If set, routine uses parameters appropriate for non-
;                               relativistic proton velocity distributions
;                               [Default = FALSE]
;               FIXED_C    :  [4]-Element array containing ones for each element of
;                               COREP the user does NOT wish to vary (i.e., if FIXED_C[0]
;                               is = 1, then COREP[0] will not change when calling
;                               MPFITFUN.PRO).
;                               [Default  :  All elements = 0]
;               FIXED_H    :  [4]-Element array containing ones for each element of
;                               HALOP the user does NOT wish to vary (i.e., if FIXED_H[2]
;                               is = 1, then HALOP[2] will not change when calling
;                               MPFITFUN.PRO).
;                               [Default  :  All elements = 0]
;               FIXED_B    :  [4]-Element array containing ones for each element of
;                               BEAMP the user does NOT wish to vary (i.e., if FIXED_B[3]
;                               is = 1, then BEAMP[3] will not change when calling
;                               MPFITFUN.PRO).
;                               [Default  :  All elements = 0]
;               NCORE_RAN  :  [4]-Element [numeric] array defining the range of allowed
;                               values to use for the core number density or PARAM[0].
;                               Note, if this keyword is set, it is equivalent to telling
;                               the routine that N_core should be limited by these
;                               bounds.  Setting this keyword will define:
;                                 PARINFO[0].LIMITED[*] = BYTE(NCORE_RAN[0:1])
;                                 PARINFO[0].LIMITS[*]  = NCORE_RAN[2:3]
;               NHALO_RAN  :  Same as NCORE_RAN but for PARAM[6] and PARINFO[6].
;               NBEAM_RAN  :  Same as NCORE_RAN but for BPARM[0] and BARINFO[0].
;               VTACORERN  :  [4]-Element [numeric] array defining the range of allowed
;                               values to use for the core parallel thermal speed or
;                               PARAM[1].  Note, if this keyword is set, it is
;                               equivalent to telling the routine that V_Tcpara should be
;                               limited by these bounds.  Setting this keyword will
;                               define:
;                                 PARINFO[1].LIMITED[*] = BYTE(VTACORERN[0:1])
;                                 PARINFO[1].LIMITS[*]  = VTACORERN[2:3]
;               VTAHALORN  :  Same as VTACORERN but for PARAM[7] and PARINFO[7].
;               VTABEAMRN  :  Same as VTACORERN but for BPARM[1] and BARINFO[1].
;               VTECORERN  :  [4]-Element [numeric] array defining the range of allowed
;                               values to use for the core perpendicular thermal speed
;                               or PARAM[2].  Note, if this keyword is set, it is
;                               equivalent to telling the routine that V_Tcperp should be
;                               limited by these bounds.  Setting this keyword will
;                               define:
;                                 PARINFO[2].LIMITED[*] = BYTE(VTECORERN[0:1])
;                                 PARINFO[2].LIMITS[*]  = VTECORERN[2:3]
;               VTEHALORN  :  Same as VTECORERN but for PARAM[8] and PARINFO[8].
;               VTEBEAMRN  :  Same as VTECORERN but for BPARM[2] and BARINFO[2].
;               VOACORERN  :  [4]-Element [numeric] array defining the range of allowed
;                               values to use for the core parallel drift speed or
;                               PARAM[3].  Note, if this keyword is set, it is
;                               equivalent to telling the routine that V_ocpara should be
;                               limited by these bounds.  Setting this keyword will
;                               define:
;                                 PARINFO[3].LIMITED[*] = BYTE(VOACORERN[0:1])
;                                 PARINFO[3].LIMITS[*]  = VOACORERN[2:3]
;               VOAHALORN  :  Same as VOACORERN but for PARAM[9] and PARINFO[9].
;               VOABEAMRN  :  Same as VOACORERN but for BPARM[3] and BARINFO[3].
;               VOECORERN  :  [4]-Element [numeric] array defining the range of allowed
;                               values to use for the core perpendicular drift speed
;                               or PARAM[4].  Note, if this keyword is set, it is
;                               equivalent to telling the routine that V_ocperp should be
;                               limited by these bounds.  Setting this keyword will
;                               define:
;                                 PARINFO[4].LIMITED[*] = BYTE(VOECORERN[0:1])
;                                 PARINFO[4].LIMITS[*]  = VOECORERN[2:3]
;               VOEHALORN  :  Same as VOECORERN but for PARAM[10] and PARINFO[10].
;               VOEBEAMRN  :  Same as VOECORERN but for BPARM[4] and BARINFO[4].
;               EXPCORERN  :  [4]-Element [numeric] array defining the range of allowed
;                               values to use for the exponent parameter or PARAM[5].
;                               Note, if this keyword is set, it is equivalent to
;                               telling the routine that V_ocperp should be limited by
;                               these bounds.  Setting this keyword will define:
;                                 PARINFO[5].LIMITED[*] = BYTE(EXPCORERN[0:1])
;                                 PARINFO[5].LIMITS[*]  = EXPCORERN[2:3]
;               EXPHALORN  :  Same as EXPCORERN but for PARAM[11] and PARINFO[11].
;               EXPBEAMRN  :  Same as EXPCORERN but for BPARM[5] and BARINFO[5].
;               FTOL       :  Scalar [double] definining the maximum values in both
;                               the actual and predicted relative reductions in the sum
;                               squares are at most FTOL at termination.  Therefore, FTOL
;                               measures the relative error desired in the sum of
;                               squares.
;                               [Default  :  1d-14 ]
;               GTOL       :  Scalar [double] definining the value of the absolute cosine
;                               of the angle between fvec and any column of the jacobian
;                               allowed before terminating the fit calculation.
;                               Therefore, GTOL measures the orthogonality desired
;                               between the function vector and the columns of the
;                               jacobian.
;                               [Default  :  1d-14 ]
;               XTOL       :  Scalar [double] definining the maximum relative error
;                               between two consecutive iterates to allow before
;                               terminating the fit calculation.  Thus, XTOL measures
;                               the relative error desired in the approximate solution.
;                               [Default  :  1d-12 ]
;               USE_MM     :  If set, routine will convert input speeds/velocities to
;                               Mm from km
;                               [Default = FALSE]
;               ****************
;               ***  OUTPUT  ***
;               ****************
;               ELECTRONS  :  Scalar [boolean] defining whether the default parameters
;                               assume electron (TRUE) or ions (FALSE)
;                               [Default = TRUE]
;               IONS       :  Scalar [boolean] defining whether the default parameters
;                               assume electron (FALSE) or ions (TRUE)
;                               [Default = FALSE]
;               CFUNC      :  Scalar [string] limited to one of the proper model functions
;                               to use for the core VDF (see allowed values above)
;               HFUNC      :  Scalar [string] limited to one of the proper model functions
;                               to use for the halo VDF (see allowed values above)
;               BFUNC      :  Scalar [string] limited to one of the proper model functions
;                               to use for the beam/strahl VDF (see allowed values above)
;               FTOL       :  Set to a named variable to return the maximum values in both
;                               the actual and predicted relative reductions in the sum
;                               squares
;               GTOL       :  Set to a named variable to return the value of the
;                               absolute cosine  of the angle between fvec and any
;                               column of the jacobian allowed
;               XTOL       :  Set to a named variable to return the maximum relative
;                               error between two consecutive iterates to allow
;               DEF_OFFST  :  Set to a named variable to return the default offset
;                               applied to the number densities in the PARAM array
;               PARINFO    :  Set to a named variable to return the default parameter
;                               structure to be passed to MPFIT.PRO.  The output will
;                               be a [12]-element array [structure] where the i-th
;                               element contains the following tags and definitions:
;                               VALUE    =  Scalar [float/double] value defined by
;                                             PARAM[i].  The user need not set this value.
;                                             [Default = PARAM[i] ]
;                               FIXED    =  Scalar [boolean] value defining whether to
;                                             allow MPFIT.PRO to vary PARAM[i] or not
;                                             TRUE   :  parameter constrained
;                                                       (i.e., no variation allowed)
;                                             FALSE  :  parameter unconstrained
;                               LIMITED  =  [2]-Element [boolean] array defining if the
;                                             lower/upper bounds defined by LIMITS
;                                             are imposed(TRUE) otherwise it has no effect
;                                             [Default = FALSE]
;                               LIMITS   =  [2]-Element [float/double] array defining the
;                                             [lower,upper] bounds on PARAM[i].  Both
;                                             LIMITED and LIMITS must be given together.
;                                             [Default = [0.,0.] ]
;                               TIED     =  Scalar [string] that mathematically defines
;                                             how PARAM[i] is forcibly constrained.  For
;                                             instance, assume that PARAM[0] is always
;                                             equal to 2 Pi times PARAM[1], then one would
;                                             define the following:
;                                               PARINFO[0].TIED = '2 * !DPI * P[1]'
;                                             [Default = '']
;                               MPSIDE   =  Scalar value with the following
;                                             consequences:
;                                              0 : 1-sided deriv. computed automatically
;                                              1 : 1-sided deriv. (f(x+h) - f(x)  )/h
;                                             -1 : 1-sided deriv. (f(x)   - f(x-h))/h
;                                              2 : 2-sided deriv. (f(x+h) - f(x-h))/(2*h)
;                                              3 : explicit deriv. used for this parameter
;                                             See MPFIT.PRO and MPFITFUN.PRO for more...
;                                             [Default = 3]
;               BARINFO    :  Set to a named variable to return the default parameter
;                               structure to be passed to MPFIT.PRO for the beam.  The
;                               output will be a [6]-element array [structure] with the
;                               same format as PARINFO.
;
;   CHANGED:  1)  Finished writing beta version of main routine
;                                                                   [04/19/2018   v1.0.0]
;             2)  Added keywords BFUNC and BEAMP to main routine
;                   and added keywords BFUNC and BARINFO
;                                                                   [04/20/2018   v1.0.1]
;             3)  Added limits for number densities
;                   and now density and exponent parameter derivatives are computed
;                   numerically and a relative step of 2% is now set for numerical
;                   derivative parameters
;                                                                   [04/20/2018   v1.0.2]
;             4)  Added keywords:  FIXED_[C,H,B], N[CORE,HALO,BEAM]_RAN,
;                   VTA[CORE,HALO,BEAM]RN, VTE[CORE,HALO,BEAM]RN, VOA[CORE,HALO,BEAM]RN,
;                   VOE[CORE,HALO,BEAM]RN, and EXP[CORE,HALO,BEAM]RN
;                                                                   [04/23/2018   v1.2.0]
;             5)  Cleaned up and addressed bug/issue that occurs if explicit derivatives
;                   are used instead of numerical ones
;                                                                   [04/23/2018   v1.2.1]
;             6)  Removed offset in parameters and input data to reduce dynamic range of
;                   values in PARAM and now calls mpfit2dfun.pro again
;                                                                   [04/24/2018   v1.2.2]
;             7)  Cleaned up and updated Man. page
;                                                                   [04/24/2018   v1.2.3]
;             8)  Added keywords EMIN_CH and EMIN_B to main routine
;                                                                   [04/24/2018   v1.2.3]
;             9)  Added error handling for output from the routine
;                   test_range_keys_4_fitvdf2sumof2funcs.pro
;                                                                   [05/02/2018   v1.2.4]
;            10)  Added keywords:  FTOL, GTOL, and XTOL
;                                                                   [05/03/2018   v1.2.5]
;            11)  Added keyword:  USE_MM
;                                                                   [06/18/2018   v1.2.6]
;
;   NOTES:      
;               1)  VDF = velocity distribution function
;               2)  Routine will not force or check if combination of CFUNC and HFUNC
;                     is an allowed pair, that is done elsewhere
;               3)  There is an odd issue that occurs in some cases when MPSIDE=3 for
;                     all parameters except the densities and exponents.  The Jacobian
;                     fails to converge and the MPFIT routines return a status of -16.
;                     To mitigate this issue, we force MPSIDE=0 as a default instead of
;                     MPSIDE=3.
;
;  REFERENCES:  
;               NA
;
;   CREATED:  04/17/2018
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  06/18/2018   v1.2.6
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************

FUNCTION get_default_pinfo_4_fitvdf2sumof2funcs,CFUNC=cfunc,HFUNC=hfunc,BFUNC=bfunc,           $
                                  ELECTRONS=electrons,IONS=ions,                               $
                                  FIXED_C=fixed_c,FIXED_H=fixed_h,FIXED_B=fixed_b,             $
                                  NCORE_RAN=ncore_ran,NHALO_RAN=nhalo_ran,NBEAM_RAN=nbeam_ran, $
                                  VTACORERN=vtacorern,VTAHALORN=vtahalorn,VTABEAMRN=vtabeamrn, $
                                  VTECORERN=vtecorern,VTEHALORN=vtehalorn,VTEBEAMRN=vtebeamrn, $
                                  VOACORERN=voacorern,VOAHALORN=voahalorn,VOABEAMRN=voabeamrn, $
                                  VOECORERN=voecorern,VOEHALORN=voehalorn,VOEBEAMRN=voebeamrn, $
                                  EXPCORERN=expcorern,EXPHALORN=exphalorn,EXPBEAMRN=expbeamrn, $
                                  FTOL=ftol,GTOL=gtol,XTOL=xtol,USE_MM=use_mm,                 $
                                  DEF_OFFST=def_offst,PARINFO=def_pinf,                        $
                                  BARINFO=def_binf

;;----------------------------------------------------------------------------------------
;;  Constants
;;----------------------------------------------------------------------------------------
f                       = !VALUES.F_NAN
d                       = !VALUES.D_NAN
relstep                 = 2d-2                                ;;  Relative/Fractional step for numerical derivatives
dumbd2                  = REPLICATE(d,2)
;;-------------------------------------------------------
;;  Default fit parameter estimates
;;-------------------------------------------------------
def_vth_emks            = [20d2,50d2,50d2]                    ;;  Default electron thermal speeds [km/s]
def_v_o_emks            = [ 1d2, 1d3, 1d3]                    ;;  Default electron drift speeds [km/s]
def_vth_imks            = [20d0,50d0,50d0]                    ;;  Default proton thermal speeds [km/s]
def_v_o_imks            = [ 3d2, 5d2, 5d2]                    ;;  Default proton drift speeds [km/s]
def_ei_offst            = [1d18,1d10]                         ;;  Default offset to force data to be ≥ 1.0
def_ks                  = [3d0,5d0]                           ;;  Default kappa and self-similar exponent values
def_n_ch                = [5d0,3d-1]                          ;;  Default core/halo number densities [cm^(-3)]
;;-------------------------------------------------------
;;  Default fit parameter limits/ranges
;;-------------------------------------------------------
;;  Default limits/ranges:  Electrons
def_n_ec_lim            = [5d-2,2d2]      ;;  0.05 ≤ n_ec ≤ 200 cm^(-3)
def_n_eh_lim            = [1d-3,2d1]      ;;  0.001 ≤ n_eh ≤ 20 cm^(-3)
def_n_eb_lim            = [1d-4,1d1]      ;;  0.0001 ≤ n_eh ≤ 10 cm^(-3)
def_vtec_lim            = [5d0,1d4]       ;;  5 km/s ≤ V_Tecj ≤ 10000 km/s
def_vteh_lim            = [5d0,2d4]       ;;  5 km/s ≤ V_Tehj ≤ 20000 km/s
def_voec_lim            = [-1d0,1d0]*1d3  ;;   -1000 km/s ≤ V_oecj ≤  +1000 km/s
def_voeh_lim            = [-1d0,1d0]*1d4  ;;  -10000 km/s ≤ V_oecj ≤ +10000 km/s
;;  Default limits/ranges:  Protons
def_n_ic_lim            = [5d-2,2d2]      ;;  0.05 ≤ n_ic ≤ 200 cm^(-3)
def_n_ih_lim            = [1d-3,2d1]      ;;  0.001 ≤ n_ih ≤ 20 cm^(-3)
def_n_ib_lim            = [1d-4,2d1]      ;;  0.0001 ≤ n_ih ≤ 20 cm^(-3)
def_vtic_lim            = [1d0,1d3]       ;;  1 km/s ≤ V_Tpcj ≤ 1000 km/s
def_vtih_lim            = [1d0,2d3]       ;;  1 km/s ≤ V_Tphj ≤ 2000 km/s
def_voic_lim            = [-1d0,1d0]*2d3  ;;   -2000 km/s ≤ V_opcj ≤  +2000 km/s
def_voih_lim            = [-1d0,1d0]*25d2 ;;   -2500 km/s ≤ V_opcj ≤  +2500 km/s
;;  Default limits/ranges:  kappa and self-similar exponent values
def_kapp_lim            = [3d0/2d0,10d1]  ;;  3/2 ≤ kappa ≤ 100
def_ssex_lim            = [2d0,1d1]       ;;  self-similar exponent:  2 ≤ p ≤ 10
;;-------------------------------------------------------
;;  Default fit parameter arrays
;;-------------------------------------------------------
;;  Electrons
def_bimax_ec            = [def_n_ch[0],def_vth_emks[0],def_vth_emks[0],def_v_o_emks[0],0d0,0d0]        ;;  Default bi-Maxwellian core electrons
def_bikap_ec            = [def_n_ch[0],def_vth_emks[1],def_vth_emks[1],def_v_o_emks[1],0d0,def_ks[0]]  ;;  Default bi-kappa " "
def_bi_ss_ec            = [def_n_ch[0],def_vth_emks[2],def_vth_emks[2],def_v_o_emks[2],0d0,def_ks[1]]  ;;  Default bi-self-similar " "
def_bimax_eh            = [def_n_ch[1],def_vth_emks[0],def_vth_emks[0],def_v_o_emks[0],0d0,0d0]        ;;  Default bi-Maxwellian halo electrons
def_bikap_eh            = [def_n_ch[1],def_vth_emks[1],def_vth_emks[1],def_v_o_emks[1],0d0,def_ks[0]]  ;;  Default bi-kappa " "
def_bi_ss_eh            = [def_n_ch[1],def_vth_emks[2],def_vth_emks[2],def_v_o_emks[2],0d0,def_ks[1]]  ;;  Default bi-self-similar " "
;;  Protons
def_bimax_ic            = [def_n_ch[0],def_vth_imks[0],def_vth_imks[0],def_v_o_imks[0],0d0,0d0]        ;;  Default bi-Maxwellian core protons
def_bikap_ic            = [def_n_ch[0],def_vth_imks[1],def_vth_imks[1],def_v_o_imks[1],0d0,def_ks[0]]  ;;  Default bi-kappa " "
def_bi_ss_ic            = [def_n_ch[0],def_vth_imks[2],def_vth_imks[2],def_v_o_imks[2],0d0,def_ks[1]]  ;;  Default bi-self-similar " "
def_bimax_ih            = [def_n_ch[1],def_vth_imks[0],def_vth_imks[0],def_v_o_imks[0],0d0,0d0]        ;;  Default bi-Maxwellian core protons
def_bikap_ih            = [def_n_ch[1],def_vth_imks[1],def_vth_imks[1],def_v_o_imks[1],0d0,def_ks[0]]  ;;  Default bi-kappa " "
def_bi_ss_ih            = [def_n_ch[1],def_vth_imks[2],def_vth_imks[2],def_v_o_imks[2],0d0,def_ks[1]]  ;;  Default bi-self-similar " "
;;  Define default parameter array
def_param               = [def_bimax_ec,def_bikap_eh]
np                      = N_ELEMENTS(def_param)
;;-------------------------------------------------------
;;  Define default PARINFO structure
;;-------------------------------------------------------
tags                    = ['VALUE','FIXED','LIMITED','LIMITS','TIED','MPSIDE','RELSTEP']
tags                    = [tags,'MPDERIV_DEBUG','MPDERIV_RELTOL','MPDERIV_ABSTOL']
def_pinfo0              = CREATE_STRUCT(tags,d,0b,[0b,0b],[0d0,0d0],'',3,relstep[0],0,1d-1,1d-4)
def_pinf                = REPLICATE(def_pinfo0[0],np)
;;  The following are necessary to avoid an oddity whereby the original MPFIT routines
;;    would return a status of -16 (i.e., something went infinite) when debugging was off
;;    but the routines run through just fine if debugging is on.  It's not entirely clear
;;    why debugging would allow the routine to work to the end.  Though it may have to
;;    do with explicit vs. numerical derivatives, where the former may have unexpected
;;    poles at relevant locations while the latter may not.  Again, I am not sure what
;;    is causing the issue.
def_pinf[*].MPSIDE[0]   = 0
;;  Limit kappa values [default is bi-Maxwellian plus kappa]
def_pinf[11].LIMITED[*] = 1b
def_pinf[11].LIMITS[0]  = def_kapp_lim[0]
def_pinf[11].LIMITS[1]  = def_kapp_lim[1]
;;----------------------------------------------------------------------------------------
;;  Check keywords with default options
;;----------------------------------------------------------------------------------------
;;  Check IONS
test           = (N_ELEMENTS(ions) GT 0) AND KEYWORD_SET(ions)
IF (test[0]) THEN ion__on = 1b ELSE ion__on = 0b
;;  Check ELECTRONS
test           = (N_ELEMENTS(electrons) GT 0) AND KEYWORD_SET(electrons)
IF (test[0]) THEN elec_on = 1b ELSE elec_on = ([0b,1b])[~ion__on[0]]
IF (elec_on[0] AND ion__on[0]) THEN ion__on[0] = 0b                    ;;  Make sure only one particle type is set
;;  Check CFUNC
test                    = (SIZE(cfunc,/TYPE) EQ 7)
IF (test[0]) THEN cf = STRUPCASE(STRMID(cfunc[0],0,2)) ELSE cf = 'MM'
CASE cf[0] OF               ;;  Redefine output to proper/allowed format
  'MM'  :  cfunc = 'MM'
  'KK'  :  cfunc = 'KK'
  'SS'  :  cfunc = 'SS'
  ELSE  :  cfunc = 'MM'     ;;  Default
ENDCASE
;;  Check HFUNC
test                    = (SIZE(hfunc,/TYPE) EQ 7)
IF (test[0]) THEN hf = STRUPCASE(STRMID(hfunc[0],0,2)) ELSE hf = 'KK'
CASE hf[0] OF               ;;  Redefine output to proper/allowed format
  'MM'  :  hfunc = 'MM'
  'KK'  :  hfunc = 'KK'
  'SS'  :  hfunc = 'SS'
  ELSE  :  hfunc = 'KK'     ;;  Default
ENDCASE
;;  Check BFUNC
test                    = (SIZE(bfunc,/TYPE) EQ 7)
IF (test[0]) THEN bf = STRUPCASE(STRMID(bfunc[0],0,2)) ELSE bf = 'KK'
CASE bf[0] OF               ;;  Redefine output to proper/allowed format
  'MM'  :  bfunc = 'MM'
  'KK'  :  bfunc = 'KK'
  'SS'  :  bfunc = 'SS'
  ELSE  :  bfunc = 'KK'     ;;  Default
ENDCASE
;;  Check FTOL, GTOL, and XTOL
test                    = (N_ELEMENTS(ftol) GT 0) AND is_a_number(ftol,/NOMSSG)
IF (test[0]) THEN ftol = DOUBLE(ftol[0]) ELSE ftol = 1d-14
test                    = (N_ELEMENTS(gtol) GT 0) AND is_a_number(gtol,/NOMSSG)
IF (test[0]) THEN gtol = DOUBLE(gtol[0]) ELSE gtol = 1d-14
test                    = (N_ELEMENTS(xtol) GT 0) AND is_a_number(xtol,/NOMSSG)
IF (test[0]) THEN xtol = DOUBLE(xtol[0]) ELSE xtol = 1d-12
;;  Check USE_MM
test                    = (N_ELEMENTS(use_mm) GT 0) AND KEYWORD_SET(use_mm)
IF (test[0]) THEN vfac = 1d-3 ELSE vfac = 1d0
;;----------------------------------------------------------------------------------------
;;  Define species-dependent limits
;;----------------------------------------------------------------------------------------
IF (elec_on[0]) THEN BEGIN
  ;;  Use electron values
  def_denc_lim = def_n_ec_lim
  def_denh_lim = def_n_eh_lim
  def_denb_lim = def_n_eb_lim
  def_vthc_lim = def_vtec_lim
  def_vthh_lim = def_vteh_lim
  def_v_oc_lim = def_voec_lim
  def_v_oh_lim = def_voeh_lim
  def_offst    = def_ei_offst[0]
ENDIF ELSE BEGIN
  ;;  Use proton values
  def_denc_lim = def_n_ic_lim
  def_denh_lim = def_n_ih_lim
  def_denb_lim = def_n_ib_lim
  def_vthc_lim = def_vtic_lim
  def_vthh_lim = def_vtih_lim
  def_v_oc_lim = def_voic_lim
  def_v_oh_lim = def_voih_lim
  def_offst    = def_ei_offst[1]
ENDELSE
;;----------------------------------------------------------------------------------------
;;  Check PARINFO keywords
;;----------------------------------------------------------------------------------------
;;  Check FIXED_C
test                    = (N_ELEMENTS(fixed_c) EQ 6) AND is_a_number(fixed_c,/NOMSSG)
IF (test[0]) THEN fixc = (REFORM(fixed_c) EQ 1) ELSE fixc = REPLICATE(0b,6)
;;  Check FIXED_H
test                    = (N_ELEMENTS(fixed_h) EQ 6) AND is_a_number(fixed_h,/NOMSSG)
IF (test[0]) THEN fixh = (REFORM(fixed_h) EQ 1) ELSE fixh = REPLICATE(0b,6)
fixch                   = [fixc,fixh]
;;  Check FIXED_B
test                    = (N_ELEMENTS(fixed_b) EQ 6) AND is_a_number(fixed_b,/NOMSSG)
IF (test[0]) THEN fixb = (REFORM(fixed_b) EQ 1) ELSE fixb = REPLICATE(0b,6)
;;  Check N[CORE,HALO,BEAM]_RAN
test                    = test_range_keys_4_fitvdf2sumof2funcs(RKEY_IN=ncore_ran,DEF_RAN=def_denc_lim,LIMS_OUT=lims_ncore,LIMD_OUT=limd_ncore,RKEY_ON=ncore_on)
test                    = test_range_keys_4_fitvdf2sumof2funcs(RKEY_IN=nhalo_ran,DEF_RAN=def_denh_lim,LIMS_OUT=lims_nhalo,LIMD_OUT=limd_nhalo,RKEY_ON=nhalo_on)
test                    = test_range_keys_4_fitvdf2sumof2funcs(RKEY_IN=nbeam_ran,DEF_RAN=def_denb_lim,LIMS_OUT=lims_nbeam,LIMD_OUT=limd_nbeam,RKEY_ON=nbeam_on)
;;  Check VTA[CORE,HALO,BEAM]RN
test                    = test_range_keys_4_fitvdf2sumof2funcs(RKEY_IN=vtacorern,DEF_RAN=def_vthc_lim,LIMS_OUT=lims_v_tca,LIMD_OUT=limd_v_tca,RKEY_ON=v_tca_on)
test                    = test_range_keys_4_fitvdf2sumof2funcs(RKEY_IN=vtahalorn,DEF_RAN=def_vthh_lim,LIMS_OUT=lims_v_tha,LIMD_OUT=limd_v_tha,RKEY_ON=v_tha_on)
test                    = test_range_keys_4_fitvdf2sumof2funcs(RKEY_IN=vtabeamrn,DEF_RAN=def_vthh_lim,LIMS_OUT=lims_v_tba,LIMD_OUT=limd_v_tba,RKEY_ON=v_tba_on)
;;  Check VTE[CORE,HALO,BEAM]RN
test                    = test_range_keys_4_fitvdf2sumof2funcs(RKEY_IN=vtecorern,DEF_RAN=def_vthc_lim,LIMS_OUT=lims_v_tce,LIMD_OUT=limd_v_tce,RKEY_ON=v_tce_on)
test                    = test_range_keys_4_fitvdf2sumof2funcs(RKEY_IN=vtehalorn,DEF_RAN=def_vthh_lim,LIMS_OUT=lims_v_the,LIMD_OUT=limd_v_the,RKEY_ON=v_the_on)
test                    = test_range_keys_4_fitvdf2sumof2funcs(RKEY_IN=vtebeamrn,DEF_RAN=def_vthh_lim,LIMS_OUT=lims_v_tbe,LIMD_OUT=limd_v_tbe,RKEY_ON=v_tbe_on)
;;  Check VOA[CORE,HALO,BEAM]RN
test                    = test_range_keys_4_fitvdf2sumof2funcs(RKEY_IN=voacorern,DEF_RAN=def_v_oc_lim,LIMS_OUT=lims_v_oca,LIMD_OUT=limd_v_oca,RKEY_ON=v_oca_on)
test                    = test_range_keys_4_fitvdf2sumof2funcs(RKEY_IN=voahalorn,DEF_RAN=def_v_oh_lim,LIMS_OUT=lims_v_oha,LIMD_OUT=limd_v_oha,RKEY_ON=v_oha_on)
test                    = test_range_keys_4_fitvdf2sumof2funcs(RKEY_IN=voabeamrn,DEF_RAN=def_v_oh_lim,LIMS_OUT=lims_v_oba,LIMD_OUT=limd_v_oba,RKEY_ON=v_oba_on)
;;  Check VOE[CORE,HALO,BEAM]RN
test                    = test_range_keys_4_fitvdf2sumof2funcs(RKEY_IN=voecorern,DEF_RAN=def_v_oc_lim,LIMS_OUT=lims_v_oce,LIMD_OUT=limd_v_oce,RKEY_ON=v_oce_on)
test                    = test_range_keys_4_fitvdf2sumof2funcs(RKEY_IN=voehalorn,DEF_RAN=def_v_oh_lim,LIMS_OUT=lims_v_ohe,LIMD_OUT=limd_v_ohe,RKEY_ON=v_ohe_on)
test                    = test_range_keys_4_fitvdf2sumof2funcs(RKEY_IN=voebeamrn,DEF_RAN=def_v_oh_lim,LIMS_OUT=lims_v_obe,LIMD_OUT=limd_v_obe,RKEY_ON=v_obe_on)
;;  Check EXP[CORE,HALO,BEAM]RN
IF (cfunc[0] NE 'MM') THEN BEGIN
  IF (cfunc[0] EQ 'KK') THEN def_expcran = def_kapp_lim ELSE def_expcran = def_ssex_lim
  test = test_range_keys_4_fitvdf2sumof2funcs(RKEY_IN=expcorern,DEF_RAN=def_expcran,LIMS_OUT=lims_exp_c,LIMD_OUT=limd_exp_c,RKEY_ON=exp_c_on)
ENDIF
IF (hfunc[0] NE 'MM') THEN BEGIN
  IF (hfunc[0] EQ 'KK') THEN def_exphran = def_kapp_lim ELSE def_exphran = def_ssex_lim
  test = test_range_keys_4_fitvdf2sumof2funcs(RKEY_IN=exphalorn,DEF_RAN=def_exphran,LIMS_OUT=lims_exp_h,LIMD_OUT=limd_exp_h,RKEY_ON=exp_h_on)
ENDIF
IF (bfunc[0] NE 'MM') THEN BEGIN
  IF (bfunc[0] EQ 'KK') THEN def_expbran = def_kapp_lim ELSE def_expbran = def_ssex_lim
  test = test_range_keys_4_fitvdf2sumof2funcs(RKEY_IN=expbeamrn,DEF_RAN=def_expbran,LIMS_OUT=lims_exp_b,LIMD_OUT=limd_exp_b,RKEY_ON=exp_b_on)
ENDIF
;;----------------------------------------------------------------------------------------
;;  Impose limits on default PARINFO structure
;;----------------------------------------------------------------------------------------
;;  Define default beam structure BARINFO
def_binf                = def_pinf[6L:11L]
;;  Impose FIXED settings for PARINFO and BARINFO
def_pinf[*].FIXED       = fixch
def_binf[*].FIXED       = fixb
;;  Limit number densities [cm^(-3)]
IF (ncore_on[0]) THEN def_pinf[00].LIMITED[*] = limd_ncore ELSE def_pinf[00].LIMITED[*] = 1b
IF (ncore_on[0]) THEN def_pinf[00].LIMITS[*]  = lims_ncore ELSE def_pinf[00].LIMITS[*]  = def_denc_lim
IF (nhalo_on[0]) THEN def_pinf[06].LIMITED[*] = limd_nhalo ELSE def_pinf[06].LIMITED[*] = 1b
IF (nhalo_on[0]) THEN def_pinf[06].LIMITS[*]  = lims_nhalo ELSE def_pinf[06].LIMITS[*]  = def_denh_lim
IF (nbeam_on[0]) THEN def_binf[00].LIMITED[*] = limd_nbeam ELSE def_binf[00].LIMITED[*] = 1b
IF (nbeam_on[0]) THEN def_binf[00].LIMITS[*]  = lims_nbeam ELSE def_binf[00].LIMITS[*]  = def_denb_lim
;;  Limit parallel thermal speeds [km/s]
IF (v_tca_on[0]) THEN def_pinf[01].LIMITED[*] = limd_v_tca ELSE def_pinf[01].LIMITED[*] = 1b
IF (v_tha_on[0]) THEN def_pinf[07].LIMITED[*] = limd_v_tha ELSE def_pinf[07].LIMITED[*] = 1b
IF (v_tba_on[0]) THEN def_binf[01].LIMITED[*] = limd_v_tba ELSE def_binf[01].LIMITED[*] = 1b
IF (v_tca_on[0]) THEN def_pinf[01].LIMITS[*]  = lims_v_tca ELSE def_pinf[01].LIMITS[*]  = def_vthc_lim
IF (v_tha_on[0]) THEN def_pinf[07].LIMITS[*]  = lims_v_tha ELSE def_pinf[07].LIMITS[*]  = def_vthh_lim
IF (v_tba_on[0]) THEN def_binf[01].LIMITS[*]  = lims_v_tba ELSE def_binf[01].LIMITS[*]  = def_vthh_lim
;;  Limit perpendicular thermal speeds [km/s]
IF (v_tce_on[0]) THEN def_pinf[02].LIMITED[*] = limd_v_tce ELSE def_pinf[02].LIMITED[*] = 1b
IF (v_the_on[0]) THEN def_pinf[08].LIMITED[*] = limd_v_the ELSE def_pinf[08].LIMITED[*] = 1b
IF (v_tbe_on[0]) THEN def_binf[02].LIMITED[*] = limd_v_tbe ELSE def_binf[02].LIMITED[*] = 1b
IF (v_tce_on[0]) THEN def_pinf[02].LIMITS[*]  = lims_v_tce ELSE def_pinf[02].LIMITS[*]  = def_vthc_lim
IF (v_the_on[0]) THEN def_pinf[08].LIMITS[*]  = lims_v_the ELSE def_pinf[08].LIMITS[*]  = def_vthh_lim
IF (v_tbe_on[0]) THEN def_binf[02].LIMITS[*]  = lims_v_tbe ELSE def_binf[02].LIMITS[*]  = def_vthh_lim
;;  Limit parallel drift speeds [km/s]
IF (v_oca_on[0]) THEN def_pinf[03].LIMITED[*] = limd_v_oca ELSE def_pinf[03].LIMITED[*] = 1b
IF (v_oha_on[0]) THEN def_pinf[09].LIMITED[*] = limd_v_oha ELSE def_pinf[09].LIMITED[*] = 1b
IF (v_oba_on[0]) THEN def_binf[03].LIMITED[*] = limd_v_oba ELSE def_binf[03].LIMITED[*] = 1b
IF (v_oca_on[0]) THEN def_pinf[03].LIMITS[*]  = lims_v_oca ELSE def_pinf[03].LIMITS[*]  = def_v_oc_lim
IF (v_oha_on[0]) THEN def_pinf[09].LIMITS[*]  = lims_v_oha ELSE def_pinf[09].LIMITS[*]  = def_v_oh_lim
IF (v_oba_on[0]) THEN def_binf[03].LIMITS[*]  = lims_v_oba ELSE def_binf[03].LIMITS[*]  = def_v_oh_lim
;;  Limit perpendicular drift speeds [km/s]
IF (v_oce_on[0]) THEN def_pinf[04].LIMITED[*] = limd_v_oce ELSE def_pinf[04].LIMITED[*] = 1b
IF (v_ohe_on[0]) THEN def_pinf[10].LIMITED[*] = limd_v_ohe ELSE def_pinf[10].LIMITED[*] = 1b
IF (v_obe_on[0]) THEN def_binf[04].LIMITED[*] = limd_v_obe ELSE def_binf[04].LIMITED[*] = 1b
IF (v_oce_on[0]) THEN def_pinf[04].LIMITS[*]  = lims_v_oce ELSE def_pinf[04].LIMITS[*]  = def_v_oc_lim
IF (v_ohe_on[0]) THEN def_pinf[10].LIMITS[*]  = lims_v_ohe ELSE def_pinf[10].LIMITS[*]  = def_v_oh_lim
IF (v_obe_on[0]) THEN def_binf[04].LIMITS[*]  = lims_v_obe ELSE def_binf[04].LIMITS[*]  = def_v_oh_lim

;;  Adjust limits by velocity factor
def_pinf[1:4].LIMITS   *= vfac[0]
def_pinf[7:10].LIMITS  *= vfac[0]
def_binf[1:4].LIMITS   *= vfac[0]
;;----------------------------------------------------------------------------------------
;;  Define model- and species-dependent parameters
;;----------------------------------------------------------------------------------------
;;  CORE:
CASE cfunc[0] OF               ;;  Redefine output to proper/allowed format
  'MM'  :  BEGIN
    ;;  bi-Maxwellian core
    IF (elec_on[0]) THEN def_c_param = def_bimax_ec ELSE def_c_param = def_bimax_ic
    ;;  Fix unused parameter
    def_pinf[05].FIXED      = 1b
  END
  'KK'  :  BEGIN
    ;;  bi-kappa core
    IF (elec_on[0]) THEN def_c_param = def_bikap_ec ELSE def_c_param = def_bikap_ic
    IF (exp_c_on[0]) THEN BEGIN
      ;;  Limit kappa values
      def_pinf[05].LIMITED[*] = limd_exp_c
      def_pinf[05].LIMITS[*]  = lims_exp_c
    ENDIF ELSE BEGIN
      ;;  Limit kappa values [use defaults]
      def_pinf[05].LIMITED[*] = 1b
      def_pinf[05].LIMITS[0]  = def_kapp_lim[0]
      def_pinf[05].LIMITS[1]  = def_kapp_lim[1]
    ENDELSE
  END
  'SS'  :  BEGIN
    ;;  bi-self-similar core
    IF (elec_on[0]) THEN def_c_param = def_bi_ss_ec ELSE def_c_param = def_bi_ss_ic
    IF (exp_c_on[0]) THEN BEGIN
      ;;  Limit self-similar exponent values
      def_pinf[05].LIMITED[*] = limd_exp_c
      def_pinf[05].LIMITS[*]  = lims_exp_c
    ENDIF ELSE BEGIN
      ;;  Limit self-similar exponent values [use defaults]
      def_pinf[05].LIMITED[*] = 1b
      def_pinf[05].LIMITS[*]  = def_ssex_lim
    ENDELSE
  END
ENDCASE
;;  HALO:
CASE hfunc[0] OF               ;;  Redefine output to proper/allowed format
  'MM'  :  BEGIN
    ;;  bi-Maxwellian halo
    IF (elec_on[0]) THEN def_h_param = def_bimax_eh ELSE def_h_param = def_bimax_ih
    ;;  Fix unused parameter
    def_pinf[11].FIXED      = 1b
  END
  'KK'  :  BEGIN
    ;;  bi-kappa halo
    IF (elec_on[0]) THEN def_h_param = def_bikap_eh ELSE def_h_param = def_bikap_ih
    IF (exp_h_on[0]) THEN BEGIN
      ;;  Limit kappa values
      def_pinf[11].LIMITED[*] = limd_exp_h
      def_pinf[11].LIMITS[*]  = lims_exp_h
    ENDIF ELSE BEGIN
      ;;  Limit kappa values [use defaults]
      def_pinf[11].LIMITED[*] = 1b
      def_pinf[11].LIMITS[*]  = def_kapp_lim
    ENDELSE
  END
  'SS'  :  BEGIN
    ;;  bi-self-similar halo
    IF (elec_on[0]) THEN def_h_param = def_bi_ss_eh ELSE def_h_param = def_bi_ss_ih
    IF (exp_h_on[0]) THEN BEGIN
      ;;  Limit self-similar exponent values
      def_pinf[11].LIMITED[*] = limd_exp_h
      def_pinf[11].LIMITS[*]  = lims_exp_h
    ENDIF ELSE BEGIN
      ;;  Limit self-similar exponent values [use defaults]
      def_pinf[11].LIMITED[*] = 1b
      def_pinf[11].LIMITS[*]  = def_ssex_lim
    ENDELSE
  END
ENDCASE
;;  BEAM:
CASE bfunc[0] OF               ;;  Redefine output to proper/allowed format
  'MM'  :  BEGIN
    ;;  bi-Maxwellian beam
    IF (elec_on[0]) THEN def_b_param = def_bimax_eh ELSE def_b_param = def_bimax_ih
    ;;  Fix unused parameter
    def_binf[05].FIXED      = 1b
  END
  'KK'  :  BEGIN
    ;;  bi-kappa beam
    IF (elec_on[0]) THEN def_b_param = def_bikap_eh ELSE def_b_param = def_bikap_ih
    IF (exp_b_on[0]) THEN BEGIN
      ;;  Limit kappa values
      def_binf[05].LIMITED[*] = limd_exp_b
      def_binf[05].LIMITS[*]  = lims_exp_b
    ENDIF ELSE BEGIN
      ;;  Limit kappa values [use defaults]
      def_binf[05].LIMITED[*] = 1b
      def_binf[05].LIMITS[*]  = def_kapp_lim
    ENDELSE
  END
  'SS'  :  BEGIN
    ;;  bi-self-similar beam
    IF (elec_on[0]) THEN def_b_param = def_bi_ss_eh ELSE def_b_param = def_bi_ss_ih
    IF (exp_b_on[0]) THEN BEGIN
      ;;  Limit self-similar exponent values
      def_binf[05].LIMITED[*] = limd_exp_b
      def_binf[05].LIMITS[*]  = lims_exp_b
    ENDIF ELSE BEGIN
      ;;  Limit self-similar exponent values [use defaults]
      def_binf[05].LIMITED[*] = 1b
      def_binf[05].LIMITS[*]  = def_ssex_lim
    ENDELSE
  END
ENDCASE
;;  Redefine default parameter array
def_bparm               = def_b_param
def_param               = [def_c_param,def_h_param]
;;  Adjust parameters by velocity factor
def_param[1:4]         *= vfac[0]
def_param[7:10]        *= vfac[0]
def_bparm[1:4]         *= vfac[0]
;;----------------------------------------------------------------------------------------
;;  Check limits against default values
;;----------------------------------------------------------------------------------------
FOR j=0L, np[0] - 1L DO BEGIN
  IF (def_pinf[j].LIMITED[0]) THEN def_param[j] = def_param[j] > def_pinf[j].LIMITS[0]
  IF (def_pinf[j].LIMITED[1]) THEN def_param[j] = def_param[j] < def_pinf[j].LIMITS[1]
  IF (j LE 5) THEN BEGIN
    IF (def_binf[j].LIMITED[0]) THEN def_bparm[j] = def_bparm[j] > def_binf[j].LIMITS[0]
    IF (def_binf[j].LIMITED[1]) THEN def_bparm[j] = def_bparm[j] < def_binf[j].LIMITS[1]
  ENDIF
ENDFOR
;;  Define VALUE tag for PARINFO and BARINFO structures
def_pinf.VALUE          = def_param
def_binf.VALUE          = def_bparm
;;  Redefine ELECTRONS and IONS keywords for wrapping routine
electrons               = elec_on[0]
ions                    = ion__on[0]
;;----------------------------------------------------------------------------------------
;;  Return to user
;;----------------------------------------------------------------------------------------

RETURN,1b
END


;*****************************************************************************************
;
;  FUNCTION :   get_default_fitfunc_4_fitvdf2sumof2funcs.pro
;  PURPOSE  :   This is a subroutine of wrapper_fit_vdf_2_sumof2funcs.pro meant to return
;                 the fit function names and plot labels appropriate for the given input.
;
;  CALLED BY:   
;               wrapper_fit_vdf_2_sumof2funcs.pro
;
;  INCLUDES:
;               NA
;
;  CALLS:
;               NA
;
;  REQUIRES:    
;               1)  UMN Modified Wind/3DP IDL Libraries
;
;  INPUT:
;               NA
;
;  EXAMPLES:    
;               [calling sequence]
;               test = get_default_fitfunc_4_fitvdf2sumof2funcs(                        $
;                                          [,CFUNC=cfunc] [,HFUNC=hfunc] [,BFUNC=bfunc] $
;                                          [,FUNC_C=func_c] [,FUNC_H=func_h]            $
;                                          [,FIT_FUN=fit_fun] [,CORE_LABS=core_labs]    $
;                                          [,HALO_LABS=halo_labs] [,XYLAB_PRE=xylabpre] $
;                                          [,BEAM_LABS=beam_labs] [,FUNC_B=func_b]      )
;
;  KEYWORDS:    
;               ****************
;               ***  INPUTS  ***
;               ****************
;               CFUNC      :  Scalar [string] used to determine which model function to
;                               use for the core VDF
;                                 'MM'  :  bi-Maxwellian VDF
;                                 'KK'  :  bi-kappa VDF
;                                 'SS'  :  bi-self-similar VDF
;                               [Default = 'MM']
;               HFUNC      :  Scalar [string] used to determine which model function to
;                               use for the halo VDF
;                                 'MM'  :  bi-Maxwellian VDF
;                                 'KK'  :  bi-kappa VDF
;                                 'SS'  :  bi-self-similar VDF
;                               [Default = 'KK']
;               BFUNC      :  Scalar [string] used to determine which model function to
;                               use for the beam/strahl part of VDF
;                                 'MM'  :  bi-Maxwellian VDF
;                                 'KK'  :  bi-kappa VDF
;                                 'SS'  :  bi-self-similar VDF
;                               [Default = 'KK']
;               ****************
;               ***  OUTPUT  ***
;               ****************
;               CFUNC      :  Scalar [string] limited to one of the proper model functions
;                               to use for the core VDF (see allowed values above)
;               HFUNC      :  Scalar [string] limited to one of the proper model functions
;                               to use for the halo VDF (see allowed values above)
;               BFUNC      :  Scalar [string] limited to one of the proper model functions
;                               to use for the beam/strahl VDF (see allowed values above)
;               FUNC_C     :  Set to a named variable to return the default model
;                               function name to use for the core VDF
;                                 'MM'  -->  'bimaxwellian_fit'
;                                 'KK'  -->  'bikappa_fit'
;                                 'SS'  -->  'biselfsimilar_fit'
;               FUNC_H     :  Set to a named variable to return the default model
;                               function name to use for the halo VDF
;                                 'MM'  -->  'bimaxwellian_fit'
;                                 'KK'  -->  'bikappa_fit'
;                                 'SS'  -->  'biselfsimilar_fit'
;               FUNC_B     :  Set to a named variable to return the default model
;                               function name to use for the beam/strahl VDF
;                                 'MM'  -->  'bimaxwellian_fit'
;                                 'KK'  -->  'bikappa_fit'
;                                 'SS'  -->  'biselfsimilar_fit'
;               FIT_FUN    :  Set to a named variable to return the default model
;                               function name to use for the fitting part
;                                 'core_bm_halo_bm_fit'  :  core bi-Maxwellian + halo bi-Maxwellian
;                                 'core_kk_halo_kk_fit'  :  core bi-kappa + halo bi-kappa
;                                 'core_ss_halo_kk_fit'  :  core bi-self-similar + halo bi-kappa
;                                 'core_bm_halo_kk_fit'  :  core bi-Maxwellian + halo bi-kappa
;               CORE_LABS  :  Set to a named variable to return the default labels for
;                               the core fits outputs and plot legends
;               HALO_LABS  :  Set to a named variable to return the default labels for
;                               the halo fits outputs and plot legends
;               BEAM_LABS  :  Set to a named variable to return the default labels for
;                               the beam/strahl fits outputs and plot legends
;               XYLAB_PRE  :  Set to a named variable to return the default label
;                               prefixes for XYOUTS output
;
;   CHANGED:  1)  Finished writing beta version of main routine
;                                                                   [04/19/2018   v1.0.0]
;             2)  Added keywords BFUNC and BEAMP to main routine
;                   and added keywords BFUNC, FUNC_B, and BEAM_LABS
;                                                                   [04/20/2018   v1.0.1]
;             3)  Added keywords to main routine:  FIXED_[C,H,B], N[CORE,HALO,BEAM]_RAN,
;                   VTA[CORE,HALO,BEAM]RN, VTE[CORE,HALO,BEAM]RN, VOA[CORE,HALO,BEAM]RN,
;                   VOE[CORE,HALO,BEAM]RN, and EXP[CORE,HALO,BEAM]RN
;                                                                   [04/23/2018   v1.0.1]
;             4)  Cleaned up and updated Man. page
;                                                                   [04/24/2018   v1.0.2]
;             5)  Added keywords EMIN_CH and EMIN_B to main routine
;                                                                   [04/24/2018   v1.0.2]
;
;   NOTES:      
;               1)  VDF = velocity distribution function
;               2)  Routine will force and check if combination of CFUNC and HFUNC
;                     is an allowed pair.  If not, then the routine will redefine these
;                     to prevent breaking elsewhere.
;
;  REFERENCES:  
;               NA
;
;   CREATED:  04/17/2018
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  04/24/2018   v1.0.2
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************

FUNCTION get_default_fitfunc_4_fitvdf2sumof2funcs,CFUNC=cfunc,HFUNC=hfunc,BFUNC=bfunc, $    ;;  Inputs
                                   FUNC_C=func_c,FUNC_H=func_h,FIT_FUN=fit_fun,        $    ;;  Outputs
                                   CORE_LABS=core_labs,HALO_LABS=halo_labs,            $
                                   XYLAB_PRE=xylabpre,BEAM_LABS=beam_labs,             $
                                   FUNC_B=func_b

;;----------------------------------------------------------------------------------------
;;  Constants
;;----------------------------------------------------------------------------------------
f                       = !VALUES.F_NAN
d                       = !VALUES.D_NAN
;;----------------------------------------------------------------------------------------
;;  Defaults
;;----------------------------------------------------------------------------------------
;;  Default output strings when printing fit results
pre_pre_str             = ';;  '
chb_lab_str             = ['c','h','b']
c___lab_str             = [REPLICATE(chb_lab_str[0],5L),'']
h___lab_str             = [REPLICATE(chb_lab_str[1],5L),'']
b___lab_str             = [REPLICATE(chb_lab_str[2],5L),'']
fac_lab_st0             = ['par','per']
fac_lab_str             = ['',fac_lab_st0,fac_lab_st0,'']
pre_lab_str             = ['N_o','V_T','V_T','V_o','V_o','']
suf_lab_str             = [['     ','  ','  ','  ','  ']+'=  ','']
exp_lab_str             = ['','kappa','SS exp']
;;-------------------------------------------------------
;;  Define default labels
;;-------------------------------------------------------
;;  bi-Maxwellian core labels
core_bm_lab             = pre_pre_str[0]+pre_lab_str+c___lab_str+fac_lab_str+suf_lab_str
;;  bi-kappa core labels
core_kk_lab             = pre_pre_str[0]+pre_lab_str+c___lab_str+fac_lab_str+suf_lab_str
core_kk_lab[5]          = core_kk_lab[5]+exp_lab_str[1]+chb_lab_str[0]+'   =  '
;;  bi-self-similar core labels
core_ss_lab             = pre_pre_str[0]+pre_lab_str+c___lab_str+fac_lab_str+suf_lab_str
core_ss_lab[5]          = core_ss_lab[5]+exp_lab_str[2]+chb_lab_str[0]+'  =  '
;;  bi-Maxwellian halo labels
halo_bm_lab             = pre_pre_str[0]+pre_lab_str+h___lab_str+fac_lab_str+suf_lab_str
;;  bi-kappa halo labels
halo_kk_lab             = pre_pre_str[0]+pre_lab_str+h___lab_str+fac_lab_str+suf_lab_str
halo_kk_lab[5]          = halo_kk_lab[5]+exp_lab_str[1]+chb_lab_str[1]+'   =  '
;;  bi-self-similar halo labels
halo_ss_lab             = pre_pre_str[0]+pre_lab_str+h___lab_str+fac_lab_str+suf_lab_str
halo_ss_lab[5]          = halo_ss_lab[5]+exp_lab_str[2]+chb_lab_str[1]+'  =  '
;;  bi-Maxwellian beam labels
beam_bm_lab             = pre_pre_str[0]+pre_lab_str+b___lab_str+fac_lab_str+suf_lab_str
;;  bi-kappa beam labels
beam_kk_lab             = pre_pre_str[0]+pre_lab_str+b___lab_str+fac_lab_str+suf_lab_str
beam_kk_lab[5]          = beam_kk_lab[5]+exp_lab_str[1]+chb_lab_str[2]+'   =  '
;;  bi-self-similar beam labels
beam_ss_lab             = pre_pre_str[0]+pre_lab_str+b___lab_str+fac_lab_str+suf_lab_str
beam_ss_lab[5]          = beam_ss_lab[5]+exp_lab_str[2]+chb_lab_str[2]+'  =  '
;;----------------------------------------------------------------------------------------
;;  Check keywords with default options
;;----------------------------------------------------------------------------------------
;;  Check CFUNC
testc                   = (SIZE(cfunc,/TYPE) EQ 7)
IF (testc[0]) THEN cf = STRUPCASE(STRMID(cfunc[0],0,2)) ELSE cf = 'MM'
CASE cf[0] OF
  'MM'  :  core_labs = core_bm_lab ;;  Do nothing
  'KK'  :  core_labs = core_kk_lab ;;  Do nothing
  'SS'  :  core_labs = core_ss_lab ;;  Do nothing
  ELSE  :  BEGIN
    cf        = 'MM'      ;;  Force definition as user input was invalid!
    core_labs = core_bm_lab
  END
ENDCASE
;;  Check HFUNC
test                    = (SIZE(hfunc,/TYPE) EQ 7)
IF (test[0]) THEN BEGIN
  hf = STRUPCASE(STRMID(hfunc[0],0,2))
  CASE hf[0] OF
    'MM'  :  BEGIN
      ;;  bi-Maxwellian halo
      fit_fun     = 'core_bm_halo_bm_fit'
      func_c      = 'bimaxwellian_fit'
      func_h      = 'bimaxwellian_fit'
      halo_labs   = halo_bm_lab
      xylabpre    = ['Bi-Max.','Bi-Max.']
      ;;  Redefine CFUNC and HFUNC
      cfunc       = 'MM'
      hfunc       = 'MM'
    END
    'KK'  :  BEGIN
      ;;  bi-kappa halo
      CASE cf[0] OF
        'MM'  :  fit_fun     = 'core_bm_halo_kk_fit'
        'KK'  :  fit_fun     = 'core_kk_halo_kk_fit'
        'SS'  :  fit_fun     = 'core_ss_halo_kk_fit'
        ELSE  :  BEGIN
          ;;  Default:  sum of bi-Maxwellian core with bi-kappa halo
          fit_fun     = 'core_bm_halo_kk_fit'
        END
      ENDCASE
      func_c      = (['bimaxwellian_fit','bikappa_fit','biselfsimilar_fit'])[(WHERE(cf[0] EQ ['MM','KK','SS']))[0]]
      func_h      = 'bikappa_fit'
      halo_labs   = halo_kk_lab
      xyl0        = (['Bi-Max.','Bi-kappa','Bi-SS'])[(WHERE(cf[0] EQ ['MM','KK','SS']))[0]]
      xylabpre    = [xyl0[0],'Bi-kappa']
      ;;  Redefine CFUNC and HFUNC
      temp        = STRMID(fit_fun[0],5L,2L)
      cfunc       = (['MM','KK','SS'])[(WHERE(temp[0] EQ ['bm','kk','ss']))[0]]
      hfunc       = 'KK'
    END
    ELSE  :  BEGIN
      ;;  Default:  sum of bi-Maxwellian core with bi-kappa halo
      fit_fun     = 'core_bm_halo_kk_fit'
      func_c      = 'bimaxwellian_fit'
      func_h      = 'bikappa_fit'
      halo_labs   = halo_kk_lab
      xylabpre    = ['Bi-Max.','Bi-kappa']
      ;;  Redefine CFUNC and HFUNC
      cfunc       = 'MM'
      hfunc       = 'KK'
    END
  ENDCASE
ENDIF ELSE BEGIN
  ;;  Default:  Halo is a bi-kappa
  hf          = 'KK'
  fit_fun     = 'core_bm_halo_kk_fit'
  func_c      = 'bimaxwellian_fit'
  func_h      = 'bikappa_fit'
  halo_labs   = halo_kk_lab
  xylabpre    = ['Bi-Max.','Bi-kappa']
  ;;  Redefine CFUNC and HFUNC
  cfunc       = 'MM'
  hfunc       = 'KK'
ENDELSE
;;  Check BFUNC
test                    = (SIZE(bfunc,/TYPE) EQ 7)
IF (test[0]) THEN BEGIN
  bf = STRUPCASE(STRMID(bfunc[0],0,2))
  CASE bf[0] OF
    'MM'  :  BEGIN
      ;;  bi-Maxwellian beam
      func_b      = 'bimaxwellian_fit'
      beam_labs   = beam_bm_lab
      xylabpre    = [xylabpre,'Bi-Max.']
      ;;  Redefine BFUNC
      bfunc       = 'MM'
    END
    'KK'  :  BEGIN
      ;;  bi-kappa beam
      func_b      = 'bikappa_fit'
      beam_labs   = beam_kk_lab
      xylabpre    = [xylabpre,'Bi-kappa']
      ;;  Redefine BFUNC
      bfunc       = 'KK'
    END
    'SS'  :  BEGIN
      ;;  bi-self-similar beam
      func_b      = 'biselfsimilar_fit'
      beam_labs   = beam_ss_lab
      xylabpre    = [xylabpre,'Bi-SS']
      ;;  Redefine BFUNC
      bfunc       = 'SS'
    END
    ELSE  :  BEGIN
      ;;  Default:  bi-kappa beam
      func_b      = 'bikappa_fit'
      beam_labs   = beam_kk_lab
      xylabpre    = [xylabpre,'Bi-kappa']
      ;;  Redefine BFUNC
      bfunc       = 'KK'
    END
  ENDCASE
ENDIF ELSE BEGIN
  ;;  Default:  Beam is a bi-kappa
  bf          = 'KK'
  func_b      = 'bikappa_fit'
  beam_labs   = beam_kk_lab
  xylabpre    = [xylabpre,'Bi-kappa']
  ;;  Redefine BFUNC
  bfunc       = 'KK'
ENDELSE
;;----------------------------------------------------------------------------------------
;;  Return to user
;;----------------------------------------------------------------------------------------

RETURN,1b
END


;+
;*****************************************************************************************
;
;  PROCEDURE:   wrapper_fit_vdf_2_sumof2funcs.pro
;  PURPOSE  :   This is a wrapping routine that plots and fits input velocity
;                 distributions to the sum of two model functions and then replots the
;                 results.  The routine returns a structure to the user for later use,
;                 if so desired.
;
;  CALLED BY:   
;               NA
;
;  INCLUDES:
;               test_range_keys_4_fitvdf2sumof2funcs.pro
;               get_default_pinfo_4_fitvdf2sumof2funcs.pro
;               get_default_fitfunc_4_fitvdf2sumof2funcs.pro
;
;  CALLS:
;               is_a_number.pro
;               is_a_3_vector.pro
;               lbw_window.pro
;               get_default_pinfo_4_fitvdf2sumof2funcs.pro
;               get_default_fitfunc_4_fitvdf2sumof2funcs.pro
;               test_range_keys_4_fitvdf2sumof2funcs.pro
;               sign.pro
;               unit_vec.pro
;               struct_value.pro
;               str_element.pro
;               test_file_path_format.pro
;               general_vdf_contour_plot.pro
;               fill_range.pro
;               energy_to_vel.pro
;               mpfit2dfun.pro
;               core_bm_halo_bm_fit.pro
;               core_bm_halo_kk_fit.pro
;               core_kk_halo_kk_fit.pro
;               core_ss_halo_kk_fit.pro
;               bimaxwellian_fit.pro
;               bikappa_fit.pro
;               biselfsimilar_fit.pro
;               num2int_str.pro
;               find_1d_cuts_2d_dist.pro
;               popen.pro
;               pclose.pro
;
;  REQUIRES:    
;               1)  UMN Modified Wind/3DP IDL Libraries
;
;  INPUT:
;               VDF      :  [N]-Element [float/double] array defining particle velocity
;                             distribution function (VDF) in units of phase space density
;                             [e.g., # s^(+3) km^(-3) cm^(-3)]
;               VELXYZ   :  [N,3]-Element [float/double] array defining the particle
;                             velocity 3-vectors for each element of VDF
;                             [e.g., km/s]
;
;  EXAMPLES:    
;               [calling sequence]
;               wrapper_fit_vdf_2_sumof2funcs,vdf,velxyz [,VFRAME=vframe] [,VEC1=vec1]                          $
;                                          [,VEC2=vec2] [,COREP=corep] [,HALOP=halop]                           $
;                                          [,CFUNC=cfunc] [,HFUNC=hfunc]                                        $
;                                          [,RMSTRAHL=rmstrahl] [,V1ISB=v1isb]                                  $
;                                          [,ELECTRONS=electrons] [,IONS=ions]                                  $
;                                          [,SAVEF=savef] [,FILENAME=filename]                                  $
;                                          [,BEAMP=beamp] [,BFUNC=bfunc] [,ONLY_TOT=only_tot]                   $
;                                          [,FIXED_C=fixed_c] [,FIXED_H=fixed_h] [,FIXED_B=fixed_b]             $
;                                          [,NCORE_RAN=ncore_ran] [,NHALO_RAN=nhalo_ran] [,NBEAM_RAN=nbeam_ran] $
;                                          [,VTACORERN=vtacorern] [,VTAHALORN=vtahalorn] [,VTABEAMRN=vtabeamrn] $
;                                          [,VTECORERN=vtecorern] [,VTEHALORN=vtehalorn] [,VTEBEAMRN=vtebeamrn] $
;                                          [,VOACORERN=voacorern] [,VOAHALORN=voahalorn] [,VOABEAMRN=voabeamrn] $
;                                          [,VOECORERN=voecorern] [,VOEHALORN=voehalorn] [,VOEBEAMRN=voebeamrn] $
;                                          [,EXPCORERN=expcorern] [,EXPHALORN=exphalorn] [,EXPBEAMRN=expbeamrn] $
;                                          [,EMIN_CH=emin_ch] [,EMIN_B=emin_b]                                  $
;                                          [,EMAX_CH=emax_ch] [,EMAX_B=emax_b]                                  $
;                                          [,FTOL=ftol] [,GTOL=gtol] [,XTOL=xtol] [,USE_MM=use_mm]              $
;                                          [,USE1C4WGHT=use1c4wght] [,NO_WGHT=no_wght] [,/PLOT_BOTH]            $
;                                          [,POISSON=poisson] [,NB_LT_NH=nb_lt_nh] [,/NOUSECTAB]                $
;                                          [,OUTSTRC=out_struc] [,_EXTRA=extrakey]
;
;  KEYWORDS:    
;               ***  INPUTS  ***
;               !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
;               ***  [all of the following have default settings]  ***
;               !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
;               VFRAME      :  [3]-Element [float/double] array defining the 3-vector
;                                velocity of the K'-frame relative to the K-frame [km/s]
;                                to use to transform the velocity distribution into the
;                                bulk flow reference frame
;                                [ Default = [10,0,0] ]
;               VEC1        :  [3]-Element vector to be used for "parallel" direction in
;                                a 3D rotation of the input data
;                                [e.g. see rotate_3dp_structure.pro]
;                                [ Default = [1.,0.,0.] ]
;               VEC2        :  [3]--Element vector to be used with VEC1 to define a 3D
;                                rotation matrix.  The new basis will have the following:
;                                  X'  :  parallel to VEC1
;                                  Z'  :  parallel to (VEC1 x VEC2)
;                                  Y'  :  completes the right-handed set
;                                [ Default = [0.,1.,0.] ]
;               COREP       :  [6]-Element [numeric] array where each element is defined
;                                by the following quantities:
;                                PARAM[0]  = Core Number Density [cm^(-3)]
;                                PARAM[1]  = Core Parallel Thermal Speed [km/s]
;                                PARAM[2]  = Core Perpendicular Thermal Speed [km/s]
;                                PARAM[3]  = Core Parallel Drift Speed [km/s]
;                                PARAM[4]  = Core Perpendicular Drift Speed [km/s]
;                                PARAM[5]  = Core kappa, self-similar exponent, or not used
;                              If set, the routine will output 1D cuts of the model defined
;                                by the CFUNC keyword setting
;                                [Default = See code for default values]
;               HALOP       :  [6]-Element [numeric] array where each element is defined
;                                by the following quantities:
;                                PARAM[6]  = Halo Number Density [cm^(-3)]
;                                PARAM[7]  = Halo Parallel Thermal Speed [km/s]
;                                PARAM[8]  = Halo Perpendicular Thermal Speed [km/s]
;                                PARAM[9]  = Halo Parallel Drift Speed [km/s]
;                                PARAM[10] = Halo Perpendicular Drift Speed [km/s]
;                                PARAM[11] = Halo kappa, self-similar exponent, or not used
;                              If set, the routine will output 1D cuts of the model defined
;                                by the HFUNC keyword setting
;                                [Default = See code for default values]
;               CFUNC       :  Scalar [string] used to determine which model function to
;                                use for the core VDF
;                                  'MM'  :  bi-Maxwellian VDF
;                                  'KK'  :  bi-kappa VDF
;                                  'SS'  :  bi-self-similar VDF
;                                [Default = 'MM']
;               HFUNC       :  Scalar [string] used to determine which model function to
;                                use for the halo VDF
;                                  'MM'  :  bi-Maxwellian VDF
;                                  'KK'  :  bi-kappa VDF
;                                  'SS'  :  bi-self-similar VDF
;                                [Default = 'KK']
;               RMSTRAHL    :  ***  Still Testing  ***
;                              Scalar [structure] definining the direction and angular
;                                range about defined direction to remove from data when
;                                considering which points that MPFIT.PRO will use in
;                                the fitting process.  The structure must have the
;                                following formatted tags:
;                                  'DIR'  :  [3]-Element [numeric] array defining the
;                                              direction of the strahl (e.g., either
;                                              parallel or anti-parallel to Bo in the
;                                              anti-sunward direction)
;                                              [Default = -1d0*VEC1]
;                                  'ANG'  :  Scalar [numeric] defining the angle [deg] about
;                                              DIR to ignore when fitting the data, i.e.,
;                                              this is the half-angle of the cone about
;                                              DIR that will be excluded
;                                              [Default = 45 degrees]
;                                  'S_L'  :  Scalar [numeric] defining the minimum cutoff
;                                              speed [km/s] below which the data will still
;                                              be included in the fit
;                                              [Default = 1000 km/s]
;               V1ISB       :  Set to a positive or negative unity to indicate whether
;                                the strahl/beam direction is parallel or anti-parallel,
;                                respectively, to the quasi-static magnetic field defined
;                                by VEC1.  If set, the routine will construct the RMSTRAHL
;                                structure with the default values for the tags ANG and
;                                E_L and the DIR tag will be set to V1ISB[0]*VEC1.
;                                [Default = FALSE]
;               _EXTRA      :  Other keywords accepted by general_vdf_contour_plot.pro
;               ELECTRONS   :  If set, routine uses parameters appropriate for non-
;                                relativistic electron velocity distributions
;                                [Default = TRUE]
;               IONS        :  If set, routine uses parameters appropriate for non-
;                                relativistic proton velocity distributions
;                                [Default = FALSE]
;               SAVEF       :  If set, routine will save the final plot to a PS file
;                                [Default = FALSE]
;               FILENAME    :  Scalar [string] defining the file name for the saved PS
;                                file.  Note that the format of the file name must be
;                                such that IDL_VALIDNAME.PRO returns a non-null string
;                                with at least the CONVERT_ALL keyword set.
;                                [Default = 'vdf_fit_plot_0']
;               BFUNC       :  Scalar [string] used to determine which model function to
;                                use for the beam/strahl part of VDF
;                                  'MM'  :  bi-Maxwellian VDF
;                                  'KK'  :  bi-kappa VDF
;                                  'SS'  :  bi-self-similar VDF
;                                [Default = 'KK']
;               BEAMP       :  [6]-Element [numeric] array where each element is defined
;                                by the following quantities:
;                                BPARM[0]  = Beam Number Density [cm^(-3)]
;                                BPARM[1]  = Beam Parallel Thermal Speed [km/s]
;                                BPARM[2]  = Beam Perpendicular Thermal Speed [km/s]
;                                BPARM[3]  = Beam Parallel Drift Speed [km/s]
;                                BPARM[4]  = Beam Perpendicular Drift Speed [km/s]
;                                BPARM[5]  = Beam kappa, self-similar exponent, or not used
;                              If set, the routine will output 1D cuts of the model defined
;                                by the BFUNC keyword setting
;                                [Default = starts with similar values as halo]
;               ONLY_TOT    :  If set, routine will only plot the sum of all the model fit
;                                cuts instead of each individually
;                                [Default = FALSE]
;               FIXED_C     :  [6]-Element array containing ones for each element of
;                                COREP the user does NOT wish to vary (i.e., if FIXED_C[0]
;                                is = 1, then COREP[0] will not change when calling
;                                MPFITFUN.PRO).
;                                [Default  :  All elements = 0]
;               FIXED_H     :  [6]-Element array containing ones for each element of
;                                HALOP the user does NOT wish to vary (i.e., if FIXED_H[2]
;                                is = 1, then HALOP[2] will not change when calling
;                                MPFITFUN.PRO).
;                                [Default  :  All elements = 0]
;               FIXED_B     :  [6]-Element array containing ones for each element of
;                                BEAMP the user does NOT wish to vary (i.e., if FIXED_B[3]
;                                is = 1, then BEAMP[3] will not change when calling
;                                MPFITFUN.PRO).
;                                [Default  :  All elements = 0]
;               NCORE_RAN   :  [4]-Element [numeric] array defining the range of allowed
;                                values to use for the core number density or PARAM[0].
;                                Note, if this keyword is set, it is equivalent to telling
;                                the routine that N_core should be limited by these
;                                bounds.  Setting this keyword will define:
;                                  PARINFO[0].LIMITED[*] = BYTE(NCORE_RAN[0:1])
;                                  PARINFO[0].LIMITS[*]  = NCORE_RAN[2:3]
;               NHALO_RAN   :  Same as NCORE_RAN but for PARAM[6] and PARINFO[6].
;               NBEAM_RAN   :  Same as NCORE_RAN but for BPARM[0] and BARINFO[0].
;               VTACORERN   :  [4]-Element [numeric] array defining the range of allowed
;                                values to use for the core parallel thermal speed or
;                                PARAM[1].  Note, if this keyword is set, it is
;                                equivalent to telling the routine that V_Tcpara should be
;                                limited by these bounds.  Setting this keyword will
;                                define:
;                                  PARINFO[1].LIMITED[*] = BYTE(VTACORERN[0:1])
;                                  PARINFO[1].LIMITS[*]  = VTACORERN[2:3]
;               VTAHALORN   :  Same as VTACORERN but for PARAM[7] and PARINFO[7].
;               VTABEAMRN   :  Same as VTACORERN but for BPARM[1] and BARINFO[1].
;               VTECORERN   :  [4]-Element [numeric] array defining the range of allowed
;                                values to use for the core perpendicular thermal speed
;                                or PARAM[2].  Note, if this keyword is set, it is
;                                equivalent to telling the routine that V_Tcperp should be
;                                limited by these bounds.  Setting this keyword will
;                                define:
;                                  PARINFO[2].LIMITED[*] = BYTE(VTECORERN[0:1])
;                                  PARINFO[2].LIMITS[*]  = VTECORERN[2:3]
;               VTEHALORN   :  Same as VTECORERN but for PARAM[8] and PARINFO[8].
;               VTEBEAMRN   :  Same as VTECORERN but for BPARM[2] and BARINFO[2].
;               VOACORERN   :  [4]-Element [numeric] array defining the range of allowed
;                                values to use for the core parallel drift speed or
;                                PARAM[3].  Note, if this keyword is set, it is
;                                equivalent to telling the routine that V_ocpara should be
;                                limited by these bounds.  Setting this keyword will
;                                define:
;                                  PARINFO[3].LIMITED[*] = BYTE(VOACORERN[0:1])
;                                  PARINFO[3].LIMITS[*]  = VOACORERN[2:3]
;               VOAHALORN   :  Same as VOACORERN but for PARAM[9] and PARINFO[9].
;               VOABEAMRN   :  Same as VOACORERN but for BPARM[3] and BARINFO[3].
;               VOECORERN   :  [4]-Element [numeric] array defining the range of allowed
;                                values to use for the core perpendicular drift speed
;                                or PARAM[4].  Note, if this keyword is set, it is
;                                equivalent to telling the routine that V_ocperp should be
;                                limited by these bounds.  Setting this keyword will
;                                define:
;                                  PARINFO[4].LIMITED[*] = BYTE(VOECORERN[0:1])
;                                  PARINFO[4].LIMITS[*]  = VOECORERN[2:3]
;               VOEHALORN   :  Same as VOECORERN but for PARAM[10] and PARINFO[10].
;               VOEBEAMRN   :  Same as VOECORERN but for BPARM[4] and BARINFO[4].
;               EXPCORERN   :  [4]-Element [numeric] array defining the range of allowed
;                                values to use for the exponent parameter or PARAM[5].
;                                Note, if this keyword is set, it is equivalent to
;                                telling the routine that V_ocperp should be limited by
;                                these bounds.  Setting this keyword will define:
;                                  PARINFO[5].LIMITED[*] = BYTE(EXPCORERN[0:1])
;                                  PARINFO[5].LIMITS[*]  = EXPCORERN[2:3]
;               EXPHALORN   :  Same as EXPCORERN but for PARAM[11] and PARINFO[11].
;               EXPBEAMRN   :  Same as EXPCORERN but for BPARM[5] and BARINFO[5].
;               EMIN_CH     :  Scalar [numeric] defining the minimum energy [eV] to
;                                consider during the fitting process (only alters the
;                                WEIGHTS parameter) for the core+halo distribution
;                                [Default = 0]
;               EMIN_B      :  Scalar [numeric] defining the minimum energy [eV] to
;                                consider during the fitting process (only alters the
;                                WEIGHTS parameter) for the beam distribution
;                                [Default = 0]
;               EMAX_CH     :  Scalar [numeric] defining the maximum energy [eV] to
;                                consider during the fitting process (only alters the
;                                WEIGHTS parameter) for the core+halo distribution
;                                [Default = 10^30]
;               EMAX_B      :  Scalar [numeric] defining the maximum energy [eV] to
;                                consider during the fitting process (only alters the
;                                WEIGHTS parameter) for the beam distribution
;                                [Default = 10^30]
;               FTOL        :  Scalar [double] definining the maximum values in both
;                                the actual and predicted relative reductions in the sum
;                                squares are at most FTOL at termination.  Therefore, FTOL
;                                measures the relative error desired in the sum of
;                                squares.
;                                [Default  :  1d-14 ]
;               GTOL        :  Scalar [double] definining the value of the absolute cosine
;                                of the angle between fvec and any column of the jacobian
;                                allowed before terminating the fit calculation.
;                                Therefore, GTOL measures the orthogonality desired
;                                between the function vector and the columns of the
;                                jacobian.
;                                [Default  :  1d-14 ]
;               XTOL        :  Scalar [double] definining the maximum relative error
;                                between two consecutive iterates to allow before
;                                terminating the fit calculation.  Thus, XTOL measures
;                                the relative error desired in the approximate solution.
;                                [Default  :  1d-12 ]
;               USE1C4WGHT  :  If set, routine will use the one-count levels for weights
;                                instead of 1% of the data
;                                [Default  :  FALSE]
;               NO_WGHT     :  If set, routine will use a value of 1.0 for all weights
;                                instead of 1% of the data
;                                [Default  :  FALSE]
;               PLOT_BOTH   :  If set, routine will plot both forms of output where one
;                                shows only the sum of all fits and the other shows each
;                                1D fit line cut individually.  Note that if set, this
;                                keyword will take precedence over the ONLY_TOT setting.
;                                [Default  :  FALSE]
;               POISSON     :  [N]-Element [float/double] array defining the Poisson
;                                counting statistics of the input VDF in units of
;                                phase space density.  Note the units and size must
;                                match that of the VDF input for this to be meaningful.
;                                [e.g., # s^(+3) km^(-3) cm^(-3)]
;                                [Default  :  FALSE]
;               NB_LT_NH    :  If set, routine will redefine the LIMITS values of the
;                                PARINFO structure for the beam fit so as to keep the
;                                beam density at or below the halo density.  For the
;                                solar wind electrons, it is generally assumed that the
;                                strahl density is less than the halo at 1 AU, so one
;                                may find setting this keyword to be the physically
;                                significant approach.  It may also hinder a good fit
;                                and it should be noted that the strahl having a smaller
;                                density than the halo is largely an assumption that
;                                has been imposed upon the fitting routines in past
;                                studies, not necessarily a rigorous, physically
;                                consistent requirement.
;               NOUSECTAB   :  If set, routine will not force the use of its default
;                                color table setting of IDL's color table 33
;                                [Default  :  FALSE]
;               USE_MM      :  If set, routine will convert input speeds/velocities to
;                                Mm from km
;                                ***  Still testing  ***
;                                [Default = FALSE]
;               ***  OUTPUT  ***
;               !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
;               ***  [all the following changed on output]  ***
;               !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
;               OUTSTRC     :  Set to a named variable to return all the relevant data
;                                used to create the contour plot and cuts of the VDF
;
;   CHANGED:  1)  Continued to write routine
;                                                                   [04/10/2018   v1.0.0]
;             2)  Continued to write routine
;                 [added keywords: ELECTRONS and IONS]
;                 [now includes get_default_pinfo_4_fitvdf2sumof2funcs.pro]
;                 [now includes get_default_fitfunc_4_fitvdf2sumof2funcs.pro]
;                                                                   [04/17/2018   v1.0.0]
;             3)  Continued to write routine
;                 [cleaned up and updated Man. page]
;                                                                   [04/17/2018   v1.0.0]
;             4)  Continued to write routine
;                 [added keywords: SAVE and FILENAME]
;                 [now calls test_file_path_format.pro, popen.pro, and pclose.pro]
;                                                                   [04/18/2018   v1.0.0]
;             5)  Continued to write routine
;                 [changed LIMITS for V1ISB usage and updated Man. page]
;                 [now outputs fit status information too]
;                 [now calls fill_range.pro, num2int_str.pro]
;                                                                   [04/19/2018   v1.0.0]
;             6)  Finished writing beta version of routine
;                                                                   [04/19/2018   v1.0.0]
;             7)  Altered format of output structure
;                                                                   [04/19/2018   v1.0.1]
;             8)  Added keywords:  BFUNC and BEAMP
;                   and added functionality to handle new keywords
;                                                                   [04/20/2018   v1.1.0]
;             8)  Added keyword:  ONLY_TOT
;                                                                   [04/20/2018   v1.1.1]
;             9)  Added limits for number densities
;                   and changed default settings for FTOL, GTOL, and XTOL for
;                   MPFIT.PRO input
;                                                                   [04/20/2018   v1.1.2]
;            10)  Added keywords:  FIXED_[C,H,B], N[CORE,HALO,BEAM]_RAN,
;                   VTA[CORE,HALO,BEAM]RN, VTE[CORE,HALO,BEAM]RN, VOA[CORE,HALO,BEAM]RN,
;                   VOE[CORE,HALO,BEAM]RN, and EXP[CORE,HALO,BEAM]RN
;                   and now includes test_range_keys_4_fitvdf2sumof2funcs.pro
;                   and now calls lbw_mpfit2dfun.pro instead of mpfit2dfun.pro
;                                                                   [04/23/2018   v1.2.0]
;            11)  Cleaned up and addressed bug/issue that occurs if explicit derivatives
;                   are used instead of numerical ones
;                                                                   [04/23/2018   v1.2.1]
;            12)  Removed offset in parameters and input data to reduce dynamic range of
;                   values in PARAM and now calls mpfit2dfun.pro again
;                                                                   [04/24/2018   v1.2.2]
;            13)  Cleaned up and updated Man. page
;                                                                   [04/24/2018   v1.2.3]
;            14)  Added keywords:  EMIN_CH and EMIN_B
;                   and now calls energy_to_vel.pro
;                                                                   [04/24/2018   v1.2.4]
;            15)  Added checks on IDL version number to avoid errors caused by using
;                   NAN keyword in INTERPOL.PRO, which was not introduced until version 8
;                                                                   [04/28/2018   v1.2.5]
;            16)  Removed the use of NaNs for errors on input to MPFIT routines
;                                                                   [04/30/2018   v1.2.6]
;            17)  Tried adding some rules to prevent MPFIT from failing so easily due
;                   to a numerical instability
;                                                                   [05/02/2018   v1.2.7]
;            18)  Added keywords:  EMAX_CH, EMAX_B, FTOL, GTOL, and XTOL
;                                                                   [05/03/2018   v1.2.8]
;            19)  Added keywords:  USE1C4WGHT and NO_WGHT
;                                                                   [05/07/2018   v1.2.9]
;            20)  Added keyword:  PLOT_BOTH
;                                                                   [05/07/2018   v1.3.0]
;            21)  Added a check on the quality of the beam fit results
;                                                                   [05/07/2018   v1.3.1]
;            22)  Added keyword:  POISSON
;                                                                   [05/07/2018   v1.3.2]
;            23)  Use of Poisson statistics works so no longer need to check the quality
;                   of the beam fit and cleaned up
;                                                                   [05/08/2018   v1.3.3]
;            24)  Added keyword:  NB_LT_NH
;                                                                   [05/08/2018   v1.3.4]
;            25)  Increased line and character thickness when saving to PS files
;                                                                   [05/23/2018   v1.3.5]
;            26)  Fixed a bug that occurred when the use of the strahl removal keyword
;                   conflicted with the parallel core drift speed
;                                                                   [05/24/2018   v1.3.6]
;            27)  Fixed an issue for inputs where zeros exist causing a bad estimate of
;                   the offsets
;                                                                   [05/25/2018   v1.3.7]
;            28)  Removed some repeated lines of code and now calculates energies
;                   regardless of the EMIN_* or EMAX_* keyword settings and
;                   now structures track the number of times the routine tried to fit
;                   and changed some of the color schemes by use of NOUSECTAB keyword
;                                                                   [05/30/2018   v1.3.8]
;            29)  Fixed a typo in the use of keywords for energy_to_vel.pro
;                   and cleaned up some things
;                                                                   [05/31/2018   v1.3.9]
;            30)  Added keyword:  USE_MM
;                                                                   [06/18/2018   v1.4.0]
;
;   NOTES:      
;               0)  ***  Do not directly set the RMSTRAHL keyword  ***
;               1)  AUTODERIVATIVE=0 overrides any setting of MPSIDE for all parameters
;               2)  To use explicit derivatives, set AUTODERIVATIVE=0 or set MPSIDE=3 for
;                     each parameter for which the user wishes to use explicit
;                     derivatives.
;               3)  **  Do NOT set PARINFO, let the routine set it up for you  **
;               ******************************************
;               ***  Do not set this keyword yourself  ***
;               ******************************************
;               PARINFO  :  [12]-Element array [structure] used by MPFIT.PRO
;                             where the i-th contains the following tags and
;                             definitions:
;                             VALUE    =  Scalar [float/double] value defined by
;                                           PARAM[i].  The user need not set this value.
;                                           [Default = PARAM[i] ]
;                             FIXED    =  Scalar [boolean] value defining whether to
;                                           allow MPFIT.PRO to vary PARAM[i] or not
;                                           TRUE   :  parameter constrained
;                                                     (i.e., no variation allowed)
;                                           FALSE  :  parameter unconstrained
;                             LIMITED  =  [2]-Element [boolean] array defining if the
;                                           lower/upper bounds defined by LIMITS
;                                           are imposed(TRUE) otherwise it has no effect
;                                           [Default = FALSE]
;                             LIMITS   =  [2]-Element [float/double] array defining the
;                                           [lower,upper] bounds on PARAM[i].  Both
;                                           LIMITED and LIMITS must be given together.
;                                           [Default = [0.,0.] ]
;                             TIED     =  Scalar [string] that mathematically defines
;                                           how PARAM[i] is forcibly constrained.  For
;                                           instance, assume that PARAM[0] is always
;                                           equal to 2 Pi times PARAM[1], then one would
;                                           define the following:
;                                             PARINFO[0].TIED = '2 * !DPI * P[1]'
;                                           [Default = '']
;                             MPSIDE   =  Scalar value with the following
;                                           consequences:
;                                            0 : 1-sided deriv. computed automatically
;                                            1 : 1-sided deriv. (f(x+h) - f(x)  )/h
;                                           -1 : 1-sided deriv. (f(x)   - f(x-h))/h
;                                            2 : 2-sided deriv. (f(x+h) - f(x-h))/(2*h)
;                                            3 : explicit deriv. used for this parameter
;                                           See MPFIT.PRO and MPFITFUN.PRO for more...
;                                           [Default = 3]
;               4)  Fit Status Interpretations
;                     > 0 = success
;                     -18 = a fatal execution error has occurred.  More information may
;                           be available in the ERRMSG string.
;                     -16 = a parameter or function value has become infinite or an
;                           undefined number.  This is usually a consequence of numerical
;                           overflow in the user's model function, which must be avoided.
;                     -15 to -1 = 
;                           these are error codes that either MYFUNCT or ITERPROC may
;                           return to terminate the fitting process (see description of
;                           MPFIT_ERROR common below).  If either MYFUNCT or ITERPROC
;                           set ERROR_CODE to a negative number, then that number is
;                           returned in STATUS.  Values from -15 to -1 are reserved for
;                           the user functions and will not clash with MPFIT.
;                     0 = improper input parameters.
;                     1 = both actual and predicted relative reductions in the sum of
;                           squares are at most FTOL.
;                     2 = relative error between two consecutive iterates is at most XTOL
;                     3 = conditions for STATUS = 1 and STATUS = 2 both hold.
;                     4 = the cosine of the angle between fvec and any column of the
;                           jacobian is at most GTOL in absolute value.
;                     5 = the maximum number of iterations has been reached
;                           (may indicate failure to converge)
;                     6 = FTOL is too small. no further reduction in the sum of squares
;                           is possible.
;                     7 = XTOL is too small. no further improvement in the approximate
;                           solution x is possible.
;                     8 = GTOL is too small. fvec is orthogonal to the columns of the
;                           jacobian to machine precision.
;               5)  MPFIT routines can be found at:
;                     http://cow.physics.wisc.edu/~craigm/idl/idl.html
;               6)  Definition of WEIGHTS keyword input for MPFIT routines
;                     Array of weights to be used in calculating the chi-squared
;                     value.  If WEIGHTS is specified then the ERR parameter is
;                     ignored.  The chi-squared value is computed as follows:
;
;                         CHISQ = TOTAL( ( Y - MYFUNCT(X,P) )^2 * ABS(WEIGHTS) )
;
;                     where ERR = the measurement error (yerr variable herein).
;
;                     Here are common values of WEIGHTS for standard weightings:
;                       1D/ERR^2 - Normal or Gaussian weighting
;                       1D/Y     - Poisson weighting (counting statistics)
;                       1D       - Unweighted
;
;                     NOTE: the following special cases apply:
;                       -- if WEIGHTS is zero, then the corresponding data point
;                            is ignored
;                       -- if WEIGHTS is NaN or Infinite, and the NAN keyword is set,
;                            then the corresponding data point is ignored
;                       -- if WEIGHTS is negative, then the absolute value of WEIGHTS
;                            is used
;               7)  See also:  biselfsimilar_fit.pro, bikappa_fit.pro, bimaxwellian_fit.pro
;               8)  VDF = velocity distribution function
;               9)  There is an odd issue that occurs in some cases when MPSIDE=3 for
;                     all parameters except the densities and exponents.  The Jacobian
;                     fails to converge and the MPFIT routines return a status of -16.
;                     To mitigate this issue, we force MPSIDE=0 as a default instead of
;                     MPSIDE=3.
;              10)  Errors and weights are used in the following way in MPFIT2DFUN_EVAL.PRO
;                     result = (z_in - f_model)/error
;                   OR
;                     result = (z_in - f_model)*weights
;              11)  The best results occur when the user supplies Poisson counting
;                     statistics through the POISSON keyword (and gives decent guesses,
;                     of course).  The resulting reduced chi-squared values tend toward
;                     unity rather than hundreds or thousands with the other error
;                     estimates.
;
;  REFERENCES:  
;               0)  Barnes, A. "Collisionless Heating of the Solar-Wind Plasma I. Theory
;                      of the Heating of Collisionless Plasma by Hydromagnetic Waves,"
;                      Astrophys. J. 154, pp. 751--759, 1968.
;               1)  Mace, R.L. and R.D. Sydora "Parallel whistler instability in a plasma
;                      with an anisotropic bi-kappa distribution," J. Geophys. Res. 115,
;                      pp. A07206, doi:10.1029/2009JA015064, 2010.
;               2)  Livadiotis, G. "Introduction to special section on Origins and
;                      Properties of Kappa Distributions: Statistical Background and
;                      Properties of Kappa Distributions in Space Plasmas,"
;                      J. Geophys. Res. 120, pp. 1607--1619, doi:10.1002/2014JA020825,
;                      2015.
;               3)  Dum, C.T., et al., "Turbulent Heating and Quenching of the Ion Sound
;                      Instability," Phys. Rev. Lett. 32(22), pp. 1231--1234, 1974.
;               4)  Dum, C.T. "Strong-turbulence theory and the transition from Landau
;                      to collisional damping," Phys. Rev. Lett. 35(14), pp. 947--950,
;                      1975.
;               5)  Jain, H.C. and S.R. Sharma "Effect of flat top electron distribution
;                      on the turbulent heating of a plasma," Beitraega aus der
;                      Plasmaphysik 19, pp. 19--24, 1979.
;               6)  Goldman, M.V. "Strong turbulence of plasma waves," Rev. Modern Phys.
;                      56(4), pp. 709--735, 1984.
;               7)  Horton, W., et al., "Ion-acoustic heating from renormalized
;                      turbulence theory," Phys. Rev. A 14(1), pp. 424--433, 1976.
;               8)  Horton, W. and D.-I. Choi "Renormalized turbulence theory for the
;                      ion acoustic problem," Phys. Rep. 49(3), pp. 273--410, 1979.
;               9)  Livadiotis, G. "Statistical origin and properties of kappa
;                      distributions," J. Phys.: Conf. Ser. 900(1), pp. 012014, 2017.
;              10)  Livadiotis, G. "Derivation of the entropic formula for the
;                      statistical mechanics of space plasmas,"
;                      Nonlin. Proc. Geophys. 25(1), pp. 77-88, 2018.
;              11)  Livadiotis, G. "Modeling anisotropic Maxwell-Jüttner distributions:
;                      derivation and properties," Ann. Geophys. 34(1),
;                      pp. 1145-1158, 2016.
;              12) Markwardt, C. B. "Non-Linear Least Squares Fitting in IDL with
;                    MPFIT," in proc. Astronomical Data Analysis Software and Systems
;                    XVIII, Quebec, Canada, ASP Conference Series, Vol. 411,
;                    Editors: D. Bohlender, P. Dowler & D. Durand, (Astronomical
;                    Society of the Pacific: San Francisco), pp. 251-254,
;                    ISBN:978-1-58381-702-5, 2009.
;              13) Moré, J. 1978, "The Levenberg-Marquardt Algorithm: Implementation and
;                    Theory," in Numerical Analysis, Vol. 630, ed. G. A. Watson
;                    (Springer-Verlag: Berlin), pp. 105, doi:10.1007/BFb0067690, 1978.
;              14) Moré, J. and S. Wright "Optimization Software Guide," SIAM,
;                    Frontiers in Applied Mathematics, Number 14,
;                    ISBN:978-0-898713-22-0, 1993.
;              15)  The IDL MINPACK routines can be found on Craig B. Markwardt's site at:
;                     http://cow.physics.wisc.edu/~craigm/idl/fitting.html
;              16)  Wilson III, L.B., et al., "Quantified Energy Dissipation Rates in the
;                      Terrestrial Bow Shock: 1. Analysis Techniques and Methodology,"
;                      J. Geophys. Res. 119(8), pp. 6455--6474, 2014a.
;              17)  Wilson III, L.B., et al., "Quantified Energy Dissipation Rates in the
;                      Terrestrial Bow Shock: 2. Waves and Dissipation,"
;                      J. Geophys. Res. 119(8), pp. 6475--6495, 2014b.
;              18)  Wilson III, L.B., et al., "Relativistic electrons produced by
;                      foreshock disturbances observed upstream of the Earth’s bow
;                      shock," Phys. Rev. Lett. 117(21), pp. 215101, 2016.
;
;   CREATED:  04/09/2018
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  06/18/2018   v1.4.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

PRO wrapper_fit_vdf_2_sumof2funcs,vdf,velxyz,VFRAME=vframe,VEC1=vec1,VEC2=vec2,                $
                                  COREP=corep,HALOP=halop,CFUNC=cfunc,HFUNC=hfunc,             $
                                  RMSTRAHL=rmstrahl,V1ISB=v1isb,                               $
                                  ELECTRONS=electrons,IONS=ions,                               $
                                  BEAMP=beamp,BFUNC=bfunc,ONLY_TOT=only_tot,                   $
                                  FIXED_C=fixed_c,FIXED_H=fixed_h,FIXED_B=fixed_b,             $
                                  NCORE_RAN=ncore_ran,NHALO_RAN=nhalo_ran,NBEAM_RAN=nbeam_ran, $
                                  VTACORERN=vtacorern,VTAHALORN=vtahalorn,VTABEAMRN=vtabeamrn, $
                                  VTECORERN=vtecorern,VTEHALORN=vtehalorn,VTEBEAMRN=vtebeamrn, $
                                  VOACORERN=voacorern,VOAHALORN=voahalorn,VOABEAMRN=voabeamrn, $
                                  VOECORERN=voecorern,VOEHALORN=voehalorn,VOEBEAMRN=voebeamrn, $
                                  EXPCORERN=expcorern,EXPHALORN=exphalorn,EXPBEAMRN=expbeamrn, $
                                  EMIN_CH=emin_ch,EMIN_B=emin_b,EMAX_CH=emax_ch,EMAX_B=emax_b, $
                                  FTOL=ftol,GTOL=gtol,XTOL=xtol,USE1C4WGHT=use1c4wght,         $
                                  NO_WGHT=no_wght,PLOT_BOTH=plot_both,POISSON=poisson,         $
                                  NB_LT_NH=nb_lt_nh,SAVEF=savef,FILENAME=filename,             $
                                  NOUSECTAB=nousectab,USE_MM=use_mm,                           $
                                  _EXTRA=extrakey,                                             $
                                  OUTSTRC=out_struc

;;----------------------------------------------------------------------------------------
;;  Constants
;;----------------------------------------------------------------------------------------
f                       = !VALUES.F_NAN
d                       = !VALUES.D_NAN
verns                   = !VERSION.RELEASE     ;;  e.g., '7.1.1'
vernn                   = LONG(STRMID(verns[0],0L,1L))
;;  Check IDL version
IF (vernn[0] LT 8) THEN nan_on = 0b ELSE nan_on = 1b
;;----------------------------------------------------------------------------------------
;;  Defaults
;;----------------------------------------------------------------------------------------
ch_trial                = 1                  ;;  Counting value to let user know how many tries the routine used before exiting
b__trial                = 1                  ;;  Counting value to let user know how many tries the routine used before exiting
pre_pre_str             = ';;  '
sform                   = '(e15.4)'
fitstat_mid             = ['Model Fit Status  ','# of Iterations   ','Deg. of Freedom   ',$
                           'Chi-Squared       ','Red. Chi-Squared  ']+'= '
;c_cols                  = [200, 75]
;h_cols                  = [225, 30]
;b_cols                  = [175,100]
c_cols                  = [225, 75]
h_cols                  = [200, 30]
b_cols                  = [110, 90]
t_cols                  = [200,100]
maxiter                 = 300L               ;;  Default maximum # of iterations to allow MPFIT.PRO to cycle through
def_ctab                = 39                 ;;  Default color table for lines
;;  Define popen structure
popen_str               = {PORT:1,UNITS:'inches',XSIZE:8e0,YSIZE:11e0,ASPECT:0}
;;-------------------------------------------------------
;;  Default fit parameter limits/ranges
;;-------------------------------------------------------
def_kapp_lim            = [3d0/2d0,10d1]  ;;  3/2 ≤ kappa ≤ 100
def_ssex_lim            = [2d0,1d1]       ;;  self-similar exponent:  2 ≤ p ≤ 10
def_voec_lim            = [-1d0,1d0]*1d3  ;;   -1000 km/s ≤ V_oecj ≤  +1000 km/s
def_voic_lim            = [-1d0,1d0]*2d3  ;;   -2000 km/s ≤ V_opcj ≤  +2000 km/s
;;  Check IONS
test           = (N_ELEMENTS(ions) GT 0) AND KEYWORD_SET(ions)
IF (test[0]) THEN ion__on = 1b ELSE ion__on = 0b
;;  Check ELECTRONS
test           = (N_ELEMENTS(electrons) GT 0) AND KEYWORD_SET(electrons)
IF (test[0]) THEN elec_on = 1b ELSE elec_on = ([0b,1b])[~ion__on[0]]
IF (elec_on[0] AND ion__on[0]) THEN ion__on[0] = 0b                    ;;  Make sure only one particle type is set
IF (elec_on[0]) THEN def_v_oc_lim = def_voec_lim ELSE def_v_oc_lim = def_voic_lim
;;  Check NOUSECTAB
IF ((N_ELEMENTS(nousectab) EQ 0) OR ~KEYWORD_SET(nousectab)) THEN BEGIN
  ;;  Force new color table that minimizes amount of green and yellow on output
  SET_PLOT,'X'
  LOADCT,def_ctab[0]
  SET_PLOT,'PS'
  LOADCT,def_ctab[0]
  SET_PLOT,'X'
ENDIF
;;  Shut off SPEDAS settings for !P
;!P.BACKGROUND = 0L
;!P.BACKGROUND = !D.N_COLORS[0] - 1L
;!P.COLOR      = 0L
;!P.COLOR      = !D.TABLE_SIZE[0] - 1L
;;-------------------------------------------------------
;;  Define default RMSTRAHL structure
;;-------------------------------------------------------
tags                    = ['DIR','ANG','S_L']
def_rmstrahl            = CREATE_STRUCT(tags,[-1d0,0d0,0d0],45d0,1d3)
;;----------------------------------------------------------------------------------------
;;  Check input
;;----------------------------------------------------------------------------------------
IF (N_PARAMS() LT 2) THEN RETURN          ;;  Don't bother if nothing is provided
;;  Check parameter
test                    = is_a_number(vdf,/NOMSSG) AND is_a_3_vector(velxyz,V_OUT=vv1,/NOMSSG)
IF (~test[0]) THEN RETURN                 ;;  Don't bother if input is bad
szdf                    = SIZE(vdf,/DIMENSIONS)
szdv                    = SIZE(vv1,/DIMENSIONS)
IF (szdf[0] NE szdv[0]) THEN RETURN       ;;  Don't bother if input is improperly formatted
nn_f                    = szdf[0]         ;;  # of VDF points in input array
vdf                     = REFORM(vdf,nn_f[0])
velxyz                  = vv1
vv1                     = 0
;;----------------------------------------------------------------------------------------
;;  Open 2 plot windows
;;----------------------------------------------------------------------------------------
dev_name                = STRLOWCASE(!D[0].NAME[0])
os__name                = STRLOWCASE(!VERSION.OS_FAMILY)       ;;  'unix' or 'windows'
;;  Check device settings
test_xwin               = (dev_name[0] EQ 'x') OR (dev_name[0] EQ 'win')
IF (test_xwin[0]) THEN BEGIN
  ;;  Proper setting --> find out which windows are already open
  DEVICE,WINDOW_STATE=wstate
ENDIF ELSE BEGIN
  ;;  Switch to proper device
  IF (os__name[0] EQ 'windows') THEN SET_PLOT,'win' ELSE SET_PLOT,'x'
  ;;  Determine which windows are already open
  DEVICE,WINDOW_STATE=wstate
ENDELSE
DEVICE,GET_SCREEN_SIZE=s_size
wsz                     = LONG(MIN(s_size*7d-1))
xywsz                   = [wsz[0],LONG(wsz[0]*1.375d0)]
;;  Now that things are okay, check window status
good_w                  = WHERE(wstate,gd_w)
wind_ns                 = [4,5]
;;  Check if user specified window is already open
test_wopen0             = (TOTAL(good_w EQ wind_ns[0]) GT 0)     ;;  TRUE --> window already open
test_wopen1             = (TOTAL(good_w EQ wind_ns[1]) GT 0)     ;;  TRUE --> window already open
IF (test_wopen0[0]) THEN BEGIN
  ;;  Window 4 is open --> check if was opened by this routine
  WSET,wind_ns[0]
  cur_xywsz               = [!D.X_SIZE[0],!D.Y_SIZE[0]]
  new_w_0                 = (xywsz[0] NE cur_xywsz[0]) OR (xywsz[1] NE cur_xywsz[1])
ENDIF ELSE new_w_0 = 1b   ;;  Open new  window
IF (test_wopen1[0]) THEN BEGIN
  ;;  Window 5 is open --> check if was opened by this routine
  WSET,wind_ns[1]
  cur_xywsz               = [!D.X_SIZE[0],!D.Y_SIZE[0]]
  new_w_1                 = (xywsz[0] NE cur_xywsz[0]) OR (xywsz[1] NE cur_xywsz[1])
ENDIF ELSE new_w_1 = 1b   ;;  Open new  window
;;  Temporarily change settings when cleaning windows
IF ((N_ELEMENTS(nousectab) EQ 0) OR ~KEYWORD_SET(nousectab)) THEN BEGIN
  LOADCT,def_ctab[0]
  !P.BACKGROUND = 'FFFFFF'x       ;;  Hex equivalent in RGB of white
  !P.COLOR      = '000000'x       ;;  Hex equivalent in RGB of black
ENDIF
win_ttl                 = 'VDF Initial Guess'
win_str                 = {RETAIN:2,XSIZE:xywsz[0],YSIZE:xywsz[1],TITLE:win_ttl[0],XPOS:10,YPOS:10}
lbw_window,WIND_N=wind_ns[0],NEW_W=new_w_0[0],_EXTRA=win_str,/CLEAN
win_ttl                 = 'VDF Fit Results'
win_str                 = {RETAIN:2,XSIZE:xywsz[0],YSIZE:xywsz[1],TITLE:win_ttl[0],XPOS:50,YPOS:10}
lbw_window,WIND_N=wind_ns[1],NEW_W=new_w_1[0],_EXTRA=win_str,/CLEAN
IF ((N_ELEMENTS(nousectab) EQ 0) OR ~KEYWORD_SET(nousectab)) THEN LOADCT,def_ctab[0]
;;----------------------------------------------------------------------------------------
;;  Get default PARINFO structure
;;----------------------------------------------------------------------------------------
test                    = get_default_pinfo_4_fitvdf2sumof2funcs(CFUNC=cfunc,HFUNC=hfunc,      $
                                  ELECTRONS=electrons,IONS=ions,                               $
                                  FIXED_C=fixed_c,FIXED_H=fixed_h,FIXED_B=fixed_b,             $
                                  NCORE_RAN=ncore_ran,NHALO_RAN=nhalo_ran,NBEAM_RAN=nbeam_ran, $
                                  VTACORERN=vtacorern,VTAHALORN=vtahalorn,VTABEAMRN=vtabeamrn, $
                                  VTECORERN=vtecorern,VTEHALORN=vtehalorn,VTEBEAMRN=vtebeamrn, $
                                  VOACORERN=voacorern,VOAHALORN=voahalorn,VOABEAMRN=voabeamrn, $
                                  VOECORERN=voecorern,VOEHALORN=voehalorn,VOEBEAMRN=voebeamrn, $
                                  EXPCORERN=expcorern,EXPHALORN=exphalorn,EXPBEAMRN=expbeamrn, $
                                  FTOL=ftol,GTOL=gtol,XTOL=xtol,USE_MM=use_mm,                 $
                                  DEF_OFFST=def_offst,PARINFO=def_pinf,                        $
                                  BFUNC=bfunc,BARINFO=def_binf                                 )
IF (SIZE(def_pinf,/TYPE) NE 8) THEN STOP ;; Debug
def_param               = def_pinf.VALUE
np                      = N_ELEMENTS(def_pinf)
;;----------------------------------------------------------------------------------------
;;  Get default fit functions and plot labels
;;----------------------------------------------------------------------------------------
test                    = get_default_fitfunc_4_fitvdf2sumof2funcs(CFUNC=cfunc,HFUNC=hfunc,$
                                                   FUNC_C=cfun,FUNC_H=hfun,FIT_FUN=func,   $
                                                   CORE_LABS=core_labs,HALO_LABS=halo_labs,$
                                                   XYLAB_PRE=xylabpre,BFUNC=bfunc,         $
                                                   BEAM_LABS=beam_labs,FUNC_B=bfun)
cf                      = cfunc[0]
hf                      = hfunc[0]
bf                      = bfunc[0]
;;----------------------------------------------------------------------------------------
;;  Check keywords with default options
;;----------------------------------------------------------------------------------------
;;  Check USE_MM
test                    = (N_ELEMENTS(use_mm) GT 0) AND KEYWORD_SET(use_mm)
IF (test[0]) THEN vfac = 1d-3 ELSE vfac = 1d0
ffac                    = 1d0/vfac[0]^3d0                        ;;  km^(-3) --> Mm^(-3)
pfar                    = [1d0,REPLICATE(vfac[0],4L),1d0]        ;;  Array to multiply with parameters for general_vdf_contour_plot.pro input and use for inversing:  Mm --> km
;;  Redefine defaults
CASE func[0] OF
  'core_bm_halo_bm_fit'  :  BEGIN
    def_param[11]           = 0d0
    def_pinf[11].FIXED      = 1b
    def_pinf[11].LIMITED[*] = 0b
    def_pinf[11].LIMITS[0]  = 0d0
    def_pinf[11].LIMITS[1]  = 0d0
  END
  'core_bm_halo_kk_fit'  :  ;;  Do nothing
  'core_kk_halo_kk_fit'  :  BEGIN
    def_param[5]            = 1d1
    def_pinf[5].FIXED       = 0b
    test                    = test_range_keys_4_fitvdf2sumof2funcs(RKEY_IN=expcorern,  $
                                              DEF_RAN=def_kapp_lim,LIMS_OUT=lims_exp_c,$
                                              LIMD_OUT=limd_exp_c,RKEY_ON=exp_c_on)
    def_pinf[5].LIMITED[*]  = limd_exp_c
    def_pinf[5].LIMITS[*]   = lims_exp_c
  END
  'core_ss_halo_kk_fit'  :  BEGIN
    def_param[5]            = 4d0
    def_pinf[5].FIXED       = 0b
    test                    = test_range_keys_4_fitvdf2sumof2funcs(RKEY_IN=expcorern,  $
                                              DEF_RAN=def_ssex_lim,LIMS_OUT=lims_exp_c,$
                                              LIMD_OUT=limd_exp_c,RKEY_ON=exp_c_on)
    def_pinf[5].LIMITED[*]  = limd_exp_c
    def_pinf[5].LIMITS[*]   = lims_exp_c
  END
  ELSE  :  STOP   ;;  Debug
ENDCASE
;;------------------------------
;;  Check COREP
;;------------------------------
test                    = (N_ELEMENTS(corep) EQ 6) AND is_a_number(corep,/NOMSSG)
IF (test[0]) THEN BEGIN
  pcore        = DOUBLE(corep)
  ;;  Adjust parameters by velocity factor
  pcore[1:4]  *= vfac[0]
  ;;  Check limits [*** Required to avoid conflicts in MPFIT.PRO ***]
  IF (def_pinf[00].LIMITED[0]) THEN pcore[0]  = pcore[0] > def_pinf[00].LIMITS[0]
  IF (def_pinf[00].LIMITED[1]) THEN pcore[0]  = pcore[0] < def_pinf[00].LIMITS[1]
  IF (def_pinf[01].LIMITED[0]) THEN pcore[1]  = pcore[1] > def_pinf[01].LIMITS[0]
  IF (def_pinf[01].LIMITED[1]) THEN pcore[1]  = pcore[1] < def_pinf[01].LIMITS[1]
  IF (def_pinf[01].LIMITED[0]) THEN pcore[2]  = pcore[2] > def_pinf[01].LIMITS[0]
  IF (def_pinf[01].LIMITED[1]) THEN pcore[2]  = pcore[2] < def_pinf[01].LIMITS[1]
  IF (def_pinf[03].LIMITED[0]) THEN pcore[3]  = pcore[3] > def_pinf[03].LIMITS[0]
  IF (def_pinf[03].LIMITED[1]) THEN pcore[3]  = pcore[3] < def_pinf[03].LIMITS[1]
  IF (def_pinf[04].LIMITED[0]) THEN pcore[4]  = pcore[4] > def_pinf[04].LIMITS[0]
  IF (def_pinf[04].LIMITED[1]) THEN pcore[4]  = pcore[4] < def_pinf[04].LIMITS[1]
  IF (cf[0] NE 'MM') THEN BEGIN
    ;;  Limit kappa or self-similar exponent accordingly
    IF (def_pinf[05].LIMITED[0]) THEN pcore[5]  = pcore[5] > def_pinf[05].LIMITS[0]
    IF (def_pinf[05].LIMITED[1]) THEN pcore[5]  = pcore[5] < def_pinf[05].LIMITS[1]
  ENDIF
ENDIF ELSE BEGIN
  ;;  Use defaults for core
  pcore        = def_param[0L:5L]
ENDELSE
;;------------------------------
;;  Check HALOP
;;------------------------------
test                    = (N_ELEMENTS(halop) EQ 6) AND is_a_number(halop,/NOMSSG)
IF (test[0]) THEN BEGIN
  phalo        = DOUBLE(halop)
  ;;  Adjust parameters by velocity factor
  phalo[1:4]  *= vfac[0]
  ;;  Check limits [*** Required to avoid conflicts in MPFIT.PRO ***]
  IF (def_pinf[06].LIMITED[0]) THEN phalo[0]  = phalo[0] > def_pinf[06].LIMITS[0]
  IF (def_pinf[06].LIMITED[1]) THEN phalo[0]  = phalo[0] < def_pinf[06].LIMITS[1]
  IF (def_pinf[07].LIMITED[0]) THEN phalo[1]  = phalo[1] > def_pinf[07].LIMITS[0]
  IF (def_pinf[07].LIMITED[1]) THEN phalo[1]  = phalo[1] < def_pinf[07].LIMITS[1]
  IF (def_pinf[08].LIMITED[0]) THEN phalo[2]  = phalo[2] > def_pinf[08].LIMITS[0]
  IF (def_pinf[08].LIMITED[1]) THEN phalo[2]  = phalo[2] < def_pinf[08].LIMITS[1]
  IF (def_pinf[09].LIMITED[0]) THEN phalo[3]  = phalo[3] > def_pinf[09].LIMITS[0]
  IF (def_pinf[09].LIMITED[1]) THEN phalo[3]  = phalo[3] < def_pinf[09].LIMITS[1]
  IF (def_pinf[10].LIMITED[0]) THEN phalo[4]  = phalo[4] > def_pinf[10].LIMITS[0]
  IF (def_pinf[10].LIMITED[1]) THEN phalo[4]  = phalo[4] < def_pinf[10].LIMITS[1]
  IF (hf[0] NE 'MM') THEN BEGIN
    ;;  Limit kappa or self-similar exponent accordingly
    IF (def_pinf[11].LIMITED[0]) THEN phalo[5]  = phalo[5] > def_pinf[11].LIMITS[0]
    IF (def_pinf[11].LIMITED[1]) THEN phalo[5]  = phalo[5] < def_pinf[11].LIMITS[1]
  ENDIF
ENDIF ELSE BEGIN
  ;;  Use defaults for halo
  phalo        = def_param[6L:11L]
ENDELSE
;;------------------------------
;;  Check V1ISB
;;------------------------------
test                    = (N_ELEMENTS(v1isb) EQ 1) AND is_a_number(v1isb,/NOMSSG)
IF (test[0]) THEN test = is_a_3_vector(vec1,V_OUT=vv1,/NOMSSG) ELSE vv1 = REPLICATE(d,3)
IF (test[0]) THEN BEGIN
  sb       = sign(v1isb[0])
  uv_st    = REFORM(sb[0]*unit_vec(vv1))
  v1isb_on = (TOTAL(FINITE(uv_st)) EQ 3)
ENDIF ELSE BEGIN
  v1isb_on = 0b
  uv_st    = REPLICATE(d,3)
ENDELSE
;;------------------------------
;;  Check RMSTRAHL
;;------------------------------
test                    = (N_ELEMENTS(rmstrahl) GT 0) AND (SIZE(rmstrahl,/TYPE) EQ 8)
IF (test[0]) THEN BEGIN
  ;;  RMSTRAHL is set to a structure --> check format
  tags                    = ['DIR','ANG','S_L']
  st_dir                  = struct_value(rmstrahl,tags[0],DEFAULT=uv_st,INDEX=i_dir)
  st_ang                  = struct_value(rmstrahl,tags[1],DEFAULT=def_rmstrahl.ANG[0],INDEX=i_ang)
  st_e_l                  = struct_value(rmstrahl,tags[2],DEFAULT=def_rmstrahl.S_L[0],INDEX=i_e_l)
  test                    = ((i_dir[0] GE 0) AND (i_ang[0] GE 0) AND (i_e_l[0] GE 0)) OR $
                            ((TOTAL(FINITE(st_dir)) EQ 3) AND FINITE(st_ang[0]) AND FINITE(st_e_l[0]))
  IF (test[0]) THEN BEGIN
    ;;  okay --> define new structure
    strahl_str   = CREATE_STRUCT(tags,st_dir,st_ang[0],st_e_l[0])
    rm_strahl_on = 1b
  ENDIF ELSE BEGIN
    ;;  Not okay --> use default
    strahl_str   = def_rmstrahl[0]
    ;;  Check if user wants to use VEC1
    IF (v1isb_on[0]) THEN str_element,strahl_str,tags[0],uv_st,/ADD_REPLACE    ;;  TRUE --> use
    rm_strahl_on = 1b
  ENDELSE
ENDIF ELSE BEGIN
  ;;  RMSTRAHL is not set --> check V1ISB
  IF (v1isb_on[0]) THEN BEGIN
    ;;  Set --> define default
    strahl_str   = def_rmstrahl[0]
    str_element,strahl_str,tags[0],uv_st,/ADD_REPLACE
    rm_strahl_on = 1b
  ENDIF ELSE BEGIN
    ;;  Not on --> do not remove anything
    rm_strahl_on = 0b
  ENDELSE
ENDELSE
;;------------------------------
;;  Check BEAMP
;;------------------------------
test                    = (N_ELEMENTS(beamp) EQ 6) AND is_a_number(beamp,/NOMSSG)
IF (test[0]) THEN BEGIN
  pbeam        = DOUBLE(beamp)
  ;;  Adjust parameters by velocity factor
  pbeam[1:4]  *= vfac[0]
  ;;  Check limits [*** Required to avoid conflicts in MPFIT.PRO ***]
  IF (def_binf[00].LIMITED[0]) THEN pbeam[0]  = pbeam[0] > def_binf[00].LIMITS[0]
  IF (def_binf[00].LIMITED[1]) THEN pbeam[0]  = pbeam[0] < def_binf[00].LIMITS[1]
  IF (def_binf[01].LIMITED[0]) THEN pbeam[1]  = pbeam[1] > def_binf[01].LIMITS[0]
  IF (def_binf[01].LIMITED[1]) THEN pbeam[1]  = pbeam[1] < def_binf[01].LIMITS[1]
  IF (def_binf[01].LIMITED[0]) THEN pbeam[2]  = pbeam[2] > def_binf[02].LIMITS[0]
  IF (def_binf[01].LIMITED[1]) THEN pbeam[2]  = pbeam[2] < def_binf[02].LIMITS[1]
  IF (def_binf[03].LIMITED[0]) THEN pbeam[3]  = pbeam[3] > def_binf[03].LIMITS[0]
  IF (def_binf[03].LIMITED[1]) THEN pbeam[3]  = pbeam[3] < def_binf[03].LIMITS[1]
  IF (def_binf[04].LIMITED[0]) THEN pbeam[4]  = pbeam[4] > def_binf[04].LIMITS[0]
  IF (def_binf[04].LIMITED[1]) THEN pbeam[4]  = pbeam[4] < def_binf[04].LIMITS[1]
  IF (bf[0] NE 'MM') THEN BEGIN
    ;;  Limit kappa or self-similar exponent accordingly
    IF (def_binf[05].LIMITED[0]) THEN pbeam[5]  = pbeam[5] > def_binf[05].LIMITS[0]
    IF (def_binf[05].LIMITED[1]) THEN pbeam[5]  = pbeam[5] < def_binf[05].LIMITS[1]
  ENDIF
ENDIF ELSE BEGIN
  ;;  Use defaults for beam
  pbeam        = REFORM(def_binf.VALUE)
  ;;  Define beam PARINFO structure
  def_binf     = def_binf
ENDELSE
;;------------------------------
;;  Check SAVEF
;;------------------------------
test           = (N_ELEMENTS(savef) GT 0) AND KEYWORD_SET(savef)
IF (test[0]) THEN save_on = 1b ELSE save_on = 0b
;;------------------------------
;;  Check FILENAME
;;------------------------------
test                    = (N_ELEMENTS(filename) GT 0) AND (SIZE(filename,/TYPE) EQ 7)
IF (test[0]) THEN fname = filename[0] ELSE IF (save_on[0]) THEN fname = 'vdf_fit_plot_0' ELSE fname = ''
test                    = ~save_on[0] AND ((SIZE(fname[0],/TYPE) EQ 7) AND (fname[0] NE ''))
IF (test[0]) THEN save_on = 1b  ;;  Turn on file saving in case it was not set but FILENAME was
;;------------------------------
;;  Check format of file name
;;------------------------------
test                    = (fname[0] EQ '') OR $
                          ((IDL_VALIDNAME(fname[0],/CONVERT_SPACES) EQ '') AND $
                           (IDL_VALIDNAME(fname[0],/CONVERT_ALL)    EQ '')     )
IF (test[0]) THEN BEGIN
  ;;  format is bad --> shut off file saving
  IF (save_on[0]) THEN BEGIN
    ;;  Let user know something went wrong
    MESSAGE,'Bad FILENAME input format --> No file will be saved!',/INFORMATIONAL,/CONTINUE
  ENDIF
  f_name  = ''
  save_on = 0b  ;;  Turn off file saving
ENDIF ELSE BEGIN
  ;;  get current working directory
  test    = test_file_path_format('.',EXISTS=exists,DIR_OUT=savdir)
  ;;  format is good --> remove any leading or trailing spaces
  f_name  = savdir[0]+STRTRIM(fname[0],2L)
  save_on = 1b  ;;  Turn on file saving in case it was not set but FILENAME was
ENDELSE
;;------------------------------
;;  Check ONLY_TOT
;;------------------------------
test           = (N_ELEMENTS(only_tot) GT 0) AND KEYWORD_SET(only_tot)
IF (test[0]) THEN plottot_on = 1b ELSE plottot_on = 0b
;;------------------------------
;;  Check EMIN_CH and EMIN_B
;;------------------------------
test                    = (N_ELEMENTS(emin_ch) GT 0) AND is_a_number(emin_ch,/NOMSSG)
IF (test[0]) THEN ch_emin = 1d0*ABS(emin_ch[0]) ELSE ch_emin = 0d0
test                    = (N_ELEMENTS(emin_b) GT 0) AND is_a_number(emin_b,/NOMSSG)
IF (test[0]) THEN b__emin = 1d0*ABS(emin_b[0]) ELSE b__emin = 0d0
;;------------------------------
;;  Check EMAX_CH and EMAX_B
;;------------------------------
test                    = (N_ELEMENTS(emax_ch) GT 0) AND is_a_number(emax_ch,/NOMSSG)
IF (test[0]) THEN ch_emax = 1d0*ABS(emax_ch[0]) ELSE ch_emax = 1d30
test                    = (N_ELEMENTS(emax_b) GT 0) AND is_a_number(emax_b,/NOMSSG)
IF (test[0]) THEN b__emax = 1d0*ABS(emax_b[0]) ELSE b__emax = 1d30
;;------------------------------
;;  Check USE1C4WGHT
;;------------------------------
test           = (N_ELEMENTS(use1c4wght) GT 0) AND KEYWORD_SET(use1c4wght)
IF (test[0]) THEN use1c4w_on = 1b ELSE use1c4w_on = 0b
;;------------------------------
;;  Check NO_WGHT
;;------------------------------
test           = (N_ELEMENTS(no_wght) GT 0) AND KEYWORD_SET(no_wght)
IF (test[0]) THEN use_nowght_on = 1b ELSE use_nowght_on = 0b
;;------------------------------
;;  Check PLOT_BOTH
;;------------------------------
test           = (N_ELEMENTS(plot_both) GT 0) AND KEYWORD_SET(plot_both)
IF (test[0]) THEN BEGIN
  both_on    = 1b
  plottot_on = 0b  ;;  Shut off only total
ENDIF ELSE BEGIN
  both_on    = 0b
ENDELSE
;;------------------------------
;;  Check POISSON
;;------------------------------
test           = (N_ELEMENTS(poisson) GT 0) AND is_a_number(poisson,/NOMSSG)
IF (test[0]) THEN BEGIN
  poisson_on     = (N_ELEMENTS(poisson) EQ nn_f[0])
ENDIF ELSE BEGIN
  poisson_on     = 0b
ENDELSE
;;  Make sure only one weighting scheme is used
;;    Priority:  1 = Poisson, 2 = one-count, 3 = no weights, 4 = default
good_wts                = WHERE([use1c4w_on[0],use_nowght_on[0],poisson_on[0],1b],gd_wts)
CASE gd_wts[0] OF
  1    :  BEGIN
    ;;  No priority set --> use 10% of data
    tenperc_on    = 1b
    use1c4w_on    = 0b
    use_nowght_on = 0b
    poisson_on    = 0b
  END
  2    :  BEGIN
    ;;  At least one user-defined weighting scheme is set
    IF (good_wts[0] EQ 2) THEN BEGIN
      ;;  Use Poisson
      poisson_on    = 1b
      use_nowght_on = 0b
      use1c4w_on    = 0b
      tenperc_on    = 0b
    ENDIF ELSE BEGIN
      ;;  Check other two options
      IF (good_wts[0] EQ 1) THEN BEGIN
        ;;  No weighting
        poisson_on    = 0b
        use_nowght_on = 1b
        use1c4w_on    = 0b
        tenperc_on    = 0b
      ENDIF ELSE BEGIN
        ;;  Use one-count for errors
        poisson_on    = 0b
        use_nowght_on = 0b
        use1c4w_on    = 1b
        tenperc_on    = 0b
      ENDELSE
    ENDELSE
  END
  3    :  BEGIN
    ;;  At least two user-defined weighting schemes are set
    IF (good_wts[0] EQ 1) THEN BEGIN
      ;;  Give priority to Poisson
      poisson_on    = 1b
      use_nowght_on = 0b
      use1c4w_on    = 0b
      tenperc_on    = 0b
    ENDIF ELSE BEGIN
      ;;  Set Priority
      IF (good_wts[1] EQ 2) THEN BEGIN
        ;;  Give priority to Poisson
        poisson_on    = 1b
        use_nowght_on = 0b
        use1c4w_on    = 0b
        tenperc_on    = 0b
      ENDIF ELSE BEGIN
        ;;  Give priority to one-count
        poisson_on    = 0b
        use_nowght_on = 0b
        use1c4w_on    = 1b
        tenperc_on    = 0b
      ENDELSE
    ENDELSE
  END
  4    :  BEGIN
    ;;  At least three user-defined weighting schemes are set
    ;;    --> priority goes to Poisson
    poisson_on    = 1b
    use_nowght_on = 0b
    use1c4w_on    = 0b
    tenperc_on    = 0b
  END
  ELSE :  STOP  ;;  Should not be possible --> debug
ENDCASE
;;----------------------------------------------------------------------------------------
;;  Plot 2D contour of VDF and return data
;;----------------------------------------------------------------------------------------
WSET,wind_ns[0]
WSHOW,wind_ns[0]
;;  Check if user wishes to ignore the strahl component
IF (rm_strahl_on[0]) THEN BEGIN
  ;;--------------------------------------------------------------------------------------
  ;;  Check if we need to alter PARINFO limits
  ;;--------------------------------------------------------------------------------------
  test                    = is_a_3_vector(vec1,V_OUT=vv1,/NOMSSG)
  IF (test[0]) THEN BEGIN
    ;;------------------------------------------------------------------------------------
    ;;  VEC1 is set --> determine side to ignore
    ;;------------------------------------------------------------------------------------
    uv_1                    = REFORM(unit_vec(vv1))
    uvst                    = REFORM(unit_vec(uv_st))
    v1_dot_uvst             = TOTAL(uv_1*uvst,/NAN)
    para_bo                 = (v1_dot_uvst[0] GE 0)
    ;;  Check if user is trying to override the default functionality
    test                    = test_range_keys_4_fitvdf2sumof2funcs(RKEY_IN=voacorern,  $
                                              DEF_RAN=def_v_oc_lim,LIMS_OUT=lims_v_oca,$
                                              LIMD_OUT=limd_v_oca,RKEY_ON=v_oca_on)
    IF (para_bo[0]) THEN BEGIN
      ;;----------------------------------------------------------------------------------
      ;;  strahl is parallel to Bo
      ;;----------------------------------------------------------------------------------
      IF (~v_oca_on[0]) THEN BEGIN
        pcore[3]                = pcore[3] < 0
        def_pinf[3].LIMITS[1]   = def_pinf[3].LIMITS[1] < 0
      ENDIF
      phalo[3]                = phalo[3] < 0
      def_pinf[9].LIMITS[1]   = def_pinf[9].LIMITS[1] < 0
      ;;  Alter beam limits structure
      pbeam[3]                = pbeam[3] > 0
      def_binf[3].LIMITS[0]   = def_binf[3].LIMITS[0] > 0
      ;;  Check LIMITS
      test                    = (def_pinf[3].LIMITS[0] GT def_pinf[3].LIMITS[1]) AND def_pinf[3].LIMITED[1]
      IF (test[0]) THEN def_pinf[3].LIMITS[1] = -10*ABS(def_pinf[3].LIMITS[0])
      test                    = (def_pinf[9].LIMITS[0] GT def_pinf[9].LIMITS[1]) AND def_pinf[9].LIMITED[1]
      IF (test[0]) THEN def_pinf[9].LIMITS[1] = -10*ABS(def_pinf[9].LIMITS[0])
      test                    = (def_binf[3].LIMITS[0] GT def_binf[3].LIMITS[1]) AND def_binf[3].LIMITED[1]
      IF (test[0]) THEN BEGIN
        ;;  Adjust and sort
        def_binf[3].LIMITS[1] = 10*def_binf[3].LIMITS[0]
        temp                  = def_binf[3].LIMITS
        sp                    = SORT(temp)
        def_binf[3].LIMITS    = temp[sp]
        temp                  = def_binf[3].LIMITED
        def_binf[3].LIMITED   = temp[sp]
      ENDIF
    ENDIF ELSE BEGIN
      ;;----------------------------------------------------------------------------------
      ;;  strahl is anti-parallel to Bo
      ;;----------------------------------------------------------------------------------
      IF (~v_oca_on[0]) THEN BEGIN
        pcore[3]                = pcore[3] > 0
        def_pinf[3].LIMITS[0]   = def_pinf[3].LIMITS[0] > 0
      ENDIF
      phalo[3]                = phalo[3] > 0
      def_pinf[9].LIMITS[0]   = def_pinf[9].LIMITS[0] > 0
      ;;  Alter beam limits structure
      pbeam[3]                = pbeam[3] < 0
      def_binf[3].LIMITS[1]   = def_binf[3].LIMITS[1] < 0
      ;;  Check LIMITS
      test                    = (def_pinf[3].LIMITS[0] GT def_pinf[3].LIMITS[1]) AND def_pinf[3].LIMITED[1]
      IF (test[0]) THEN def_pinf[3].LIMITS[1] = 10*def_pinf[3].LIMITS[0]
      test                    = (def_pinf[9].LIMITS[0] GT def_pinf[9].LIMITS[1]) AND def_pinf[9].LIMITED[1]
      IF (test[0]) THEN def_pinf[9].LIMITS[1] = 10*def_pinf[9].LIMITS[0]
      test                    = (def_binf[3].LIMITS[0] GT def_binf[3].LIMITS[1]) AND def_binf[3].LIMITED[1]
      IF (test[0]) THEN BEGIN
        ;;  Adjust and sort
        def_binf[3].LIMITS[1] = -10*ABS(def_binf[3].LIMITS[0])
        temp                  = def_binf[3].LIMITS
        sp                    = SORT(temp)
        def_binf[3].LIMITS    = temp[sp]
        temp                  = def_binf[3].LIMITED
        def_binf[3].LIMITED   = temp[sp]
      ENDIF
    ENDELSE
  ENDIF ELSE BEGIN
    ;;------------------------------------------------------------------------------------
    ;;  VEC1 is not set --> do not ignore either side
    ;;------------------------------------------------------------------------------------
    para_bo                 = -1
  ENDELSE
  ;;  Plot VDF
  pcore0 = pcore/pfar
  phalo0 = phalo/pfar
  general_vdf_contour_plot,vdf,velxyz,VFRAME=vframe,VEC1=vec1,VEC2=vec2,_EXTRA=extrakey,  $
                           BIMAX=pcore0,BIKAP=phalo0,DAT_OUT=dat_out
ENDIF ELSE BEGIN
  ;;--------------------------------------------------------------------------------------
  ;;  VEC1 is not set --> do not ignore either side
  ;;--------------------------------------------------------------------------------------
  para_bo                 = -1
  ;;  Call normally without excluding any data
  pcore0 = pcore/pfar
  phalo0 = phalo/pfar
  general_vdf_contour_plot,vdf,velxyz,VFRAME=vframe,VEC1=vec1,VEC2=vec2,_EXTRA=extrakey,  $
                           BIMAX=pcore0,BIKAP=phalo0,DAT_OUT=dat_out
ENDELSE
IF (SIZE(dat_out,/TYPE) NE 8) THEN BEGIN
  MESSAGE,'Failure at plot level output!',/INFORMATION,/CONTINUE
  RETURN        ;;  Failed to plot!!!
ENDIF
;;----------------------------------------------------------------------------------------
;;  Setup fit for VDFs
;;----------------------------------------------------------------------------------------
;;  Define input fit parameters
param                   = [pcore,phalo]
;;  Define gridded VDF parameters
vdf_2d                  = dat_out.CONT_DATA.VDF_2D          ;;  [# cm^(-3) km^(-3) s^(+3)]
vdf_2d                 *= ffac[0]                           ;;  km^(-3) --> Mm^(-3)
vpara                   = dat_out.CONT_DATA.VXGRID          ;;  [Mm/s]
vperp                   = dat_out.CONT_DATA.VXGRID          ;;  [Mm/s]
IF (vfac[0] LT 1d0) THEN BEGIN
  ;;  Use Mm
  vx_in                   = vpara
  vy_in                   = vperp
  vx_km                   = vpara/vfac[0]
  vy_km                   = vperp/vfac[0]
ENDIF ELSE BEGIN
  ;;  Use km
  vx_km                   = vpara*1d3
  vy_km                   = vperp*1d3
  vx_in                   = vx_km
  vy_in                   = vy_km
ENDELSE
;vpara                   = dat_out.CONT_DATA.VXGRID*1d3      ;;  Mm --> km
;vperp                   = dat_out.CONT_DATA.VXGRID*1d3      ;;  Mm --> km
good                    = WHERE(ABS(vdf_2d) GT 0,gd)
IF (gd[0] GT 0) THEN BEGIN
  ;;  Constant by which to offset data
  offset = 1d0/MIN(ABS(vdf_2d[good]),/NAN)
  medoff = 1d0/MEDIAN(ABS(vdf_2d[good]))
ENDIF ELSE BEGIN
  offset = d
  medoff = d
ENDELSE
n_vdf                   = N_ELEMENTS(vdf_2d)
n_par                   = N_ELEMENTS(vx_in)
n_per                   = N_ELEMENTS(vy_in)
;;  Check output so far
test                    = (FINITE(offset) EQ 0) OR (offset[0] LE 0) OR (n_vdf[0] LT 20)
IF (test[0]) THEN BEGIN
  MESSAGE,'Failure after plot level output [insufficient finite output]!',/INFORMATION,/CONTINUE
  RETURN        ;;  Failed to plot!!!
ENDIF
;;----------------------------------------------------------------------------------------
;;  Get VDF for Poisson statistics if desired
;;----------------------------------------------------------------------------------------
IF (poisson_on[0]) THEN BEGIN
  general_vdf_contour_plot,poisson,velxyz,VFRAME=vframe,VEC1=vec1,VEC2=vec2,_EXTRA=extrakey,  $
                           /GET_ROT,ROT_OUT=rot_out
  IF (SIZE(rot_out,/TYPE) EQ 8) THEN BEGIN
    ;;  Currently only allows XY-Plane --> get structure variables
    poisson_2d    = rot_out.PLANE_XY.DF2D_XY          ;;  [# cm^(-3) km^(-3) s^(+3)]
    poisson_2d   *= ffac[0]                           ;;  km^(-3) --> Mm^(-3)
    ;;  Shutoff other weighting options (in case user has them on)
    use1c4w_on    = 0b
    use_nowght_on = 0b
    poisson_on    = 1b
    poisson_2ds   = SMOOTH(poisson_2d,3,/NAN,/EDGE_TRUNCATE)
    poisson_2dc   = poisson_2ds
    poisson_2db   = poisson_2ds
    good          = WHERE(ABS(poisson_2d) GT 0,gd)
    IF (gd[0] GT 0) THEN poffst = 1d0/MIN(ABS(poisson_2d[good]),/NAN) ELSE poffst = 0d0
  ENDIF ELSE BEGIN
    ;;  Something failed --> shutoff Poisson setting
    poisson_on    = 0b
  ENDELSE
ENDIF
;;----------------------------------------------------------------------------------------
;;  Ignore some data for fitting
;;----------------------------------------------------------------------------------------
vdf_2ds                 = SMOOTH(vdf_2d,3,/NAN,/EDGE_TRUNCATE)
vdf_2dc                 = vdf_2ds
vdf_2db                 = vdf_2ds
IF (use1c4w_on[0]) THEN BEGIN
  onec_2dc = SMOOTH(dat_out.ONE_CUT.VDF_2D,3,/NAN,/EDGE_TRUNCATE)*ffac[0]
  onec_2db = onec_2dc
ENDIF ELSE BEGIN
  onec_2dc = 0*vdf_2d
  onec_2db = onec_2dc
ENDELSE
IF (rm_strahl_on[0]) THEN BEGIN
  IF (para_bo[0] GE 0) THEN BEGIN
    IF (para_bo[0]) THEN BEGIN
      ;;  strahl is parallel to Bo
      s_low  = (n_par[0]/2L + 3L)
      s_upp  = (n_par[0] - 1L)
      b_low  = 0L
      b_upp  = (n_par[0]/2L + 3L) - 1L
    ENDIF ELSE BEGIN
      ;;  strahl is anti-parallel to Bo
      s_low  = 0L
      s_upp  = (n_par[0]/2L + 3L) - 1L
      b_low  = (n_par[0]/2L + 3L)
      b_upp  = (n_par[0] - 1L)
    ENDELSE
    ;;  Define bad index range
    s_ind  = fill_range(s_low[0],s_upp[0],DIND=1L)
    b_ind  = fill_range(b_low[0],b_upp[0],DIND=1L)
    ;;  Kill data in bad range
    vdf_2dc[s_ind,*] = f
    vdf_2db[b_ind,*] = f
    IF (use1c4w_on[0]) THEN BEGIN
      onec_2dc[s_ind,*] = f
      onec_2db[b_ind,*] = f
    ENDIF
    IF (poisson_on[0]) THEN BEGIN
      poisson_2dc[s_ind,*] = f
      poisson_2db[b_ind,*] = f
    ENDIF
  ENDIF
ENDIF
;;  Define PARINFO structure
parinfo                 = def_pinf
parinfo.VALUE           = param                             ;;  Redefine parameters
;;----------------------------------------------------------------------------------------
;;  Define error and weights
;;----------------------------------------------------------------------------------------
;;  Define error as 1% of data
vdf_2dp                 = vdf_2dc*offset[0]                 ;;  Force values to > 1.0
good_wts                = WHERE([use1c4w_on[0],use_nowght_on[0],poisson_on[0],tenperc_on[0]],gd_wts)
CASE good_wts[0] OF
  0    : BEGIN       ;;  one-count
    zerr                    = onec_2dc*offset[0]
    weights                 = 1d0/zerr                          ;;  Poisson weights of one-count
  END
  1    : BEGIN       ;;  no weighting
    ;;  Use 10% of data for errors
    zerr                    = 1d-2*vdf_2dp
    weights                 = REPLICATE(1d0,n_par[0],n_per[0])
  END
  2    : BEGIN       ;;  Poisson
    ;;  Oddly, the use of Poisson counting statistics on input with Gaussian weights
    ;;   produces the best results
    zerr                    = poisson_2dc*poffst[0]
    weights                 = 1d0/zerr^2d0
  END
  3    : BEGIN       ;;  10% of data
    zerr                    = 1d-2*vdf_2dp
    weights                 = 1d0/zerr^2d0                      ;;  Gaussian weights
  END
  ELSE : STOP        ;;  Should not be possible --> debug
ENDCASE
;;  Remove negatives and zeros
test                    = (FINITE(vdf_2dc) EQ 0) OR (vdf_2dc LE 0) OR $
                          (FINITE(zerr) EQ 0) OR (zerr LE 0) OR       $
                          (FINITE(weights) EQ 0) OR (weights LE 0)
bad                     = WHERE(test,bd,COMPLEMENT=good,NCOMPLEMENT=gd)
test                    = (1d0*bd[0] GT 9d-1*n_vdf[0])
IF (test[0]) THEN BEGIN
  ;;  Too many "bad" data points --> Failure!
  MESSAGE,'Failure:  Too many bad data points!',/INFORMATION,/CONTINUE
  RETURN        ;;  Failed to plot!!!
ENDIF ELSE BEGIN
  IF (bd[0] GT 0) THEN BEGIN
    ;;  Success!
    vdf_2dc[bad]            = 0d0
    zerr[bad]               = 1d50       ;;  MPFIT.PRO does not allow 0.0 errrors if others are finite
    weights[bad]            = 0d0        ;;  Zero for weights will result in ignoring those points
  ENDIF ELSE BEGIN
    ;;  All "good" data points --> Success!
  ENDELSE
ENDELSE
;;----------------------------------------------------------------------------------------
;;  Calculate energies corresponding to the regridded velocities
;;----------------------------------------------------------------------------------------
vpar2d                  = vx_in # REPLICATE(1d0,n_per[0])
vper2d                  = REPLICATE(1d0,n_par[0]) # vy_in
vel_2d                  = [[[vpar2d]],[[vper2d]]]             ;;  [N,M,2]-Element array
speed                   = SQRT(TOTAL(vel_2d^2,3,/NAN))        ;;  [N,M]-Element array of speeds [km/s]
;;  Convert to energies [eV]
eners                   = energy_to_vel(speed,ELECTRON=elec_on[0],PROTON=ion__on[0],/INVERSE)
;;----------------------------------------------------------------------------------------
;;  Check if user wants to exclude data below EMIN_CH
;;----------------------------------------------------------------------------------------
IF (ch_emin[0] GT 0) THEN BEGIN
  ;;  Exclude data below EMIN_CH
  bad2                    = WHERE(eners LE ch_emin[0],bd2)
  IF (bd2[0] GT 0) THEN BEGIN
    ;;  Zero-out values of weights to tell MPFIT to ignore those points
    weights[bad2]            = 0d0
    zerr[bad2]               = 1d50       ;;  MPFIT.PRO does not allow 0.0 errrors if others are finite
  ENDIF
ENDIF
;;----------------------------------------------------------------------------------------
;;  Check if user wants to exclude data above EMAX_CH
;;----------------------------------------------------------------------------------------
IF (ch_emax[0] LT 1d30) THEN BEGIN
  ;;  Exclude data above EMAX_CH
  bad2                    = WHERE(eners GE ch_emax[0],bd2)
  IF (bd2[0] GT 0) THEN BEGIN
    ;;  Zero-out values of weights to tell MPFIT to ignore those points
    weights[bad2]            = 0d0
    zerr[bad2]               = 1d50       ;;  MPFIT.PRO does not allow 0.0 errrors if others are finite
  ENDIF
ENDIF
;;----------------------------------------------------------------------------------------
;;  Fit to model 2D function
;;----------------------------------------------------------------------------------------
x                       = vx_in
y                       = vy_in
z                       = vdf_2dc
bifit                   = mpfit2dfun(func[0],x,y,z,zerr,param,PARINFO=parinfo,PERROR=f_sigma,    $
                                     BESTNORM=chisq,DOF=dof,STATUS=status,NITER=iter,            $
                                     YFIT=vdf_fit_out,QUIET=1,WEIGHTS=weights,NAN=nan_on[0],     $
                                     FTOL=ftol,GTOL=gtol,XTOL=xtol,ERRMSG=errmsg,                $
                                     BEST_RESID=zerrors,PFREE_INDEX=pfree_ind,NPEGGED=npegged,   $
                                     MAXITER=maxiter                                             )
IF (status[0] EQ -16) THEN BEGIN
  ;;  TRUE = Try changing MPSIDE for densities
  ;;  try again
  parinfo[00].MPSIDE[0]   = 3
  parinfo[06].MPSIDE[0]   = 3
  ch_trial               += 1       ;; Increment trial counter
  ;;  Clean up first
  IF (SIZE(vdf_fit_out,/TYPE) NE 0)      THEN dumb = TEMPORARY(vdf_fit_out)
  IF (SIZE(bifit,/TYPE)       NE 0)      THEN dumb = TEMPORARY(bifit)
  IF (SIZE(f_sigma,/TYPE)     NE 0)      THEN dumb = TEMPORARY(f_sigma)
  IF (SIZE(chisq,/TYPE)       NE 0)      THEN dumb = TEMPORARY(chisq)
  IF (SIZE(dof,/TYPE)         NE 0)      THEN dumb = TEMPORARY(dof)
  IF (SIZE(iter,/TYPE)        NE 0)      THEN dumb = TEMPORARY(iter)
  IF (SIZE(zerrors,/TYPE)     NE 0)      THEN dumb = TEMPORARY(zerrors)
  IF (SIZE(pfree_ind,/TYPE)   NE 0)      THEN dumb = TEMPORARY(pfree_ind)
  IF (SIZE(npegged,/TYPE)     NE 0)      THEN dumb = TEMPORARY(npegged)
  bifit                   = mpfit2dfun(func[0],x,y,z,zerr,param,PARINFO=parinfo,PERROR=f_sigma,    $
                                       BESTNORM=chisq,DOF=dof,STATUS=status,NITER=iter,            $
                                       YFIT=vdf_fit_out,QUIET=1,WEIGHTS=weights,NAN=nan_on[0],     $
                                       FTOL=ftol,GTOL=gtol,XTOL=xtol,ERRMSG=errmsg,                $
                                       BEST_RESID=zerrors,PFREE_INDEX=pfree_ind,NPEGGED=npegged,   $
                                       MAXITER=maxiter                                             )
  IF (status[0] EQ -16) THEN BEGIN
    ;;  TRUE = Try changing MPSIDE for perpendicular thermal speeds
    ;;  try again
    parinfo[02].MPSIDE[0]   = 3
    parinfo[08].MPSIDE[0]   = 3
    ch_trial               += 1       ;; Increment trial counter
    ;;  Clean up first
    IF (SIZE(vdf_fit_out,/TYPE) NE 0)      THEN dumb = TEMPORARY(vdf_fit_out)
    IF (SIZE(bifit,/TYPE)       NE 0)      THEN dumb = TEMPORARY(bifit)
    IF (SIZE(f_sigma,/TYPE)     NE 0)      THEN dumb = TEMPORARY(f_sigma)
    IF (SIZE(chisq,/TYPE)       NE 0)      THEN dumb = TEMPORARY(chisq)
    IF (SIZE(dof,/TYPE)         NE 0)      THEN dumb = TEMPORARY(dof)
    IF (SIZE(iter,/TYPE)        NE 0)      THEN dumb = TEMPORARY(iter)
    IF (SIZE(zerrors,/TYPE)     NE 0)      THEN dumb = TEMPORARY(zerrors)
    IF (SIZE(pfree_ind,/TYPE)   NE 0)      THEN dumb = TEMPORARY(pfree_ind)
    IF (SIZE(npegged,/TYPE)     NE 0)      THEN dumb = TEMPORARY(npegged)
    bifit                   = mpfit2dfun(func[0],x,y,z,zerr,param,PARINFO=parinfo,PERROR=f_sigma,    $
                                         BESTNORM=chisq,DOF=dof,STATUS=status,NITER=iter,            $
                                         YFIT=vdf_fit_out,QUIET=1,WEIGHTS=weights,NAN=nan_on[0],     $
                                         FTOL=ftol,GTOL=gtol,XTOL=xtol,ERRMSG=errmsg,                $
                                         BEST_RESID=zerrors,PFREE_INDEX=pfree_ind,NPEGGED=npegged,   $
                                         MAXITER=maxiter                                             )
  END
END
;;----------------------------------------------------------------------------------------
;;   STATUS : 
;;             > 0 = success
;;             -18 = a fatal execution error has occurred.  More information may be
;;                   available in the ERRMSG string.
;;             -16 = a parameter or function value has become infinite or an undefined
;;                   number.  This is usually a consequence of numerical overflow in the
;;                   user's model function, which must be avoided.
;;             -15 to -1 = 
;;                   these are error codes that either MYFUNCT or ITERPROC may return to
;;                   terminate the fitting process (see description of MPFIT_ERROR
;;                   common below).  If either MYFUNCT or ITERPROC set ERROR_CODE to a
;;                   negative number, then that number is returned in STATUS.  Values
;;                   from -15 to -1 are reserved for the user functions and will not
;;                   clash with MPFIT.
;;             0 = improper input parameters.
;;             1 = both actual and predicted relative reductions in the sum of squares
;;                   are at most FTOL.
;;             2 = relative error between two consecutive iterates is at most XTOL
;;             3 = conditions for STATUS = 1 and STATUS = 2 both hold.
;;             4 = the cosine of the angle between fvec and any column of the jacobian
;;                   is at most GTOL in absolute value.
;;             5 = the maximum number of iterations has been reached
;;                   (may indicate failure to converge)
;;             6 = FTOL is too small. no further reduction in the sum of squares is
;;                   possible.
;;             7 = XTOL is too small. no further improvement in the approximate
;;                   solution x is possible.
;;             8 = GTOL is too small. fvec is orthogonal to the columns of the
;;                   jacobian to machine precision.
;;----------------------------------------------------------------------------------------
normal                  = REPLICATE(1d0,12)
IF (status[0] GT 0) THEN BEGIN  ;;  TRUE = Success!  -->  Print out info
  ;;--------------------------------------------------------------------------------------
  ;;  Success!  -->  Fit to residual
  ;;--------------------------------------------------------------------------------------
  parmb                   = pbeam
  b_info                  = def_binf
  b_info.VALUE            = parmb                               ;;  Redefine parameters
  fit_out                 = vdf_fit_out
  residual                = (vdf_2ds - fit_out) > 0             ;;  Force values to > 1.0
  CASE good_wts[0] OF
    0    : BEGIN       ;;  one-count
      berror                  = onec_2db*offset[0]
      bweight                 = 1d0/berror                          ;;  Poisson weights of one-count
    END
    1    : BEGIN       ;;  no weighting
      ;;  Use 10% of data for errors
      berror                  = 1d-2*residual*offset[0]
      bweight                 = REPLICATE(1d0,n_par[0],n_per[0])
    END
    2    : BEGIN       ;;  Poisson
      ;;  Oddly, the use of Poisson counting statistics on input with Gaussian weights
      ;;   produces the best results
      berror                  = poisson_2db*poffst[0]
      bweight                 = 1d0/berror^2d0
    END
    3    : BEGIN       ;;  10% of data
      berror                  = 1d-2*residual*offset[0]
      bweight                 = 1d0/berror^2d0                      ;;  Gaussian weights
    END
    ELSE : STOP        ;;  Should not be possible --> debug
  ENDCASE
  ;;  Remove negatives and zeros
  test                    = (FINITE(residual) EQ 0) OR (residual LE 0) OR $
                            (FINITE(berror) EQ 0) OR (berror LE 0) OR     $
                            (FINITE(bweight) EQ 0) OR (bweight LE 0)
  badb                    = WHERE(test,bdb,COMPLEMENT=goodb,NCOMPLEMENT=gdb)
  test                    = (1d0*bdb[0] LE 9d-1*n_vdf[0]) AND (bdb[0] GT 0)
  IF (test[0]) THEN BEGIN
    ;;  Some "bad" data points
    residual[badb]          = 0d0
    berror[badb]            = 1d50       ;;  MPFIT.PRO does not allow 0.0 errrors if others are finite
    bweight[badb]           = 0d0
  ENDIF
  ;;--------------------------------------------------------------------------------------
  ;;  Check if user wants to exclude data below EMIN_B
  ;;--------------------------------------------------------------------------------------
  IF (b__emin[0] GT 0) THEN BEGIN
    ;;  Exclude data below EMIN_B
    bad3                    = WHERE(eners LE b__emin[0],bd3)
    IF (bd3[0] GT 0) THEN BEGIN
      ;;  Zero-out values of weights to tell MPFIT to ignore those points
      bweight[bad3]            = 0d0
      berror[badb]             = 1d50       ;;  MPFIT.PRO does not allow 0.0 errrors if others are finite
    ENDIF
  ENDIF
  ;;--------------------------------------------------------------------------------------
  ;;  Check if user wants to exclude data above EMAX_B
  ;;--------------------------------------------------------------------------------------
  IF (b__emax[0] LT 1d30) THEN BEGIN
    ;;  Exclude data above EMAX_B
    bad3                    = WHERE(eners GE b__emax[0],bd3)
    IF (bd3[0] GT 0) THEN BEGIN
      ;;  Zero-out values of weights to tell MPFIT to ignore those points
      bweight[bad3]            = 0d0
      berror[badb]             = 1d50       ;;  MPFIT.PRO does not allow 0.0 errrors if others are finite
    ENDIF
  ENDIF
  ;;--------------------------------------------------------------------------------------
  ;;  Check NB_LT_NH
  ;;--------------------------------------------------------------------------------------
  test           = (N_ELEMENTS(nb_lt_nh) GT 0) AND KEYWORD_SET(nb_lt_nh)
  IF (test[0]) THEN BEGIN
    ;;  Use the halo density result from the core+halo fit to limit the beam density
    old_lims          = b_info[0].LIMITS
    old_limd          = b_info[0].LIMITED
    halo_dens         = bifit[6]
    new_lims          = old_lims
    new_lims[1]       = new_lims[1] < (9d-1*halo_dens[0])
    IF (new_lims[1] LE new_lims[0]) THEN new_lims[0] *= 1d-1     ;;  Shrink, if necessary
    ;;  Redefine PARINFO limits for beam fit
    b_info[0].LIMITS  = new_lims
    b_info[0].LIMITED = 1b
    new_bdens         = MEAN(new_lims,/NAN)
    b_info[0].VALUE   = new_bdens[0]
    parmb[0]          = new_bdens[0]
  ENDIF
  ;;--------------------------------------------------------------------------------------
  ;;  Fit beam to model 2D function
  ;;--------------------------------------------------------------------------------------
  xb                      = vx_in
  yb                      = vy_in
  zb                      = residual
  beamf                   = mpfit2dfun(bfun[0],xb,yb,zb,berror,parmb,PARINFO=b_info,           $
                                     BESTNORM=chisqb,DOF=dofb,STATUS=statb,NITER=biter,        $
                                     YFIT=beamfit_out,/QUIET,WEIGHTS=bweight,NAN=nan_on[0],    $
                                     FTOL=ftol,GTOL=gtol,XTOL=xtol,ERRMSG=errmsg,              $
                                     BEST_RESID=berrors,PFREE_INDEX=bfree_ind,NPEGGED=bpegged, $
                                     PERROR=b_sigma,MAXITER=maxiter                            )
  IF (statb[0] EQ -16) THEN BEGIN
    ;;  TRUE = Try changing MPSIDE for density
    b_info[00].MPSIDE[0]    = 3
    b__trial               += 1       ;; Increment trial counter
    ;;  Clean up first
    IF (SIZE(statb,/TYPE)       EQ 0) THEN dumb = TEMPORARY(statb)
    IF (SIZE(beamfit_out,/TYPE) EQ 0) THEN dumb = TEMPORARY(beamfit_out)
    IF (SIZE(beamf,/TYPE)       EQ 0) THEN dumb = TEMPORARY(beamf)
    IF (SIZE(b_sigma,/TYPE)     EQ 0) THEN dumb = TEMPORARY(b_sigma)
    IF (SIZE(chisqb,/TYPE)      EQ 0) THEN dumb = TEMPORARY(chisqb)
    IF (SIZE(dofb,/TYPE)        EQ 0) THEN dumb = TEMPORARY(dofb)
    IF (SIZE(biter,/TYPE)       EQ 0) THEN dumb = TEMPORARY(biter)
    IF (SIZE(berrors,/TYPE)     EQ 0) THEN dumb = TEMPORARY(berrors)
    IF (SIZE(bfree_ind,/TYPE)   EQ 0) THEN dumb = TEMPORARY(bfree_ind)
    IF (SIZE(bpegged,/TYPE)     EQ 0) THEN dumb = TEMPORARY(bpegged)
    beamf                   = mpfit2dfun(bfun[0],xb,yb,zb,berror,parmb,PARINFO=b_info,           $
                                       BESTNORM=chisqb,DOF=dofb,STATUS=statb,NITER=biter,        $
                                       YFIT=beamfit_out,/QUIET,WEIGHTS=bweight,NAN=nan_on[0],    $
                                       FTOL=ftol,GTOL=gtol,XTOL=xtol,ERRMSG=errmsg,              $
                                       BEST_RESID=berrors,PFREE_INDEX=bfree_ind,NPEGGED=bpegged, $
                                       PERROR=b_sigma,MAXITER=maxiter                            )
    IF (statb[0] EQ -16) THEN BEGIN
      ;;  TRUE = Try changing MPSIDE for perpendicular thermal speed
      b_info[02].MPSIDE[0]    = 3
      b__trial               += 1       ;; Increment trial counter
      ;;  Clean up first
      IF (SIZE(statb,/TYPE)       EQ 0) THEN dumb = TEMPORARY(statb)
      IF (SIZE(beamfit_out,/TYPE) EQ 0) THEN dumb = TEMPORARY(beamfit_out)
      IF (SIZE(beamf,/TYPE)       EQ 0) THEN dumb = TEMPORARY(beamf)
      IF (SIZE(b_sigma,/TYPE)     EQ 0) THEN dumb = TEMPORARY(b_sigma)
      IF (SIZE(chisqb,/TYPE)      EQ 0) THEN dumb = TEMPORARY(chisqb)
      IF (SIZE(dofb,/TYPE)        EQ 0) THEN dumb = TEMPORARY(dofb)
      IF (SIZE(biter,/TYPE)       EQ 0) THEN dumb = TEMPORARY(biter)
      IF (SIZE(berrors,/TYPE)     EQ 0) THEN dumb = TEMPORARY(berrors)
      IF (SIZE(bfree_ind,/TYPE)   EQ 0) THEN dumb = TEMPORARY(bfree_ind)
      IF (SIZE(bpegged,/TYPE)     EQ 0) THEN dumb = TEMPORARY(bpegged)
      beamf                   = mpfit2dfun(bfun[0],xb,yb,zb,berror,parmb,PARINFO=b_info,           $
                                         BESTNORM=chisqb,DOF=dofb,STATUS=statb,NITER=biter,        $
                                         YFIT=beamfit_out,/QUIET,WEIGHTS=bweight,NAN=nan_on[0],    $
                                         FTOL=ftol,GTOL=gtol,XTOL=xtol,ERRMSG=errmsg,              $
                                         BEST_RESID=berrors,PFREE_INDEX=bfree_ind,NPEGGED=bpegged, $
                                         PERROR=b_sigma,MAXITER=maxiter                            )
    ENDIF
  ENDIF
  ;;--------------------------------------------------------------------------------------
  ;;  Check beam fit
  ;;--------------------------------------------------------------------------------------
  IF (statb[0] GT 0) THEN BEGIN
    ;;  TRUE = Success!  -->  Print out info
    bfitp                   = beamf/pfar
    CASE good_wts[0] OF
      0    : BEGIN       ;;  one-count
        bsigp                   = b_sigma/(offset[0])
        chisqb                 *= offset[0]
      END
      1    : BEGIN       ;;  no weighting
        bsigp                   = b_sigma
        chisqb                 *= medoff[0]
      END
      2    : BEGIN       ;;  Poisson
        bsigp                   = b_sigma/(poffst[0])
        chisqb                 *= poffst[0]^2d0
      END
      3    : BEGIN       ;;  10% of data
        bsigp                   = b_sigma/(1d-2*offset[0])
        chisqb                 *= offset[0]^2d0
      END
      ELSE : STOP        ;;  Should not be possible --> debug
    ENDCASE
    bsigp                  /= pfar
    ;;  Get 2D model results
;    beam_2d                 = CALL_FUNCTION(bfun[0],vpara,vperp,bfitp,REPLICATE(0,6))
    beam_2d                 = CALL_FUNCTION(bfun[0],vx_km,vy_km,bfitp,REPLICATE(0,6))
    ;;  Get 1D cuts
    bbeam_struc             = find_1d_cuts_2d_dist(beam_2d,vx_km,vy_km,X_0=0d0,Y_0=0d0)
;    bbeam_struc             = find_1d_cuts_2d_dist(beam_2d,vpara,vperp,X_0=0d0,Y_0=0d0)
    bbeam_para              = bbeam_struc.X_1D_FXY         ;;  horizontal 1D cut
    bbeam_perp              = bbeam_struc.Y_1D_FXY         ;;  vertical 1D cut
    ;;  Define outputs
    beamout                 = beamfit_out/ffac[0]
;    beamout                 = beamfit_out
  ENDIF ELSE BEGIN
    ;;  Failed!
    MESSAGE,errmsg[0],/INFORMATIONAL,/CONTINUE
    ;;  Failure --> define default beam fit outputs
    xb                      = x*0
    yb                      = y*0
    zb                      = z*0
    IF (use1c4w_on[0]) THEN fac = 1d0/(1d-2*offset[0]) ELSE fac = 1d0/offset[0]
    IF (use_nowght_on[0]) THEN fac = 1d0
    IF (poisson_on[0]) THEN fac = 1d0/poffst[0]
    IF (SIZE(statb,/TYPE) EQ 0)            THEN statb       = -1
    IF (SIZE(beamfit_out,/TYPE) EQ 0)      THEN beamout     = REPLICATE(d,n_par[0],n_per[0]) ELSE beamout  = beamfit_out/ffac[0]
    IF (SIZE(beamf,/TYPE) EQ 0)            THEN bfitp       = REPLICATE(d,6)                 ELSE bfitp    = beamf/pfar
;    IF (SIZE(beamfit_out,/TYPE) EQ 0)      THEN beamout     = REPLICATE(d,n_par[0],n_per[0]) ELSE beamout  = beamfit_out
;    IF (SIZE(beamf,/TYPE) EQ 0)            THEN bfitp       = REPLICATE(d,6)                 ELSE bfitp    = beamf
    IF (SIZE(b_sigma,/TYPE) EQ 0)          THEN bsigp       = REPLICATE(d,6)                 ELSE bsigp    = (b_sigma*fac[0])/pfar
    IF (SIZE(bweight,/TYPE) EQ 0)          THEN bweight     = REPLICATE(d,n_par[0],n_per[0])
    IF (SIZE(chisqb,/TYPE) EQ 0)           THEN chisqb      = d
    IF (SIZE(dofb,/TYPE) EQ 0)             THEN dofb        = d
    IF (SIZE(biter,/TYPE) EQ 0)            THEN biter       = -1
    IF (SIZE(berrors,/TYPE) EQ 0)          THEN berrors     = REPLICATE(d,n_par[0],n_per[0])
    IF (SIZE(b_info,/TYPE) EQ 0)           THEN b_info      = def_binf
    IF (SIZE(bfree_ind,/TYPE) EQ 0)        THEN bfree_ind   = -1
    IF (SIZE(bpegged,/TYPE) EQ 0)          THEN bpegged     = -1
    bbeam_para              = REPLICATE(0d0,n_par[0])         ;;  horizontal 1D cut
    bbeam_perp              = REPLICATE(0d0,n_per[0])         ;;  vertical 1D cut
  ENDELSE
ENDIF ELSE BEGIN
  ;;--------------------------------------------------------------------------------------
  ;;  Main fit to core+halo failed --> don't bother with beam
  ;;--------------------------------------------------------------------------------------
  xb                      = x*0
  yb                      = y*0
  zb                      = z*0
  b__trial                = -1
  ;;  Failure --> define default beam fit outputs
  IF (use1c4w_on[0]) THEN fac = 1d0/(1d-2*offset[0]) ELSE fac = 1d0/offset[0]
  IF (use_nowght_on[0]) THEN fac = 1d0
  IF (poisson_on[0]) THEN fac = 1d0/poffst[0]
  IF (SIZE(statb,/TYPE) EQ 0)            THEN statb       = -1
  IF (SIZE(beamfit_out,/TYPE) EQ 0)      THEN beamout     = REPLICATE(d,n_par[0],n_per[0]) ELSE beamout  = beamfit_out/ffac[0]
  IF (SIZE(beamf,/TYPE) EQ 0)            THEN bfitp       = REPLICATE(d,6)                 ELSE bfitp    = beamf/pfar
;  IF (SIZE(beamfit_out,/TYPE) EQ 0)      THEN beamout     = REPLICATE(d,n_par[0],n_per[0]) ELSE beamout  = beamfit_out
;  IF (SIZE(beamf,/TYPE) EQ 0)            THEN bfitp       = REPLICATE(d,6)                 ELSE bfitp    = beamf
  IF (SIZE(b_sigma,/TYPE) EQ 0)          THEN bsigp       = REPLICATE(d,6)                 ELSE bsigp    = (b_sigma*fac[0])/pfar
  IF (SIZE(bweight,/TYPE) EQ 0)          THEN bweight     = REPLICATE(d,n_par[0],n_per[0])
  IF (SIZE(chisqb,/TYPE) EQ 0)           THEN chisqb      = d
  IF (SIZE(dofb,/TYPE) EQ 0)             THEN dofb        = d
  IF (SIZE(biter,/TYPE) EQ 0)            THEN biter       = -1
  IF (SIZE(berrors,/TYPE) EQ 0)          THEN berrors     = REPLICATE(d,n_par[0],n_per[0])
  IF (SIZE(b_info,/TYPE) EQ 0)           THEN b_info      = def_binf
  IF (SIZE(bfree_ind,/TYPE) EQ 0)        THEN bfree_ind   = -1
  IF (SIZE(bpegged,/TYPE) EQ 0)          THEN bpegged     = -1
  bbeam_para              = REPLICATE(0d0,n_par[0])         ;;  horizontal 1D cut
  bbeam_perp              = REPLICATE(0d0,n_per[0])         ;;  vertical 1D cut
ENDELSE
;;----------------------------------------------------------------------------------------
;;  Define beam fit strings for output
;;----------------------------------------------------------------------------------------
;;  Define sign of fit values
signbf                  = sign(bfitp)
sbf_str                 = (['-','+'])[(signbf GT 0)]
;;  Define fit status, DoFs, and Red. Chi-Squared strings
bstatstr                = num2int_str(statb[0],NUM_CHAR=12L,/ZERO_PAD)
biterstr                = num2int_str(biter[0],NUM_CHAR=12L,/ZERO_PAD)
dofb_str                = num2int_str(dofb[0],NUM_CHAR=12L,/ZERO_PAD)
chsqbstr                = STRTRIM(STRING(ABS(chisqb[0]),FORMAT=sform[0]),2L)
rcsqbstr                = STRTRIM(STRING(ABS(chisqb[0]/dofb[0]),FORMAT=sform[0]),2L)
bfitstatsuf             = [bstatstr[0],biterstr[0],dofb_str[0],chsqbstr[0],rcsqbstr[0]]
;;  Define print output of fit results
bfit_str                = sbf_str+STRTRIM(STRING(ABS(bfitp),FORMAT=sform[0]),2L)
bsig_str                =         STRTRIM(STRING(ABS(bsigp),FORMAT=sform[0]),2L)
units_out               = '  '+['cm^(-3)',REPLICATE('km s^(-1)',4L),'']
midf                    = ' +/- '
beam_xyout              = beam_labs+bfit_str+midf[0]+bsig_str+units_out
bstatxyout              = pre_pre_str[0]+fitstat_mid+bfitstatsuf
;;----------------------------------------------------------------------------------------
;;  Print and plot output
;;----------------------------------------------------------------------------------------
thck                    = 3.5e0
now_save                = 0b
both_plotted            = 0b
IF (status[0] GT 0) THEN BEGIN  ;;  TRUE = Success!  -->  Print out info
  ;;--------------------------------------------------------------------------------------
  ;;  Success!  -->  Print out info
  ;;--------------------------------------------------------------------------------------
  cfitp                   = bifit[0L:5L]/pfar
  hfitp                   = bifit[6L:11L]/pfar
  CASE good_wts[0] OF
    0    : BEGIN       ;;  one-count
      csigp                   = f_sigma[0L:5L]/(offset[0])
      hsigp                   = f_sigma[6L:11L]/(offset[0])
      chisq                  *= offset[0]                           ;;  Remove correction that was added to weights to ensure ≥ 1.0
    END
    1    : BEGIN       ;;  no weighting
      csigp                   = f_sigma[0L:5L]
      hsigp                   = f_sigma[6L:11L]
      chisq                  *= medoff[0]
    END
    2    : BEGIN       ;;  Poisson
      csigp                   =  f_sigma[0L:5L]/poffst[0]
      hsigp                   = f_sigma[6L:11L]/poffst[0]
      chisq                  *= poffst[0]^2d0
    END
    3    : BEGIN       ;;  10% of data
      csigp                   = f_sigma[0L:5L]/(1d-2*offset[0])
      hsigp                   = f_sigma[6L:11L]/(1d-2*offset[0])
      chisq                  *= offset[0]^2d0                       ;;  Remove correction that was added to weights to ensure ≥ 1.0
    END
    ELSE : STOP        ;;  Should not be possible --> debug
  ENDCASE
  csigp                  /= pfar
  hsigp                  /= pfar
  ;;  Define sign of fit values
  signcf                  = sign(cfitp)
  signhf                  = sign(hfitp)
  scf_str                 = (['-','+'])[(signcf GT 0)]
  shf_str                 = (['-','+'])[(signhf GT 0)]
  ;;  Define fit status, DoFs, and Red. Chi-Squared strings
  stat_str                = num2int_str(status[0],NUM_CHAR=12L,/ZERO_PAD)
  dof__str                = num2int_str(dof[0],NUM_CHAR=12L,/ZERO_PAD)
  iter_str                = num2int_str(iter[0],NUM_CHAR=12L,/ZERO_PAD)
  chsq_str                = STRTRIM(STRING(ABS(chisq[0]),FORMAT=sform[0]),2L)
  rcsq_str                = STRTRIM(STRING(ABS(chisq[0]/dof[0]),FORMAT=sform[0]),2L)
  fitstat_suf             = [stat_str[0],iter_str[0],dof__str[0],chsq_str[0],rcsq_str[0]]
  ;;--------------------------------------------------------------------------------------
  ;;  Print out fit results
  ;;--------------------------------------------------------------------------------------
  cfit_str                = scf_str+STRTRIM(STRING(ABS(cfitp),FORMAT=sform[0]),2L)
  csig_str                =         STRTRIM(STRING(ABS(csigp),FORMAT=sform[0]),2L)
  hfit_str                = shf_str+STRTRIM(STRING(ABS(hfitp),FORMAT=sform[0]),2L)
  hsig_str                =         STRTRIM(STRING(ABS(hsigp),FORMAT=sform[0]),2L)
  units_out               = '  '+['cm^(-3)',REPLICATE('km s^(-1)',4L),'']
  midf                    = ' +/- '
  core_xyout              = core_labs+cfit_str+midf[0]+csig_str+units_out
  halo_xyout              = halo_labs+hfit_str+midf[0]+hsig_str+units_out
  stat_xyout              = pre_pre_str[0]+fitstat_mid+fitstat_suf
  PRINT,pre_pre_str[0]
  FOR jj=0L, 4L DO PRINT,core_xyout[jj]
  IF (cf[0] NE 'MM') THEN PRINT,core_xyout[5] ELSE PRINT,pre_pre_str[0]
  PRINT,pre_pre_str[0]
  FOR jj=0L, 4L DO PRINT,halo_xyout[jj]
  IF (hf[0] NE 'MM') THEN PRINT,halo_xyout[5] ELSE PRINT,pre_pre_str[0]
  PRINT,pre_pre_str[0]
  FOR jj=0L, N_ELEMENTS(stat_xyout) - 1L DO PRINT,stat_xyout[jj]
  PRINT,pre_pre_str[0]
  IF (statb[0] GT 0) THEN BEGIN
    ;;  Print out beam info
    FOR jj=0L, 4L DO PRINT,beam_xyout[jj]
    IF (hf[0] NE 'MM') THEN PRINT,beam_xyout[5] ELSE PRINT,pre_pre_str[0]
    PRINT,pre_pre_str[0]
    FOR jj=0L, N_ELEMENTS(bstatxyout) - 1L DO PRINT,bstatxyout[jj]
    PRINT,pre_pre_str[0]
  ENDIF
  ;;--------------------------------------------------------------------------------------
  ;;  Define output parameters for returning to user
  ;;--------------------------------------------------------------------------------------
  fit_out                 = vdf_fit_out/ffac[0]
  bifitout                = [cfitp,hfitp]
  f_sigout                = [csigp,hsigp]
  ;;--------------------------------------------------------------------------------------
  ;;  Define 2D model function for core and halo
  ;;--------------------------------------------------------------------------------------
  ;;  Get 2D model results
  core_2d                 = CALL_FUNCTION(cfun[0],vx_km,vy_km,cfitp,REPLICATE(0,6))
  halo_2d                 = CALL_FUNCTION(hfun[0],vx_km,vy_km,hfitp,REPLICATE(0,6))
;  core_2d                 = CALL_FUNCTION(cfun[0],vpara,vperp,cfitp,REPLICATE(0,6))
;  halo_2d                 = CALL_FUNCTION(hfun[0],vpara,vperp,hfitp,REPLICATE(0,6))
  ;;  Get 1D cuts
  bicor_struc             = find_1d_cuts_2d_dist(core_2d,vx_km,vy_km,X_0=0d0,Y_0=0d0)
  bicor_para              = bicor_struc.X_1D_FXY         ;;  horizontal 1D cut
  bicor_perp              = bicor_struc.Y_1D_FXY         ;;  vertical 1D cut
  bihal_struc             = find_1d_cuts_2d_dist(halo_2d,vx_km,vy_km,X_0=0d0,Y_0=0d0)
  bihal_para              = bihal_struc.X_1D_FXY         ;;  horizontal 1D cut
  bihal_perp              = bihal_struc.Y_1D_FXY         ;;  vertical 1D cut
  ;;--------------------------------------------------------------------------------------
  ;;  Replot 2D contour of VDF with fit results
  ;;--------------------------------------------------------------------------------------
  JUMP_REPLOT:
  IF (both_on[0]) THEN BEGIN
    CASE both_plotted[0] OF
      0     :  f_name1 = f_name[0]+'_only_tot'      ;;  start with user default settings plus defining suffix
      1     :  f_name1 = f_name[0]+'_show_comps'    ;;  now show the components
      ELSE  :  STOP   ;;  Debug, should not happen!
    END
  ENDIF ELSE BEGIN
    IF (plottot_on[0]) THEN f_name1 = f_name[0]+'_only_tot' ELSE f_name1 = f_name[0]+'_show_comps'
  ENDELSE
  IF (save_on[0]) THEN BEGIN
    ;;  User wants to save --> do not plot to screen
    IF (now_save[0]) THEN BEGIN
      ;;  Now save plot
      popen,f_name1[0],_EXTRA=popen_str
    ENDIF ELSE BEGIN
      WSET,wind_ns[1]
      WSHOW,wind_ns[1]
    ENDELSE
  ENDIF ELSE BEGIN
    ;;  User did not want to save --> plot to screen
    WSET,wind_ns[1]
    WSHOW,wind_ns[1]
  ENDELSE
  IF (STRLOWCASE(!D.NAME) EQ 'ps') THEN BEGIN
    l_thick  = 4e0            ;;  Plot line thickness
    chthick  = 3e0            ;;  Character line thickness
  ENDIF ELSE BEGIN
    l_thick  = 2e0
    chthick  = 1.5e0
  ENDELSE
  ;;--------------------------------------------------------------------------------------
  ;;  Plot Contour
  ;;--------------------------------------------------------------------------------------
  general_vdf_contour_plot,vdf,velxyz,VFRAME=vframe,VEC1=vec1,VEC2=vec2,_EXTRA=extrakey
  ;;  Oplot Fit results
  IF (plottot_on[0] OR (both_on[0] AND both_plotted[0] EQ 0)) THEN BEGIN
    ;;------------------------------------------------------------------------------------
    ;;  Only plot total sum of fit lines
    ;;------------------------------------------------------------------------------------
    temp                    = [[bicor_para],[bihal_para],[bbeam_para]]
    bitot_para              = TOTAL(temp,2,/NAN,/DOUBLE)
    temp                    = [[bicor_perp],[bihal_perp],[bbeam_perp]]
    bitot_perp              = TOTAL(temp,2,/NAN,/DOUBLE)
    OPLOT,vpara,bitot_para,COLOR=t_cols[0],LINESTYLE=3,THICK=l_thick[0]
    OPLOT,vperp,bitot_perp,COLOR=t_cols[1],LINESTYLE=3,THICK=l_thick[0]
;    OPLOT,vpara*1d-3,bitot_para,COLOR=t_cols[0],LINESTYLE=3,THICK=l_thick[0]
;    OPLOT,vperp*1d-3,bitot_perp,COLOR=t_cols[1],LINESTYLE=3,THICK=l_thick[0]
    ;;  Output labels
    cutstruc   = dat_out.CUTS_DATA.CUT_LIM
    xyposi     = [3d-1*cutstruc.XRANGE[1],1d1*cutstruc.YRANGE[0]]
    XYOUTS,xyposi[0],xyposi[1],'Total Para.',/DATA,COLOR=t_cols[0],CHARTHICK=chthick[0]
    xyposi[1] *= 0.7
    XYOUTS,xyposi[0],xyposi[1],'Total Perp.',/DATA,COLOR=t_cols[1],CHARTHICK=chthick[0]
  ENDIF ELSE BEGIN
    ;;------------------------------------------------------------------------------------
    ;;  Plot fit lines individually
    ;;------------------------------------------------------------------------------------
    OPLOT,vpara,bicor_para,COLOR=c_cols[0],LINESTYLE=3,THICK=l_thick[0]
    OPLOT,vperp,bicor_perp,COLOR=c_cols[1],LINESTYLE=3,THICK=l_thick[0]
    OPLOT,vpara,bihal_para,COLOR=h_cols[0],LINESTYLE=3,THICK=l_thick[0]
    OPLOT,vperp,bihal_perp,COLOR=h_cols[1],LINESTYLE=3,THICK=l_thick[0]
;    OPLOT,vpara*1d-3,bicor_para,COLOR=c_cols[0],LINESTYLE=3,THICK=l_thick[0]
;    OPLOT,vperp*1d-3,bicor_perp,COLOR=c_cols[1],LINESTYLE=3,THICK=l_thick[0]
;    OPLOT,vpara*1d-3,bihal_para,COLOR=h_cols[0],LINESTYLE=3,THICK=l_thick[0]
;    OPLOT,vperp*1d-3,bihal_perp,COLOR=h_cols[1],LINESTYLE=3,THICK=l_thick[0]
    IF (statb[0] GT 0) THEN BEGIN
      ;;  Oplot beam fit
      OPLOT,vpara,bbeam_para,COLOR=b_cols[0],LINESTYLE=3,THICK=l_thick[0]
      OPLOT,vperp,bbeam_perp,COLOR=b_cols[1],LINESTYLE=3,THICK=l_thick[0]
;      OPLOT,vpara*1d-3,bbeam_para,COLOR=b_cols[0],LINESTYLE=3,THICK=l_thick[0]
;      OPLOT,vperp*1d-3,bbeam_perp,COLOR=b_cols[1],LINESTYLE=3,THICK=l_thick[0]
    ENDIF
    ;;  Output labels
    cutstruc   = dat_out.CUTS_DATA.CUT_LIM
    xyposi     = [3d-1*cutstruc.XRANGE[1],1d1*cutstruc.YRANGE[0]]
    XYOUTS,xyposi[0],xyposi[1],xylabpre[0]+' Para. Core',/DATA,COLOR=c_cols[0],CHARTHICK=chthick[0]
    xyposi[1] *= 0.7
    XYOUTS,xyposi[0],xyposi[1],xylabpre[0]+' Perp. Core',/DATA,COLOR=c_cols[1],CHARTHICK=chthick[0]
    xyposi[1] *= 0.7
    XYOUTS,xyposi[0],xyposi[1],xylabpre[1]+' Para. Halo',/DATA,COLOR=h_cols[0],CHARTHICK=chthick[0]
    xyposi[1] *= 0.7
    XYOUTS,xyposi[0],xyposi[1],xylabpre[1]+' Perp. Halo',/DATA,COLOR=h_cols[1],CHARTHICK=chthick[0]
    IF (statb[0] GT 0) THEN BEGIN
      ;;  Output beam info
      xyposi[1] *= 0.7
      XYOUTS,xyposi[0],xyposi[1],xylabpre[2]+' Para. Beam',/DATA,COLOR=b_cols[0],CHARTHICK=chthick[0]
      xyposi[1] *= 0.7
      XYOUTS,xyposi[0],xyposi[1],xylabpre[2]+' Perp. Beam',/DATA,COLOR=b_cols[1],CHARTHICK=chthick[0]
    ENDIF
  ENDELSE
  ;;--------------------------------------------------------------------------------------
  ;;  Print out fit results to plot
  ;;--------------------------------------------------------------------------------------
  xyposi     = [0.785,0.06,0.02]
  temp_outc  = STRTRIM(STRMID(core_xyout[0L:4L],2L),2L)
  temp_outh  = STRTRIM(STRMID(halo_xyout[0L:4L],2L),2L)
  IF (statb[0] GT 0) THEN BEGIN
    ;;------------------------------------------------------------------------------------
    ;;  Include beam fit
    ;;------------------------------------------------------------------------------------
    temp_outb  = STRTRIM(STRMID(beam_xyout[0L:4L],2L),2L)
    temp_out   = temp_outc+';  '+temp_outh+';  '+temp_outb
  ENDIF ELSE BEGIN
    temp_out   = temp_outc+';  '+temp_outh
  ENDELSE
  FOR jj=0L, 4L DO BEGIN
    xyposi[0] += xyposi[2]
    XYOUTS,xyposi[0],xyposi[1],temp_out[jj],CHARSIZE=.65,/NORMAL,ORIENTATION=90.,CHARTHICK=chthick[0]
  ENDFOR
  IF (cf[0] NE 'MM') THEN temp_out = STRTRIM(STRMID(core_xyout[5L],2L),2L) ELSE temp_out = ''
  IF (hf[0] NE 'MM') THEN BEGIN
    IF (temp_out[0] NE '') THEN temp_out[0] += ';  '+STRTRIM(STRMID(halo_xyout[5L],2L),2L) ELSE temp_out[0] = STRTRIM(STRMID(halo_xyout[5L],2L),2L)
  ENDIF
  IF (bf[0] NE 'MM') THEN BEGIN
    IF (temp_out[0] NE '') THEN temp_out[0] += ';  '+STRTRIM(STRMID(beam_xyout[5L],2L),2L) ELSE temp_out[0] = STRTRIM(STRMID(beam_xyout[5L],2L),2L)
  ENDIF
  IF (temp_out[0] NE '') THEN BEGIN
    xyposi[0] += xyposi[2]
    XYOUTS,xyposi[0],xyposi[1],temp_out[0],CHARSIZE=.65,/NORMAL,ORIENTATION=90.,CHARTHICK=chthick[0]
  ENDIF
  ;;--------------------------------------------------------------------------------------
  ;;  Output fit status etc.
  ;;--------------------------------------------------------------------------------------
  IF (statb[0] GT 0) THEN BEGIN
    ;;------------------------------------------------------------------------------------
    ;;  Include beam fit
    ;;------------------------------------------------------------------------------------
    fitstat_mid             = ['Model Fit Status  ','# of Iterations   ','Deg. of Freedom   ',$
                               'Chi-Squared       ','Red. Chi-Squared  ']+'[C+H,B] = '
    fstatstrout             = fitstat_suf+', '+bfitstatsuf
    temp_outc               = fitstat_mid+fstatstrout
    temp_out                = temp_outc[0]+';  '+temp_outc[1]+';  '+temp_outc[2]
    xyposi[0]              += xyposi[2]
    XYOUTS,xyposi[0],xyposi[1],temp_out[0],CHARSIZE=.65,/NORMAL,ORIENTATION=90.,CHARTHICK=chthick[0]
    temp_out                = temp_outc[4]
    xyposi[0]              += xyposi[2]
    XYOUTS,xyposi[0],xyposi[1],temp_out[0],CHARSIZE=.65,/NORMAL,ORIENTATION=90.,CHARTHICK=chthick[0]
  ENDIF ELSE BEGIN
    ;;------------------------------------------------------------------------------------
    ;;  Do not include beam fit info
    ;;------------------------------------------------------------------------------------
    fstatstrout             = fitstat_suf
    temp_outc               = fitstat_mid+fstatstrout
    temp_out                = temp_outc[0]+';  '+temp_outc[1]+';  '+temp_outc[2]+';  '+temp_outc[4]
    xyposi[0]              += xyposi[2]
    XYOUTS,xyposi[0],xyposi[1],temp_out[0],CHARSIZE=.65,/NORMAL,ORIENTATION=90.,CHARTHICK=chthick[0]
  ENDELSE
  ;;  Close file if saving
  IF (save_on[0]) THEN BEGIN
    IF (now_save[0]) THEN BEGIN
      ;;  Now save plot
      pclose
      IF (both_on[0]) THEN BEGIN
        ;;  Replot with components the 2nd time through
        both_plotted += 1b
        IF (both_plotted[0] LT 2) THEN GOTO,JUMP_REPLOT
      ENDIF
    ENDIF ELSE BEGIN
      now_save = 1b
      GOTO,JUMP_REPLOT
    ENDELSE
  ENDIF
ENDIF ELSE BEGIN
  ;;--------------------------------------------------------------------------------------
  ;;  Core+Halo Fit Failed --> define necessary parameters for output
  ;;--------------------------------------------------------------------------------------
  MESSAGE,errmsg[0],/INFORMATIONAL,/CONTINUE
  ;;  Make sure outputs are defined
  ch_trial                = -1
  IF (use1c4w_on[0]) THEN fac = 1d0/(1d-2*offset[0]) ELSE fac = 1d0/offset[0]
  IF (use_nowght_on[0]) THEN fac = 1d0
  IF (poisson_on[0]) THEN fac = 1d0/poffst[0]
  IF (SIZE(vdf_fit_out,/TYPE) EQ 0)      THEN fit_out     = REPLICATE(d,n_par[0],n_per[0]) ELSE fit_out  = vdf_fit_out/ffac[0]
  IF (SIZE(bifit,/TYPE) EQ 0)            THEN bifitout    = REPLICATE(d,12)                ELSE bifitout = bifit/[pfar,pfar]
  IF (SIZE(f_sigma,/TYPE) EQ 0)          THEN f_sigout    = REPLICATE(d,12)                ELSE f_sigout = (f_sigma*fac[0])/pfar
  IF (SIZE(chisq,/TYPE) EQ 0)            THEN chisq       = d
  IF (SIZE(dof,/TYPE) EQ 0)              THEN dof         = d
  IF (SIZE(iter,/TYPE) EQ 0)             THEN iter        = -1
  IF (SIZE(zerrors,/TYPE) EQ 0)          THEN zerrors     = REPLICATE(d,n_par[0],n_per[0])
  IF (SIZE(parinfo,/TYPE) EQ 0)          THEN parinfo     = def_pinf
  IF (SIZE(pfree_ind,/TYPE) EQ 0)        THEN pfree_ind   = -1
  IF (SIZE(npegged,/TYPE) EQ 0)          THEN npegged     = -1
ENDELSE
;;----------------------------------------------------------------------------------------
;;  Check if MPFIT left required parameters undefined on output
;;----------------------------------------------------------------------------------------
;;  Core + Halo Fit
IF (SIZE(status,/TYPE) EQ 0)     THEN status      = -1
IF (SIZE(fit_out,/TYPE) EQ 0)    THEN fit_out     = REPLICATE(d,n_par[0],n_per[0])
IF (SIZE(bifitout,/TYPE) EQ 0)   THEN bifitout    = REPLICATE(d,12)
IF (SIZE(f_sigout,/TYPE) EQ 0)   THEN f_sigout    = REPLICATE(d,12)
IF (SIZE(weights,/TYPE) EQ 0)    THEN weights     = REPLICATE(d,n_par[0],n_per[0])
IF (SIZE(chisq,/TYPE) EQ 0)      THEN chisq       = d
IF (SIZE(dof,/TYPE) EQ 0)        THEN dof         = d
IF (SIZE(iter,/TYPE) EQ 0)       THEN iter        = -1
IF (SIZE(zerrors,/TYPE) EQ 0)    THEN zerrors     = REPLICATE(d,n_par[0],n_per[0])
IF (SIZE(parinfo,/TYPE) EQ 0)    THEN parinfo     = def_pinf
IF (SIZE(pfree_ind,/TYPE) EQ 0)  THEN pfree_ind   = -1
IF (SIZE(npegged,/TYPE) EQ 0)    THEN npegged     = -1
;;  Beam Fit
IF (SIZE(statb,/TYPE) EQ 0)      THEN statb       = -1
IF (SIZE(beamout,/TYPE) EQ 0)    THEN beamout     = REPLICATE(d,n_par[0],n_per[0])
IF (SIZE(bfitp,/TYPE) EQ 0)      THEN bfitp       = REPLICATE(d,6)
IF (SIZE(bsigp,/TYPE) EQ 0)      THEN bsigp       = REPLICATE(d,6)
IF (SIZE(bweight,/TYPE) EQ 0)    THEN bweight     = REPLICATE(d,n_par[0],n_per[0])
IF (SIZE(chisqb,/TYPE) EQ 0)     THEN chisqb      = d
IF (SIZE(dofb,/TYPE) EQ 0)       THEN dofb        = d
IF (SIZE(biter,/TYPE) EQ 0)      THEN biter       = -1
IF (SIZE(berrors,/TYPE) EQ 0)    THEN berrors     = REPLICATE(d,n_par[0],n_per[0])
IF (SIZE(b_info,/TYPE) EQ 0)     THEN b_info      = def_binf
IF (SIZE(bfree_ind,/TYPE) EQ 0)  THEN bfree_ind   = -1
IF (SIZE(bpegged,/TYPE) EQ 0)    THEN bpegged     = -1
;;  Correct inputs for output

;;----------------------------------------------------------------------------------------
;;  Define return structure
;;----------------------------------------------------------------------------------------
out_tags                = ['X_IN','Y_IN','Z_IN','WEIGHTS','YFIT','FIT_PARAMS','SIG_PARAM',$
                           'CHISQ','DOF','N_ITER','STATUS','YERROR','FUNC','PARINFO',     $
                           'PFREE_INDEX','NPEGGED','Z_ORIG','OFFSET','NTRIALS']
beam_strc               = CREATE_STRUCT(out_tags,xb,yb,zb,bweight,beamout,bfitp,bsigp,      $
                                        chisqb[0],dofb[0],biter[0],statb[0],berrors,bfun[0],$
                                        b_info,bfree_ind,bpegged,vdf_2db,offset[0],b__trial[0])
c_h_struc               = CREATE_STRUCT(out_tags,x,y,z,weights,fit_out,bifitout,f_sigout, $
                                        chisq[0],dof[0],iter[0],status[0],zerrors,func[0],$
                                        parinfo,pfree_ind,npegged,vdf_2d,offset[0],ch_trial[0])
out_struc               = CREATE_STRUCT(['CORE_HALO','BEAM'],c_h_struc,beam_strc)
;;----------------------------------------------------------------------------------------
;;  Return to user
;;----------------------------------------------------------------------------------------

RETURN
END


