;*******************************************************************************
  pro deslit, indir, outdir
;*******************************************************************************
;
; IDL procedure deslit.pro takes all the fits files in a folder and removes the
; SpeX slit from the center of each image.  It then writes these files to
; a new folder but with the same file names.  Also removes detector crack
; Slit may be 60" or 15".
;
; Procedures Called:
; 
; readfits      astron library
; writefits     astron library
;
;
; Mark A. Bullock                                               3/18/09
;
; Revisions:
;
; Added the capability to operate on files without contiguous numbering.  Uses
; function 'file_test' to test for files' existence.            12/27/09
;
; Simplified file name reading and modified indir to read directly from any
; telescope data folder.										2/2/11
;
;
;*******************************************************************************

; Directories

  if n_elements(indir) eq 0 then begin
    indir = 'C:\bullock\telescope data\irtf 4-17\4-23-17\' + $
            'processed\0cont-k sharps1\'
  endif
  
  if n_elements(outdir) eq 0 then begin
    outdir = 'C:\bullock\telescope data\irtf 4-17\4-23-17\' + $
             'processed\1cont-k deslit1\'
  endif
    
; Define crack geometry

  x1 = 240.0
  y1 = 0.0
  x2 = 0.0
  y2 = 420.0
  
  m = (y2-y1)/(x2-x1)
  
  b = ((y1 - m*x1) + (y2 - m*x2))/2.0 

; Read in filenames and count the number of fits files in the input directory

  cd, indir

  files = file_search('*.fits',count=nfiles) 
    
; Read fits files and their headers for processing info
  
  for i = 0,nfiles-1 do begin
    image = (rotate(readfits(files[i],header,/no_unsigned),7))
    datamin = float(strmid(header[5],21,7))
    datamax = float(strmid(header[6],21,8))
    posangle = float(strmid(header[48],21,8))
    slit = strmid(header[49],23,6)

; Remove crack on detector
    
    for k = 1,y2-2 do begin
      y = k
      x = (y - b)/m
      image[x,y] = (image[x+2,y] + image[x-2,y])/2.0
      image[x+1,y] = (image[x+2,y] + image[x-2,y])/2.0
      image[x-1,y] = (image[x+2,y] + image[x-2,y])/2.0
;      image[x,y-1] = (image[x+2,y] + image[x-2,y])/2.0
    endfor
    
; Test if no slit is present on images, but define slit length if it is 

    if slit ne 'Mirror' then begin
      whichslit = fix(strmid(slit,4,2))
      
; Define 15" slit geometry

      if whichslit eq 15 then begin
        slitwidth = 4
        slitlength = 127
        slitystart = 209
      endif else begin
  
; Define 60" slit geometry

        slitwidth = 8
        slitlength = 511
        slitystart = 1
      endelse  

; Remove slit

      for j=slitystart,slitystart+slitlength-1 do begin
        leftvalue = image[251-slitwidth/2-3,j]
        rightvalue = image[251+slitwidth/2+2,j]
        image[251-slitwidth/2-3:251+slitwidth/2+2,j] = $
        (indgen(slitwidth+6)) * $
        float((rightvalue-leftvalue)/(slitwidth+5)) + leftvalue
      endfor
    endif
    
; Remove negative values

    image1 = rot(image, -posangle,/cubic) > 0.0

; Write fits file to deslit director
      
    writefits, outdir + 'deslit_' + files[i], rotate(image1,7), header

  endfor

  end

;*******************************************************************************
;
;                             End of deslit.pro
;
;*******************************************************************************
