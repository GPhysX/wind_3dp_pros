;+
;*****************************************************************************************
;
;  FUNCTION :   log10_e_bikappa_fit.pro
;  PURPOSE  :   Creates a Bi-Kappa Distribution Function (KDF) for electrons from a user
;                 defined amplitude, temperature, and array of velocities to define
;                 the KDF at.  The only note to be careful of is to make sure the
;                 thermal speed and array of velocities have the same units.  The output
;                 will be the base-10 log of the KDF.
;
;  CALLED BY:   
;               NA
;
;  INCLUDES:
;               NA
;
;  CALLS:
;               @load_constants_fund_em_atomic_c2014_batch.pro
;               lbw_digamma.pro
;
;  REQUIRES:    
;               1)  UMN Modified Wind/3DP IDL Libraries
;
;  INPUT:
;               VPARA  :  [N]-Element [numeric] array of velocities parallel to the
;                           quasi-static magnetic field direction [km/s]
;               VPERP  :  [M]-Element [numeric] array of velocities orthogonal to the
;                           quasi-static magnetic field direction [km/s]
;               PARAM  :  [6]-Element [numeric] array where each element is defined by
;                           the following quantities:
;                           PARAM[0] = Number Density [cm^(-3)]
;                           PARAM[1] = Parallel Temperature [eV]
;                           PARAM[2] = Perpendicular Temperature [eV]
;                           PARAM[3] = Parallel Drift Speed [km/s]
;                           PARAM[4] = Perpendicular Drift Speed [km/s]
;                           PARAM[5] = Kappa Value
;               PDER   :  [6]-Element [numeric] array defining which partial derivatives
;                           of the 6 variable coefficients in PARAM to compute.  For
;                           instance, to take the partial derivative with respect to
;                           only the first and third coefficients, then do:
;                           PDER = [1,0,1,0,0,0]
;
;  OUTPUT:
;               PDER   :  On output, the routine returns an [N,M,6]-element [numeric]
;                           array containing the partial derivatives of Y with respect
;                           to each element of PARAM that were not set to zero in
;                           PDER on input.
;
;  EXAMPLES:    
;               [calling sequence]
;               l10bikap = log10_e_bikappa_fit(vpara, vperp, param, pder [,FF=ff])
;
;  KEYWORDS:    
;               FF     :  Set to a named variable to return an [N,M]-element array of
;                           the base-10 log of the values corresponding to the evaluated
;                           function
;
;   CHANGED:  1)  NA
;                                                                   [MM/DD/YYYY   v1.0.0]
;
;   NOTES:      
;               1)  The thermal speeds are the "most probable speeds" for each direction
;                     --> V_tpara = SQRT(2*kB*T_para/m)
;               2)  User should not call this routine
;               3)  See also:  biselfsimilar.pro and bimaxwellian.pro
;               4)  VDF = velocity distribution function
;               5)  The digamma function is slow as it computes a 30 million element
;                     array to ensure at least 7 digits of accuracy
;
;  REFERENCES:  
;               0)  Barnes, A. "Collisionless Heating of the Solar-Wind Plasma I. Theory
;                      of the Heating of Collisionless Plasma by Hydromagnetic Waves,"
;                      Astrophys. J. 154, pp. 751--759, 1968.
;               1)  Mace, R.L. and R.D. Sydora "Parallel whistler instability in a plasma
;                      with an anisotropic bi-kappa distribution," J. Geophys. Res. 115,
;                      pp. A07206, doi:10.1029/2009JA015064, 2010.
;               2)  Livadiotis, G. "Introduction to special section on Origins and
;                      Properties of Kappa Distributions: Statistical Background and
;                      Properties of Kappa Distributions in Space Plasmas,"
;                      J. Geophys. Res. 120, pp. 1607--1619, doi:10.1002/2014JA020825,
;                      2015.
;               3)  Livadiotis, G. "Statistical origin and properties of kappa
;                      distributions," J. Phys.: Conf. Ser. 900(1), pp. 012014, 2017.
;               4)  Livadiotis, G. "Derivation of the entropic formula for the
;                      statistical mechanics of space plasmas,"
;                      Nonlin. Proc. Geophys. 25(1), pp. 77-88, 2018.
;               5)  Livadiotis, G. "Modeling anisotropic Maxwell-Jüttner distributions:
;                      derivation and properties," Ann. Geophys. 34(1),
;                      pp. 1145-1158, 2016.
;               6)  L.B. Wilson III, et al., "Electron energy partition across
;                      interplanetary shocks: I. Methodology and Data Product,"
;                      arXiv, eprint 1902.01476, 2019a.
;
;   ADAPTED FROM: bikappa_fit.pro    BY: Lynn B. Wilson III
;   CREATED:  04/03/2019
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  04/03/2019   v1.0.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

FUNCTION log10_e_bikappa_fit,vpara,vperp,param,pder,FF=ff

;;----------------------------------------------------------------------------------------
;;  Define some constants and dummy variables
;;----------------------------------------------------------------------------------------
f              = !VALUES.F_NAN
d              = !VALUES.D_NAN
zran           = [1d-2,101d0]                 ;;  Currently allowed range in readable ASCII file of digamma results
;;----------------------------------------------------------------------------------------
;;  Define fundamental, electromagnetic, and atomic constants
;;----------------------------------------------------------------------------------------
@load_constants_fund_em_atomic_c2014_batch.pro
;;  Conversion factors
;;    Energy and Temperature
f_1eV          = qq[0]/hh[0]              ;;  Freq. associated with 1 eV of energy [ Hz --> f_1eV*energy{eV} = freq{Hz} ]
eV2J           = hh[0]*f_1eV[0]           ;;  Energy associated with 1 eV of energy [ J --> J_1eV*energy{eV} = energy{J} ]
eV2K           = qq[0]/kB[0]              ;;  Temp. associated with 1 eV of energy [11,604.5221 K/eV, 2014 CODATA/NIST --> eV2K*energy{eV} = Temp{K}]
K2eV           = kB[0]/qq[0]              ;;  Energy associated with 1 K Temp. [8.6173303 x 10^(-5) eV/K, 2014 CODATA/NIST --> K2eV*Temp{K} = energy{eV}]
;;    Speed and Frequency
vtefac         = SQRT(2d0*eV2J[0]/me[0])*1d-3
;;----------------------------------------------------------------------------------------
;;  Check input
;;----------------------------------------------------------------------------------------
IF (N_PARAMS() LT 3) THEN BEGIN
  ;;  no input???
  RETURN,0b
ENDIF

np             = N_ELEMENTS(param)
nva            = N_ELEMENTS(vpara)
nve            = N_ELEMENTS(vperp)
test           = (np[0] NE 6)
IF (test[0]) THEN BEGIN
  ;;  bad input???
  RETURN,0b
ENDIF
;;----------------------------------------------------------------------------------------
;;  Calculate distribution
;;----------------------------------------------------------------------------------------
kk             = param[5]              ;;  kappa value
;;  Ensure k ≥ 3/2
kk             = kk[0] > 3d0/2d0
km32           = kk[0] - 3d0/2d0       ;;  k - 3/2
km12           = kk[0] - 1d0/2d0       ;;  k - 1/2
kp_1           = kk[0] + 1d0           ;;  k + 1
;;  Define velocities offset by drift speeds:  U_j = V_j - V_oj  [km/s]
uelpa          = vpara - param[3]      ;;  Parallel velocity minus drift speed [km/s]
uelpe          = vperp - param[4]      ;;  Perpendicular velocity minus drift speed [km/s]
;;  Convert to 2D
uelpa2d        = uelpa # REPLICATE(1d0,nve[0])
uelpe2d        = REPLICATE(1d0,nva[0]) # uelpe
;;  Define thermal speeds [km/s]
vtepar         = vtefac[0]*SQRT(param[1])
vteper         = vtefac[0]*SQRT(param[2])
;;  Define:  W_j = U_j/V_Tj
welpa2d        = uelpa2d/vtepar[0]
welpe2d        = uelpe2d/vteper[0]
;;  Define factors for kappa VDF
factor0        = (1d0/(!DPI*km32[0]))^(3d0/2d0)
factor1        = GAMMA(kp_1[0])/GAMMA(km12[0])
factor2        = param[0]/(vtepar[0]*vteper[0]^2d0)
factors        = factor0[0]*factor1[0]*factor2[0]
;;  Define velocity term:  (W_par^2 + W_per^2)/K32
velfact        = (welpa2d^2d0 + welpe2d^2d0)/km32[0]
;;  Define the 2D bi-kappa [Eq. 1 in Mace and Sydora, (2010) with density added]
ff             = factors[0]*(1d0 + velfact)^(-1d0*kp_1[0])
;;----------------------------------------------------------------------------------------
;;  Calculate partial derivatives of Z = H(A,B,C,F) {1 + (F-3/2)^(-1) [((X-D)/B)^2 + ((Y-E)/C)^2]}^(-(F-1))
;;    H(A,B,C,F) = [F/π(F-3/2)]^(3/2) A GG(F+1)/[F^(3/2) B C^2 GG(F-1/2)]
;;    GG(z)      = GAMMA(z)
;;    DG(z)      = GAMMA'(z)/GAMMA(z)  =  digamma function
;;    Let us define the following for brevity:
;;      K32 = F - 3/2
;;      K1m = F - 1/2
;;      K1p = F + 1/2
;;      K_1 = F + 1
;;      U_j = V_j - V_oj  =  {X,Y} - {D,E}
;;      W_j = U_j/V_Tj    =  ({X,Y} - {D,E})/{B,C}
;;      DEN = W_par^2 + W_per^2 + K32
;;
;;
;;    dZ/dA = Z/A
;;    dZ/dB = Z [2 K1p W_par^2 - W_per^2 - K32]/[B * DEN]
;;    dZ/dC = Z 2*[F W_per^2 - W_par^2 - K32]/[C * DEN]
;;    dZ/dD = Z 2*[W_par K_1]/[B * DEN]
;;    dZ/dE = Z 2*[W_per K_1]/[C * DEN]
;;    dZ/dF = Z { [(W_par^2 + W_per^2) K1m - K32*3/2]/[K32 * DEN] -
;;               ln| 1 + (W_par^2 + W_per^2)/K32 | + DG(K_1) - DG(K1m) }
;;----------------------------------------------------------------------------------------
IF (N_PARAMS() GT 3) THEN BEGIN
  ;;  Save original (input) partial derivative settings
  requested      = pder
  ;;  Redefine partial derivative array
  pder           = MAKE_ARRAY(nva,nve,np,VALUE=vpara[0]*0)
  ;;  Define: DEN = W_par^2 + W_per^2 + K32
  denom          = (welpa2d^2d0 + welpe2d^2d0 + km32[0])
  FOR k=0L, np[0] - 1L DO BEGIN
    IF (requested[k] NE 0) THEN BEGIN
      CASE k[0] OF
        0     :  BEGIN
          ;;  dZ/dA = Z/A
          pder[*,*,k] = ALOG10(ABS(ff/param[0]))
        END
        1     :  BEGIN
          ;;  dZ/dB = Z [2 K1p W_par^2 - W_per^2 - K32]/[B * DEN]
          pder[*,*,k] = ALOG10(ABS(ff*(2d0*kp_1[0]*welpa2d^2d0 - welpe2d^2d0 - km32[0])/(vtepar[0]*denom)))
        END
        2     :  BEGIN
          ;;  dZ/dC = Z 2*[F W_per^2 - W_par^2 - K32]/[C * DEN]
          pder[*,*,k] = ALOG10(ABS(ff*2d0*(kk[0]*welpe2d^2d0 - welpa2d^2d0 - km32[0])/(vteper[0]*denom)))
        END
        3     :  BEGIN
          ;;  dZ/dD = Z 2*[W_par K_1]/[B * DEN]
          pder[*,*,k] = ALOG10(ABS(ff*2d0*welpa2d*kp_1[0]/(vtepar[0]*denom)))
        END
        4     :  BEGIN
          ;;  dZ/dE = Z 2*[W_per K_1]/[C * DEN]
          pder[*,*,k] = ALOG10(ABS(ff*2d0*welpe2d*kp_1[0]/(vteper[0]*denom)))
        END
        5     :  BEGIN
          ;;  dZ/dF = Z { [(W_par^2 + W_per^2) K1m - K32*3/2]/[K32 * DEN] -
          ;;             ln| 1 + (W_par^2 + W_per^2)/K32 | + DG(K_1) - DG(K1m) }
          term0       = (welpa2d^2d0 + welpe2d^2d0)*km12[0] - 3d0*km32[0]/2d0
          term1       = term0/(km32[0]*denom)
          term2       = ALOG(ABS(1d0 + (welpa2d^2d0 + welpe2d^2d0)/km32[0]))
          ndg         = 30000000L
          test        = (kp_1[0] GT zran[0]) AND (kp_1[0] LT zran[1])
          IF (test[0]) THEN digkp_1 = lbw_digamma(kp_1[0],/READ_DG) ELSE digkp_1 = lbw_digamma(kp_1[0],N=ndg[0])
          test        = (km12[0] GT zran[0]) AND (km12[0] LT zran[1])
          IF (test[0]) THEN digkm12 = lbw_digamma(km12[0],/READ_DG) ELSE digkm12 = lbw_digamma(km12[0],N=ndg[0])
          term3       = digkp_1[0] - digkm12[0]
          term4       = term1 - term2 + term3[0]
          pder[*,*,k] = ALOG10(ABS(ff*term4))
        END
        ELSE  :  ;;  Do nothing as this parameter is not used
      ENDCASE
    ENDIF
  ENDFOR
ENDIF
;;  Redefine FF (keep keyword consistent)
ff             = ALOG10(ff)
;;----------------------------------------------------------------------------------------
;;  Return the base-10 log of the total distribution
;;----------------------------------------------------------------------------------------

RETURN,ff
END



