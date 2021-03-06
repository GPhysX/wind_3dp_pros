;+
;*****************************************************************************************
;
;  FUNCTION :   tplot.pro
;  PURPOSE  :   Creates (a) time series plot(s) of user defined quantities stored as
;                 pointer-heap variables in IDL.  The variables have string and
;                 integer tags associated with them allowing them to be called from
;                 multiple places.
;
;  CALLED BY:   
;               NA
;
;  INCLUDES:
;               NA
;
;  CALLS:
;               tplot_com.pro
;               printdat.pro
;               tplot_options.pro
;               time_double.pro
;               extract_tags.pro
;               ctime.pro
;               tnames.pro
;               str_element.pro
;               get_data.pro
;               dprint.pro
;               plot_positions.pro
;               minmax.pro
;               time_ticks.pro
;               data_cut.pro
;               timetick.pro
;               time_string.pro
;               box.pro
;               get_ylimits.pro
;               specplot.pro
;               mplot.pro
;
;  REQUIRES:    
;               1)  SPEDAS IDL libraries or UMN Modified Wind/3DP IDL Libraries
;
;  INPUT:
;               DATANAMES          :  Scalar or [N]-element array of TPLOT handles as
;                                       either numeric indices or strings.  If omitted,
;                                       the most recent data values are used instead.
;                                       Each name MUST be associated with a TPLOT
;                                       quantity.  To see a list, run tplot_names.pro.
;
;  EXAMPLES:    
;               **  => [after running _get_example_dat.pro] <=  **
;               tplot,'amp slp flx2'    ; => Plots the named quantities
;           =============================================================
;           **  =>   tplot,['amp','slp','flx2'] OR tplot,[1,2,4]   <=  **
;           =============================================================
;               tplot,'flx1',/ADD_VAR   ; => Adds the quantity to the TPLOT quantities
;               tplot                   ; => Re-plot the last plot
;               tplot,VAR_LABEL=['alt'] ; => Put Distance labels at bottom of plot
;               ;-------------------------------------------------------------------------
;               ; => To get a list of the TPLOT names, do:
;               ;-------------------------------------------------------------------------
;               tplot_names,NAMES=names   ; **  => same as names = tnames()
;               tplot,names[0:2]          ; => Plots 'amp','slp', and 'flx1'
;               ;-------------------------------------------------------------------------
;               ; => To see more examples, look at file:  _tplot_example.pro
;               ;-------------------------------------------------------------------------
;
;  KEYWORDS:    
;               WINDOW             :  Scalar [numeric] defining the window to be used
;                                       for all time plots.  If set to -1, then the
;                                       current window is used.
;                                       [Default = 0]
;               NOCOLOR            :  Set this to produce plot without color.
;               VERSION            :  Must be 1,2,3, or 4 [Uses a different labeling]
;                                       [Default = 3]
;               OPLOT              :  Will not erase the previous screen if set.
;               OVERPLOT           :  Will not erase the previous screen if set.
;               TITLE              :  A string to be used for the title.
;                                       [Remembered for future plots.]
;               LASTVAR            :  Set this variable to plot the previous variables
;                                       plotted in a TPLOT window.
;               ADD_VAR            :  Set this variable to add datanames to the previous
;                                       plot.  If set to 1, the new panels will appear
;                                       at the top (position 1) of the plot.  If set to
;                                       2, they will be inserted directly after the
;                                       first panel and so on.  Set this to a value
;                                       greater than the existing number of panels in
;                                       your tplot window to add panels to the bottom
;                                       of the plot.
;               REFDATE            :  Scalar [string] defining the reference date for
;                                       the time series ['YYYY-MM-DD']
;               VAR_LABEL          :  String [array]; Variable(s) used for putting
;                                       labels along the bottom.  This allows quantities
;                                       such as altitude to be labeled.
;               OPTIONS            :  A TPLOT structure that can contain keywords for the
;                                       IDL built-in PLOT.PRO
;               T_OFFSET           :  A named variable to be returned to the user
;                                       containing the Unix time offset from
;                                       Jan 1st, 1970 (seconds)
;               TRANGE             :  [2]-Element [numeric] array of Unix times defining
;                                       the time range to be shown
;                                       [Default = currently shown or full time range]
;               NAMES              :  The names of the tplot variables that are plotted.
;               PICK               :  If set, user can define desired panels to plot
;                                       with mouse
;               NEW_TVARS          :  Returns the tplot_vars structure for the plot
;                                       created.   Set aside the structure so that it
;                                       may be restored using the OLD_TVARS keyword
;                                       later.  This structure includes information about
;                                       various TPLOT options and settings and can be
;                                       used to recreates a plot.
;               OLD_TVARS          :  Use this to pass an existing tplot_vars structure
;                                       to override the one in the tplot_com common block.
;               DATAGAP            :  **Obselete**
;               HELP               :  Set this to print the contents of the
;                                       tplot_vars.OPTIONS (user-defined options)
;                                       structure.
;               SPEC_RES           :  A scalar defining the number of pixels per inch
;                                       for PS files
;               NOMSSG             :  If set, TPLOT will NOT print out the index and
;                                       TPLOT handle of the variables being plotted
;               GET_PLOT_POSITION  :  Returns an array containing the corners of each
;                                       panel in the plot, to make it easier to
;                                       overplot and annotate plots
;
;   CHANGED:  1)  Davin Larson changed something...
;                                                                   [11/01/2002   v1.0.97]
;             2)  Re-wrote and cleaned up
;                                                                   [06/10/2009   v1.1.0]
;             3)  Added keyword:  Z_BUFF
;                                                                   [06/11/2009   v1.2.0]
;             4)  Added keyword:  SPEC_RES
;                                                                   [06/11/2009   v1.3.0]
;             5)  Updated man page
;                                                                   [06/17/2009   v1.3.1]
;             6)  Added keyword:  NOMSSG
;                                                                   [09/29/2009   v1.3.2]
;             7)  Changed an optional parameter, NUM_LAB_MIN, to force the minimum
;                   number of TPLOT time labels to = 4 instead of 2
;                                                                   [09/30/2009   v1.3.3]
;             8)  Changed the tick label format to be more dynamic and robust
;                   and eliminated pointer usage in the plotting part of program
;                                                                   [10/01/2010   v1.4.0]
;             9)  Corrected missed print statement associated with NOMSSG keyword
;                                                                   [10/07/2010   v1.4.1]
;            10)  Updated to be in accordance with newest version of tplot.pro in TDAS
;                   A)  now calls dprint.pro
;                   B)  no longer calls data_type.pro or ndimen.pro
;                   C)  removed obsolete Z_BUFF keyword
;                   D)  no longer uses () for arrays
;                                                                   [03/24/2012   v1.5.0]
;            11)  Updated to be in accordance with newest version of tplot.pro
;                   in TDAS IDL libraries [thmsw_r10908_2012-09-10]
;                   A)  new keywords:  GET_PLOT_POSITION
;                   B)  new functionalities
;                                                                   [09/12/2012   v1.6.0]
;            12)  Removed dependence on undefined.pro
;                                                                   [09/19/2012   v1.6.1]
;            13)  Fixed a bug when using the NOMSSG keyword and plotting a TPLOT
;                   handle that is composed of other TPLOT handles
;                                                                   [11/14/2013   v1.6.2]
;            14)  Updated Man. page and updated to be in accordance with SPEDAS version
;                   last modified on Jan. 8, 2016
;                                                                   [02/04/2016   v1.6.3]
;
;   NOTES:      
;               1)  Lists of examples are found in _tplot_example.pro
;               2)  Use tnames.pro to return an array of current names.
;               3)  Use "TPLOT_NAMES" to print a list of acceptable names to plot.
;               4)  Use "TPLOT_OPTIONS" for setting various global options. 
;               5)  Plot limits can be set with the "YLIM" procedure or by using:
;                       options,[TPLOT Name],'YRANGE',[y_min,y_max]
;                       options,[TPLOT Name],'YSTYLE',1
;               6)  Spectrogram limits can be set with the "ZLIM" procedure or by using:
;                       options,[TPLOT Name],'ZRANGE',[z_min,z_max] etc.
;               7)  Time limits can be set with the "TLIMIT" procedure.
;               8)  The "OPTIONS" procedure can be used to set all IDL plotting
;                       keyword parameters (i.e. psym, color, linestyle, etc) as well
;                       as some keywords that are specific to tplot 
;                       (i.e. panel_size, labels, etc.)  For example, to change the 
;                       relative panel width for the quantity 'slp', run the following:
;                       options,'slp','PANEL_SIZE',1.5
;               9)  TPLOT calls the routine "SPECPLOT" to make spectrograms and 
;                       calls "MPLOT" to make the line plots. See these routines to 
;                       determine what other options are available.
;               10) Use "GET_DATA" to retrieve the data structure (or limit structure) 
;                       associated with a TPLOT quantity.
;               11) Use "STORE_DATA" to create new TPLOT quantities to plot.
;               12) The routine "DATA_CUT" can be used to extract interpolated data.
;               13) The routine "TSAMPLE" can also be used to extract data.
;               14) Time stamping is performed with the routine "TIME_STAMP".
;               15) Use "CTIME" or "GETTIME" to obtain time values.
;               16) TPLOT variables can be stored in files using "TPLOT_SAVE" and loaded
;                       again using "TPLOT_RESTORE"
;
;  SEE ALSO:
;               tplot_names.pro
;               tplot_options.pro
;               mplot.pro
;               specplot.pro
;               get_data.pro
;               store_data.pro
;               time_stamp.pro
;               tplot_save.pro
;               tplot_restore.pro
;               tplot_com.pro
;
;  REFERENCES:  
;               NA
;
;   CREATED:  June, 1995
;   CREATED BY:  Davin Larson
;    LAST MODIFIED:  02/04/2016   v1.6.3
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

PRO tplot,datanames,                               $
                    WINDOW            = wind,      $
                    NOCOLOR           = nocolor,   $
                    VERSION           = ver,       $
                    OPLOT             = oplot,     $
                    OVERPLOT          = overplot,  $
                    TITLE             = title,     $
                    LASTVAR           = lastvar,   $
                    ADD_VAR           = add_var,   $
                    REFDATE           = refdate,   $
                    VAR_LABEL         = var_label, $
                    OPTIONS           = opts,      $
                    T_OFFSET          = t_offset,  $
                    TRANGE            = trng,      $
                    NAMES             = names,     $
                    PICK              = pick,      $
                    NEW_TVARS         = new_tvars, $
                    OLD_TVARS         = old_tvars, $
                    DATAGAP           = datagap,   $
                    HELP              = help,      $
                    SPEC_RES          = spec_res,  $
                    NOMSSG            = nom,       $
                    GET_PLOT_POSITION = pos

;;----------------------------------------------------------------------------------------
;; Set common blocks:
;;----------------------------------------------------------------------------------------
@tplot_com.pro
;;----------------------------------------------------------------------------------------
;;  Check for imbedded calls
;;----------------------------------------------------------------------------------------
;  TDAS Update
IF 1 THEN BEGIN
  stack       = scope_traceback(/STRUCTURE)
  stack       = stack[0L:(N_ELEMENTS(stack) - 2L)]
  nocallsfrom = ['CTIME','TPLOT']
  incommon    = array_union(nocallsfrom,stack.ROUTINE)
  w = where(incommon NE -1,nw)
  IF (nw GT 0) THEN BEGIN
    dprint,DLEVEL=2,'Calls to TPLOT are not allowed from within '+STRUPCASE(nocallsfrom[w])
    RETURN
  ENDIF
ENDIF
;;----------------------------------------------------------------------------------------
;;  Check for default verbose value if it exists
;;----------------------------------------------------------------------------------------
;  TDAS Update
IF (SIZE(verbose,/TYPE) EQ 0) THEN str_element,tplot_vars,'OPTIONS.VERBOSE',verbose
IF (SIZE(wshow,  /TYPE) EQ 0) THEN str_element,tplot_vars,'OPTIONS.WSHOW',wshow

;;----------------------------------------------------------------------------------------
;;  Override existing tplot_vars structure if necessary
;;----------------------------------------------------------------------------------------
IF KEYWORD_SET(old_tvars) THEN tplot_vars = old_tvars
  
IF KEYWORD_SET(help) THEN BEGIN
;  TDAS Update
;  printdat,tplot_vars.OPTIONS
  printdat,tplot_vars.OPTIONS,VARNAME='TPLOT_VARS.OPTIONS'
  new_tvars = tplot_vars
  RETURN
ENDIF
;;----------------------------------------------------------------------------------------
;;  Setup tplot_vars....
;;----------------------------------------------------------------------------------------
tplot_options,VERSION=ver,TITLE=title,VAR_LABEL=var_label,REFDATE=refdate, $
              WINDOW=wind,OPTIONS=opts
;;----------------------------------------------------------------------------------------
;;  Define some defaults
;;----------------------------------------------------------------------------------------
IF KEYWORD_SET(overplot) THEN oplot = overplot
IF (N_ELEMENTS(trng) EQ 2) THEN trange = time_double(trng)

chsize = !P.CHARSIZE
IF (chsize EQ 0.) THEN chsize = 1.

def_opts= {YMARGIN:[4.,2.],XMARGIN:[12.,12.],POSITION:FLTARR(4),TITLE:'', $
           YTITLE:'',XTITLE:'',XRANGE:DBLARR(2),VERSION:3,                $
           WINDOW:-1, WSHOW:0,XSTYLE:1,CHARSIZE:chsize,NOERASE:0,         $
           OVERPLOT:0,SPEC:0                                               }

extract_tags,def_opts,tplot_vars.OPTIONS
;;----------------------------------------------------------------------------------------
;; Define the variables to be plotted:
;;----------------------------------------------------------------------------------------
IF KEYWORD_SET(pick) THEN $
  ctime,PROMPT='Click on desired panels. (button 3 to quit)',PANEL=mix,/SILENT
IF (N_ELEMENTS(mix) NE 0) THEN datanames = tplot_vars.SETTINGS.VARNAMES[mix]

IF KEYWORD_SET(add_var) THEN BEGIN
  names = tnames(datanames,/ALL)
  IF (add_var EQ 1) THEN datanames = [names,tplot_vars.OPTIONS.VARNAMES] ELSE $
  IF (add_var GT N_ELEMENTS(tplot_vars.OPTIONS.VARNAMES)) THEN BEGIN
    datanames = [tplot_vars.OPTIONS.VARNAMES,names]
  ENDIF ELSE BEGIN
    datanames = [tplot_vars.OPTIONS.VARNAMES[0:add_var-2],names,$
                 tplot_vars.OPTIONS.VARNAMES[add_var-1:*]]
  ENDELSE
ENDIF

dt   = SIZE(/TYPE,datanames)          ; => Determine if integer or string
ndim = SIZE(/N_DIMENSIONS,datanames)  ; => Determine the number of dimensions

IF (dt NE 0) THEN BEGIN
  IF (dt NE 7 OR ndim GE 1) THEN BEGIN
    dnames = STRJOIN(tnames(datanames,/ALL),' ')
  ENDIF ELSE BEGIN
    dnames = datanames
  ENDELSE
ENDIF ELSE BEGIN
  tpv_opt_tags = TAG_NAMES(tplot_vars.OPTIONS)
  idx          = WHERE(tpv_opt_tags EQ 'DATANAMES',icnt)
  IF (icnt GT 0) THEN BEGIN
    ; => found structure tag
    dnames = tplot_vars.OPTIONS.DATANAMES
  ENDIF ELSE BEGIN
    ; => no structure tag found, so leave
    RETURN
  ENDELSE
ENDELSE
;;----------------------------------------------------------------------------------------
;;  Plot last variables if desired
;;----------------------------------------------------------------------------------------
IF KEYWORD_SET(lastvar) THEN str_element,tplot_vars,'SETTINGS.LAST_VARNAMES',names
str_element,tplot_vars,'OPTIONS.LAZY_YTITLE',lazy_ytitle

varnames = tnames(dnames,nd,INDEX=ind,/ALL)

str_element,tplot_vars,'OPTIONS.DATANAMES',dnames,/ADD_REPLACE
str_element,tplot_vars,'OPTIONS.VARNAMES',varnames,/ADD_REPLACE

IF (nd EQ 0) THEN BEGIN
;  TDAS Update
;  MESSAGE,'No valid variable names found to tplot! (use TPLOT_NAMES to display)',/CONTINUE,/INFORMATIONAL
  dprint,'No valid variable names found to tplot! (use TPLOT_NAMES to display)',$
         DLEVEL=0,VERBOSE=verbose
  RETURN
ENDIF
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
sizes = FLTARR(nd)
FOR i=0, nd - 1L DO BEGIN
   dum = 1.
   lim = 0
   get_data,tplot_vars.OPTIONS.VARNAMES[i],ALIM=lim
   str_element,lim,'PANEL_SIZE',VALUE=dum
   sizes[i] = dum
ENDFOR
;;----------------------------------------------------------------------------------------
;;  Plot and window structure info
;;----------------------------------------------------------------------------------------
plt = {X:!X,Y:!Y,Z:!Z,P:!P}
;;----------------------------------------------------------------------------------------
;;  Define window devices
;;----------------------------------------------------------------------------------------
IF ((!D.FLAGS AND 256) NE 0) THEN BEGIN
   current_window = !D.WINDOW > 0
   IF (def_opts.WINDOW GE 0) THEN w = def_opts.WINDOW ELSE w = current_window
   ; => test to see if this window exists before wset, jmm, 7-may-2008:
   ;      removed upper limit on window number, jmm, 19-mar-2009
   DEVICE,WINDOW_STATE=wins
   IF (w EQ 0 OR wins[w]) THEN BEGIN
     WSET,w
   ENDIF ELSE BEGIN
;  TDAS Update
;     dprint, 'Window is closed and Unavailable, Returning'
     dprint,'Window is closed and Unavailable, Returning',VERBOSE=verbose
     w               = current_window
     def_opts.WINDOW = w
     tplot_options,WINDOW=w
     RETURN
   ENDELSE
;  TDAS Update
;   IF (def_opts.WSHOW NE 0) THEN WSHOW;,ICON=0   ; The icon=0 option doesn't work with windows
   IF (def_opts.WSHOW NE 0) || KEYWORD_SET(wshow) THEN WSHOW ;,icon=0   ; The icon=0 option doesn't work with windows
   str_element,def_opts,'WSIZE',VALUE=wsize
   ; => Open new window
   wi,w,WSIZE=wsize
ENDIF

str_element,tplot_vars,'SETTINGS.Y',REPLICATE(!Y,nd),/ADD_REPLACE
str_element,tplot_vars,'SETTINGS.CLIP',LONARR(6,nd),/ADD_REPLACE
str_element,def_opts,'YGAP',VALUE=ygap
str_element,def_opts,'CHARSIZE',VALUE=chsize

IF KEYWORD_SET(nocolor) THEN str_element,def_opts,'NOCOLOR',nocolor,/ADD_REPLACE

nvlabs = [0.,0.,0.,1.,0.]
str_element,tplot_vars,'OPTIONS.VAR_LABEL',var_label
IF KEYWORD_SET(var_label) THEN BEGIN
  IF (SIZE(var_label,/TYPE) EQ 7) THEN BEGIN
    IF (SIZE(var_label,/N_DIMENSIONS) EQ 0) THEN var_label = tnames(var_label) ;,/extrac)
  ENDIF
ENDIF
;  TDAS Update
IF (def_opts.VERSION LT 1 OR def_opts.VERSION GT 5) THEN def_opts.VERSION = 3
; => ensure the index does not go out of range, other values will use default
nvl               = N_ELEMENTS(var_label) + nvlabs[def_opts.VERSION]
def_opts.YMARGIN += [nvl,0.]
;;----------------------------------------------------------------------------------------
;;  Define window size(s) and position(s)
;;----------------------------------------------------------------------------------------
!P.MULTI = 0
pos = plot_positions(YSIZES=sizes,OPTIONS=def_opts,YGAP=ygap)
;;----------------------------------------------------------------------------------------
;;  Define time range
;;----------------------------------------------------------------------------------------
IF KEYWORD_SET(trange) THEN BEGIN
  str_element,tplot_vars,'OPTIONS.TRANGE',trange,/ADD_REPLACE
ENDIF ELSE BEGIN
  str_element,tplot_vars,'OPTIONS.TRANGE',trange
ENDELSE

IF (trange[0] EQ trange[1]) THEN BEGIN
  trg = minmax(REFORM(data_quants[ind].TRANGE),MIN_VALUE=0.1)
ENDIF ELSE BEGIN
  trg = trange
ENDELSE
;;----------------------------------------------------------------------------------------
;;  Define TPLOT Version definitions
;;----------------------------------------------------------------------------------------
CASE def_opts.VERSION OF
  3    : BEGIN
    str_element,def_opts,'NUM_LAB_MIN', VALUE=num_lab_min
    str_element,def_opts,'TICKINTERVAL',VALUE=tickinterval
    str_element,def_opts,'XTITLE',      VALUE=xtitle
    IF NOT KEYWORD_SET(num_lab_min) THEN BEGIN
      num_lab_min = 4. > (.035*(pos[2,0] - pos[0,0])*!D.X_SIZE/(chsize*!D.X_CH_SIZE))
    ENDIF
;  TDAS Update
;    time_setup = time_ticks(trg,time_offset,NUM_LAB_MIN=num_lab_min,SIDE=vtitle, $
;                                            XTITLE=xtitle,TICKINTERVAL=tickinterval)
    time_setup = time_ticks(trg,time_offset,NUM_LAB_MIN=num_lab_min,SIDE=vtitle, $
                            XTITLE=xtitle,TICKINTERVAL=tickinterval,$
                            LOCAL_TIME=local_time)
    time_scale = 1.
  END
  2    : BEGIN
    time_setup = timetick(trg[0],trg[1],0,time_offset,xtitle)
    time_scale = 1.
  END
  1    : BEGIN
    deltat = trg[1] - trg[0]
    CASE 1 OF
      (deltat LT 6d1)            : BEGIN
        time_scale = 1.
        tu         = 'Seconds'
        p          = 16
      END
      (deltat LT 36d2)           : BEGIN
        time_scale = 6d1
        tu         = 'Minutes'
        p          = 13
      END
      (deltat LE 864d2)          : BEGIN
        time_scale = 36d2
        tu         = 'Hours'
        p          = 10
      END
      (deltat LE 864d2*365.25d0) : BEGIN
        time_scale = 864d2
        tu         = 'Days'
        p          = 7
      END
      ELSE                       : BEGIN
        time_scale = 864d2*365.25d0
        tu         = 'Years'
        p          = 5
      END
    ENDCASE
    ref             = STRMID(time_string(trg[0]),0,p)
    time_offset     = time_double(ref)
    def_opts.XTITLE = 'Time (UT)  '+tu+' after '+ref
    str_element,def_opts,'XTICKNAME',REPLICATE('',22),/ADD_REPLACE
  END
  4    : BEGIN
    deltat          = trg[1] - trg[0]
    time_scale      = 1.
    tu              = 'Seconds'
    p               = 16
    ref             = STRMID(time_string(trg[0]),0,p)
    time_offset     = 0
    PRINT, ref+' '+tu, p, time_offset - trg[0]
    def_opts.XTITLE = tu+' after launch'
    str_element,def_opts,'XTICKNAME',REPLICATE('',22),/ADD_REPLACE
  END
;  TDAS Update
  5    : BEGIN
    ;; version eq 5 is identical to version eq 3 except that time labels are supressed
    str_element,def_opts,'NUM_LAB_MIN', VALUE=num_lab_min
    str_element,def_opts,'TICKINTERVAL',VALUE=tickinterval
    str_element,def_opts,'XTITLE',      VALUE=xtitle
    IF NOT KEYWORD_SET(num_lab_min) THEN BEGIN
      num_lab_min = 4. > (.035*(pos[2,0] - pos[0,0])*!D.X_SIZE/(chsize*!D.X_CH_SIZE))
    ENDIF
    time_setup = time_ticks(trg,time_offset,NUM_LAB_MIN=num_lab_min,SIDE=vtitle, $
                            XTITLE=xtitle,TICKINTERVAL=tickinterval,$
                            LOCAL_TIME=local_time)
    time_scale = 1.
  END
  ELSE : BEGIN
  END
ENDCASE
;;----------------------------------------------------------------------------------------
;;  Special issues for version 5
;;----------------------------------------------------------------------------------------
;  TDAS Update
IF (def_opts.VERSION EQ 5) THEN BEGIN
  vtitle               = ''
  time_setup.XTICKNAME = ' '
  time_setup.XTITLE    = ''
  IF KEYWORD_SET(var_label) THEN BEGIN
    time = time_setup.XTICKV + time_offset
    FOR i=0L, N_ELEMENTS(var_label) - 1L DO BEGIN
      vtit = strmid(var_label[i],0,3)
      get_data,var_label[i],DATA=pdata,ALIMITS=limits
;      get_data,var_label[i],ptr=pdata,alimits=limits
      IF (SIZE(pdata,/TYPE) NE 8) THEN BEGIN
        dprint,VERBOSE=verbose,var_label[i],' not valid!'
;      if size(/type,pdata) ne 8 then  dprint,verbose=verbose,var_label[i], ' not valid!'  $
      ENDIF ELSE BEGIN
        def  = {YTITLE:vtit,FORMAT:'(F6.1)'}
;            extract_tags,def,data,tags = ['ytitle','format']
        extract_tags,def,limits,TAGS=['ytitle','format']
        v    = data_cut(var_label[i],time)
        vlab = STRCOMPRESS(STRING(v,FORMAT=def.FORMAT),/REMOVE_ALL)
        w    = WHERE(FINITE(v) EQ 0,nw)
        IF (nw GT 0) THEN vlab[w] = ''
        
        IF (i EQ 0) THEN BEGIN
          vtitle                  = def.YTITLE + vtitle
          time_setup.XTICKNAME[*] = vlab+time_setup.XTICKNAME
          time_setup.XTITLE       = ''+time_setup.XTITLE
        ENDIF ELSE BEGIN
          vtitle               = def.YTITLE+'!C'+vtitle
          time_setup.XTICKNAME = vlab+'!C'+time_setup.XTICKNAME
          time_setup.XTITLE    = '!C'+time_setup.XTITLE
        ENDELSE
      ENDELSE
    ENDFOR
  ENDIF
  extract_tags,def_opts,time_setup
ENDIF
;;----------------------------------------------------------------------------------------
; => Special issues for versions 2 and 3
;;----------------------------------------------------------------------------------------
IF (def_opts.VERSION EQ 2 OR def_opts.VERSION EQ 3) THEN BEGIN
  IF KEYWORD_SET(var_label) THEN BEGIN
    time   = time_setup.XTICKV + time_offset
    IF (def_opts.VERSION EQ 2) THEN vtitle = 'UT'
    FOR i=0L, N_ELEMENTS(var_label) - 1L DO BEGIN
      vtit = STRMID(var_label[i],0,3)
      get_data,var_label[i],DATA=pdata,ALIMITS=limits
      IF (SIZE(/TYPE,pdata) NE 8) THEN BEGIN
        dprint,var_label[i],' not valid!'
      ENDIF ELSE BEGIN
        ; => Make the tick label format dynamic
        vtlen = STRLEN(STRTRIM(STRING(FORMAT='(f20.2)',pdata.Y),2L))
        IF (MAX(vtlen,/NAN) GE 7L) THEN mform = '(g9.3)' ELSE mform = '(f8.2)'
        def   = {YTITLE:vtit,FORMAT:mform}
        extract_tags,def,limits,TAGS=['YTITLE','FORMAT']
        v     = data_cut(var_label[i],time)
        vlab  = STRCOMPRESS(STRING(v,FORMAT=def.FORMAT),/REMOVE_ALL)
        IF (def_opts.VERSION EQ 3) THEN BEGIN
          ;;------------------------------------------------------------------------------
          ;;  Version 3 issues
          ;;------------------------------------------------------------------------------
          w    = WHERE(FINITE(v) EQ 0,nw)
          IF (nw GT 0) THEN vlab[w] = ''
          vtitle                = def.YTITLE+'!C'+vtitle
          time_setup.XTICKNAME  = vlab+'!C'+time_setup.XTICKNAME
          time_setup.XTITLE     = '!C'+time_setup.XTITLE
        ENDIF ELSE BEGIN
          ;;------------------------------------------------------------------------------
          ;;  Version 2 issues
          ;;------------------------------------------------------------------------------
          vtitle               += '!C'+def.YTITLE
          time_setup.XTICKNAME += '!C'+vlab
          xtitle                = '!C'+xtitle
        ENDELSE
      ENDELSE
    ENDFOR
    IF (def_opts.VERSION EQ 2) THEN def_opts.XTITLE = xtitle
  ENDIF ELSE BEGIN
    IF (def_opts.VERSION EQ 2) THEN def_opts.XTITLE = 'Time (UT) '+xtitle
  ENDELSE
  extract_tags,def_opts,time_setup
ENDIF
;; return time_offset in the t_offset keyword, if requested
;  TDAS Update
;IF undefined(time_offset) THEN BEGIN
IF (SIZE(time_offset,/TYPE) EQ 0) THEN BEGIN
  dprint,'Illegal time interval.',DLEVEL=1
  RETURN
ENDIF
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
t_offset          = time_offset
def_opts.XRANGE   = (trg - time_offset)/time_scale
IF KEYWORD_SET(oplot) THEN def_opts.NOERASE = 1
init_opts         = def_opts
init_opts.XSTYLE  = 5

IF (init_opts.NOERASE EQ 0) THEN ERASE
init_opts.NOERASE = 1
str_element,init_opts,'YSTYLE',5,/ADD_REPLACE
;;----------------------------------------------------------------------------------------
;;  Define plot axes outline area in device
;;----------------------------------------------------------------------------------------
box,init_opts

def_opts.NOERASE  = 1
str_element,tplot_vars,'OPTIONS.TIMEBAR',tbnames
IF KEYWORD_SET(tbnames) THEN BEGIN
   tbnames = tnames(tbnames)
   ntb = N_ELEMENTS(tbnames)
   FOR i=0L, ntb - 1L DO BEGIN
      t = 0
      get_data,tbnames[i],DATA=d
      str_element,d,'X',t
      str_element,d,'TIME',t
      FOR j=0L, N_ELEMENTS(t) - 1 DO BEGIN
        OPLOT,(t[j] - time_offset)/time_scale*[1,1],[0,1],LINESTYLE=1
      ENDFOR
   ENDFOR
ENDIF
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
str_element,/ADD_REPLACE,tplot_vars,'SETTINGS.Y', REPLICATE(!Y,nd)
str_element,/ADD_REPLACE,tplot_vars,'SETTINGS.CLIP',LONARR(6,nd)
;;----------------------------------------------------------------------------------------
;;  Plot data
;;----------------------------------------------------------------------------------------
FOR i=0L, nd - 1L DO BEGIN
  name              = tplot_vars.OPTIONS.VARNAMES[i]
  ;;--------------------------------------------------------------------------------------
  ;;  Get the correct plot position
  ;;--------------------------------------------------------------------------------------
  def_opts.POSITION = pos[*,i]
  get_data,name,ALIMITS=limits,DATA=pdata,INDEX=index,DTYPE=dtype
;  get_data,name,ALIMITS=limits,PTR=pdata,DATA=data,INDEX=index,DTYPE=dtype
;  => LBW 10/01/2010
;      [no longer uses pointers]
  IF (NOT KEYWORD_SET(pdata) AND dtype NE 3) THEN BEGIN
;  TDAS Update
;    dprint,'Undefined variable data: ',name
    dprint,'Undefined variable data: ',name,VERBOSE=verbose
  ENDIF ELSE BEGIN
    IF NOT KEYWORD_SET(nom) THEN dprint,index,name,FORMAT='(i3," ",a)',VERBOSE=verbose,DLEVEL=1
  ENDELSE
  IF KEYWORD_SET(pdata) THEN  nd2 = N_ELEMENTS(pdata) ELSE nd2 = 1
  IF (dtype EQ 3) THEN BEGIN
;    datastr = data
;  => LBW 10/01/2010
;      [no longer uses pointers]
    datastr = pdata
    yrange  = [0.,0.]
    str_element,limits,'YRANGE',yrange
;  TDAS Update
;    IF (SIZE(/N_DIMENSIONS,datastr) EQ 0) THEN datastr = STRSPLIT(datastr,/EXTRACT)
    IF (SIZE(/N_DIMENSIONS,datastr) EQ 0) THEN datastr = tnames(datastr,/ALL)
    nd2 = N_ELEMENTS(datastr)
    IF (yrange[0] EQ yrange[1]) THEN get_ylimits,datastr,limits,trg
  ENDIF ELSE BEGIN
    datastr = 0
  ENDELSE
;  TDAS Update
  ;;  allow label placing for pseudo variables
  all_labels      = ''
  labflag         = 0b
  label_placement = 0  ;; array to determine label positions
  labidx          = 0  ;; offset for indexing position array
  str_element,limits,'LABFLAG',labflag
  IF (nd2 GT 1 && KEYWORD_SET(labflag) && KEYWORD_SET(datastr)) THEN BEGIN
    ;check for labels set on the pseudo variable, use defaults if not set
    str_element,limits,'LABELS',all_labels
    IF ~KEYWORD_SET(ALL_LABELS) THEN BEGIN
      FOR c=0L, nd2 - 1L DO BEGIN
        templab = ''
        get_data,datastr[c],ALIMITS=templim
        str_element,templim,'LABELS',templab
        IF KEYWORD_SET(templab) THEN BEGIN
          all_labels      = KEYWORD_SET(all_labels) ? [all_labels,templab]:templab
          label_placement = [label_placement,REPLICATE(c,N_ELEMENTS(templab))]
        ENDIF
      ENDFOR
    ENDIF
    IF (N_ELEMENTS(label_placement) GT 1) THEN BEGIN
      label_placement = label_placement[1L:(N_ELEMENTS(label_placement) - 1L)]
    ENDIF
  ENDIF
;  TDAS Update
  ;;  allow colors to be set on pseudo variables
  colors_set   = 0b
  color_offset = 0
  str_element,limits,'COLORS',colors_set
  ;;--------------------------------------------------------------------------------------
  ;;  Loop through each plot
  ;;--------------------------------------------------------------------------------------
  FOR d=0L, nd2 - 1L DO BEGIN
    newlim        = def_opts
    newlim.YTITLE = KEYWORD_SET(lazy_ytitle) ? STRJOIN(STRSPLIT(name,'_',/EXTRACT),'!C')  : name
;    newlim.YTITLE = name
    IF KEYWORD_SET(datastr) THEN BEGIN
      name = datastr[d]
      get_data,name,INDEX=index,DATA=pdata,ALIMITS=limits2,DTYPE=dtype
;      get_data,name,INDEX=index,DATA=data,PTR=pdata,ALIMITS=limits2,DTYPE=dtype
;  => LBW 10/01/2010
;      [no longer uses pointers]
      IF NOT KEYWORD_SET(pdata) THEN BEGIN
        dprint,'Unknown variable: ',name,VERBOSE=verbose
      ENDIF ELSE BEGIN
;  TDAS Update
;        IF NOT KEYWORD_SET(nom) THEN dprint,index,name,FORMAT='(i3,"   ",a)'
;        dprint,index,name,FORMAT='(i3,"   ",a)',VERBOSE=verbose,DLEVEL=1
        ;;  LBW III 11/14/2013   v1.6.2
        IF NOT KEYWORD_SET(nom) THEN dprint,index,name,FORMAT='(i3,"   ",a)',VERBOSE=verbose,DLEVEL=1
;        PRINT,index,name,FORMAT='(i3,"   ",a)'
;  => LBW 10/07/2011
      ENDELSE
    ENDIF ELSE BEGIN
      limits2 = 0
    ENDELSE
    ;;------------------------------------------------------------------------------------
    ;;  Redefine time stamps
    ;;------------------------------------------------------------------------------------
    IF (SIZE(/TYPE,pdata) EQ 8) THEN BEGIN
;    IF (dtype EQ 1) THEN BEGIN
      tshift = 0d0
;      str_element,data,'TSHIFT',VALUE=tshift
;      data.X = (*pdata.X - (time_offset - tshift))/time_scale
;  => LBW 10/01/2010
;      [no longer uses pointers]
      str_element,pdata,'TSHIFT',VALUE=tshift
;;  SPEDAS Update
;      ttt_x   = (pdata.X - (time_offset - tshift))/time_scale
      tshift  = tshift[0]      ;;  force to be a scalar
      ttt_x   = (pdata.X - (time_offset - tshift[0]))/time_scale[0]
      pdata.X = ttt_x
    ENDIF ELSE BEGIN
      pdata = {X:DINDGEN(2),Y:FINDGEN(2)}
;  => LBW 10/01/2010
    ENDELSE
;    extract_tags,newlim,data,EXCEPT = ['X','Y','DY','V']
;  => LBW 10/01/2010
;      [no longer uses pointers]
    extract_tags,newlim,pdata,EXCEPT = ['X','Y','DY','V']
    extract_tags,newlim,limits2
    extract_tags,newlim,ylimits
    extract_tags,newlim,limits
    newlim.OVERPLOT = d NE 0
    IF KEYWORD_SET(overplot) THEN newlim.OVERPLOT = 1   ;<- *** LINE ADDED **
    IF (i NE (nd-1L)) THEN newlim.XTITLE = ''
    IF (i NE (nd-1L)) THEN newlim.XTICKNAME = ' '
    ;;------------------------------------------------------------------------------------
    ;;  Pseudo variables
    ;;------------------------------------------------------------------------------------
;  TDAS Update
    ;; add labels if set on pseudo var
    IF KEYWORD_SET(all_labels) THEN BEGIN
      ;; labels not set on pseudo var, placement determined earlier
      IF KEYWORD_SET(label_placement) THEN BEGIN
        label_index = WHERE(label_placement EQ d,nl)
        IF (nl LT 1) THEN label_index = -1
      ;; labels explicitly set on pseudo var, add labels in order
      ENDIF ELSE BEGIN
        label_index = INDGEN(dimen2(data.y)) + labidx
        labidx      = MAX(label_index) + 1
      ENDELSE
      ;; add aggregated labels/indexes for current variable
      str_element,newlim,'label_index',label_index,/ADD_REPLACE
      str_element,newlim,'all_labels',all_labels,/ADD_REPLACE
    ENDIF
    ;; set offset into color array, if plotting pseudo vars this should
    ;;   allow the next variable's trace to start at the proper color
    IF KEYWORD_SET(colors_set) THEN BEGIN
      str_element,newlim,'color_offset',color_offset,/ADD_REPLACE
    ENDIF
    ;;------------------------------------------------------------------------------------
    ;;  Set Y-Axis subtitle
    ;;------------------------------------------------------------------------------------
    ysubtitle = struct_value(newlim,'ysubtitle',DEF='')
    IF KEYWORD_SET(ysubtitle) THEN newlim.YTITLE += '!C'+ysubtitle
    ;-------
    IF (newlim.SPEC NE 0) THEN routine = 'specplot' ELSE routine = 'mplot'
    str_element,newlim,'TPLOT_ROUTINE',VALUE=routine
    ;;------------------------------------------------------------------------------------
    ;;  Set color table
    ;;------------------------------------------------------------------------------------
    color_table = struct_value(newlim,'color_table',DEFAULT=-1) & pct = -1
    IF (color_table GE 0) THEN loadct2,color_table,PREVIOUS_CT=pct
    ;;------------------------------------------------------------------------------------
    ;;  Set PS resolution if desired
    ;;------------------------------------------------------------------------------------
    IF KEYWORD_SET(spec_res) THEN BEGIN
      IF (routine EQ 'specplot') THEN BEGIN
        default_res  = 60.              ; => Default Resolution of PS files
        s_resolution = FLOAT(spec_res)  ; => Desired resolution
        nsbuff       = N_ELEMENTS(s_resolution)
        IF (nsbuff NE 1L) THEN s_resolution = default_res
        ; => Get original Device settings before setting Z-Buffer
        oldDevice   = !D.NAME
        IF (STRLOWCASE(oldDevice) NE 'ps') THEN BEGIN
          CALL_PROCEDURE,routine,DATA=pdata,LIMITS=newlim
;  => LBW 10/01/2010
        ENDIF ELSE BEGIN
          CALL_PROCEDURE,routine,DATA=pdata,LIMITS=newlim,PS_RESOLUTION=s_resolution
;  => LBW 10/01/2010
        ENDELSE
      ENDIF ELSE BEGIN
        CALL_PROCEDURE,routine,DATA=pdata,LIMITS=newlim
;  => LBW 10/01/2010
      ENDELSE
    ENDIF ELSE BEGIN
      CALL_PROCEDURE,routine,DATA=pdata,LIMITS=newlim
;  => LBW 10/01/2010
    ENDELSE
;  TDAS Update
    ;;  Reset color table if so desired
    IF (color_table NE pct) THEN loadct2,pct
    ;;  get offset into color array (for pseudo vars)
    IF KEYWORD_SET(colors_set) THEN BEGIN
      str_element,newlim,'color_offset',VALUE=color_offset
    ENDIF
  ENDFOR
  def_opts.NOERASE              = 1
  def_opts.TITLE                = ''
  tplot_vars.SETTINGS.Y[i]      = !Y
  tplot_vars.SETTINGS.CLIP[*,i] = !P.CLIP
ENDFOR
;;----------------------------------------------------------------------------------------
;;  Finish var_labels
;;----------------------------------------------------------------------------------------
str_element,tplot_vars,'SETTINGS.VARNAMES',varnames,/ADD_REPLACE
str_element,tplot_vars,'SETTINGS.D',!D,/ADD_REPLACE
str_element,tplot_vars,'SETTINGS.P',!P,/ADD_REPLACE
str_element,tplot_vars,'SETTINGS.X',!X,/ADD_REPLACE
str_element,tplot_vars,'SETTINGS.TRANGE_CUR',(!X.RANGE * time_scale) + time_offset

IF KEYWORD_SET(vtitle) THEN BEGIN
  xspace = chsize * !D.X_CH_SIZE / !D.X_SIZE
  yspace = chsize * !D.Y_CH_SIZE / !D.Y_SIZE
  xpos = pos[0,(nd-1L)] - (def_opts.XMARGIN[0] - 1) * xspace 
  ypos = pos[1,(nd-1L)] - 1.5 * yspace 
  XYOUTS,xpos,ypos,vtitle,/NORMAL,CHARSIZE=chsize
ENDIF
;;----------------------------------------------------------------------------------------
;;  Restore system variable defaults
;;----------------------------------------------------------------------------------------
time_stamp,CHARSIZE=chsize*.5

IF ((!D.FLAGS AND 256) NE 0) THEN BEGIN    ; windowing devices
  str_element,tplot_vars,'SETTINGS.WINDOW',!D.WINDOW,/ADD_REPLACE
  IF (def_opts.WINDOW GE 0) THEN WSET,current_window
ENDIF
!X = plt.X
!Y = plt.Y
!Z = plt.Z
!P = plt.P

str_element,tplot_vars,'SETTINGS.TIME_SCALE',time_scale,/ADD_REPLACE
str_element,tplot_vars,'SETTINGS.TIME_OFFSET',time_offset,/ADD_REPLACE
new_tvars = tplot_vars
;;----------------------------------------------------------------------------------------
;;  Return to user
;;----------------------------------------------------------------------------------------

RETURN
END

