;*******************************************************************************
  pro xccstackclean, indir, outdir, outfile
;*******************************************************************************
;
; IDL procedure xccstackclean.pro takes fits files in indir and uses cross
; correlation correl_optimize.pro to recommend a fraction pixel shift for
; registering each image. Each image is fractionally shifted by this amount
; using sshift2d.pro.  The images are stacked by taking the median of each
; pixel in the stack, which removes outliers. The stacked superimage is
; written to outdir.
;
; Procedures Called:
;
; readfits.pro            astron library. Reads fits files
; writefits.pro           astron library. Writes fits files
; correll_optimize.pro    calculate fractional pixel shift to align images
; sshift2d.pro            perform fractional pixel shift on image 
;
; Mark A. Bullock                                               3/1/2018
;
; Revisions:
;
;
;*******************************************************************************
  
; User-dependent paths and files

  if n_elements(indir) eq 0 then begin
    indir  = 'C:\bullock\telescope data\' + $
             'irtf 4-17\4-25-17\processed\4br-g deslit9\'
  endif
  
  if n_elements(outdir) eq 0 then begin
    outdir = 'C:\bullock\telescope data\' + $
             'irtf 4-17\4-25-17\processed\5br-g super9\'
  endif
  
  if n_elements(outfile) eq 0 then begin
    outfile = 'clean_deslit_super_4-25-17_br-g9.fits'
  endif
  
; Count image files in input directory and get file names

  cd, indir, current=old_dir

  files = file_search('*.fits',count=nfiles)
 
  cd, old_dir
  
  imagestack = fltarr(512,512,nfiles)

; Read the first fits file

  imageAfname = files[0]
  imageA = readfits(indir + imageAfname, headerA)
;  superimage = imageA
  superimageA = fltarr(512,512)
  imagestack[*,*,0] = imageA
  
; Read each file, determine offsets, and shift each image on top of imageA

  for i = 2,nfiles do begin
    fname = files[i-1]
    imageB = readfits(indir + fname, header)
  
    correl_optimize,imageA,imageB,xoffset_optimum,yoffset_optimum,mag=4,/numpix
    
    imageC = sshift2d(imageB,[xoffset_optimum,yoffset_optimum])
    
;    print,fname
;    print,'x offset: ',xoffset_optimum,'y offset: ',yoffset_optimum
;    print
    imagestack[*,*,i-1] = imageC
;    superimage = superimage + imageC  
  endfor
  
; For each i,j, choose median of the stack

  for i=0,511 do begin
    for j=0,511 do begin
      medpix = median(imagestack[i,j,*])
      superimageA[i,j] = medpix
    endfor
  endfor
  
; Superimage is just the mean of all the images
  
;  superimage = superimage/float(nfiles)

; Use bytscl only when aligning with mask

;  superimage = bytscl(superimage/float(nfiles))
  
;  print,'Min and Max of superimage = ',minmax(superimage)
  
; Display superimage  

;  window,0,xs=512,ys=512,title='Superimage'
;  tvscl,superimage < 1000.0
;  
;  window,2,xs=512,ys=512,title='Cleaned Superimage'
;  tvscl,superimageA < 1000.0
;  
; Save superimage as a fits file  

  superimageA = superimageA > 0.0
  
  writefits,outdir + outfile,superimageA,headerA

  end

;*******************************************************************************
;
;                             End of xccstack.pro
;
;*******************************************************************************
