;*****************************************************************************************
;
;  FUNCTION :   load_swe_and_calc_new_vbulk_scpot.pro
;  PURPOSE  :   Loads SWE Faraday Cup (FC) data from the H1 CDF files and then
;                 calculates the total ion density and spacecraft frame bulk flow
;                 velocity.
;
;  CALLED BY:   
;               general_load_and_save_wind_3dp_data.pro
;
;  INCLUDES:
;               NA
;
;  CALLS:
;               get_valid_trange.pro
;               wind_h1_swe_to_tplot.pro
;               test_tplot_handle.pro
;               get_data.pro
;               t_get_struc_unix.pro
;               sc_pot.pro
;               store_data.pro
;               options.pro
;
;  REQUIRES:    
;               1)  UMN Modified Wind/3DP IDL Libraries
;               2)  The following data:
;                     Wind/SWE H1 CDF files
;
;  INPUT:
;               NA
;
;  EXAMPLES:    
;               [calling sequence]
;               load_swe_and_calc_new_vbulk_scpot [,TDATE=tdate] [,TRANGE=trange]
;
;  KEYWORDS:    
;               TDATE      :  Scalar [string] defining the start date ['YYYY-MM-DD']
;               TRANGE     :  [2]-Element [double] array defining the Unix time range of
;                               SWE data to load into TPLOT
;
;   CHANGED:  1)  Continued to write routine
;                                                                   [07/19/2017   v1.0.0]
;             2)  Continued to write routine
;                                                                   [07/20/2017   v1.0.0]
;             3)  Finished writing routine
;                                                                   [07/31/2017   v1.0.0]
;             4)  Fixed a bug in main routine
;                                                                   [09/26/2017   v1.0.0]
;             5)  Now wind_h1_swe_to_tplot.pro combines moments internally
;                                                                   [02/05/2018   v1.1.0]
;
;   NOTES:      
;               0)  User should not call this routine
;               1)  The thermal speeds are "most probable speeds" speeds, not rms
;               2)  The velocity due to the Earth's orbit about the sun has been removed
;                     from the bulk flow velocities.  This means that ~29.78 km/s has
;                     been subtracted from the Y-GSE component.
;               3)  The nonlinear fits provided in the H1 files do NOT contain the higher
;                     resolution calculations used in Maruca&Kasper, [2013].
;
;  REFERENCES:  
;               1)  K.W. Ogilvie et al., "SWE, A Comprehensive Plasma Instrument for the
;                     Wind Spacecraft," Space Science Reviews Vol. 71, pp. 55-77,
;                     doi:10.1007/BF00751326, 1995.
;               2)  J.C. Kasper et al., "Physics-based tests to identify the accuracy of
;                     solar wind ion measurements:  A case study with the Wind
;                     Faraday Cups," Journal of Geophysical Research Vol. 111,
;                     pp. A03105, doi:10.1029/2005JA011442, 2006.
;               3)  B.A. Maruca and J.C. Kasper "Improved interpretation of solar wind
;                     ion measurements via high-resolution magnetic field data,"
;                     Advances in Space Research Vol. 52, pp. 723-731,
;                     doi:10.1016/j.asr.2013.04.006, 2013.
;
;   CREATED:  07/18/2017
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  02/05/2018   v1.1.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************

FUNCTION load_swe_and_calc_new_vbulk_scpot,TDATE=tdate,TRANGE=trange

;;  Requires:  
;;  Requires:  
;;----------------------------------------------------------------------------------------
;;  Constants
;;----------------------------------------------------------------------------------------
;;  Atomic
me             = 9.1093835600d-31         ;;  Electron mass [kg, 2014 CODATA/NIST]
mp             = 1.6726218980d-27         ;;  Proton mass [kg, 2014 CODATA/NIST]
mn             = 1.6749274710d-27         ;;  Neutron mass [kg, 2014 CODATA/NIST]
ma             = 6.6446572300d-27         ;;  Alpha particle mass [kg, 2014 CODATA/NIST]
;;----------------------------------------------------------------------------------------
;;  Coordinates and vectors
;;----------------------------------------------------------------------------------------
coord_gse      = 'gse'
coord_mag      = 'mag'
coord_gseu     = STRUPCASE(coord_gse[0])
vec_str        = ['x','y','z']
vec_col        = [250,200,75]
xyz_str        = vec_str
xyz_col        = vec_col
;;  Define spacecraft name
sc             = 'Wind'
scpref         = sc[0]+'_'
;;  Define SWE TPLOT handles
vel_sub_str    = [coord_mag[0],xyz_str]
vth_sub_str    = ['_avg','perp','para']
species        = ['p','a']
vel_subscs     = ['bulk','Th']
vel___pref     = 'V'+vel_subscs+'_'
vel_p_pref     = vel___pref+species[0]+'_'
vel_a_pref     = vel___pref+species[1]+'_'
dens_tpn_pa    = 'N'+species
nonmom_suffs   = ['_nonlin','_moms']
swesuff        = '_SWE'
xyz_str        = vec_str
tpn_pronon_var = scpref[0]+[vel_p_pref[0]+[coord_mag[0],xyz_str+coord_gse[0]],$
                            vel_p_pref[1]+vth_sub_str,dens_tpn_pa[0]]+swesuff[0]+nonmom_suffs[0]
tpn_alpnon_var = scpref[0]+[vel_a_pref[0]+[coord_mag[0],xyz_str+coord_gse[0]],$
                            vel_a_pref[1]+vth_sub_str,dens_tpn_pa[1]]+swesuff[0]+nonmom_suffs[0]
;;  Define default TPLOT plot limits structures
def__lim       = {YSTYLE:1,PANEL_SIZE:2.,XMINOR:5,XTICKLEN:0.04,YTICKLEN:0.01}
def_dlim       = {SPEC:0,COLORS:50L,LABELS:'1',LABFLAG:2}
;;----------------------------------------------------------------------------------------
;;  Define date/time of interest
;;----------------------------------------------------------------------------------------
test           = get_valid_trange(TDATE=tdate,TRANGE=trange,PRECISION=6)
IF (SIZE(test[0],/TYPE) NE 8) THEN STOP        ;;  Stop before user runs into issues
tran1d         = trange
;;----------------------------------------------------------------------------------------
;;  Load SWE Faraday Cup ion moments
;;----------------------------------------------------------------------------------------
;wind_h1_swe_to_tplot,TDATE=tdate,TRANGE=tran1d,NO_SWE_B=1b
wind_h1_swe_to_tplot,TDATE=tdate,TRANGE=tran1d,NO_SWE_B=1b,/COMBINE_PA
;;  Verify something was loaded
test_p         = test_tplot_handle(tpn_pronon_var,TPNMS=gd_tpn_p)
test_a         = test_tplot_handle(tpn_alpnon_var,TPNMS=gd_tpn_a)
test           = ~test_p[0] AND ~test_a[0]
IF (test[0]) THEN RETURN,0b        ;;  Nothing loaded --> exit before user runs into issues
;;  Define logic for later
no_vel         = 0b
no_den         = 0b
;;;----------------------------------------------------------------------------------------
;;;  Define new combined velocities
;;;----------------------------------------------------------------------------------------
;;;  Find velocities
;get_data,tpn_pronon_var[1],DATA=t_swe_vxp,DLIM=dlim_swe_vxp,LIM=lim_swe_vxp
;get_data,tpn_pronon_var[2],DATA=t_swe_vyp,DLIM=dlim_swe_vyp,LIM=lim_swe_vyp
;get_data,tpn_pronon_var[3],DATA=t_swe_vzp,DLIM=dlim_swe_vzp,LIM=lim_swe_vzp
;get_data,tpn_alpnon_var[1],DATA=t_swe_vxa,DLIM=dlim_swe_vxa,LIM=lim_swe_vxa
;get_data,tpn_alpnon_var[2],DATA=t_swe_vya,DLIM=dlim_swe_vya,LIM=lim_swe_vya
;get_data,tpn_alpnon_var[3],DATA=t_swe_vza,DLIM=dlim_swe_vza,LIM=lim_swe_vza
;check_vs       = [(SIZE(t_swe_vxp,/TYPE) NE 8),(SIZE(t_swe_vyp,/TYPE) NE 8),$
;                  (SIZE(t_swe_vzp,/TYPE) NE 8),(SIZE(t_swe_vxa,/TYPE) NE 8),$
;                  (SIZE(t_swe_vya,/TYPE) NE 8),(SIZE(t_swe_vza,/TYPE) NE 8) ]
;bad_vs         = WHERE(check_vs,bd_vs,COMPLEMENT=good_vs,NCOMPLEMENT=gd_vs)
;test_vs        = (gd_vs[0] EQ 0)
;struc_pa       = {VXP:t_swe_vxp,VYP:t_swe_vyp,VZP:t_swe_vzp,VXA:t_swe_vxa,VYA:t_swe_vya,VZA:t_swe_vza}
;nt             = N_TAGS(struc_pa)
;IF (test_vs[0]) THEN BEGIN
;  ;;  No SWE velocities loaded --> Skip defining new Vp and Va TPLOT handles
;  dumb   = REPLICATE(0e0,10)
;  velp   = dumb # REPLICATE(0e0,3)
;  vela   = velp
;  unix   = DOUBLE(dumb)
;  no_vel = 1b
;ENDIF ELSE BEGIN
;  unix   = t_get_struc_unix(struc_pa.(good_vs[0]))
;  dumb   = REPLICATE(0e0,N_ELEMENTS(unix))
;  velp   = dumb # REPLICATE(0e0,3)
;  vela   = velp
;  FOR j=0L, gd_vs[0] - 1L DO BEGIN
;    k     = good_vs[j[0]]
;    struc = struc_pa.(k[0])
;    CASE k[0] OF
;      0L  :  velp[*,0L] = struc.Y
;      1L  :  velp[*,1L] = struc.Y
;      2L  :  velp[*,2L] = struc.Y
;      3L  :  vela[*,0L] = struc.Y
;      4L  :  vela[*,1L] = struc.Y
;      5L  :  vela[*,2L] = struc.Y
;      ELSE:  ;;  do nothing
;    ENDCASE
;  ENDFOR
;  ;;--------------------------------------------------------------------------------------
;  ;;  Replace NaNs with zeros
;  ;;--------------------------------------------------------------------------------------
;  good_p  = WHERE(FINITE(velp) AND ABS(velp) GE 0,gd_p,COMPLEMENT=bad_p,NCOMPLEMENT=bd_p)
;  good_a  = WHERE(FINITE(vela) AND ABS(vela) GE 0,gd_a,COMPLEMENT=bad_a,NCOMPLEMENT=bd_a)
;  IF (bd_p[0] GT 0) THEN velp[bad_p] = 0e0
;  IF (bd_a[0] GT 0) THEN vela[bad_a] = 0e0
;ENDELSE
;;;----------------------------------------------------------------------------------------
;;;  Define total ion density
;;;    N_i = ∑_s Z_s N_s
;;;----------------------------------------------------------------------------------------
;;;  Find densities
;get_data,tpn_pronon_var[7],DATA=t_swe_np,DLIM=dlim_swe_np,LIM=lim_swe_np
;get_data,tpn_alpnon_var[7],DATA=t_swe_na,DLIM=dlim_swe_na,LIM=lim_swe_na
;check_ns       = [(SIZE(t_swe_np,/TYPE) NE 8),(SIZE(t_swe_na,/TYPE) NE 8)]
;bad_ns         = WHERE(check_ns,bd_ns,COMPLEMENT=good_ns,NCOMPLEMENT=gd_ns)
;test_ns        = (gd_ns[0] EQ 0)
;struc_pa       = {NP:t_swe_np,NA:t_swe_na}
;nt             = N_TAGS(struc_pa)
;;;  Define dummy arrays to fill if valid data present
;nn             = N_ELEMENTS(velp[*,0])
;dumb           = REPLICATE(0e0,nn[0])
;dens_p         = dumb
;dens_a         = dumb
;IF (test_ns[0]) THEN BEGIN
;  ;;  No SWE densities loaded --> Skip changing Vsw and SC Pot. TPLOT handles
;  no_den = 1b
;ENDIF ELSE BEGIN
;  IF (no_vel[0]) THEN BEGIN
;    ;;  No SWE velocities loaded --> Need new dummy arrays
;    unix           = t_get_struc_unix(struc_pa.(good_ns[0]))
;    nn             = N_ELEMENTS(unix)
;    dumb           = REPLICATE(0e0,nn[0])
;    dens_p         = dumb
;    dens_a         = dumb
;  ENDIF
;  FOR j=0L, gd_ns[0] - 1L DO BEGIN
;    k     = good_ns[j[0]]
;    struc = struc_pa.(k[0])
;    CASE k[0] OF
;      0L  :  dens_p = struc.Y
;      1L  :  dens_a = struc.Y
;      ELSE:  ;;  do nothing
;    ENDCASE
;  ENDFOR
;  ;;--------------------------------------------------------------------------------------
;  ;;  Replace NaNs with zeros
;  ;;--------------------------------------------------------------------------------------
;  good_p  = WHERE(FINITE(dens_p) AND dens_p GE 0,gd_p,COMPLEMENT=bad_p,NCOMPLEMENT=bd_p)
;  good_a  = WHERE(FINITE(dens_a) AND dens_a GE 0,gd_a,COMPLEMENT=bad_a,NCOMPLEMENT=bd_a)
;  IF (bd_p[0] GT 0) THEN dens_p[bad_p] = 0e0
;  IF (bd_a[0] GT 0) THEN dens_a[bad_a] = 0e0
;ENDELSE
;;;----------------------------------------------------------------------------------------
;;;  Define N_i (= ∑_s Z_s N_s)
;;;----------------------------------------------------------------------------------------
;dens_t         = dens_p + 2e0*dens_a
;;;  Send to TPLOT
;struc          = {X:unix,Y:dens_t}
;tpn_swe_scpot  = scpref[0]+'Ni_tot'+swesuff[0]
;store_data,tpn_swe_scpot[0],DATA=struc,DLIM=def_dlim,LIM=def__lim
;;----------------------------------------------------------------------------------------
;;  Define new SC Potential
;;----------------------------------------------------------------------------------------
tpn_swe_nitot  = scpref[0]+'Ni_tot'+swesuff[0]
get_data,tpn_swe_nitot[0],DATA=struc,DLIM=dlim_ntot,LIM=lim_ntot
IF (SIZE(struc,/TYPE) NE 8) THEN RETURN,0b
unix           = t_get_struc_unix(struc)
dens_t         = struc.Y
sc_phi         = sc_pot(dens_t)
;;  Send to TPLOT
struc          = {X:unix,Y:sc_phi}
tpn_swe_scpot  = scpref[0]+'sc_pot'+swesuff[0]
store_data,tpn_swe_scpot[0],DATA=struc,DLIM=def_dlim,LIM=def__lim
;;;----------------------------------------------------------------------------------------
;;;  Define Vbulk
;;;    V_i = ∑_s (M_s N_s V_s)/∑_s (M_s N_s)
;;;----------------------------------------------------------------------------------------
;dens_p3d       = ABS(dens_p # REPLICATE(1e0,3))
;dens_a3d       = ABS(dens_a # REPLICATE(1e0,3))
;numer          = mp[0]*dens_p3d*velp + ma[0]*dens_a3d*vela
;denom          = mp[0]*dens_p3d + ma[0]*dens_a3d
;vbulk          = FLOAT(numer/denom)
;;;  Account for Earth's abberation velocity [i.e., add ~29.78 km/s to y-component]
;vbulk[*,1]    += 29.78
;;;  Send to TPLOT
;struc          = {X:unix,Y:vbulk}
;tpn_swe_vbulk  = scpref[0]+'Vbulk_'+coord_gse[0]+swesuff[0]+nonmom_suffs[0]
;store_data,tpn_swe_vbulk[0],DATA=struc,DLIM=def_dlim,LIM=def__lim
;options,tpn_swe_vbulk[0],LABELS=vec_str,COLORS=vec_col,YTITLE='Vbulk [km/s, GSE]',/DEF
;;----------------------------------------------------------------------------------------
;;  Return to user
;;----------------------------------------------------------------------------------------

RETURN,1b
END


;+
;*****************************************************************************************
;
;  PROCEDURE:   general_load_and_save_wind_3dp_data.pro
;  PURPOSE  :   Loads and creates IDL save files containing arrays of IDL structures
;                 defining the velocity distribution functions (VDFs) measured by the
;                 multiple detectors comprising the 3DP instrument suite.
;
;  CALLED BY:   
;               NA
;
;  INCLUDES:
;               load_swe_and_calc_new_vbulk_scpot.pro
;
;  CALLS:
;               get_os_slash.pro
;               test_tdate_format.pro
;               test_file_path_format.pro
;               tnames.pro
;               store_data.pro
;               time_double.pro
;               get_valid_trange.pro
;               load_3dp_data.pro
;               timespan.pro
;               lbw_window.pro
;               tplot.pro
;               wind_orbit_to_tplot.pro
;               options.pro
;               tplot_options.pro
;               pesa_low_moment_calibrate.pro
;               get_pmom2.pro
;               load_swe_and_calc_new_vbulk_scpot.pro
;               lbw_tplot_set_defaults.pro
;               file_name_times.pro
;               get_3dp_structs.pro
;               add_vsw2.pro
;               add_magf2.pro
;               add_scpot.pro
;
;  REQUIRES:    
;               1)  UMN Modified Wind/3DP IDL Libraries
;               2)  The following data:
;                     Wind/3DP level zero files
;                     Wind/MFI H0 CDF files
;                     Wind orbit ASCII files
;                     Wind/SWE H1 CDF files
;
;  INPUT:
;               NA
;
;  EXAMPLES:    
;               [calling sequence]
;               general_load_and_save_wind_3dp_data [,TDATE=tdate] [,TRANGE=trange]    $
;                                        [,/LOAD_EESA] [,/LOAD_PESA] [,/LOAD__SST]     $
;                                        [,/LOAD_SWEFC] [,SAVE_DIR=save_dir]           $
;                                        [,/NO_CLEANT] [,BURST_ON=burst_on]
;
;  KEYWORDS:    
;               TDATE       :  Scalar [string] defining the start date ['YYYY-MM-DD']
;               TRANGE      :  [2]-Element [double] array defining the Unix time range of
;                                3DP, MFI, and SWE data to load into IDL
;               LOAD_????   :  If set, routine will load and save instrument-type data
;                                {where ???? = EESA, PESA, or _SST}
;                                [Default = FALSE]
;               LOAD_SWEFC  :  If set, routine will load SWE Faraday Cup (FC) data into
;                                TPLOT and try to use resulting data for VSW and
;                                SC_POT definitions in 3DP IDL structures
;                                [Default = FALSE]
;               SAVE_DIR    :  Scalar [string] defining the directory where IDL save
;                                files will be stored
;                                [Default = current working directory]
;               NO_CLEANT   :  If set, routine will not delete/remove TPLOT data prior to
;                                returning to user
;                                [Default = FALSE]
;
;               **********************************
;               ***     ALTERED ON OUTPUT      ***
;               **********************************
;               BURST_ON    :  Set to a named variable that will return a structure
;                                informing the user whether a given instrument had burst
;                                data available for the time range of interest
;
;   CHANGED:  1)  Continued to write routine
;                                                                   [07/19/2017   v1.0.0]
;             2)  Continued to write routine
;                                                                   [07/20/2017   v1.0.0]
;             3)  Finished writing routine
;                                                                   [07/31/2017   v1.0.0]
;             4)  Fixed an undefined variable
;                                                                   [09/26/2017   v1.0.1]
;             5)  Fixed a bug when TRANGE is set but TDATE is not
;                                                                   [02/02/2018   v1.0.2]
;             6)  Added keyword:  BURST_ON
;                                                                   [02/02/2018   v1.0.3]
;             7)  Cleaned up some of the loading and error handling
;                                                                   [02/02/2018   v1.0.4]
;             8)  Now wind_h1_swe_to_tplot.pro combines moments internally
;                                                                   [02/05/2018   v1.0.5]
;             9)  Fixed an issue when TDATE is set but TRANGE is not
;                                                                   [02/26/2019   v1.0.6]
;
;   NOTES:      
;               .compile $HOME/Desktop/temp_idl/general_load_and_save_wind_3dp_data.pro
;
;  REFERENCES:  
;               0)  Harten, R. and K. Clark "The Design Features of the GGS Wind and
;                      Polar Spacecraft," Space Sci. Rev. Vol. 71, pp. 23--40, 1995.
;               1)  Carlson et al., "An instrument for rapidly measuring plasma
;                      distribution functions with high resolution," Adv. Space Res.
;                      2, pp. 67--70, 1983.
;               2)  Curtis et al., "On-board data analysis techniques for space plasma
;                      particle instruments," Rev. Sci. Inst. 60, pp. 372--380, 1989.
;               3)  Lin et al., "A Three-Dimensional Plasma and Energetic particle
;                      investigation for the Wind spacecraft," Space Sci. Rev.
;                      71, pp. 125--153, 1995.
;               4)  Paschmann, G. and P.W. Daly "Analysis Methods for Multi-Spacecraft
;                      Data," ISSI Scientific Report, Noordwijk, The Netherlands.,
;                      Intl. Space Sci. Inst., 1998.
;               5)  Bougeret, J.-L., M.L. Kaiser, P.J. Kellogg, R. Manning, K. Goetz,
;                      S.J. Monson, N. Monge, L. Friel, C.A. Meetre, C. Perche,
;                      L. Sitruk, and S. Hoang "WAVES:  The Radio and Plasma Wave
;                      Investigation on the Wind Spacecraft," Space Sci. Rev. 71,
;                      pp. 231--263, doi:10.1007/BF00751331, 1995.
;               6)  Viñas, A.F. and J.D. Scudder "Fast and Optimal Solution to the
;                      'Rankine-Hugoniot Problem'," J. Geophys. Res. 91, pp. 39-58, 1986.
;               7)  A. Szabo "An improved solution to the 'Rankine-Hugoniot' problem,"
;                      J. Geophys. Res. 99, pp. 14,737--14,746, 1994.
;               8)  Koval, A. and A. Szabo "Modified 'Rankine-Hugoniot' shock fitting
;                      technique:  Simultaneous solution for shock normal and speed,"
;                      J. Geophys. Res. 113, pp. A10110, 2008.
;               9)  Russell, C.T., J.T. Gosling, R.D. Zwickl, and E.J. Smith
;                      "Multiple spacecraft observations of interplanetary shocks:  ISEE
;                      Three-Dimensional Plasma Measurements," J. Geophys. Res. 88,
;                      pp. 9941--9947, 1983.
;              10)  Lepping et al., "The Wind Magnetic Field Investigation,"
;                      Space Sci. Rev. Vol. 71, pp. 207--229, 1995.
;              11)  K.W. Ogilvie et al., "SWE, A Comprehensive Plasma Instrument for the
;                     Wind Spacecraft," Space Science Reviews Vol. 71, pp. 55--77,
;                     doi:10.1007/BF00751326, 1995.
;              12)  J.C. Kasper et al., "Physics-based tests to identify the accuracy of
;                     solar wind ion measurements:  A case study with the Wind
;                     Faraday Cups," Journal of Geophysical Research Vol. 111,
;                     pp. A03105, doi:10.1029/2005JA011442, 2006.
;              13)  B.A. Maruca and J.C. Kasper "Improved interpretation of solar wind
;                     ion measurements via high-resolution magnetic field data,"
;                     Advances in Space Research Vol. 52, pp. 723--731,
;                     doi:10.1016/j.asr.2013.04.006, 2013.
;
;   CREATED:  07/18/2017
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  02/26/2019   v1.0.6
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

PRO general_load_and_save_wind_3dp_data,TDATE=tdate,TRANGE=trange,LOAD_EESA=load_eesa, $
                                        LOAD_PESA=load_pesa,LOAD__SST=load__sst,       $
                                        LOAD_SWEFC=load_swefc,SAVE_DIR=save_dir,       $
                                        NO_CLEANT=no_cleant,BURST_ON=burst_on

;;----------------------------------------------------------------------------------------
;;  IDL system and OS stuff
;;----------------------------------------------------------------------------------------
vers           = !VERSION.OS_FAMILY   ;;  e.g., 'unix'
vern           = !VERSION.RELEASE     ;;  e.g., '7.1.1'
slash          = get_os_slash()       ;;  '/' for Unix, '\' for Windows
;;----------------------------------------------------------------------------------------
;;  Constants
;;----------------------------------------------------------------------------------------
f              = !VALUES.F_NAN
d              = !VALUES.D_NAN
;;  Fundamental
c              = 2.9979245800d+08         ;;  Speed of light in vacuum [m s^(-1), 2014 CODATA/NIST]
kB             = 1.3806485200d-23         ;;  Boltzmann Constant [J K^(-1), 2014 CODATA/NIST]
hh             = 6.6260700400d-34         ;;  Planck Constant [J s, 2014 CODATA/NIST]
;;  Electromagnetic
qq             = 1.6021766208d-19         ;;  Fundamental charge [C, 2014 CODATA/NIST]
epo            = 8.8541878170d-12         ;;  Permittivity of free space [F m^(-1), 2014 CODATA/NIST]
muo            = !DPI*4.00000d-07         ;;  Permeability of free space [N A^(-2) or H m^(-1), 2014 CODATA/NIST]
;;  Atomic
me             = 9.1093835600d-31         ;;  Electron mass [kg, 2014 CODATA/NIST]
mp             = 1.6726218980d-27         ;;  Proton mass [kg, 2014 CODATA/NIST]
mn             = 1.6749274710d-27         ;;  Neutron mass [kg, 2014 CODATA/NIST]
ma             = 6.6446572300d-27         ;;  Alpha particle mass [kg, 2014 CODATA/NIST]
;;  --> Define mass of particles in units of energy [eV]
ma_eV          = ma[0]*c[0]^2/qq[0]       ;;  ~3727.379378(23) [MeV, 2014 CODATA/NIST]
me_eV          = me[0]*c[0]^2/qq[0]       ;;  ~0.5109989461(31) [MeV, 2014 CODATA/NIST]
mn_eV          = mn[0]*c[0]^2/qq[0]       ;;  ~939.5654133(58) [MeV, 2014 CODATA/NIST]
mp_eV          = mp[0]*c[0]^2/qq[0]       ;;  ~938.2720813(58) [MeV, 2014 CODATA/NIST]
;;  Astronomical
R_S___m        = 6.9600000d08             ;;  Sun's Mean Equatorial Radius [m, 2015 AA values]
R_Ea__m        = 6.3781366d06             ;;  Earth's Mean Equatorial Radius [m, 2015 AA values]
M_E            = 5.9722000d24             ;;  Earth's mass [kg, 2015 AA values]
M_S__kg        = 1.9884000d30             ;;  Sun's mass [kg, 2015 AA values]
au             = 1.49597870700d+11        ;;  1 astronomical unit or AU [m, from Mathematica 10.1 on 2015-04-21]
R_E            = R_Ea__m[0]*1d-3          ;;  m --> km
;;----------------------------------------------------------------------------------------
;;  Conversion Factors
;;----------------------------------------------------------------------------------------
;;  Energy and Temperature
f_1eV          = qq[0]/hh[0]          ;;  Freq. associated with 1 eV of energy [ Hz --> f_1eV*energy{eV} = freq{Hz} ]
eV2J           = hh[0]*f_1eV[0]       ;;  Energy associated with 1 eV of energy [ J --> J_1eV*energy{eV} = energy{J} ]
eV2K           = qq[0]/kB[0]          ;;  Temp. associated with 1 eV of energy [11,604.5221 K/eV, 2014 CODATA/NIST --> K_eV*energy{eV} = Temp{K}]
K2eV           = kB[0]/qq[0]          ;;  Energy associated with 1 K Temp. [8.6173303 x 10^(-5) eV/K, 2014 CODATA/NIST --> eV_K*Temp{K} = energy{eV}]
;;----------------------------------------------------------------------------------------
;;  Coordinates and vectors
;;----------------------------------------------------------------------------------------
;;  Define some coordinate strings
coord_dsl      = 'dsl'
coord_gse      = 'gse'
coord_gsm      = 'gsm'
coord_fac      = 'fac'
coord_mag      = 'mag'
coord_gseu     = STRUPCASE(coord_gse[0])
vec_str        = ['x','y','z']
vec_col        = [250,150, 50]
xyz_str        = vec_str
xyz_col        = vec_col
tensor_str     = ['x'+vec_str,'y'+vec_str[1:2],'zz']
fac_vec_str    = ['perp1','perp2','para']
fac_dir_str    = ['para','perp','anti']
;;  Define dummy error messages
dummy_errmsg   = ['You have not defined the proper input!',                $
                  'This batch routine expects three inputs',               $
                  'with following EXACT variable names:',                  $
                  "date         ;; e.g., '072608' for July 26, 2008",      $
                  "tdate        ;; e.g., '2008-07-26' for July 26, 2008"   ]
nderrmsg       = N_ELEMENTS(dummy_errmsg) - 1L
;;  Define default TPLOT plot limits structures
def__lim       = {YSTYLE:1,PANEL_SIZE:2.,XMINOR:5,XTICKLEN:0.04,YTICKLEN:0.01}
def_dlim       = {SPEC:0,COLORS:50L,LABELS:'1',LABFLAG:2}
;;  Define spacecraft name
sc             = 'Wind'
scpref         = sc[0]+'_'
;;  Define SWE TPLOT handles
vel_sub_str    = [coord_mag[0],xyz_str]
vth_sub_str    = ['_avg','perp','para']
species        = ['p','a']
vel_subscs     = ['bulk','Th']
vel___pref     = 'V'+vel_subscs+'_'
vel_p_pref     = vel___pref+species[0]+'_'
vel_a_pref     = vel___pref+species[1]+'_'
dens_tpn_pa    = 'N'+species
nonmom_suffs   = ['_nonlin','_moms']
swesuff        = '_SWE'
xyz_str        = vec_str
tpn_pronon_var = scpref[0]+[vel_p_pref[0]+[coord_mag[0],xyz_str+coord_gse[0]],$
                            vel_p_pref[1]+vth_sub_str,dens_tpn_pa[0]]+swesuff[0]+nonmom_suffs[0]
tpn_alpnon_var = scpref[0]+[vel_a_pref[0]+[coord_mag[0],xyz_str+coord_gse[0]],$
                            vel_a_pref[1]+vth_sub_str,dens_tpn_pa[1]]+swesuff[0]+nonmom_suffs[0]
;;----------------------------------------------------------------------------------------
;;  Define dummy structure for burst info
;;----------------------------------------------------------------------------------------
lh_tag         = ['l','h']
fo_tag         = ['f','o']
tags           = ['e'+lh_tag,'p'+lh_tag,'s'+fo_tag]+'b'
burst_on       = CREATE_STRUCT(tags,0b,0b,0b,0b,0b,0b)
;;----------------------------------------------------------------------------------------
;;  Define and times/dates Probe from input
;;----------------------------------------------------------------------------------------
;;  Check for TDATE and/or TRANGE
test           = ((N_ELEMENTS(tdate) GT 0) AND (SIZE(tdate,/TYPE) EQ 7) AND test_tdate_format(tdate)) OR $
                 ((N_ELEMENTS(trange) EQ 2) AND is_a_number(trange,/NOMSSG))
IF (test[0]) THEN BEGIN
  ;;  At least one is set --> use that one
  test           = ((N_ELEMENTS(tdate) GT 0) AND (SIZE(tdate,/TYPE) EQ 7) AND test_tdate_format(tdate))
  IF (test[0]) THEN time_ra = get_valid_trange(TDATE=tdate,TRANGE=trange) ELSE time_ra = get_valid_trange(TDATE=tdate,TRANGE=trange)
;  IF (test[0]) THEN time_ra = get_valid_trange(TDATE=tdate) ELSE time_ra = get_valid_trange(TRANGE=trange)
ENDIF ELSE BEGIN
  ;;  Prompt user and ask user for date/times
  time_ra        = get_valid_trange(TDATE=tdate,TRANGE=trange)
ENDELSE
;;  Check LOAD_EESA
test           = (N_ELEMENTS(load_eesa) EQ 0) OR ~KEYWORD_SET(load_eesa)
IF (test[0]) THEN eesa_on = 0b ELSE eesa_on = 1b
;;  Check LOAD_PESA
test           = (N_ELEMENTS(load_pesa) EQ 0) OR ~KEYWORD_SET(load_pesa)
IF (test[0]) THEN pesa_on = 0b ELSE pesa_on = 1b
;;  Check LOAD__SST
test           = (N_ELEMENTS(load__sst) EQ 0) OR ~KEYWORD_SET(load__sst)
IF (test[0]) THEN sst__on = 0b ELSE sst__on = 1b
;;  Check LOAD_SWEFC
test           = (N_ELEMENTS(load_swefc) EQ 0) OR ~KEYWORD_SET(load_swefc)
IF (test[0]) THEN swefc_on = 0b ELSE swefc_on = 1b
;;  Check NO_CLEANT
test           = KEYWORD_SET(no_cleant) AND (N_ELEMENTS(no_cleant) GT 0)
IF (test[0]) THEN cleant_on = 0b ELSE cleant_on = 1b
;;  Check SAVE_DIR
test           = test_file_path_format(save_dir,EXISTS=exists,DIR_OUT=savdir)
IF (~test[0]) THEN test = test_file_path_format('.',EXISTS=exists,DIR_OUT=savdir)      ;;  Use current working directory
IF (~exists[0]) THEN FILE_MKDIR,savdir[0],/NOEXPAND_PATH
;;----------------------------------------------------------------------------------------
;;  Check TPLOT and keywords
;;----------------------------------------------------------------------------------------
nna            = tnames()
IF (nna[0] NE '') THEN store_data,DELETE=nna  ;;  Make sure nothing is already loaded
;;----------------------------------------------------------------------------------------
;;  Define date/time of interest
;;----------------------------------------------------------------------------------------
start_of_day_t = '00:00:00.000000000'
end___of_day_t = '23:59:59.999999999'
start_of_day   = '00:00:00.000000'
end___of_day   = '23:59:59.999999'
trange         = time_ra.UNIX_TRANGE
tran1d         = trange
IF (N_ELEMENTS(tdate) EQ 0) THEN BEGIN
  tr_00          = time_string(tran1d,PREC=3)
  tdates         = STRMID(tr_00,0L,10L)
  tdate          = tdates[0]
ENDIF
;;  Define DATE ['MMDDYY']
date           = STRMID(tdate[0],5L,2L)+STRMID(tdate[0],8L,2L)+STRMID(tdate[0],2L,2L)
;;----------------------------------------------------------------------------------------
;;  Load 3DP data
;;    -->  The following loads data from the level zero files found at:
;;           http://sprg.ssl.berkeley.edu/wind3dp/data/wi/3dp/lz/
;;    -->  load_3dp_data.pro requires the use of a shared object library, which are
;;           found in the ./wind_3dp_pros/WIND_PRO/ directory and are both operating
;;           system- (OS) and memory size-dependent (i.e., *_64.so files allow the use
;;           of 64 bit IDL, whereas others require 32 bit IDL)
;;----------------------------------------------------------------------------------------
;;  Define a start date and time
start_t        = tdate[0]+'/'+start_of_day[0]
;;  Define a duration of time to load [hours]
dur            = 200.
;;  Define the memory size to limit to [mostly for older systems]
memsz          = 200.
;;  Define the packet quality [2 allows "invalid" distributions through]
qual           = 2
;;  Load the level zero data files and store in pointer memory
load_3dp_data,start_t[0],dur[0],QUALITY=qual[0],MEMSIZE=memsz[0]
;;  Make sure data was loaded
nna            = tnames()
IF (nna[0] EQ '') THEN STOP  ;;  Something failed --> Debug
;;  Set TPLOT time range
delt           = tran1d[1] - tran1d[0]
timespan,tran1d[0],delt[0],/SECONDS
;;----------------------------------------------------------------------------------------
;;  Open window and plot
;;----------------------------------------------------------------------------------------
DEVICE,GET_SCREEN_SIZE=s_size
wsz            = s_size*7d-1
win_ttl        = 'Wind Plots ['+tdate[0]+']'
win_str        = {RETAIN:2,XSIZE:wsz[0],YSIZE:wsz[1],TITLE:win_ttl[0],XPOS:10,YPOS:10}
lbw_window,WIND_N=0,_EXTRA=win_str
;;  Plot MFI data for date of interest
tplot,[1,2],TRANGE=tran1d
;;----------------------------------------------------------------------------------------
;;  Load orbit data
;;----------------------------------------------------------------------------------------
Bgse_tpnm      = 'wi_B3(GSE)'        ;;  TPLOT handle associated with Bo [GSE, nT]
wind_orbit_to_tplot,BNAME=Bgse_tpnm[0],TRANGE=tran1d
;;  Change Y-Axis titles
options,'Wind_Radial_Distance','YTITLE','Radial Dist. (R!DE!N)'
options,'Wind_GSE_Latitude','YTITLE','GSE Lat. [deg]'
options,'Wind_GSE_Longitude','YTITLE','GSE Lon. [deg]'
;;  Add these variables as tick mark labels
gnames         = ['Wind_Radial_Distance','Wind_GSE_Latitude','Wind_GSE_Longitude','Wind_MLT']
tplot_options,VAR_LABEL=gnames
;;----------------------------------------------------------------------------------------
;;  Load PESA Low ion moments
;;----------------------------------------------------------------------------------------
Bgse_tpnm      = 'wi_B3(GSE)'        ;;  TPLOT handle associated with Bo [GSE, nT]
Vgse_tpnm      = 'V_sw2'             ;;  " " Vsw [GSE, km/s]
pesa_low_moment_calibrate,DATE=date,TRANGE=tran1d,BNAME=Bgse_tpnm[0]
;;  Determine which TPLOT handle to use for estimate of spacecraft potential [eV]
IF (tnames('sc_pot_3') EQ '') THEN scp_tpn = 'sc_pot_2' ELSE scp_tpn = 'sc_pot_3'
;;----------------------------------------------------------------------------------------
;;  Load onboard PESA Low ion moments
;;----------------------------------------------------------------------------------------
get_pmom2,PREFIX=scpref[0],MAGNAME=Bgse_tpnm[0]
;;  Set some options
pmom_tpns      = scpref[0]+['Np','Tp','Vp','T3p']
options,pmom_tpns,'PSYM'
options,pmom_tpns[[2,3]],'LABELS'
options,pmom_tpns[[2,3]],'COLORS'
options,pmom_tpns[2],LABELS=vec_str,COLORS=vec_col,/DEF
options,pmom_tpns[3],LABELS=fac_vec_str,COLORS=vec_col,/DEF
;;----------------------------------------------------------------------------------------
;;  Load SWE Faraday Cup ion moments [if desired]
;;----------------------------------------------------------------------------------------
IF (swefc_on[0]) THEN BEGIN
  test           = load_swe_and_calc_new_vbulk_scpot(TDATE=tdate,TRANGE=tran1d)
  IF (test[0]) THEN BEGIN
    ;;  Check for success
    tpn_swe_scpot  = scpref[0]+'sc_pot'+swesuff[0]
    tpn_swe_vbulk  = scpref[0]+'Vbulk_'+coord_gse[0]+swesuff[0]+nonmom_suffs[0]
    tpns           = tnames([tpn_swe_scpot[0],tpn_swe_vbulk[0]])
    test           = (TOTAL(tpns NE '') EQ 2)
    IF (test[0]) THEN BEGIN
      ;;  Define new Vsw and 
      Vgse_tpnm = (tnames(tpn_swe_vbulk[0]))[0]
      scp_tpn   = (tnames(tpn_swe_scpot[0]))[0]
    ENDIF
  ENDIF
ENDIF
;;----------------------------------------------------------------------------------------
;;  Inform User of TPLOT handles being used for VDF tags
;;----------------------------------------------------------------------------------------
PRINT,''
PRINT,'      Magnetic field TPLOT handle [nT, GSE]: '+Bgse_tpnm[0]
PRINT,'Bulk flow velocity TPLOT handle [km/s, GSE]: '+Vgse_tpnm[0]
PRINT,'     Spacecraft potential TPLOT handle [eV]: '+scp_tpn[0]
PRINT,''
;;  Define IDL save file description
idl_save_desc  = 'MAGF Structure tag = Magnetic field TPLOT handle [nT, GSE]: '+Bgse_tpnm[0]
idl_save_desc  = idl_save_desc[0]+';;  VSW Structure tag = Bulk flow velocity TPLOT handle [km/s, GSE]: '+Vgse_tpnm[0]
idl_save_desc  = idl_save_desc[0]+';;  SC_POT Structure tag = Spacecraft potential TPLOT handle [eV]: '+scp_tpn[0]
;;----------------------------------------------------------------------------------------
;;  Set some defaults for TPLOT
;;----------------------------------------------------------------------------------------
lbw_tplot_set_defaults
tplot_options,'XMARGIN',[ 20, 15]
tplot_options,'YMARGIN',[ 5, 5]
;;----------------------------------------------------------------------------------------
;;  Define time suffix for output files
;;----------------------------------------------------------------------------------------
fnm            = file_name_times(tran1d,PREC=0)
ftime0         = fnm.F_TIME          ; e.g. 1998-08-09_0801x09.494
ftimes         = STRMID(ftime0[*],0L,15L)
tsuffx         = ftimes[0]+'_'+ftimes[1]
;;----------------------------------------------------------------------------------------
;;  Get thermal [PESA Low] and suprathermal [PESA High]
;;    ion velocity distribution functions (VDFs)
;;
;;    Low   :  ~0.1-10.0 keV ions
;;    High  :  ~0.5-28.0 keV ions
;;----------------------------------------------------------------------------------------
fpref          = 'Pesa_3DP_Structures_'
fsuffx         = '_w-Vsw-Ni-SCPot.sav'
;;  Initialize structure variables
apl_           = 0
aplb           = 0
aph_           = 0
aphb           = 0
IF (pesa_on[0]) THEN BEGIN
  pl_dat         = get_3dp_structs('pl' ,TRANGE=tran1d)      ;;  PESA  Low
  plbdat         = get_3dp_structs('plb',TRANGE=tran1d)      ;;  PESA  Low Burst
  ph_dat         = get_3dp_structs('ph' ,TRANGE=tran1d)      ;;  PESA High
  phbdat         = get_3dp_structs('phb',TRANGE=tran1d)      ;;  PESA High Burst
  ;;--------------------------------------------------------------------------------------
  ;;  PESA Low
  ;;--------------------------------------------------------------------------------------
  IF (SIZE(pl_dat,/TYPE) EQ 8) THEN BEGIN
    apl_ = pl_dat.DATA
    add_vsw2, apl_,Vgse_tpnm[0]
    add_magf2,apl_,Bgse_tpnm[0]
    add_scpot,apl_,  scp_tpn[0]
  ENDIF
  ;;--------------------------------------------------------------------------------------
  ;;  PESA Low Burst
  ;;--------------------------------------------------------------------------------------
  IF (SIZE(plbdat,/TYPE) EQ 8) THEN BEGIN
    aplb = plbdat.DATA
    add_vsw2, aplb,Vgse_tpnm[0]
    add_magf2,aplb,Bgse_tpnm[0]
    add_scpot,aplb,  scp_tpn[0]
  ENDIF
  ;;--------------------------------------------------------------------------------------
  ;;  PESA High
  ;;--------------------------------------------------------------------------------------
  IF (SIZE(ph_dat,/TYPE) EQ 8) THEN BEGIN
    aph_ = ph_dat.DATA
    add_vsw2, aph_,Vgse_tpnm[0]
    add_magf2,aph_,Bgse_tpnm[0]
    add_scpot,aph_,  scp_tpn[0]
  ENDIF
  ;;--------------------------------------------------------------------------------------
  ;;  PESA High Burst
  ;;--------------------------------------------------------------------------------------
  IF (SIZE(phbdat,/TYPE) EQ 8) THEN BEGIN
    aphb = phbdat.DATA
    add_vsw2, aphb,Vgse_tpnm[0]
    add_magf2,aphb,Bgse_tpnm[0]
    add_scpot,aphb,  scp_tpn[0]
  ENDIF
  ;;--------------------------------------------------------------------------------------
  ;;  Define BURST_ON status for PLB and PHB
  ;;--------------------------------------------------------------------------------------
  burst_on.PLB   = (N_ELEMENTS(aplb) GT 1)
  burst_on.PHB   = (N_ELEMENTS(aphb) GT 1)
  ;;--------------------------------------------------------------------------------------
  ;;  Print out name as a check
  ;;--------------------------------------------------------------------------------------
  fname          = savdir[0]+fpref[0]+tsuffx[0]+fsuffx[0]
  PRINT,';; ',fname[0]
  ;;--------------------------------------------------------------------------------------
  ;;  Create IDL save file
  ;;--------------------------------------------------------------------------------------
  SAVE,apl_,aplb,aph_,aphb,FILENAME=fname[0],DESCRIPTION=idl_save_desc[0]
  ;;--------------------------------------------------------------------------------------
  ;;  Clean up
  ;;--------------------------------------------------------------------------------------
  dumb = TEMPORARY(apl_) & dumb = TEMPORARY(aph_) & dumb = TEMPORARY(aplb) & dumb = TEMPORARY(aphb)
  dumb = TEMPORARY(pl_dat) & dumb = TEMPORARY(plbdat)
  dumb = TEMPORARY(ph_dat) & dumb = TEMPORARY(phbdat)
ENDIF ELSE BEGIN
  pl_dat         = 0
  plbdat         = 0
  ph_dat         = 0
  phbdat         = 0
ENDELSE
;;----------------------------------------------------------------------------------------
;;  Get thermal [EESA Low] and suprathermal [EESA High]
;;    electron velocity distribution functions (VDFs)
;;
;;    Low   :     ~5-1100  eV electrons
;;    High  :  ~0.14-28.0 keV electrons
;;----------------------------------------------------------------------------------------
fpref          = 'Eesa_3DP_Structures_'
fsuffx         = '_w-Vsw-Ni-SCPot.sav'
;;  Initialize structure variables
ael_           = 0
aelb           = 0
aeh_           = 0
aehb           = 0
IF (eesa_on[0]) THEN BEGIN
  el_dat         = get_3dp_structs('el' ,TRANGE=tran1d)      ;;  EESA  Low
  elbdat         = get_3dp_structs('elb',TRANGE=tran1d)      ;;  EESA  Low Burst
  eh_dat         = get_3dp_structs('eh' ,TRANGE=tran1d)      ;;  EESA High
  ehbdat         = get_3dp_structs('ehb',TRANGE=tran1d)      ;;  EESA High Burst
  ;;--------------------------------------------------------------------------------------
  ;;  EESA Low
  ;;--------------------------------------------------------------------------------------
  IF (SIZE(el_dat,/TYPE) EQ 8) THEN BEGIN
    ael_ = el_dat.DATA
    add_vsw2, ael_,Vgse_tpnm[0]
    add_magf2,ael_,Bgse_tpnm[0]
    add_scpot,ael_,  scp_tpn[0]
  ENDIF
  ;;--------------------------------------------------------------------------------------
  ;;  EESA Low Burst
  ;;--------------------------------------------------------------------------------------
  IF (SIZE(elbdat,/TYPE) EQ 8) THEN BEGIN
    aelb = elbdat.DATA
    add_vsw2, aelb,Vgse_tpnm[0]
    add_magf2,aelb,Bgse_tpnm[0]
    add_scpot,aelb,  scp_tpn[0]
  ENDIF
  ;;--------------------------------------------------------------------------------------
  ;;  EESA High
  ;;--------------------------------------------------------------------------------------
  IF (SIZE(eh_dat,/TYPE) EQ 8) THEN BEGIN
    aeh_ = eh_dat.DATA
    add_vsw2, aeh_,Vgse_tpnm[0]
    add_magf2,aeh_,Bgse_tpnm[0]
    add_scpot,aeh_,  scp_tpn[0]
  ENDIF
  ;;--------------------------------------------------------------------------------------
  ;;  EESA High Burst
  ;;--------------------------------------------------------------------------------------
  IF (SIZE(ehbdat,/TYPE) EQ 8) THEN BEGIN
    aehb = ehbdat.DATA
    add_vsw2, aehb,Vgse_tpnm[0]
    add_magf2,aehb,Bgse_tpnm[0]
    add_scpot,aehb,  scp_tpn[0]
  ENDIF
  ;;--------------------------------------------------------------------------------------
  ;;  Define BURST_ON status for ELB and EHB
  ;;--------------------------------------------------------------------------------------
  burst_on.ELB   = (N_ELEMENTS(aelb) GT 1)
  burst_on.EHB   = (N_ELEMENTS(aehb) GT 1)
  ;;--------------------------------------------------------------------------------------
  ;;  Print out name as a check
  ;;--------------------------------------------------------------------------------------
  fname          = savdir[0]+fpref[0]+tsuffx[0]+fsuffx[0]
  PRINT,';; ',fname[0]
  ;;--------------------------------------------------------------------------------------
  ;;  Create IDL save file
  ;;--------------------------------------------------------------------------------------
  SAVE,ael_,aelb,aeh_,aehb,FILENAME=fname[0],DESCRIPTION=idl_save_desc[0]
  ;;--------------------------------------------------------------------------------------
  ;;  Clean up
  ;;--------------------------------------------------------------------------------------
  dumb = TEMPORARY(ael_) & dumb = TEMPORARY(aeh_) & dumb = TEMPORARY(aelb) & dumb = TEMPORARY(aehb)
  dumb = TEMPORARY(el_dat) & dumb = TEMPORARY(elbdat)
  dumb = TEMPORARY(eh_dat) & dumb = TEMPORARY(ehbdat)
ENDIF ELSE BEGIN
  el_dat         = 0
  elbdat         = 0
  eh_dat         = 0
  ehbdat         = 0
ENDELSE
;;----------------------------------------------------------------------------------------
;;  Get solid-state telescope [SST] velocity distribution functions (VDFs)
;;    for electrons [Foil] and protons [Open]
;;
;;    Foil  :   ~20-550 keV electrons
;;    Open  :  ~70-6500 keV protons
;;----------------------------------------------------------------------------------------
fpref          = 'SST-Foil-Open_3DP_Structures_'
fsuffx         = '_w-Vsw-Ni-SCPot.sav'
;;  Initialize structure variables
asf_           = 0
asfb           = 0
aso_           = 0
asob           = 0
IF (sst__on[0]) THEN BEGIN
  sf_dat         = get_3dp_structs('sf' ,TRANGE=tran1d)      ;;  SST Foil
  sfbdat         = get_3dp_structs('sfb',TRANGE=tran1d)      ;;  SST Foil Burst
  so_dat         = get_3dp_structs('so' ,TRANGE=tran1d)      ;;  SST Open
  sobdat         = get_3dp_structs('sob',TRANGE=tran1d)      ;;  SST Open Burst
  ;;--------------------------------------------------------------------------------------
  ;;  SST Foil
  ;;--------------------------------------------------------------------------------------
  IF (SIZE(sf_dat,/TYPE) EQ 8) THEN BEGIN
    asf_         = sf_dat.DATA
    add_vsw2, asf_,Vgse_tpnm[0]
    add_magf2,asf_,Bgse_tpnm[0]
    add_scpot,asf_,  scp_tpn[0]
  ENDIF
  ;;--------------------------------------------------------------------------------------
  ;;  SST Foil Burst
  ;;--------------------------------------------------------------------------------------
  IF (SIZE(sfbdat,/TYPE) EQ 8) THEN BEGIN
    asfb         = sfbdat.DATA
    add_vsw2, asfb,Vgse_tpnm[0]
    add_magf2,asfb,Bgse_tpnm[0]
    add_scpot,asfb,  scp_tpn[0]
  ENDIF
  ;;--------------------------------------------------------------------------------------
  ;;  SST Open
  ;;--------------------------------------------------------------------------------------
  IF (SIZE(so_dat,/TYPE) EQ 8) THEN BEGIN
    aso_         = so_dat.DATA
    add_vsw2, aso_,Vgse_tpnm[0]
    add_magf2,aso_,Bgse_tpnm[0]
    add_scpot,aso_,  scp_tpn[0]
  ENDIF
  ;;--------------------------------------------------------------------------------------
  ;;  SST Open Burst
  ;;--------------------------------------------------------------------------------------
  IF (SIZE(sobdat,/TYPE) EQ 8) THEN BEGIN
    asob         = sobdat.DATA
    add_vsw2, asob,Vgse_tpnm[0]
    add_magf2,asob,Bgse_tpnm[0]
    add_scpot,asob,  scp_tpn[0]
  ENDIF
  ;;--------------------------------------------------------------------------------------
  ;;  Define BURST_ON status for SFB and SOB
  ;;--------------------------------------------------------------------------------------
  burst_on.SFB   = (N_ELEMENTS(asfb) GT 1)
  burst_on.SOB   = (N_ELEMENTS(asob) GT 1)
  ;;--------------------------------------------------------------------------------------
  ;;  Print out name as a check
  ;;--------------------------------------------------------------------------------------
  fname          = savdir[0]+fpref[0]+tsuffx[0]+fsuffx[0]
  PRINT,';; ',fname[0]
  ;;--------------------------------------------------------------------------------------
  ;;  Create IDL save file
  ;;--------------------------------------------------------------------------------------
  SAVE,asf_,asfb,aso_,asob,FILENAME=fname[0],DESCRIPTION=idl_save_desc[0]
  ;;--------------------------------------------------------------------------------------
  ;;  Clean up
  ;;--------------------------------------------------------------------------------------
  dumb = TEMPORARY(asf_) & dumb = TEMPORARY(aso_) & dumb = TEMPORARY(asfb) & dumb = TEMPORARY(asob)
  dumb = TEMPORARY(sf_dat) & dumb = TEMPORARY(sfbdat)
  dumb = TEMPORARY(so_dat) & dumb = TEMPORARY(sobdat)
ENDIF ELSE BEGIN
  sf_dat         = 0
  sfbdat         = 0
  so_dat         = 0
  sobdat         = 0
ENDELSE
;;----------------------------------------------------------------------------------------
;;  Clean up
;;----------------------------------------------------------------------------------------
dumb           = TEMPORARY(Bgse_tpnm) & dumb = TEMPORARY(Vgse_tpnm) & dumb = TEMPORARY(scp_tpn)
dumb           = TEMPORARY(fnm) & dumb = TEMPORARY(ftimes) & dumb = TEMPORARY(ftime0) & dumb = TEMPORARY(tsuffx)
dumb           = TEMPORARY(fname) & dumb = TEMPORARY(fpref) & dumb = TEMPORARY(fsuffx)
;;  Remove TPLOT handles/data
nna            = tnames()
IF (nna[0] NE '') THEN IF (cleant_on[0]) THEN store_data,DELETE=nna  ;;  Clean up TPLOT
;;----------------------------------------------------------------------------------------
;;  Return to user
;;----------------------------------------------------------------------------------------

RETURN
END










































