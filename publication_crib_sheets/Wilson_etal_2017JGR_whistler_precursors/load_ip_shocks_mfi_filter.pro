;;  .compile $HOME/Desktop/low_beta_Ma_whistlers/crib_sheets/load_ip_shocks_mfi_filter.pro

PRO load_ip_shocks_mfi_filter,TRANGE=trange,PRECISION=prec,FREQ_RANGE=freq_range,NO_INS_NAN=no_ins_nan

;;  Requires:  TRANGE      :  [2]-element [numeric] time range [Unix]
;;  Optional:  PRECISION   :  Scalar [numeric] defining the # of Sig. Figs.
;;  Optional:  FREQ_RANGE  :  [2]-element [numeric] frequency range [Hz]
;;  Optional:  NO_INS_NAN  :  If set, routine will not insert NaNs in data gaps
;;----------------------------------------------------------------------------------------
;;  Constants
;;----------------------------------------------------------------------------------------
all_labs       = ['x','y','z','mag']
all_cols       = [250,200,75,25]
vec_str        = ['x','y','z']
vec_col        = [250,150,50]
mfi_gse_tpn    = 'Wind_B_htr_gse'
mfi_mag_tpn    = 'Wind_B_htr_mag'
mfi_filt_lp    = 'lowpass_Bo'
mfi_filt_hp    = 'highpass_Bo'
mfi_filt_dettp = 'highpass_Bo_detrended'
yttl_lpfilt    = 'LPFilt. Bo [nT, GSE]'
yttl_hpfilt    = 'HPFilt. Bo [nT, GSE]'
yttl_hpfiltdet = 'HPFilt. Bo [nT, GSE, Det.]'
yttl_bvec      = 'Bo [nT, GSE]'
yttl_bmag      = '|Bo| [nT]'
;;  Define defaults
def_tramp      = '1995-04-17/23:33:07.755'         ;;  Midpoint of 1st ramp with precursor
def_delt       = [-1,1]*36d2                       ;;  default to a 2 hour window
;;----------------------------------------------------------------------------------------
;;  Check TPLOT and keywords
;;----------------------------------------------------------------------------------------
nna            = tnames()
IF (nna[0] NE '') THEN store_data,DELETE=nna  ;;  Make sure nothing is already loaded

;;----------------------------------------------------------------------------------------
;;  Check keywords
;;----------------------------------------------------------------------------------------
;;  Check TRANGE
test           = (N_ELEMENTS(trange) NE 2) OR (is_a_number(trange,/NOMSSG) EQ 0)
IF (test[0]) THEN BEGIN
  ;;  Default to first precursor event
  tran           = time_double(def_tramp[0]) + def_delt
  outmssg        = 'Defaulting to ±1 hour window about 1995-04-17/23:33:07.755 UTC'
  MESSAGE,outmssg[0],/INFORMATIONAL,/CONTINUE
ENDIF ELSE BEGIN
  temp           = get_valid_trange(TRANGE=trange,PRECISION=prec)
  tran           = temp.UNIX_TRANGE
ENDELSE
;;  Check FREQ_RANGE
test           = (N_ELEMENTS(freq_range) NE 2) OR (is_a_number(freq_range,/NOMSSG) EQ 0)
IF (test[0]) THEN fran = [1e-1,1d2] ELSE fran = REFORM(freq_range)
test           = (fran[0] EQ fran[1]) OR (TOTAL(FINITE(fran)) LT 2)
;test           = (fran[0] EQ fran[1]) OR (TOTAL(FINITE(fran) EQ 0) LT 2)
IF (test[0]) THEN fran = [1e-1,1d2]
PRINT,';;  fran = ',fran[0],' - ',fran[1]
;;  Check NO_INS_NAN
test           = (N_ELEMENTS(no_ins_nan) GE 1)
IF (test[0]) THEN test = KEYWORD_SET(no_ins_nan[0]) ELSE test = 0b
IF (test[0]) THEN nans_on = 0b ELSE nans_on = 1b
;;----------------------------------------------------------------------------------------
;;  Load MFI into TPLOT
;;----------------------------------------------------------------------------------------
load_ip_shocks_mfi_split_magvec,TRANGE=tran,PRECISION=prec
;;  Make sure data was loaded
nna            = tnames(mfi_gse_tpn[0])
IF (nna[0] EQ '') THEN STOP    ;;  Something's wrong --> Debug!
;;----------------------------------------------------------------------------------------
;;  Get MFI data and filter
;;----------------------------------------------------------------------------------------
;;  Get data
get_data,mfi_gse_tpn[0],DATA=temp,DLIM=dlim,LIM=lim
;;  Define params
unix           = t_get_struc_unix(temp,TSHFT_ON=tshft_on)
IF KEYWORD_SET(tshft_on) THEN tshft = temp.TSHIFT[0] ELSE tshft = 0d0
srate0         = sample_rate(unix,/AVERAGE,OUT_MED_AVG=medavg)
fac            = 15d-1
test           = (srate0[0] GE fac[0]*medavg[0]) OR (srate0[0] LE medavg[0]/fac[0])
IF (test[0]) THEN srate = medavg[0] ELSE srate = srate0[0]     ;;  Make sure average is not thrown off by outliers
vecs           = temp.Y
;;  Define smoothing width prior to low-pass filtering to avoid aliasing
lp_wdth        = CEIL(srate[0]/fran[0])
tempx          = SMOOTH(vecs[*,0],lp_wdth[0],/NAN,/EDGE_TRUNCATE)
tempy          = SMOOTH(vecs[*,1],lp_wdth[0],/NAN,/EDGE_TRUNCATE)
tempz          = SMOOTH(vecs[*,2],lp_wdth[0],/NAN,/EDGE_TRUNCATE)
smthB          = [[tempx],[tempy],[tempz]]
;;  Filter data
low_pass       = vector_bandpass(smthB,srate[0],0d0,fran[0],/MIDF)
highpass       = vector_bandpass( vecs,srate[0],fran[0],fran[1],/MIDF)
;;  Detrend high pass filtered result to remove large deviations due to ramp
wdth           = 10L
tempx          = SMOOTH(highpass[*,0],wdth[0],/NAN,/EDGE_TRUNCATE)
tempy          = SMOOTH(highpass[*,1],wdth[0],/NAN,/EDGE_TRUNCATE)
tempz          = SMOOTH(highpass[*,2],wdth[0],/NAN,/EDGE_TRUNCATE)
smhpB          = [[tempx],[tempy],[tempz]]
;;  Detrend:  ∂B* = ∂B - <∂B>
detr_dB        = highpass - smhpB
;;----------------------------------------------------------------------------------------
;;  Send to TPLOT
;;----------------------------------------------------------------------------------------
;;  Define TPLOT structures
lpstruc        = {X:unix,Y:low_pass,TSHIFT:tshft[0]}
hpstruc        = {X:unix,Y:highpass,TSHIFT:tshft[0]}
hpdetst        = {X:unix,Y:detr_dB, TSHIFT:tshft[0]}
;;  Store data in TPLOT
store_data,   mfi_filt_lp[0],DATA=lpstruc,DLIM=dlim,LIM=lim
store_data,   mfi_filt_hp[0],DATA=hpstruc,DLIM=dlim,LIM=lim
store_data,mfi_filt_dettp[0],DATA=hpstruc,DLIM=dlim,LIM=lim
;;  Fix options
options,[mfi_filt_lp[0],mfi_filt_hp[0],mfi_filt_dettp[0]],'COLORS'
options,[mfi_filt_lp[0],mfi_filt_hp[0],mfi_filt_dettp[0]],'LABELS'
options,[mfi_filt_lp[0],mfi_filt_hp[0],mfi_filt_dettp[0]],'YTITLE'
options,   mfi_filt_lp[0],COLORS=vec_col,LABELS=vec_str,YTITLE=yttl_lpfilt[0],   /DEF
options,   mfi_filt_hp[0],COLORS=vec_col,LABELS=vec_str,YTITLE=yttl_hpfilt[0],   /DEF
options,mfi_filt_dettp[0],COLORS=vec_col,LABELS=vec_str,YTITLE=yttl_hpfiltdet[0],/DEF
;;  Insert NaNs in gaps to prevent IDL from connecting lines across gaps
gapthsh        = 2d0/srate[0]
nna            = [mfi_mag_tpn[0],mfi_gse_tpn[0],mfi_filt_lp[0],mfi_filt_hp[0],mfi_filt_dettp[0]]
IF (nans_on[0]) THEN t_insert_nan_at_interval_se,nna,GAP_THRESH=gapthsh[0]
;;  Plot results
tplot,nna,TRANGE=tran
;;----------------------------------------------------------------------------------------
;;  Return to user
;;----------------------------------------------------------------------------------------

RETURN
END
