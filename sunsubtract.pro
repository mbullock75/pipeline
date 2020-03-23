;*******************************************************************************
  pro sunsubtract, imagedir, sunimagedir, outdir, outfile
;*******************************************************************************
;
; IDL procedure sunsubtract.pro subtracts a Br-g superimage from a cont-k
; superimage in order to eliminate scattered sunlight,
;
; Procedures Called:
; 
; readfits.pro            astron library. Reads fits files
; writefits.pro           astron library. Writes fits files
; correll_optimize.pro    calculate fractional pixel shift to align images
; sshift2d.pro            perform fractional pixel shift on image 
;
;
; Mark A. Bullock                                               3/1/2018
;
; Revisions:
;
;
;*******************************************************************************
  
; User-dependent paths and files

  if n_elements(imagedir) eq 0 then begin
    imagedir  = 'C:\bullock\telescope data\' + $
             'irtf 4-17\4-21-17\processed\2cont-k super2\'
  endif
  
  if n_elements(sunimagedir) eq 0 then begin
    sunimagedir = 'C:\bullock\telescope data\' + $
             'irtf 4-17\4-21-17\processed\5br-g super2\'
  endif
  
  if n_elements(outdir) eq 0 then begin
    outdir = 'C:\bullock\telescope data\' + $
             'irtf 4-17\4-21-17\processed\6sunlight subtract2\'
  endif
  
  if n_elements(outfile) eq 0 then begin
    outfile = 'clean_deslit_sunsubtract_4-26-17_cont-k2.fits'
  endif
  
; Count image files in input directories and get file names

  cd, imagedir, current=old_dir

  imagefiles = file_search('*.fits',count=nimagefiles)
 
  cd, sunimagedir
  
  sunimagefiles = file_search('*.fits',count=nsunimagefiles)
  
  cd, old_dir
  
; Read files  
  
  image = readfits(imagedir + imagefiles[0],header)
  sunimage = readfits(sunimagedir + sunimagefiles[0],sunheader)
  
; Adjust backgrounds

  backtop = mean(image[128:383,490:499])
  backbot = mean(image[128:383,12:21])
  backlft  = mean(image[12:21,128:383])
  backrt  = mean(image[490:499,128:383])
  background = min([backtop,backbot,backlft,backrt])
  imageA = (image - background) > 0.0
    
  sunbacktop = mean(sunimage[128:383,490:499])
  sunbackbot = mean(sunimage[128:383,12:21])
  sunbacklft  = mean(sunimage[12:21,128:383])
  sunbackrt  = mean(sunimage[490:499,128:383])
  sunbackground = min([sunbacktop,sunbackbot,sunbacklft,sunbackrt])
  sunimageA = (sunimage - sunbackground) > 0.0

; Bypass background adjust.  Comment out to adjust background

    imageA = image
    sunimageA = sunimage

; Coregister images and subtract sunlight image
  
  correl_optimize,imageA,sunimageA,xoffset_optimum,yoffset_optimum,mag=2,/numpix
    
  imageC = sshift2d(sunimageA,[xoffset_optimum,yoffset_optimum])
    
  print
  print,'x,y = ',xoffset_optimum,yoffset_optimum
    
  sunsubtractimage = (imageA - 0.7*imageC) - min(imageA - 0.7*imageC)

; Display superimage  

  window,0,xs=512,ys=512,title='Image'
  tvscl,imageA < 1000.0
  
  window,2,xs=512,ys=512,title='Shifted Sunimage'
  tvscl,imageC < 1000.0
  
; Save superimage as a fits file  
  
  writefits,outdir + outfile,sunsubtractimage, header

  end

;*******************************************************************************
;
;                             End of sunsubtract.pro
;
;*******************************************************************************
