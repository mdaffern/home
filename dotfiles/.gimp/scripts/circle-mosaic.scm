; Circle-mosaic.scm for GIMP2.2 & GIMP1.2
;                                                    "         "                                 "Outline"                            
; Copyright (C) 2005           
; -------------------------------------------------------------------------------------------

(define (script-fu-circle-mosaic image drawable size outline)
 (let* ((width (car (gimp-drawable-width drawable)))
        (height (car (gimp-drawable-height drawable)))
        (type (car (gimp-drawable-type drawable)))
        (alpha (car (gimp-drawable-has-alpha drawable)))
        (selection (car (gimp-selection-is-empty image)))
        (mosaic-layer (car (gimp-layer-copy drawable TRUE)))
        (old-fg (car (gimp-context-get-foreground))) 
        (channel)(copy-layer)(new-image)(background)(selection-layer)

)

  (gimp-image-undo-group-start image)

  (if (= selection FALSE)
    (begin
      (set! channel (car (gimp-selection-save image)))
      (gimp-selection-none image)
      (set! copy-layer (car (gimp-layer-copy drawable TRUE)))
  ))

  (gimp-edit-fill drawable 2)
  (gimp-drawable-set-name drawable "Base Color")
  (gimp-drawable-set-name mosaic-layer "Circle Mosaic")
  (gimp-image-add-layer image mosaic-layer -1)
  (plug-in-pixelize 1 image mosaic-layer size)

  (set! new-image (car (gimp-image-new size size 1)))
  (set! background (car (gimp-layer-new new-image size size 3 "background" 100 NORMAL)))
  (gimp-image-add-layer new-image background -1)
  (gimp-drawable-fill background TRANSPARENT-FILL)
  (gimp-ellipse-select new-image 0 0 (- size 1) (- size 1) REPLACE TRUE FALSE 0)
  (gimp-edit-fill background 2)
  (gimp-selection-none new-image)
  (plug-in-tile 1 new-image background width height FALSE)
  (gimp-edit-copy background)

  (set! selection-layer (car (gimp-edit-paste mosaic-layer FALSE)))
  (gimp-drawable-set-name selection-layer "Selection Layer")
  (gimp-selection-layer-alpha selection-layer)
  (gimp-selection-invert image)
  (gimp-edit-clear mosaic-layer)
  (gimp-selection-none image)
  (gimp-layer-set-preserve-trans mosaic-layer TRUE)
  (gimp-image-remove-layer image selection-layer)

  (if (= outline TRUE)
    (begin
      (gimp-selection-layer-alpha mosaic-layer)
      (gimp-selection-shrink image 1)
      (gimp-selection-invert image)
      (gimp-context-set-foreground '(0 0 0))
      (gimp-bucket-fill mosaic-layer 0 0 60 255 FALSE 0 0)
      (gimp-selection-none image)
  ))

  (if (= selection FALSE)
    (begin
      (gimp-image-add-layer image copy-layer -1)
      (gimp-selection-load channel)
      (gimp-edit-clear copy-layer)
      (gimp-image-merge-down image copy-layer 0)
      (gimp-image-remove-channel image channel)
  ))

  (gimp-image-delete new-image)
  (gimp-context-set-foreground old-fg)
  (gimp-image-undo-group-end image)
  (gimp-displays-flush)
))

(script-fu-register "script-fu-circle-mosaic"
 	"Circle Mosaic..."
 	"                                       "
 	"Etigoya"
 	"Etigoya"
 	"2005/09"
 	"RGB* GRAY*"
 	SF-IMAGE      "Image"    0
 	SF-DRAWABLE   "Drawable" 0 
 	SF-ADJUSTMENT "         "       '(20 10 100 1 1 0 0)
 	SF-TOGGLE     "                  "  FALSE
)

(script-fu-menu-register "script-fu-circle-mosaic"
 	"<Image>/Script-Fu/Alchemy"
)
