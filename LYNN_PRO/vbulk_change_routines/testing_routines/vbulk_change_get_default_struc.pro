;+
;*****************************************************************************************
;
;  FUNCTION :   vbulk_change_get_default_struc.pro
;  PURPOSE  :   This routine creates a structure filled with default values for all
;                 relevant parameters used by the Vbulk changing routines.
;
;  CALLED BY:   
;               NA
;
;  INCLUDES:
;               NA
;
;  CALLS:
;               get_os_slash.pro
;               add_os_slash.pro
;
;  REQUIRES:    
;               1)  UMN Modified Wind/3DP IDL Libraries
;
;  INPUT:
;               NA
;
;  EXAMPLES:    
;               [calling sequence]
;               def_struc = vbulk_change_get_default_struc()
;
;               !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
;               ***  OUTPUT:  Structure containing the following tags  ***
;               !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
;
;               VFRAME     :  [3]-Element [float/double] array defining the 3-vector
;                               velocity of the K'-frame relative to the K-frame [km/s]
;                               to use to transform the velocity distribution into the
;                               bulk flow reference frame
;                               [ Default = [0,0,0] ]
;               VEC1       :  [3]-Element vector to be used for "parallel" direction in
;                               a 3D rotation of the input data
;                               [e.g. see rotate_3dp_structure.pro]
;                               [ Default = [1.,0.,0.] ]
;               VEC2       :  [3]--Element vector to be used with VEC1 to define a 3D
;                               rotation matrix.  The new basis will have the following:
;                                 X'  :  parallel to VEC1
;                                 Z'  :  parallel to (VEC1 x VEC2)
;                                 Y'  :  completes the right-handed set
;                               [ Default = [0.,1.,0.] ]
;               VLIM       :  Scalar [numeric] defining the velocity [km/s] limit for x-y
;                               velocity axes over which to plot data
;                               [Default = 1e3]
;               NLEV       :  Scalar [numeric] defining the # of contour levels to plot
;                               [Default = 30L]
;               XNAME      :  Scalar [string] defining the name of vector associated with
;                               the VEC1 input
;                               [Default = 'X']
;               YNAME      :  Scalar [string] defining the name of vector associated with
;                               the VEC2 input
;                               [Default = 'Y']
;               SM_CUTS    :  If set, program smoothes the cuts of the VDF before plotting
;                               [Default = FALSE]
;               SM_CONT    :  If set, program smoothes the contours of the VDF before
;                               plotting
;                               [Default = FALSE]
;               NSMCUT     :  Scalar [numeric] defining the # of points over which to
;                               smooth the 1D cuts of the VDF before plotting
;                               [Default = 3]
;               NSMCON     :  Scalar [numeric] defining the # of points over which to
;                               smooth the 2D contour of the VDF before plotting
;                               [Default = 3]
;               PLANE      :  Scalar [string] defining the plane projection to plot with
;                               corresponding cuts [Let V1 = VEC1, V2 = VEC2]
;                                 'xy'  :  horizontal axis parallel to V1 and normal
;                                            vector to plane defined by (V1 x V2)
;                                            [default]
;                                 'xz'  :  horizontal axis parallel to (V1 x V2) and
;                                            vertical axis parallel to V1
;                                 'yz'  :  horizontal axis defined by (V1 x V2) x V1
;                                            and vertical axis (V1 x V2)
;                               [Default = 'xy']
;               DFMIN      :  Scalar [numeric] defining the minimum allowable phase space
;                               density to plot, which is useful for ion distributions
;                               with large angular gaps in data (prevents lower bound
;                               from falling below DFMIN)
;                               [Default = 1d-20]
;               DFMAX      :  Scalar [numeric] defining the maximum allowable phase space
;                               density to plot, which is useful for distributions with
;                               data spikes (prevents upper bound from exceeding DFMAX)
;                               [Default = 1d-2]
;               DFRA       :  [2]-Element [numeric] array specifying the VDF range in
;                               phase space density [e.g., # s^(+3) km^(-3) cm^(-3)] for
;                               the cuts and contour plots
;                               [Default = [DFMIN,DFMAX]]
;               V_0X       :  Scalar [float/double] defining the velocity [km/s] along
;                               the X-Axis (horizontal) to shift the location where the
;                               perpendicular (vertical) cut of the DF will be performed
;                               [Default = 0.0]
;               V_0Y       :  Scalar [float/double] defining the velocity [km/s] along
;                               the Y-Axis (vertical) to shift the location where the
;                               parallel (horizontal) cut of the DF will be performed
;                               [Default = 0.0]
;               SAVE_DIR   :  Scalar [string] defining the directory where the plots
;                               will be stored
;                               [Default = FILE_EXPAND_PATH('')]
;               FILE_PREF  :  [N]-Element array [string] defining the prefix associated
;                               with each PostScript plot on output
;                               [Default = 'VDF_ions']
;               FILE_MIDF  :  Scalar [string] defining the plane of projection and number
;                               grids used for contour plot levels
;                               [Default = 'V1xV2xV1_vs_V1_xxGrids_']
;
;  KEYWORDS:    
;               NA
;
;   CHANGED:  1)  Continued to write routine
;                                                                   [05/17/2017   v1.0.0]
;
;   NOTES:      
;               NA
;
;  REFERENCES:  
;               NA
;
;   CREATED:  05/16/2017
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  05/17/2017   v1.0.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

FUNCTION vbulk_change_get_default_struc

;;----------------------------------------------------------------------------------------
;;  Constants and dummy variables
;;----------------------------------------------------------------------------------------
f              = !VALUES.F_NAN
d              = !VALUES.D_NAN
xyzvecf        = ['V1','V1xV2xV1','V1xV2']
def_xysuff     = xyzvecf[1]+'_vs_'+xyzvecf[0]+'_'  ;;  e.g., 'V1xV2xV1_vs_V1_'
def_xzsuff     = xyzvecf[0]+'_vs_'+xyzvecf[2]+'_'  ;;  e.g., 'V1_vs_V1xV2_'
def_yzsuff     = xyzvecf[2]+'_vs_'+xyzvecf[1]+'_'  ;;  e.g., 'V1xV2_vs_V1xV2xV1_'
def_suffix     = [def_xysuff[0],def_xzsuff[0],def_yzsuff[0]]
slash          = get_os_slash()                    ;;  '/' for Unix-like, '\' for Windows
vers           = !VERSION.OS_FAMILY                ;;  e.g., 'unix'
vern           = !VERSION.RELEASE                  ;;  e.g., '7.1.1'
;;  Define the current working directory character
;;    e.g., './' [for unix and linux] otherwise guess './' or '.\'
test           = (vern[0] GE '6.0')
IF (test[0]) THEN cwd_char = FILE_DIRNAME('',/MARK_DIRECTORY) ELSE cwd_char = '.'+slash[0]
;;----------------------------------------------------------------------------------------
;;  Define default values
;;----------------------------------------------------------------------------------------
def_vframe     = REPLICATE(0d0,3L)
def_vec__1     = [1d0,0d0,0d0]
def_vec__2     = [0d0,1d0,0d0]
def_vrange     = 1d3
def_nlevel     = 30L
def__xname     = 'X'
def__yname     = 'Y'
def_smcuts     = 0b
def_smcont     = 0b
def_nsmcut     = 3L
def_nsmcon     = 3L
def__plane     = 'xy'
def__dfmin     = 1d-18
def__dfmax     = 1d-2
def__dfran     = [def__dfmin[0],def__dfmax[0]]
def___v_0x     = 0d0
def___v_0y     = 0d0
;;  Define default location for save directory
def_savdir     = (add_os_slash(FILE_EXPAND_PATH(cwd_char[0])))[0]
;;  Define file name defaults
def__fpref     = 'VDF_ions'
def__fmidf     = (def_suffix[WHERE(['xy','xz','yz'] EQ def__plane[0])])[0]
;;----------------------------------------------------------------------------------------
;;  Define default structure
;;----------------------------------------------------------------------------------------
;;  Define structure tags
tags           = ['VFRAME','VEC1','VEC2','VLIM','NLEV','XNAME','YNAME','SM_CUTS',$
                  'SM_CONT','NSMCUT','NSMCON','PLANE','DFMIN','DFMAX','DFRA',    $
                  'V_0X','V_0Y','SAVE_DIR','FILE_PREF','FILE_MIDF']
struct         = CREATE_STRUCT(tags,def_vframe,def_vec__1,def_vec__2,def_vrange, $
                                    def_nlevel,def__xname,def__yname,def_smcuts, $
                                    def_smcont,def_nsmcut,def_nsmcon,def__plane, $
                                    def__dfmin,def__dfmax,def__dfran,def___v_0x, $
                                    def___v_0y,def_savdir,def__fpref,def__fmidf  )
;;----------------------------------------------------------------------------------------
;;  Return to user
;;----------------------------------------------------------------------------------------

RETURN,struct
END
