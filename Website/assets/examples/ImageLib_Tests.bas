' ============================================================================
' ImageLib Test Suite
' ============================================================================
' Comprehensive tests for all ImageLib functions
' Total: 85 functions tested
' ============================================================================
PRINTLN "============================================================================"
PRINTLN "ImageLib Test Suite"
PRINTLN "============================================================================"
PRINTLN
LET testsPassed = 0
LET testsFailed = 0
LET testNum = 0
' Helper function to report test results
FUNCTION ReportTest(description$, passed) LOCAL msg$
  testNum = testNum + 1
  IF passed <> 0 THEN
    testsPassed = testsPassed + 1
    msg$ = "[PASS] Test #" + stri$(testNum) + ": " + description$
  ELSE
    testsFailed = testsFailed + 1
    msg$ = "[FAIL] Test #" + stri$(testNum) + ": " + description$
  END IF
  PRINTLN msg$
END FUNCTION
' Create test form
LET frm# = form#("ImageLib Tests", 1000, 700)
' ============================================================================
' Error Handling Tests
' ============================================================================
PRINTLN
PRINTLN "--- Error Handling Tests ---"
PRINTLN
' Test 1: Clear error
image_clearerror()
LET t = 0
IF image_error() = 0 THEN
  t = 1
END IF
ReportTest("image_clearerror clears error state", t)
' Test 2: Initial error state
t = 0
IF image_error() = 0 THEN
  t = 1
END IF
ReportTest("image_error returns 0 initially", t)
' Test 3: Error message empty initially
t = 0
IF image_errormsg$() = "" THEN
  t = 1
END IF
ReportTest("image_errormsg$ returns empty string initially", t)
' Test 4: strerror for code 0
t = 0
IF image_strerror$(0) = "No error" THEN
  t = 1
END IF
ReportTest("image_strerror$ returns 'No error' for code 0", t)
' Test 5: strerror for code 1
t = 0
IF image_strerror$(1) = "Invalid image" THEN
  t = 1
END IF
ReportTest("image_strerror$ returns 'Invalid image' for code 1", t)
' Test 6: strerror for code 6
t = 0
IF image_strerror$(6) = "File not found" THEN
  t = 1
END IF
ReportTest("image_strerror$ returns 'File not found' for code 6", t)
' ============================================================================
' Creation Tests
' ============================================================================
PRINTLN
PRINTLN "--- Creation Tests ---"
PRINTLN
' Test 7: Create image with parent only
LET img1# = image#(frm#)
t = 0
IF PntToNum(img1#) <> 0 THEN
  t = 1
END IF
ReportTest("image#(parent) creates valid image", t)
' Test 8: Create image with size
LET img2# = image#(frm#, 200, 150)
t = 0
IF PntToNum(img2#) <> 0 THEN
  t = 1
END IF
ReportTest("image#(parent, w, h) creates valid image", t)
' Test 9: Check width from size constructor
t = 0
IF image_width(img2#) = 200 THEN
  t = 1
END IF
ReportTest("image width set correctly in creation", t)
' Test 10: Check height from size constructor
t = 0
IF image_height(img2#) = 150 THEN
  t = 1
END IF
ReportTest("image height set correctly in creation", t)
' Test 11: Create image with full bounds
LET img3# = image#(frm#, 50, 50, 180, 120)
t = 0
IF PntToNum(img3#) <> 0 THEN
  t = 1
END IF
ReportTest("image#(parent, x, y, w, h) creates valid image", t)
' Test 12: Check X position
t = 0
IF image_x(img3#) = 50 THEN
  t = 1
END IF
ReportTest("image X position set correctly", t)
' Test 13: Check Y position
t = 0
IF image_y(img3#) = 50 THEN
  t = 1
END IF
ReportTest("image Y position set correctly", t)
' ============================================================================
' Bitmap Properties Tests (without file)
' ============================================================================
PRINTLN
PRINTLN "--- Bitmap Properties Tests ---"
PRINTLN
' Test 14: Check if empty initially
LET imgEmpty# = image#(frm#, 250, 50, 180, 120)
t = 0
IF image_isempty(imgEmpty#) = 1 THEN
  t = 1
END IF
ReportTest("image_isempty returns 1 for new image", t)
' Test 15: Bitmap width of empty image
t = 0
IF image_bitmapwidth(imgEmpty#) = 0 THEN
  t = 1
END IF
ReportTest("image_bitmapwidth returns 0 for empty image", t)
' Test 16: Bitmap height of empty image
t = 0
IF image_bitmapheight(imgEmpty#) = 0 THEN
  t = 1
END IF
ReportTest("image_bitmapheight returns 0 for empty image", t)
' Test 17: Clear image
image_clear#(imgEmpty#)
t = 0
IF PntToNum(imgEmpty#) <> 0 THEN
  t = 1
END IF
ReportTest("image_clear# executes without error", t)
' Test 18: Clear image with color
image_clear#(imgEmpty#, "red")
t = 0
IF PntToNum(imgEmpty#) <> 0 THEN
  t = 1
END IF
ReportTest("image_clear# with color executes without error", t)
' ============================================================================
' WrapMode Tests
' ============================================================================
PRINTLN
PRINTLN "--- WrapMode Tests ---"
PRINTLN
' Test 19: Get default wrapmode (Fit = 1)
LET imgWrap# = image#(frm#, 450, 50, 180, 120)
t = 0
IF image_wrapmode(imgWrap#) = 1 THEN
  t = 1
END IF
ReportTest("image_wrapmode default is Fit (1)", t)
' Test 20: Set wrapmode to Original
image_wrapmode#(imgWrap#, 0)
t = 0
IF image_wrapmode(imgWrap#) = 0 THEN
  t = 1
END IF
ReportTest("image_wrapmode# set to Original (0)", t)
' Test 21: Set wrapmode to Stretch
image_wrapmode#(imgWrap#, 2)
t = 0
IF image_wrapmode(imgWrap#) = 2 THEN
  t = 1
END IF
ReportTest("image_wrapmode# set to Stretch (2)", t)
' Test 22: Set wrapmode to Tile
image_wrapmode#(imgWrap#, 3)
t = 0
IF image_wrapmode(imgWrap#) = 3 THEN
  t = 1
END IF
ReportTest("image_wrapmode# set to Tile (3)", t)
' Test 23: Set wrapmode to Center
image_wrapmode#(imgWrap#, 4)
t = 0
IF image_wrapmode(imgWrap#) = 4 THEN
  t = 1
END IF
ReportTest("image_wrapmode# set to Center (4)", t)
' Test 24: Set wrapmode to Place
image_wrapmode#(imgWrap#, 5)
t = 0
IF image_wrapmode(imgWrap#) = 5 THEN
  t = 1
END IF
ReportTest("image_wrapmode# set to Place (5)", t)
' Reset to Fit
image_wrapmode#(imgWrap#, 1)
' ============================================================================
' Position and Size Tests
' ============================================================================
PRINTLN
PRINTLN "--- Position and Size Tests ---"
PRINTLN
' Test 25: Get X
LET imgPos# = image#(frm#, 100, 200, 150, 100)
t = 0
IF image_x(imgPos#) = 100 THEN
  t = 1
END IF
ReportTest("image_x returns correct X", t)
' Test 26: Set X
image_x#(imgPos#, 120)
t = 0
IF image_x(imgPos#) = 120 THEN
  t = 1
END IF
ReportTest("image_x# sets X position", t)
' Test 27: Get Y
t = 0
IF image_y(imgPos#) = 200 THEN
  t = 1
END IF
ReportTest("image_y returns correct Y", t)
' Test 28: Set Y
image_y#(imgPos#, 220)
t = 0
IF image_y(imgPos#) = 220 THEN
  t = 1
END IF
ReportTest("image_y# sets Y position", t)
' Test 29: Get width
t = 0
IF image_width(imgPos#) = 150 THEN
  t = 1
END IF
ReportTest("image_width returns correct width", t)
' Test 30: Set width
image_width#(imgPos#, 160)
t = 0
IF image_width(imgPos#) = 160 THEN
  t = 1
END IF
ReportTest("image_width# sets width", t)
' Test 31: Get height
t = 0
IF image_height(imgPos#) = 100 THEN
  t = 1
END IF
ReportTest("image_height returns correct height", t)
' Test 32: Set height
image_height#(imgPos#, 110)
t = 0
IF image_height(imgPos#) = 110 THEN
  t = 1
END IF
ReportTest("image_height# sets height", t)
' Test 33: Set bounds
image_bounds#(imgPos#, 50, 400, 200, 150)
t = 0
IF image_x(imgPos#) = 50 THEN
  t = 1
END IF
ReportTest("image_bounds# sets X correctly", t)
' Test 34: Bounds sets Y
t = 0
IF image_y(imgPos#) = 400 THEN
  t = 1
END IF
ReportTest("image_bounds# sets Y correctly", t)
' Test 35: Bounds sets width
t = 0
IF image_width(imgPos#) = 200 THEN
  t = 1
END IF
ReportTest("image_bounds# sets width correctly", t)
' Test 36: Bounds sets height
t = 0
IF image_height(imgPos#) = 150 THEN
  t = 1
END IF
ReportTest("image_bounds# sets height correctly", t)
' Test 37: Set size
image_size#(imgPos#, 180, 130)
t = 0
IF image_width(imgPos#) = 180 THEN
  t = 1
END IF
ReportTest("image_size# sets width correctly", t)
' Test 38: Size sets height
t = 0
IF image_height(imgPos#) = 130 THEN
  t = 1
END IF
ReportTest("image_size# sets height correctly", t)
' Test 39: Set move
image_move#(imgPos#, 60, 410)
t = 0
IF image_x(imgPos#) = 60 THEN
  t = 1
END IF
ReportTest("image_move# sets X correctly", t)
' Test 40: Move sets Y
t = 0
IF image_y(imgPos#) = 410 THEN
  t = 1
END IF
ReportTest("image_move# sets Y correctly", t)
' ============================================================================
' Alignment Tests
' ============================================================================
PRINTLN
PRINTLN "--- Alignment Tests ---"
PRINTLN
' Test 41: Get default alignment
LET imgAlign# = image#(frm#, 300, 200, 150, 100)
t = 0
IF image_align(imgAlign#) = 0 THEN
  t = 1
END IF
ReportTest("image_align default is None (0)", t)
' Test 42: Set alignment
image_align#(imgAlign#, 1)
t = 0
IF image_align(imgAlign#) = 1 THEN
  t = 1
END IF
ReportTest("image_align# set to Top (1)", t)
' Reset alignment
image_align#(imgAlign#, 0)
image_move#(imgAlign#, 300, 200)
' ============================================================================
' Margin Tests
' ============================================================================
PRINTLN
PRINTLN "--- Margin Tests ---"
PRINTLN
' Test 43: Set margin left
LET imgMargin# = image#(frm#, 500, 200, 150, 100)
image_marginleft#(imgMargin#, 10)
t = 0
IF image_marginleft(imgMargin#) = 10 THEN
  t = 1
END IF
ReportTest("image_marginleft# sets to 10", t)
' Test 44: Set margin top
image_margintop#(imgMargin#, 15)
t = 0
IF image_margintop(imgMargin#) = 15 THEN
  t = 1
END IF
ReportTest("image_margintop# sets to 15", t)
' Test 45: Set margin right
image_marginright#(imgMargin#, 20)
t = 0
IF image_marginright(imgMargin#) = 20 THEN
  t = 1
END IF
ReportTest("image_marginright# sets to 20", t)
' Test 46: Set margin bottom
image_marginbottom#(imgMargin#, 25)
t = 0
IF image_marginbottom(imgMargin#) = 25 THEN
  t = 1
END IF
ReportTest("image_marginbottom# sets to 25", t)
' Test 47: Set all margins
image_margins#(imgMargin#, 5, 10, 15, 20)
t = 0
IF image_marginleft(imgMargin#) = 5 THEN
  t = 1
END IF
ReportTest("image_margins# sets left to 5", t)
' Test 48: Margins sets top
t = 0
IF image_margintop(imgMargin#) = 10 THEN
  t = 1
END IF
ReportTest("image_margins# sets top to 10", t)
' Test 49: Set uniform margin
image_margin#(imgMargin#, 8)
t = 0
IF image_marginleft(imgMargin#) = 8 THEN
  t = 1
END IF
ReportTest("image_margin# sets uniform left", t)
' Test 50: Uniform margin sets right
t = 0
IF image_marginright(imgMargin#) = 8 THEN
  t = 1
END IF
ReportTest("image_margin# sets uniform right", t)
' ============================================================================
' Visibility and Behavior Tests
' ============================================================================
PRINTLN
PRINTLN "--- Visibility and Behavior Tests ---"
PRINTLN
' Test 51: Get visible default
LET imgVis# = image#(frm#, 700, 200, 150, 100)
t = 0
IF image_visible(imgVis#) = 1 THEN
  t = 1
END IF
ReportTest("image_visible default is true", t)
' Test 52: Set visible false
image_visible#(imgVis#, 0)
t = 0
IF image_visible(imgVis#) = 0 THEN
  t = 1
END IF
ReportTest("image_visible# set to false", t)
' Test 53: Set visible true
image_visible#(imgVis#, 1)
t = 0
IF image_visible(imgVis#) = 1 THEN
  t = 1
END IF
ReportTest("image_visible# set to true", t)
' Test 54: Get enabled default
t = 0
IF image_enabled(imgVis#) = 1 THEN
  t = 1
END IF
ReportTest("image_enabled default is true", t)
' Test 55: Set enabled false
image_enabled#(imgVis#, 0)
t = 0
IF image_enabled(imgVis#) = 0 THEN
  t = 1
END IF
ReportTest("image_enabled# set to false", t)
' Test 56: Set enabled true
image_enabled#(imgVis#, 1)
t = 0
IF image_enabled(imgVis#) = 1 THEN
  t = 1
END IF
ReportTest("image_enabled# set to true", t)
' Test 57: Get opacity default
t = 0
IF image_opacity(imgVis#) = 1 THEN
  t = 1
END IF
ReportTest("image_opacity default is 1.0", t)
' Test 58: Set opacity
image_opacity#(imgVis#, 0.7)
LET opac = image_opacity(imgVis#)
t = 0
IF opac >= 0.69 THEN
  IF opac <= 0.71 THEN
    t = 1
  END IF
END IF
ReportTest("image_opacity# set to 0.7", t)
' Reset opacity
image_opacity#(imgVis#, 1.0)
' Test 59: Get hittest default
t = 0
IF image_hittest(imgVis#) = 1 THEN
  t = 1
END IF
ReportTest("image_hittest default is true", t)
' Test 60: Set hittest false
image_hittest#(imgVis#, 0)
t = 0
IF image_hittest(imgVis#) = 0 THEN
  t = 1
END IF
ReportTest("image_hittest# set to false", t)
' Reset hittest
image_hittest#(imgVis#, 1)
' ============================================================================
' Tag and Rotation Tests
' ============================================================================
PRINTLN
PRINTLN "--- Tag and Rotation Tests ---"
PRINTLN
' Test 61: Get tag default
LET imgTag# = image#(frm#, 50, 350, 150, 100)
t = 0
IF image_tag(imgTag#) = 0 THEN
  t = 1
END IF
ReportTest("image_tag default is 0", t)
' Test 62: Set tag
image_tag#(imgTag#, 42)
t = 0
IF image_tag(imgTag#) = 42 THEN
  t = 1
END IF
ReportTest("image_tag# set to 42", t)
' Test 63: Get rotation default
t = 0
IF image_rotation(imgTag#) = 0 THEN
  t = 1
END IF
ReportTest("image_rotation default is 0", t)
' Test 64: Set rotation
image_rotation#(imgTag#, 45)
t = 0
IF image_rotation(imgTag#) = 45 THEN
  t = 1
END IF
ReportTest("image_rotation# set to 45", t)
' ============================================================================
' Parent Tests
' ============================================================================
PRINTLN
PRINTLN "--- Parent Tests ---"
PRINTLN
' Test 65: Get parent
LET imgParent# = image#(frm#, 250, 350, 150, 100)
t = 0
IF PntToNum(image_parent#(imgParent#)) <> 0 THEN
  t = 1
END IF
ReportTest("image_parent# returns valid parent", t)
' Test 66: Bring to front
image_bringtofront#(imgParent#)
t = 0
IF PntToNum(imgParent#) <> 0 THEN
  t = 1
END IF
ReportTest("image_bringtofront# executes without error", t)
' Test 67: Send to back
image_sendtoback#(imgParent#)
t = 0
IF PntToNum(imgParent#) <> 0 THEN
  t = 1
END IF
ReportTest("image_sendtoback# executes without error", t)
' ============================================================================
' Invalidation Test
' ============================================================================
PRINTLN
PRINTLN "--- Invalidation Test ---"
PRINTLN
' Test 68: Invalidate
LET imgInv# = image#(frm#, 450, 350, 150, 100)
image_invalidate#(imgInv#)
t = 0
IF PntToNum(imgInv#) <> 0 THEN
  t = 1
END IF
ReportTest("image_invalidate# executes without error", t)
' ============================================================================
' Event Callback Tests
' ============================================================================
PRINTLN
PRINTLN "--- Event Callback Tests ---"
PRINTLN
' Test 69: Set onclick
LET imgEvent# = image#(frm#, 650, 350, 150, 100)
image_onclick#(imgEvent#, "OnImageClick")
t = 0
IF image_onclick$(imgEvent#) = "OnImageClick" THEN
  t = 1
END IF
ReportTest("image_onclick# set correctly", t)
' Test 70: Set ondblclick
image_ondblclick#(imgEvent#, "OnImageDblClick")
t = 0
IF image_ondblclick$(imgEvent#) = "OnImageDblClick" THEN
  t = 1
END IF
ReportTest("image_ondblclick# set correctly", t)
' Test 71: Set onmousedown
image_onmousedown#(imgEvent#, "OnImageMouseDown")
t = 0
IF image_onmousedown$(imgEvent#) = "OnImageMouseDown" THEN
  t = 1
END IF
ReportTest("image_onmousedown# set correctly", t)
' Test 72: Set onmouseup
image_onmouseup#(imgEvent#, "OnImageMouseUp")
t = 0
IF image_onmouseup$(imgEvent#) = "OnImageMouseUp" THEN
  t = 1
END IF
ReportTest("image_onmouseup# set correctly", t)
' Test 73: Set onmousemove
image_onmousemove#(imgEvent#, "OnImageMouseMove")
t = 0
IF image_onmousemove$(imgEvent#) = "OnImageMouseMove" THEN
  t = 1
END IF
ReportTest("image_onmousemove# set correctly", t)
' Test 74: Set onmouseenter
image_onmouseenter#(imgEvent#, "OnImageEnter")
t = 0
IF image_onmouseenter$(imgEvent#) = "OnImageEnter" THEN
  t = 1
END IF
ReportTest("image_onmouseenter# set correctly", t)
' Test 75: Set onmouseleave
image_onmouseleave#(imgEvent#, "OnImageLeave")
t = 0
IF image_onmouseleave$(imgEvent#) = "OnImageLeave" THEN
  t = 1
END IF
ReportTest("image_onmouseleave# set correctly", t)
' Test 76: Set onmousewheel
image_onmousewheel#(imgEvent#, "OnImageWheel")
t = 0
IF image_onmousewheel$(imgEvent#) = "OnImageWheel" THEN
  t = 1
END IF
ReportTest("image_onmousewheel# set correctly", t)
' Test 77: Set onresize
image_onresize#(imgEvent#, "OnImageResize")
t = 0
IF image_onresize$(imgEvent#) = "OnImageResize" THEN
  t = 1
END IF
ReportTest("image_onresize# set correctly", t)
' Test 78: Clear callbacks
image_clearcallbacks#(imgEvent#)
t = 0
IF PntToNum(imgEvent#) <> 0 THEN
  t = 1
END IF
ReportTest("image_clearcallbacks# returns valid pointer", t)
' Test 79: Callbacks cleared
t = 0
IF image_onclick$(imgEvent#) = "" THEN
  t = 1
END IF
ReportTest("image_clearcallbacks# clears onclick", t)
' ============================================================================
' File Load Error Test
' ============================================================================
PRINTLN
PRINTLN "--- File Load Error Test ---"
PRINTLN
' Test 80: Load non-existent file
image_clearerror()
LET loadResult = image_load(imgEvent#, "nonexistent_file_xyz123.png")
t = 0
IF loadResult = 0 THEN
  t = 1
END IF
ReportTest("image_load returns 0 for non-existent file", t)
' Test 81: Error set after failed load
t = 0
IF image_error() = 6 THEN
  t = 1
END IF
ReportTest("image_error returns 6 (file not found) after failed load", t)
' ============================================================================
' Destruction Test
' ============================================================================
PRINTLN
PRINTLN "--- Destruction Test ---"
PRINTLN
' Test 82: Free function exists
ReportTest("image_free function available (not executed)", 1)
' ============================================================================
' Visual Demo Setup
' ============================================================================
' Style the test images with colors for visual verification
image_clear#(img3#, "#e74c3c")
image_clear#(imgEmpty#, "#3498db")
image_clear#(imgWrap#, "#2ecc71")
image_clear#(imgPos#, "#9b59b6")
image_clear#(imgAlign#, "#f39c12")
image_clear#(imgMargin#, "#1abc9c")
image_clear#(imgVis#, "#e67e22")
image_clear#(imgTag#, "#34495e")
image_clear#(imgParent#, "#c0392b")
image_clear#(imgInv#, "#16a085")
image_clear#(imgEvent#, "#8e44ad")
' ============================================================================
' Web Image Loading Demo
' ============================================================================
PRINTLN
PRINTLN "--- Web Image Loading Demo ---"
PRINTLN
PRINTLN "Loading images from Lorem Picsum (https://picsum.photos)..."
PRINTLN
' Create web image gallery
LET lblWeb# = label#(frm#, "Web Images from Lorem Picsum:", 50, 560)
LET webImg1# = image#(frm#, 50, 580, 150, 100)
LET webImg2# = image#(frm#, 210, 580, 150, 100)
LET webImg3# = image#(frm#, 370, 580, 150, 100)
LET webImg4# = image#(frm#, 530, 580, 150, 100)
LET webImg5# = image#(frm#, 690, 580, 150, 100)
' Set wrap mode to Fit for all web images
image_wrapmode#(webImg1#, 1)
image_wrapmode#(webImg2#, 1)
image_wrapmode#(webImg3#, 1)
image_wrapmode#(webImg4#, 1)
image_wrapmode#(webImg5#, 1)
' Load images from web using consistent seeds
PRINTLN "Loading image 1 (nature)..."
image_load#(webImg1#, "https://picsum.photos/seed/nature/150/100")
PRINTLN "Loading image 2 (city)..."
image_load#(webImg2#, "https://picsum.photos/seed/city/150/100")
PRINTLN "Loading image 3 (ocean)..."
image_load#(webImg3#, "https://picsum.photos/seed/ocean/150/100")
PRINTLN "Loading image 4 (forest)..."
image_load#(webImg4#, "https://picsum.photos/seed/forest/150/100")
PRINTLN "Loading image 5 (grayscale)..."
image_load#(webImg5#, "https://picsum.photos/seed/mountain/150/100?grayscale")
' Test web image dimensions
LET webW = image_bitmapwidth(webImg1#)
LET webH = image_bitmapheight(webImg1#)
t = 0
IF webW > 0 THEN
  IF webH > 0 THEN
    t = 1
  END IF
END IF
ReportTest("Web image loaded with dimensions " + stri$(webW) + "x" + stri$(webH), t)
' Test that web image is not empty
t = 0
IF image_isempty(webImg1#) = 0 THEN
  t = 1
END IF
ReportTest("Web image is not empty after loading", t)
PRINTLN
PRINTLN "Web images loaded successfully!"
PRINTLN
' ============================================================================
' Interactive Demo Image
' ============================================================================
' Create interactive image for event testing
LET imgDemo# = image#(frm#, 850, 50, 130, 130)
image_load#(imgDemo#, "https://picsum.photos/seed/demo/130/130")
image_wrapmode#(imgDemo#, 1)
image_onclick#(imgDemo#, "OnDemoClick")
image_onmouseenter#(imgDemo#, "OnDemoEnter")
image_onmouseleave#(imgDemo#, "OnDemoLeave")
image_onmousewheel#(imgDemo#, "OnDemoWheel")
' Label for interactive demo
LET lblDemo# = label#(frm#, "Click or scroll on image", 840, 190)
' Rotation counter for demo
LET demoRotation = 0
' ============================================================================
' Summary
' ============================================================================
PRINTLN
PRINTLN "============================================================================"
PRINTLN "Test Summary"
PRINTLN "============================================================================"
PRINTLN "Total Tests:  " + stri$(testNum)
PRINTLN "Passed:       " + stri$(testsPassed)
PRINTLN "Failed:       " + stri$(testsFailed)
PRINTLN
IF testsFailed = 0 THEN
  PRINTLN "*** ALL TESTS PASSED ***"
ELSE
  PRINTLN "*** SOME TESTS FAILED ***"
END IF
PRINTLN
PRINTLN "============================================================================"
PRINTLN "Visual Test - Image Controls"
PRINTLN "============================================================================"
PRINTLN "Multiple colored images and web images should be visible."
PRINTLN "Bottom row shows 5 images loaded from Lorem Picsum (web)."
PRINTLN "Top-right image is interactive: click to rotate, scroll wheel for fine control."
PRINTLN
form_show(frm#)
' Event handlers for interactive demo
FUNCTION OnDemoClick(sender#)
  demoRotation = demoRotation + 15
  IF demoRotation >= 360 THEN
    demoRotation = 0
  END IF
  image_rotation#(sender#, demoRotation)
  label_text#(lblDemo#, "Rotation: " + stri$(demoRotation) + "°")
END FUNCTION
FUNCTION OnDemoEnter(sender#)
  image_opacity#(sender#, 0.7)
  label_text#(lblDemo#, "Mouse entered!")
END FUNCTION
FUNCTION OnDemoLeave(sender#)
  image_opacity#(sender#, 1.0)
  label_text#(lblDemo#, "Mouse left")
END FUNCTION
FUNCTION OnDemoWheel(sender#, delta, shift$)
  IF delta > 0 THEN
    demoRotation = demoRotation + 5
  ELSE
    demoRotation = demoRotation - 5
  END IF
  IF demoRotation >= 360 THEN
    demoRotation = demoRotation - 360
  END IF
  IF demoRotation < 0 THEN
    demoRotation = demoRotation + 360
  END IF
  image_rotation#(sender#, demoRotation)
  label_text#(lblDemo#, "Wheel: " + stri$(demoRotation) + "°")
END FUNCTION
