;+
;*****************************************************************************************
;
;  PROCEDURE:   waves_tnr_rad_to_tplot.pro
;  PURPOSE  :   Plots the [TNR,RAD1,RAD2, or ALL of] WAVES receiver spectrogram data
;                 from the Wind spacecraft using TPLOT as an interface.
;
;  CALLED BY:   
;               NA
;
;  INCLUDES:
;               NA
;
;  CALLS:
;               get_valid_trange.pro
;               get_general_char_name.pro
;               is_a_number.pro
;               waves_get_ascii_file_wrapper.pro
;               store_data.pro
;
;  REQUIRES:    
;               1)  UMN Modified Wind/3DP IDL Libraries
;               2)  ASCII files found at:
;                     https://solar-radio.gsfc.nasa.gov/wind/data_products.html
;
;  INPUT:
;               NA
;
;  EXAMPLES:    
;               [calling sequence]
;               waves_tnr_rad_to_tplot [,DATE=date] [,FLOW=fl] [,FHIGH=fh] [,YSCL=yscl] $
;                                      [,TRANGE=trange] [,/NODCBLS] [,TDATE=tdate]
;
;               ;;  To send all the receivers to TPLOT...
;               fl        = 4.5    ;;  low frequency bound (kHz)
;               fh        = 13e3   ;;  high " "
;               yscl      = 'log'  ;;  frequency axis set to a logarithmic scale
;               waves_tnr_rad_to_tplot,DATE=date,FLOW=fl,FHIGH=fh,YSCL=yscl
;
;  KEYWORDS:    
;               DATE      :  Scalar [string] or array of the form:
;                              'MMDDYY' [MM=month, DD=day, YY=year]
;               FLOW      :  Scalar [float] frequency (kHz) that defines the low
;                              end of the frequency spectrum you're interested in
;               FHIGH     :  Scalar [float] frequency (kHz) that defines the high
;                              end of the frequency spectrum you're interested in
;               YSCL      :  Scalar [string] defining the Y-Axis scaling
;                              'lin'  :  plot frequencies on a linear scale
;                              'log'  :  plot frequencies on a logarithmic scale
;                              [Default = 'lin']
;               TRANGE    :  [2]-Element [Double] array specifying the time range from
;                              which the user desires to get data [Unix time]
;               NODCBLS   :  If set, program returns dynamic spectra in microvolts
;                              per root Hz instead of dB above background
;                              [Default = FALSE]
;               TDATE     :  Scalar [string] defining the date of interest of the form:
;                              'YYYY-MM-DD' [MM=month, DD=day, YYYY=year]
;
;   CHANGED:  1)  Fixed typo
;                                                                   [05/25/2010   v1.0.1]
;             2)  Added keyword:  NODCBLS
;                                                                   [10/11/2010   v1.1.0]
;             3)  Updated website location
;                                                                   [03/11/2011   v1.1.1]
;             4)  Updated man page and changed name to waves_tnr_rad_to_tplot.pro
;                   and now moved to ~/wind_3dp_pros/LYNN_PRO/ directory
;                   and now calls waves_get_ascii_file_wrapper.pro
;                                                                   [03/21/2013   v2.0.0]
;             5)  Updated Man. page and routine, no longer calls time_range_define.pro
;                   and now calls get_valid_trange.pro and get_general_char_name.pro and
;                   is_a_number.pro
;                   and now uses TDATE keyword in place of DATE keyword
;                                                                   [03/06/2019   v2.0.1]
;
;   NOTES:      
;               1)  See man-page of either waves_tnr_file_read.pro or
;                     waves_rad_file_read.pro for documentation of WAVES ASCII
;                     files
;               ==================================================================
;               = -Documentation on WAVES TNR, RAD1&2 ASCII file documentation   =
;               =   PROVIDED BY:  Michael L. Kaiser (Michael.kaiser@nasa.gov)    =
;               ==================================================================
;               2)  Be careful when using the NODCBLS keyword as there are often times
;                     when the background level in the ASCII files is set to 0e0 for
;                     RAD1 and RAD2.
;
;  REFERENCES:  
;               1)  Bougeret, J.-L., M.L. Kaiser, P.J. Kellogg, R. Manning, K. Goetz,
;                      S.J. Monson, N. Monge, L. Friel, C.A. Meetre, C. Perche,
;                      L. Sitruk, and S. Hoang (1995) "WAVES:  The Radio and Plasma
;                      Wave Investigation on the Wind Spacecraft," Space Sci. Rev.
;                      Vol. 71, pp. 231-263, doi:10.1007/BF00751331.
;
;   CREATED:  05/11/2010
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  03/06/2019   v2.0.1
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

PRO waves_tnr_rad_to_tplot,DATE=date,FLOW=fl0,FHIGH=fh0,YSCL=yscl0,TRANGE=trange, $
                           NODCBLS=nodcbls,TDATE=tdate

;;----------------------------------------------------------------------------------------
;;  Define Constants and dummy variables
;;----------------------------------------------------------------------------------------
f              = !VALUES.F_NAN
d              = !VALUES.D_NAN
;;  dummy error messages
nodatamssg     = 'No data found --> nothing will be sent to TPLOT!'
;;----------------------------------------------------------------------------------------
;;  Define some defaults
;;----------------------------------------------------------------------------------------
ylgg           = 0                                 ;;  Logic for YLOG keyword in PLOT
inv            = 0                                 ;;  *** Obsolete *** Logic for determining whether to invert data
ymin           = 10L                               ;;  Default number of Y-axis minor tick marks
poss_yscl      = ['lin','log']
min_flow       = 4d0
max_fhig       = 13.825d3
;;  Plotting defaults
ytun           = 'Hz'                              ;;  Base unit for Y-Axis data
yttp           = 'Frequency'                       ;;  Type of data plotted on Y-Axis
ytpr           = ['k','M']                         ;;  SI unit prefixes
;;  RAD2 defaults
rd2_yttl       = 'RAD2 '+yttp[0]+' ('+ytpr[1]+ytun[0]+')'
rd2_ytn        = ['3','5','7','9','11','13']
rd2_ytv        = [3000.,5000.,7000.,9000.,11000.,13000.]
;;  RAD1 defaults
rd1_yttl       = 'RAD1 '+yttp[0]+' ('+ytpr[0]+ytun[0]+')'
rd1_ytn        = ['100','200','500','750','1000']
rd1_ytv        = [100.,200.,500.,750.,1000.]
;;  TNR defaults
tnr_yttl       = 'TNR '+yttp[0]+' ('+ytpr[0]+ytun[0]+')'
tnr_ytn        = ['10','100']
tnr_ytv        = [10.,100.]
;;----------------------------------------------------------------------------------------
;;  Check keywords
;;----------------------------------------------------------------------------------------
;;  Check TDATE and TRANGE
time_ra        = get_valid_trange(TDATE=tdate,TRANGE=trange)
tra            = time_ra.UNIX_TRANGE
tdates         = time_ra.DATE_TRANGE        ;;  'YYYY-MM-DD'  e.g., '2009-07-13'
mdates         = STRMID(tdates,5,2)+STRMID(tdates,8,2)+STRMID(tdates,2,2)
mdate          = mdates[0]                  ;;  'MMDDYY'  e.g., '071309'
;;  Check YSCL
test_yscl      = KEYWORD_SET(yscl0) OR (SIZE(yscl0,/TYPE) EQ 7)
IF (test_yscl) THEN BEGIN
  outyscl = get_general_char_name(poss_yscl,CHARS=STRLOWCASE(yscl0[0]),DEF__NAME=poss_yscl[0])
  IF (SIZE(outyscl,/TYPE) NE 7) THEN yscl = poss_yscl[0] ELSE yscl = outyscl[0]
ENDIF ELSE BEGIN
  ;;  Use default
  yscl    = poss_yscl[0]
ENDELSE
CASE yscl[0] OF
  'lin' : BEGIN
    ;;  Use linear scale
    ylgg = 0
    ymin = 10L
  END
  'log' : BEGIN
    ;;  Use logarithmic scale
    ylgg = 1
    ymin = 9L
  END
  ELSE  : BEGIN
    ;;  Default:  Assume linear scale
    ylgg = 0
    ymin = 10L
  END
ENDCASE
;;  Check NODCBLS
test_nodb      = KEYWORD_SET(nodcbls) OR (N_ELEMENTS(nodcbls) EQ 1)
IF (test_nodb) THEN nodb = BYTE(nodcbls[0]) ELSE nodb = 0b
;;  Check FLOW and FHIGH
IF (is_a_number(fl0,/NOMSSG)) THEN fl = DOUBLE(fl0[0])
IF (is_a_number(fh0,/NOMSSG)) THEN fh = DOUBLE(fh0[0])
IF (is_a_number(fl,/NOMSSG) AND is_a_number(fh,/NOMSSG)) THEN BEGIN
  ;;  Make sure frequency ranges are appropriate
  fl = (fl[0] < fh[0]) > min_flow[0]
  fh = (fh[0] > fl[0]) < max_fhig[0]
ENDIF
;IF (test_yscl) THEN yscl = STRLOWCASE(yscl[0]) ELSE yscl   = ''
;time_ra        = time_range_define(DATE=date,TRANGE=trange)
;tra            = time_ra.TR_UNIX       ;;  Unix time range
;mdate          = time_ra.S_DATE_SE[0]  ;;  e.g., '040600'  [MMDDYY]
;;----------------------------------------------------------------------------------------
;;  Get WAVES data
;;----------------------------------------------------------------------------------------
struc          = waves_get_ascii_file_wrapper(DATE=date,FLOW=fl,FHIGH=fh,TRANGE=tra, $
                                              NODCBLS=nodb[0],TDATE=tdates[0])
IF (SIZE(struc,/TYPE) NE 8) THEN RETURN
dat            = struc.DATA
tnr_d          = dat.TNR
rd1_d          = dat.RAD1
rd2_d          = dat.RAD2
;;----------------------------------------------------------------------------------------
;;  Check data
;;----------------------------------------------------------------------------------------
test_tnr       = FINITE(tnr_d.Y) NE 0
test_rd1       = FINITE(rd1_d.Y) NE 0
test_rd2       = FINITE(rd2_d.Y) NE 0
good_tnr       = WHERE(test_tnr,gdtr)
good_rd1       = WHERE(test_rd1,gdr1)
good_rd2       = WHERE(test_rd2,gdr2)
test           = TOTAL([gdtr,gdr1,gdr2]) LT 1
IF (test[0]) THEN BEGIN
  ;;  No WAVES files were found
  MESSAGE,nodatamssg[0],/INFORMATIONAL,/CONTINUE
  RETURN
ENDIF
;;----------------------------------------------------------------------------------------
;;  Determine Y- and Z-Axis defaults
;;----------------------------------------------------------------------------------------
;CASE yscl[0] OF
;  'lin' : BEGIN
;    ;;  Use linear scale
;    ylgg = 0
;;    ytun = 'Hz'
;;    yttp = 'Frequency'
;;    ytpr = ['k','M']
;;    inv  = 0
;    ymin = 10L
;  END
;  'log' : BEGIN
;    ;;  Use logarithmic scale
;    ylgg = 1
;;    ytun = 'Hz'
;;    yttp = 'Frequency'
;;    ytpr = ['k','M']
;;    inv  = 0
;    ymin = 9L
;  END
;  ELSE  : BEGIN
;    ;;  Default:  Assume linear scale
;    ylgg = 0
;;    ytun = 'Hz'
;;    yttp = 'Frequency'
;;    ytpr = ['k','M']
;;    inv  = 0
;    ymin = 10L
;  END
;ENDCASE
CASE nodb[0] OF 
  1     :  zttl = 'microVolts Hz!U-1/2!N'
  0     :  zttl = 'dB above background'
  ELSE  :  zttl = 'dB above background'
ENDCASE
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;  Determine default plot structures and then send data to TPLOT
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;  WAVES/RAD2
rd2_ytm        = 5
rd2_yra        = [MIN(rd2_d.V,/NAN),MAX(rd2_d.V,/NAN)]
rd2_yts        = N_ELEMENTS(rd2_ytv) - 1L
dlim           = {YTITLE:rd2_yttl,YLOG:ylgg,ZLOG:1,YTICKNAME:rd2_ytn,YTICKV:rd2_ytv,   $
                  YTICKS:rd2_yts,MIN_VALUE:0.01,ZTITLE:zttl,ZTICKS:5}
lim            = {YSTYLE:1,YMINOR:ymin[0],PANEL_SIZE:2.0,XMINOR:5,XTICKLEN:0.04}
IF (gdr2 GT 0) THEN BEGIN
  ;;  Send RAD2 data to TPLOT
  store_data,'RAD2_'+mdate[0],DATA=rd2_d,DLIMIT=dlim,LIMIT=lim
ENDIF

;;  WAVES/RAD1
rd1_ytm        = 5
rd1_yra        = [MIN(rd1_d.V,/NAN),MAX(rd1_d.V,/NAN)]
rd1_yts        = N_ELEMENTS(rd1_ytv) - 1L
dlim           = {YTITLE:rd1_yttl,YLOG:ylgg,ZLOG:1,YTICKNAME:rd1_ytn,YTICKV:rd1_ytv,   $
                  YTICKS:rd1_yts,MIN_VALUE:0.01,ZTITLE:zttl,ZTICKS:5}
lim            = {YSTYLE:1,YMINOR:ymin[0],PANEL_SIZE:2.0,XMINOR:5,XTICKLEN:0.04}
IF (gdr1 GT 0) THEN BEGIN
  ;;  Send RAD1 data to TPLOT
  store_data,'RAD1_'+mdate[0],DATA=rd1_d,DLIMIT=dlim,LIMIT=lim
ENDIF

;;  WAVES/TNR
tnr_ytm        = 9
tnr_yra        = [MIN(tnr_d.V,/NAN), MAX(tnr_d.V,/NAN)]
tnr_yts        = 1
dlim           = {YTITLE:tnr_yttl,YLOG:ylgg,ZLOG:1,YTICKNAME:tnr_ytn,YTICKV:tnr_ytv,$
                  YTICKS:tnr_yts,MIN_VALUE:0.01,ZTITLE:zttl,ZTICKS:5}
lim            = {YSTYLE:1,YMINOR:ymin[0],PANEL_SIZE:2.0,XMINOR:5,XTICKLEN:0.04}
IF (gdtr GT 0) THEN BEGIN
  ;;  Send TNR data to TPLOT
  store_data,'TNR_'+mdate[0],DATA=tnr_d,DLIMIT=dlim,LIMIT=lim
ENDIF
;;----------------------------------------------------------------------------------------
;;  Return to user
;;----------------------------------------------------------------------------------------

RETURN
END
