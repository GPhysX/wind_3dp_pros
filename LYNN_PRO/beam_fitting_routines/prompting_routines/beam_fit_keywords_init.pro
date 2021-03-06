;+
;*****************************************************************************************
;
;  FUNCTION :   beam_fit_get_inst_pref.pro
;  PURPOSE  :   This routine returns the string associated with the specific instrument
;                 that produced DAT.
;
;  CALLED BY:   
;               beam_fit_keywords_init.pro
;
;  CALLS:
;               test_wind_vs_themis_esa_struct.pro
;               dat_3dp_str_names.pro
;               dat_themis_esa_str_names.pro
;
;  REQUIRES:    
;               1)  UMN Modified Wind/3DP IDL Libraries
;
;  INPUT:
;               DAT        :  Scalar data structure containing a particle velocity
;                               distribution function (DF) from either the Wind/3DP
;                               instrument [use get_??.pro, ?? = e.g. phb] or from
;                               the THEMIS ESA instruments.  Regardless, the structure
;                               must satisfy the criteria needed to produce a contour
;                               plot showing the phase (velocity) space density of the
;                               DF.  The structure must also have the following two tags
;                               with finite [3]-element vectors:  VSW and MAGF.
;
;  EXAMPLES:    
;               NA
;
;  KEYWORDS:    
;               NA
;
;   CHANGED:  1)  Continued to write routine                       [08/29/2012   v1.0.0]
;
;   NOTES:      
;               1)  User should NOT call this routine
;
;   CREATED:  08/28/2012
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  08/29/2012   v1.0.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

FUNCTION beam_fit_get_inst_pref,dat

;;----------------------------------------------------------------------------------------
;; => Define some constants and dummy variables
;;----------------------------------------------------------------------------------------
f              = !VALUES.F_NAN
d              = !VALUES.D_NAN
;; => Dummy error messages
noinpt_msg     = 'No input supplied...'
notstr_msg     = 'DAT must be an IDL structure...'
notvdf_msg     = 'DAT must be an ion velocity distribution IDL structure...'
;;----------------------------------------------------------------------------------------
;; => Check input
;;----------------------------------------------------------------------------------------
test           = (N_ELEMENTS(dat) EQ 0) OR (N_PARAMS() NE 1)
IF (test) THEN BEGIN
  MESSAGE,noinpt_msg,/INFORMATIONAL,/CONTINUE
  RETURN,0b
ENDIF

test           = (SIZE(dat[0],/TYPE)  NE 8)
IF (test) THEN BEGIN
  MESSAGE,notstr_msg,/INFORMATIONAL,/CONTINUE
  RETURN,0b
ENDIF

str            = dat[0]
test0          = test_wind_vs_themis_esa_struct(str,/NOM)
test           = (test0.(0) + test0.(1)) NE 1
IF (test) THEN BEGIN
  MESSAGE,notvdf_msg,/INFORMATIONAL,/CONTINUE
  RETURN,0b
ENDIF
;;----------------------------------------------------------------------------------------
;; => Check which spacecraft is being used
;;----------------------------------------------------------------------------------------
IF (test0.(0)) THEN BEGIN
  ;-------------------------------------------
  ; Wind
  ;-------------------------------------------
  ; => Check which instrument is being used
  strns   = dat_3dp_str_names(dat[0])
  sn         = strns.SN                    ;; e.g. 'el'
  lc         = strns.LC                    ;; e.g. 'Eesa Low'
  eps_typ    = STRMID(sn[0],0,1)           ;; For Logic:  EESA, PESA, or SST
  lhfo_typ   = STRMID(sn[0],1,1)           ;; For Logic:  Low, High, Foil, or Open
  bt_typ     = STRMID(sn[0],2,1)           ;; For Logic:  '', 'Burst', or 'Thick'
  itype      = (['EESA','PESA','SST'])[WHERE(eps_typ[0] EQ ['e','p','s'])]
  entype     = (['Low','High','Foil','Open'])[WHERE(lhfo_typ[0] EQ ['l','h','f','o'])]
  bttype     = (['','Burst','Thick'])[WHERE(bt_typ[0] EQ ['','b','t'])]
  t_pref     = itype[0]+'_'+entype[0]+'_'+bttype[0]+'_'       ;; e.g. 'EESA_Low__'
ENDIF ELSE BEGIN
  ;-------------------------------------------
  ; THEMIS
  ;-------------------------------------------
  ; => Check which instrument is being used
  strns      = dat_themis_esa_str_names(dat[0])
  sn         = strns.SN                    ;; e.g. 'peib'
  lc         = strns.LC                    ;; e.g. 'IESA 3D Burst Distribution'
  frb_typ    = STRMID(sn[0],3,1)           ;; For Logic:  Burst, Full, or Reduced
  type       = (['Full','Reduced','Burst'])[WHERE(frb_typ[0] EQ ['f','r','b'])]
  i_or_e     = STRMID(sn[0],2,1)           ;; For Logic:  Electron or Ion
  s_or_e     = STRMID(sn[0],1,1)           ;; For Logic:  SST or ESA
  IF (s_or_e EQ 's') THEN BEGIN
    ;; SST distribution
    iename     = (['Electron','Ion'])[i_or_e[0] EQ 'i']
    instnm     = 'SST_'+iename[0]+'_'      ;; e.g. 'SST_Electron_'
  ENDIF ELSE BEGIN
    iename     = (['E','I'])[i_or_e[0] EQ 'i']
    instnm     = iename[0]+'ESA_'          ;; e.g. 'IESA_'
  ENDELSE
  t_pref     = instnm[0]+type[0]+'_'       ;; e.g. 'IESA_Burst_'
ENDELSE
;;----------------------------------------------------------------------------------------
;; => Return to user
;;----------------------------------------------------------------------------------------

RETURN,t_pref[0]
END


;+
;*****************************************************************************************
;
;  PROCEDURE:   beam_fit_keywords_init.pro
;  PURPOSE  :   This routine initializes the keywords etc. used by plotting routines and
;                 other subroutines called.  The values on output are only the default
;                 values and some may be changed later.
;
;  CALLED BY:   
;               beam_fit_1df_plot_fit.pro
;               wrapper_beam_fit_array.pro
;
;  CALLS:
;               beam_fit_unset_common.pro
;               delete_variable.pro
;               beam_fit_keyword_com.pro
;               beam_fit_params_com.pro
;               beam_fit_set_defaults.pro
;               test_wind_vs_themis_esa_struct.pro
;               beam_fit_get_inst_pref.pro
;               time_string.pro
;               beam_fit_gen_prompt.pro
;               beam_fit_prompts.pro
;               file_name_times.pro
;
;  REQUIRES:    
;               1)  UMN Modified Wind/3DP IDL Libraries
;
;  INPUT:
;               DAT        :  [N]-Element array of data structures containing particle
;                               velocity distribution functions (DFs) from either the
;                               Wind/3DP instrument [use get_??.pro, ?? = e.g. phb]
;                               or from the THEMIS ESA instruments.  Regardless, the
;                               structures must satisfy the criteria needed to produce
;                               a contour plot showing the phase (velocity) space density
;                               of the DF.  The structures must also have the following
;                               two tags with finite [3]-element vectors:  VSW and MAGF.
;
;  EXAMPLES:    
;               NA
;
;  KEYWORDS:    
;               ***  INPUT  ***
;               DFRA_IN    :  [2]-Element array [float/double] defining the DF range
;                               [cm^(-3) km^(-3) s^(3)] that defines the minimum and
;                               maximum value for both the contour levels and the
;                               Y-Axis of the cuts plot
;                               [Default = range of data]
;               CLEAN_UP   :  If set, routine removes common block variable definitions
;                               from the system memory
;                               [Default = FALSE]
;               KEY_CLEAN  :  [K]-Element array [string] defining which common block
;                               variables the user wishes to remove [used with CLEAN_UP]
;                               [Default = All common block variables]
;
;  KEYWORDS:    
;               ***  OUTPUT  ***
;               !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
;               ***  [all the following changed on output]  ***
;               !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
;               KEY_INIT   :  Set to a named variable to return an integer that tells
;                               whether this routine has been called already, thus
;                               whether the keywords were already initialized
;               READ_OUT   :  Set to a named variable to return a string containing the
;                               last command line input.  This is used by the overhead
;                               routine to determine whether user left the program by
;                               quitting or if the program finished
;
;  COMMON BLOCK VARIABLES:
;
;               VLIM       :  Scalar [float/double] defining the maximum speed [km/s]
;                               to plot for both the contour and cuts
;                               [Default = Vel. defined by maximum energy bin value]
;               NGRID      :  Scalar [long] defining the # of contour levels to use on
;                               output
;                               [Default = 30L]
;               NSMOOTH    :  Scalar [long] defining the # of points over which to
;                               smooth the DF contours and cuts
;                               [Default = 3]
;               SM_CUTS    :  If set, program plots the smoothed (by NSMOOTH points)
;                               cuts of the DF
;                               [Default:  FALSE]
;               SM_CONT    :  If set, program plots the smoothed (by NSMOOTH points)
;                               contours of DF
;                               [Default:  Smoothed to the minimum # of points]
;               DFRA       :  [2]-Element array [float/double] defining the DF range
;                               [cm^(-3) km^(-3) s^(3)] that defines the minimum and
;                               maximum value for both the contour levels and the
;                               Y-Axis of the cuts plot
;                               [Default = {DFMIN,DFMAX}]
;               DFMIN      :  Scalar [float/double] defining the minimum allowable phase
;                               (velocity) space density to plot, which is useful for
;                               ion distributions with large angular gaps in data
;                               [i.e. prevents lower bound from falling below DFMIN]
;                               [Default = 1d-18]
;               DFMAX      :  Scalar [float/double] defining the maximum allowable phase
;                               (velocity) space density to plot, which is useful for
;                               distributions with data spikes
;                               [i.e. prevents upper bound from exceeding DFMAX]
;                               [Default = 1d-2]
;               PLANE      :  Scalar [string] defining the plane projection to plot with
;                               corresponding cuts [Let V1 = MAGF, V2 = VSW]
;                                 'xy'  :  horizontal axis parallel to V1 and normal
;                                            vector to plane defined by (V1 x V2)
;                                            [default]
;                                 'xz'  :  horizontal axis parallel to (V1 x V2) and
;                                            vertical axis parallel to V1
;                                 'yz'  :  horizontal axis defined by (V1 x V2) x V1
;                                            and vertical axis (V1 x V2)
;                               [Default = 'xy']
;               ANGLE      :  Scalar [float/double] defining the angle [deg] from the
;                               Y-Axis by which to rotate the [X,Y]-cuts
;                               [Default = 0.0]
;               FILL       :  Scalar [float/double] defining the lowest possible values
;                               to consider and the value to use for replacing zeros
;                               and NaNs when fitting to beam peak
;                               [Default = 1d-20]
;               PERC_PK    :  Scalar [float/double] defining the percentage of the peak
;                               beam amplitude, A_b [cm^(-3) km^(-3) s^(3)], to use in
;                               the fit analysis
;                               [Default = 0.01 (or 1%)]
;               SAVE_DIR   :  Scalar [string] defining the directory where the plots
;                               will be stored
;                               [Default = FILE_EXPAND_PATH('')]
;               FILE_PREF  :  [N]-Element array [string] defining the prefix associated
;                               with each PostScript plot on output
;                               [Default = 'DF_00j', j = index # of DAT]
;               FILE_MIDF  :  Scalar [string] defining the plane of projection and number
;                               grids used for contour plot levels
;                               [Default = 'V1xV2xV1_vs_V1_30Grids_']
;
;   CHANGED:  1)  Continued to write routine                       [08/28/2012   v1.0.0]
;             2)  Continued to write routine                       [08/28/2012   v1.0.0]
;             3)  Continued to write routine                       [08/29/2012   v1.0.0]
;             4)  Continued to write routine                       [08/30/2012   v1.0.0]
;             5)  Continued to write routine                       [08/31/2012   v1.0.0]
;             6)  Continued to write routine                       [09/01/2012   v1.0.0]
;             7)  Continued to write routine                       [09/07/2012   v1.0.0]
;
;   NOTES:      
;               1)  The ANGLE is not fully tested and should not be changed from the
;                     default
;               2)  Setting the DFRA keyword will override your input values prompted
;                     for DFMIN and DFMAX
;               3)  KEY_CH cannot be used on READ_OUT
;
;   CREATED:  08/27/2012
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  09/07/2012   v1.0.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

PRO beam_fit_keywords_init,dat,DFRA_IN=dfra_in,CLEAN_UP=clean_up,KEY_CLEAN=key_clean,$
                               KEY_INIT=key_init,READ_OUT=read_out

;;----------------------------------------------------------------------------------------
;; => Check if user wants to erase common block definitions prior to initialization
;;      [gets rid of old definitions if desired]
;;----------------------------------------------------------------------------------------
IF KEYWORD_SET(clean_up) THEN BEGIN
  MESSAGE,"Removing common block definitions...",/INFORMATIONAL,/CONTINUE
  ;;  Remove variables defined in beam_fit_keyword_com.pro
  key_com_str    = ['vlim','ngrid','nsmooth','sm_cuts','sm_cont','dfra','dfmin','dfmax',$
                    'plane','angle','fill','perc_pk','save_dir','file_pref','file_midf']
  key_par_str    = ['vsw','vcmax','v_bx','v_by','vb_reg','vbmax','def_fill','def_perc',$
                    'def_dfmin','def_dfmax','def_ngrid','def_nsmth','def_plane',       $
                    'def_sdir','def_pref','def_midf','def_vlim']
  key_all_str    = [key_com_str,key_par_str]
  test           = (N_ELEMENTS(key_clean) EQ 0) OR (SIZE(key_clean,/TYPE) NE 7)
  IF (test) THEN key_remove = key_all_str ELSE key_remove = REFORM(key_clean)
  ;;  Undefine common block variables
  beam_fit_unset_common,key_remove,STATUS=status
  ;;  Remove the string arrays
  delete_variable,key_com_str,key_par_str,key_all_str,key_remove,status
  ;;--------------------------------------------------------------------------------------
  ;;  Return
  ;;--------------------------------------------------------------------------------------
  RETURN
ENDIF
;;----------------------------------------------------------------------------------------
;; => Load Common Block
;;----------------------------------------------------------------------------------------
@beam_fit_keyword_com.pro
@beam_fit_params_com.pro
;;----------------------------------------------------------------------------------------
;; => Define some constants and dummy variables
;;----------------------------------------------------------------------------------------
f              = !VALUES.F_NAN
d              = !VALUES.D_NAN
c              = 2.99792458d8      ;;  Speed of light in vacuum (m/s)
ckm            = c[0]*1d-3         ;;  [km/s]
read_out       = ''    ;; output value of decision
value_out      = 0.    ;; output value for prompt
;; => Define parts of file names
xyzvecf        = ['V1','V1xV2xV1','V1xV2']
xy_suff        = xyzvecf[1]+'_vs_'+xyzvecf[0]+'_'
xz_suff        = xyzvecf[0]+'_vs_'+xyzvecf[2]+'_'
yz_suff        = xyzvecf[2]+'_vs_'+xyzvecf[1]+'_'
;; => Define keyword names
def_keys       = STRLOWCASE(['VLIM','NGRID','NSMOOTH','SM_CUTS','SM_CONT','DFRA','DFMIN',$
                             'DFMAX','PLANE','ANGLE','FILL','PERC_PK','SAVE_DIR',$
                             'FILE_PREF','FILE_MIDF','KEY_INIT'])
;; => Dummy error messages
noinpt_msg     = 'No input supplied...'
notstr_msg     = 'DAT must be an IDL structure...'
notvdf_msg     = 'DAT must be an ion velocity distribution IDL structure...'
;;----------------------------------------------------------------------------------------
;; => Define default values for FILL, PERC_PK, DFMIN, DFMAX, NGRID, NSMOOTH, PLANE,
;;                              SAVE_DIR, FILE_PREF, and FILE_MIDF
;;----------------------------------------------------------------------------------------
beam_fit_set_defaults
;;----------------------------------------------------------------------------------------
;; => Check input
;;----------------------------------------------------------------------------------------
test           = (N_ELEMENTS(dat) EQ 0) OR (N_PARAMS() NE 1)
IF (test) THEN BEGIN
  MESSAGE,noinpt_msg,/INFORMATIONAL,/CONTINUE
  RETURN
ENDIF

test           = (SIZE(dat[0],/TYPE)  NE 8)
IF (test) THEN BEGIN
  MESSAGE,notstr_msg,/INFORMATIONAL,/CONTINUE
  RETURN
ENDIF

str            = dat[0]
test0          = test_wind_vs_themis_esa_struct(str,/NOM)
test           = (test0.(0) + test0.(1)) NE 1
IF (test) THEN BEGIN
  MESSAGE,notvdf_msg,/INFORMATIONAL,/CONTINUE
  RETURN
ENDIF
;;----------------------------------------------------------------------------------------
;; => Get prefix associated with instrument
;;----------------------------------------------------------------------------------------
t_pref         = beam_fit_get_inst_pref(dat)
;;----------------------------------------------------------------------------------------
;; => Define some parameters
;;----------------------------------------------------------------------------------------
s_times        = dat[*].TIME
e_times        = dat[*].END_TIME
nt             = N_ELEMENTS(dat)
;;----------------------------------------------------------------------------------------
;; => Initialize keywords:  SAVE_DIR
;;      => Create Directory
;;----------------------------------------------------------------------------------------
ymdbs          = time_string(s_times,PREC=3L)     ;; e.g.  '2000-10-03/00:01:11.598'
tdates         = STRMID(ymdbs[0],0L,10L)          ;; e.g.  '2000-10-03'
save_dir       = def_sdir[0]+t_pref[0]+tdates[0]  ;; e.g.  '~/IESA_Burst_2000-10-03'
pro_out        = ["Creating Directory:  "+save_dir[0]]
;; Inform user of directory creation
info_out       = beam_fit_gen_prompt(PRO_OUT=pro_out,FORM_OUT=7)
FILE_MKDIR,save_dir[0]
;;----------------------------------------------------------------------------------------
;; => Initialize keywords:  VLIM and NGRID
;;----------------------------------------------------------------------------------------
beam_fit_prompts,dat,/N_VLIM,READ_OUT=read_out
;; => Check if user wishes to quit
IF (read_out EQ 'q') THEN RETURN

beam_fit_prompts,dat,/N_NGRID,READ_OUT=read_out
;; => Check if user wishes to quit
IF (read_out EQ 'q') THEN RETURN
;;----------------------------------------------------------------------------------------
;; => Initialize keywords:  SM_CUTS, SM_CONT, and NSMOOTH
;;----------------------------------------------------------------------------------------
beam_fit_prompts,dat,/N_SM_CONT,READ_OUT=read_out
;; => Check if user wishes to quit
IF (read_out EQ 'q') THEN RETURN
beam_fit_prompts,dat,/N_SM_CUTS,READ_OUT=read_out
;; => Check if user wishes to quit
IF (read_out EQ 'q') THEN RETURN
beam_fit_prompts,dat,/N_NSMOOTH,READ_OUT=read_out
;; => Check if user wishes to quit
IF (read_out EQ 'q') THEN RETURN
;;----------------------------------------------------------------------------------------
;; => Initialize keywords:  PLANE
;;----------------------------------------------------------------------------------------
beam_fit_prompts,dat,/N_PLANE,READ_OUT=read_out
;; => Check if user wishes to quit
IF (read_out EQ 'q') THEN RETURN
;;----------------------------------------------------------------------------------------
;; => Initialize keywords:  DFRA, DFMIN, and DFMAX
;;----------------------------------------------------------------------------------------
;; => Define:  DFRA
beam_fit_prompts,dat,/N_DFRA,READ_OUT=read_out
;; => Check if user wishes to quit
IF (read_out EQ 'q') THEN RETURN
;; => Define:  DFMIN
beam_fit_prompts,dat,/N_DFMIN,READ_OUT=read_out
;; => Check if user wishes to quit
IF (read_out EQ 'q') THEN RETURN
;; => Define:  DFMAX
beam_fit_prompts,dat,/N_DFMAX,READ_OUT=read_out
;; => Check if user wishes to quit
IF (read_out EQ 'q') THEN RETURN
;;----------------------------------------------------------------------------------------
;; => Initialize keywords:  FILL and PERC_PK
;;----------------------------------------------------------------------------------------
beam_fit_prompts,dat,/N_FILL,READ_OUT=read_out
;; => Check if user wishes to quit
IF (read_out EQ 'q') THEN RETURN
beam_fit_prompts,dat,/N_PERC_PK,READ_OUT=read_out
;; => Check if user wishes to quit
IF (read_out EQ 'q') THEN RETURN
;;--------------------------------------------------------------------------------------
;; Define suffix associated with timestamps
;;--------------------------------------------------------------------------------------
fnm            = file_name_times(s_times,PREC=3)
ftimes         = fnm.F_TIME                 ;; e.g. '1998-08-09_0801x09.494'
;;--------------------------------------------------------------------------------------
;; Define file name prefixes [FILE_PREF and FILE_MIDF]
;;--------------------------------------------------------------------------------------
file_pref      = t_pref[0]+ftimes[*]+'_'    ;; e.g. 'IESA_Burst_1998-08-09_0801x09.494_'
test           = (N_ELEMENTS(file_pref) NE 0) AND (N_ELEMENTS(def_pref) NE 0) AND $
                 (N_ELEMENTS(file_pref) NE N_ELEMENTS(def_pref))
IF (test) THEN BEGIN
  ;; => Change the number of elements in DEF_PREF
  def_pref       = def_pref[0L:(nt - 1L)]
ENDIF
;; check temporary value
test           = (N_ELEMENTS(file_pref) EQ 0) AND (N_ELEMENTS(def_pref) GE nt)
IF (test) THEN file_pref = def_pref[0L:(nt - 1L)]
;;----------------------------------------------------------------------------------------
;; => Define output
;;----------------------------------------------------------------------------------------
IF (~KEYWORD_SET(dfmin) OR ~KEYWORD_SET(dfmax)) THEN BEGIN
  ;; use defaults
  IF ~KEYWORD_SET(dfmin) THEN dfmin = def_dfmin[0]
  IF ~KEYWORD_SET(dfmax) THEN dfmax = def_dfmax[0]
ENDIF
;; => Set ANGLE = 0.0 degrees
angle          = 0d0
;;----------------------------------------------------------------------------------------
;; => Return to user
;;----------------------------------------------------------------------------------------
key_init       = 1

RETURN
END
