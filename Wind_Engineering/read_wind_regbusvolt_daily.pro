;+
;*****************************************************************************************
;
;  FUNCTION :   read_wind_regbusvolt_daily.pro
;  PURPOSE  :   This routine reads the ASCII file containing information about the
;                 regulated bus voltage for the Wind spacecraft.
;
;  CALLED BY:   
;               NA
;
;  INCLUDES:
;               NA
;
;  CALLS:
;               get_os_slash.pro
;               time_double.pro
;               str_element.pro
;
;  REQUIRES:    
;               1)  UMN Modified Wind/3DP IDL Libraries
;               2)  ASCII File:  wind_regulated_bus_voltage_daily.txt
;
;  INPUT:
;               NA
;
;  EXAMPLES:    
;               [calling sequence]
;               test = read_wind_regbusvolt_daily()
;
;  KEYWORDS:    
;               NA
;
;   CHANGED:  1)  Updated Man. page and updated ASCII file for 2017 senior review
;                                                                   [01/22/2017   v1.1.0]
;             2)  Updated ASCII file for 2020 senior review and now calls
;                   test_file_path_format.pro
;                                                                   [01/16/2020   v1.1.1]
;
;   NOTES:      
;               1)  Data in ASCII files provided to Wind project scientist (currently
;                     Lynn B. Wilson III) by flight operations team at GSFC
;
;  REFERENCES:  
;               1)  Harten, R., K. Clark (1995) "The Design Features of the GGS Wind
;                      and Polar Spacecraft," Space Sci. Rev. Vol. 71, pp. 23-40.
;
;   CREATED:  11/08/2013
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  01/16/2020   v1.1.1
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

FUNCTION read_wind_regbusvolt_daily

;;----------------------------------------------------------------------------------------
;;  Define dummy variables
;;----------------------------------------------------------------------------------------
f              = !VALUES.F_NAN
d              = !VALUES.D_NAN
pick_mssg      = 'Select the desired file and then click okay'
;;  Define format of file
mform          = '(a10,I8.3,3f25.4)'
slash          = get_os_slash()         ;;  '/' for Unix, '\' for Windows
;;----------------------------------------------------------------------------------------
;;  Find file
;;----------------------------------------------------------------------------------------
;;  Define directory location of file
dir_str        = '.'+slash[0]+'wind_3dp_pros'+slash[0]+'Wind_Engineering'+slash[0]
test           = test_file_path_format(dir_str[0],EXISTS=exists,DIR_OUT=mdir)
IF (~test[0]) THEN STOP
;mdir           = FILE_EXPAND_PATH(dir_str[0])
;;  Define file name
fname          = 'wind_regulated_bus_voltage_daily.txt'
file           = FILE_SEARCH(mdir,fname[0])
;;----------------------------------------------------------------------------------------
;;  Check for file
;;----------------------------------------------------------------------------------------
good           = WHERE(file[0] NE '',gd)
IF (gd EQ 0) THEN BEGIN
  ;;  Not found --> ask user to pick file by hand
  gfile = DIALOG_PICKFILE(PATH=dir_str[0],TITLE=pick_mssg)
ENDIF ELSE BEGIN
  gfile = file[0]
ENDELSE
;;----------------------------------------------------------------------------------------
;;  Define relevant quantities
;;      Units:  A = ampere, V = volts
;;----------------------------------------------------------------------------------------
n              = FILE_LINES(gfile[0]) - 4L    ;;  number of lines of data in file
month          = STRARR(n)                    ;;  Month of year [e.g., '11']
day            = STRARR(n)                    ;;  Day of month [e.g., '03']
year           = STRARR(n)                    ;;  Year [e.g., '1994']
dates          = STRARR(n)                    ;;  Dates [e.g., '1994-11-03/00:00:00.000']
doy            = LONARR(n)                    ;;  Day of Year
rb__avg        = DBLARR(n)                    ;;  Regulated bus voltage output [Avg., V]
rb__min        = DBLARR(n)                    ;;  Regulated bus voltage output [Min., V]
rb__max        = DBLARR(n)                    ;;  Regulated bus voltage output [Max., V]
;;  Define dummy variables for reading in data
a              = ''                           ;; e.g., '11/03/1994'
b              = 0L                           ;; e.g., 307
c              = DBLARR(3)
;;----------------------------------------------------------------------------------------
;;  Open file and read header
;;----------------------------------------------------------------------------------------
mline          = ''
infile         = gfile[0]
OPENR,gunit,infile,/GET_LUN
FOR mvc=0L, 3L DO READF,gunit,mline           ;;  Read header lines and discard
;;----------------------------------------------------------------------------------------
;;  Read file and define data
;;----------------------------------------------------------------------------------------
FOR j=0L, n - 1L DO BEGIN
  READF,gunit,a,b,c,FORMAT=mform
  ;;  Define date and day of year
  year[j]     = STRMID(a[0],6L)
  month[j]    = STRMID(a[0],0L,2L)
  day[j]      = STRMID(a[0],3L,2L)
  doy[j]      = LONG(b[0])
  ;;  Define regulated bus voltage outputs
  rb__avg[j]  = DOUBLE(c[0])
  rb__min[j]  = DOUBLE(c[1])
  rb__max[j]  = DOUBLE(c[2])
ENDFOR
;;  Close file
FREE_LUN,gunit
;;----------------------------------------------------------------------------------------
;;  Define timestamps
;;----------------------------------------------------------------------------------------
dates          = year+'-'+month+'-'+day+'/00:00:00.000'
unix           = time_double(dates)           ;;  Convert to Unix
;;----------------------------------------------------------------------------------------
;;  Define dummy structure to return to user
;;----------------------------------------------------------------------------------------
;;  Define dates and timestamps
str_element,dummy,'SCETS'        ,dates     ,/ADD_REPLACE
str_element,dummy,'DOY'          ,doy       ,/ADD_REPLACE
str_element,dummy,'UNIX'         ,unix      ,/ADD_REPLACE
;;  Define regulated bus voltage outputs
str_element,dummy,'REGBUS_V_AVG' ,rb__avg   ,/ADD_REPLACE
str_element,dummy,'REGBUS_V_MIN' ,rb__min   ,/ADD_REPLACE
str_element,dummy,'REGBUS_V_MAX' ,rb__max   ,/ADD_REPLACE
;;----------------------------------------------------------------------------------------
;;  Return to user
;;----------------------------------------------------------------------------------------

RETURN,dummy
END
