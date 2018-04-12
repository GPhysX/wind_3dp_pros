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
;               NA
;
;  CALLS:
;               lbw_window.pro
;               is_a_number.pro
;               is_a_3_vector.pro
;               sign.pro
;               unit_vec.pro
;               struct_value.pro
;               str_element.pro
;               general_vdf_contour_plot.pro
;               mpfit2dfun.pro
;               core_bm_halo_bm_fit.pro
;               core_bm_halo_kk_fit.pro
;               core_kk_halo_kk_fit.pro
;               core_ss_halo_kk_fit.pro
;               bimaxwellian_fit.pro
;               bikappa_fit.pro
;               biselfsimilar_fit.pro
;               find_1d_cuts_2d_dist.pro
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
;               
;
;  KEYWORDS:    
;               ***  INPUTS  ***
;               !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
;               ***  [all of the following have default settings]  ***
;               !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
;               VFRAME    :  [3]-Element [float/double] array defining the 3-vector
;                              velocity of the K'-frame relative to the K-frame [km/s]
;                              to use to transform the velocity distribution into the
;                              bulk flow reference frame
;                              [ Default = [10,0,0] ]
;               VEC1      :  [3]-Element vector to be used for "parallel" direction in
;                              a 3D rotation of the input data
;                              [e.g. see rotate_3dp_structure.pro]
;                              [ Default = [1.,0.,0.] ]
;               VEC2      :  [3]--Element vector to be used with VEC1 to define a 3D
;                              rotation matrix.  The new basis will have the following:
;                                X'  :  parallel to VEC1
;                                Z'  :  parallel to (VEC1 x VEC2)
;                                Y'  :  completes the right-handed set
;                              [ Default = [0.,1.,0.] ]
;               COREP     :  [6]-Element [numeric] array where each element is defined
;                              by the following quantities:
;                              PARAM[0]  = Core Number Density [cm^(-3)]
;                              PARAM[1]  = Core Parallel Thermal Speed [km/s]
;                              PARAM[2]  = Core Perpendicular Thermal Speed [km/s]
;                              PARAM[3]  = Core Parallel Drift Speed [km/s]
;                              PARAM[4]  = Core Perpendicular Drift Speed [km/s]
;                              PARAM[5]  = Core kappa, self-similar exponent, or not used
;                            If set, the routine will output 1D cuts of the model defined
;                              by the CFUNC keyword setting
;                              [Default = See code for default values]
;               HALOP     :  [6]-Element [numeric] array where each element is defined
;                              by the following quantities:
;                              PARAM[6]  = Halo Number Density [cm^(-3)]
;                              PARAM[7]  = Halo Parallel Thermal Speed [km/s]
;                              PARAM[8]  = Halo Perpendicular Thermal Speed [km/s]
;                              PARAM[9]  = Halo Parallel Drift Speed [km/s]
;                              PARAM[10] = Halo Perpendicular Drift Speed [km/s]
;                              PARAM[11] = Halo kappa, self-similar exponent, or not used
;                            If set, the routine will output 1D cuts of the model defined
;                              by the HFUNC keyword setting
;                              [Default = See code for default values]
;               CFUNC     :  Scalar [string] used to determine which model function to
;                              use for the core VDF
;                                'MM'  :  bi-Maxwellian VDF
;                                'KK'  :  bi-kappa VDF
;                                'SS'  :  bi-self-similar VDF
;                              [Default = 'MM']
;               HFUNC     :  Scalar [string] used to determine which model function to
;                              use for the halo VDF
;                                'MM'  :  bi-Maxwellian VDF
;                                'KK'  :  bi-kappa VDF
;                                'SS'  :  bi-self-similar VDF
;                              [Default = 'KK']
;               RMSTRAHL  :  Scalar [structure] definining the direction and angular
;                              range about defined direction to remove from data when
;                              considering which points that MPFIT.PRO will use in
;                              the fitting process.  The structure must have the
;                              following formatted tags:
;                                'DIR'  :  [3]-Element [numeric] array defining the
;                                            direction of the strahl (e.g., either
;                                            parallel or anti-parallel to Bo in the
;                                            anti-sunward direction)
;                                            [Default = -1d0*VEC1]
;                                'ANG'  :  Scalar [numeric] defining the angle [deg] about
;                                            DIR to ignore when fitting the data, i.e.,
;                                            this is the half-angle of the cone about
;                                            DIR that will be excluded
;                                            [Default = 45 degrees]
;                                'S_L'  :  Scalar [numeric] defining the minimum cutoff
;                                            speed [km/s] below which the data will still
;                                            be included in the fit
;                                            [Default = 1000 km/s]
;               V1ISB     :  Set to a positive or negative unity to indicate whether
;                              the strahl direction is parallel or anti-parallel,
;                              respectively, to the quasi-static magnetic field defined
;                              by VEC1.  If set, the routine will construct the RMSTRAHL
;                              structure with the default values for the tags ANG and
;                              E_L and the DIR tag will be set to V1ISB[0]*VEC1.
;                              [Default = FALSE]
;               _EXTRA    :  Other keywords accepted by general_vdf_contour_plot.pro
;               ***  OUTPUT  ***
;               !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
;               ***  [all the following changed on output]  ***
;               !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
;               OUTSTRC   :  Set to a named variable to return all the relevant data
;                              used to create the contour plot and cuts of the VDF
;
;   CHANGED:  1)  Continued to write routine
;                                                                   [04/10/2018   v1.0.0]
;
;   NOTES:      
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
;    LAST MODIFIED:  04/10/2018   v1.0.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

PRO wrapper_fit_vdf_2_sumof2funcs,vdf,velxyz,VFRAME=vframe,VEC1=vec1,VEC2=vec2,       $
                                  COREP=corep,HALOP=halop,CFUNC=cfunc,HFUNC=hfunc,    $
                                  RMSTRAHL=rmstrahl,V1ISB=v1isb,                      $
                                  _EXTRA=extrakey,                                    $
                                  OUTSTRC=out_struc

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
c_h_lab_str             = ['c','h']
c___lab_str             = [REPLICATE(c_h_lab_str[0],5L),'']
h___lab_str             = [REPLICATE(c_h_lab_str[1],5L),'']
fac_lab_st0             = ['par','per']
fac_lab_str             = ['',fac_lab_st0,fac_lab_st0,'']
pre_lab_str             = ['N_o','V_T','V_T','V_o','V_o','']
suf_lab_str             = [['     ','  ','  ','  ','  ']+'=  ','']
exp_lab_str             = ['','kappa    =  ','SS exp   =  ']
;;-------------------------------------------------------
;;  Define default labels
;;-------------------------------------------------------
;;  bi-Maxwellian core labels
core_bm_lab             = pre_pre_str[0]+pre_lab_str+c___lab_str+fac_lab_str+suf_lab_str
;;  bi-kappa core labels
core_kk_lab             = pre_pre_str[0]+pre_lab_str+c___lab_str+fac_lab_str+suf_lab_str
core_kk_lab[5]          = core_kk_lab[5]+exp_lab_str[1]
;;  bi-self-similar core labels
core_ss_lab             = pre_pre_str[0]+pre_lab_str+c___lab_str+fac_lab_str+suf_lab_str
core_ss_lab[5]          = core_ss_lab[5]+exp_lab_str[2]
;;  bi-Maxwellian halo labels
halo_bm_lab             = pre_pre_str[0]+pre_lab_str+h___lab_str+fac_lab_str+suf_lab_str
;;  bi-kappa halo labels
halo_kk_lab             = pre_pre_str[0]+pre_lab_str+h___lab_str+fac_lab_str+suf_lab_str
halo_kk_lab[5]          = halo_kk_lab[5]+exp_lab_str[1]
;;  bi-self-similar halo labels
halo_ss_lab             = pre_pre_str[0]+pre_lab_str+h___lab_str+fac_lab_str+suf_lab_str
halo_ss_lab[5]          = halo_ss_lab[5]+exp_lab_str[2]
;;-------------------------------------------------------
;;  Default fit parameter estimates
;;-------------------------------------------------------
def_bimax               = [5d0 ,20d2,20d2, 1d2,0d0,0d0]       ;;  Default bi-Maxwellian parameters
def_bikap               = [3d-1,50d2,50d2, 1d3,0d0,3d0]       ;;  Default bi-kappa " "
def_bi_ss               = [3d-1,50d2,50d2, 1d3,0d0,5d0]       ;;  Default bi-self-similar " "
def_param               = [def_bimax,def_bikap]
def_offst               = 1d18           ;;  Default offset to force data to be ≥ 1.0
def_param[0]            *= def_offst[0]
def_param[6]            *= def_offst[0]
np                      = N_ELEMENTS(def_param)
;;-------------------------------------------------------
;;  Define default PARINFO structure
;;-------------------------------------------------------
tags                    = ['VALUE','FIXED','LIMITED','LIMITS','TIED','MPSIDE']
def_pinfo0              = CREATE_STRUCT(tags,d,0b,[0b,0b],[0d0,0d0],'',3)
def_pinf                = REPLICATE(def_pinfo0[0],np)
def_pinf.VALUE          = def_param
autoderiv               = 0b              ;;  Force explicit derivatives
;;  Define default limits for parameters
def_vthc_lim            = [5d0,1d4]       ;;  5 km/s ≤ V_Tcj ≤ 10000 km/s
def_vthh_lim            = [5d0,2d4]       ;;  5 km/s ≤ V_Thj ≤ 20000 km/s
def_v_oc_lim            = [-1d0,1d0]*1d3  ;;  -1000 km/s ≤ V_ocj ≤ +1000 km/s
def_v_oh_lim            = [-1d0,1d0]*1d4  ;;  -10000 km/s ≤ V_ocj ≤ +10000 km/s
def_kapp_lim            = [3d0/2d0,4d1]   ;;  3/2 ≤ kappa ≤ 40
def_ssex_lim            = [2d0,1d1]       ;;  self-similar exponent:  2 ≤ p ≤ 10
;;  Limit core thermal speeds [km/s]
def_pinf[1].LIMITED[*]  = 1b
def_pinf[2].LIMITED[*]  = 1b
def_pinf[1].LIMITS[0]   = def_vthc_lim[0]
def_pinf[1].LIMITS[1]   = def_vthc_lim[1]
def_pinf[2].LIMITS[0]   = def_vthc_lim[0]
def_pinf[2].LIMITS[1]   = def_vthc_lim[1]
;;  Limit halo thermal speeds [km/s]
def_pinf[7].LIMITED[*]  = 1b
def_pinf[8].LIMITED[*]  = 1b
def_pinf[7].LIMITS[0]   = def_vthh_lim[0]
def_pinf[7].LIMITS[1]   = def_vthh_lim[1]
def_pinf[8].LIMITS[0]   = def_vthh_lim[0]
def_pinf[8].LIMITS[1]   = def_vthh_lim[1]
;;  Limit core drift speeds [km/s]
def_pinf[3].LIMITED[*]  = 1b
def_pinf[4].LIMITED[*]  = 1b
def_pinf[3].LIMITS[0]   = def_v_oc_lim[0]
def_pinf[3].LIMITS[1]   = def_v_oc_lim[1]
def_pinf[4].LIMITS[0]   = def_v_oc_lim[0]
def_pinf[4].LIMITS[1]   = def_v_oc_lim[1]
;;  Limit halo drift speeds [km/s]
def_pinf[9].LIMITED[*]  = 1b
def_pinf[10].LIMITED[*] = 1b
def_pinf[9].LIMITS[0]   = def_v_oh_lim[0]
def_pinf[9].LIMITS[1]   = def_v_oh_lim[1]
def_pinf[10].LIMITS[0]  = def_v_oh_lim[0]
def_pinf[10].LIMITS[1]  = def_v_oh_lim[1]
;;  Limit kappa values [default is bi-Maxwellian plus kappa]
def_pinf[11].LIMITED[*] = 1b
def_pinf[11].LIMITS[0]  = def_kapp_lim[0]
def_pinf[11].LIMITS[1]  = def_kapp_lim[1]
;;  Fix unused parameter
def_pinf[5].FIXED       = 1b
;;-------------------------------------------------------
;;  Define default RMSTRAHL structure
;;-------------------------------------------------------
tags                    = ['DIR','ANG','S_L']
def_rmstrahl            = CREATE_STRUCT(tags,[-1d0,0d0,0d0],45d0,1d3)
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
win_ttl                 = 'VDF Initial Guess'
win_str                 = {RETAIN:2,XSIZE:xywsz[0],YSIZE:xywsz[1],TITLE:win_ttl[0],XPOS:10,YPOS:10}
lbw_window,WIND_N=wind_ns[0],NEW_W=new_w_0[0],_EXTRA=win_str
win_ttl                 = 'VDF Fit Results'
win_str                 = {RETAIN:2,XSIZE:xywsz[0],YSIZE:xywsz[1],TITLE:win_ttl[0],XPOS:20,YPOS:10}
lbw_window,WIND_N=wind_ns[1],NEW_W=new_w_1[0],_EXTRA=win_str
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
      func      = 'core_bm_halo_bm_fit'
      cfun      = 'bimaxwellian_fit'
      hfun      = 'bimaxwellian_fit'
      halo_labs = halo_bm_lab
      xylabpre  = ['Bi-Max.','Bi-Max.']
    END
    'KK'  :  BEGIN
      CASE cf[0] OF
        'MM'  :  func = 'core_bm_halo_kk_fit'
        'KK'  :  func = 'core_kk_halo_kk_fit'
        'SS'  :  func = 'core_ss_halo_kk_fit'
        ELSE  :  func = 'core_bm_halo_kk_fit'
      ENDCASE
      halo_labs = halo_kk_lab
      cfun      = (['bimaxwellian_fit','bikappa_fit','biselfsimilar_fit'])[(WHERE(cf[0] EQ ['MM','KK','SS']))[0]]
      hfun      = 'bikappa_fit'
      xyl0      = (['Bi-Max.','Bi-kappa','Bi-SS'])[(WHERE(cf[0] EQ ['MM','KK','SS']))[0]]
      xylabpre  = [xyl0[0],'Bi-kappa']
    END
    ELSE  :  BEGIN
      func      = 'core_bm_halo_kk_fit'
      halo_labs = halo_kk_lab
      cfun      = 'bimaxwellian_fit'
      hfun      = 'bikappa_fit'
      xylabpre  = ['Bi-Max.','Bi-kappa']
    END
  ENDCASE
ENDIF ELSE BEGIN
  hf        = 'KK'
  func      = 'core_bm_halo_kk_fit'
  halo_labs = halo_kk_lab
  cfun      = 'bimaxwellian_fit'
  hfun      = 'bikappa_fit'
  xylabpre  = ['Bi-Max.','Bi-kappa']
ENDELSE
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
    def_pinf[5].LIMITED[*]  = 1b
    def_pinf[5].LIMITS[0]   = def_kapp_lim[0]
    def_pinf[5].LIMITS[1]   = def_kapp_lim[1]
  END
  'core_ss_halo_kk_fit'  :  BEGIN
    def_param[5]            = 4d0
    def_pinf[5].FIXED       = 0b
    def_pinf[5].LIMITED[*]  = 1b
    def_pinf[5].LIMITS[0]   = def_ssex_lim[0]
    def_pinf[5].LIMITS[1]   = def_ssex_lim[1]
  END
  ELSE  :  STOP   ;;  Debug
ENDCASE
;;  Redefine default parameters
def_pinf.VALUE          = def_param
;;  Check COREP
test                    = (N_ELEMENTS(corep) EQ 6) AND is_a_number(corep,/NOMSSG)
IF (test[0]) THEN BEGIN
  pcore = DOUBLE(corep)
  ;;  Check limits [*** Required to avoid conflicts in MPFIT.PRO ***]
  pcore[1]  = pcore[1] > def_vthc_lim[0]
  pcore[2]  = pcore[2] < def_vthc_lim[1]
  pcore[3]  = pcore[3] > def_v_oc_lim[0]
  pcore[4]  = pcore[4] < def_v_oc_lim[1]
  IF (cf[0] NE 'MM') THEN BEGIN
    ;;  Limit kappa or self-similar exponent accordingly
    pcore[5]  = pcore[5] > def_pinf[5].LIMITS[0]
    pcore[5]  = pcore[5] < def_pinf[5].LIMITS[1]
  ENDIF
ENDIF ELSE BEGIN
  ;;  Use defaults for core
  pcore = def_param[0L:5L]
ENDELSE
;;  Check HALOP
test                    = (N_ELEMENTS(halop) EQ 6) AND is_a_number(halop,/NOMSSG)
IF (test[0]) THEN BEGIN
  phalo = DOUBLE(halop)
  ;;  Check limits [*** Required to avoid conflicts in MPFIT.PRO ***]
  phalo[1]  = phalo[1] > def_vthh_lim[0]
  phalo[2]  = phalo[2] < def_vthh_lim[1]
  phalo[3]  = phalo[3] > def_v_oh_lim[0]
  phalo[4]  = phalo[4] < def_v_oh_lim[1]
  IF (hf[0] NE 'MM') THEN BEGIN
    ;;  Limit kappa or self-similar exponent accordingly
    phalo[5]  = phalo[5] > def_pinf[11].LIMITS[0]
    phalo[5]  = phalo[5] < def_pinf[11].LIMITS[1]
  ENDIF
ENDIF ELSE BEGIN
  ;;  Use defaults for halo
  phalo = def_param[6L:11L]
ENDELSE
;;  Check V1ISB
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
;;  Check RMSTRAHL
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
;;----------------------------------------------------------------------------------------
;;  Plot 2D contour of VDF and return data
;;----------------------------------------------------------------------------------------
WSET,wind_ns[0]
WSHOW,wind_ns[0]
;;  Check if user wishes to ignore the strahl component
IF (rm_strahl_on[0]) THEN BEGIN
  ;;  Convert vectors to latitude/longitude
  u_vxyz                  = unit_vec(velxyz)
  u_vmag                  = mag__vec(velxyz,/NAN)
  invv_the                = ASIN(u_vxyz[*,2])*18d1/!DPI
  invv_phi                = ATAN(u_vxyz[*,1],u_vxyz[*,0])*18d1/!DPI
  uv_st                   = strahl_str.DIR
  uvst_the                = ASIN(uv_st[2])*18d1/!DPI
  uvst_phi                = ATAN(uv_st[1],uv_st[0])*18d1/!DPI
  uvst_tra                = uvst_the[0] + [-1d0,1d0]*strahl_str.ANG[0]
  uvst_pra                = uvst_phi[0] + [-1d0,1d0]*strahl_str.ANG[0]
  ;;  Define tests
  test_the                = (invv_the GE MIN(uvst_tra,/NAN)) AND (invv_the LE MAX(uvst_tra,/NAN))
  test_phi                = (invv_phi GE MIN(uvst_pra,/NAN)) AND (invv_phi LE MAX(uvst_pra,/NAN))
  test_mag                = (u_vmag GE ABS(strahl_str.S_L[0]))
  test_all                = test_the AND test_phi AND test_mag
  bad_strahl              = WHERE(test_all,bd_strahl,COMPLEMENT=good_strahl,NCOMPLEMENT=gd_strahl)
  IF (bd_strahl[0] GT 0 AND bd_strahl[0] LT N_ELEMENTS(vdf)) THEN BEGIN
    vdf2                    = vdf
    velxyz2                 = velxyz
    vdf2[bad_strahl]        = d
    velxyz2[bad_strahl,*]   = d
    ;;  Check if we need to alter PARINFO limits
    test                    = is_a_3_vector(vec1,V_OUT=vv1,/NOMSSG)
    IF (test[0]) THEN BEGIN
      ;;  VEC1 is set --> determine side to ignore
      uv_1                    = REFORM(unit_vec(vv1))
      uvst                    = REFORM(unit_vec(uv_st))
      v1_dot_uvst             = TOTAL(uv_1*uvst,/NAN)
      para_bo                 = (v1_dot_uvst[0] GE 0)
      IF (para_bo[0]) THEN BEGIN
        ;;  strahl is parallel to Bo
        pcore[3]                = pcore[3] < ABS(strahl_str.S_L[0])
        phalo[3]                = phalo[3] < ABS(strahl_str.S_L[0])
        def_pinf[3].LIMITS[1]   = def_pinf[3].LIMITS[1] < ABS(strahl_str.S_L[0])
        def_pinf[9].LIMITS[1]   = def_pinf[9].LIMITS[1] < ABS(strahl_str.S_L[0])
      ENDIF ELSE BEGIN
        ;;  strahl is anti-parallel to Bo
        pcore[3]                = pcore[3] > (-1d0*ABS(strahl_str.S_L[0]))
        phalo[3]                = phalo[3] > (-1d0*ABS(strahl_str.S_L[0]))
        def_pinf[3].LIMITS[0]   = def_pinf[3].LIMITS[0] > (-1d0*ABS(strahl_str.S_L[0]))
        def_pinf[9].LIMITS[0]   = def_pinf[9].LIMITS[0] > (-1d0*ABS(strahl_str.S_L[0]))
      ENDELSE
    ENDIF
;    ;;  Plot without strahl data
;    general_vdf_contour_plot,vdf2,velxyz2,VFRAME=vframe,VEC1=vec1,VEC2=vec2,_EXTRA=extrakey,  $
;                             BIMAX=pcore,BIKAP=phalo,DAT_OUT=dat_out
    general_vdf_contour_plot,vdf,velxyz,VFRAME=vframe,VEC1=vec1,VEC2=vec2,_EXTRA=extrakey,  $
                             BIMAX=pcore,BIKAP=phalo,DAT_OUT=dat_out
  ENDIF ELSE BEGIN
    ;;  Bad input --> do not remove strahl and plot normally
    rm_strahl_on = 0b
    general_vdf_contour_plot,vdf,velxyz,VFRAME=vframe,VEC1=vec1,VEC2=vec2,_EXTRA=extrakey,  $
                             BIMAX=pcore,BIKAP=phalo,DAT_OUT=dat_out
  ENDELSE
ENDIF ELSE BEGIN
  ;;  Call normally without excluding any data
  general_vdf_contour_plot,vdf,velxyz,VFRAME=vframe,VEC1=vec1,VEC2=vec2,_EXTRA=extrakey,  $
                           BIMAX=pcore,BIKAP=phalo,DAT_OUT=dat_out
ENDELSE
IF (SIZE(dat_out,/TYPE) NE 8) THEN BEGIN
  MESSAGE,'Failure at plot level output!',/INFORMATION,/CONTINUE
  RETURN        ;;  Failed to plot!!!
ENDIF
;;  Define input parameters
param                   = [pcore,phalo]
;;----------------------------------------------------------------------------------------
;;  Setup fit for VDFs
;;----------------------------------------------------------------------------------------
vdf_2d                  = dat_out.CONT_DATA.VDF_2D          ;;  [# cm^(-3) km^(-3) s^(+3)]
vpara                   = dat_out.CONT_DATA.VXGRID*1d3      ;;  Mm --> km
vperp                   = dat_out.CONT_DATA.VXGRID*1d3      ;;  Mm --> km
offset                  = 1d0/MIN(ABS(vdf_2d),/NAN)         ;;  Constant by which to offset data
n_vdf                   = N_ELEMENTS(vdf_2d)
n_par                   = N_ELEMENTS(vpara)
n_per                   = N_ELEMENTS(vperp)
;;  Check output so far
test                    = (FINITE(offset) EQ 0) OR (offset[0] LE 0) OR (n_vdf[0] LT 20)
IF (test[0]) THEN BEGIN
  MESSAGE,'Failure after plot level output [insufficient finite output]!',/INFORMATION,/CONTINUE
  RETURN        ;;  Failed to plot!!!
ENDIF
;;  Shift densities
param[[0L,6L]]         *= offset[0]
;;  Define PARINFO structure
parinfo                 = def_pinf
parinfo.VALUE           = param                             ;;  Redefine parameters
;;  Define error as 1% of data
vdf_2dp                 = vdf_2d*offset[0]                  ;;  Force values to > 1.0
zerr                    = 1d-2*vdf_2dp
weights                 = 1d0/zerr^2d0                      ;;  Gaussian Weights
;;  Remove negatives and zeros
bad                     = WHERE(FINITE(vdf_2dp) EQ 0 OR vdf_2dp LE 0,bd,COMPLEMENT=good,NCOMPLEMENT=gd)
test                    = (1d0*bd[0] GT 9d-1*n_vdf[0])
IF (test[0]) THEN BEGIN
  ;;  Too many "bad" data points --> Failure!
  MESSAGE,'Failure:  Too many bad data points!',/INFORMATION,/CONTINUE
  RETURN        ;;  Failed to plot!!!
ENDIF ELSE BEGIN
  IF (bd[0] GT 0) THEN BEGIN
    ;;  Success!
    vdf_2dp[bad]            = 0d0
    zerr[bad]               = d       ;;  MPFIT.PRO does not allow 0.0 errrors if others are finite
    weights[bad]            = 0d0     ;;  Zero for weights will result in ignoring those points
  ENDIF ELSE BEGIN
    ;;  All "bad" data points --> Failure!
    MESSAGE,'Failure:  All bad data points!',/INFORMATION,/CONTINUE
    RETURN        ;;  Failed to plot!!!
  ENDELSE
ENDELSE
;;----------------------------------------------------------------------------------------
;;  Fit to model 2D function
;;----------------------------------------------------------------------------------------
x                       = vpara
y                       = vperp
z                       = vdf_2dp
bifit                   = mpfit2dfun(func[0],x,y,z,zerr,param,PARINFO=parinfo,PERROR=f_sigma,    $
                                     BESTNORM=chisq,DOF=dof,STATUS=status,NITER=iter,            $
                                     YFIT=vdf_fit_out,/QUIET,WEIGHTS=weights,/NAN,               $
                                     FTOL=1d-14,GTOL=1d-14,ERRMSG=errmsg,BEST_RESID=zerrors,     $
                                     PFREE_INDEX=pfree_ind,NPEGGED=npegged,                      $
                                     AUTODERIVATIVE=autoderiv                                    )
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
normal[[0L,6L]]        /= offset[0]
IF (status[0] GT 0) THEN BEGIN  ;;  TRUE = Success!  -->  Print out info
  ;;  Success!  -->  Print out info
  cfitp                   = bifit[0L:5L]
  hfitp                   = bifit[6L:11L]
  csigp                   = f_sigma[0L:5L]
  hsigp                   = f_sigma[6L:11L]
  ;;  Renormalize densities
  cfitp[0]               /= offset[0]
  hfitp[0]               /= offset[0]
  csigp[0]               /= offset[0]
  hsigp[0]               /= offset[0]
  ;;  Print out fit results
  PRINT,pre_pre_str[0]
  PRINT,core_labs[0],cfitp[0],'   +/- ',ABS(csigp[0]),'  cm^(-3)'
  PRINT,core_labs[1],cfitp[1],'   +/- ',ABS(csigp[1]),'  km s^(-1)'
  PRINT,core_labs[2],cfitp[2],'   +/- ',ABS(csigp[2]),'  km s^(-1)'
  PRINT,core_labs[3],cfitp[3],'   +/- ',ABS(csigp[3]),'  km s^(-1)'
  PRINT,core_labs[4],cfitp[4],'   +/- ',ABS(csigp[4]),'  km s^(-1)'
  IF (cf[0] NE 'MM') THEN PRINT,core_labs[5],cfitp[5],'   +/- ',ABS(csigp[5]) ELSE PRINT,pre_pre_str[0]
  PRINT,pre_pre_str[0]
  PRINT,halo_labs[0],hfitp[0],'   +/- ',ABS(hsigp[0]),'  cm^(-3)'
  PRINT,halo_labs[1],hfitp[1],'   +/- ',ABS(hsigp[1]),'  km s^(-1)'
  PRINT,halo_labs[2],hfitp[2],'   +/- ',ABS(hsigp[2]),'  km s^(-1)'
  PRINT,halo_labs[3],hfitp[3],'   +/- ',ABS(hsigp[3]),'  km s^(-1)'
  PRINT,halo_labs[4],hfitp[4],'   +/- ',ABS(hsigp[4]),'  km s^(-1)'
  IF (hf[0] NE 'MM') THEN PRINT,halo_labs[5],hfitp[5],'   +/- ',ABS(hsigp[5]) ELSE PRINT,pre_pre_str[0]
  PRINT,pre_pre_str[0]
  PRINT,pre_pre_str[0]+'Model Fit Status                    = ',status[0]
  PRINT,pre_pre_str[0]+'Number of Iterations                = ',iter[0]
  PRINT,pre_pre_str[0]+'Degrees of Freedom                  = ',dof[0]
  PRINT,pre_pre_str[0]+'Chi-Squared                         = ',chisq[0]
  PRINT,pre_pre_str[0]+'Reduced Chi-Squared                 = ',chisq[0]/dof[0]
  PRINT,pre_pre_str[0]
  ;;--------------------------------------------------------------------------------------
  ;;  Define output parameters for returning to user
  ;;--------------------------------------------------------------------------------------
  fit_out                 = vdf_fit_out/offset[0]
  bifitout                = [cfitp,hfitp]
  f_sigout                = [csigp,hsigp]
  ;;--------------------------------------------------------------------------------------
  ;;  Replot 2D contour of VDF with fit results
  ;;--------------------------------------------------------------------------------------
  ;;  Get 2D model results
  core_2d                 = CALL_FUNCTION(cfun[0],vpara,vperp,cfitp,REPLICATE(0,6))
  halo_2d                 = CALL_FUNCTION(hfun[0],vpara,vperp,hfitp,REPLICATE(0,6))
  ;;  Get 1D cuts
  bicor_struc   = find_1d_cuts_2d_dist(core_2d,vpara,vperp,X_0=0d0,Y_0=0d0)
  bicor_para    = bicor_struc.X_1D_FXY         ;;  horizontal 1D cut
  bicor_perp    = bicor_struc.Y_1D_FXY         ;;  vertical 1D cut
  bihal_struc   = find_1d_cuts_2d_dist(halo_2d,vpara,vperp,X_0=0d0,Y_0=0d0)
  bihal_para    = bihal_struc.X_1D_FXY         ;;  horizontal 1D cut
  bihal_perp    = bihal_struc.Y_1D_FXY         ;;  vertical 1D cut
  ;;  Plot Contour
  WSET,wind_ns[1]
  WSHOW,wind_ns[1]
  general_vdf_contour_plot,vdf,velxyz,VFRAME=vframe,VEC1=vec1,VEC2=vec2,_EXTRA=extrakey
  ;;  Oplot Fit results
  OPLOT,vpara*1d-3,bicor_para,COLOR=200,LINESTYLE=3,THICK=2
  OPLOT,vperp*1d-3,bicor_perp,COLOR= 75,LINESTYLE=3,THICK=2
  OPLOT,vpara*1d-3,bihal_para,COLOR=225,LINESTYLE=3,THICK=2
  OPLOT,vperp*1d-3,bihal_perp,COLOR= 30,LINESTYLE=3,THICK=2
  ;;  Output labels
  cutstruc   = dat_out.CUTS_DATA.CUT_LIM
  xyposi     = [3d-1*cutstruc.XRANGE[1],6d0*cutstruc.YRANGE[0]]
  XYOUTS,xyposi[0],xyposi[1],xylabpre[0]+' Para.',/DATA,COLOR=200
  xyposi[1] *= 0.7
  XYOUTS,xyposi[0],xyposi[1],xylabpre[0]+' Perp.',/DATA,COLOR= 75
  xyposi[1] *= 0.7
  XYOUTS,xyposi[0],xyposi[1],xylabpre[1]+' Para.',/DATA,COLOR=225
  xyposi[1] *= 0.7
  XYOUTS,xyposi[0],xyposi[1],xylabpre[1]+' Perp.',/DATA,COLOR= 30
ENDIF ELSE BEGIN
  ;;  Failed!
  MESSAGE,errmsg[0],/INFORMATIONAL,/CONTINUE
  ;;  Make sure outputs are defined
  IF (SIZE(vdf_fit_out,/TYPE) EQ 0)      THEN fit_out     = REPLICATE(d,n_par[0],n_per[0]) ELSE fit_out  = vdf_fit_out/offset[0]
  IF (SIZE(bifit,/TYPE) EQ 0)            THEN bifitout    = REPLICATE(d,12)                ELSE bifitout = bifit*normal
  IF (SIZE(f_sigma,/TYPE) EQ 0)          THEN f_sigout    = REPLICATE(d,12)                ELSE f_sigout = f_sigma*normal
  IF (SIZE(chisq,/TYPE) EQ 0)            THEN chisq       = d
  IF (SIZE(dof,/TYPE) EQ 0)              THEN dof         = d
  IF (SIZE(iter,/TYPE) EQ 0)             THEN iter        = -1
  IF (SIZE(zerrors,/TYPE) EQ 0)          THEN zerrors     = REPLICATE(d,n_par[0],n_per[0])
  IF (SIZE(parinfo,/TYPE) EQ 0)          THEN parinfo     = def_pinf
  IF (SIZE(pfree_ind,/TYPE) EQ 0)        THEN pfree_ind   = -1
  IF (SIZE(npegged,/TYPE) EQ 0)          THEN npegged     = -1
ENDELSE
;;----------------------------------------------------------------------------------------
;;  Define return structure
;;----------------------------------------------------------------------------------------
out_tags                = ['X_IN','Y_IN','Z_IN','YFIT','FIT_PARAMS','SIG_PARAM','CHISQ','DOF','N_ITER','STATUS','YERROR','FUNC','PARINFO','PFREE_INDEX','NPEGGED']
out_struc               = CREATE_STRUCT(out_tags,x,y,z,fit_out,bifitout,f_sigout,chisq[0],$
                                        dof[0],iter[0],status[0],zerrors,func[0],parinfo, $
                                        pfree_ind,npegged)
;;----------------------------------------------------------------------------------------
;;  Return to user
;;----------------------------------------------------------------------------------------

RETURN
END






;test                    = (bd[0] GT 0) AND (1d0*bd[0] GT 9d-1*n_vdf[0])
