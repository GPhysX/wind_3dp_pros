;+
;*****************************************************************************************
;
;  FUNCTION :   format_number_2_string.pro
;  PURPOSE  :   This routine converts an input number to a string with a user defined
;                 format.
;
;  CALLED BY:   
;               NA
;
;  CALLS:
;               is_a_number.pro
;               format_number_2_string.pro
;               sign.pro
;
;  REQUIRES:    
;               1)  UMN Modified Wind/3DP IDL Libraries
;
;  INPUT:
;               NUMBERS  :  [N]-Element array [int/long/float/double] of values of
;                             numeric type
;
;  EXAMPLES:    
;               ;;*************************************************
;               ;;  Float-like input
;               ;;*************************************************
;               IDL> numbers = [1.23d-10,1.7,-1d10,1.83d25,1d35]
;               IDL> PRINT, TRANSPOSE(format_number_2_string(numbers,NV=10,ND=4,NEXP=10))
;               1.2300E-10
;               1.7000
;               -1.0000E+10
;               1.8300E+25
;               1.0000E+35
;
;               IDL> PRINT, TRANSPOSE(format_number_2_string(numbers,NV=5,ND=2,NEXP=10))
;               1.23E-10
;               1.70
;               -1.00E+10
;               1.83E+25
;               1.00E+35
;
;               IDL> PRINT, TRANSPOSE(format_number_2_string(numbers,NV=24,ND=13,NEXP=13))
;               0.0000000001230
;               1.7000000000000
;               -1.0000000000000E+10
;               1.8300000000000E+25
;               1.0000000000000E+35
;
;               IDL> PRINT, TRANSPOSE(format_number_2_string(numbers,NV=24,ND=0,NEXP=0))
;               1E-10
;               2E+00
;               -1E+10
;               2E+25
;               1E+35
;
;               ;;*************************************************
;               ;;  Integer-like input
;               ;;*************************************************
;               IDL> num2 = [10000LL,100000000000LL,-2131313LL,1LL]
;               IDL> PRINT, TRANSPOSE(format_number_2_string(num2,NV=10,ND=4,NEXP=10))
;               10000
;               100000000000
;               -2131313
;               0001
;
;               IDL> PRINT, TRANSPOSE(format_number_2_string(num2,NV=20,ND=4,NEXP=3))
;               1.0000E+04
;               1.0000E+11
;               -2.1313E+06
;               0001
;
;               IDL> PRINT, TRANSPOSE(format_number_2_string(num2,NV=20,ND=0,NEXP=3))
;               1E+04
;               1E+11
;               -2E+06
;               1
;
;               ;;*************************************************
;               ;;  Complex input
;               ;;*************************************************
;               IDL> num3 = COMPLEX(numbers,ALOG(ABS(numbers)))
;               IDL> PRINT, TRANSPOSE(format_number_2_string(num3,NV=10,ND=4,NEXP=10))
;               ( 1.2300E-10, -22.8188)
;               ( 1.7000, 0.5306)
;               ( -1.0000E+10, 23.0259)
;               ( 1.8300E+25, 58.1689)
;               ( 1.0000E+35, 80.5905)
;
;               IDL> PRINT, TRANSPOSE(format_number_2_string(num3,NV=20,ND=2,NEXP=3))
;               ( 1.23E-10, -22.82)
;               ( 1.70, 0.53)
;               ( -1.00E+10, 23.03)
;               ( 1.83E+25, 58.17)
;               ( 1.00E+35, 80.59)
;
;  KEYWORDS:    
;               NV       :  Scalar [int/long] defining the total # of character digits
;                             to include in the output
;                             [Default = 15 (unless value is larger)]
;               ND       :  Scalar [int/long] defining the # of character digits
;                             to include after the decimal place (only matters for
;                             float/double type inputs
;                             [Default = 2]
;               NEXP     :  Scalar [int/long] defining the maximum base-10 logarithmic
;                             exponent to allow before converting the output to an
;                             exponential format.  Meaning, if ALOG10(NUMBERS) > NEXP,
;                             then those numbers will be converted to exponential form.
;                                       { 1  for  float/double input types
;                             Default = {
;                                       {24  for  integer-like input types
;
;   CHANGED:  1)  Finished writing routine and cleaned up
;                                                                  [04/29/2015   v1.0.0]
;             2)  Fixed a bug when ND=1 that forced output to use E format
;                                                                  [06/30/2015   v1.0.1]
;
;   NOTES:      
;               1)  If ND is too large relative to NV, then NV will be increased to
;                     force all output to have ND decimal places
;               2)  For integer-like inputs, if we define NSL[i] = STRLEN(NUMBERS[i]) and
;                     L10[i] = ALOG10(ABS(NUMBERS[i])), then if the following holds
;                       (L10[i] < NEXP) = TRUE
;                       (NSL[i] > ND)   = TRUE
;                     then the i-th output will have the format:  '(I'NSL[i].NSL[i]')'
;
;  REFERENCES:  
;               NA
;
;   CREATED:  04/29/2015
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  06/30/2015   v1.0.1
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

FUNCTION format_number_2_string,numbers,NV=nv,ND=nd,NEXP=nexp

;;  Let IDL know that the following are functions
FORWARD_FUNCTION is_a_number, sign
;;----------------------------------------------------------------------------------------
;;  Constants/Defaults
;;----------------------------------------------------------------------------------------
f              = !VALUES.F_NAN
d              = !VALUES.D_NAN
is_int_vals    = [1,2,3,12,13,14,15]     ;;  Type codes for all integer-like numbers
is_fdc_vals    = [4,5,6,9]               ;;  Type codes for float/double numbers
is_rel_vals    = [4,5]
is_img_vals    = [6,9]
def_nv         = 15L                     ;;  Default # of numeric characters
def_nd         = 2L                      ;;  Default # of decimal places
def_nes        = [1L,24L]                ;;  Default NEXP values for [float,integer]-type inputs
min_nv         = 6L                      ;;  Minimum # for NV input for float-type inputs
max_nv         = 200L
geif_str       = ['G','E','I','F']
geif_form      = '('+geif_str+')'
plus_min_str   = ['-','+']
;;----------------------------------------------------------------------------------------
;;  Check input
;;----------------------------------------------------------------------------------------
test           = (is_a_number(numbers,/NOMSSG) EQ 0) OR (N_ELEMENTS(numbers) EQ 0)
IF (test) THEN RETURN,0b
;;----------------------------------------------------------------------------------------
;;  Determine the maximum number of characters in the result
;;----------------------------------------------------------------------------------------
nums           = REFORM(numbers)
nn             = N_ELEMENTS(nums)
type           = SIZE(nums,/TYPE)
test_int       = (TOTAL(type[0] EQ is_int_vals) EQ 1)   ;;  TRUE  -->  Input is integer-like [ Max allowed input = 18446744073709551615ULL ]
test_fdc       = (TOTAL(type[0] EQ is_fdc_vals) EQ 1)   ;;  TRUE  -->  Input is float-like
test_rel       = (TOTAL(type[0] EQ is_rel_vals) EQ 1)   ;;  TRUE  -->  Input is float-like and real
test_img       = (TOTAL(type[0] EQ is_img_vals) EQ 1)   ;;  TRUE  -->  Input is float-like and complex
;;  Define the default Ne value
def_ne         = def_nes[test_int[0]]
mx_abs_val     = MAX(ABS(nums),/NAN)
;IF (test_int) THEN sform = gei_form[2] ELSE sform = '(G200)'
IF (test_int) THEN sform = geif_form[2] ELSE sform = '(G200)'
mx_av_str      = STRTRIM(STRING(mx_abs_val[0],FORMAT=sform[0]),2L)
;;----------------------------------------------------------------------------------------
;;  Check keywords
;;----------------------------------------------------------------------------------------
;;  Check NV
test           = (N_ELEMENTS(nv) EQ 1) AND (is_a_number(nv,/NOMSSG))
IF (test[0]) THEN BEGIN
  ;;  NV set --> check format
  IF (nv[0] GT 1) THEN tnv = (LONG(nv[0]) > min_nv[0]) ELSE tnv = def_nv[0]
ENDIF ELSE BEGIN
  ;;  NV not set --> use default
  tnv = def_nv[0]
ENDELSE
;;  Check NEXP
test           = (N_ELEMENTS(nexp) EQ 1) AND (is_a_number(nexp,/NOMSSG))
IF (test[0]) THEN tne = (LONG(nexp[0]) > 0L) ELSE tne = def_ne[0] > (tnv[0] + 1L)
;;  Check ND
test           = (N_ELEMENTS(nd) EQ 1) AND (is_a_number(nd,/NOMSSG))
IF (test[0]) THEN tnd = (LONG(nd[0]) > (-1)) ELSE tnd = def_nd[0]
;;  Make sure NV is not too small
IF (test_int) THEN tnv = (tnv[0] > tnd[0]) ELSE tnv = (tnv[0] > (tnd[0] + 5L))
IF (tnd[0] LT 1) THEN find_dec = 1b ELSE find_dec = 0b    ;;  Logic to determine whether to find decimal place
;;  Define maximum negative exponent allowed for float/double
;;  LBW III  06/30/2015   v1.0.1
;neg_tne        = (tnd[0] - 1) > 0
IF (tnd[0] GT 1) THEN neg_tne = ((tnd[0] - 1L) > 0L) ELSE neg_tne = (tnd[0] > 0L)
;;  Convert keyword inputs to string formats
tne_str        = STRTRIM(STRING(tne[0],FORMAT=geif_form[2]),2L)
tnv_str        = STRTRIM(STRING(tnv[0],FORMAT=geif_form[2]),2L)
tnd_str        = STRTRIM(STRING(tnd[0],FORMAT=geif_form[2]),2L)
;;  Define exponent cases
tnv_e_str      = STRTRIM(STRING((tnv[0] + 1L),FORMAT=geif_form[2]),2L)
tnd_e_str      = tnd_str[0]
;;----------------------------------------------------------------------------------------
;;  Define format statements
;;----------------------------------------------------------------------------------------
dumb_type_out  = REPLICATE('',nn)
out_form       = REPLICATE('',nn)
IF (test_fdc AND test_rel) THEN BEGIN
  ;;--------------------------------------------------------------------------------------
  ;;  Real float/double type
  ;;--------------------------------------------------------------------------------------
  ;;  Initialize format type and statements
  dumb_type_out  = REPLICATE(geif_str[3],nn)
  out_form       = '('+dumb_type_out+tnv_str[0]+'.'+tnd_str[0]+')'
  ;;  Check to see if any elements exceed the user defined allowed values without resorting to exponent format
  test_exp       = (ABS(ALOG10(ABS(nums))) GT tne[0])
  test_big       = ( (ABS(ALOG10(ABS(nums))) + 1 + tnd[0]) GE tnv[0] ) OR (ALOG10(ABS(nums)) LT -1*neg_tne[0])
  yes_exp        = WHERE(test_exp,y_exp,COMPLEMENT=no__exp,NCOMPLEMENT=n_exp)
  yes_big        = WHERE(test_big,y_big,COMPLEMENT=no__big,NCOMPLEMENT=n_big)
  ;;  Define the format statements
  IF (y_exp GT 0 OR y_big GT 0) THEN BEGIN
    ;;  Some values exceed NEXP or NV limit
    IF (y_exp GT 0 AND y_big GT 0) THEN BEGIN
      yes_out = [yes_exp,yes_big]
    ENDIF ELSE BEGIN
      IF (y_exp GT 0) THEN yes_out = yes_exp ELSE yes_out = yes_big
    ENDELSE
    ;;  Only alter "bad" numbers
    y_out   = N_ELEMENTS(yes_out)
    dumb_type_out[yes_out] = geif_str[1]
    out_form[yes_out]      = '('+dumb_type_out[yes_out]+tnv_e_str[0]+'.'+tnd_e_str[0]+')'
  ENDIF ELSE BEGIN
    ;;  Only one format statement
    out_form       = out_form[0]
  ENDELSE
ENDIF ELSE BEGIN
  ;;--------------------------------------------------------------------------------------
  ;;  Integer or complext type
  ;;--------------------------------------------------------------------------------------
  IF (test_int) THEN BEGIN
    ;;------------------------------------------------------------------------------------
    ;;  Integer-like
    ;;------------------------------------------------------------------------------------
    ;;  Initialize format type
    dumb_type_out  = REPLICATE(geif_str[2],nn)
    out_form       = '('+dumb_type_out+tnv_str[0]+'.'+tnd_str[0]+')'
    ;;  Integer-like --> define the minimum length for each
    min_nv_i       = STRLEN(STRTRIM(STRING(nums,FORMAT=sform[0]),2L))
    min_nd_i       = min_nv_i
    ;;  Check for negative values --> need to subtract +1 from decimal widths
    neg_nums       = WHERE(nums LT 0,neg)
    IF (neg GT 0) THEN min_nd_i[neg_nums] -= 1L
    ;;  Convert lengths to strings
    min_nv_i_str   = STRTRIM(STRING(min_nv_i,FORMAT=geif_form[2]),2L)
    min_nd_i_str   = STRTRIM(STRING(min_nd_i,FORMAT=geif_form[2]),2L)
    ;;  Check to see if any elements exceed the user defined allowed values without resorting to exponent format
    test_exp       = (ABS(ALOG10(ABS(DOUBLE(nums)))) GT tne[0])
    test_big       = (min_nd_i GT tnv[0])
    yes_exp        = WHERE(test_exp,y_exp,COMPLEMENT=no__exp,NCOMPLEMENT=n_exp)
    yes_big        = WHERE(test_big,y_big,COMPLEMENT=no__big,NCOMPLEMENT=n_big)
    IF (y_exp GT 0 OR y_big GT 0) THEN BEGIN
      ;;  Some values exceed exponent limit
      IF (y_exp GT 0) THEN BEGIN
        yes_out = yes_exp
        ;;  Only alter "bad" numbers
        y_out   = N_ELEMENTS(yes_out)
        dumb_type_out[yes_out] = geif_str[1]
        out_form[yes_out]      = '('+dumb_type_out[yes_out]+tnv_e_str[0]+'.'+tnd_e_str[0]+')'
      ENDIF
      IF (y_big GT 0) THEN BEGIN
        yes_out = yes_big
        dumb_type_out[yes_out] = geif_str[2]
        out_form[yes_out]      = '('+dumb_type_out[yes_out]+min_nv_i_str[yes_out]+'.'+min_nd_i_str[yes_out]+')'
      ENDIF
    ENDIF ELSE BEGIN
      ;;  No values exceed NEXP or NV limits
      test           = (N_ELEMENTS(UNIQ(min_nv_i,SORT(min_nv_i))) EQ 1)
      IF (test) THEN BEGIN
        ;;  Only one format statement --> All inputs have the same number of characters
        out_form       = '('+geif_str[2]+min_nv_i_str[0]+'.'+min_nd_i_str[0]+')'
      ENDIF ELSE BEGIN
        ;;  Multiple formats, but one format type
        out_form = '('+geif_str[2]+min_nv_i_str+'.'+min_nd_i_str+')'
      ENDELSE
    ENDELSE
  ENDIF ELSE BEGIN
    IF (test_img) THEN BEGIN
      ;;----------------------------------------------------------------------------------
      ;;  Complex input --> get real and imaginary parts then re-call format_number_2_string.pro
      ;;----------------------------------------------------------------------------------
      r_part = REAL_PART(nums)
      i_part = IMAGINARY(nums)
      re_out = format_number_2_string(r_part,NV=nv,ND=nd,NEXP=nexp)
      im_out = format_number_2_string(i_part,NV=nv,ND=nd,NEXP=nexp)
      ;;  Combine to form output
      s_out  = '( '+re_out+', '+im_out+')'
      RETURN,s_out
    ENDIF ELSE STOP     ;;  Not sure how this happened --> debug
  ENDELSE
ENDELSE
;;----------------------------------------------------------------------------------------
;;  If float --> define sign and take absolute value
;;----------------------------------------------------------------------------------------
IF (test_fdc) THEN BEGIN
  ss    = sign(nums) EQ 1
  s_pre = plus_min_str[ss]
  n_out = ABS(nums)
  neg_n = WHERE(nums LT 0,ng_n)
ENDIF ELSE BEGIN
  s_pre = REPLICATE('',nn)
  n_out = nums
  ng_n  = 0
ENDELSE
;;----------------------------------------------------------------------------------------
;;  Define string outputs
;;----------------------------------------------------------------------------------------
n_oform        = N_ELEMENTS(out_form)
IF (n_oform EQ nn) THEN BEGIN
  ;;  Multiple output formats
  s_out          = REPLICATE('',nn)
  FOR j=0L, nn[0] - 1L DO BEGIN
    s_out[j] = STRTRIM(STRING(n_out[j],FORMAT=out_form[j]),2L)
  ENDFOR
ENDIF ELSE BEGIN
  ;;  Only one output formats
  s_out          = STRTRIM(STRING(n_out,FORMAT=out_form[0]),2L)
ENDELSE
;;  Check if '-' needs to be added
IF (ng_n GT 0) THEN s_out[neg_n] = s_pre[neg_n]+s_out[neg_n]
;;----------------------------------------------------------------------------------------
;;  Remove decimal place if ND = 0 on input
;;----------------------------------------------------------------------------------------
IF (tnd[0] EQ 0) THEN BEGIN
  ;;  User wishes to remove decimal points
  dp_posi = STRPOS(s_out,'.')
  good_dp = WHERE(dp_posi GE 0,gd_dp)
  IF (gd_dp[0] GT 0) THEN BEGIN
    ;;  decimal points found --> remove
    s_bef = REPLICATE('',gd_dp[0])
    s_aft = REPLICATE('',gd_dp[0])
    FOR j=0L, gd_dp[0] - 1L DO BEGIN
      k        = good_dp[j]
      s_bef[j] = STRMID(s_out[k],0L,dp_posi[k])
      s_aft[j] = STRMID(s_out[k],dp_posi[k] + 1L)
    ENDFOR
    ;;  Remove
    s_out[good_dp] = s_bef+s_aft
  ENDIF
ENDIF
;;----------------------------------------------------------------------------------------
;;  Return to user
;;----------------------------------------------------------------------------------------

RETURN,s_out
END
