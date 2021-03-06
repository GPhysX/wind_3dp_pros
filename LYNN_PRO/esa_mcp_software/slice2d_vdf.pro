;+
;*****************************************************************************************
;
;  FUNCTION :   slice2d_vdf.pro
;  PURPOSE  :   This routine uses Delaunay triangulation to take a 2D slice through
;                 a 3D velocity distribution function (VDF) through the origin.
;
;  CALLED BY:   
;               NA
;
;  INCLUDES:
;               NA
;
;  CALLS:
;               is_a_number.pro
;               is_a_3_vector.pro
;               mag__vec.pro
;               unit_vec.pro
;
;  REQUIRES:    
;               1)  UMN Modified Wind/3DP IDL Libraries
;
;  INPUT:
;               VELS       :  [K,3]-Element [numeric] array of particle 3-velocities
;                               for each value of DATA
;                               [e.g., km/s]
;               DATA       :  [K]-Element [numeric] array of phase space densities
;                               describing a velocity distribution function (VDF)
;                               [e.g., s^(3) cm^(-3) km^(-3)]
;
;  EXAMPLES:    
;               [calling sequence]
;               slice_2d = slice2d_vdf(vels, data [,VLIM=vlim] [,NGRID=ngrid] [,C_LOG=c_log] $
;                                      [,F3D_QH=f3d_qh])
;
;  KEYWORDS:    
;               VLIM       :  Scalar [numeric] defining the speed limit for the velocity
;                               grids over which to triangulate the data [km/s]
;                               [Default = max vel. magnitude]
;               NGRID      :  Scalar [numeric] defining the number of grid points in each
;                               direction to use when triangulating the data.  The input
;                               will be limited to values between 30 and 300.
;                               [Default = 101]
;               C_LOG      :  If set, routine assumes input DATA is in logarithmic (base-10)
;                               instead of linear space, which really only changes
;                               some testing/error handling for TRIANGULATE.PRO and
;                               TRIGRID.PRO
;                               [Default = FALSE]
;               F3D_QH     :  Set to a named variable to return the 3D array of phase
;                               space densities triangulated onto a regular grid
;
;   CHANGED:  1)  Addressed an issue that arose in this routine but not when entering
;                   all commands one-by-one on the command line.  The issue arose from
;                   the test that (DATA > 0), which caused problems at low energies
;                   and resulted in an unrealistic extrapolation to large phase space
;                   densities
;                                                                   [05/30/2017   v1.0.1]
;             2)  Fixed the X vs. Z output (was incorrectly Z vs. X)
;                                                                   [08/12/2017   v1.0.2]
;             3)  Added keyword:  F3D_QH
;                                                                   [04/12/2019   v1.0.3]
;
;   NOTES:      
;               1)  User should not call this routine
;               2)  Routine assumes user already transformed into rest frame and rotated
;                     into coordinate basis of interest
;               3)  The velocity and VDF units need not be the examples suggested in each
;                     case so long as they are consistent (i.e., use the same units for
;                     VELS as VLIM).
;               4)  The C_LOG keyword assumes a base-10 logarithm was used, not natural
;                     log (i.e., not base e).
;
;  REFERENCES:  
;               1)  See IDL's documentation for QHULL.PRO and QGRID3.PRO at:
;                     https://harrisgeospatial.com/docs/qhull.html
;                     https://harrisgeospatial.com/docs/QGRID3.html
;
;   CREATED:  05/27/2017
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  04/12/2019   v1.0.3
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

FUNCTION slice2d_vdf,vels,data,VLIM=vlim,NGRID=ngrid,C_LOG=c_log,F3D_QH=f3d_qh

;;----------------------------------------------------------------------------------------
;;  Define some constants and dummy variables
;;----------------------------------------------------------------------------------------
f              = !VALUES.F_NAN
d              = !VALUES.D_NAN
toler          = 1d-6                ;;  Tolerance for jitter
;;  Dummy error messages
no_inpt_msg    = 'User must supply VELS and DATA as arrays of 3-vector velocities and VDF values...'
badform_msg    = 'VELS and DATA must be a [K,3]-element and a [K]-element [numeric] array, respectively'
;;----------------------------------------------------------------------------------------
;;  Check input
;;----------------------------------------------------------------------------------------
test           = (N_PARAMS() LT 2) OR (is_a_number(data,/NOMSSG) EQ 0) OR  $
                 (is_a_3_vector(vels,V_OUT=swfv,/NOMSSG) EQ 0)
IF (test[0]) THEN BEGIN
  ;;  Incorrect inputs --> exit without plotting
  MESSAGE,no_inpt_msg[0],/INFORMATIONAL,/CONTINUE
  RETURN,0b
ENDIF
;;  Check dimensions to make sure user did not enter a 2D DATA array
szdv           = SIZE(swfv,/DIMENSIONS)
szdd           = SIZE(data,/DIMENSIONS)
test           = (N_ELEMENTS(szdd) NE 1) OR (N_ELEMENTS(data) NE szdv[0])
IF (test[0]) THEN BEGIN
  ;;  Incorrect input formats --> exit without plotting
  MESSAGE,badform_msg[0],/INFORMATIONAL,/CONTINUE
  RETURN,0b
ENDIF
;;  Define params
kk             = szdv[0]                     ;;  # of vectors
dat_1d         = REFORM(data,kk[0])          ;;  [K]-Element array
;;----------------------------------------------------------------------------------------
;;  Check keywords
;;----------------------------------------------------------------------------------------
;;  Check VLIM
test           = (N_ELEMENTS(vlim) EQ 0) OR (is_a_number(vlim,/NOMSSG) EQ 0)
IF (test[0]) THEN BEGIN
  smax           = MAX(SQRT(TOTAL(swfv^2,2L,/NAN)),/NAN)
ENDIF ELSE BEGIN
  smax           = FLOAT(vlim[0])
ENDELSE
;;  Check NGRID
test           = (N_ELEMENTS(ngrid) EQ 0) OR (is_a_number(ngrid,/NOMSSG) EQ 0)
IF (test[0]) THEN nm = 101L ELSE nm = (LONG(ngrid[0]) > 30L) < 300L
;;  Check C_LOG
test           = (N_ELEMENTS(c_log) EQ 1) AND KEYWORD_SET(c_log)
IF (test[0]) THEN clog_on = 1b ELSE clog_on = 0b
;;----------------------------------------------------------------------------------------
;;  Define inputs for QHULL.PRO and QGRID3.PRO
;;----------------------------------------------------------------------------------------
;;  Define jitter about mean (to avoid colinear points error)
jitter         = REPLICATE(d,kk[0],3L)
FOR j=0L, 2L DO jitter[*,j] = 2d0*(RANDOMU(seed,kk[0],/DOUBLE) - 5d-1)*toler[0]
;;  Add jitter to velocities
vel_smear      = swfv + jitter
;;  Check for non-finite values
test_vdf       = FINITE(dat_1d)
;IF (clog_on[0]) THEN test_vdf = FINITE(dat_1d) ELSE test_vdf = FINITE(dat_1d) AND (dat_1d GT 0)
test           = FINITE(vel_smear[*,0]) AND FINITE(vel_smear[*,1]) AND $
                 FINITE(vel_smear[*,2]) AND test_vdf
good_in        = WHERE(test,gd_in,COMPLEMENT=bad_in,NCOMPLEMENT=bd_in)
;;  Define arrays to be used by QHULL.PRO and QGRID3.PRO
fv1d           = dat_1d
vel_sm         = vel_smear
IF (gd_in[0] GT 0) THEN BEGIN
  ;;  Define input for triangulation
  v_in           = TRANSPOSE(vel_sm[good_in,*])
  IF (clog_on[0]) THEN f_in = 1d1^REFORM(fv1d[good_in]) ELSE f_in = REFORM(fv1d[good_in])
;  IF (clog_on[0]) THEN f_in = ALOG(1d1^REFORM(fv1d[good_in])) ELSE f_in = ALOG(REFORM(fv1d[good_in]))
ENDIF ELSE RETURN,0b
IF (bd_in[0] GT 0) THEN BEGIN
  vel_sm[bad_in,*] = 10d0*smax[0]
  IF (clog_on[0]) THEN fv1d[bad_in] = -45d0 ELSE fv1d[bad_in] = 1d-45
ENDIF
;;  Define max input against which to test
IF (clog_on[0]) THEN fin_max = MAX(fv1d,/NAN) ELSE fin_max = MAX(ABS(fv1d),/NAN)
;;  Define new delta_Vs
nc             = nm[0]/2L
delv           = smax[0]/nc[0]
v_st           = -1d0*smax[0]
;;----------------------------------------------------------------------------------------
;;  Triangulate and slice
;;----------------------------------------------------------------------------------------
;;  Find convex hull and associated tetrahedron indices using Delaunay triangulation
QHULL,v_in,tetra,/DELAUNAY
;;  Generate 3D f(vx,vy,vz)
lnf3d_qh       = QGRID3(v_in,f_in,tetra,DELTA=delv[0],DIMENSION=nm[0],MISSING=d,START=v_st[0])
;IF (clog_on[0]) THEN f3d_qh = ALOG10(EXP(lnf3d_qh)) ELSE f3d_qh = EXP(lnf3d_qh)
IF (clog_on[0]) THEN f3d_qh = ALOG10(lnf3d_qh) ELSE f3d_qh = lnf3d_qh
;;  Remove negative and/or zeroed data (depends on C_LOG setting)
IF (clog_on[0]) THEN BEGIN
  test_xy = FINITE(f3d_qh[*,*,nc[0]])
  test_xz = FINITE(f3d_qh[*,nc[0],*])
  test_yz = FINITE(f3d_qh[nc[0],*,*])
ENDIF ELSE BEGIN
  test_xy = FINITE(f3d_qh[*,*,nc[0]]) AND (f3d_qh[*,*,nc[0]] GT 0)
  test_xz = FINITE(f3d_qh[*,nc[0],*]) AND (f3d_qh[*,nc[0],*] GT 0)
  test_yz = FINITE(f3d_qh[nc[0],*,*]) AND (f3d_qh[nc[0],*,*] GT 0)
ENDELSE
;;  Define good indices
gind_xy        = WHERE(test_xy,gd_xy)
gind_xz        = WHERE(test_xz,gd_xz)
gind_yz        = WHERE(test_yz,gd_yz)
IF (clog_on[0]) THEN test = (FINITE(f3d_qh) EQ 0) ELSE test = (FINITE(f3d_qh) EQ 0) OR (f3d_qh LE 0)
bad            = WHERE(test OR f3d_qh GT fin_max[0],bd)
IF (bd[0] GT 0) THEN f3d_qh[bad] = d
;;  Define 2D slices/planes that pass through the origin and lie in the planes
;;    defined by the coordinate basis axes
f2d_xy         = REFORM(f3d_qh[*,*,nc[0]])
f2d_xz         = TRANSPOSE(REFORM(f3d_qh[*,nc[0],*]))  ;;  (Z vs. X) --> (X vs. Z)
;f2d_xz         = REFORM(f3d_qh[*,nc[0],*])
f2d_yz         = REFORM(f3d_qh[nc[0],*,*])
;;  Define corresponding 1D velocity grid values
v1d_grid       = DINDGEN(nm[0])*delv[0] + v_st[0]
;;----------------------------------------------------------------------------------------
;;  Define speeds and 2D projections of velocities (conserving energy)
;;----------------------------------------------------------------------------------------
;;  Now set "bad" points to NaNs for output
IF (bd_in[0] GT 0) THEN vel_sm[bad_in,*] = d
;;  Define |v| and v/|v|
v_mag          = mag__vec(vel_sm,/NAN)
uvels          = unit_vec(vel_sm)
;;  Define azimuthal angles of projection onto each plane from horizontal axis
phi            = ATAN(uvels[*,1],uvels[*,0])      ;;  Azimuthal angle from X-axis of projection onto XY-plane
psi            = ATAN(uvels[*,0],uvels[*,2])      ;;  Azimuthal angle from Z-axis of projection onto XZ-plane
chi            = ATAN(uvels[*,2],uvels[*,1])      ;;  Azimuthal angle from Y-axis of projection onto YZ-plane
zeros          = REPLICATE(0d0,kk[0])
;;  Y vs. X Plane
vx_xy          = v_mag*COS(phi)
vy_xy          = v_mag*SIN(phi)
vz_xy          = zeros
;;  X vs. Z Plane
vx_xz          = v_mag*COS(psi)
vy_xz          = v_mag*SIN(psi)
vz_xz          = zeros
;;  Z vs. Y Plane
vx_yz          = v_mag*COS(chi)
vy_yz          = v_mag*SIN(chi)
vz_yz          = zeros
;;----------------------------------------------------------------------------------------
;;  Create return structure
;;----------------------------------------------------------------------------------------
tag_pref       = ['DF2D','VELX','VELY','VELZ','TR','VX_GRID','VY_GRID','GOOD_IND']
tags           = ['VX2D','VY2D','PLANE_XY','PLANE_XZ','PLANE_YZ']
tag_xy         = tag_pref+'_XY'
tag_xz         = tag_pref+'_XZ'
tag_yz         = tag_pref+'_YZ'

str_xy         = CREATE_STRUCT(tag_xy,f2d_xy,vx_xy,vy_xy,vz_xy,tetra,v1d_grid,v1d_grid,gind_xy)
str_xz         = CREATE_STRUCT(tag_xz,f2d_xz,vx_xz,vy_xz,vz_xz,tetra,v1d_grid,v1d_grid,gind_xz)
str_yz         = CREATE_STRUCT(tag_yz,f2d_yz,vx_yz,vy_yz,vz_yz,tetra,v1d_grid,v1d_grid,gind_yz)
struct         = CREATE_STRUCT(tags,v1d_grid,v1d_grid,str_xy,str_xz,str_yz)
;;----------------------------------------------------------------------------------------
;;  Return to user
;;----------------------------------------------------------------------------------------

RETURN,struct
END
