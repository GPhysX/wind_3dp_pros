;;----------------------------------------------------------------------------------------
;; => Define some constants and dummy variables
;;----------------------------------------------------------------------------------------
f              = !VALUES.F_NAN
d              = !VALUES.D_NAN
me             = 9.1093829100d-31     ;; => Electron mass [kg]
mp             = 1.6726217770d-27     ;; => Proton mass [kg]
ma             = 6.6446567500d-27     ;; => Alpha-Particle mass [kg]
c              = 2.9979245800d+08     ;; => Speed of light in vacuum [m/s]
epo            = 8.8541878170d-12     ;; => Permittivity of free space [F/m]
muo            = !DPI*4.00000d-07     ;; => Permeability of free space [N/A^2 or H/m]
qq             = 1.6021765650d-19     ;; => Fundamental charge [C]
kB             = 1.3806488000d-23     ;; => Boltzmann Constant [J/K]
hh             = 6.6260695700d-34     ;; => Planck Constant [J s]
GG             = 6.6738400000d-11     ;; => Newtonian Constant [m^(3) kg^(-1) s^(-1)]

f_1eV          = qq[0]/hh[0]          ;; => Freq. associated with 1 eV of energy [Hz]
J_1eV          = hh[0]*f_1eV[0]       ;; => Energy associated with 1 eV of energy [J]
;; => Temp. associated with 1 eV of energy [K]
K_eV           = qq[0]/kB[0]          ;; ~ 11,604.519 K
R_E            = 6.37814d3            ;; => Earth's Equitorial Radius [km]

; => Compile necessary routines
@comp_lynn_pros
.compile read_thm_j_E_S_corr
thm_init

WINDOW,1,RETAIN=2,XSIZE=1700,YSIZE=1100,TITLE='Energy Dissipation 1'
WINDOW,2,RETAIN=2,XSIZE=1700,YSIZE=1100,TITLE='Energy Dissipation 2'


;;----------------------------------------------------------------------------------------
;; => Define file name parameters etc.
;;----------------------------------------------------------------------------------------
mdir           = FILE_EXPAND_PATH('IDL_stuff/themis_data_dir/themis_ascii/')
nsm            = 10L
nsms           = STRING(FORMAT='(I3.3)',nsm[0])
sm_suffx       = '_sm'+nsms[0]+'pts'
jes_tagsu      = ['SCETS','UNIX','J_MAG_SM','J_VEC_NIF_NCB_SM','E_VEC_NIF_GSE_JT', $
                  'B_VEC_SCF_GSE_JT','S_VEC_NIF_GSE_JT','S_POW_NIF_GSE_JT',        $
                  'S_DOT_N_N_NIF_GSE','N_X_S_X_N_NIF_GSE','NEG_E_DOT_J_SM',        $
                  'ETA_JSQ_GSE','ETA_JSQ_NIF']
jes_tags       = STRLOWCASE(jes_tagsu)  ;; tags from read_thm_j_E_S_corr.pro
cross_str      = ['1st','2nd','3rd','4th','5th','6th','7th','8th','9th']
probes         = ['b','c','a']
xyprefs        = STRUPCASE('th'+probes)
scprefs        = xyprefs+'_'
tdates         = ['2009-07-13','2009-07-23','2009-09-26']
def_fpref      = 'Relevant_Dissipation_Parameters_jtimestamps'+sm_suffx[0]+'_'+scprefs


fnames         = def_fpref+tdates+'_*'
file_0713      = FILE_SEARCH(mdir,fnames[0])
file_0723      = FILE_SEARCH(mdir,fnames[1])
file_0926      = FILE_SEARCH(mdir,fnames[2])
n_0713         = N_ELEMENTS(file_0713)
n_0723         = N_ELEMENTS(file_0723)
n_0926         = N_ELEMENTS(file_0926)

all_files      = [file_0713,file_0723,file_0926]
n_cross        = N_ELEMENTS(all_files)
nind           = LINDGEN(n_cross)
all_tdates     = [REPLICATE(tdates[0],n_0713),REPLICATE(tdates[1],n_0723),REPLICATE(tdates[2],n_0926)]
c_tags         = 'C_'+STRING(nind,FORMAT='(I3.3)')

all_cross_str  = [cross_str[LINDGEN(n_0713)],cross_str[LINDGEN(n_0723)],cross_str[LINDGEN(n_0926)]]
all_xyprefs    = [REPLICATE(xyprefs[0],n_0713),REPLICATE(xyprefs[1],n_0723),REPLICATE(xyprefs[2],n_0926)]
xyout_suf      = ' ['+all_cross_str+' BS Crossing]'
all_xyout      = all_xyprefs+' '+all_tdates+xyout_suf     ;; strings for XYOUTS
xposi_xyout    = REPLICATE(0.12,n_cross)                  ;; X[normal]-positions for XYOUTS
yposi_xyout    = 0.95 - FLOAT(nind)*0.03                  ;; Y[normal]-positions for XYOUTS
xyout_cols     = nind*(250L - 30L)/(n_cross - 1L) + 30L   ;; colors for XYOUTS
;;----------------------------------------------------------------------------------------
;; => Define Define rotation from GSE to NCB
;;----------------------------------------------------------------------------------------
jj             = 0L
;; => Avg. terms [2009-07-13:  1st Shock Crossing]
gnorm          = [0.99012543d0,0.086580460d0,-0.0038282813d0]
theta_Bn       =   42.213702d0
magf_up        = [-2.88930d0,1.79045d0,-1.37976d0]
magf_dn        = [  -3.85673d0,10.8180d0,-8.72761d0]
;; => X'-vector
xvnor          = gnorm/NORM(REFORM(gnorm))
;; => Y'-vector
yvect          = my_crossp_2(magf_dn,magf_up,/NOM)
yvnor          = yvect/NORM(REFORM(yvect))
;; => Z'-vector
zvect          = my_crossp_2(xvnor,yvnor,/NOM)
zvnor          = zvect/NORM(REFORM(zvect))
;; => Rotation Matrix from NCB to ICB
rotgse         = TRANSPOSE([[xvnor],[yvnor],[zvnor]])
;; => Define rotation from ICB to NCB
rotnif         = LA_INVERT(rotgse)
str_element,all_rotgse,c_tags[jj],rotgse,/ADD_REPLACE
str_element,all_rotnif,c_tags[jj],rotnif,/ADD_REPLACE

;;--------------------------------------------------------------
;; => Avg. terms [2009-07-23:  1st Shock Crossing]
;;--------------------------------------------------------------
jj            += 1L
gnorm          = [0.99518093d0,0.021020125d0,0.011474467d0]  ;; GSE
theta_Bn       =   88.569206d0
magf_up        = [-0.0836601d0,0.112276d0,-6.04225d0]
magf_dn        = [-1.17367d0,2.16511d0,-19.2497d0]
;; => X'-vector
xvnor          = gnorm/NORM(REFORM(gnorm))
;; => Y'-vector
yvect          = my_crossp_2(magf_dn,magf_up,/NOM)
yvnor          = yvect/NORM(REFORM(yvect))
;; => Z'-vector
zvect          = my_crossp_2(xvnor,yvnor,/NOM)
zvnor          = zvect/NORM(REFORM(zvect))
;; => Rotation Matrix from NCB to ICB
rotgse         = TRANSPOSE([[xvnor],[yvnor],[zvnor]])
;; => Define rotation from ICB to NCB
rotnif         = LA_INVERT(rotgse)
str_element,all_rotgse,c_tags[jj],rotgse,/ADD_REPLACE
str_element,all_rotnif,c_tags[jj],rotnif,/ADD_REPLACE
;;--------------------------------------------------------------
;; => Avg. terms [2009-07-23:  2nd Shock Crossing]
;;--------------------------------------------------------------
jj            += 1L
gnorm          = [0.99615338d0,-0.079060538d0,-0.0026399172d0]
theta_Bn       =   88.975636d0
magf_up        = [-0.114245d0,0.135357d0,-6.06984d0]
magf_dn        = [1.48669d0,-17.6263d0,-15.3921d0]
;; => X'-vector
xvnor          = gnorm/NORM(REFORM(gnorm))
;; => Y'-vector
yvect          = my_crossp_2(magf_dn,magf_up,/NOM)
yvnor          = yvect/NORM(REFORM(yvect))
;; => Z'-vector
zvect          = my_crossp_2(xvnor,yvnor,/NOM)
zvnor          = zvect/NORM(REFORM(zvect))
;; => Rotation Matrix from NCB to ICB
rotgse         = TRANSPOSE([[xvnor],[yvnor],[zvnor]])
;; => Define rotation from ICB to NCB
rotnif         = LA_INVERT(rotgse)
str_element,all_rotgse,c_tags[jj],rotgse,/ADD_REPLACE
str_element,all_rotnif,c_tags[jj],rotnif,/ADD_REPLACE
;;--------------------------------------------------------------
;; => Avg. terms [2009-07-23:  3rd Shock Crossing]
;;--------------------------------------------------------------
jj            += 1L
gnorm          = [0.99282966d0,0.064151304d0,-0.0022364971d0]
theta_Bn       =   56.199579d0
magf_up        = [3.88880d0,-4.95385d0,1.12260d0]
magf_dn        = [4.13227d0,-15.5434d0,2.96303d0]
;; => X'-vector
xvnor          = gnorm/NORM(REFORM(gnorm))
;; => Y'-vector
yvect          = my_crossp_2(magf_dn,magf_up,/NOM)
yvnor          = yvect/NORM(REFORM(yvect))
;; => Z'-vector
zvect          = my_crossp_2(xvnor,yvnor,/NOM)
zvnor          = zvect/NORM(REFORM(zvect))
;; => Rotation Matrix from NCB to ICB
rotgse         = TRANSPOSE([[xvnor],[yvnor],[zvnor]])
;; => Define rotation from ICB to NCB
rotnif         = LA_INVERT(rotgse)
str_element,all_rotgse,c_tags[jj],rotgse,/ADD_REPLACE
str_element,all_rotnif,c_tags[jj],rotnif,/ADD_REPLACE

;;--------------------------------------------------------------
;; => Avg. terms [2009-09-26:  1st Shock Crossing]
;;--------------------------------------------------------------
jj            += 1L
gnorm          = [0.95576882d0,-0.18012919d0,-0.14100009d0]  ;; GSE
theta_Bn       =   51.464211d0
magf_up        = [1.54738d0,-0.185112d0,-2.65947d0]
magf_dn        = [-1.69473d0,-14.2039d0,1.26029d0]
;; => X'-vector
xvnor          = gnorm/NORM(REFORM(gnorm))
;; => Y'-vector
yvect          = my_crossp_2(magf_dn,magf_up,/NOM)
yvnor          = yvect/NORM(REFORM(yvect))
;; => Z'-vector
zvect          = my_crossp_2(xvnor,yvnor,/NOM)
zvnor          = zvect/NORM(REFORM(zvect))
;; => Rotation Matrix from NCB to ICB
rotgse         = TRANSPOSE([[xvnor],[yvnor],[zvnor]])
;; => Define rotation from ICB to NCB
rotnif         = LA_INVERT(rotgse)
str_element,all_rotgse,c_tags[jj],rotgse,/ADD_REPLACE
str_element,all_rotnif,c_tags[jj],rotnif,/ADD_REPLACE


;;----------------------------------------------------------------------------------------
;; => Get data from ASCII files
;;----------------------------------------------------------------------------------------
FOR j=0L, n_cross - 1L DO BEGIN                                           $
  temp = read_thm_j_E_S_corr(FILE_NAME=all_files[j])                    & $
  str_element,all_data,c_tags[j],temp[0],/ADD_REPLACE                   & $
  str_element,all_ns,c_tags[j],N_ELEMENTS(temp[0].SCETS),/ADD_REPLACE

FOR j=0L, n_cross - 1L DO PRINT,';; ', all_ns.(j)
;;         1648
;;          816
;;          816
;;         1648
;;         1648

n_pts          = 0L
FOR j=0L, n_cross - 1L DO n_pts += all_ns.(j)
PRINT,';; ', n_cross, n_pts
;;            5        6576

;;--------------------------------------------------------------
;; Define j and |j|  [µA m^(-2), in NIF and NCB]
;;--------------------------------------------------------------
test           = (jes_tags EQ 'j_mag_sm') OR (jes_tags EQ 'j_vec_nif_ncb_sm')
ind            = WHERE(test,in)
FOR j=0L, n_cross - 1L DO BEGIN                                         $
  str_element,jmag_v_sm,c_tags[j],all_data.(j).(ind[0]),/ADD_REPLACE  & $
  str_element,jvec_v_sm,c_tags[j],all_data.(j).(ind[1]),/ADD_REPLACE

;;--------------------------------------------------------------
;;  Define EFI [mV/m, from efw] & SCM [nT, from scw]
;;    [in NIF and GSE]
;;--------------------------------------------------------------
test           = (jes_tags EQ 'e_vec_nif_gse_jt') OR (jes_tags EQ 'b_vec_scf_gse_jt')
ind            = WHERE(test,in)
FOR j=0L, n_cross - 1L DO BEGIN                                             $
  str_element,efi_nifgse_jt,c_tags[j],all_data.(j).(ind[0]),/ADD_REPLACE  & $
  str_element,scm_scfgse_jt,c_tags[j],all_data.(j).(ind[1]),/ADD_REPLACE

;;--------------------------------------------------------------
;;  Define S [µW m^(-2)] & |S(w,k)| [µW m^(-2) Hz, the Hz = ?]
;;    [in NIF and GSE]
;;--------------------------------------------------------------
test           = (jes_tags EQ 's_vec_nif_gse_jt') OR (jes_tags EQ 's_pow_nif_gse_jt')
ind            = WHERE(test,in)
FOR j=0L, n_cross - 1L DO BEGIN                                             $
  str_element,Svec_nif_jt,c_tags[j],all_data.(j).(ind[0]),/ADD_REPLACE    & $
  str_element,Spow_nif_jt,c_tags[j],all_data.(j).(ind[1]),/ADD_REPLACE

;;--------------------------------------------------------------
;; Define Sn [= (n . S) n] & St [= n x (S x n)]
;;    [µW m^(-2), in NIF and GSE]
;;--------------------------------------------------------------
test           = (jes_tags EQ 's_dot_n_n_nif_gse') OR (jes_tags EQ 'n_x_s_x_n_nif_gse')
ind            = WHERE(test,in)
FOR j=0L, n_cross - 1L DO BEGIN                                             $
  str_element,Sn_nif_jt,c_tags[j],all_data.(j).(ind[0]),/ADD_REPLACE      & $
  str_element,St_nif_jt,c_tags[j],all_data.(j).(ind[1]),/ADD_REPLACE

;;--------------------------------------------------------------
;; Define -(E . j) [µW m^(-3), E downsampled to j]
;;    [in NIF and NCB]
;;--------------------------------------------------------------
test           = (jes_tags EQ 'neg_e_dot_j_sm')
ind            = WHERE(test,in)
FOR j=0L, n_cross - 1L DO BEGIN                                             $
  str_element,Edotj_nif_v,c_tags[j],all_data.(j).(ind[0]),/ADD_REPLACE

;;--------------------------------------------------------------
;; Define *eta* |j|^2 [µW m^(-3)]
;;    [*eta* in GSE and NIF]
;;--------------------------------------------------------------
test           = (jes_tags EQ 'eta_jsq_gse') OR (jes_tags EQ 'eta_jsq_nif')
ind            = WHERE(test,in)
FOR j=0L, n_cross - 1L DO BEGIN                                             $
  str_element,all_etagse_j2,c_tags[j],all_data.(j).(ind[0]),/ADD_REPLACE  & $
  str_element,all_etanif_j2,c_tags[j],all_data.(j).(ind[1]),/ADD_REPLACE
;;----------------------------------------------------------------------------------------
;; => Calculate (j . S) by component [in NCB]
;;----------------------------------------------------------------------------------------
ufac           = 1d-6*1d-6*1d6   ;; µA -> A, µW -> W, 1x -> 10^(-6) x
xstruc         = jvec_v_sm
ystruc         = Svec_nif_jt
FOR j=0L, n_cross - 1L DO BEGIN                                             $
  xdat = xstruc.(j)*ufac[0]                                               & $
  ydat = ystruc.(j)                                                       & $
  rotm = all_rotnif.(j)                                                   & $
  ndat = REFORM(rotm ## ydat)                                             & $
  jySy = xdat[*,1]*ndat[*,1]                                              & $
  jzSz = xdat[*,2]*ndat[*,2]                                              & $
  jdS  = jySy + jzSz                                                      & $
  str_element,jdotS_nif_ncb,c_tags[j],[[jySy],[jzSz],[jdS]],/ADD_REPLACE

;;----------------------------------------------------------------------------------------
;; => Save correlation plots
;;----------------------------------------------------------------------------------------
Delta_str      = STRUPCASE(get_greek_letter('delta'))
mu__str        = get_greek_letter('mu')
muo_str        = mu__str[0]+'!Do!N'
eta_str        = get_greek_letter('eta')
omega_str      = get_greek_letter('omega')

yttle          = eta_str[0]+'|j|!U2!N [GSE Dissipation, '+mu__str[0]+'W m!U-3!N'+']'
xttle          = '|S| [FFT Power, '+mu__str[0]+'W m!U-2!N'+']'
pttle          = 'Dissipation [IAW GSE] Rate vs. Integrated FFT Poynting Flux'
pstr           = {TITLE:pttle,XTITLE:xttle,YTITLE:yttle,YLOG:1,XLOG:1,NODATA:1,$
                  YMINOR:9L,XMINOR:9L}
;;  Initialize plot
n_sum          = 1L
WSET,1
WSHOW,1
  PLOT,Spow_nif_jt.(0L),all_etagse_j2.(0L)[*,0],_EXTRA=pstr
  ;;  Overplot results and legends
  FOR j=0L, n_cross - 1L DO BEGIN                                                            $
    OPLOT,Spow_nif_jt.(j),all_etagse_j2.(j)[*,0],PSYM=7,COLOR=xyout_cols[j],NSUM=n_sum[0]  & $
    XYOUTS,xposi_xyout[j],yposi_xyout[j],all_xyout[j],COLOR=xyout_cols[j],/NORMAL


;;  Plot with [N]-summed points to reduce clutter
n_sum          = 3L
WSET,1
WSHOW,1
  PLOT,Spow_nif_jt.(0L),all_etagse_j2.(0L)[*,0],_EXTRA=pstr
  ;;  Overplot results and legends
  FOR j=0L, n_cross - 1L DO BEGIN                                                            $
    OPLOT,Spow_nif_jt.(j),all_etagse_j2.(j)[*,0],PSYM=7,COLOR=xyout_cols[j],NSUM=n_sum[0]  & $
    XYOUTS,xposi_xyout[j],yposi_xyout[j],all_xyout[j],COLOR=xyout_cols[j],/NORMAL



yttle          = '|(n . S) n| ['+mu__str[0]+'W m!U-2!N'+']'
xttle          = '|(E . j)| [Dissipation, '+mu__str[0]+'W m!U-3!N'+']'
pttle          = 'EM Power Out vs. Rate of Mechanical Work'
xra            = [1d-6,1d0]
yra            = [1d-5,1d2]
pstr           = {TITLE:pttle,XTITLE:xttle,YTITLE:yttle,YLOG:1,XLOG:1,NODATA:1,$
                  XRANGE:xra,YRANGE:yra,YSTYLE:1,XSTYLE:1}
xstruc         = Edotj_nif_v
ystruc         = Sn_nif_jt
n_sum          = 1L
WSET,1
WSHOW,1
  PLOT,ABS(xstruc.(0L)),SQRT(TOTAL(ystruc.(0L)^2,2L,/NAN)),_EXTRA=pstr
  ;;  Overplot results and legends
  FOR j=0L, n_cross - 1L DO BEGIN                                                            $
    xdat = ABS(xstruc.(j))                                                                 & $
    ydat = SQRT(TOTAL(ystruc.(j)^2,2L,/NAN))                                               & $
    OPLOT,xdat,ydat,PSYM=7,COLOR=xyout_cols[j],NSUM=n_sum[0]                               & $
    XYOUTS,xposi_xyout[j],yposi_xyout[j],all_xyout[j],COLOR=xyout_cols[j],/NORMAL



yttle          = '|n x (S x n)| ['+mu__str[0]+'W m!U-2!N'+']'
xttle          = '|(E . j)| [Dissipation, '+mu__str[0]+'W m!U-3!N'+']'
pttle          = 'EM Power Out vs. Rate of Mechanical Work'
xra            = [1d-6,1d0]
yra            = [1d-5,1d2]
pstr           = {TITLE:pttle,XTITLE:xttle,YTITLE:yttle,YLOG:1,XLOG:1,NODATA:1,$
                  XRANGE:xra,YRANGE:yra,YSTYLE:1,XSTYLE:1}
xstruc         = Edotj_nif_v
ystruc         = St_nif_jt
n_sum          = 1L
WSET,2
WSHOW,2
  PLOT,ABS(xstruc.(0L)),SQRT(TOTAL(ystruc.(0L)^2,2L,/NAN)),_EXTRA=pstr
  ;;  Overplot results and legends
  FOR j=0L, n_cross - 1L DO BEGIN                                                            $
    xdat = ABS(xstruc.(j))                                                                 & $
    ydat = SQRT(TOTAL(ystruc.(j)^2,2L,/NAN))                                               & $
    OPLOT,xdat,ydat,PSYM=7,COLOR=xyout_cols[j],NSUM=n_sum[0]                               & $
    XYOUTS,xposi_xyout[j],yposi_xyout[j],all_xyout[j],COLOR=xyout_cols[j],/NORMAL




yttle          = eta_str[0]+'|j|!U2!N [Dissipation, '+mu__str[0]+'W m!U-3!N'+']'
xttle          = '|(E . j)|/|(n . S) n| [Ratio of Work to EM Power]'
pttle          = 'Dissipation Rate vs. (Rate of Mechanical Work)/(EM Power Out)'
xra            = [1d-6,1d2]
yra            = [1d-11,1d-2]
pstr           = {TITLE:pttle,XTITLE:xttle,YTITLE:yttle,YLOG:1,XLOG:1,NODATA:1,$
                  XRANGE:xra,YRANGE:yra,YSTYLE:1,XSTYLE:1,YMINOR:9L,XMINOR:9L}
xstruc0        = Edotj_nif_v
xstruc1        = Sn_nif_jt
ystruc         = all_etagse_j2
n_sum          = 1L
WSET,1
WSHOW,1
  PLOT,ABS(xstruc0.(0L))/SQRT(TOTAL(xstruc1.(0L)^2,2L,/NAN)),ystruc.(0L)[*,0],_EXTRA=pstr
  ;;  Overplot results and legends
  FOR j=0L, n_cross - 1L DO BEGIN                                                            $
    xdat = ABS(xstruc0.(j))/SQRT(TOTAL(xstruc1.(j)^2,2L,/NAN))                             & $
    ydat = ystruc.(j)[*,0]                                                                 & $
    OPLOT,xdat,ydat,PSYM=7,COLOR=xyout_cols[j],NSUM=n_sum[0]                               & $
    XYOUTS,xposi_xyout[j],yposi_xyout[j],all_xyout[j],COLOR=xyout_cols[j],/NORMAL



yttle          = eta_str[0]+'|j|!U2!N [Dissipation, '+mu__str[0]+'W m!U-3!N'+']'
xttle          = '|(E . j)|/|n x (S x n)| [Ratio of Work to EM Power]'
pttle          = 'Dissipation Rate vs. (Rate of Mechanical Work)/(EM Power Out)'
xra            = [1d-6,1d2]
yra            = [1d-11,1d-2]
pstr           = {TITLE:pttle,XTITLE:xttle,YTITLE:yttle,YLOG:1,XLOG:1,NODATA:1,$
                  XRANGE:xra,YRANGE:yra,YSTYLE:1,XSTYLE:1,YMINOR:9L,XMINOR:9L}
xstruc0        = Edotj_nif_v
xstruc1        = St_nif_jt
ystruc         = all_etagse_j2
n_sum          = 1L
WSET,2
WSHOW,2
  PLOT,ABS(xstruc0.(0L))/SQRT(TOTAL(xstruc1.(0L)^2,2L,/NAN)),ystruc.(0L)[*,0],_EXTRA=pstr
  ;;  Overplot results and legends
  FOR j=0L, n_cross - 1L DO BEGIN                                                            $
    xdat = ABS(xstruc0.(j))/SQRT(TOTAL(xstruc1.(j)^2,2L,/NAN))                             & $
    ydat = ystruc.(j)[*,0]                                                                 & $
    OPLOT,xdat,ydat,PSYM=7,COLOR=xyout_cols[j],NSUM=n_sum[0]                               & $
    XYOUTS,xposi_xyout[j],yposi_xyout[j],all_xyout[j],COLOR=xyout_cols[j],/NORMAL



xttle          = '|j| ['+mu__str[0]+'A m!U-2!N'+']'
yttle          = '|(n . S) n| ['+mu__str[0]+'W m!U-2!N'+']'
pttle          = 'EM Power Out vs. Current Density'
xra            = [1d-2,1d2]
yra            = [1d-4,1d2]
pstr           = {TITLE:pttle,XTITLE:xttle,YTITLE:yttle,YLOG:1,XLOG:1,NODATA:1,$
                  XRANGE:xra,YRANGE:yra,YSTYLE:1,XSTYLE:1}
xstruc         = jmag_v_sm
ystruc         = Sn_nif_jt
n_sum          = 1L
WSET,1
WSHOW,1
  PLOT,ABS(xstruc.(0L)),SQRT(TOTAL(ystruc.(0L)^2,2L,/NAN)),_EXTRA=pstr
  ;;  Overplot results and legends
  FOR j=0L, n_cross - 1L DO BEGIN                                                            $
    xdat = ABS(xstruc.(j))                                                                 & $
    ydat = SQRT(TOTAL(ystruc.(j)^2,2L,/NAN))                                               & $
    OPLOT,xdat,ydat,PSYM=7,COLOR=xyout_cols[j],NSUM=n_sum[0]                               & $
    XYOUTS,xposi_xyout[j],yposi_xyout[j],all_xyout[j],COLOR=xyout_cols[j],/NORMAL



xttle          = '|j| ['+mu__str[0]+'A m!U-2!N'+']'
yttle          = '|n x (S x n)| ['+mu__str[0]+'W m!U-2!N'+']'
pttle          = 'EM Power Out vs. Current Density'
xra            = [1d-2,1d2]
yra            = [1d-4,1d2]
pstr           = {TITLE:pttle,XTITLE:xttle,YTITLE:yttle,YLOG:1,XLOG:1,NODATA:1,$
                  XRANGE:xra,YRANGE:yra,YSTYLE:1,XSTYLE:1}
xstruc         = jmag_v_sm
ystruc         = St_nif_jt
n_sum          = 1L
WSET,2
WSHOW,2
  PLOT,ABS(xstruc.(0L)),SQRT(TOTAL(ystruc.(0L)^2,2L,/NAN)),_EXTRA=pstr
  ;;  Overplot results and legends
  FOR j=0L, n_cross - 1L DO BEGIN                                                            $
    xdat = ABS(xstruc.(j))                                                                 & $
    ydat = SQRT(TOTAL(ystruc.(j)^2,2L,/NAN))                                               & $
    OPLOT,xdat,ydat,PSYM=7,COLOR=xyout_cols[j],NSUM=n_sum[0]                               & $
    XYOUTS,xposi_xyout[j],yposi_xyout[j],all_xyout[j],COLOR=xyout_cols[j],/NORMAL


yttle          = '|(n . S) n|/|E| ['+mu__str[0]+'A m!U-2!N'+']'
xttle          = '|(E . j)| [Dissipation, '+mu__str[0]+'W m!U-3!N'+']'
pttle          = 'EM Power Out vs. Rate of Mechanical Work'
xra            = [1d-6,1d0]
yra            = [1d-3,1d3]
pstr           = {TITLE:pttle,XTITLE:xttle,YTITLE:yttle,YLOG:1,XLOG:1,NODATA:1,$
                  XRANGE:xra,YRANGE:yra,YSTYLE:1,XSTYLE:1}
xstruc         = Edotj_nif_v
ystruc0        = Sn_nif_jt
ystruc1        = efi_nifgse_jt
sefac          = 1d-6/1d-3*1d6   ;;  µW -> W, mV^(-1) -> V^(-1), A -> µA
n_sum          = 3L
WSET,1
WSHOW,1
  PLOT,ABS(xstruc.(0L)),ABS(ystruc0.(0L))/SQRT(TOTAL(ystruc1.(0L)^2,2L,/NAN))*sefac[0],_EXTRA=pstr
  ;;  Overplot results and legends
  FOR j=0L, n_cross - 1L DO BEGIN                                                            $
    xdat = ABS(xstruc.(j))                                                                 & $
    ydat = ABS(ystruc0.(j))/SQRT(TOTAL(ystruc1.(j)^2,2L,/NAN))*sefac[0]                    & $
    OPLOT,xdat,ydat,PSYM=7,COLOR=xyout_cols[j],NSUM=n_sum[0]                               & $
    XYOUTS,xposi_xyout[j],yposi_xyout[j],all_xyout[j],COLOR=xyout_cols[j],/NORMAL



yttle          = '|n x (S x n)|/|E| ['+mu__str[0]+'A m!U-2!N'+']'
xttle          = '|(E . j)| [Dissipation, '+mu__str[0]+'W m!U-3!N'+']'
pttle          = 'EM Power Out vs. Rate of Mechanical Work'
xra            = [1d-6,1d0]
yra            = [1d-3,1d3]
pstr           = {TITLE:pttle,XTITLE:xttle,YTITLE:yttle,YLOG:1,XLOG:1,NODATA:1,$
                  XRANGE:xra,YRANGE:yra,YSTYLE:1,XSTYLE:1}
xstruc         = Edotj_nif_v
ystruc0        = St_nif_jt
ystruc1        = efi_nifgse_jt
sefac          = 1d-6/1d-3*1d6   ;;  µW -> W, mV^(-1) -> V^(-1), A -> µA
n_sum          = 3L
WSET,2
WSHOW,2
  PLOT,ABS(xstruc.(0L)),ABS(ystruc0.(0L))/SQRT(TOTAL(ystruc1.(0L)^2,2L,/NAN))*sefac[0],_EXTRA=pstr
  ;;  Overplot results and legends
  FOR j=0L, n_cross - 1L DO BEGIN                                                            $
    xdat = ABS(xstruc.(j))                                                                 & $
    ydat = ABS(ystruc0.(j))/SQRT(TOTAL(ystruc1.(j)^2,2L,/NAN))*sefac[0]                    & $
    OPLOT,xdat,ydat,PSYM=7,COLOR=xyout_cols[j],NSUM=n_sum[0]                               & $
    XYOUTS,xposi_xyout[j],yposi_xyout[j],all_xyout[j],COLOR=xyout_cols[j],/NORMAL




xttle          = '|S|/|E| [FFT Power, '+mu__str[0]+'A m!U-2!N'+']'
yttle          = eta_str[0]+'|j|!U2!N'+'/|E| [NIF Dissipation, '+mu__str[0]+'A m!U-3!N'+']'
pttle          = 'Dissipation [IAW GSE] Rate vs. Integrated FFT Poynting Flux'
xra            = [1d-6,1d-1]
yra            = [1d-9,1d1]
pstr           = {TITLE:pttle,XTITLE:xttle,YTITLE:yttle,YLOG:1,XLOG:1,NODATA:1,$
                  XRANGE:xra,YRANGE:yra,YSTYLE:1,XSTYLE:1}
xstruc         = Spow_nif_jt
ystruc         = all_etanif_j2
zstruc         = efi_nifgse_jt
sxfac          = 1d-6/1d-3*1d0   ;;  µW -> W, mV^(-1) -> V^(-1), A ->  A
syfac          = 1d-6/1d-3*1d6   ;;  µW -> W, mV^(-1) -> V^(-1), A -> µA
n_sum          = 1L
WSET,3
WSHOW,3
  xdat = ABS(xstruc.(0L))/SQRT(TOTAL(zstruc.(0L)^2,2L,/NAN))*sxfac[0]
  ydat = ABS(ystruc.(0L))/SQRT(TOTAL(zstruc.(0L)^2,2L,/NAN))*syfac[0]
  PLOT,xdat,ydat,_EXTRA=pstr
  ;;  Overplot results and legends
  FOR j=0L, n_cross - 1L DO BEGIN                                                            $
    xdat = ABS(xstruc.(j))/SQRT(TOTAL(zstruc.(j)^2,2L,/NAN))*sxfac[0]                      & $
    ydat = ABS(ystruc.(j))/SQRT(TOTAL(zstruc.(j)^2,2L,/NAN))*syfac[0]                      & $
    OPLOT,xdat,ydat,PSYM=7,COLOR=xyout_cols[j],NSUM=n_sum[0]                               & $
    XYOUTS,xposi_xyout[j],yposi_xyout[j],all_xyout[j],COLOR=xyout_cols[j],/NORMAL
    ;;  Overplot y = x line
    OPLOT,xra,xra,LINESTYLE=2,THICK=2



xttle          = '|S| [FFT Power, '+mu__str[0]+'W m!U-2!N'+']'
yttle          = eta_str[0]+'|j|!U2!N'+'/|E| [NIF Dissipation, '+mu__str[0]+'A m!U-3!N'+']'
pttle          = 'Dissipation [IAW GSE] Rate vs. Integrated FFT Poynting Flux'
xra            = [1d-4,1d2]
yra            = [1d-9,1d1]
yxline0        = [1d-2,1d-9]
yxline1        = 1d2 + [0d0,(yxline0[1]-yxline0[0])]
yxline         = [[yxline0[0],yxline1[0]],[yxline0[1],yxline1[1]]]
pstr           = {TITLE:pttle,XTITLE:xttle,YTITLE:yttle,YLOG:1,XLOG:1,NODATA:1,$
                  XRANGE:xra,YRANGE:yra,YSTYLE:1,XSTYLE:1}
xstruc         = Spow_nif_jt
ystruc         = all_etanif_j2
zstruc         = efi_nifgse_jt
sxfac          = 1d0             ;;  µW -> µW
syfac          = 1d-6/1d-3*1d6   ;;  µW -> W, mV^(-1) -> V^(-1), A -> µA
n_sum          = 3L
WSET,3
WSHOW,3
  xdat = ABS(xstruc.(0L))*sxfac[0]
  ydat = ABS(ystruc.(0L))/SQRT(TOTAL(zstruc.(0L)^2,2L,/NAN))*syfac[0]
  PLOT,xdat,ydat,_EXTRA=pstr
  ;;  Overplot results and legends
  FOR j=0L, n_cross - 1L DO BEGIN                                                            $
    xdat = ABS(xstruc.(j))*sxfac[0]                                                        & $
    ydat = ABS(ystruc.(j))/SQRT(TOTAL(zstruc.(j)^2,2L,/NAN))*syfac[0]                      & $
    OPLOT,xdat,ydat,PSYM=7,COLOR=xyout_cols[j],NSUM=n_sum[0]                               & $
    XYOUTS,xposi_xyout[j],yposi_xyout[j],all_xyout[j],COLOR=xyout_cols[j],/NORMAL
    ;;  Overplot y = x + b line
    OPLOT,yxline[*,0],yxline[*,1],LINESTYLE=2,THICK=2









WINDOW,3,RETAIN=2,XSIZE=1700,YSIZE=1100,TITLE='Energy Dissipation 3'
xttle          = '|(n . S) n| ['+mu__str[0]+'W m!U-2!N'+']'
yttle          = '|n x (S x n)| ['+mu__str[0]+'W m!U-2!N'+']'
pttle          = '|St| vs. |Sn|'
xra            = [1d-4,1d2]
yra            = [1d-4,1d2]
pstr           = {TITLE:pttle,XTITLE:xttle,YTITLE:yttle,YLOG:1,XLOG:1,NODATA:1,$
                  XRANGE:xra,YRANGE:yra,YSTYLE:1,XSTYLE:1}
xstruc         = Sn_nif_jt
ystruc         = St_nif_jt
n_sum          = 3L
WSET,3
WSHOW,3
  PLOT,ABS(xstruc.(0L)),SQRT(TOTAL(ystruc.(0L)^2,2L,/NAN)),_EXTRA=pstr
  ;;  Overplot results and legends
  FOR j=0L, n_cross - 1L DO BEGIN                                                            $
    xdat = ABS(xstruc.(j))                                                                 & $
    ydat = SQRT(TOTAL(ystruc.(j)^2,2L,/NAN))                                               & $
    OPLOT,xdat,ydat,PSYM=7,COLOR=xyout_cols[j],NSUM=n_sum[0]                               & $
    XYOUTS,xposi_xyout[j],yposi_xyout[j],all_xyout[j],COLOR=xyout_cols[j],/NORMAL
    ;;  Overplot y = x line
    OPLOT,xra,yra,LINESTYLE=2,THICK=2


xttle          = '|(j . S)!Dy!N'+'| ['+mu__str[0]+'A W m!U-4!N'+']'
yttle          = '|(j . S)!Dz!N'+'| ['+mu__str[0]+'A W m!U-4!N'+']'
pttle          = '|(j . S)z| vs. |(j . S)y|'
xra            = [1d-12,1d-4]
yra            = xra
pstr           = {TITLE:pttle,XTITLE:xttle,YTITLE:yttle,YLOG:1,XLOG:1,NODATA:1,$
                  XRANGE:xra,YRANGE:yra,YSTYLE:1,XSTYLE:1}
xstruc         = jdotS_nif_ncb
ystruc         = jdotS_nif_ncb
n_sum          = 1L
WSET,3
WSHOW,3
  PLOT,ABS(xstruc.(0L)[*,0]),ABS(ystruc.(0L)[*,1]),_EXTRA=pstr
  ;;  Overplot results and legends
  FOR j=0L, n_cross - 1L DO BEGIN                                                            $
    xdat = ABS(xstruc.(j)[*,0])                                                            & $
    ydat = ABS(ystruc.(j)[*,1])                                                            & $
    OPLOT,xdat,ydat,PSYM=7,COLOR=xyout_cols[j],NSUM=n_sum[0]                               & $
    XYOUTS,xposi_xyout[j],yposi_xyout[j],all_xyout[j],COLOR=xyout_cols[j],/NORMAL
    ;;  Overplot y = x line
    OPLOT,xra,yra,LINESTYLE=2,THICK=2



xttle          = '|j!Dy!N'+'| ['+mu__str[0]+'A m!U-2!N'+']'
yttle          = '|j!Dz!N'+'| ['+mu__str[0]+'A m!U-2!N'+']'
pttle          = '|jz| vs. |jy|'
xra            = [1d-4,2d1]
yra            = [1d-4,1d2]
pstr           = {TITLE:pttle,XTITLE:xttle,YTITLE:yttle,YLOG:1,XLOG:1,NODATA:1,$
                  XRANGE:xra,YRANGE:yra,YSTYLE:1,XSTYLE:1}
xstruc         = jvec_v_sm
ystruc         = jvec_v_sm
n_sum          = 3L
WSET,3
WSHOW,3
  PLOT,ABS(xstruc.(0L)[*,1]),ABS(ystruc.(0L)[*,2]),_EXTRA=pstr
  ;;  Overplot results and legends
  FOR j=0L, n_cross - 1L DO BEGIN                                                            $
    xdat = ABS(xstruc.(j)[*,1])                                                            & $
    ydat = ABS(ystruc.(j)[*,2])                                                            & $
    OPLOT,xdat,ydat,PSYM=7,COLOR=xyout_cols[j],NSUM=n_sum[0]                               & $
    XYOUTS,xposi_xyout[j],yposi_xyout[j],all_xyout[j],COLOR=xyout_cols[j],/NORMAL
    ;;  Overplot y = x line
    OPLOT,xra,xra,LINESTYLE=2,THICK=2

























































































n_sum          = 1L
WSET,1
  PLOT,SPF_jt,all_eta_jsq[*,0],_EXTRA=pstr
    OPLOT,SPF_jt[ind_0],all_eta_jsq[ind_0,0],PSYM=7,COLOR= 50,NSUM=n_sum[0]
    OPLOT,SPF_jt[ind_1],all_eta_jsq[ind_1,0],PSYM=7,COLOR=150,NSUM=n_sum[0]
    ;; overplot fit lines
    OPLOT,   x_fit_bs,      y_fit_bs,LINESTYLE=2,COLOR=250,THICK=2.0
    OPLOT,x_linfit_bs, y_linfit_bs_v,LINESTYLE=2,COLOR=200,THICK=2.0
    OPLOT,x_linfit_bs,  y_polyfit_bs,LINESTYLE=2,COLOR=100,THICK=2.0
    ;; output fit legend
    XYOUTS,0.15,0.80,'Ln| Y | = Ln| A + B X | [BS Points (LADFIT Soln.)]',/NORMAL,COLOR=250
    XYOUTS,0.15,0.75,'Ln| Y | = Ln| A + B X | [BS Points (LINFIT Soln.)]',/NORMAL,COLOR=200
    poly_str = 'Y =  A + B X + C X!U2!N + D X!U3!N + E X!U4!N'+'!C'
    XYOUTS,0.15,0.70,poly_str[0]+'  [BS Points (COMFIT Soln.)]',/NORMAL,COLOR=100
    ;; output legend
    XYOUTS,0.15,0.90,'X = '+tdate0[0]+' [Bow Shock (BS)]',/NORMAL,COLOR= 50
    XYOUTS,0.15,0.85,'X = '+tdate1[0]+' [Bow Shock (BS)]',/NORMAL,COLOR=150



SET_PLOT,'PS'
pfontold       = !P.FONT
!P.FONT        = -1
mu__strps      = get_greek_letter('mu')
eta_strps      = get_greek_letter('eta')
!P.FONT        = pfontold[0]
SET_PLOT,'X'

yttleps        = eta_strps[0]+' |j|!U2!N [Dissipation, '+mu__strps[0]+'W m!U-3!N'+']'
xttleps        = '|S| [FFT Power, '+mu__strps[0]+'W m!U-2!N'+']'
pttle          = 'Dissipation Rate vs. Integrated FFT Poynting Flux '+tdate_01[0]
pstrps         = {TITLE:pttle,XTITLE:xttleps,YTITLE:yttleps,YLOG:1,XLOG:1,NODATA:1,YTICKS:14L,YMINOR:9L,XMINOR:9L}
fname          = 'Dissipation-Rate_vs_Integrated-FFT-Poynting-Flux_'+tdate_01f[0]+'_fit-lines'

popen,fname[0],/LAND
  !P.FONT        = -1
  PLOT,SPF_jt,all_eta_jsq[*,0],_EXTRA=pstr
    OPLOT,SPF_jt[ind_0],all_eta_jsq[ind_0,0],PSYM=7,COLOR= 50
    OPLOT,SPF_jt[ind_1],all_eta_jsq[ind_1,0],PSYM=7,COLOR=150
    ;; overplot fit lines
    OPLOT,   x_fit_bs,      y_fit_bs,LINESTYLE=2,COLOR=250,THICK=2.0
    OPLOT,x_linfit_bs, y_linfit_bs_v,LINESTYLE=2,COLOR=200,THICK=2.0
    OPLOT,x_linfit_bs,  y_polyfit_bs,LINESTYLE=2,COLOR=100,THICK=2.0
    ;; output fit legend
    XYOUTS,0.15,0.80,'Ln| Y | = Ln| A + B X | [BS Points (LADFIT Soln.)]',/NORMAL,COLOR=250
    XYOUTS,0.15,0.75,'Ln| Y | = Ln| A + B X | [BS Points (LINFIT Soln.)]',/NORMAL,COLOR=200
    poly_str = 'Y =  A + B X + C X!U2!N + D X!U3!N + E X!U4!N'+'!C'
    XYOUTS,0.15,0.70,poly_str[0]+'  [BS Points (COMFIT Soln.)]',/NORMAL,COLOR=100
    ;; output legend
    XYOUTS,0.15,0.90,'X = '+tdate0[0]+' [Bow Shock (BS)]',/NORMAL,COLOR= 50
    XYOUTS,0.15,0.85,'X = '+tdate1[0]+' [Bow Shock (BS)]',/NORMAL,COLOR=150
  !P.FONT        = 0
pclose





yttle          = eta_str[0]+'|j|!U2!N [Dissipation, '+mu__str[0]+'W m!U-3!N'+']'
xttle          = '|S| [FFT Power, '+mu__str[0]+'W m!U-2!N'+']'
pttle          = 'Dissipation Rate vs. Integrated FFT Poynting Flux '+tdate_01[0]
pstr           = {TITLE:pttle,XTITLE:xttle,YTITLE:yttle,YLOG:1,XLOG:1,NODATA:1,YTICKS:14L,YMINOR:9L,XMINOR:9L}

n_sum          = 3L
WSET,1
  PLOT,SPF_jt,all_eta_jsq[*,0],_EXTRA=pstr
    OPLOT,SPF_jt[ind_0],all_eta_jsq[ind_0,0],PSYM=7,COLOR= 50,NSUM=n_sum[0]
    OPLOT,SPF_jt[ind_1],all_eta_jsq[ind_1,0],PSYM=7,COLOR=150,NSUM=n_sum[0]
    OPLOT,SPF_jt[ind_2],all_eta_jsq[ind_2,0],PSYM=7,COLOR=250,NSUM=n_sum[0]
    ;; overplot fit lines
    OPLOT,   x_fit_bs,      y_fit_bs,LINESTYLE=2,COLOR=250,THICK=2.0
    OPLOT,x_linfit_bs, y_linfit_bs_v,LINESTYLE=2,COLOR=200,THICK=2.0
    ;; output legend
    XYOUTS,0.12,0.90,'X = '+tdate0[0]+' [Bow Shock (BS)]',/NORMAL,COLOR= 50
    XYOUTS,0.12,0.85,'X = '+tdate1[0]+' [Bow Shock (BS)]',/NORMAL,COLOR=150
    XYOUTS,0.12,0.80,'X = '+tdate2[0]+' [Foreshock Bubble (FB)]',/NORMAL,COLOR=250
    ;; output fit legend
    XYOUTS,0.12,0.75,'Ln| Y | = Ln| A + B X | [BS Points (LADFIT Soln.)]',/NORMAL,COLOR=250
    XYOUTS,0.12,0.70,'Ln| Y | = Ln| A + B X | [BS Points (LINFIT Soln.)]',/NORMAL,COLOR=200





yttle          = '(n . S) ['+mu__str[0]+'W m!U-2!N'+']'
xttle          = '-(E . j) [Dissipation, '+mu__str[0]+'W m!U-3!N'+']'
pttle          = 'EM Power Out vs. Rate of Mechanical Work '+tdate_01[0]
pstr           = {TITLE:pttle,XTITLE:xttle,YTITLE:yttle,YLOG:0,XLOG:0,NODATA:1}
WSET,1
PLOT,E_dot_j_sm,n_dot_S_jt,_EXTRA=pstr
  OPLOT,E_dot_j_sm,n_dot_S_jt,PSYM=2,COLOR=50
  OPLOT,ABS(E_dot_j_sm),ABS(n_dot_S_jt),PSYM=7,COLOR=250



yttle          = '|(n . S)| ['+mu__str[0]+'W m!U-2!N'+']'
xttle          = '|(E . j)| [Dissipation, '+mu__str[0]+'W m!U-3!N'+']'
pttle          = 'EM Power Out vs. Rate of Mechanical Work '+tdate_01[0]
pstr           = {TITLE:pttle,XTITLE:xttle,YTITLE:yttle,YLOG:1,XLOG:1,NODATA:1,YMINOR:9L,XMINOR:9L}
xdata          = ABS(E_dot_j_sm)
ydata          = ABS(n_dot_S_jt)
test0          = FINITE(xdata) AND FINITE(ydata)
test1          = (xdata GT 0) AND (ydata GT 0)
good           = WHERE(test0 AND test1,gd)
xdata          = xdata[good]
ydata          = ydata[good]

n_sum          = 10L
WSET,1
PLOT,xdata,ydata,_EXTRA=pstr
    OPLOT,xdata[ind_0],ydata[ind_0],PSYM=7,COLOR= 50,NSUM=n_sum[0]
    OPLOT,xdata[ind_1],ydata[ind_1],PSYM=7,COLOR=150,NSUM=n_sum[0]
    ;; output legend
    XYOUTS,0.15,0.90,'X = '+tdate0[0]+' [Bow Shock (BS)]',/NORMAL,COLOR= 50
    XYOUTS,0.15,0.85,'X = '+tdate1[0]+' [Bow Shock (BS)]',/NORMAL,COLOR=150



yttle          = eta_str[0]+'|j|!U2!N [Dissipation, '+mu__str[0]+'W m!U-3!N'+']'
xttle          = '|(E . j)/(n . S)| [Ratio of Work to EM Power]'
pttle          = 'Dissipation Rate vs. (Rate of Mechanical Work)/(EM Power Out) '+tdate_01[0]
pstr           = {TITLE:pttle,XTITLE:xttle,YTITLE:yttle,YLOG:1,XLOG:1,NODATA:1,YMINOR:9L,XMINOR:9L}
xdata          = ABS(E_dot_j_sm/n_dot_S_jt)
ydata          = REFORM(all_eta_jsq[*,0])
test0          = FINITE(xdata) AND FINITE(ydata)
test1          = (xdata GT 0) AND (ydata GT 0)
good           = WHERE(test0 AND test1,gd)
xdata          = xdata[good]
ydata          = ydata[good]

WSET,1
PLOT,xdata,ydata,_EXTRA=pstr
    OPLOT,xdata[ind_0],ydata[ind_0],PSYM=7,COLOR= 50
    OPLOT,xdata[ind_1],ydata[ind_1],PSYM=7,COLOR=150
    ;; output legend
    XYOUTS,0.15,0.90,'X = '+tdate0[0]+' [Bow Shock (BS)]',/NORMAL,COLOR= 50
    XYOUTS,0.15,0.85,'X = '+tdate1[0]+' [Bow Shock (BS)]',/NORMAL,COLOR=150


yttle          = '|S| [FFT Power, '+mu__str[0]+'W m!U-2!N'+']'
xttle          = '|(E . j)/(n . S)| [Ratio of Work to EM Power]'
pttle          = 'Integrated FFT Poynting Flux vs. (Rate of Mechanical Work)/(EM Power Out) '+tdate_01[0]
pstr           = {TITLE:pttle,XTITLE:xttle,YTITLE:yttle,YLOG:1,XLOG:1,NODATA:1,YMINOR:9L,XMINOR:9L}
xdata          = ABS(E_dot_j_sm/n_dot_S_jt)
ydata          = REFORM(SPF_jt)
test0          = FINITE(xdata) AND FINITE(ydata)
test1          = (xdata GT 0) AND (ydata GT 0)
good           = WHERE(test0 AND test1,gd)
xdata          = xdata[good]
ydata          = ydata[good]

WSET,2
PLOT,xdata,ydata,_EXTRA=pstr
    OPLOT,xdata[ind_0],ydata[ind_0],PSYM=7,COLOR= 50
    OPLOT,xdata[ind_1],ydata[ind_1],PSYM=7,COLOR=150
    ;; output legend
    XYOUTS,0.15,0.90,'X = '+tdate0[0]+' [Bow Shock (BS)]',/NORMAL,COLOR= 50
    XYOUTS,0.15,0.85,'X = '+tdate1[0]+' [Bow Shock (BS)]',/NORMAL,COLOR=150






;;----------------------------------------------------------------------------------------
;; => Old
;;----------------------------------------------------------------------------------------
;;  Read in data
.compile read_thm_j_E_S_corr
data_0713_0    = read_thm_j_E_S_corr(FILE_NAME=file_0713[0])
data_0723_0    = read_thm_j_E_S_corr(FILE_NAME=file_0723[0])
data_0723_1    = read_thm_j_E_S_corr(FILE_NAME=file_0723[1])
data_0723_2    = read_thm_j_E_S_corr(FILE_NAME=file_0723[2])
data_0926_0    = read_thm_j_E_S_corr(FILE_NAME=file_0926[0])

;;  Define # of elements and corresponding indices for each crossing
n_0713_0       = N_ELEMENTS(data_0713_0.SCETS)
n_0723_0       = N_ELEMENTS(data_0723_0.SCETS)
n_0723_1       = N_ELEMENTS(data_0723_1.SCETS)
n_0723_2       = N_ELEMENTS(data_0723_2.SCETS)
n_0926_0       = N_ELEMENTS(data_0926_0.SCETS)
all_ns         = [n_0713_0,n_0723_0,n_0723_1,n_0723_2,n_0926_0]
PRINT,';; ', n_0713_0, n_0723_0, n_0723_1, n_0723_2, n_0926_0
;;         1648         816         816        1648        1648


n_cross        = N_ELEMENTS(all_ns)
n_pts          = LONG(TOTAL(all_ns))
PRINT,';; ', n_cross, n_pts
;;            5        6576






mdir           = FILE_EXPAND_PATH('IDL_stuff/themis_data_dir/themis_ascii/')
tdate0         = '2009-07-13'        ;;  Bow Shock        (BS) event
tdate1         = '2009-07-23'        ;;  Bow Shock        (BS) event
tdate2         = '2009-09-26'        ;;  Bow Shock        (BS) event
tdate3         = '2008-07-14'        ;;  Foreshock Bubble (FB) event
mform          = '(a30,2E15.5,2f15.5,4E15.5)'
tdate_01       = '['+tdate0[0]+', '+tdate1[0]+', '+tdate2[0]+']'
tdate_01f      = tdate0[0]+'_and_'+tdate1[0]+'_and_'+tdate2[0]

fname0         = 'Integrated-FFT-Poynting-Flux-Sm-NotSm_Dissipation-Rate_'+tdate0[0]+'.txt'
fname1         = 'Integrated-FFT-Poynting-Flux-Sm-NotSm_Dissipation-Rate_'+tdate1[0]+'.txt'
fname2         = 'Integrated-FFT-Poynting-Flux-Sm-NotSm_Dissipation-Rate_'+tdate2[0]+'.txt'
file0          = FILE_SEARCH(mdir,fname0[0])
file1          = FILE_SEARCH(mdir,fname1[0])
file2          = FILE_SEARCH(mdir,fname2[0])

nl0            = FILE_LINES(file0[0])
nl1            = FILE_LINES(file1[0])
nl2            = FILE_LINES(file2[0])
n              = nl0 + nl1 + nl2

scets          = STRARR(n)           ;;  e.g., 2009-09-26/15:53:02.695
SPF_jt         = DBLARR(n)           ;;  |S(w,k)|     [µW m^(-2), at |j| timestamps]
sm_SPF_jt      = DBLARR(n)           ;;  |S(w,k)|     [µW m^(-2), at |j| timestamps, smoothed]
n_dot_S_jt     = DBLARR(n)           ;;  (n . S)      [µW m^(-2), at |j| timestamps]
E_dot_j_sm     = DBLARR(n)           ;;  -(E . j)     [µW m^(-3), at |j| timestamps, j-smoothed]
all_eta_jsq    = DBLARR(n,4L)        ;;  *eta* |j|^2  [µW m^(-3), at |j| timestamps, j-smoothed]


;  PRINTF,gunit,FORMAT=mform,scets[i],SPF_vals_jt[i],sm_SPF_vals_jt[i],$
;               ndotS_sm_jt[i],E_dot_j_sm[i],REFORM(all_eta_j2[i,*])

aa             = ''
bb             = DBLARR(2)
cc             = DBLARR(2)
dd             = DBLARR(4)
;;---------------------------------------
;;  Open 1st file  [Bow Shock event]
;;---------------------------------------
OPENR,gunit,file0[0],/GET_LUN
FOR i=0L, nl0 - 1L DO BEGIN                      $
  READF,gunit,FORMAT=mform,aa,bb,cc,dd         & $
  scets[i]          = STRTRIM(aa[0],2)         & $
  SPF_jt[i]         = bb[0]                    & $
  sm_SPF_jt[i]      = bb[1]                    & $
  n_dot_S_jt[i]     = cc[0]                    & $
  E_dot_j_sm[i]     = cc[1]                    & $
  all_eta_jsq[i,0]  = dd[0]                    & $
  all_eta_jsq[i,1]  = dd[1]                    & $
  all_eta_jsq[i,2]  = dd[2]                    & $
  all_eta_jsq[i,3]  = dd[3]
;;  Close file
FREE_LUN,gunit
;;---------------------------------------
;;  Open 2nd file  [Bow Shock event]
;;---------------------------------------
OPENR,gunit,file1[0],/GET_LUN
FOR j=0L, nl1 - 1L DO BEGIN                $
  i                   = j[0] + nl0[0]    & $
  READF,gunit,FORMAT=mform,aa,bb,cc,dd         & $
  scets[i]          = STRTRIM(aa[0],2)         & $
  SPF_jt[i]         = bb[0]                    & $
  sm_SPF_jt[i]      = bb[1]                    & $
  n_dot_S_jt[i]     = cc[0]                    & $
  E_dot_j_sm[i]     = cc[1]                    & $
  all_eta_jsq[i,0]  = dd[0]                    & $
  all_eta_jsq[i,1]  = dd[1]                    & $
  all_eta_jsq[i,2]  = dd[2]                    & $
  all_eta_jsq[i,3]  = dd[3]
;;  Close file
FREE_LUN,gunit
;;---------------------------------------
;;  Open 3rd file  [Foreshock Bubble]
;;---------------------------------------
n01            = nl0 + nl1
OPENR,gunit,file2[0],/GET_LUN
FOR j=0L, nl2 - 1L DO BEGIN                $
  i                   = j[0] + n01[0]    & $
  READF,gunit,FORMAT=mform,aa,bb,cc,dd         & $
  scets[i]          = STRTRIM(aa[0],2)         & $
  SPF_jt[i]         = bb[0]                    & $
  sm_SPF_jt[i]      = bb[1]                    & $
  n_dot_S_jt[i]     = cc[0]                    & $
  E_dot_j_sm[i]     = cc[1]                    & $
  all_eta_jsq[i,0]  = dd[0]                    & $
  all_eta_jsq[i,1]  = dd[1]                    & $
  all_eta_jsq[i,2]  = dd[2]                    & $
  all_eta_jsq[i,3]  = dd[3]
;;  Close file
FREE_LUN,gunit

n01            = nl0 + nl1
ind_0          = LINDGEN(nl0)
ind_1          = LINDGEN(nl1) + nl0
ind_2          = LINDGEN(nl2) + n01
ind_01         = [ind_0,ind_1]
sp             = SORT(ind_01)  ;; just in case
ind_01         = ind_01[sp]
;;----------------------------------------------------------------------------------------
;; => Plot scatter plot
;;----------------------------------------------------------------------------------------
Delta_str      = STRUPCASE(get_greek_letter('delta'))
mu__str        = get_greek_letter('mu')
muo_str        = mu__str[0]+'!Do!N'
eta_str        = get_greek_letter('eta')
omega_str      = get_greek_letter('omega')

.compile scatter_plot_3d

x              = ALOG(SPF_jt[ind_01])
y              = ALOG(REFORM(all_eta_jsq[ind_01,0]))
z              = ALOG(ind_01)
;x              = SPF_jt[ind_01]
;y              = REFORM(all_eta_jsq[ind_01,0])
;z              = ind_01
;; normalize by maximum for each
max_xyz        = [MAX(ABS(x),/NAN),MAX(ABS(y),/NAN),MAX(ABS(z),/NAN)]
xxn            = x/max_xyz[0]
yyn            = y/max_xyz[1]
zzn            = z/max_xyz[2]

yttle          = 'ln| '+eta_str[0]+'|j|!U2!N | [Dissipation, '+mu__str[0]+'W m!U-3!N'+']'
xttle          = 'ln| |S| | [FFT Power, '+mu__str[0]+'W m!U-2!N'+']'
pttle          = 'Dissipation Rate vs. Integrated FFT Poynting Flux '+tdate_01[0]
pstr           = {TITLE:pttle,XTITLE:xttle,YTITLE:yttle,YMINOR:9L,XMINOR:9L}
scatter_plot_3d,x,y,z,LIMIT=pstr,YLOG=0,XLOG=0,/CONNECT
;scatter_plot_3d,x,y,z,LIMIT=pstr,YLOG=1,XLOG=1;,/CONNECT
;scatter_plot_3d,xxn,yyn,zzn,LIMIT=pstr,YLOG=0,XLOG=0;,/CONNECT

;;----------------------------------------------------------------------------------------
;; => Try fitting to data
;;
;;      Let w = dependent data points, z = independent data points, then the plot
;;  shows a result that is consistent with a power-law relationship between the input
;;  and the output given by:
;;
;;      w(z) = Wo + ∂W z^{a}
;;
;;  which can be rewritten as:
;;
;;      ß(ø) = ƒo + µ ø
;;
;;  where we have:
;;
;;        ß(ø)   <-->  Y  <-->  ln| [w(z) - Wo]/Wo |
;;        ƒo     <-->  A  <-->  ln| ∂W/Wo | = ln|∂W| - ln|Wo|
;;        µ      <-->  B  <-->  a
;;        ø      <-->  X  <-->  ln|z|
;;
;;----------------------------------------------------------------------------------------
;;  Y = A + B X
;;
;;    Y = Ln| *eta* |j|^2 |  <--> Ln| F(X) |
;;    X = Ln| S(w,k) |       <--> Ln| X |
;;
;;-----------------------------------------------
n_vals         = 1000L

ln_SPF_jt      = ALOG(SPF_jt)
ln_IAW_etajsq  = ALOG(all_eta_jsq[*,0])
test0          = FINITE(ln_SPF_jt) AND FINITE(ln_IAW_etajsq)
good           = WHERE(test0,gd)
PRINT,';;  ', gd, N_ELEMENTS(SPF_jt)
;;          4234        4320

fit_la         = LADFIT(ln_SPF_jt[good],ln_IAW_etajsq[good],ABSDEV=absdev,/DOUBLE)
A_fit          = fit_la[0]
B_fit          = fit_la[1]
PRINT,';;  ', fit_la[0], fit_la[1], absdev[0]
;;        -15.260507       1.5415978       2.7422281

x_range        = [MIN(ln_SPF_jt[good],/NAN),MAX(ln_SPF_jt[good],/NAN)]
PRINT,';;  ', x_range
;;        -4.8212413       6.7891767

;; Expand range
IF (x_range[0] LT 0) THEN x_range[0] *= 1.05 ELSE x_range[0] /= 1.05
IF (x_range[1] LT 0) THEN x_range[1] /= 1.05 ELSE x_range[1] *= 1.05
PRINT,';;  ', x_range
;;        -5.0623031       7.1286352

;;  Construct fit line:  Y = A + B X
ln_x_values    = DINDGEN(n_vals)*(x_range[1] - x_range[0])/(n_vals - 1L) + x_range[0]
ln_y_fit       = A_fit[0] + B_fit[0]*ln_x_values
;;  Return values to linear space
x_fit_all      = EXP(ln_x_values)
y_fit_all      = EXP(ln_y_fit)
;;-----------------------------------------------
;;  Fit to just Bow Shock (BS) events
;;-----------------------------------------------
spf_jt_bs      = SPF_jt[ind_01]
iaw_etajsq_bs  = REFORM(all_eta_jsq[ind_01,0])
;;  Sort results by |S(w,k)|
sp             = SORT(spf_jt_bs)
spf_jt_bs      = spf_jt_bs[sp]
iaw_etajsq_bs  = iaw_etajsq_bs[sp]


ln_SPF_jt_bs   = ALOG(spf_jt_bs)
lnIAWetajsq_bs = ALOG(iaw_etajsq_bs)
test0          = FINITE(ln_SPF_jt_bs) AND FINITE(lnIAWetajsq_bs)
good_bs        = WHERE(test0,gdbs)
PRINT,';;  ', gdbs, N_ELEMENTS(ln_SPF_jt_bs)
;;          3290        3296

fit_la_bs      = LADFIT(ln_SPF_jt_bs[good_bs],lnIAWetajsq_bs[good_bs],ABSDEV=absdev_bs,/DOUBLE)
A_fit_bs       = fit_la_bs[0]
B_fit_bs       = fit_la_bs[1]
PRINT,';;  ', fit_la_bs[0], fit_la_bs[1], absdev_bs[0]
;;        -14.358836       1.6296579       1.9166228

x_range_bs     = [MIN(ln_SPF_jt_bs[good_bs],/NAN),MAX(ln_SPF_jt_bs[good_bs],/NAN)]
PRINT,';;  ', x_range_bs
;;        -4.3873850       6.7891767

;; Expand range
IF (x_range_bs[0] LT 0) THEN x_range_bs[0] *= 1.05 ELSE x_range_bs[0] /= 1.05
IF (x_range_bs[1] LT 0) THEN x_range_bs[1] /= 1.05 ELSE x_range_bs[1] *= 1.05
PRINT,';;  ', x_range_bs
;;        -4.6067540       7.1286352

;;  Construct fit line:  Y = A + B X
ln_x_values_bs = DINDGEN(n_vals)*(x_range_bs[1] - x_range_bs[0])/(n_vals - 1L) + x_range_bs[0]
ln_y_fit_bs    = A_fit_bs[0] + B_fit_bs[0]*ln_x_values_bs
;;  Return values to linear space
x_fit_bs       = EXP(ln_x_values_bs)
y_fit_bs       = EXP(ln_y_fit_bs)
;;-----------------------------------------------
;;  Try LINFIT for just BS events
;;-----------------------------------------------
ln_SPF_jt_bs   = ALOG(spf_jt_bs)
lnIAWetajsq_bs = ALOG(iaw_etajsq_bs)
test0          = FINITE(ln_SPF_jt_bs) AND FINITE(lnIAWetajsq_bs)
good_bs        = WHERE(test0,gdbs)
PRINT,';;  ', gdbs, N_ELEMENTS(ln_SPF_jt_bs)
;;          3290        3296

ln_x_bs        = ln_SPF_jt_bs[good_bs]
ln_y_bs        = lnIAWetajsq_bs[good_bs]
linfit_bs      = LINFIT(ln_x_bs,ln_y_bs,CHISQR=chisq_bs,/DOUBLE,PROB=prob_bs,SIGMA=sig_bs)
A_linfit_bs    = linfit_bs[0]
B_linfit_bs    = linfit_bs[1]
dog_bs         = N_ELEMENTS(ln_x_bs) - 2L - 1L
PRINT,';;  ', fit_la_bs[0], fit_la_bs[1], chisq_bs[0]/dog_bs[0], $
              prob_bs[0], sig_bs[0], sig_bs[1]
;;        -14.358836       1.6296579       6.1469047       1.0000000     0.043911944     0.026662264

;;  Construct fit line:  Y = A + B X
lnxlinfit_bs   = DINDGEN(n_vals)*(x_range_bs[1] - x_range_bs[0])/(n_vals - 1L) + x_range_bs[0]
lnylinfit_bs_v = A_linfit_bs[0] + B_linfit_bs[0]*ln_x_values_bs
lnylinfit_bs_l = (A_linfit_bs[0] + sig_bs[0]) + (B_linfit_bs[0] - sig_bs[1])*ln_x_values_bs  ;; low  end
lnylinfit_bs_h = (A_linfit_bs[0] - sig_bs[0]) + (B_linfit_bs[0] + sig_bs[1])*ln_x_values_bs  ;; high end
;;  Return values to linear space
x_linfit_bs    = EXP(lnxlinfit_bs)
y_linfit_bs_v  = EXP(lnylinfit_bs_v)
y_linfit_bs_l  = EXP(lnylinfit_bs_l)
y_linfit_bs_h  = EXP(lnylinfit_bs_h)
;;
;;  Print out linear space versions
;;

PRINT,';;  ', EXP(A_linfit_bs[0]), EXP(sig_bs[0]), B_linfit_bs[0], sig_bs[1]
;;     5.3304542e-07       1.0448903       1.6042011     0.026662264

;;-----------------------------------------------
;;  Try POLY_FIT for 4th degree
;;
;;    Y = A + B X + C X^{2} + D X^{3} + E X^{4}
;;-----------------------------------------------
ln_SPF_jt_bs   = ALOG(spf_jt_bs)
lnIAWetajsq_bs = ALOG(iaw_etajsq_bs)
test0          = FINITE(ln_SPF_jt_bs) AND FINITE(lnIAWetajsq_bs)
good_bs        = WHERE(test0,gdbs)
PRINT,';;  ', gdbs, N_ELEMENTS(ln_SPF_jt_bs)
;;          3290        3296

ln_x_bs        = ln_SPF_jt_bs[good_bs]
ln_y_bs        = lnIAWetajsq_bs[good_bs]
;;  Perform fit
polyfit_bs     = POLY_FIT(ln_x_bs,ln_y_bs,4,/DOUBLE,CHISQ=polychisq,     $
                          STATUS=status,SIGMA=sigpoly_bs,YBAND=lnyband,$
                          YERROR=yerror)
PRINT,';;  ', status[0]
;;             0

polyfit_bs     = REFORM(polyfit_bs)
polydog        = N_ELEMENTS(ln_x_bs) - N_ELEMENTS(polyfit_bs) - 1L
PRINT,';;  ', polychisq[0]/polydog[0], yerror[0]
;;         6.1010471       2.4696538


PRINT,';;  ', sigpoly_bs
;;       0.061560904     0.045873611     0.023561420    0.0057127242    0.0014496023

A_polyfit_bs   = polyfit_bs[0]
B_polyfit_bs   = polyfit_bs[1]
C_polyfit_bs   = polyfit_bs[2]
D_polyfit_bs   = polyfit_bs[3]
E_polyfit_bs   = polyfit_bs[4]
PRINT,';;  ', REFORM(polyfit_bs)
;;        -14.588404       1.7181019     0.082167427    -0.013162865   -0.0026592710

;;  Construct fit line:  Y = A + B X + C X^{2} + D X^{3} + E X^{4}
ln_y_polyfit   = A_polyfit_bs[0] + B_polyfit_bs[0]*lnxlinfit_bs + $
                 C_polyfit_bs[0]*lnxlinfit_bs^2 + D_polyfit_bs[0]*lnxlinfit_bs^3 + $
                 E_polyfit_bs[0]*lnxlinfit_bs^4
y_polyfit_bs   = EXP(ln_y_polyfit)
;;----------------------------------------------------------------------------------------
;; => Find density function in 2D
;;----------------------------------------------------------------------------------------
v1             = SPF_jt[ind_01]
v2             = REFORM(all_eta_jsq[ind_01,0])
;;  Sort results by |S(w,k)|
sp             = SORT(v1)
v1             = v1[sp]
v2             = v2[sp]
;;  Keep only finite results
test0          = FINITE(v1) AND FINITE(v2)
good_bin       = WHERE(test0,gdbin)
PRINT,';;  ', gdbin, N_ELEMENTS(v1)
;;          3290        3296
v1             = v1[good_bin]
v2             = v2[good_bin]
;;  Define ranges (from examining plots by eye)
minmax1        = [1d-2,1d2]
minmax2        = [1d-11,1d-2]
ln_nx1         = ALOG(minmax1)
ln_nx2         = ALOG(minmax2)
;;  Define bin width/height
nb1            = 40L
nb2            = 80L
ln_bin1        = (ln_nx1[1] - ln_nx1[0])/(nb1 - 1L)
ln_bin2        = (ln_nx2[1] - ln_nx2[0])/(nb2 - 1L)
bin1           = EXP(ln_bin1)
bin2           = EXP(ln_bin2)

dens_v1        = HISTOGRAM(ALOG(v1),BINSIZE=ln_bin1,LOCATIONS=ln_loc1,MIN=ln_nx1[0],MAX=ln_nx1[1],/NAN)
dens_v2        = HISTOGRAM(ALOG(v2),BINSIZE=ln_bin2,LOCATIONS=ln_loc2,MIN=ln_nx2[0],MAX=ln_nx2[1],/NAN)

loc1           = EXP(ln_loc1)
loc2           = EXP(ln_loc2)
;;  Define Avg. values and ranges within each 2D bin

loc_x_val      = DBLARR(nb1 - 1L,nb2 - 1L)
loc_y_val      = DBLARR(nb1 - 1L,nb2 - 1L)
avg_xy         = DBLARR(nb1 - 1L,nb2 - 1L,2L)  ;; [X-index, Y-index, { <X>, <Y> }]
min_xy         = DBLARR(nb1 - 1L,nb2 - 1L,2L)
max_xy         = DBLARR(nb1 - 1L,nb2 - 1L,2L)
FOR i=0L, nb1 - 2L DO BEGIN                                                              $
  i2 = i + 1L                                                                          & $
  FOR j=0L, nb2 - 2L DO BEGIN                                                            $
    j2 = j + 1L                                                                        & $
    loc_x_val[i,j] = MEAN([loc1[i],loc1[i2]],/NAN)                                     & $
    loc_y_val[i,j] = MEAN([loc2[j],loc2[j2]],/NAN)                                     & $
    test_x  = (v1 GE loc1[i]) AND (v1 LE loc1[i2])                                     & $
    test_y  = (v2 GE loc2[j]) AND (v2 LE loc2[j2])                                     & $
    good_x  = WHERE(test_x,gdx)                                                        & $
    good_y  = WHERE(test_y,gdy)                                                        & $
    good_xy = WHERE(test_x AND test_y,gdxy)                                            & $
    IF (gdxy GT 0) THEN avg_xy[i,j,*] = [MEAN(v1[good_x],/NAN),MEAN(v2[good_y],/NAN)]  & $
    IF (gdxy GT 0) THEN min_xy[i,j,*] = [ MIN(v1[good_x],/NAN), MIN(v2[good_y],/NAN)]  & $
    IF (gdxy GT 0) THEN max_xy[i,j,*] = [ MAX(v1[good_x],/NAN), MAX(v2[good_y],/NAN)]


;dens_2d        = HIST_2D(v1,v2,BIN1=bin1,BIN2=bin2,MAX1=minmax1[1],MAX2=minmax2[1],$
;                         MIN1=minmax1[0],MIN2=minmax2[0])
;TVSCL, dens_2d

WINDOW,3,RETAIN=2,XSIZE=1700,YSIZE=1100,TITLE='Energy Dissipation:  Binned'
WSET,3
!P.MULTI = [0,1,2]
  PLOT,loc1,dens_v1,YRANGE=minmax(dens_v1),XRANGE=minmax1,XLOG=1,YLOG=0,XSTYLE=1,YSTYLE=1,/NODATA
    OPLOT,loc1,dens_v1,PSYM=10,COLOR= 50
  PLOT,loc2,dens_v2,YRANGE=minmax(dens_v2),XRANGE=minmax2,XLOG=1,YLOG=0,XSTYLE=1,YSTYLE=1,/NODATA
    OPLOT,loc2,dens_v2,PSYM=10,COLOR=250
!P.MULTI = 0


;;----------------------------------------------------------------------------------------
;; => Save correlation plots
;;----------------------------------------------------------------------------------------
Delta_str      = STRUPCASE(get_greek_letter('delta'))
mu__str        = get_greek_letter('mu')
muo_str        = mu__str[0]+'!Do!N'
eta_str        = get_greek_letter('eta')
omega_str      = get_greek_letter('omega')


yttle          = eta_str[0]+'|j|!U2!N [Dissipation, '+mu__str[0]+'W m!U-3!N'+']'
xttle          = '|S| [FFT Power, '+mu__str[0]+'W m!U-2!N'+']'
pttle          = 'Dissipation Rate vs. Integrated FFT Poynting Flux '+tdate_01[0]
pstr           = {TITLE:pttle,XTITLE:xttle,YTITLE:yttle,YLOG:1,XLOG:1,NODATA:1,YTICKS:14L,YMINOR:9L,XMINOR:9L}

n_sum          = 1L
WSET,1
  PLOT,SPF_jt,all_eta_jsq[*,0],_EXTRA=pstr
    OPLOT,SPF_jt[ind_0],all_eta_jsq[ind_0,0],PSYM=7,COLOR= 50,NSUM=n_sum[0]
    OPLOT,SPF_jt[ind_1],all_eta_jsq[ind_1,0],PSYM=7,COLOR=150,NSUM=n_sum[0]
    ;; overplot fit lines
    OPLOT,   x_fit_bs,      y_fit_bs,LINESTYLE=2,COLOR=250,THICK=2.0
    OPLOT,x_linfit_bs, y_linfit_bs_v,LINESTYLE=2,COLOR=200,THICK=2.0
    OPLOT,x_linfit_bs,  y_polyfit_bs,LINESTYLE=2,COLOR=100,THICK=2.0
    ;; output fit legend
    XYOUTS,0.15,0.80,'Ln| Y | = Ln| A + B X | [BS Points (LADFIT Soln.)]',/NORMAL,COLOR=250
    XYOUTS,0.15,0.75,'Ln| Y | = Ln| A + B X | [BS Points (LINFIT Soln.)]',/NORMAL,COLOR=200
    poly_str = 'Y =  A + B X + C X!U2!N + D X!U3!N + E X!U4!N'+'!C'
    XYOUTS,0.15,0.70,poly_str[0]+'  [BS Points (COMFIT Soln.)]',/NORMAL,COLOR=100
    ;; output legend
    XYOUTS,0.15,0.90,'X = '+tdate0[0]+' [Bow Shock (BS)]',/NORMAL,COLOR= 50
    XYOUTS,0.15,0.85,'X = '+tdate1[0]+' [Bow Shock (BS)]',/NORMAL,COLOR=150



SET_PLOT,'PS'
pfontold       = !P.FONT
!P.FONT        = -1
mu__strps      = get_greek_letter('mu')
eta_strps      = get_greek_letter('eta')
!P.FONT        = pfontold[0]
SET_PLOT,'X'

yttleps        = eta_strps[0]+' |j|!U2!N [Dissipation, '+mu__strps[0]+'W m!U-3!N'+']'
xttleps        = '|S| [FFT Power, '+mu__strps[0]+'W m!U-2!N'+']'
pttle          = 'Dissipation Rate vs. Integrated FFT Poynting Flux '+tdate_01[0]
pstrps         = {TITLE:pttle,XTITLE:xttleps,YTITLE:yttleps,YLOG:1,XLOG:1,NODATA:1,YTICKS:14L,YMINOR:9L,XMINOR:9L}
fname          = 'Dissipation-Rate_vs_Integrated-FFT-Poynting-Flux_'+tdate_01f[0]+'_fit-lines'

popen,fname[0],/LAND
  !P.FONT        = -1
  PLOT,SPF_jt,all_eta_jsq[*,0],_EXTRA=pstr
    OPLOT,SPF_jt[ind_0],all_eta_jsq[ind_0,0],PSYM=7,COLOR= 50
    OPLOT,SPF_jt[ind_1],all_eta_jsq[ind_1,0],PSYM=7,COLOR=150
    ;; overplot fit lines
    OPLOT,   x_fit_bs,      y_fit_bs,LINESTYLE=2,COLOR=250,THICK=2.0
    OPLOT,x_linfit_bs, y_linfit_bs_v,LINESTYLE=2,COLOR=200,THICK=2.0
    OPLOT,x_linfit_bs,  y_polyfit_bs,LINESTYLE=2,COLOR=100,THICK=2.0
    ;; output fit legend
    XYOUTS,0.15,0.80,'Ln| Y | = Ln| A + B X | [BS Points (LADFIT Soln.)]',/NORMAL,COLOR=250
    XYOUTS,0.15,0.75,'Ln| Y | = Ln| A + B X | [BS Points (LINFIT Soln.)]',/NORMAL,COLOR=200
    poly_str = 'Y =  A + B X + C X!U2!N + D X!U3!N + E X!U4!N'+'!C'
    XYOUTS,0.15,0.70,poly_str[0]+'  [BS Points (COMFIT Soln.)]',/NORMAL,COLOR=100
    ;; output legend
    XYOUTS,0.15,0.90,'X = '+tdate0[0]+' [Bow Shock (BS)]',/NORMAL,COLOR= 50
    XYOUTS,0.15,0.85,'X = '+tdate1[0]+' [Bow Shock (BS)]',/NORMAL,COLOR=150
  !P.FONT        = 0
pclose





yttle          = eta_str[0]+'|j|!U2!N [Dissipation, '+mu__str[0]+'W m!U-3!N'+']'
xttle          = '|S| [FFT Power, '+mu__str[0]+'W m!U-2!N'+']'
pttle          = 'Dissipation Rate vs. Integrated FFT Poynting Flux '+tdate_01[0]
pstr           = {TITLE:pttle,XTITLE:xttle,YTITLE:yttle,YLOG:1,XLOG:1,NODATA:1,YTICKS:14L,YMINOR:9L,XMINOR:9L}

n_sum          = 3L
WSET,1
  PLOT,SPF_jt,all_eta_jsq[*,0],_EXTRA=pstr
    OPLOT,SPF_jt[ind_0],all_eta_jsq[ind_0,0],PSYM=7,COLOR= 50,NSUM=n_sum[0]
    OPLOT,SPF_jt[ind_1],all_eta_jsq[ind_1,0],PSYM=7,COLOR=150,NSUM=n_sum[0]
    OPLOT,SPF_jt[ind_2],all_eta_jsq[ind_2,0],PSYM=7,COLOR=250,NSUM=n_sum[0]
    ;; overplot fit lines
    OPLOT,   x_fit_bs,      y_fit_bs,LINESTYLE=2,COLOR=250,THICK=2.0
    OPLOT,x_linfit_bs, y_linfit_bs_v,LINESTYLE=2,COLOR=200,THICK=2.0
    ;; output legend
    XYOUTS,0.12,0.90,'X = '+tdate0[0]+' [Bow Shock (BS)]',/NORMAL,COLOR= 50
    XYOUTS,0.12,0.85,'X = '+tdate1[0]+' [Bow Shock (BS)]',/NORMAL,COLOR=150
    XYOUTS,0.12,0.80,'X = '+tdate2[0]+' [Foreshock Bubble (FB)]',/NORMAL,COLOR=250
    ;; output fit legend
    XYOUTS,0.12,0.75,'Ln| Y | = Ln| A + B X | [BS Points (LADFIT Soln.)]',/NORMAL,COLOR=250
    XYOUTS,0.12,0.70,'Ln| Y | = Ln| A + B X | [BS Points (LINFIT Soln.)]',/NORMAL,COLOR=200





yttle          = '(n . S) ['+mu__str[0]+'W m!U-2!N'+']'
xttle          = '-(E . j) [Dissipation, '+mu__str[0]+'W m!U-3!N'+']'
pttle          = 'EM Power Out vs. Rate of Mechanical Work '+tdate_01[0]
pstr           = {TITLE:pttle,XTITLE:xttle,YTITLE:yttle,YLOG:0,XLOG:0,NODATA:1}
WSET,1
PLOT,E_dot_j_sm,n_dot_S_jt,_EXTRA=pstr
  OPLOT,E_dot_j_sm,n_dot_S_jt,PSYM=2,COLOR=50
  OPLOT,ABS(E_dot_j_sm),ABS(n_dot_S_jt),PSYM=7,COLOR=250



yttle          = '|(n . S)| ['+mu__str[0]+'W m!U-2!N'+']'
xttle          = '|(E . j)| [Dissipation, '+mu__str[0]+'W m!U-3!N'+']'
pttle          = 'EM Power Out vs. Rate of Mechanical Work '+tdate_01[0]
pstr           = {TITLE:pttle,XTITLE:xttle,YTITLE:yttle,YLOG:1,XLOG:1,NODATA:1,YMINOR:9L,XMINOR:9L}
xdata          = ABS(E_dot_j_sm)
ydata          = ABS(n_dot_S_jt)
test0          = FINITE(xdata) AND FINITE(ydata)
test1          = (xdata GT 0) AND (ydata GT 0)
good           = WHERE(test0 AND test1,gd)
xdata          = xdata[good]
ydata          = ydata[good]

n_sum          = 10L
WSET,1
PLOT,xdata,ydata,_EXTRA=pstr
    OPLOT,xdata[ind_0],ydata[ind_0],PSYM=7,COLOR= 50,NSUM=n_sum[0]
    OPLOT,xdata[ind_1],ydata[ind_1],PSYM=7,COLOR=150,NSUM=n_sum[0]
    ;; output legend
    XYOUTS,0.15,0.90,'X = '+tdate0[0]+' [Bow Shock (BS)]',/NORMAL,COLOR= 50
    XYOUTS,0.15,0.85,'X = '+tdate1[0]+' [Bow Shock (BS)]',/NORMAL,COLOR=150



yttle          = eta_str[0]+'|j|!U2!N [Dissipation, '+mu__str[0]+'W m!U-3!N'+']'
xttle          = '|(E . j)/(n . S)| [Ratio of Work to EM Power]'
pttle          = 'Dissipation Rate vs. (Rate of Mechanical Work)/(EM Power Out) '+tdate_01[0]
pstr           = {TITLE:pttle,XTITLE:xttle,YTITLE:yttle,YLOG:1,XLOG:1,NODATA:1,YMINOR:9L,XMINOR:9L}
xdata          = ABS(E_dot_j_sm/n_dot_S_jt)
ydata          = REFORM(all_eta_jsq[*,0])
test0          = FINITE(xdata) AND FINITE(ydata)
test1          = (xdata GT 0) AND (ydata GT 0)
good           = WHERE(test0 AND test1,gd)
xdata          = xdata[good]
ydata          = ydata[good]

WSET,1
PLOT,xdata,ydata,_EXTRA=pstr
    OPLOT,xdata[ind_0],ydata[ind_0],PSYM=7,COLOR= 50
    OPLOT,xdata[ind_1],ydata[ind_1],PSYM=7,COLOR=150
    ;; output legend
    XYOUTS,0.15,0.90,'X = '+tdate0[0]+' [Bow Shock (BS)]',/NORMAL,COLOR= 50
    XYOUTS,0.15,0.85,'X = '+tdate1[0]+' [Bow Shock (BS)]',/NORMAL,COLOR=150


yttle          = '|S| [FFT Power, '+mu__str[0]+'W m!U-2!N'+']'
xttle          = '|(E . j)/(n . S)| [Ratio of Work to EM Power]'
pttle          = 'Integrated FFT Poynting Flux vs. (Rate of Mechanical Work)/(EM Power Out) '+tdate_01[0]
pstr           = {TITLE:pttle,XTITLE:xttle,YTITLE:yttle,YLOG:1,XLOG:1,NODATA:1,YMINOR:9L,XMINOR:9L}
xdata          = ABS(E_dot_j_sm/n_dot_S_jt)
ydata          = REFORM(SPF_jt)
test0          = FINITE(xdata) AND FINITE(ydata)
test1          = (xdata GT 0) AND (ydata GT 0)
good           = WHERE(test0 AND test1,gd)
xdata          = xdata[good]
ydata          = ydata[good]

WSET,2
PLOT,xdata,ydata,_EXTRA=pstr
    OPLOT,xdata[ind_0],ydata[ind_0],PSYM=7,COLOR= 50
    OPLOT,xdata[ind_1],ydata[ind_1],PSYM=7,COLOR=150
    ;; output legend
    XYOUTS,0.15,0.90,'X = '+tdate0[0]+' [Bow Shock (BS)]',/NORMAL,COLOR= 50
    XYOUTS,0.15,0.85,'X = '+tdate1[0]+' [Bow Shock (BS)]',/NORMAL,COLOR=150



















































;;----------------------------------------------------------------------------------------
;; => Test plots
;;----------------------------------------------------------------------------------------

WSET,1
  PLOT,SPF_jt,all_eta_jsq[*,0],_EXTRA=pstr
    OPLOT,SPF_jt[ind_0],all_eta_jsq[ind_0,0],PSYM=7,COLOR= 50
    OPLOT,SPF_jt[ind_1],all_eta_jsq[ind_1,0],PSYM=7,COLOR=150
    OPLOT,SPF_jt[ind_2],all_eta_jsq[ind_2,0],PSYM=7,COLOR=250
    ;; overplot fit lines
    OPLOT,x_fit_all,y_fit_all,LINESTYLE=2,COLOR=200,THICK=2.0
    OPLOT,x_fit_bs ,y_fit_bs ,LINESTYLE=2,COLOR=100,THICK=2.0
    XYOUTS,0.15,0.75,'Ln| Y | = Ln| A + B X | [ALL Points]',/NORMAL,COLOR=200
    XYOUTS,0.15,0.70,'Ln| Y | = Ln| A + B X | [BS Points]',/NORMAL,COLOR=100
    ;; output legend
    XYOUTS,0.15,0.90,'X = '+tdate0[0]+' [Bow Shock (BS)]',/NORMAL,COLOR= 50
    XYOUTS,0.15,0.85,'X = '+tdate1[0]+' [Bow Shock (BS)]',/NORMAL,COLOR=150
    XYOUTS,0.15,0.80,'X = '+tdate2[0]+' [Foreshock Bubble (FB)]',/NORMAL,COLOR=250


WSET,1
  PLOT,SPF_jt,all_eta_jsq[*,0],_EXTRA=pstr
    OPLOT,SPF_jt[ind_0],all_eta_jsq[ind_0,0],PSYM=7,COLOR= 50
    OPLOT,SPF_jt[ind_1],all_eta_jsq[ind_1,0],PSYM=7,COLOR=150
    ;; overplot fit lines
    OPLOT,   x_fit_bs,     y_fit_bs,LINESTYLE=2,COLOR=250,THICK=2.0
    OPLOT,x_linfit_bs,y_linfit_bs_v,LINESTYLE=2,COLOR=200,THICK=2.0
    OPLOT,x_linfit_bs,y_linfit_bs_l,LINESTYLE=2,COLOR=100,THICK=2.0
    OPLOT,x_linfit_bs,y_linfit_bs_h,LINESTYLE=2,COLOR= 30,THICK=2.0
    XYOUTS,0.15,0.80,'Ln| Y | = Ln| A + B X | [BS Points (LADFIT Soln.)]',/NORMAL,COLOR=250
    XYOUTS,0.15,0.75,'Ln| Y | = Ln| A + B X | [BS Points (LINFIT Soln.)]',/NORMAL,COLOR=200
    XYOUTS,0.15,0.70,'Ln| Y | = Ln| A + B X | [BS Points (LINFIT   Low)]',/NORMAL,COLOR=100
    XYOUTS,0.15,0.65,'Ln| Y | = Ln| A + B X | [BS Points (LINFIT  High)]',/NORMAL,COLOR= 30
    ;; output legend
    XYOUTS,0.15,0.90,'X = '+tdate0[0]+' [Bow Shock (BS)]',/NORMAL,COLOR= 50
    XYOUTS,0.15,0.85,'X = '+tdate1[0]+' [Bow Shock (BS)]',/NORMAL,COLOR=150


a_guess        = [1d-6,2.25,1d-14]
lntest         = ALOG(a_guess[0]*x_fit_bs^(a_guess[1]) + a_guess[2])
test           = EXP(lntest)

WSET,2
  PLOT,SPF_jt,all_eta_jsq[*,0],_EXTRA=pstr
    OPLOT,SPF_jt[ind_0],all_eta_jsq[ind_0,0],PSYM=7,COLOR= 50
    OPLOT,SPF_jt[ind_1],all_eta_jsq[ind_1,0],PSYM=7,COLOR=150
    ;; overplot fit lines
    OPLOT,x_fit_bs,test,LINESTYLE=2,COLOR=250,THICK=2.0
    ;; output legend
    XYOUTS,0.15,0.90,'X = '+tdate0[0]+' [Bow Shock (BS)]',/NORMAL,COLOR= 50
    XYOUTS,0.15,0.85,'X = '+tdate1[0]+' [Bow Shock (BS)]',/NORMAL,COLOR=150

















