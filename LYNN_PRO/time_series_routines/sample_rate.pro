;+
;*****************************************************************************************
;
;  FUNCTION :   sample_rate.pro
;  PURPOSE  :   Determines the sample rate of an input time series of data with the
;                 ability to set gap thresholds to avoid including them in the
;                 calculation.
;
;  CALLED BY:   
;               NA
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
;               TIME         :  [N]-Element array of time stamps [s] associated with
;                                 a time series for which the user is interested in
;                                 determining the sample rate
;
;  EXAMPLES:    
;               [calling sequence]
;               srate = sample_rate(time [,GAP_THRESH=gap_thresh] [,/AVERAGE]         $
;                                        [,OUT_MED_AVG=out_med_avg]                   )
;
;  KEYWORDS:    
;               GAP_THRESH   :  Scalar [numeric] defining the maximum data gap [s]
;                                 allowed in the calculation
;                                 [Default = MAX(TIME) - MIN(TIME)]
;               AVERAGE      :  If set, routine returns the scalar average sample rate
;                                 [Default = 0, which returns an array of sample rates]
;               OUT_MED_AVG  :  Set to a named variable to return the median and average
;                                 values of the sample rate if the user wants all values
;                                 as well
;
;   CHANGED:  1)  Changed algorithm slightly to help avoid some special issues and
;                   added keyword:  OUT_MED_AVG
;                                                                   [07/26/2013   v1.1.0]
;             2)  Optimize a little to reduce wasted computations and
;                   updated Man. page and now calls is_a_number.pro
;                                                                   [12/01/2017   v1.1.1]
;
;   NOTES:      
;               1)  The output is the sample rate in [# samples per unit time]
;               2)  If GAP_THRESH is set too small, then the returned result is a NaN
;
;  REFERENCES:  
;               NA
;
;   CREATED:  03/28/2012
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  12/01/2017   v1.1.1
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

FUNCTION sample_rate,time,GAP_THRESH=gap_thresh,AVERAGE=average,OUT_MED_AVG=medavg

;;----------------------------------------------------------------------------------------
;;  Define dummy variables
;;----------------------------------------------------------------------------------------
f              = !VALUES.F_NAN
d              = !VALUES.D_NAN
medavg         = [d,d]
;;----------------------------------------------------------------------------------------
;;  Check input
;;----------------------------------------------------------------------------------------
IF (N_PARAMS() NE 1) THEN RETURN,0b       ;;  User did not input anything
test           = (is_a_number(time[0],/NOMSSG) EQ 0) OR (N_ELEMENTS(time) LT 3)
IF (test[0]) THEN RETURN,0b               ;;  Bad input
;;----------------------------------------------------------------------------------------
;;  Define relevant parameters
;;----------------------------------------------------------------------------------------
tt             = REFORM(time)
nt             = N_ELEMENTS(tt)
;;  Sort input just in case
sp             = SORT(tt)
;tt             = tt[sp]
tt             = TEMPORARY(tt[sp])
;;  Define the total time between the first and last data point
trange         = MAX(tt,/NAN) - MIN(tt,/NAN)
;;  Define shifted difference
lower          = LINDGEN(nt[0] - 1L)
upper          = lower + 1L
sh_diff        = [d,(tt[upper] - tt[lower])]
;;----------------------------------------------------------------------------------------
;;  Determine the maximum allowable gap and remove "bad" values
;;----------------------------------------------------------------------------------------
test           = (is_a_number(gap_thresh,/NOMSSG) EQ 0) OR (N_ELEMENTS(gap_thresh) LT 1)
;IF (N_ELEMENTS(gap_thresh) EQ 0) THEN mx_gap = trange[0] ELSE mx_gap = gap_thresh[0]
IF (test[0]) THEN mx_gap = trange[0] ELSE mx_gap = gap_thresh[0]
bad            = WHERE(ABS(sh_diff) GT mx_gap[0] OR ABS(sh_diff) EQ 0,bd,COMPLEMENT=good,NCOMPLEMENT=gd)
IF (bd[0] GT 0 AND bd[0] LT nt[0]) THEN BEGIN
  ;;  Not all are bad
  sh_diff[bad] = d
ENDIF ELSE BEGIN
  IF (bd[0] EQ nt[0]) THEN RETURN,d      ;;  All are bad --> Return NaN
ENDELSE
;;----------------------------------------------------------------------------------------
;;  Check for outliers and remove if necessary
;;----------------------------------------------------------------------------------------
avg_dt         = MEAN(sh_diff,/NAN,/DOUBLE)
med_dt         = MEDIAN(sh_diff,/DOUBLE)
top            = ABS(avg_dt[0]) > ABS(med_dt[0])
bot            = ABS(avg_dt[0]) < ABS(med_dt[0])
;;  Make sure there is not a significant difference between Avg. and Med.
ratio          = ABS(top[0]/bot[0])*1d1
test           = (ratio[0] GE 1) AND (ABS(avg_dt[0]) NE ABS(med_dt[0]))  ;;  If true, then start loop to eliminate outliers
jj             = 0L
IF (test[0]) THEN BEGIN
  ;;  There are large gaps causing bad sample rate estimates
  ;;    --> Limit "good" intervals to ±3 sigma
  std_dt   = STDDEV(sh_diff,/NAN,/DOUBLE)
  tb       = avg_dt[0] + std_dt[0]*3d0*[-1d0,1d0]
  ;;  Check for outliers
  temp     = ((sh_diff GE tb[1]) OR (sh_diff LE tb[0]))
  bad      = WHERE(temp,bd)
  IF (bd[0] GT 0 AND bd[0] LT nt[0]) THEN BEGIN
    ;;  Remove outliers
    sh_diff[bad] = d
    avg_dt       = MEAN(sh_diff,/NAN,/DOUBLE)
    med_dt       = MEDIAN(sh_diff,/DOUBLE)
  ENDIF
ENDIF
;;----------------------------------------------------------------------------------------
;;  Calculate the sample rate
;;----------------------------------------------------------------------------------------
samrates       = 1d0/sh_diff
avgsmrt        = MEAN(samrates,/NAN,/DOUBLE)
medsmrt        = MEDIAN(samrates,/DOUBLE)
IF KEYWORD_SET(average) THEN sam_rate = avgsmrt[0] ELSE sam_rate = samrates
medavg         = [medsmrt[0],avgsmrt[0]]
;;----------------------------------------------------------------------------------------
;;  Return to user
;;----------------------------------------------------------------------------------------

RETURN,sam_rate
END

