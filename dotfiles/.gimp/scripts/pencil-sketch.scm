; The GIMP -- an image manipulation program
; Copyright (C) 1995 Spencer Kimball and Peter Mattis
; ---------------------------------------------------------------------
; The GIMP script-fu  Pencil Sketch for GIMP1.2 & 2.0
; Copyright (C) 2004 Tamagoro <tamagoro_1@excite.co.jp>
; ---------------------------------------------------------------------
; This program is free software; you can redistribute it and/or modify
; it under the terms of the GNU General Public License as published by
; the Free Software Foundation; either version 2 of the License, or
; (at your option) any later version.
; 
; This program is distributed in the hope that it will be useful,
; but WITHOUT ANY WARRANTY; without even the implied warranty of
; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
; GNU General Public License for more details.
; 
; You should have received a copy of the GNU General Public License
; along with this program; if not, write to the Free Software
; Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
; ---------------------------------------------------------------------

(define (script-fu-pencil-sketch image drawable)
  (let* (
 	     (W (car (gimp-image-width image)))
 	     (H (car (gimp-image-height image)))
 	     (type (car (gimp-drawable-type drawable)))
 	     (select (car (gimp-selection-is-empty image)))
 	     (select-channel)
 	     (backup-layer)
 	     (copy-layer)
 	     (base-layer)  )
  	
 	(gimp-image-undo-group-start image)
 	(if (equal? select FALSE) 
 	(begin 
 	    (set! select-channel (car (gimp-selection-save image)))
 	    (set! backup-layer (car (gimp-layer-copy drawable 1)))))

 	(if (< type 2) (gimp-desaturate drawable))
 	(plug-in-normalize 1 image drawable)
 	(plug-in-noisify 1 image drawable FALSE 0.01 0.01 0.01 0.00)
 	(plug-in-sharpen 1 image drawable 70)
 	(plug-in-noisify 1 image drawable FALSE 0.01 0.01 0.01 0.00)

	(set! copy-layer (car (gimp-layer-copy drawable 1)))
 	(gimp-image-add-layer image copy-layer -1)
 	(gimp-layer-set-mode copy-layer DIVIDE)
 	(plug-in-gauss-iir 1 image copy-layer (+ 1 (/ (+ W H) 500)) TRUE TRUE)
 	(set! base-layer (car (gimp-image-merge-down image copy-layer 2)))

 	(set! copy-layer (car (gimp-layer-copy base-layer 1)))
 	(gimp-image-add-layer image copy-layer -1)
 	(gimp-brightness-contrast copy-layer 0 125)
 	(gimp-invert copy-layer)
 	(gimp-layer-set-mode copy-layer SCREEN)
 	(gimp-layer-set-opacity copy-layer 60)
 	(set! base-layer (car (gimp-image-merge-down image copy-layer 2)))
 	(plug-in-normalize 1 image base-layer)

 	(set! copy-layer (car (gimp-layer-copy base-layer 1)))
 	(gimp-image-add-layer image copy-layer -1)
 	(gimp-invert copy-layer)
 	(gimp-layer-set-mode copy-layer OVERLAY)
 	(gimp-layer-set-opacity copy-layer 50)
 	(set! base-layer (car (gimp-image-merge-down image copy-layer 2)))

 	(set! copy-layer (car (gimp-layer-copy base-layer 1)))
 	(gimp-image-add-layer image copy-layer -1)
 	(plug-in-gauss-iir 1 image copy-layer 1 TRUE TRUE)
 	(gimp-layer-set-opacity copy-layer 60)
 	(set! base-layer (car (gimp-image-merge-down image copy-layer 2)))
 	(if (< type 2)
 	    (plug-in-vpropagate 1 image base-layer 2 TRUE 1.0 15 0 255)
 	    (begin (gimp-convert-rgb image)
 	       (plug-in-vpropagate 1 image base-layer 2 TRUE 1.0 15 0 255)
 	       (gimp-convert-grayscale image)) )
  	(gimp-levels base-layer 0 30 255 1.0 0 255)

	(if (equal? select FALSE) 
	    (begin 
 		   (gimp-image-add-layer image backup-layer -1)
 		   (gimp-selection-load select-channel)
 		   (gimp-edit-clear backup-layer)
 		   (gimp-image-remove-channel image select-channel)
 		   (gimp-image-merge-down image backup-layer 2)) )

 	(gimp-image-undo-group-end image)
 	(gimp-displays-flush)
  )
)

(script-fu-register "script-fu-pencil-sketch"
 	"Pencil Sketch"
 	"                                    "
 	"Tamagoro <tamagoro_1@excite.co.jp>"
 	"Tamagoro"
 	"October 2004"
 	"RGB*, GRAY*"
 	 SF-IMAGE      _"Image"     0
 	 SF-DRAWABLE   _"Drawable"  0
)

(script-fu-menu-register "script-fu-pencil-sketch"
 	"<Image>/Script-Fu/Photo"
)