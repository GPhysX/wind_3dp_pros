;+
;*****************************************************************************************
;
;  PROCEDURE:   t_stacked_ener_pad_spec_2_tplot.pro
;  PURPOSE  :   This is a wrapping routine for the following two routines:
;                 t_stacked_energy_spec_2_tplot.pro
;                 t_stacked_pad_spec_2_tplot.pro
;
;  CALLED BY:   
;               NA
;
;  INCLUDES:
;               NA
;
;  CALLS:
;               test_wind_vs_themis_esa_struct.pro
;               dat_3dp_str_names.pro
;               dat_themis_esa_str_names.pro
;               t_stacked_energy_spec_2_tplot.pro
;               struct_value.pro
;               t_stacked_pad_spec_2_tplot.pro
;               get_data.pro
;               tplot_struct_format_test.pro
;               lbw_append_arr.pro
;               extract_tags.pro
;               store_data.pro
;               tnames.pro
;               options.pro
;               str_element.pro
;
;  REQUIRES:    
;               1)  SPEDAS IDL libraries and UMN Modified Wind/3DP IDL Libraries
;
;  INPUT:
;               DAT         :  [N]-Element [structure] array of THEMIS ESA or Wind/3DP
;                                IDL data structures containing the 3D velocity
;                                distribution functions to use to create the stacked
;                                OMNI and PAD energy spectra plots
;
;  EXAMPLES:    
;               [calling sequence]
;               t_stacked_ener_pad_spec_2_tplot, dat [,LIMITS=limits] [,UNITS=units]     $
;                                                    [,BINS=bins] [,NAME=name]           $
;                                                    [,TRANGE=trange] [,ERANGE=erange]   $
;                                                    [,NUM_PA=num_pa] [,/NO_TRANS]       $
;                                                    [,DAT_STR2=dat_str2] [,B2INS=bins2] $
;                                                    [,_EXTRA=_extra]
;
;  KEYWORDS:    
;               **********************************
;               ***       DIRECT  INPUTS       ***
;               **********************************
;               LIMITS      :  Scalar [structure] that may contain any combination of the
;                                following structure tags or keywords accepted by
;                                PLOT.PRO:
;                                  XLOG,   YLOG,   ZLOG,
;                                  XRANGE, YRANGE, ZRANGE,
;                                  XTITLE, YTITLE,
;                                  TITLE, POSITION, REGION, etc.
;                                  (see IDL documentation for a description)
;               UNITS       :  Scalar [string] defining the units to use for the
;                                vertical axis of the plot and the outputs YDAT and DYDAT
;                                [Default = 'flux' or number flux]
;               BINS        :  [M]-Element [byte] array defining which solid angle bins
;                                should be plotted [i.e., BINS[good] = 1b] and which
;                                bins should not be plotted [i.e., BINS[bad] = 0b].
;                                One can also define bins as an array of indices that
;                                define which solid angle bins to plot.  If this is the
;                                case, then on output, BINS will be redefined to an
;                                array of byte values specifying which bins are TRUE or
;                                FALSE.
;                                [Default:  BINS[*] = 1b]
;               NAME        :  Scalar [string] defining the TPLOT handle for the energy
;                                omni-directional spectra
;                                [Default : '??_ener_spec', ?? = 'el','eh','elb',etc.]
;               TRANGE      :  [2]-Element [double] array of Unix times specifying the
;                                time range over which to calculate spectra
;                                [Default : [MIN(DAT.TIME),MAX(DAT.END_TIME)] ]
;               ERANGE      :  [2]-Element [double] array defining the energy [eV] range
;                                over which to calculate spectra
;                                [Default : [MIN(DAT.ENERGY),MAX(DAT.ENERGY)] ]
;               NUM_PA      :  Scalar [integer] that defines the number of pitch-angle
;                                bins to calculate for the resulting distribution
;                                [Default = 8]
;               NO_TRANS    :  If set, routine will not transform data into bulk flow
;                                rest frame defined by the structure tag VSW in each
;                                DAT structure (VELOCITY tag in THEMIS ESA structures
;                                will work as well so long as the THETA/PHI angles are
;                                in the same coordinate basis as VELOCITY and MAGF)
;                                [Default = FALSE]
;               DAT_STR2    :  [K]-Element [structure] array of THEMIS ESA or Wind/3DP
;                                IDL data structures containing the 3D velocity
;                                distribution functions to use to create the stacked
;                                OMNI and PAD energy spectra plots.  These structures
;                                will initially create separate TPLOT variables that
;                                will eventually be merged with those created by DAT.
;                                The purpose of using this keyword is for situations
;                                where the format of DAT and DAT_STR2 are incompatible
;                                so that it is not possible to concatenate the two
;                                into one array like DAT3 = [DAT,DAT_STR2].
;               B2INS       :  [L]-Element [byte] array defining which solid angle bins
;                                should be plotted [i.e., B2INS[good] = 1b] and which
;                                bins should not be plotted [i.e., B2INS[bad] = 0b].
;                                These bins are for DAT_STR2 only.
;               _EXTRA      :  ***  Currently not in use  ***
;               **********************************
;               ***       DIRECT OUTPUTS       ***
;               **********************************
;               TPN_STRUC   :  Set to a named variable to return an IDL structure
;                                containing information relevant to the newly created
;                                TPLOT handles
;
;   CHANGED:  1)  Continued to write routine
;                                                                   [02/11/2015   v1.0.0]
;             2)  Fixed a typo in use of NO_TRANS keyword
;                                                                   [11/15/2015   v1.0.1]
;             3)  Cleaned up and renamed from
;                   temp_send_stacked_ener_pad_spec_2_tplot.pro to
;                   t_stacked_ener_pad_spec_2_tplot.pro and
;                   now calls is_a_number.pro, tplot_struct_format_test.pro
;                                                                   [01/15/2016   v1.1.0]
;             4)  Fixed a bug where badvdf_msg and notthm_msg variables were not defined
;                                                                   [02/02/2016   v1.1.1]
;             5)  In very unusual circumstances, incompatible arrays would get through
;                   and cause errors which have now been fixed using the routine
;                   lbw_append_arr.pro and
;                   all V* tags are now forced to be 2D on output to avoid issues
;                   in other routines that assume or require 2D arrays for these tags
;                                                                   [05/09/2019   v1.1.2]
;
;   NOTES:      
;               1)  See also:  get_spec.pro, get_padspecs.pro,
;                     t_stacked_energy_spec_2_tplot.pro, and
;                     t_stacked_pad_spec_2_tplot.pro
;
;  REFERENCES:  
;               1)  Carlson et al., (1983), "An instrument for rapidly measuring
;                      plasma distribution functions with high resolution,"
;                      Adv. Space Res. Vol. 2, pp. 67-70.
;               2)  Curtis et al., (1989), "On-board data analysis techniques for
;                      space plasma particle instruments," Rev. Sci. Inst. Vol. 60,
;                      pp. 372.
;               3)  Lin et al., (1995), "A Three-Dimensional Plasma and Energetic
;                      particle investigation for the Wind spacecraft," Space Sci. Rev.
;                      Vol. 71, pp. 125.
;               4)  Paschmann, G. and P.W. Daly (1998), "Analysis Methods for Multi-
;                      Spacecraft Data," ISSI Scientific Report, Noordwijk, 
;                      The Netherlands., Int. Space Sci. Inst.
;               5)  McFadden, J.P., C.W. Carlson, D. Larson, M. Ludlam, R. Abiad,
;                      B. Elliot, P. Turin, M. Marckwordt, and V. Angelopoulos
;                      "The THEMIS ESA Plasma Instrument and In-flight Calibration,"
;                      Space Sci. Rev. 141, pp. 277-302, (2008).
;               6)  McFadden, J.P., C.W. Carlson, D. Larson, J.W. Bonnell,
;                      F.S. Mozer, V. Angelopoulos, K.-H. Glassmeier, U. Auster
;                      "THEMIS ESA First Science Results and Performance Issues,"
;                      Space Sci. Rev. 141, pp. 477-508, (2008).
;               7)  Auster, H.U., K.-H. Glassmeier, W. Magnes, O. Aydogar, W. Baumjohann,
;                      D. Constantinescu, D. Fischer, K.H. Fornacon, E. Georgescu,
;                      P. Harvey, O. Hillenmaier, R. Kroth, M. Ludlam, Y. Narita,
;                      R. Nakamura, K. Okrafka, F. Plaschke, I. Richter, H. Schwarzl,
;                      B. Stoll, A. Valavanoglou, and M. Wiedemann "The THEMIS Fluxgate
;                      Magnetometer," Space Sci. Rev. 141, pp. 235-264, (2008).
;               8)  Angelopoulos, V. "The THEMIS Mission," Space Sci. Rev. 141,
;                      pp. 5-34, (2008).
;               9)  L.B. Wilson III, et al., "Electron energy partition across
;                      interplanetary shocks: I. Methodology and Data Product,"
;                      Astrophys. J. Suppl., under review, eprint 1902.01476, 2019a.
;              10)  Wilson III, L.B., et al., "Relativistic Electrons Produced by
;                      Foreshock Disturbances Observed Upstream of Earth's Bow Shock,"
;                      Phys. Rev. Lett. 117(21), pp. 215101,
;                      doi:10.1103/PhysRevLett.117.215101, 2016.
;              11)  L.B. Wilson III, et al., "Electron energy partition across
;                      interplanetary shocks: II. Statistics," Astrophys. J. Suppl.,
;                      in preparation, 20??.
;              12)  L.B. Wilson III, et al., "Electron energy partition across
;                      interplanetary shocks: III. Analysis," Astrophys. J.,
;                      in preparation, 20??.
;
;   CREATED:  02/10/2015
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  05/09/2019   v1.1.2
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

PRO t_stacked_ener_pad_spec_2_tplot,dat,LIMITS=limits,UNITS=units,BINS=bins,        $
                                        NAME=name,TRANGE=trange,ERANGE=erange,      $
                                        NUM_PA=num_pa,NO_TRANS=no_trans,            $
                                        TPN_STRUC=tpn_struc,DAT_STR2=dat_str2,      $
                                        B2INS=bins2,_EXTRA=ex_str

;;  Define compiler options
COMPILE_OPT IDL2
;;  Let IDL know that the following are functions
FORWARD_FUNCTION test_wind_vs_themis_esa_struct, dat_3dp_str_names,                 $
                 dat_themis_esa_str_names, struct_value, tnames, is_a_number,       $
                 tplot_struct_format_test
ex_start       = SYSTIME(1)
;;----------------------------------------------------------------------------------------
;;  Define some constants and dummy variables
;;----------------------------------------------------------------------------------------
f              = !VALUES.F_NAN
d              = !VALUES.D_NAN
mission_logic  = [0b,0b]                ;;  Logic variable used for determining which mission is associated with DAT
def_nm_suffx   = '_ener_spec'
lab_strings    = ['para','perp','anti']
;;  Dummy error messages
noinpt_msg     = 'User must supply an array of velocity distribution functions as IDL structures...'
notstr_msg     = 'DAT must be an array of IDL structures...'
notvdf_msg     = 'Input must be a velocity distribution function as an IDL structure...'
badtra_msg     = 'TRANGE must be a 2-element array of Unix times and DAT must have a range of times as well...'
badera_msg     = 'ERANGE must be a 2-element array of energies [eV] and DAT.ENERGY must have a range of energies as well...'
badvdf_msg     = 'Input must be an IDL structure with similar format to Wind/3DP or THEMIS/ESA...'
not3dp_msg     = 'Input must be a velocity distribution IDL structure from Wind/3DP...'
notthm_msg     = 'Input must be a velocity distribution IDL structure from THEMIS/ESA...'
;;----------------------------------------------------------------------------------------
;;  Check input
;;----------------------------------------------------------------------------------------
IF (N_PARAMS() LT 1) THEN BEGIN
  MESSAGE,noinpt_msg[0],/INFORMATIONAL,/CONTINUE
  RETURN
ENDIF
IF (SIZE(dat,/TYPE) NE 8L OR N_ELEMENTS(dat) LT 2) THEN BEGIN
  MESSAGE,notstr_msg[0],/INFORMATIONAL,/CONTINUE
  RETURN
ENDIF
;;  Check to make sure distribution has the correct format
test0          = test_wind_vs_themis_esa_struct(dat[0],/NOM)
test           = (test0.(0) + test0.(1)) NE 1
IF (test[0]) THEN BEGIN
  MESSAGE,notvdf_msg[0],/INFORMATIONAL,/CONTINUE
  RETURN
ENDIF
;;  Determine instrument (i.e., ESA or 3DP) and define electric charge
dat0           = dat[0]
IF (test0.(0)) THEN BEGIN
  ;;--------------------------------------------------------------------------------------
  ;;  Wind
  ;;--------------------------------------------------------------------------------------
  mission      = 'Wind'
  strns        = dat_3dp_str_names(dat0[0])
  IF (SIZE(strns,/TYPE) NE 8) THEN BEGIN
    ;;  Neither Wind/3DP nor THEMIS/ESA VDF
    MESSAGE,not3dp_msg[0],/INFORMATIONAL,/CONTINUE
    RETURN
  ENDIF
  inst_nm_mode = strns.LC[0]         ;;  e.g., 'Pesa Low Burst'
ENDIF ELSE BEGIN
  IF (test0.(1)) THEN BEGIN
    ;;------------------------------------------------------------------------------------
    ;;  THEMIS
    ;;------------------------------------------------------------------------------------
    mission      = 'THEMIS'
    strns        = dat_themis_esa_str_names(dat0[0])
    IF (SIZE(strns,/TYPE) NE 8) THEN BEGIN
      ;;  Neither Wind/3DP nor THEMIS/ESA VDF
      MESSAGE,notthm_msg[0],/INFORMATIONAL,/CONTINUE
      RETURN
    ENDIF
    temp         = strns.LC[0]                  ;;  e.g., 'IESA 3D Reduced Distribution'
    tposi        = STRPOS(temp[0],'Distribution') - 1L
    inst_nm_mode = STRMID(temp[0],0L,tposi[0])  ;;  e.g., 'IESA 3D Reduced'
  ENDIF ELSE BEGIN
    ;;------------------------------------------------------------------------------------
    ;;  Other mission?
    ;;------------------------------------------------------------------------------------
    ;;  Not handling any other missions yet  [Need to know the format of their distributions]
    MESSAGE,badvdf_msg[0],/INFORMATIONAL,/CONTINUE
    RETURN
  ENDELSE
ENDELSE
data_str       = strns.SN[0]     ;;  e.g., 'el' for Wind EESA Low or 'peeb' for THEMIS EESA
;;----------------------------------------------------------------------------------------
;;  Check keywords
;;----------------------------------------------------------------------------------------
;;  Check NAME
test           = (N_ELEMENTS(name) EQ 0) OR (SIZE(name,/TYPE) NE 7)
IF (test[0]) THEN name = data_str[0]+def_nm_suffx[0]
;;  Check NO_TRANS
test           = KEYWORD_SET(no_trans)
IF (test[0]) THEN no_trans = 1b ELSE no_trans = 0b
;;  Define associated TPLOT handle string dependent on frame
yttl_frame     = STRUPCASE((['swf','scf'])[no_trans])
tpn_frame      = '_'+STRLOWCASE(yttl_frame[0])
;;  Check UNITS
test           = (N_ELEMENTS(units) EQ 0) OR (SIZE(units,/TYPE) NE 7)
IF (test[0]) THEN units = 'flux'
;;  Check NUM_PA
test           = (N_ELEMENTS(num_pa) EQ 0) OR (is_a_number(num_pa,/NOMSSG) EQ 0)
IF (test[0]) THEN num_pa = 8L ELSE num_pa = num_pa[0]
;;  Check if DAT_STR2 is set
test           = (SIZE(dat_str2,/TYPE) EQ 8L) AND (N_ELEMENTS(dat_str2) GT 2)
IF (test[0]) THEN BEGIN
  ;;  Make sure DAT_STR2 is from the same instrument
  test2          = test_wind_vs_themis_esa_struct(dat_str2[0],/NOM)
  test           = ((test2.(0) + test2.(1)) EQ 1) AND $
                    ((test0.(0) AND test2.(0)) OR (test0.(1) AND test2.(1)) )
  IF (test[0]) THEN merge_spec = 1 ELSE merge_spec = 0
ENDIF ELSE merge_spec = 0
;;----------------------------------------------------------------------------------------
;;  Calculate OMNI directional energy spectrum
;;----------------------------------------------------------------------------------------
t_stacked_energy_spec_2_tplot,dat,LIMITS=limits,UNITS=units,BINS=bins,$
                                        NAME=name,TRANGE=trange,ERANGE=erange,  $
                                        NO_TRANS=no_trans,_EXTRA=ex_str,        $
                                        TPN_STRUC=tpn_struc
;;  Define OMNI TPLOT handle
omni_tpn       = struct_value(tpn_struc,'OMNI.SPEC_TPLOT_NAME')
omni_tpn2      = ''   ;;  initialize variable
IF (merge_spec[0]) THEN BEGIN
  ;;--------------------------------------------------------------------------------------
  ;;  Calculate OMNI directional energy spectrum for DAT_STR2
  ;;--------------------------------------------------------------------------------------
  t_stacked_energy_spec_2_tplot,dat_str2,LIMITS=limits,UNITS=units,BINS=bins2,$
                                          NAME=name+'2',TRANGE=trange,ERANGE=erange,    $
                                          NO_TRANS=no_trans,_EXTRA=ex_str,              $
                                          TPN_STRUC=tpn_struc2
  ;;  Define OMNI TPLOT handle
  omni_tpn2      = struct_value(tpn_struc2,'OMNI.SPEC_TPLOT_NAME')
ENDIF
;;----------------------------------------------------------------------------------------
;;  Calculate pitch-angle distribution (PAD) energy spectrum
;;----------------------------------------------------------------------------------------
t_stacked_pad_spec_2_tplot,dat,LIMITS=limits,UNITS=units,BINS=bins,$
                                     NAME=name,TRANGE=trange,ERANGE=erange,  $
                                     NUM_PA=num_pa,NO_TRANS=no_trans,        $
                                     TPN_STRUC=tpn_struc
;;  Define PAD TPLOT handles
pad_omni__tpn  = struct_value(tpn_struc, 'PAD.SPEC_TPLOT_NAME')
pad_spec_tpns  = struct_value(tpn_struc, 'PAD.PAD_TPLOT_NAMES')
test           = (N_ELEMENTS([pad_omni__tpn,pad_spec_tpns]) LT 4)
IF (test[0]) THEN test = (pad_spec_tpns[0] EQ '') OR (pad_omni__tpn[0] EQ '')
IF (test[0]) THEN STOP        ;;  Problem --> Go no further
;;  initialize variable
pad_omni_tpn2  = ''
pad_spec_tpn2  = ''
IF (merge_spec[0]) THEN BEGIN
  ;;--------------------------------------------------------------------------------------
  ;;  Calculate PAD energy spectrum for DAT_STR2
  ;;--------------------------------------------------------------------------------------
  t_stacked_pad_spec_2_tplot,dat_str2,LIMITS=limits,UNITS=units,BINS=bins2,  $
                                       NAME=name+'2',TRANGE=trange,ERANGE=erange,      $
                                       NUM_PA=num_pa,NO_TRANS=no_trans,                $
                                       TPN_STRUC=tpn_struc2
  ;;  Define PAD TPLOT handles
  pad_omni_tpn2  = struct_value(tpn_struc2, 'PAD.SPEC_TPLOT_NAME')
  pad_spec_tpn2  = struct_value(tpn_struc2, 'PAD.PAD_TPLOT_NAMES')
ENDIF
;;----------------------------------------------------------------------------------------
;;  Merge OMNI spectra TPLOT handles if appropriate
;;----------------------------------------------------------------------------------------
test           = merge_spec[0] AND ((omni_tpn[0] NE '') AND (omni_tpn2[0] NE ''))
IF (test[0]) THEN BEGIN
  ;;--------------------------------------------------------------------------------------
  ;;  Merge TPLOT handles  [should be the same number for each array of structures]
  ;;--------------------------------------------------------------------------------------
  ;;  First merge the OMNI spectra
  get_data,omni_tpn[0], DATA=temp, DLIMIT=dlim, LIMIT=lim
  get_data,omni_tpn2[0],DATA=temp2,DLIMIT=dlim2,LIMIT=lim2
  ;;  Make sure structures are valid TPLOT structures
  test_1         = tplot_struct_format_test(temp ,TEST__V=test__v_1,TEST_V1_V2=test_v1_v2_1,/NOMSSG)
  test_2         = tplot_struct_format_test(temp2,TEST__V=test__v_2,TEST_V1_V2=test_v1_v2_2,/NOMSSG)
  test           = (test_1[0] AND test_2[0])
  ;;  Check for V
  vv_1d_on       = (test__v_1[0] EQ 1) AND (test__v_2[0] EQ 1)  ;;  TRUE : IFF V is 1D
  vv_2d_on       = (test__v_1[0] EQ 2) AND (test__v_2[0] EQ 2)  ;;  TRUE : IFF V is 2D
  ;;  Clean up to avoid unintentional passback issues with keywords
  dumb           =    TEMPORARY(test__v_1) & dumb =    TEMPORARY(test__v_2)
  dumb           = TEMPORARY(test_v1_v2_1) & dumb = TEMPORARY(test_v1_v2_2)
  IF (test[0]) THEN BEGIN
    ;;------------------------------------------------------------------------------------
    ;;  Data is present for both TPLOT handles and structures seem okay
    ;;    --> check dimensions
    ;;------------------------------------------------------------------------------------
    temp_x  = struct_value(temp,'X')
    temp_y  = struct_value(temp,'Y')
    temp_v  = struct_value(temp,'V')
    temp2x  = struct_value(temp2,'X')
    temp2y  = struct_value(temp2,'Y')
    temp2v  = struct_value(temp2,'V')
    szdd_1  = {T0:SIZE(temp_x,/DIMENSIONS),  T1:SIZE(temp_y,/DIMENSIONS),  T2:SIZE(temp_v,/DIMENSIONS)  }
    szdn_1  = {T0:SIZE(temp_x,/N_DIMENSIONS),T1:SIZE(temp_y,/N_DIMENSIONS),T2:SIZE(temp_v,/N_DIMENSIONS)}
    szdd_2  = {T0:SIZE(temp2x,/DIMENSIONS),  T1:SIZE(temp2y,/DIMENSIONS),  T2:SIZE(temp2v,/DIMENSIONS)  }
    szdn_2  = {T0:SIZE(temp2x,/N_DIMENSIONS),T1:SIZE(temp2y,/N_DIMENSIONS),T2:SIZE(temp2v,/N_DIMENSIONS)}
    test    = ((szdn_1.(0) EQ szdn_2.(0)) AND (szdn_1.(1) EQ szdn_2.(1)) AND $
               (szdn_1.(2) EQ szdn_2.(2))) AND (vv_1d_on[0] OR vv_2d_on[0])
    IF (test[0]) THEN BEGIN
      ;;----------------------------------------------------------------------------------
      ;;  Everything seems okay --> merge
      ;;----------------------------------------------------------------------------------
      tempx          = [temp_x,temp2x]
      IF (szdd_1.(1)[1] NE szdd_2.(1)[1]) THEN BEGIN
        ;;  Issue in 2nd dimension
        tempy = lbw_append_arr(temp_y,temp2y,LARGER=2)
      ENDIF ELSE BEGIN
        ;;  Same size --> directly append
        tempy = [temp_y,temp2y]
      ENDELSE
      ;;  Replace zeros with NaNs
      bad          = WHERE(FINITE(tempy) EQ 0 OR tempy LE 0,bd)
      IF (bd[0] GT 0) THEN tempy[bad] = d
      ;;----------------------------------------------------------------------------------
      ;;  Sort by time
      ;;----------------------------------------------------------------------------------
      sp             = SORT(tempx)
      tempx          = TEMPORARY(tempx[sp])
      tempy          = TEMPORARY(tempy[sp,*])
      IF (vv_2d_on[0]) THEN BEGIN
        ;;  V tag is a 2D array  -->  Sort by time
        IF (szdd_1.(2)[1] NE szdd_2.(2)[1]) THEN BEGIN
          tempv = lbw_append_arr(temp_v,temp2v,LARGER=2)
        ENDIF ELSE BEGIN
          ;;  Same size --> directly append
          tempv = [temp_v,temp2v]
        ENDELSE
        tempv = TEMPORARY(tempv[sp,*])
      ENDIF ELSE BEGIN
        ;;  V tag is a 1D array  -->  No time-dependent sorting necessary
        tempv = temp_v
        ;;  Force to 2D to avoid issues in other routines
        tempv = REPLICATE(1e0,N_ELEMENTS(tempx)) # tempv
      ENDELSE
      ;;  Replace zeros with NaNs
      bad            = WHERE(FINITE(tempv) EQ 0 OR tempv LE 0,bd)
      IF (bd[0] GT 0) THEN tempv[bad] = d
      ;;----------------------------------------------------------------------------------
      ;;  Define data structure for TPLOT
      ;;----------------------------------------------------------------------------------
      tstrc          = {X:tempx,Y:tempy,V:tempv}
      ;;  Extract tags from LIMITS structures
      extract_tags,dopts_str,dlim,EXCEPT_TAGS=['YRANGE']      ;;  Get current default plot limits settings
      extract_tags,opts__str, lim,EXCEPT_TAGS=['YRANGE']
      dlim_tags      = TAG_NAMES(dopts_str)
      lim__tags      = TAG_NAMES(opts__str)
      extract_tags,dopts_str,dlim2,EXCEPT_TAGS=[dlim_tags,'YRANGE']
      extract_tags,opts__str, lim2,EXCEPT_TAGS=[lim__tags,'YRANGE']
      ;;----------------------------------------------------------------------------------
      ;;  Send results to TPLOT
      ;;----------------------------------------------------------------------------------
      store_data,omni_tpn[0],DATA=tstrc,DLIMIT=dopts_str,LIMIT=opts__str
      ;;  Remove TPLOT handle associated with DAT_STR2
      store_data,DELETE=omni_tpn2[0]
      ;;  Clean up
      temp_x    = 0 & temp_y    = 0 & temp_v    = 0
      temp2x    = 0 & temp2y    = 0 & temp2v    = 0
      tempx     = 0 & tempy     = 0 & tempv     = 0
      tstrc     = 0 & dopts_str = 0 & opts__str = 0
    ENDIF
  ENDIF
ENDIF
;;----------------------------------------------------------------------------------------
;;  Merge PAD OMNI spectra TPLOT handles if appropriate
;;----------------------------------------------------------------------------------------
test           = merge_spec[0] AND                                       $
                 ((pad_omni__tpn[0] NE '') AND (pad_omni_tpn2[0] NE ''))
IF (test[0]) THEN BEGIN
  ;;--------------------------------------------------------------------------------------
  ;;  Merge TPLOT handles  [should be the same number for each array of structures]
  ;;--------------------------------------------------------------------------------------
  ;;  First merge the OMNI spectra
  get_data,pad_omni__tpn[0],DATA=temp, DLIMIT=dlim, LIMIT=lim
  get_data,pad_omni_tpn2[0],DATA=temp2,DLIMIT=dlim2,LIMIT=lim2
  ;;  Make sure structures are valid TPLOT structures
  test_1         = tplot_struct_format_test(temp ,TEST__V=test__v_1,TEST_V1_V2=test_v1_v2_1,/NOMSSG)
  test_2         = tplot_struct_format_test(temp2,TEST__V=test__v_2,TEST_V1_V2=test_v1_v2_2,/NOMSSG)
  test           = (test_1[0] AND test_2[0])
  ;;  Check for V1 and V2
  v1_v2_on       = (test_v1_v2_1[0] AND test_v1_v2_2[0])
  ;;  Clean up to avoid unintentional passback issues with keywords
  dumb           =    TEMPORARY(test__v_1) & dumb =    TEMPORARY(test__v_2)
  dumb           = TEMPORARY(test_v1_v2_1) & dumb = TEMPORARY(test_v1_v2_2)
  IF (test[0]) THEN BEGIN
    ;;------------------------------------------------------------------------------------
    ;;  Data is present for both TPLOT handles
    ;;------------------------------------------------------------------------------------
    temp_x  = struct_value(temp,'X')
    temp_y  = struct_value(temp,'Y')
    temp_v1 = struct_value(temp,'V1')
    temp_v2 = struct_value(temp,'V2')
    temp2x  = struct_value(temp2,'X')
    temp2y  = struct_value(temp2,'Y')
    temp2v1 = struct_value(temp2,'V1')
    temp2v2 = struct_value(temp2,'V2')
    szdd_1  = {T0:SIZE(temp_x,/DIMENSIONS),  T1:SIZE(temp_y,/DIMENSIONS),  T2:SIZE(temp_v1,/DIMENSIONS),  T3:SIZE(temp_v2,/DIMENSIONS)  }
    szdn_1  = {T0:SIZE(temp_x,/N_DIMENSIONS),T1:SIZE(temp_y,/N_DIMENSIONS),T2:SIZE(temp_v1,/N_DIMENSIONS),T3:SIZE(temp_v2,/N_DIMENSIONS)}
    szdd_2  = {T0:SIZE(temp2x,/DIMENSIONS),  T1:SIZE(temp2y,/DIMENSIONS),  T2:SIZE(temp2v1,/DIMENSIONS),  T3:SIZE(temp2v2,/DIMENSIONS)  }
    szdn_2  = {T0:SIZE(temp2x,/N_DIMENSIONS),T1:SIZE(temp2y,/N_DIMENSIONS),T2:SIZE(temp2v1,/N_DIMENSIONS),T3:SIZE(temp2v2,/N_DIMENSIONS)}
    test    = ((szdn_1.(0) EQ szdn_2.(0)) AND (szdn_1.(1) EQ szdn_2.(1))  AND $
               (szdn_1.(2) EQ szdn_2.(2)) AND (szdn_1.(3) EQ szdn_2.(3))) AND $
               v1_v2_on[0]
    IF (test[0]) THEN BEGIN
      ;;----------------------------------------------------------------------------------
      ;;  Everything seems okay --> merge
      ;;----------------------------------------------------------------------------------
      tempx          = [temp_x,temp2x]
      IF ((szdd_1.(1)[1] NE szdd_2.(1)[1]) OR (szdd_1.(1)[2] NE szdd_2.(1)[2])) THEN BEGIN
        ;;--------------------------------------------------------------------------------
        ;;  Uneven Y sizes
        ;;--------------------------------------------------------------------------------
        dim0      = szdd_1.(1)
        dim0[1]   = (szdd_1.(1)[1]) > (szdd_2.(1)[1])
        dim0[2]   = (szdd_1.(1)[2]) > (szdd_2.(1)[2])
        tempy     = lbw_append_arr(temp_y,temp2y,DIM_OUT=dim0)
      ENDIF ELSE BEGIN
        ;;  Same size --> directly append
        tempy     = [temp_y,temp2y]
      ENDELSE
      ;;  Replace zeros with NaNs
      bad            = WHERE(FINITE(tempy) EQ 0 OR tempy LE 0,bd)
      IF (bd[0] GT 0) THEN tempy[bad] = d
      ;;----------------------------------------------------------------------------------
      ;;  Check V1
      ;;----------------------------------------------------------------------------------
      IF (szdd_1.(2)[1] NE szdd_2.(2)[1]) THEN BEGIN
        ;;--------------------------------------------------------------------------------
        ;;  Uneven V1 sizes
        ;;--------------------------------------------------------------------------------
        dim0      = szdd_1.(2)
        dim0[1]   = (szdd_1.(2)[1]) > (szdd_2.(2)[1])
        tempv1    = lbw_append_arr(temp_v1,temp2v1,DIM_OUT=dim0)
      ENDIF ELSE BEGIN
        ;;  Same size --> directly append
        tempv1    = [temp_v1,temp2v1]
      ENDELSE
      ;;  Replace zeros with NaNs
      bad            = WHERE(FINITE(tempv1) EQ 0 OR tempv1 LE 0,bd)
      IF (bd[0] GT 0) THEN tempv1[bad] = d
      ;;----------------------------------------------------------------------------------
      ;;  Check V2
      ;;----------------------------------------------------------------------------------
      IF (szdd_1.(3)[1] NE szdd_2.(3)[1]) THEN BEGIN
        ;;--------------------------------------------------------------------------------
        ;;  Uneven V2 sizes
        ;;--------------------------------------------------------------------------------
        dim0      = szdd_1.(3)
        dim0[1]   = (szdd_1.(3)[1]) > (szdd_2.(3)[1])
        tempv2    = lbw_append_arr(temp_v2,temp2v2,DIM_OUT=dim0)
      ENDIF ELSE BEGIN
        ;;  Same size --> directly append
        tempv2    = [temp_v2,temp2v2]
      ENDELSE
      ;;  Replace zeros with NaNs
      bad            = WHERE(FINITE(tempv2) EQ 0 OR tempv2 LE 0,bd)
      IF (bd[0] GT 0) THEN tempv2[bad] = d
      ;;----------------------------------------------------------------------------------
      ;;  Sort by time
      ;;----------------------------------------------------------------------------------
      sp             = SORT(tempx)
      tempx          =  TEMPORARY(tempx[sp])
      tempy          =  TEMPORARY(tempy[sp,*,*])
      tempv1         = TEMPORARY(tempv1[sp,*])
      tempv2         = TEMPORARY(tempv2[sp,*])
      ;;  Define data structure for TPLOT
      tstrc          = {X:tempx,Y:tempy,V1:tempv1,V2:tempv2}
      ;;  Extract tags from LIMITS structures
      extract_tags,dopts_str,dlim,EXCEPT_TAGS=['YRANGE']      ;;  Get current default plot limits settings
      extract_tags,opts__str, lim,EXCEPT_TAGS=['YRANGE']
      dlim_tags      = TAG_NAMES(dopts_str)
      lim__tags      = TAG_NAMES(opts__str)
      extract_tags,dopts_str,dlim2,EXCEPT_TAGS=[dlim_tags,'YRANGE']
      extract_tags,opts__str, lim2,EXCEPT_TAGS=[lim__tags,'YRANGE']
      ;;  Send results to TPLOT
      store_data,pad_omni__tpn[0],DATA=tstrc,DLIMIT=dopts_str,LIMIT=opts__str
      ;;  Remove TPLOT handle associated with DAT_STR2
      store_data,DELETE=pad_omni_tpn2[0]
      ;;  Clean up
      temp_x    = 0 & temp_y    = 0 & temp_v1   = 0 & temp_v2   = 0
      temp2x    = 0 & temp2y    = 0 & temp2v1   = 0 & temp2v2   = 0
      tempx     = 0 & tempy     = 0 & tempv1    = 0 & tempv2    = 0
      tstrc     = 0 & dopts_str = 0 & opts__str = 0
    ENDIF
  ENDIF
ENDIF
;;----------------------------------------------------------------------------------------
;;  Merge PAD spectra TPLOT handles if appropriate
;;----------------------------------------------------------------------------------------
test           = merge_spec[0] AND                                       $
                 ((pad_spec_tpns[0] NE '') AND (pad_spec_tpn2[0] NE ''))
test2          = (N_ELEMENTS(pad_spec_tpns) EQ N_ELEMENTS(pad_spec_tpn2))
IF (test[0] AND test2[0]) THEN BEGIN
  ;;--------------------------------------------------------------------------------------
  ;;  Merge TPLOT handles  [should be the same number for each array of structures]
  ;;--------------------------------------------------------------------------------------
  n_tpn  = N_ELEMENTS(pad_spec_tpns)
  tpns1  = pad_spec_tpns
  tpns2  = pad_spec_tpn2
  FOR tj=0L, n_tpn[0] - 1L DO BEGIN
    ;;  Get data and then test format
    get_data,tpns1[tj],DATA=temp, DLIMIT=dlim, LIMIT=lim
    get_data,tpns2[tj],DATA=temp2,DLIMIT=dlim2,LIMIT=lim2
    ;;  Make sure structures are valid TPLOT structures
    test_1         = tplot_struct_format_test(temp ,TEST__V=test__v_1,TEST_V1_V2=test_v1_v2_1,/NOMSSG)
    test_2         = tplot_struct_format_test(temp2,TEST__V=test__v_2,TEST_V1_V2=test_v1_v2_2,/NOMSSG)
    test           = (test_1[0] AND test_2[0])
    ;;  Check for V
    vv_1d_on       = (test__v_1[0] EQ 1) AND (test__v_2[0] EQ 1)  ;;  TRUE : IFF V is 1D
    vv_2d_on       = (test__v_1[0] EQ 2) AND (test__v_2[0] EQ 2)  ;;  TRUE : IFF V is 2D
    ;;  Clean up to avoid unintentional passback issues with keywords
    dumb           =    TEMPORARY(test__v_1) & dumb =    TEMPORARY(test__v_2)
    dumb           = TEMPORARY(test_v1_v2_1) & dumb = TEMPORARY(test_v1_v2_2)
    IF (test[0]) THEN BEGIN
      ;;----------------------------------------------------------------------------------
      ;;  Data is present for both TPLOT handles
      ;;----------------------------------------------------------------------------------
      temp_x  = struct_value(temp,'X')
      temp_y  = struct_value(temp,'Y')
      temp_v  = struct_value(temp,'V')
      temp2x  = struct_value(temp2,'X')
      temp2y  = struct_value(temp2,'Y')
      temp2v  = struct_value(temp2,'V')
      szdd_1  = {T0:SIZE(temp_x,/DIMENSIONS),  T1:SIZE(temp_y,/DIMENSIONS),  T2:SIZE(temp_v,/DIMENSIONS)  }
      szdn_1  = {T0:SIZE(temp_x,/N_DIMENSIONS),T1:SIZE(temp_y,/N_DIMENSIONS),T2:SIZE(temp_v,/N_DIMENSIONS)}
      szdd_2  = {T0:SIZE(temp2x,/DIMENSIONS),  T1:SIZE(temp2y,/DIMENSIONS),  T2:SIZE(temp2v,/DIMENSIONS)  }
      szdn_2  = {T0:SIZE(temp2x,/N_DIMENSIONS),T1:SIZE(temp2y,/N_DIMENSIONS),T2:SIZE(temp2v,/N_DIMENSIONS)}
      test    = ((szdn_1.(0) EQ szdn_2.(0)) AND (szdn_1.(1) EQ szdn_2.(1)) AND $
                 (szdn_1.(2) EQ szdn_2.(2))) AND (vv_1d_on[0] OR vv_2d_on[0])
      IF (test[0]) THEN BEGIN
        ;;--------------------------------------------------------------------------------
        ;;  Everything seems okay --> merge
        ;;--------------------------------------------------------------------------------
        tempx          = [temp_x,temp2x]
        IF (szdd_1.(1)[1] NE szdd_2.(1)[1]) THEN BEGIN
          ;;  Issue in 2nd dimension --> Default to larger size
          tempy = lbw_append_arr(temp_y,temp2y,LARGER=2)
        ENDIF ELSE BEGIN
          ;;  Same size --> directly append
          tempy = [temp_y,temp2y]
        ENDELSE
        ;;  Replace zeros with NaNs
        bad            = WHERE(FINITE(tempy) EQ 0 OR tempy LE 0,bd)
        IF (bd[0] GT 0) THEN tempy[bad] = d
        ;;--------------------------------------------------------------------------------
        ;;  Sort by time
        ;;--------------------------------------------------------------------------------
        sp             = SORT(tempx)
        tempx          = TEMPORARY(tempx[sp])
        tempy          = TEMPORARY(tempy[sp,*])
        IF (vv_2d_on[0]) THEN BEGIN
          ;;  V tag is a 2D array  -->  Sort by time
          IF (szdd_1.(2)[1] NE szdd_2.(2)[1]) THEN BEGIN
            ;;  Issue in 2nd dimension --> Default to larger size
            tempv = lbw_append_arr(temp_v,temp2v,LARGER=2)
          ENDIF ELSE BEGIN
            ;;  Same size --> directly append
            tempv = [temp_v,temp2v]
          ENDELSE
          ;;  Apply sort
          tempv = TEMPORARY(tempv[sp,*])
        ENDIF ELSE BEGIN
          ;;  V tag is a 1D array  -->  No time-dependent sorting necessary
          ;;    Force to 2D to avoid issues in other routines
          tempv = REPLICATE(1e0,N_ELEMENTS(tempx)) # temp_v
        ENDELSE
        ;;  Replace zeros with NaNs
        bad            = WHERE(FINITE(tempv) EQ 0 OR tempv LE 0,bd)
        IF (bd[0] GT 0) THEN tempv[bad] = d
        ;;  Define data structure for TPLOT
        tstrc          = {X:tempx,Y:tempy,V:tempv}
        ;;  Extract tags from LIMITS structures
        extract_tags,dopts_str,dlim,EXCEPT_TAGS=['YRANGE']      ;;  Get current default plot limits settings
        extract_tags,opts__str, lim,EXCEPT_TAGS=['YRANGE']
        dlim_tags      = TAG_NAMES(dopts_str)
        lim__tags      = TAG_NAMES(opts__str)
        extract_tags,dopts_str,dlim2,EXCEPT_TAGS=dlim_tags
        extract_tags,opts__str, lim2,EXCEPT_TAGS=lim__tags
        ;;  Send results to TPLOT
        store_data,tpns1[tj],DATA=tstrc,DLIMIT=dopts_str,LIMIT=opts__str
        ;;  Remove TPLOT handle associated with DAT_STR2
        store_data,DELETE=tpns2[tj]
        ;;  Clean up
        temp_x    = 0 & temp_y    = 0 & temp_v    = 0
        temp2x    = 0 & temp2y    = 0 & temp2v    = 0
        tempx     = 0 & tempy     = 0 & tempv     = 0
        tstrc     = 0 & dopts_str = 0 & opts__str = 0
      ENDIF
    ENDIF
  ENDFOR
ENDIF
;;----------------------------------------------------------------------------------------
;;  Set default TPLOT options
;;----------------------------------------------------------------------------------------
nnw            = tnames([omni_tpn,pad_omni__tpn,pad_spec_tpns])
options,nnw,/YSTYLE,PANEL_SIZE=2e0,XMINOR=5,XTICKLEN=0.04,YTICKLEN=0.01
;;  Remove corresponding default options [to avoid overlap and/or conflicts]
options,nnw,    'YSTYLE',/DEF
options,nnw,'PANEL_SIZE',/DEF
options,nnw,    'XMINOR',/DEF
options,nnw,  'XTICKLEN',/DEF
options,nnw,  'YTICKLEN',/DEF
;;  Remove the MAX_VALUE setting
options,nnw, 'MAX_VALUE'
options,nnw, 'MAX_VALUE',/DEF
;;----------------------------------------------------------------------------------------
;;  Calculate anisotropy
;;    (i.e., para/perp and para/anti)
;;----------------------------------------------------------------------------------------
ind_para       = 0L
ind_perp       = (num_pa[0]/2L) - 1L
ind_anti       = num_pa[0] - 2L
pad_tpn_para   = tnames(pad_spec_tpns[ind_para[0]])
pad_tpn_perp   = tnames(pad_spec_tpns[ind_perp[0]])
pad_tpn_anti   = tnames(pad_spec_tpns[ind_anti[0]])
test           = (pad_tpn_para[0] EQ '') OR (pad_tpn_perp[0] EQ '') OR (pad_tpn_anti[0] EQ '')
IF (test[0]) THEN STOP        ;;  Problem --> Go no further
;;  Get data from TPLOT
get_data,pad_tpn_para[0],DATA=temp_para,DLIMIT=dlim_para,LIMIT=lim_para
get_data,pad_tpn_perp[0],DATA=temp_perp,DLIMIT=dlim_perp,LIMIT=lim_perp
get_data,pad_tpn_anti[0],DATA=temp_anti,DLIMIT=dlim_anti,LIMIT=lim_anti
;;  Define data parameters
para_x         = temp_para.X
para_v         = temp_para.V
para_y         = temp_para.Y
perp_y         = temp_perp.Y
anti_y         = temp_anti.Y
;;  Calculate ratios
ratio_paraperp = para_y/perp_y
ratio_paraanti = para_y/anti_y
struc_paraperp = {X:para_x,Y:ratio_paraperp,V:para_v}
struc_paraanti = {X:para_x,Y:ratio_paraanti,V:para_v}
;;----------------------------------------------------------------------------------------
;;  Define TPLOT parameters
;;----------------------------------------------------------------------------------------
;;  Define range of angles [deg] corresponding to each TPLOT variable
para_ang_ra    = STRTRIM(STRING(ROUND(lim_para.S_VALUE),FORMAT='(I)'),2L)
perp_ang_ra    = STRTRIM(STRING(ROUND(lim_perp.S_VALUE),FORMAT='(I)'),2L)
anti_ang_ra    = STRTRIM(STRING(ROUND(lim_anti.S_VALUE),FORMAT='(I)'),2L)
para_ang_ra    = para_ang_ra[0]+'-'+para_ang_ra[1]
perp_ang_ra    = perp_ang_ra[0]+'-'+perp_ang_ra[1]
anti_ang_ra    = anti_ang_ra[0]+'-'+anti_ang_ra[1]
;;  Define TPLOT YTITLE and YSUBTITLE strings
yttl_anisotro  = data_str[0]+' '+units[0]+' ['+yttl_frame[0]+']'
ymid_paraperp  = lab_strings[0]+'-to-'+lab_strings[1]
ymid_paraanti  = lab_strings[0]+'-to-'+lab_strings[2]
ysuf_paraperp  = lab_strings[0]+'_to_'+lab_strings[1]
ysuf_paraanti  = lab_strings[0]+'_to_'+lab_strings[2]
ysub_paraperp  = '['+ymid_paraperp[0]+' ratio]'
note_paraperp  = '['+para_ang_ra[0]+' deg] / ['+perp_ang_ra[0]+' deg]'
ysub_paraanti  = '['+lab_strings[0]+'-to-'+lab_strings[2]+' ratio]'
note_paraanti  = '['+para_ang_ra[0]+' deg] / ['+anti_ang_ra[0]+' deg]'
;;  Define TPLOT handles for anisotropies
tpn__paraperp  = pad_omni__tpn[0]+'_'+ysuf_paraperp[0]
tpn__paraanti  = pad_omni__tpn[0]+'_'+ysuf_paraanti[0]
;;----------------------------------------------------------------------------------------
;;  Define plot LIMITS structures
;;----------------------------------------------------------------------------------------
extract_tags, lim, lim_para,EXCEPT_TAGS=['YRANGE','S_VALUE']      ;;  Get current plot limits settings
extract_tags,dlim,dlim_para,EXCEPT_TAGS=['YRANGE','THICK']      ;;  Get current default plot limits settings

str_element,     dlim,   'YTITLE', yttl_anisotro[0],/ADD_REPLACE
dlim_rat1      = dlim
dlim_rat2      = dlim
str_element,dlim_rat1,'YSUBTITLE', ysub_paraperp[0],/ADD_REPLACE
str_element,dlim_rat1,     'NOTE', note_paraperp[0],/ADD_REPLACE
str_element,dlim_rat2,'YSUBTITLE', ysub_paraanti[0],/ADD_REPLACE
str_element,dlim_rat2,     'NOTE', note_paraanti[0],/ADD_REPLACE
;;----------------------------------------------------------------------------------------
;;  Send to TPLOT
;;----------------------------------------------------------------------------------------
store_data,tpn__paraperp[0],DATA=struc_paraperp,DLIMIT=dlim_rat1,LIMIT=lim
store_data,tpn__paraanti[0],DATA=struc_paraanti,DLIMIT=dlim_rat2,LIMIT=lim
;;  Add to TPN_STRUC
str_element,tpn_struc,   'ANIS.PAD_PAR_2_PER_N',tpn__paraperp[0],/ADD_REPLACE
str_element,tpn_struc,   'ANIS.PAD_PAR_2_ANT_N',tpn__paraanti[0],/ADD_REPLACE
;;----------------------------------------------------------------------------------------
;;  Return to user
;;----------------------------------------------------------------------------------------
MESSAGE,STRING(SYSTIME(1) - ex_start[0])+' seconds execution time.',/INFORMATIONAL,/CONTINUE

RETURN
END












