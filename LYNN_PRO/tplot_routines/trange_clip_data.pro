;+
;*****************************************************************************************
;
;  FUNCTION :   trange_clip_data.pro
;  PURPOSE  :   This routine finds the data points within a user defined time range from
;                 an input TPLOT structure and returns a TPLOT structure containing only
;                 the points constrained by TRANGE.  If an error occurs or the input
;                 format is incorrect, then the routine will return a scalar zero.  Thus,
;                 one can test for a successful completion based upon the type output
;                 matching an IDL structure.
;
;  CALLED BY:   
;               NA
;
;  INCLUDES:
;               NA
;
;  CALLS:
;               tplot_struct_format_test.pro
;               t_get_struc_unix.pro
;               struct_value.pro
;               is_a_number.pro
;               get_valid_trange.pro
;               extract_tags.pro
;
;  REQUIRES:    
;               1)  UMN Modified Wind/3DP IDL Libraries
;
;  INPUT:
;               DATA           :  Scalar [structure] defining a valid TPLOT structure
;                                   the the user wishes to clip (in time) in order to
;                                   examine only data between the limits defined by the
;                                   TRANGE keyword.  The minimum required structure tags
;                                   for a TPLOT structure are as follows:
;                                     X  :  [N]-Element array of Unix times
;                                     Y  :  [N,?]-Element array of data, where ? can be
;                                             up to two additional dimensions
;                                             [e.g., pitch-angle and energy bins]
;                                   additional potential tags are:
;                                     V  :  [N,E]-Element array of Y-Axis values
;                                             [e.g., energy bin values]
;                                   or in the special case of particle data:
;                                     V1 :  [N,E]-Element array of energy bin values
;                                     V2 :  [N,A]-Element array of pitch-angle bins
;                                   If V1 AND V2 are present, then Y must be an
;                                   [N,E,A]-element array.  If only V is present, then
;                                   Y must be an [N,E]-element array, where E is either
;                                   the 1st dimension of V [if 1D array] or the 2nd
;                                   dimension of V [if 2D array].
;                                   If the TSHIFT tag is present, the routine will assume
;                                   that TRANGE is a Unix time and DATA.X is seconds from
;                                   DATA.TSHIFT[0].
;
;                                   For MMS FPI distributions stored in TPLOT, there are
;                                   additional tags and the structure has the following
;                                   format:
;                                     X  :  [N]-Element array of Unix times
;                                     Y  :  [N,Z,L,E]-Element array of data values
;                                     V1 :  [N,Z]-Element array of azimuthal angle bin values [deg]
;                                     V2 :  [L]-Element array of poloidal angle bin values [deg]
;                                     V3 :  [N,E]-Element array of energy bin values [eV]
;
;  EXAMPLES:    
;               [calling sequence]
;               clipped = trange_clip_data(data [,TRANGE=trange] [,PRECISION=prec])
;
;               ;;  ****
;               ;;  Sample outputs using (very) incorrectly defined input
;               ;;  ****
;               nn             = 100L
;               ee             = 10L
;               aa             = 5L
;               trange         = [10d0,35d0]
;               test__bad      = trange_clip_data(struc,TRANGE=trange,PRECISION=prec)
;               % TRANGE_CLIP_DATA: User must supply an IDL TPLOT structure...
;               HELP,test__bad,/STRUC,OUTPUT=out
;               FOR j=0L, N_ELEMENTS(out) - 1L DO PRINT,';;',out[j]
;               ;;TEST__BAD       BYTE      =    0
;
;               x              = DINDGEN(nn)
;               y1d            = FLTARR(nn)
;               bad__struc     = {W:x,U:y1d}
;               test__bad      = trange_clip_data(bad__struc,TRANGE=trange,PRECISION=prec)
;               % TRANGE_CLIP_DATA: Incorrect input format:  DATA must be an IDL TPLOT structure
;               HELP,test__bad,/STRUC,OUTPUT=out
;               FOR j=0L, N_ELEMENTS(out) - 1L DO PRINT,';;',out[j]
;               ;;TEST__BAD       BYTE      =    0
;
;
;               ;;  ****
;               ;;  Sample outputs using somewhat correctly defined input structures
;               ;;  ****
;               nn             = 100L
;               ee             = 10L
;               aa             = 5L
;               ;;  Define some dummy arrays to check formatting tests
;               x              = DINDGEN(nn)
;               trange         = [10d0,35d0]         ;;  Should get elements 10-35
;               y2d            = FLTARR(nn,ee)
;               y3d            = FLTARR(nn,ee,aa)
;               v1g            = FLTARR(nn,ee)       ;;  Good V1 definition
;               v2g            = FLTARR(nn,aa)       ;;  Good V2 definition
;               v1b            = FLTARR(nn,7L)       ;;  Bad V1 definition
;               v2b            = FLTARR(nn,2L)       ;;  Bad V2 definition
;               good_struc     = {X:x,Y:y3d,V1:v1g,V2:v2g}
;               bad__struc     = {X:x,Y:y3d,V1:v1b,V2:v2b}
;               test_good      = trange_clip_data(good_struc,TRANGE=trange,PRECISION=prec)
;               test__bad      = trange_clip_data(bad__struc,TRANGE=trange,PRECISION=prec)
;               diff           = x[10L:35L] - test_good.X
;               PRINT,';;', MIN(diff,/NAN), MAX(diff,/NAN)
;               ;;       0.0000000       0.0000000
;               HELP,test_good,/STRUC,OUTPUT=out
;               FOR j=0L, N_ELEMENTS(out) - 1L DO PRINT,';;',out[j]
;               ;;** Structure <1635408>, 4 tags, length=6968, data length=6968, refs=1:
;               ;;   X               DOUBLE    Array[26]
;               ;;   Y               FLOAT     Array[26, 10, 5]
;               ;;   V1              FLOAT     Array[26, 10]
;               ;;   V2              FLOAT     Array[26, 5]
;               HELP,test__bad,/STRUC,OUTPUT=out
;               FOR j=0L, N_ELEMENTS(out) - 1L DO PRINT,';;',out[j]
;               ;;** Structure <1553928>, 2 tags, length=5408, data length=5408, refs=1:
;               ;;   X               DOUBLE    Array[26]
;               ;;   Y               FLOAT     Array[26, 10, 5]
;
;               vvg            = FLTARR(ee)          ;;  Good 1D V definition
;               vvb            = FLTARR(nn)          ;;  Bad 1D V definition
;               good_struc     = {X:x,Y:y2d,V:vvg}
;               bad__struc     = {X:x,Y:y2d,V:vvb}
;               test_good      = trange_clip_data(good_struc,TRANGE=trange,PRECISION=prec)
;               test__bad      = trange_clip_data(bad__struc,TRANGE=trange,PRECISION=prec)
;               HELP,test_good,/STRUC,OUTPUT=out
;               FOR j=0L, N_ELEMENTS(out) - 1L DO PRINT,';;',out[j]
;               ;;** Structure <1635968>, 3 tags, length=1288, data length=1288, refs=1:
;               ;;   X               DOUBLE    Array[26]
;               ;;   Y               FLOAT     Array[26, 10]
;               ;;   V               FLOAT     Array[10]
;               HELP,test__bad,/STRUC,OUTPUT=out
;               FOR j=0L, N_ELEMENTS(out) - 1L DO PRINT,';;',out[j]
;               ;;** Structure <300e2f8>, 2 tags, length=5408, data length=5408, refs=1:
;               ;;   X               DOUBLE    Array[26]
;               ;;   Y               FLOAT     Array[26, 10]
;
;               vvg            = FLTARR(nn,ee)       ;;  Good 2D V definition
;               vvb            = FLTARR(nn,7L)       ;;  Bad 2D V definition
;               good_struc     = {X:x,Y:y2d,V:vvg}
;               bad__struc     = {X:x,Y:y2d,V:vvb}
;               test_good      = trange_clip_data(good_struc,TRANGE=trange,PRECISION=prec)
;               test__bad      = trange_clip_data(bad__struc,TRANGE=trange,PRECISION=prec)
;               HELP,test_good,/STRUC,OUTPUT=out
;               FOR j=0L, N_ELEMENTS(out) - 1L DO PRINT,';;',out[j]
;               ;;** Structure <1552dd8>, 3 tags, length=2288, data length=2288, refs=1:
;               ;;   X               DOUBLE    Array[26]
;               ;;   Y               FLOAT     Array[26, 10]
;               ;;   V               FLOAT     Array[26, 10]
;               HELP,test__bad,/STRUC,OUTPUT=out
;               FOR j=0L, N_ELEMENTS(out) - 1L DO PRINT,';;',out[j]
;               ;;** Structure <16343c8>, 2 tags, length=1248, data length=1248, refs=1:
;               ;;   X               DOUBLE    Array[26]
;               ;;   Y               FLOAT     Array[26, 10]
;
;  KEYWORDS:    
;               TRANGE         :  [2]-Element [double] array specifying the Unix time
;                                   range for which to limit the data in DATA
;                                   [Default = prompted by get_valid_trange.pro]
;               PRECISION      :  Scalar [long] defining precision of the string output:
;                                   = -5  :  Year only
;                                   = -4  :  Year, month
;                                   = -3  :  Year, month, date
;                                   = -2  :  Year, month, date, hour
;                                   = -1  :  Year, month, date, hour, minute
;                                   = 0   :  Year, month, date, hour, minute, sec
;                                   = >0  :  fractional seconds
;                                   [Default = 0]
;
;   CHANGED:  1)  Updated Man. page and added a few more comments and
;                   now calls str_element.pro
;                                                                   [10/06/2015   v1.0.1]
;             2)  Updated Man. page
;                                                                   [11/10/2015   v1.0.2]
;             3)  Now uses new functionality of tplot_struct_format_test.pro for handling
;                   of V or V1 and V2 structure tags
;                   and no longer calls str_element.pro
;                                                                   [11/28/2015   v1.1.0]
;             4)  Cleaned up a bit
;                                                                   [11/28/2015   v1.1.1]
;             5)  Fixed a typo with test_vv logic variable testing
;                                                                   [03/22/2016   v1.1.2]
;             6)  Routine can now handle TSHIFT structure tag for TPLOT structures
;                                                                   [04/21/2016   v1.2.0]
;             7)  Cleaned up and now calls struct_value.pro and extract_tags.pro and
;                   now handles structures with DY tag and other time-independent tags
;                                                                   [06/15/2016   v1.3.0]
;             8)  Now allows for MMS FPI TPLOT structure distributions, i.e., 4D strucs
;                   and now calls t_get_struc_unix.pro
;                   and no longer calls str_element.pro
;                                                                   [07/12/2018   v1.3.1]
;
;   NOTES:      
;               1)  See also:  get_valid_trange.pro
;
;  REFERENCES:  
;               NA
;
;   CREATED:  10/05/2015
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  07/12/2018   v1.3.1
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

FUNCTION trange_clip_data,data,TRANGE=trange,PRECISION=prec

;;  Let IDL know that the following are functions
FORWARD_FUNCTION tplot_struct_format_test, is_a_number, get_valid_trange
;;----------------------------------------------------------------------------------------
;;  Define some defaults
;;----------------------------------------------------------------------------------------
f              = !VALUES.F_NAN
d              = !VALUES.D_NAN
;;  Dummy logic variables
test_vv        = 0b
test_vv_2d     = 0b
test_v1        = 0b
test_v2        = 0b
;;  Not extracted tags
excpt_tags     = ['X','Y','V','V1','V2','V3','DY','TSHIFT']
;;  Dummy error messages
no_inpt_msg    = 'User must supply an IDL TPLOT structure...'
baddfor_msg    = 'Incorrect input format:  DATA must be an IDL TPLOT structure'
baddinp_msg    = 'Incorrect input:  DATA must be a valid TPLOT structure with numeric times and data'
bad_tra_msg    = 'Could not define proper time range... Exiting without computation...'
nod_tra_msg    = 'No data within user specified time range... Exiting without computation...'
;;----------------------------------------------------------------------------------------
;;  Check input
;;----------------------------------------------------------------------------------------
test           = (N_PARAMS() LT 1) OR (SIZE(data,/TYPE) NE 8)
IF (test[0]) THEN BEGIN
  MESSAGE,no_inpt_msg,/INFORMATIONAL,/CONTINUE
  RETURN,0b
ENDIF
;;  Check if TPLOT structure
test           = tplot_struct_format_test(data,TEST__V=test__v,TEST_V1_V2=test_v1_v2,$
                                          TEST_DY=test_dy,TEST_V123=test_v123,/NOMSSG)
IF (test[0] EQ 0) THEN BEGIN
  MESSAGE,baddfor_msg,/INFORMATIONAL,/CONTINUE
  RETURN,0b
ENDIF
;;----------------------------------------------------------------------------------------
;;  Define parameters
;;----------------------------------------------------------------------------------------
nt             = N_TAGS(data)
unix           = t_get_struc_unix(data,TSHFT_ON=tshft_on)     ;;  [N]-Element array of Unix times
IF (tshft_on[0]) THEN BEGIN
  tshift         = struct_value(data,'TSHIFT',DEFAULT=0d0)
ENDIF ELSE BEGIN
  tshift         = 0d0
ENDELSE
time           = unix - tshift[0]  ;;  [N]-Element array of either Unix times (TSHFT_ON EQ FALSE) or seconds of day (TSHFT_ON EQ TRUE)
dats           = data.Y            ;;  [N [,M , L]]- or [N,Z,L,E]-Element array of data
szdt           = SIZE(time,/DIMENSIONS)
szdd           = SIZE(dats,/DIMENSIONS)
sznd           = SIZE(dats,/N_DIMENSIONS)
;;  Make sure data format is okay
test           = (szdt[0] NE szdd[0]) OR (is_a_number(time,/NOMSSG) EQ 0) OR $
                 (is_a_number(dats,/NOMSSG) EQ 0)
IF (test[0]) THEN BEGIN
  MESSAGE,baddinp_msg,/INFORMATIONAL,/CONTINUE
  RETURN,0b
ENDIF
;;----------------------------------------------------------------------------------------
;;  Check for other time-dependent structure tags
;;----------------------------------------------------------------------------------------
;;  Check for DY
IF (test_dy[0] GT 0) THEN BEGIN
  uny        = data.DY
  test_uy    = 1b
ENDIF ELSE test_uy = 0b

;;  Check for V
test_vv_2d     = (test__v[0] EQ 2)
IF (test__v[0] GT 0) THEN BEGIN
  vv         = data.V
  test_vv    = 1b         ;;  LBW  03/22/2016   v1.1.2
ENDIF ELSE test_vv = 0b
;;  Check for V1 and V2
v1_v2_on       = test_v1_v2[0]
IF (v1_v2_on[0]) THEN BEGIN
  ;;  Both V1 and V2 present --> define variables
  v1             = data.V1
  v2             = data.V2
ENDIF
;;  Check for V1, V2, and V3
v1v2v3_on      = test_v123[0]
IF (v1v2v3_on[0]) THEN BEGIN
  ;;  All V1, V2, and V3 present --> define variables
  v1             = data.V1
  v2             = data.V2
  v3             = data.V3
ENDIF
;;----------------------------------------------------------------------------------------
;;  Check keywords
;;----------------------------------------------------------------------------------------
;;  Check TRANGE
tra_struc      = get_valid_trange(TRANGE=trange,PRECISION=prec)
tra_unix       = tra_struc.UNIX_TRANGE
test           = (TOTAL(FINITE(tra_unix)) LT 2)
IF (test[0]) THEN BEGIN
  MESSAGE,bad_tra_msg,/INFORMATIONAL,/CONTINUE
  RETURN,0b
ENDIF
;;  Redefine TRANGE
tra_off        = tra_unix - tshift[0]  ;;  Remove TSHIFT (if present)
;IF (N_ELEMENTS(tshift) GT 0) THEN tra_off -= tshift[0]  ;;  Remove TSHIFT (if present)
trange         = tra_unix
;;----------------------------------------------------------------------------------------
;;  Determine which elements are within TRANGE
;;----------------------------------------------------------------------------------------
;;  Sort time stamps [just in case]
sp             = SORT(time)
tt             = time[sp]
test           = (tt LE tra_off[1]) AND (tt GE tra_off[0])
good           = WHERE(test,gd)
IF (gd EQ 0) THEN BEGIN
  ;;  No data between specified time range limits
  MESSAGE,nod_tra_msg,/INFORMATIONAL,/CONTINUE
  RETURN,0b
ENDIF
;;  Data found --> define output
xx             = tt[good]
sp2            = sp[good]         ;;  Define only the "good" sorted indices
CASE sznd[0] OF
  1    :  BEGIN
    yy = dats[sp2]          ;;  [N]-Element array
    IF (test_uy[0]) THEN dy = uny[sp2]
  END
  2    :  BEGIN
    yy = dats[sp2,*]        ;;  [N,M]-Element array
    IF (test_uy[0]) THEN dy = uny[sp2,*]
  END
  3    :  BEGIN
    yy = dats[sp2,*,*]      ;;  [N,M,L]-Element array
    IF (test_uy[0]) THEN dy = uny[sp2,*,*]
  END
  4    :  BEGIN
    yy = dats[sp2,*,*,*]      ;;  [N,Z,L,E]-Element array
    IF (test_uy[0]) THEN dy = uny[sp2,*,*,*]
  END
  ELSE : STOP  ;;  What did you do?  --> debug
ENDCASE
;;  Clean up to save space [important for MMS TPLOT structure inputs]
dats           = 0
uny            = 0
unix           = 0 & time = 0 & tt = 0
;;----------------------------------------------------------------------------------------
;;  Define output structure
;;----------------------------------------------------------------------------------------
;;  Extract remaining time-independent tags
extract_tags,extra,data,EXCEPT_TAGS=excpt_tags
IF (SIZE(extra,/TYPE) EQ 8) THEN extra_tags = TAG_NAMES(extra) ELSE extra_tags = 0
;;  Check for V[?] tags
check          = [test_vv[0],v1_v2_on[0],v1v2v3_on[0]]
gchck          = WHERE(check,gdchck)
out_tags       = excpt_tags[0L:1L]
IF (gdchck[0] GT 0) THEN BEGIN
  ;;--------------------------------------------------------------------------------------
  ;;  At least one V[?]-related tag is present
  ;;--------------------------------------------------------------------------------------
  CASE gchck[0] OF
    0L   :  BEGIN
      ;;----------------------------------------------------------------------------------
      ;;  V tag is present
      ;;----------------------------------------------------------------------------------
      IF (test_vv_2d[0]) THEN vvout = vv[sp2,*] ELSE vvout = vv
      ;;  Define structure
      IF (tshft_on[0]) THEN BEGIN
        ;;  Keep TSHIFT if present on input
        IF (test_uy[0]) THEN struc = {X:xx,Y:yy,V:vvout,TSHIFT:tshift[0],DY:dy} $
                        ELSE struc = {X:xx,Y:yy,V:vvout,TSHIFT:tshift[0]}
      ENDIF ELSE BEGIN
        IF (test_uy[0]) THEN struc = {X:xx,Y:yy,V:vvout,DY:dy}$
                        ELSE struc = {X:xx,Y:yy,V:vvout}
      ENDELSE
    END
    1L   :  BEGIN
      ;;----------------------------------------------------------------------------------
      ;;  Both V1 and V2 present and correctly formatted
      ;;----------------------------------------------------------------------------------
      v1out          = v1[sp2,*]
      v2out          = v2[sp2,*]
      ;;  Define structure
      IF (tshft_on[0]) THEN BEGIN
        ;;  Keep TSHIFT if present on input
        IF (test_uy[0]) THEN struc = {X:xx,Y:yy,V1:v1out,V2:v2out,TSHIFT:tshift[0],DY:dy} $
                        ELSE struc = {X:xx,Y:yy,V1:v1out,V2:v2out,TSHIFT:tshift[0]}
      ENDIF ELSE BEGIN
        IF (test_uy[0]) THEN struc = {X:xx,Y:yy,V1:v1out,V2:v2out,DY:dy} $
                        ELSE struc = {X:xx,Y:yy,V1:v1out,V2:v2out}
      ENDELSE
      
    END
    2L   :  BEGIN
      ;;----------------------------------------------------------------------------------
      ;;  All V1, V2, and V3 present --> define variables
      ;;----------------------------------------------------------------------------------
      v1out          = v1[sp2,*]
      v2out          = v2                 ;;  Poloidal angles are constant in time for MMS structures
      v3out          = v3[sp2,*]
      ;;  Define structure
      IF (tshft_on[0]) THEN BEGIN
        ;;  Keep TSHIFT if present on input
        IF (test_uy[0]) THEN struc = {X:xx,Y:yy,V1:v1out,V2:v2out,V3:v3out,TSHIFT:tshift[0],DY:dy} $
                        ELSE struc = {X:xx,Y:yy,V1:v1out,V2:v2out,V3:v3out,TSHIFT:tshift[0]}
      ENDIF ELSE BEGIN
        IF (test_uy[0]) THEN struc = {X:xx,Y:yy,V1:v1out,V2:v2out,V3:v3out,DY:dy} $
                        ELSE struc = {X:xx,Y:yy,V1:v1out,V2:v2out,V3:v3out}
      ENDELSE
    END
    ELSE :  STOP  ;;  ???
  ENDCASE
ENDIF ELSE BEGIN
  ;;--------------------------------------------------------------------------------------
  ;;  No V[?]-related tags present
  ;;--------------------------------------------------------------------------------------
  IF (tshft_on[0]) THEN BEGIN
    ;;  Keep TSHIFT if present on input
    IF (test_uy[0]) THEN struc = {X:xx,Y:yy,TSHIFT:tshift[0],DY:dy} $
                    ELSE struc = {X:xx,Y:yy,TSHIFT:tshift[0]}
  ENDIF ELSE BEGIN
    IF (test_uy[0]) THEN struc = {X:xx,Y:yy,DY:dy} $
                    ELSE struc = {X:xx,Y:yy}
  ENDELSE
ENDELSE
;;  Clean up to save space
yy             = 0
dy             = 0
xx             = 0 & vv = 0 & v1 = 0 & v2 = 0 & v3 = 0
vvout          = 0 & v1out = 0 & v2out = 0 & v3out = 0
good           = 0 & sp = 0 & sp2 = 0
;;  Add remaining time-independent tags to output structure
IF (SIZE(extra_tags,/TYPE) EQ 7) THEN extract_tags,struc,extra,TAGS=extra_tags
;;----------------------------------------------------------------------------------------
;;  Return to user
;;----------------------------------------------------------------------------------------

RETURN,struc
END
