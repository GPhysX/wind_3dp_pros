;+
;*****************************************************************************************
;
;  PROCEDURE:   plot_irreg_superposed_epoch_anal.pro
;  PURPOSE  :   This routine creates a superposed epoch analysis plot from an input
;                  array of independent data and dependent data.  The data need not
;                  be on a regular grid prior to calling as this routine will partition
;                  the data for the user.
;
;  CALLED BY:   
;               NA
;
;  INCLUDES:
;               NA
;
;  CALLS:
;               is_a_number.pro
;               test_plot_axis_range.pro
;               sample_rate.pro
;               test_window_number.pro
;               num2int_str.pro
;               num2exp_str.pro
;               routine_version.pro
;               partition_data.pro
;               calc_1var_stats.pro
;               lbw_window.pro
;               str_element.pro
;               extract_tags.pro
;               popen.pro
;               pclose.pro
;
;  REQUIRES:    
;               1)  UMN Modified Wind/3DP IDL Libraries
;               2)  At least IDL v8.4
;
;  INPUT:
;               XDATA  :  [N]-Element [numeric] array of independent data points
;               YDATA  :  [N]-Element [numeric] array of dependent data points
;
;  EXAMPLES:    
;               [calling sequence]
;               plot_irreg_superposed_epoch_anal,xdata,ydata [,XTITLE=xtitle] [,YTITLE=ytitle]  $
;                                          [,XRANGE=xrange] [,YRANGE=yrange] [,TITLE=title]     $
;                                          [,FILE_NAME=file_name] [,WIND_N=wind_n]              $
;                                          [,/XLOG] [,/YLOG] [,/SHOW_MED] [,/SHOW_AVG]          $
;                                          [,/SHOW_05P] [,/SHOW_10P] [,/SHOW_25P]               $
;                                          [,P_LENGTH=p_length] [,P__SHIFT=p__shift]            $
;                                          [,XMID_PT=xmid_pt]
;
;  KEYWORDS:    
;               ****************
;               ***  INPUTS  ***
;               ****************
;               [X,Y]TITLE  :  Scalar [string] defining the [X,Y] plot axis title
;               [X,Y]RANGE  :  [2]-Element [numeric] array defining the [X,Y] plot axis
;                                range to use
;               TITLE       :  Scalar [string] defining the plot title
;               FILE_NAME   :  Scalar [string] defining the file name of the output
;                                postscript file name
;               WIND_N      :  Scalar [numeric] defining the window number to use
;               [X,Y]LOG    :  If set, routine will show the [X,Y] plot axis on a
;                                logarithmic scale
;                                [Default = FALSE]
;               SHOW_MED    :  If set, routine will show the median trend line vs time
;                                at each partitioned abscissa point
;                                [Default = FALSE]
;               SHOW_AVG    :  If set, routine will show the average trend line vs time
;                                at each partitioned abscissa point
;                                [Default = TRUE]
;               SHOW_05P    :  If set, routine will show the upper and lower boundaries
;                                defined by the 5% and 95% confidence levels
;                                [Default = FALSE]
;               SHOW_10P    :  If set, routine will show the upper and lower boundaries
;                                defined by the 10% and 90% confidence levels
;                                [Default = FALSE]
;               SHOW_25P    :  If set, routine will show the upper and lower boundaries
;                                defined by the 25% and 75% confidence levels
;                                [Default = TRUE]
;               P_LENGTH    :  Scalar [numeric] defining the # of elements to use to
;                                partition the data into bins
;                                [Default = 4]
;               P__SHIFT    :  Scalar [numeric] defining the # of elements to shift after
;                                each partition of the data into bins
;                                [Default = 2]
;               XMID_PT     :  Scalar [numeric] defining the location along the x-axis
;                                to show a vertical line marking the midpoint of the
;                                data/plot
;               SMWDTH      :  Scalar [numeric] defining the smoothing width to apply
;                                when you wish to smooth the mean/median and percentile
;                                lines that are overplotted on the data.  Note that this
;                                keyword is only used if SMLINES is set.
;                                [Default = 0L]
;               SMLINES     :  If set, routine will smooth the mean/median and percentile
;                                lines that are overplotted on the data.  Note that this
;                                keyword must be set for SMWDTH to be applied.
;                                [Default = FALSE]
;               T_LENGTH    :  Scalar [numeric] defining the width of the windows along
;                                XDATA to use to bin up the data for one-variable
;                                statistics.  Unlike P_LENGTH this does not care where
;                                XDATA are located and will not discretely jump at
;                                data gaps.  T_LENGTH should be small enough that at least
;                                two adjacent windows fit within XRANGE if set.
;                                [Default = FALSE]
;               T__SHIFT    :  Scalar [numeric] defining the shift along XDATA to use
;                                after each bin window.  The shift length should be at
;                                least 1/2 the median sample period of XDATA if set.
;                                [Default = FALSE]
;               YTICKS      :  Scalar [numeric] defining the value to use for the YTICKS
;                                in the plot LIMITS structure
;                                [Default = 8 for linear, FALSE for log]
;               YMINOR      :  Scalar [numeric] defining the value to use for the YMINOR
;                                in the plot LIMITS structure
;                                [Default = 10 for linear, 9 for log]
;               ****************
;               ***  OUTPUT  ***
;               ****************
;               OUT_STRUC   :  Set to a named variable to return the plot line info and
;                                other plot-relevant information
;
;   CHANGED:  1)  Fixed a bug when user does not define FILE_NAME keyword
;                                                                   [09/20/2019   v1.0.1]
;             2)  Added keywords:  SMWDTH and SMLINES
;                                                                   [09/20/2019   v1.0.2]
;             3)  Changed EDGE_* keywords in SMOOTH if YLOG = TRUE to avoid stupid-looking
;                   divergences to zero at the ends
;                                                                   [09/23/2019   v1.0.3]
;             4)  Added keywords:  T_LENGTH, T__SHIFT, and OUT_STRUC and
;                   now calls sample_rate.pro and num2exp_str.pro
;                                                                   [09/23/2019   v1.1.0]
;             5)  Added keywords:  YTICKS and YMINOR
;                                                                   [09/25/2019   v1.1.1]
;             6)  Changed a few things and added some more to OUT_STRUC
;                                                                   [11/11/2019   v1.1.2]
;
;   NOTES:      
;               1)  The routine plots all data as little black dots and over plots
;                     the average (cyan) or median (red) points for each abscissa
;                     with the lower and upper quartiles as error bars.  The routine
;                     will add a suffix to the file name specifying whether the mean
;                     or median was shown.
;               2)  The FILE_NAME input can include a path to the location, but if not,
;                     then the file will be saved in the current working directory.
;               3)  Use of the T_LENGTH and T__SHIFT keywords will supercede that of
;                     P_LENGTH and P__SHIFT and cause the routine to behave similarly
;                     to plot_superposed_epoch_anal.pro with regularly gridded inputs
;
;  REFERENCES:  
;               NA
;
;   CREATED:  09/19/2019
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  11/11/2019   v1.1.2
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

PRO plot_irreg_superposed_epoch_anal,xdata,ydata,XTITLE=xtitle,YTITLE=ytitle,XRANGE=xrange,  $
                                     YRANGE=yrange,TITLE=title,FILE_NAME=file_name,          $
                                     WIND_N=wind_n,XLOG=xlog,YLOG=ylog,SHOW_MED=show_med,    $
                                     SHOW_AVG=show_avg,SHOW_10P=show_10p,SHOW_05P=show_05p,  $
                                     SHOW_25P=show_25p,P_LENGTH=p_length,P__SHIFT=p__shift,  $
                                     XMID_PT=xmid_pt,SMWDTH=smwdth,SMLINES=smlines,          $
                                     T_LENGTH=t_length,T__SHIFT=t__shift,OUT_STRUC=out_struc,$
                                     YTICKS=yticks,YMINOR=yminor

;;----------------------------------------------------------------------------------------
;;  Define some constants and dummy variables
;;----------------------------------------------------------------------------------------
f              = !VALUES.F_NAN
d              = !VALUES.D_NAN
verns          = !VERSION.RELEASE     ;;  e.g., '7.1.1'
vernn          = FLOAT(STRMID(verns[0],0L,3L))
IF (vernn[0] LT 8.4) THEN BEGIN
  ;;  Cannot run routine with object-oriented IDL_Variable calls
  MESSAGE,'Cannot run routine with object-oriented IDL_Variable calls:  Need v8.4 or higher!',/INFORMATIONAL,/CONTINUE
  RETURN
ENDIF
;;  Dummy tick mark arrays
exp_val        = LINDGEN(501) - 250L                  ;;  Array of exponent values
exp_str        = STRTRIM(STRING(exp_val,FORMAT='(I)'),2L)
log10_tickn    = '10!U'+exp_str+'!N'                  ;;  Powers of 10 tick names
log10_tickv    = 1d1^DOUBLE(exp_val[*])               ;;  " " values
;;  Define relevant indices of the output from calc_1var_stats.pro
ind_min        =  0L                                  ;;  Index for minimum value
ind_max        =  1L                                  ;;  Index for maximum value
ind_avg        =  2L                                  ;;  Index for mean value
ind_med        =  3L                                  ;;  Index for median value
ind_std        =  4L                                  ;;  Index for standard deviation of values
ind_skw        =  6L                                  ;;  Index for skewness
ind_kur        =  7L                                  ;;  Index for kurtosis
ind_lqt        =  8L                                  ;;  Index for lower quartile
ind_uqt        =  9L                                  ;;  Index for upper quartile
ind_n_t        = 11L                                  ;;  Index for total # of input points
ind_n_f        = 12L                                  ;;  Index for total # of finite input points
def_len        = 4L                                   ;;  Default value for P_LENGTH keyword
def_off        = 2L                                   ;;  Default value for P__SHIFT keyword
;;  Define some logic defaults
avg_on         = 0b
med_on         = 0b
p05_on         = 0b
p10_on         = 0b
p25_on         = 0b
xlog_on        = 0b
ylog_on        = 0b
xmid_on        = 0b
smth_on        = 0b
psym_on        = 0b
inds_on        = 1b
time_on        = 0b
ytks_on        = 0b
ymin_on        = 0b
;;  Define some plot defaults
psym           = 10                                   ;;  Histogram symbol
colr           = [50L,200L,250L,100L]                 ;;  Use blue, orange, red, or cyan for color table 39
def_xttl       = 'Independent Data Axis'
def_yttl       = 'Dependent Data Axis'
def_ttle       = 'Superposed Epoch Analysis of Data'
def_yran       = [1d0,1d2]
def_delx       = 1d0
xposi0         = [0.93,0.90]
yposi0         = 0.15
dypos0         = [0.015,0.025]
chsz           = 1.5e0
thck           = [2e0,3.0e0]
chck           = 2e0
ethk           = [2e0,3.0e0]
xmarg          = [10,15]
ymarg          = [4,4]
;;  Define some default plot and PS file structures
def_pstr       = {XSTYLE:1,YSTYLE:1,XTICKS:8,XMINOR:10L,NODATA:1,YLOG:0,YMINOR:10L,   $
                  YTITLE:def_yttl[0],YTICKS:8,XLOG:0,CHARSIZE:chsz[0],THICK:thck[0],  $
                  XTHICK:thck[0],YTHICK:thck[0],XMARGIN:xmarg,YMARGIN:ymarg,          $
                  CHARTHICK:chck[0]}
def_lstr       = {XSTYLE:1,YSTYLE:1,XMINOR:10L,YMINOR:10L,YTITLE:def_yttl[0],NODATA:1,  $
                  CHARSIZE:chsz[0],THICK:thck[0],XTHICK:thck[0],YTHICK:thck[0],         $
                  XMARGIN:xmarg,YMARGIN:ymarg,CHARTHICK:chck[0]}
def_xystr      = {NORMAL:1,CHARSIZE:0.75,ORIENTATION:9e1,CHARTHICK:chck[0]}
postruc        = {LANDSCAPE:1,PORT:0,UNITS:'inches',XSIZE:10.5,YSIZE:8.,ASPECT:0}
;;  Dummy error messages
noinpt_msg     = 'No input supplied...'
nofint_msg     = 'Not enough finite data...'
badinp_msg     = 'XDATA and YDATA must both be [N]-element [numeric] arrays...'
;;----------------------------------------------------------------------------------------
;;  Check input
;;----------------------------------------------------------------------------------------
test           = (N_PARAMS() LT 2) OR (is_a_number(xdata,/NOMSSG) EQ 0) OR (is_a_number(ydata,/NOMSSG) EQ 0)
IF (test[0]) THEN BEGIN
  ;;  No input
  MESSAGE,noinpt_msg[0],/INFORMATIONAL,/CONTINUE
  RETURN
ENDIF
;;  Define data
xx             = REFORM(xdata,N_ELEMENTS(xdata))      ;;  Force to 1D
yy             = REFORM(ydata,N_ELEMENTS(ydata))      ;;  Force to 1D
szdx           = SIZE(xx,/DIMENSIONS)
szdy           = SIZE(yy,/DIMENSIONS)
IF (szdx[0] NE szdy[0]) THEN BEGIN
  ;;  Bad input format
  MESSAGE,badinp_msg[0],/INFORMATIONAL,/CONTINUE
  RETURN
ENDIF
;;  Check for finite data
test_x         = FINITE(xx)
good_xra       = WHERE(test_x,gdx)
test_y         = FINITE(yy)
good_yra       = WHERE(test_y,gdy)
IF (gdx[0] LT 5 OR gdy[0] LT 5) THEN BEGIN
  ;;  Not enough finite input
  MESSAGE,nofint_msg[0],/INFORMATIONAL,/CONTINUE
  RETURN
ENDIF
;;  Sort data and define finite-only arrays
sp             = SORT(xx)
xx             = xx[sp]
yy             = yy[sp]
good_xyra      = WHERE(FINITE(xx) AND FINITE(yy),gdxy)
xxf            = xx[good_xyra]
yyf            = yy[good_xyra]
;;  Define default [X,Y]-Range
mnmx_x         = [MIN(xxf,/NAN),MAX(xxf,/NAN)]
mnmx_y         = [MIN(yyf,/NAN),MAX(yyf,/NAN)]
test           = test_plot_axis_range(mnmx_x,/NOMSSG) AND test_plot_axis_range(mnmx_y,/NOMSSG)
IF (~test[0]) THEN BEGIN
  ;;  Bad input
  MESSAGE,nofint_msg[0],/INFORMATIONAL,/CONTINUE
  RETURN
ENDIF
def_xran       = mnmx_x
def_yran       = mnmx_y
gd__x          = N_ELEMENTS(xx)                       ;;  Total # of x-points supplied
gd_fx          = gdxy[0]                              ;;  Total # of finite/valid x-points supplied
gd__y          = N_ELEMENTS(yy)                       ;;  Total # of y-points supplied
gd_fy          = gdxy[0]                              ;;  Total # of finite/valid y-points supplied
nt             = gdxy[0]
srate0         = sample_rate(xxf,/AVERAGE,OUT_MED_AVG=medavg)
speri          = 1d0/medavg[0]
;;----------------------------------------------------------------------------------------
;;  Check keywords
;;----------------------------------------------------------------------------------------
;;  Check WINDN
test           = test_window_number(wind_n,DAT_OUT=windn)
IF (test[0] EQ 0) THEN windn = 1L
;;  Check [X,Y]TITLE
test           = (SIZE(xtitle,/TYPE) NE 7) OR (N_ELEMENTS(xtitle) LT 1)
IF (test[0]) THEN xttl = def_xttl[0] ELSE xttl = xtitle[0]
test           = (SIZE(ytitle,/TYPE) NE 7) OR (N_ELEMENTS(ytitle) LT 1)
IF (test[0]) THEN yttl = def_yttl[0] ELSE yttl = ytitle[0]
;;  Check TITLE
test           = (SIZE(title,/TYPE) NE 7) OR (N_ELEMENTS(title) LT 1)
IF (test[0]) THEN ttle = def_ttle[0] ELSE ttle = title[0]
;;  Check FILE_NAME
test           = (SIZE(file_name,/TYPE) NE 7) OR (N_ELEMENTS(file_name) LT 1)
IF (test[0]) THEN save_on = 0b ELSE save_on = 1b
IF (save_on[0]) THEN fname = file_name[0]
;;  Check [X,Y]RANGE
test           = test_plot_axis_range(xrange,/NOMSSG)
IF (test[0]) THEN xran = xrange ELSE xran = def_xran
test           = test_plot_axis_range(yrange,/NOMSSG)
IF (test[0]) THEN yran = yrange ELSE yran = def_yran
;;  Check SHOW_[MED,AVG]
IF KEYWORD_SET(show_med) THEN med_on = 1b
IF (med_on[0] AND avg_on[0]) THEN avg_on = 0b        ;;  Shut off mean if user wants median
IF KEYWORD_SET(show_avg) THEN avg_on = 1b
IF (med_on[0] AND avg_on[0]) THEN med_on = 0b        ;;  Only allow one to be on
IF (~med_on[0] AND ~avg_on[0]) THEN avg_on = 1b      ;;  Make sure at least one is set
;;  Check SHOW_[05P,10P,25P]
IF KEYWORD_SET(show_05p) THEN p05_on = 1b
IF KEYWORD_SET(show_10p) THEN p10_on = 1b
IF KEYWORD_SET(show_25p) THEN p25_on = 1b
tot_on         = TOTAL([p05_on[0],p10_on[0],p25_on[0]])
IF (tot_on[0] GT 1) THEN BEGIN
  ;;  Only allow one to be on
  IF (tot_on[0] GT 2) THEN BEGIN
    ;;  Force to default lower/upper bounds
    p05_on = 0b
    p10_on = 0b
  ENDIF ELSE BEGIN
    IF (p05_on[0] AND p10_on[0]) THEN p05_on = 0b ELSE p10_on = 0b
  ENDELSE
ENDIF
CASE 1 OF
  p05_on[0] : conlim = 90d-2
  p10_on[0] : conlim = 80d-2
  p25_on[0] : conlim = 50d-2
  ELSE      : BEGIN
    ;;  Should not happen but it did --> resort to defaults
    p05_on = 0b & p10_on = 0b & p25_on = 1b
    conlim = 50d-2
  END
ENDCASE
;;  Check [X,Y]LOG
IF KEYWORD_SET(xlog) THEN xlog_on = 1b
IF KEYWORD_SET(ylog) THEN ylog_on = 1b
;;  Check P_LENGTH
test           = (N_ELEMENTS(p_length) EQ 1) AND is_a_number(p_length,/NOMSSG)
IF (test[0]) THEN nlen = (p_length[0] < (nt[0]/def_len[0])) ELSE nlen = def_len[0]
nlen           = nlen[0] > def_len[0]             ;;  Make sure LENGTH is at least the default minimum
;;  Check P__SHIFT
test           = (N_ELEMENTS(p__shift) EQ 1) AND is_a_number(p__shift,/NOMSSG)
IF (test[0]) THEN nshft = (p__shift[0] < (nt[0]/def_off[0])) ELSE nshft = def_off[0]
nshft          = nshft[0] > def_off[0]            ;;  Make sure OFFSET is at least the default minimum

;;  Check T_LENGTH
test           = (N_ELEMENTS(t_length) EQ 1) AND is_a_number(t_length,/NOMSSG)
IF (test[0]) THEN BEGIN
  dx_tot         = ABS(xran[1] - xran[0])
  tlen           = (ABS(t_length[0]) < (dx_tot[0]/2L))
  mnmx_grid      = xran + [-1,1]*tlen[0]
  inds_on        = 0b
  time_on        = 1b
ENDIF
;;  Check T__SHIFT
test           = (N_ELEMENTS(t__shift) EQ 1) AND is_a_number(t__shift,/NOMSSG)
IF (test[0] AND time_on[0]) THEN BEGIN
  delt           = ABS(t__shift[0]) > (speri[0]/2d0)
  ;;  Define # of bins
  dx_tot         = ABS(mnmx_grid[1] - mnmx_grid[0])
  nbins          = FLOOR(dx_tot[0]/delt[0])
  IF (nbins[0] LE 0) THEN BEGIN
    ;;  Make sure NBINS ≥ 2
    nbins          = 2L
    delt           = dx_tot[0]/(1d0*nbins[0])
  ENDIF
  ;;  Define bin start/end points
  binMid         = LINDGEN(nbins[0])*delt[0] + (mnmx_grid[0] + 5d-1*tlen[0])
  bin_st         = binMid - (5d-1*tlen[0])
  bin_en         = binMid + (5d-1*tlen[0])
ENDIF
;;  Check XMID_PT
IF (is_a_number(xmid_pt,/NOMSSG))[0] THEN BEGIN
  ;;  Make sure user set correctly
  check   = (xmid_pt[0] GE xran[0]) AND (xmid_pt[0] LE xran[1])
  IF (test[0]) THEN BEGIN
    xmid__v = REPLICATE(xmid_pt[0],2L)
    xmid_on = 1b
    xmidcol = 150L
  ENDIF
ENDIF
;;  Check SMLINES
IF KEYWORD_SET(smlines) THEN smth_on = 1b
;;  Check SMWDTH
IF ((is_a_number(smwdth,/NOMSSG))[0] AND smth_on[0]) THEN BEGIN
  wdth     = (LONG(ABS(smwdth[0])) < (gd__x[0]/2L)) > 3L
  wdth_str = num2int_str(wdth[0],NUM_CHAR=5,/ZERO_PAD)
  wdth_suf = '_Smth'+wdth_str[0]+'pts'
  vers_ex  = ';;  Smoothed '+wdth_str[0]+' pts'
ENDIF ELSE BEGIN
  wdth_suf = ''
  vers_ex  = ''
ENDELSE
;;  Define suffixes to differentiate file names
IF (time_on[0]) THEN BEGIN
  ;;  Define suffix for partition and shift lengths
  plen_suf       = '_XWinLen'+STRMID(num2exp_str(tlen[0],NUM_CHAR=10,NUM_DEC=2),1L)+'Xunits'
  pshf_suf       = '_ShftLen'+STRMID(num2exp_str(delt[0],NUM_CHAR=10,NUM_DEC=2),1L)+'Xunits'
  xyoutsuf       = ';;  Binned by dX'
ENDIF ELSE BEGIN
  ;;  Define suffix for partition and shift lengths
  plen_suf       = '_PartLen'+num2int_str(nlen[0],NUM_CHAR=4,/ZERO_PAD)+'pts'
  pshf_suf       = '_ShftLen'+num2int_str(nshft[0],NUM_CHAR=4,/ZERO_PAD)+'pts'
  xyoutsuf       = ';;  Binned by indices'
ENDELSE
;;  Check YTICKS and YMINOR
IF KEYWORD_SET(yticks) THEN ytks_on = is_a_number(yticks,/NOMSSG) AND ((yticks[0] GT 0) AND (yticks[0] LT 15))
IF KEYWORD_SET(yminor) THEN ymin_on = is_a_number(yminor,/NOMSSG) AND ((yminor[0] GT 0) AND (yminor[0] LT 15))
;;----------------------------------------------------------------------------------------
;;  Define some plot stuff
;;----------------------------------------------------------------------------------------
tot_xcnt_out   = 'Total # X    [ALL]: '+(num2int_str(gd__x[0],NUM_CHAR=10,/ZERO_PAD))[0]
tot_xfnt_out   = 'Total # X [FINITE]: '+(num2int_str(gd_fx[0],NUM_CHAR=10,/ZERO_PAD))[0]
tot_ycnt_out   = 'Total # Y    [ALL]: '+(num2int_str(gd__y[0],NUM_CHAR=10,/ZERO_PAD))[0]
tot_yfnt_out   = 'Total # Y [FINITE]: '+(num2int_str(gd_fy[0],NUM_CHAR=10,/ZERO_PAD))[0]
tot_xout_str   = tot_xcnt_out[0]+',  '+tot_xfnt_out[0]
tot_yout_str   = tot_ycnt_out[0]+',  '+tot_yfnt_out[0]
CASE 1 OF
  p05_on[0] : BEGIN
    perc_lab = '05%/95% levels'
    perc_suf = '05to95_levels'
  END
  p10_on[0] : BEGIN
    perc_lab = '10%/90% levels'
    perc_suf = '10to90_levels'
  END
  p25_on[0] : BEGIN
    perc_lab = '25%/75% levels'
    perc_suf = '25to75_levels'
  END
  ELSE      : STOP  ;;  Should not happen --> debug
ENDCASE

CASE 1 OF
  avg_on[0] : BEGIN
    xyoutlab = 'Mean with '+perc_lab[0]+xyoutsuf[0]
    IF (save_on[0]) THEN fname    = fname[0]+'_mean_'+perc_suf[0]+plen_suf[0]+pshf_suf[0]+wdth_suf[0]
  END
  med_on[0] : BEGIN
    xyoutlab = 'Median with '+perc_lab[0]+xyoutsuf[0]
    IF (save_on[0]) THEN fname    = fname[0]+'_median_'+perc_suf[0]+plen_suf[0]+pshf_suf[0]+wdth_suf[0]
  END
ENDCASE
;;  Get version info
vers           = routine_version('plot_irreg_superposed_epoch_anal.pro')+vers_ex[0]+';;  '+perc_lab[0]
;;  Define Avg. or Med. line info
plot_col       = colr[2]
err__col       = colr[3]
xyoutcol       = plot_col[0]
;;----------------------------------------------------------------------------------------
;;  Partition data into regularized bins
;;----------------------------------------------------------------------------------------
IF (time_on[0]) THEN BEGIN
  ;;--------------------------------------------------------------------------------------
  ;;  Partition data by fractional XDATA
  ;;--------------------------------------------------------------------------------------
  part_t         = REPLICATE(d,nbins[0])            ;;  Partitioned XDATA
  part_y         = REPLICATE(d,nbins[0])            ;;  Array of data line points
  part_v         = REPLICATE(d,nbins[0],15L)        ;;  Array of one-variable stats and ??th and ??th percentiles
  part_p         = REPLICATE(d,nbins[0],2L)         ;;  Lower/Upper percentile defined by user
  dumb13         = REPLICATE(d,13L)
  dumb02         = REPLICATE(d,2L)
  ;;  Define X-Bin values
  part_t         = binMid
  FOR j=0L, nbins[0] - 1L DO BEGIN
    onevs          = dumb13
    onev0          = dumb13
    percs          = dumb02
    test           = ([f,1])[(xxf GE bin_st[j] AND xxf LE bin_en[j])]
    IF (test.IsNaN( )) THEN CONTINUE
    temp_v         = ((yyf*test)).FINITE()
    onev0          = calc_1var_stats(temp_v,/NAN,RANGE=yran,CONLIM=conlim[0],PERCENTILES=percs,/NOMSSG)
    IF (N_ELEMENTS(onev0) EQ N_ELEMENTS(onevs)) THEN onevs = onev0
    part_v[j,*]    = [onevs,percs]
    part_p[j,*]    = percs
    CASE 1 OF
      med_on[0] : part_y[j]   = onevs[3]
      avg_on[0] : part_y[j]   = onevs[2]
      ELSE      : STOP         ;;  Should not happen --> debug
    ENDCASE
  ENDFOR
ENDIF ELSE BEGIN
  ;;--------------------------------------------------------------------------------------
  ;;  Partition data by elements
  ;;    Note:  return value has [LL, DD, MM]-Elements where
  ;;             LL = # of elements in LENGTH
  ;;             DD = # of divisions = N/LL, where N = # of points in input array
  ;;             MM = 2 --> MM[*,0] = XDATA, MM[*,1] = YDATA
  ;;--------------------------------------------------------------------------------------
  partition_x    = partition_data(xxf,nlen[0],nshft[0],YY=yyf)
  ;;  Define parameters
  ndd            = N_ELEMENTS(partition_x[0,*,0])
  part_t         = REPLICATE(d,ndd[0])            ;;  Partitioned times
  part_y         = REPLICATE(d,ndd[0])            ;;  Array of data line points
  part_v         = REPLICATE(d,ndd[0],15L)        ;;  Array of one-variable stats and ??th and ??th percentiles
  part_p         = REPLICATE(d,ndd[0],2L)         ;;  Lower/Upper percentile defined by user
  dumb13         = REPLICATE(d,13L)
  dumb02         = REPLICATE(d,2L)
  FOR i=0L, ndd[0] - 1L DO BEGIN
    temp_t         = REFORM(partition_x[*,i,0])
    temp_v         = REFORM(partition_x[*,i,1])
    n_t            = N_ELEMENTS(temp_t)
    even_on        = ((n_t[0] MOD 2) EQ 0)
    good_nn        = (N_ELEMENTS(temp_t) GE 3)
    onevs          = dumb13
    percs          = dumb02
    IF (good_nn[0]) THEN BEGIN
      onevs = calc_1var_stats(temp_v,/NAN,RANGE=yran,CONLIM=conlim[0],PERCENTILES=percs,/NOMSSG)
    ENDIF ELSE onevs = dumb13
    IF (TOTAL(FINITE(onevs)) LT 4) THEN CONTINUE
    part_v[i,*]    = [onevs,percs]
;    part_v[i,*]    = onevs
    part_p[i,*]    = percs
    CASE 1 OF
      med_on[0] : BEGIN
        part_t[i]   = MEDIAN(temp_t,EVEN=even_on[0])
        part_y[i]   = onevs[3]
      END
      avg_on[0] : BEGIN
        part_t[i]   = MEAN(temp_t,/NAN)
        part_y[i]   = onevs[2]
      END
      ELSE      : STOP         ;;  Should not happen --> debug
    ENDCASE
  ENDFOR
ENDELSE
IF (smth_on[0]) THEN BEGIN
  ;;  Smooth the mean/median and percentile lines prior to plotting
  edge_zero      = 0b
  edge_wrap      = 0b
  temp           = SMOOTH(part_y,wdth[0],/NAN,EDGE_ZERO=edge_zero[0],EDGE_WRAP=edge_wrap[0],/EDGE_TRUNCATE,MISSING=d)
  part_y         = temp
  temp           = SMOOTH(part_p[*,0],wdth[0],/NAN,EDGE_ZERO=edge_zero[0],EDGE_WRAP=edge_wrap[0],/EDGE_TRUNCATE,MISSING=d)
  part_p[*,0]    = temp
  temp           = SMOOTH(part_p[*,1],wdth[0],/NAN,EDGE_ZERO=edge_zero[0],EDGE_WRAP=edge_wrap[0],/EDGE_TRUNCATE,MISSING=d)
  part_p[*,1]    = temp
ENDIF
;;----------------------------------------------------------------------------------------
;;  Open window
;;----------------------------------------------------------------------------------------
DEVICE,GET_SCREEN_SIZE=s_size
wsz            = s_size*8d-1
win_str        = {RETAIN:2,XSIZE:(wsz[0] < wsz[1]),YSIZE:(wsz[0] < wsz[1]),XPOS:20,YPOS:20}
lbw_window,WIND_N=windn[0],_EXTRA=win_str
;;----------------------------------------------------------------------------------------
;;  Setup plot limits structure
;;----------------------------------------------------------------------------------------
IF (xlog_on[0] OR ylog_on[0]) THEN use_pstr = def_lstr ELSE use_pstr = def_pstr
IF (xlog_on[0]) THEN use_pstr.XMINOR = 9L ELSE str_element,use_pstr,'XTICKS',8L,/ADD_REPLACE
IF (ylog_on[0]) THEN use_pstr.YMINOR = 9L ELSE str_element,use_pstr,'YTICKS',8L,/ADD_REPLACE
new_pstr       = {XRANGE:xran,YRANGE:yran,XTITLE:xttl[0],YTITLE:yttl[0],TITLE:ttle[0],$
                  XLOG:xlog_on[0],YLOG:ylog_on[0]}
extract_tags,use_pstr,new_pstr
;;  Check if user wants to override default YTICKS and YMINOR settings
IF (ytks_on[0]) THEN str_element,use_pstr,'YTICKS',yticks[0],/ADD_REPLACE
IF (ymin_on[0]) THEN str_element,use_pstr,'YMINOR',yminor[0],/ADD_REPLACE
;;----------------------------------------------------------------------------------------
;;  Define OUT_STRUC
;;----------------------------------------------------------------------------------------
out_struc      = {XVAL:part_t,YVAL:part_y,PVAL:part_p,ONEVSTATS:part_v,LIMITS:use_pstr,VERS:vers[0]}
;;----------------------------------------------------------------------------------------
;;  Plot the data
;;----------------------------------------------------------------------------------------
;;  Reset [X,Y]POSI
xposi          = xposi0[0]
yposi          = yposi0[0]
dypos          = dypos0[0]
chthick        = 1.5e0          ;;  Character line thickness
;;  Initialize plot window
!P.MULTI       = 0
WSET,windn[0]
WSHOW,windn[0]
;;  Initialize plot
PLOT,xxf,yyf,_EXTRA=use_pstr
  ;;  Plot data as little black dots
  OPLOT,xxf,yyf,PSYM=3L
  ;;  Overplot Avg. or Med. lines
  IF (psym_on[0]) THEN BEGIN
    OPLOT,part_t,part_y,PSYM=6L,COLOR=plot_col[0],THICK=thck[0]
    OPLOT,part_t,part_p[*,0],COLOR=err__col[0],THICK=ethk[0],LINESTYLE=0L
    OPLOT,part_t,part_p[*,1],COLOR=err__col[0],THICK=ethk[0],LINESTYLE=0L
    OPLOT,part_t,part_y,LINESTYLE=0L,COLOR=plot_col[0],THICK=thck[0]     ;;  Overplot line so it can be seen
  ENDIF ELSE BEGIN
    OPLOT,part_t,part_p[*,0],COLOR=err__col[0],THICK=ethk[0],LINESTYLE=0L
    OPLOT,part_t,part_p[*,1],COLOR=err__col[0],THICK=ethk[0],LINESTYLE=0L
    OPLOT,part_t,part_y,LINESTYLE=0L,COLOR=plot_col[0],THICK=thck[0]     ;;  Overplot line so it can be seen
  ENDELSE
  ;;  Overplot midpoint vertical line if user desires
  IF (xmid_on[0]) THEN BEGIN
    OPLOT,xmid__v,yran,COLOR=xmidcol[0],THICK=thck[0]
  ENDIF
  ;;  Output label
  XYOUTS,xposi[0],yposi[0],xyoutlab[0],COLOR=xyoutcol[0],_EXTRA=def_xystr
  ;;  Output relevant info
  xposi += dypos[0]
  XYOUTS,xposi[0],yposi[0],tot_xout_str[0],COLOR=colr[0],_EXTRA=def_xystr
  xposi += dypos[0]
  XYOUTS,xposi[0],yposi[0],tot_yout_str[0],COLOR=colr[0],_EXTRA=def_xystr
  ;;--------------------------------------------------------------------------------------
  ;;  Output version # and date produced
  ;;--------------------------------------------------------------------------------------
  XYOUTS,0.995,0.06,vers[0],CHARSIZE=.65,/NORMAL,ORIENTATION=90.,CHARTHICK=chthick[0]
;;----------------------------------------------------------------------------------------
;;  Save color-coded plot (if desired)
;;----------------------------------------------------------------------------------------
;;  Reset [X,Y]POSI
xposi          = xposi0[1]
yposi          = yposi0[0]
dypos          = dypos0[1]
IF (save_on[0]) THEN BEGIN
  !P.MULTI       = 0
  str_element,use_pstr,'CHARSIZE',1.05,/ADD_REPLACE
  popen,fname[0],_EXTRA=postruc
    chthick        = 3e0          ;;  Character line thickness
    ;;  Initialize plot
    PLOT,xxf,yyf,_EXTRA=use_pstr
      ;;  Plot data as little black dots
      OPLOT,xxf,yyf,PSYM=3L
      ;;  Overplot Avg. or Med. lines
      IF (psym_on[0]) THEN BEGIN
        OPLOT,part_t,part_y,PSYM=6L,COLOR=plot_col[0],THICK=thck[1]
        OPLOT,part_t,part_p[*,0],COLOR=err__col[0],THICK=ethk[0],LINESTYLE=0L
        OPLOT,part_t,part_p[*,1],COLOR=err__col[0],THICK=ethk[0],LINESTYLE=0L
        OPLOT,part_t,part_y,LINESTYLE=0L,COLOR=plot_col[0],THICK=thck[0]     ;;  Overplot line so it can be seen
      ENDIF ELSE BEGIN
        OPLOT,part_t,part_p[*,0],COLOR=err__col[0],THICK=ethk[1],LINESTYLE=0L
        OPLOT,part_t,part_p[*,1],COLOR=err__col[0],THICK=ethk[1],LINESTYLE=0L
        OPLOT,part_t,part_y,LINESTYLE=0L,COLOR=plot_col[0],THICK=thck[1]     ;;  Overplot line so it can be seen
      ENDELSE
      ;;  Overplot midpoint vertical line if user desires
      IF (xmid_on[0]) THEN BEGIN
        OPLOT,xmid__v,yran,COLOR=xmidcol[0],THICK=thck[1]
      ENDIF
      ;;  Output label
      XYOUTS,xposi[0],yposi[0],xyoutlab[0],COLOR=xyoutcol[0],_EXTRA=def_xystr
      ;;  Output relevant info
      xposi += dypos[0]
      XYOUTS,xposi[0],yposi[0],tot_xout_str[0],COLOR=colr[0],_EXTRA=def_xystr
      xposi += dypos[0]
      XYOUTS,xposi[0],yposi[0],tot_yout_str[0],COLOR=colr[0],_EXTRA=def_xystr
      ;;----------------------------------------------------------------------------------
      ;;  Output version # and date produced
      ;;----------------------------------------------------------------------------------
      XYOUTS,0.985,0.06,vers[0],CHARSIZE=.65,/NORMAL,ORIENTATION=90.,CHARTHICK=chthick[0]
  pclose
ENDIF
;;----------------------------------------------------------------------------------------
;;  Return to user
;;----------------------------------------------------------------------------------------

RETURN
END















