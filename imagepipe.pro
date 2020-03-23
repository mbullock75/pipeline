;*******************************************************************************
  pro imagepipe
;*******************************************************************************
;
; IDL procedure imagepipe.pro strings together several Venus image processing
; steps:
; 
; 1. deslit cont-k image sharps
; 2. clean and stack cont-k deslitted images
; 3. deslit Br-g image sharps
; 4. clean and stack Br-g deslitted images
; 5. subtract Br-g superimage from cont-k superimage
;
; Procedures Called:
; 
; deslit.pro          Remove slit and detector crack from Venus images
; xccstackclean.pro   Cross corelation subixel stacking with cleaning
; sunsubtract.pro     Subtract Br-g superimage from cont-k superimage
;
;
; Mark A. Bullock                                               4/5/18
;
;
; Revisions:
;
;
;*******************************************************************************
  
  deslit, $
    'C:\bullock\telescope data\irtf 11-18\12-2-18\processed174\0f174f sharps7\', $
    'C:\bullock\telescope data\irtf 11-18\12-2-18\processed174\1f174f deslit7\'  

  xccstackclean, $
    'C:\bullock\telescope data\irtf 11-18\12-2-18\processed174\1f174f deslit7\', $
    'C:\bullock\telescope data\irtf 11-18\12-2-18\processed174\2f174f super7\', $
    'clean_deslit_super_12-2-18_f174f7.fits'

  deslit, $
    'C:\bullock\telescope data\irtf 11-18\12-2-18\processed174\3FeII sharps7\', $
    'C:\bullock\telescope data\irtf 11-18\12-2-18\processed174\4FeII deslit7\'
          
  xccstackclean, $
    'C:\bullock\telescope data\irtf 11-18\12-2-18\processed174\4FeII deslit7\', $
    'C:\bullock\telescope data\irtf 11-18\12-2-18\processed174\5FeII super7\', $
    'clean_deslit_super_12-2-18_FeII7.fits'
                
  sunsubtract, $
  'C:\bullock\telescope data\irtf 11-18\12-2-18\processed174\2f174f super7\', $
  'C:\bullock\telescope data\irtf 11-18\12-2-18\processed174\5FeII super7\', $
 'C:\bullock\telescope data\irtf 11-18\12-2-18\processed174\6sunlight subtract7\', $
  'clean_deslit_sunsubtract_12-2-18_FeII7.fits'
  
  end

;*******************************************************************************
;
;                           End of imagepipe.pro
;
;*******************************************************************************
