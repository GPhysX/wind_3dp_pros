;+
;*****************************************************************************************
;
;  CRIBSHEET:   wind_load_and_plot_3dp_vdf_then_fit_crib.pro
;  PURPOSE  :   To load and model particle velocity distributions from the Wind/3DP
;                 instrument by fitting them to the sum of multiple velocity
;                 distributions.
;
;  CALLED BY:   
;               NA
;
;  INCLUDES:
;               NA
;
;  CALLS:
;               time_double.pro
;               wind_load_and_plot_3dp_vdf_compare_shocks_batch.pro
;               fill_range.pro
;               find_strahl_direction.pro
;               time_string.pro
;               mag__vec.pro
;               conv_units.pro
;               conv_vdfidlstr_2_f_vs_vxyz_thm_wi.pro
;               trange_str.pro
;               wrapper_fit_vdf_2_sumof3funcs.pro
;               num2int_str.pro
;
;  REQUIRES:    
;               1)  UMN Modified Wind/3DP IDL Libraries
;               2)  The following data:
;                     Wind/3DP level zero files
;                     Wind/MFI H0 CDF files
;               3)  Craig B. Markwardt's MPFIT Software
;
;  INPUT:
;               NA
;
;  EXAMPLES:    
;               [calling sequence]
;               NA
;
;  KEYWORDS:    
;               NA
;
;   CHANGED:  1)  Adjusted to account for changes made to wrapper_fit_vdf_2_sumof2funcs.pro
;                                                                   [05/08/2018   v1.0.1]
;             2)  Fixed issue with events where no burst data is available the previously
;                   caused batch routine to crash and exit prematurely
;                                                                   [05/22/2018   v1.0.2]
;             3)  Updated to use wrapper_fit_vdf_2_sumof3funcs.pro
;                                                                   [08/15/2019   v1.0.3]
;
;   NOTES:      
;               1)  Follow notes in crib and enter each line by hand in the command line
;               2)  Definitions
;                     SWF  :  solar wind frame of reference
;                     FAC  :  field-aligned coordinates
;                     VDF  :  velocity distribution function
;               3)  The spacecraft (SC) potential estimates given below are really a
;                     proxy, not the real values.  This is because the deadtime and
;                     efficiency estimates for each solid angle bin are currently
;                     defined as the analytical estimates from theory for electrons
;                     incident on chevron MCPs.  The SC potential estimates are adjusted
;                     manually until the total electron density determined from the fits
;                     matches (roughly) the density determined from the upper hybrid
;                     line observed by the WAVES TNR instrument (i.e., the only
;                     unambiguous measure of the total electron density).
;               4)  For an explanation of the deadtime and efficiency estimates for MCPs
;                     see the work by Goruganthu and Wilson [1984],
;                     Meeks and Siegel [2008], and Schecker et al. [1992].
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
;              12)  Markwardt, C. B. "Non-Linear Least Squares Fitting in IDL with
;                     MPFIT," in proc. Astronomical Data Analysis Software and Systems
;                     XVIII, Quebec, Canada, ASP Conference Series, Vol. 411,
;                     Editors: D. Bohlender, P. Dowler & D. Durand, (Astronomical
;                     Society of the Pacific: San Francisco), pp. 251-254,
;                     ISBN:978-1-58381-702-5, 2009.
;              13)  Moré, J. 1978, "The Levenberg-Marquardt Algorithm: Implementation and
;                     Theory," in Numerical Analysis, Vol. 630, ed. G. A. Watson
;                     (Springer-Verlag: Berlin), pp. 105, doi:10.1007/BFb0067690, 1978.
;              14)  Moré, J. and S. Wright "Optimization Software Guide," SIAM,
;                     Frontiers in Applied Mathematics, Number 14,
;                     ISBN:978-0-898713-22-0, 1993.
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
;              19)  Location of MPFIT software
;                     https://www.physics.wisc.edu/~craigm/idl/fitting.html
;              20)  Goruganthu, R.R. and W.G. Wilson "Relative electron detection
;                      efficiency of microchannel plates from 0-3 keV,"
;                      Rev. Sci. Inst. Vol. 55, pp. 2030-–2033, doi:10.1063/1.1137709,
;                      1984.
;              21)  Meeks, C. and P.B. Siegel "Dead time correction via the time series,"
;                      Amer. J. Phys. Vol. 76, pp. 589--590, doi:10.1119/1.2870432, 2008.
;              22)  Schecker, J.A., et al., "The performance of a microchannel plate at
;                      cryogenic temperatures and in high magnetic fields, and the
;                      detection efficiency for low energy positive hydrogen ions,"
;                      Nucl. Inst. & Meth. in Phys. Res. A Vol. 320, pp. 556--561,
;                      doi:10.1016/0168-9002(92)90950-9, 1992.
;              23)  Wilson III, L.B., et al., "The Statistical Properties of Solar Wind
;                      Temperature Parameters Near 1 au," Astrophys. J. Suppl. 236(2),
;                      pp. 41, doi:10.3847/1538-4365/aab71c, 2019.
;              24)  Wilson III, L.B., et al., "Electron energy partition across
;                      interplanetary shocks: I. Methodology and Data Product,"
;                      Astrophys. J. Suppl. 243(8), doi:10.3847/1538-4365/ab22bd, 2019.
;              25)  Wilson III, L.B., et al., "Supplement to: Electron energy partition
;                      across interplanetary shocks," Zenodo Dataset,
;                      doi:10.5281/zenodo.2875806, 2019.
;
;   CREATED:  04/27/2018
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  08/15/2019   v1.0.3
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

;;----------------------------------------------------------------------------------------
;;  Turn on vectors and parallel cores
;;----------------------------------------------------------------------------------------
nthreads       = !CPU.HW_NCPU[0]
CPU,TPOOL_MIN_ELTS=10000L,/VECTOR_ENABLE,TPOOL_NTHREADS=nthreads[0]
PREF_SET,'IDL_CPU_TPOOL_NTHREADS',nthreads[0],/COMMIT
PREF_SET,'IDL_CPU_TPOOL_MIN_ELTS',10000L,/COMMIT
PREF_SET,'IDL_CPU_VECTOR_ENABLE',1b,/COMMIT
;;---------------------------------------------------
;;  1996-04-03
;;---------------------------------------------------
date           = '040396'
tdate          = '1996-04-03'
tramp          = '1996-04-03/09:47:17.152'

tura           = time_double(tramp[0])
trange         = tura[0] + [-1,1]*2d0*36d2       ;;  Use 2 hour window around ramp
;;----------------------------------------------------------------------------------------
;;  Load 3DP, MFI, and SWE data
;;----------------------------------------------------------------------------------------
;;  ***  Change directory path accordingly!  ***
@/Users/lbwilson/Desktop/swidl-0.1//wind_3dp_pros/wind_3dp_cribs/wind_load_and_plot_3dp_vdf_compare_shocks_batch.pro
;;  Redefine ramp time [above batch file gets new ramp time from JCK's shock database]
tura           = time_double(tramp[0])
trange         = tura[0] + [-1,1]*2d0*36d2       ;;  Use 4 hour window around ramp
;;----------------------------------------------------------------------------------------
;;  Define some default parameters
;;----------------------------------------------------------------------------------------
;;  Define some conversion factors
vte2tekfac      = 1d6*me[0]/2d0/kB[0]      ;;  Converts thermal speed squared to temperature [K]
vte2teevfac     = vte2tekfac[0]*K2eV[0]    ;;  Converts thermal speed squared to temperature [eV]
;;  Define some defaults
dfra_aplb      = [1e-9,5e-5]      ;;  Default VDF range for PESA Low Burst
vlim_aplb      = 75e1             ;;  Default velocity range for PESA Low Burst
dfra_aelb      = [1e-18,1e-9]     ;;  Default VDF range for EESA Low Burst
vlim_aelb      = 20e3             ;;  Default velocity range for EESA Low Burst
xname          = 'Bo'
yname          = 'Vsw'
;;  Use one of the following depending on what one plots
ttl_midfs      = [instnmmode_elb[0],instnmmode_plb[0],instnmmode_phb[0]]
;;----------------------------------------------------------------------------------------
;;  Define EESA Low Burst VDFs [could just as well define PESA Low Burst VDFs]
;;----------------------------------------------------------------------------------------
dat1           = aelb
n_elb          = N_ELEMENTS(dat1)
e_ind          = fill_range(0L,n_elb[0]-1L,DIND=1L)        ;;  change as user sees fit
;;  Find strahl direction signs (relative to Bo)
strahl         = find_strahl_direction(TRANSPOSE(dat1.MAGF))
dfra           = dfra_aelb        ;;  Default VDF range for PESA Low Burst
vlim           = vlim_aelb        ;;  Default velocity range for PESA Low Burst
tran_vdf       = tran_elb
fname_mid      = fname_mid_elb
pttl_midf      = ttl_midfs[0]

;;  Limit SC Potential to ≤ +11.3 eV for this date since energy bins are
;;    ~8.6, ~11.2, ~14.97, ~20.6, etc.
;;     [factor of 1.25 is to offset factor of 1.3 used later]
;;    See NOTES section in Man. page (above) for explanation of real meaning of
;;    the spacecraft potential.
scpot_max      = 11.3e0*[1,1]/1.25
temp           = REFORM(dat1.SC_POT)
t_st           = REFORM(dat1.TIME)
good_up        = WHERE(t_st LT tura[0],gd_up,COMPLEMENT=good_dn,NCOMPLEMENT=gd_dn)
IF (gd_up[0] GT 0) THEN max_up               = MAX(temp[good_up],/NAN)
IF (gd_up[0] GT 0) THEN med_up               = MEDIAN(temp[good_up])
IF (gd_up[0] GT 0) THEN new_upmax            = (temp[good_up]*ABS(scpot_max[0]))/max_up[0]
IF (gd_up[0] GT 0) THEN dat1[good_up].SC_POT = new_upmax

IF (gd_dn[0] GT 0) THEN max_dn               = MAX(temp[good_dn],/NAN)
IF (gd_dn[0] GT 0) THEN med_dn               = MEDIAN(temp[good_dn])
IF (gd_dn[0] GT 0) THEN new_dnmax            = (temp[good_dn]*ABS(scpot_max[1]))/max_dn[0]
IF (gd_dn[0] GT 0) THEN dat1[good_dn].SC_POT = new_dnmax
;;----------------------------------------------------------------------------------------
;;  Define specific EESA Low Burst VDF [could just as well define PESA Low Burst VDFs]
;;----------------------------------------------------------------------------------------
jj             = 0L
ii             = e_ind[jj]
dat0           = dat1[jj]         ;;  EESA Low Burst
;;  These are some pre-defined bulk flow velocities determined using the Vbulk Change
;;    software to find the true peak phase space density location from the PESA Low
;;    VDFs.
IF (time_string(dat0.TIME) EQ '1996-04-03/09:47:10') THEN dat0[0].VSW = [-352.6083e0,17.4598e0, 6.3212e0]
IF (time_string(dat0.TIME) EQ '1996-04-03/09:47:14') THEN dat0[0].VSW = [-353.3347e0,17.7673e0,13.7160e0]
IF (time_string(dat0.TIME) EQ '1996-04-03/09:47:17') THEN dat0[0].VSW = [-353.3309e0,19.8303e0,15.7891e0]
IF (time_string(dat0.TIME) EQ '1996-04-03/09:47:20') THEN dat0[0].VSW = [-359.5624e0,17.5794e0,16.1354e0]
IF (time_string(dat0.TIME) EQ '1996-04-03/09:47:23') THEN dat0[0].VSW = [-363.2769e0,19.0922e0,16.8559e0]
IF (time_string(dat0.TIME) EQ '1996-04-03/09:47:26') THEN dat0[0].VSW = [-366.8244e0,13.0794e0,17.8965e0]
IF (time_string(dat0.TIME) EQ '1996-04-03/09:47:29') THEN dat0[0].VSW = [-365.0393e0,17.5948e0,17.0503e0]
;;  Prevent interpolation below SC potential
IF (dat0.SC_POT[0] GT 0e0) THEN dat0.DATA[WHERE(dat0.ENERGY LE 1.3e0*dat0.SC_POT[0])] = f

IF (vlim[0] GT 1e4) THEN vframe = [0d0,0d0,0d0] ELSE vframe = REFORM(dat0[0].VSW)  ;;  Transformation velocity [km/s]
IF (vlim[0] GT 1e4) THEN ttle_ext       = 'SCF' ELSE ttle_ext       = 'SWF'        ;;  string to add to plot title indicating reference frame shown
IF (tdate[0] EQ '1996-04-03') THEN vframe = REFORM(dat0[0].VSW)                    ;;  Transformation velocity [km/s]
IF (tdate[0] EQ '1996-04-03') THEN ttle_ext       = 'SWF'                          ;;  string to add to plot title indicating reference frame shown
vfmag          = mag__vec(vframe,/NAN)
pttl_pref      = sc[0]+' ['+ttle_ext[0]+'] '+pttl_midf[0]
;;----------------------------------------------------------------------------------------
;;  Plot 2D contour in SWF, in FAC coordinate basis, and fit
;;----------------------------------------------------------------------------------------
dumbfix        = REPLICATE(0b,6)
sm_cuts        = 1b               ;;  Do smooth cuts
sm_cont        = 1b               ;;  Do smooth contours
nlev           = 30L
ngrid          = 101L
vec1           = REFORM(dat0[0].MAGF)
vec2           = REFORM(dat0[0].VSW)
;;  Define an initial guess for the bi-self-similar parameters of the core electrons
cparm          = [6.5d0,22d2,25d2,-4d2,1d1,3d0]
;;  Define an initial guess for the bi-kappa parameters of the halo electrons
hparm          = [4d-1,50d2,50d2, 2d3,0d0,3d0]
;;  Define an initial guess for the bi-kappa parameters of the strahl electrons
bparm          = [3d-2,50d2,65d2, 4d3,0d0,3d0]
emin_ch        = 2.90d0                   ;;  Lowest energy [eV] to allow for core+halo fits
emin_b         = 10d1                     ;;  Lowest energy [eV] to allow for beam fits
;;----------------------------------------------------------------------------------------
;;  Account for strahl and define/set limits
;;----------------------------------------------------------------------------------------
;;  Drift Speed constraints
voahalorn      = [1,1,0d0,15d3]
voabeamrn      = [1,1,2d3,15d3]
IF (ABS(strahl[jj]) GT 0) THEN hparm[3]      *= (-1*strahl[jj])
IF (ABS(strahl[jj]) GT 0) THEN bparm[3]      *= (-1*sign(hparm[3]))
IF (ABS(strahl[jj]) GT 0) THEN voabeamrn[2]   = (-1*sign(hparm[3]))*ABS(voabeamrn[2])
IF (ABS(strahl[jj]) GT 0) THEN voabeamrn[3]   = (-1*sign(hparm[3]))*ABS(voabeamrn[3])
IF (ABS(strahl[jj]) GT 0) THEN sp             = SORT(voabeamrn[2:3])
IF (ABS(strahl[jj]) GT 0) THEN IF (sp[0] NE 0) THEN voabeamrn[2:3] = voabeamrn[[3,2]]

IF (ABS(strahl[jj]) GT 0) THEN voahalorn[2:3]   = (-1*strahl[jj])*ABS(voahalorn[2:3])
IF (ABS(strahl[jj]) GT 0) THEN sp               = SORT(voahalorn[2:3])
IF (ABS(strahl[jj]) GT 0) THEN IF (sp[0] NE 0) THEN voahalorn[2:3] = voahalorn[[3,2]]   ;;  Make sure in proper order
IF (ABS(strahl[jj]) GT 0) THEN test           = (sign(hparm[3]) EQ sign(bparm[3])) OR ((sign(voabeamrn[3]) EQ sign(voahalorn[3])) AND (voahalorn[0] GT 0))
IF (test[0]) THEN STOP      ;;  Make sure sign is not screwed up
;;  Thermal Speed constraints
vtahalorn      = [1,1,125d-2*cparm[1],1d4]
vtehalorn      = [1,1,125d-2*cparm[2],1d4]
vtabeamrn      = [1,1,125d-2*cparm[1],1d4]
vtebeamrn      = [1,1,125d-2*cparm[2],1d4]
;;  Exponent constraints
;;    Note that while the kappa value can, in principle, go down to 3/2, I have found
;;      that any values below 2.0 start to look like unrealistic ``spiky'' fits, which
;;      do not seem to care about the data at all.  That is, the output looks obviously
;;      wrong/bad and even though the reduced chi-squared may look okay.
expcorern      = [1,1,2d0,1d1]        ;;  Use the ES2CORERN keyword if CFUNC = 'AS' --> also need to change values of CPARM[4] and CPARM[5]
exphalorn      = [1,1,1.75d0,10d1]
expbeamrn      = exphalorn

fixed_c        = dumbfix
fixed_h        = dumbfix
fixed_b        = dumbfix
fixed_h[4]     = 1b                       ;;  Prevent fit routines from varying perpendicular drift velocity
fixed_b[4]     = 1b                       ;;  Prevent fit routines from varying perpendicular drift velocity
;;  Setup fit function stuff
cfunc          = 'SS'
hfunc          = 'KK'
bfunc          = 'KK'
;;----------------------------------------------------------------------------------------
;;  Define some plot parameters
;;----------------------------------------------------------------------------------------
;;  Define one-count level VDF
datc           = dat0[0]
datc.DATA      = 1e0            ;;  Create a one-count copy
;;  Define Poisson statistics VDF
datp           = dat0[0]
datp.DATA      = SQRT(dat0[0].DATA)
;;  Convert to phase space density [# cm^(-3) km^(-3) s^(+3)]
;;    [works on Wind 3DP or THEMIS ESA distributions sent in as IDL structures]
dat_df         = conv_units(dat0,'df')
dat_1c         = conv_units(datc,'df')
dat_ps         = conv_units(datp,'df')
;;  Convert F(energy,theta,phi) to F(Vx,Vy,Vz)
;;    [works on Wind 3DP or THEMIS ESA distributions sent in as IDL structures]
dat_fvxyz      = conv_vdfidlstr_2_f_vs_vxyz_thm_wi(dat_df)
dat_1cxyz      = conv_vdfidlstr_2_f_vs_vxyz_thm_wi(dat_1c)
dat_psxyz      = conv_vdfidlstr_2_f_vs_vxyz_thm_wi(dat_ps)
;;  Define EX_VECS stuff  (for general_vdf_contour_plot.pro)
ex_vecs[0]     = {VEC:FLOAT(dat_df[0].VSW),NAME:'Vsw'}
ex_vecs[1]     = {VEC:FLOAT(dat_df[0].MAGF),NAME:'Bo'}
ex_vecs[2]     = {VEC:FLOAT(gnorm),NAME:'nsh'}
ex_vecs[3]     = {VEC:[1e0,0e0,0e0],NAME:'Sun'}
;;  Define EX_INFO stuff  (for general_vdf_contour_plot.pro)
ex_info        = {SCPOT:dat_df[0].SC_POT,VSW:dat_df[0].VSW,MAGF:dat_df[0].MAGF}
sm_cuts        = 1b               ;;  Do not smooth cuts
sm_cont        = 1b               ;;  Do not smooth contours
IF (vfmag[0] LT 1e0) THEN vxy_offs = [ex_info.VSW[xyind[0:1]]] ELSE vxy_offs = [0e0,0e0]  ;;  XY-Offsets of crosshairs

ptitle         = pttl_pref[0]+': '+trange_str(tran_vdf[ii,0],tran_vdf[ii,1],/MSEC)
;;  Define data arrays
data_1d        = dat_fvxyz.VDF                  ;;  [N]-Element [numeric] array of phase space densities [# s^(+3) km^(-3) cm^(-3)]
vels_1d        = dat_fvxyz.VELXYZ               ;;  [N,3]-Element [numeric] array of 3-vector velocities [km/s] corresponding to the phase space densities
onec_1d        = dat_1cxyz.VDF                  ;;  [N]-Element [numeric] array of one-count levels in units of phase space densities [# s^(+3) km^(-3) cm^(-3)]
pois_1d        = dat_psxyz.VDF                  ;;  [N]-Element [numeric] array of Poisson statistics [# cm^(-3) km^(-3) s^(+3)]
;;----------------------------------------------------------------------------------------
;;  Fit to sum of 3 functions
;;----------------------------------------------------------------------------------------
;;  Compile necessary routines to make sure IDL paths are okay and routines are available
.compile mpfit.pro
.compile mpfit2dfun.pro
.compile wrapper_fit_vdf_2_sumof3funcs.pro
;;  Define file name
vlim_str       = num2int_str(vlim[0],NUM_CHAR=6L,/ZERO_PAD)
fname_end      = 'para-red_perp-blue_1count-green_plane-'+plane[0]+'_VLIM-'+vlim_str[0]+'km_s'
fname_pre      = scpref[0]+'df_'+ttle_ext[0]+'_'
fnams_out2     = fname_pre[0]+fname_mid+'_'+fname_end[0]+'_Fits_Core-SS_Halo-KK_wo-strahl_Beam-KK'

;;  Save Plot [showing each 1D cut individually and total sum of three fits]
out_struc      = 0
wrapper_fit_vdf_2_sumof3funcs,data_1d,vels_1d,VFRAME=vframe,VEC1=vec1,VEC2=vec2,COREP=cparm,$
                          HALOP=hparm,BEAMP=bparm,CFUNC=cfunc,HFUNC=hfunc,BFUNC=bfunc,      $
                          VLIM=vlim[0],PLANE=plane[0],NLEV=nlev,NGRID=ngrid,DFRA=dfra,      $
                          SM_CUTS=sm_cuts,SM_CONT=sm_cont,XNAME=xname,YNAME=yname,          $
                          EX_VECS=ex_vecs,EX_INFO=ex_info,V_0X=vxy_offs[0],                 $
                          V_0Y=vxy_offs[1],/SLICE2D,ONE_C=onec_1d,P_TITLE=ptitle,           $
                          /STRAHL,V1ISB=strahl[jj],OUTSTRC=out_struc,                       $
                          FIXED_C=fixed_c,FIXED_H=fixed_h,FIXED_B=fixed_b,                  $
                          VOABEAMRN=voabeamrn,VOAHALORN=voahalorn,VOACORERN=voacorern,      $
                          VTABEAMRN=vtabeamrn,VTEBEAMRN=vtebeamrn,NBEAM_RAN=nbeam_ran,      $
                          VTACORERN=vtacorern,VTECORERN=vtecorern,NCORE_RAN=ncore_ran,      $
                          VTAHALORN=vtahalorn,VTEHALORN=vtehalorn,NHALO_RAN=nhalo_ran,      $
                          EXPCORERN=expcorern,EXPBEAMRN=expbeamrn,EXPHALORN=exphalorn,      $
                          ES2CORERN=es2corern,ES2HALORN=es2halorn,ES2BEAMRN=es2beamrn,      $
                          EMIN_CH=emin__ch,EMIN_B=emin__b,EMAX_CH=emax__ch,EMAX_B=emax__b,  $
                          FTOL=def_ftol,GTOL=def_gtol,XTOL=def_xtol,POISSON=pois_1d,        $
                          /PLOT_BOTH,NOUSECTAB=nousectab,S_SIGN=s_sign,                     $
                          /SAVEF,/KEEPNAN,FILENAME=fnams_out2[ii]
;;  Wind [SWF] Eesa Low Burst: 1996-04-03/09:46:17.248 - 09:46:20.408
;;  
;;  N_oc     =  +8.1202e+00 +/- 9.4135e-03  cm^(-3)
;;  V_Tcpar  =  +2.0386e+03 +/- 1.8266e+00  km s^(-1)
;;  V_Tcper  =  +2.0894e+03 +/- 1.9362e+00  km s^(-1)
;;  V_ocpar  =  -0.0000e+00 +/- 0.0000e+00  km s^(-1)
;;  V_ocper  =  +5.7730e+00 +/- 9.6741e-01  km s^(-1)
;;  SS expc  =  +2.0651e+00 +/- 2.8706e-03
;;  Model Fit Status  = 000002
;;  # of Iterations   = 000006
;;  Deg. of Freedom   = 0000010195
;;  Chi-Squared       = 8.8203e+03
;;  Red. Chi-Squared  = 8.6516e-01
;;  
;;  N_oh     =  +1.8093e-01 +/- 1.9876e-03  cm^(-3)
;;  V_Thpar  =  +4.2625e+03 +/- 1.2899e+01  km s^(-1)
;;  V_Thper  =  +4.4772e+03 +/- 1.3649e+01  km s^(-1)
;;  V_ohpar  =  -0.0000e+00 +/- 0.0000e+00  km s^(-1)
;;  V_ohper  =  -0.0000e+00 +/- 0.0000e+00  km s^(-1)
;;  kappah   =  +6.6349e+00 +/- 4.7530e-02
;;  Model Fit Status  = 000002
;;  # of Iterations   = 000010
;;  Deg. of Freedom   = 0000010196
;;  Chi-Squared       = 5.2817e+03
;;  Red. Chi-Squared  = 5.1802e-01
;;  
;;  N_ob     =  +8.0117e-02 +/- 1.3661e-03  cm^(-3)
;;  V_Tbpar  =  +3.3730e+03 +/- 2.0745e+01  km s^(-1)
;;  V_Tbper  =  +3.3491e+03 +/- 2.2357e+01  km s^(-1)
;;  V_obpar  =  +2.0000e+03 +/- 0.0000e+00  km s^(-1)
;;  V_obper  =  -0.0000e+00 +/- 0.0000e+00  km s^(-1)
;;  kappab   =  +3.5815e+00 +/- 3.9321e-02
;;  Model Fit Status  = 000002
;;  # of Iterations   = 000025
;;  Deg. of Freedom   = 0000010196
;;  Chi-Squared       = 2.5492e+03
;;  Red. Chi-Squared  = 2.5002e-01
;;

;;  Print temperatures [eV] and anisotropies
c__parms       = out_struc.CORE.FIT_PARAMS
h__parms       = out_struc.HALO.FIT_PARAMS
b__parms       = out_struc.BEAM.FIT_PARAMS
vte_all        = [c__parms[[1,2]],h__parms[[1,2]],b__parms[1:2]]      ;;  V_Tej [km/s]
tempall        = vte2teevfac[0]*vte_all^2d0                           ;;  T_ej [eV]
PRINT,';;',ptitle[0]  & $
PRINT,';;',tempall  & $
PRINT,';;',tempall[1]/tempall[0],tempall[3]/tempall[2],tempall[5]/tempall[4]
;;Wind [SWF] Eesa Low Burst: 1996-04-03/09:46:17.248 - 09:46:20.408
;;       11.814735       12.410918       51.650569       56.985424       32.343752       31.886805
;;       1.0504610       1.1032874      0.98587216
;;
;;         Tcpara          Tcperp          Thpara          Thperp          Tspara          Tsperp
;;         Tcanis          Thanis          Tsanis
;;
;;         Tjanis  = Tjperp/Tjpara  =  temperature anisotropy





;;  ***  Old/Obsolete  ***
;;
;;Wind [SWF] Eesa Low Burst: 1996-04-03/09:46:17.248 - 09:46:20.408
;;       10.608220       11.631794       55.616676       62.470147       17.114096       16.679250
;;       1.0964887       1.1232269      0.97459133
;;
;;         Tcpara          Tcperp          Thpara          Thperp          Tspara          Tsperp
;;         Tcanis          Thanis          Tsanis
;;
;;         Tjanis  = Tjperp/Tjpara  =  temperature anisotropy


;;  ***  Old/Obsolete  ***
;;
;;Wind [SWF] Eesa Low Burst: 1996-04-03/09:46:17.248 - 09:46:20.408
;;       8.0033960       9.5067176       38.147286       42.644262       37.260730       9.5750995
;;       1.1878355       1.1178846      0.25697563



