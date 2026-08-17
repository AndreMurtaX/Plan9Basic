' ============================================================================
' Web Image Gallery Demo
' ============================================================================
' Demonstrates loading images from the web using ImageLib
' Images provided by Lorem Picsum (https://picsum.photos)
' ============================================================================
PRINTLN "Web Image Gallery - Loading images from Lorem Picsum..."
PRINTLN ""
' Create main form
LET frm# = form#("Web Image Gallery", 950, 730)
LET sb# = scrollbox#(frm#)
' Title
LET lblTitle# = label#(sb#, "Web Image Gallery", 20, 10)
' Create thumbnail grid (2 rows x 4 columns)
LET thumb1# = image#(sb#, 20, 50, 220, 150)
LET thumb2# = image#(sb#, 250, 50, 220, 150)
LET thumb3# = image#(sb#, 480, 50, 220, 150)
LET thumb4# = image#(sb#, 710, 50, 220, 150)
LET thumb5# = image#(sb#, 20, 210, 220, 150)
LET thumb6# = image#(sb#, 250, 210, 220, 150)
LET thumb7# = image#(sb#, 480, 210, 220, 150)
LET thumb8# = image#(sb#, 710, 210, 220, 150)
' Set all thumbnails to Fit mode
image_wrapmode#(thumb1#, 1)
image_wrapmode#(thumb2#, 1)
image_wrapmode#(thumb3#, 1)
image_wrapmode#(thumb4#, 1)
image_wrapmode#(thumb5#, 1)
image_wrapmode#(thumb6#, 1)
image_wrapmode#(thumb7#, 1)
image_wrapmode#(thumb8#, 1)
' Store seed names in tags for later reference
image_tag#(thumb1#, 1)
image_tag#(thumb2#, 2)
image_tag#(thumb3#, 3)
image_tag#(thumb4#, 4)
image_tag#(thumb5#, 5)
image_tag#(thumb6#, 6)
image_tag#(thumb7#, 7)
image_tag#(thumb8#, 8)
' Make thumbnails clickable
image_onclick#(thumb1#, "OnThumbClick")
image_onclick#(thumb2#, "OnThumbClick")
image_onclick#(thumb3#, "OnThumbClick")
image_onclick#(thumb4#, "OnThumbClick")
image_onclick#(thumb5#, "OnThumbClick")
image_onclick#(thumb6#, "OnThumbClick")
image_onclick#(thumb7#, "OnThumbClick")
image_onclick#(thumb8#, "OnThumbClick")
' Add hover effects
image_onmouseenter#(thumb1#, "OnThumbEnter")
image_onmouseenter#(thumb2#, "OnThumbEnter")
image_onmouseenter#(thumb3#, "OnThumbEnter")
image_onmouseenter#(thumb4#, "OnThumbEnter")
image_onmouseenter#(thumb5#, "OnThumbEnter")
image_onmouseenter#(thumb6#, "OnThumbEnter")
image_onmouseenter#(thumb7#, "OnThumbEnter")
image_onmouseenter#(thumb8#, "OnThumbEnter")
image_onmouseleave#(thumb1#, "OnThumbLeave")
image_onmouseleave#(thumb2#, "OnThumbLeave")
image_onmouseleave#(thumb3#, "OnThumbLeave")
image_onmouseleave#(thumb4#, "OnThumbLeave")
image_onmouseleave#(thumb5#, "OnThumbLeave")
image_onmouseleave#(thumb6#, "OnThumbLeave")
image_onmouseleave#(thumb7#, "OnThumbLeave")
image_onmouseleave#(thumb8#, "OnThumbLeave")
' Main display area
LET imgMain# = image#(sb#, 20, 380, 910, 280)
image_wrapmode#(imgMain#, 1)
' Status label
LET lblStatus# = label#(sb#, "Loading thumbnails from web...", 20, 670)
' Seed names for consistent images
LET seeds$ = "nature,city,ocean,forest,mountain,sunset,beach,river"
' Load thumbnails from web
PRINTLN "Loading thumbnail 1 (nature)..."
image_load#(thumb1#, "https://picsum.photos/seed/nature/220/150")
PRINTLN "Loading thumbnail 2 (city)..."
image_load#(thumb2#, "https://picsum.photos/seed/city/220/150")
PRINTLN "Loading thumbnail 3 (ocean)..."
image_load#(thumb3#, "https://picsum.photos/seed/ocean/220/150")
PRINTLN "Loading thumbnail 4 (forest)..."
image_load#(thumb4#, "https://picsum.photos/seed/forest/220/150")
PRINTLN "Loading thumbnail 5 (mountain)..."
image_load#(thumb5#, "https://picsum.photos/seed/mountain/220/150")
PRINTLN "Loading thumbnail 6 (sunset)..."
image_load#(thumb6#, "https://picsum.photos/seed/sunset/220/150")
PRINTLN "Loading thumbnail 7 (beach)..."
image_load#(thumb7#, "https://picsum.photos/seed/beach/220/150")
PRINTLN "Loading thumbnail 8 (river)..."
image_load#(thumb8#, "https://picsum.photos/seed/river/220/150")
' Load first image in main display
PRINTLN "Loading main display..."
image_load#(imgMain#, "https://picsum.photos/seed/nature/910/280")
PRINTLN ""
PRINTLN "All images loaded!"
PRINTLN "Click on any thumbnail to view it in the main display area."
label_text#(lblStatus#, "Click a thumbnail to view larger. Images from Lorem Picsum (picsum.photos)")
' Seed names for word$() function
LET seeds$ = "nature,city,ocean,forest,mountain,sunset,beach,river"
form_show(frm#)
IF os_name$() = "Android" OR os_name$() = "iOS" THEN
  PRINTLN "Note: Images are loaded from the web synchronously."
  PRINTLN "The UI may pause briefly while each image downloads on mobile."
  PRINTLN ""
END IF
' ============================================================================
' Event Handlers
' ============================================================================
FUNCTION OnThumbClick(sender#) LOCAL tag, seed$, url$
  tag = image_tag(sender#)
  seed$ = word$(seeds$, tag, ",")
  url$ = "https://picsum.photos/seed/" + seed$ + "/910/280"
  label_text#(lblStatus#, "Loading: " + seed$ + "...")
  image_load#(imgMain#, url$)
  label_text#(lblStatus#, "Viewing: " + seed$ + " (from picsum.photos/seed/" + seed$ + ")")
END FUNCTION
FUNCTION OnThumbEnter(sender#)
  image_opacity#(sender#, 0.7)
END FUNCTION
FUNCTION OnThumbLeave(sender#)
  image_opacity#(sender#, 1.0)
END FUNCTION
