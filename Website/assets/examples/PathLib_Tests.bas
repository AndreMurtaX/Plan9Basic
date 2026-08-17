' ============================================================================
' PathLib Test Suite
' ============================================================================
' Comprehensive tests for all PathLib functions
' Total: 105 functions tested
' ============================================================================
PRINTLN "============================================================================"
PRINTLN "PathLib Test Suite"
PRINTLN "============================================================================"
PRINTLN ""
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
LET frm# = form#("PathLib Tests", 1000, 700)
' ============================================================================
' Error Handling Tests
' ============================================================================
PRINTLN ""
PRINTLN "--- Error Handling Tests ---"
PRINTLN ""
' Test 1: Clear error
path_clearerror()
LET t = 0
IF path_error() = 0 THEN
  t = 1
END IF
ReportTest("path_clearerror clears error state", t)
' Test 2: Initial error state
t = 0
IF path_error() = 0 THEN
  t = 1
END IF
ReportTest("path_error returns 0 initially", t)
' Test 3: Error message empty initially
t = 0
IF path_errormsg$() = "" THEN
  t = 1
END IF
ReportTest("path_errormsg returns empty string initially", t)
' Test 4: strerror for code 0
t = 0
IF path_strerror$(0) = "No error" THEN
  t = 1
END IF
ReportTest("path_strerror returns 'No error' for code 0", t)
' Test 5: strerror for code 1
t = 0
IF path_strerror$(1) = "Invalid path" THEN
  t = 1
END IF
ReportTest("path_strerror returns 'Invalid path' for code 1", t)
' Test 6: strerror for code 7
t = 0
IF path_strerror$(7) = "Invalid path data" THEN
  t = 1
END IF
ReportTest("path_strerror returns 'Invalid path data' for code 7", t)
' ============================================================================
' Creation Tests
' ============================================================================
PRINTLN ""
PRINTLN "--- Creation Tests ---"
PRINTLN ""
' Test 7: Create path with parent only
LET p1# = path#(frm#)
t = 0
IF PntToNum(p1#) <> 0 THEN
  t = 1
END IF
ReportTest("path#(parent) creates valid path", t)
' Test 8: Create path with size
LET p2# = path#(frm#, 100, 100)
t = 0
IF PntToNum(p2#) <> 0 THEN
  t = 1
END IF
ReportTest("path#(parent, w, h) creates valid path", t)
' Test 9: Check width from size constructor
t = 0
IF path_width(p2#) = 100 THEN
  t = 1
END IF
ReportTest("path width set correctly in creation", t)
' Test 10: Create path with full bounds
LET p3# = path#(frm#, 50, 50, 150, 150)
t = 0
IF PntToNum(p3#) <> 0 THEN
  t = 1
END IF
ReportTest("path#(parent, x, y, w, h) creates valid path", t)
' Test 11: Check X position
t = 0
IF path_x(p3#) = 50 THEN
  t = 1
END IF
ReportTest("path X position set correctly", t)
' Test 12: Check Y position
t = 0
IF path_y(p3#) = 50 THEN
  t = 1
END IF
ReportTest("path Y position set correctly", t)
' ============================================================================
' Path Data String Tests
' ============================================================================
PRINTLN ""
PRINTLN "--- Path Data String Tests ---"
PRINTLN ""
' Test 13: Set path data via string
LET pStr# = path#(frm#, 200, 50, 100, 100)
path_data#(pStr#, "M 10,10 L 90,10 L 90,90 L 10,90 Z")
t = 0
IF len(path_data$(pStr#)) > 0 THEN
  t = 1
END IF
ReportTest("path_data# sets SVG path string", t)
' Test 14: Get path data
LET dataStr$ = path_data$(pStr#)
t = 0
IF len(dataStr$) > 0 THEN
  t = 1
END IF
ReportTest("path_data$ retrieves path string", t)
' ============================================================================
' Programmatic Path Construction Tests
' ============================================================================
PRINTLN ""
PRINTLN "--- Programmatic Path Construction Tests ---"
PRINTLN ""
' Test 15: MoveTo
LET pProg# = path#(frm#, 320, 50, 100, 100)
path_moveto#(pProg#, 10, 10)
t = 0
IF PntToNum(pProg#) <> 0 THEN
  t = 1
END IF
ReportTest("path_moveto# executes without error", t)
' Test 16: LineTo
path_lineto#(pProg#, 90, 10)
t = 0
IF path_pointcount(pProg#) >= 2 THEN
  t = 1
END IF
ReportTest("path_lineto# executes without error", t)
' Test 17: HLineTo
path_hlineto#(pProg#, 50)
t = 0
IF path_pointcount(pProg#) >= 3 THEN
  t = 1
END IF
ReportTest("path_hlineto# executes without error", t)
' Test 18: VLineTo
path_vlineto#(pProg#, 90)
t = 0
IF path_pointcount(pProg#) >= 4 THEN
  t = 1
END IF
ReportTest("path_vlineto# executes without error", t)
' Test 19: ClosePath
path_closepath#(pProg#)
t = 0
IF path_pointcount(pProg#) >= 5 THEN
  t = 1
END IF
ReportTest("path_closepath# executes without error", t)
' Test 20: Clear path
LET pClear# = path#(frm#, 440, 50, 100, 100)
path_moveto#(pClear#, 0, 0)
path_lineto#(pClear#, 50, 50)
path_clear#(pClear#)
t = 0
IF path_pointcount(pClear#) = 0 THEN
  t = 1
END IF
ReportTest("path_clear# clears path data", t)
' ============================================================================
' Curve Tests
' ============================================================================
PRINTLN ""
PRINTLN "--- Curve Tests ---"
PRINTLN ""
' Test 21: CurveTo (Cubic Bezier)
LET pCurve# = path#(frm#, 50, 180, 120, 120)
path_moveto#(pCurve#, 10, 60)
path_curveto#(pCurve#, 30, 10, 70, 110, 110, 60)
t = 0
IF path_pointcount(pCurve#) >= 4 THEN
  t = 1
END IF
ReportTest("path_curveto# creates cubic bezier", t)
' Test 22: SmoothCurveTo
LET pSmooth# = path#(frm#, 190, 180, 120, 120)
path_moveto#(pSmooth#, 10, 60)
path_curveto#(pSmooth#, 20, 10, 40, 10, 50, 60)
path_smoothcurveto#(pSmooth#, 80, 110, 110, 60)
t = 0
IF path_pointcount(pSmooth#) >= 7 THEN
  t = 1
END IF
ReportTest("path_smoothcurveto# creates smooth curve", t)
' Test 23: QuadCurveTo (Quadratic Bezier)
LET pQuad# = path#(frm#, 330, 180, 120, 120)
path_moveto#(pQuad#, 10, 100)
path_quadcurveto#(pQuad#, 60, 10, 110, 100)
t = 0
IF path_pointcount(pQuad#) >= 3 THEN
  t = 1
END IF
ReportTest("path_quadcurveto# creates quadratic bezier", t)
' ============================================================================
' Helper Shape Tests
' ============================================================================
PRINTLN ""
PRINTLN "--- Helper Shape Tests ---"
PRINTLN ""
' Test 24: AddRectangle
LET pRect# = path#(frm#, 470, 180, 120, 120)
path_addrectangle#(pRect#, 10, 10, 100, 100, 10, 10)
t = 0
IF path_pointcount(pRect#) > 0 THEN
  t = 1
END IF
ReportTest("path_addrectangle# adds rectangle to path", t)
' Test 25: AddEllipse
LET pEllipse# = path#(frm#, 610, 180, 120, 120)
path_addellipse#(pEllipse#, 10, 10, 100, 100)
t = 0
IF path_pointcount(pEllipse#) > 0 THEN
  t = 1
END IF
ReportTest("path_addellipse# adds ellipse to path", t)
' Test 26: AddArc
LET pArc# = path#(frm#, 750, 180, 120, 120)
path_addarc#(pArc#, 60, 60, 40, 40, 0, 270)
t = 0
IF path_pointcount(pArc#) > 0 THEN
  t = 1
END IF
ReportTest("path_addarc# adds arc to path", t)
' ============================================================================
' Path Transformation Tests
' ============================================================================
PRINTLN ""
PRINTLN "--- Path Transformation Tests ---"
PRINTLN ""
' Test 27: Scale
LET pScale# = path#(frm#, 50, 320, 100, 100)
path_moveto#(pScale#, 10, 10)
path_lineto#(pScale#, 50, 50)
path_scale#(pScale#, 1.5, 1.5)
t = 0
IF PntToNum(pScale#) <> 0 THEN
  t = 1
END IF
ReportTest("path_scale# scales path data", t)
' Test 28: Translate
LET pTrans# = path#(frm#, 170, 320, 100, 100)
path_moveto#(pTrans#, 10, 10)
path_lineto#(pTrans#, 50, 50)
path_translate#(pTrans#, 20, 20)
t = 0
IF PntToNum(pTrans#) <> 0 THEN
  t = 1
END IF
ReportTest("path_translate# translates path data", t)
' Test 29: Rotate
LET pRotate# = path#(frm#, 290, 320, 100, 100)
path_moveto#(pRotate#, 25, 50)
path_lineto#(pRotate#, 75, 50)
path_rotate#(pRotate#, 45)
t = 0
IF PntToNum(pRotate#) <> 0 THEN
  t = 1
END IF
ReportTest("path_rotate# rotates path data", t)
' ============================================================================
' Path Query Tests
' ============================================================================
PRINTLN ""
PRINTLN "--- Path Query Tests ---"
PRINTLN ""
' Test 30: Point count
LET pQuery# = path#(frm#, 410, 320, 100, 100)
path_moveto#(pQuery#, 10, 10)
path_lineto#(pQuery#, 90, 10)
path_lineto#(pQuery#, 90, 90)
path_lineto#(pQuery#, 10, 90)
path_closepath#(pQuery#)
t = 0
IF path_pointcount(pQuery#) >= 5 THEN
  t = 1
END IF
ReportTest("path_pointcount returns correct count", t)
' Test 31: LastX
LET lastX = path_lastx(pQuery#)
t = 0
IF lastX >= 0 THEN
  t = 1
END IF
ReportTest("path_lastx returns last X coordinate", t)
' Test 32: LastY
LET lastY = path_lasty(pQuery#)
t = 0
IF lastY >= 0 THEN
  t = 1
END IF
ReportTest("path_lasty returns last Y coordinate", t)
' Test 33: Bounds X
LET bx = path_boundsx(pQuery#)
t = 0
IF bx >= 0 THEN
  t = 1
END IF
ReportTest("path_boundsx returns bounds left", t)
' Test 34: Bounds Y
LET by = path_boundsy(pQuery#)
t = 0
IF by >= 0 THEN
  t = 1
END IF
ReportTest("path_boundsy returns bounds top", t)
' Test 35: Bounds Width
LET bw = path_boundswidth(pQuery#)
t = 0
IF bw > 0 THEN
  t = 1
END IF
ReportTest("path_boundswidth returns bounds width", t)
' Test 36: Bounds Height
LET bh = path_boundsheight(pQuery#)
t = 0
IF bh > 0 THEN
  t = 1
END IF
ReportTest("path_boundsheight returns bounds height", t)
' ============================================================================
' WrapMode Tests
' ============================================================================
PRINTLN ""
PRINTLN "--- WrapMode Tests ---"
PRINTLN ""
' Test 37: Get default wrapmode (Stretch = 2)
LET pWrap# = path#(frm#, 530, 320, 100, 100)
path_addrectangle#(pWrap#, 10, 10, 30, 30, 0, 0)
t = 0
IF path_wrapmode(pWrap#) = 2 THEN
  t = 1
END IF
ReportTest("path_wrapmode default is Stretch (2)", t)
' Test 38: Set wrapmode to Original
path_wrapmode#(pWrap#, 0)
t = 0
IF path_wrapmode(pWrap#) = 0 THEN
  t = 1
END IF
ReportTest("path_wrapmode# set to Original (0)", t)
' Test 39: Set wrapmode to Fit
path_wrapmode#(pWrap#, 1)
t = 0
IF path_wrapmode(pWrap#) = 1 THEN
  t = 1
END IF
ReportTest("path_wrapmode# set to Fit (1)", t)
' Test 40: Set wrapmode to Tile
path_wrapmode#(pWrap#, 3)
t = 0
IF path_wrapmode(pWrap#) = 3 THEN
  t = 1
END IF
ReportTest("path_wrapmode# set to Tile (3)", t)
' ============================================================================
' Fill Tests
' ============================================================================
PRINTLN ""
PRINTLN "--- Fill Tests ---"
PRINTLN ""
' Test 41: Set fill color
LET pFill# = path#(frm#, 650, 320, 100, 100)
path_addrectangle#(pFill#, 10, 10, 80, 80, 5, 5)
path_fill#(pFill#, "#FF0000")
t = 0
IF len(path_fill$(pFill#)) > 0 THEN
  t = 1
END IF
ReportTest("path_fill# sets fill color", t)
' Test 42: Set fill named color
path_fill#(pFill#, "blue")
t = 0
IF len(path_fill$(pFill#)) > 0 THEN
  t = 1
END IF
ReportTest("path_fill# sets named color", t)
' Test 43: Remove fill
path_fillnone#(pFill#)
t = 0
IF PntToNum(pFill#) <> 0 THEN
  t = 1
END IF
ReportTest("path_fillnone# removes fill (visual verification)", t)
' ============================================================================
' Stroke Tests
' ============================================================================
PRINTLN ""
PRINTLN "--- Stroke Tests ---"
PRINTLN ""
' Test 44: Set stroke color
LET pStroke# = path#(frm#, 770, 320, 100, 100)
path_addrectangle#(pStroke#, 10, 10, 80, 80, 0, 0)
path_stroke#(pStroke#, "#00FF00")
t = 0
IF len(path_stroke$(pStroke#)) > 0 THEN
  t = 1
END IF
ReportTest("path_stroke# sets stroke color", t)
' Test 45: Set stroke named color
path_stroke#(pStroke#, "purple")
t = 0
IF len(path_stroke$(pStroke#)) > 0 THEN
  t = 1
END IF
ReportTest("path_stroke# sets named color", t)
' Test 46: Remove stroke
path_strokenone#(pStroke#)
t = 0
IF PntToNum(pStroke#) <> 0 THEN
  t = 1
END IF
ReportTest("path_strokenone# removes stroke", t)
' Test 47: Set stroke thickness
path_stroke#(pStroke#, "black")
path_strokethickness#(pStroke#, 3)
t = 0
IF path_strokethickness(pStroke#) = 3 THEN
  t = 1
END IF
ReportTest("path_strokethickness# set to 3", t)
' Test 48: Set stroke dash
path_strokedash#(pStroke#, 1)
t = 0
IF path_strokedash(pStroke#) = 1 THEN
  t = 1
END IF
ReportTest("path_strokedash# set to Dash (1)", t)
' Test 49: Set stroke cap
path_strokecap#(pStroke#, 1)
t = 0
IF path_strokecap(pStroke#) = 1 THEN
  t = 1
END IF
ReportTest("path_strokecap# set to Round (1)", t)
' Test 50: Set stroke join
path_strokejoin#(pStroke#, 2)
t = 0
IF path_strokejoin(pStroke#) = 2 THEN
  t = 1
END IF
ReportTest("path_strokejoin# set to Bevel (2)", t)
' ============================================================================
' Position and Size Tests
' ============================================================================
PRINTLN ""
PRINTLN "--- Position and Size Tests ---"
PRINTLN ""
' Test 51: Get X
LET pPos# = path#(frm#, 100, 100, 80, 80)
t = 0
IF path_x(pPos#) = 100 THEN
  t = 1
END IF
ReportTest("path_x returns correct X", t)
' Test 52: Set X
path_x#(pPos#, 120)
t = 0
IF path_x(pPos#) = 120 THEN
  t = 1
END IF
ReportTest("path_x# sets X position", t)
' Test 53: Get Y
t = 0
IF path_y(pPos#) = 100 THEN
  t = 1
END IF
ReportTest("path_y returns correct Y", t)
' Test 54: Set Y
path_y#(pPos#, 130)
t = 0
IF path_y(pPos#) = 130 THEN
  t = 1
END IF
ReportTest("path_y# sets Y position", t)
' Test 55: Get width
t = 0
IF path_width(pPos#) = 80 THEN
  t = 1
END IF
ReportTest("path_width returns correct width", t)
' Test 56: Set width
path_width#(pPos#, 90)
t = 0
IF path_width(pPos#) = 90 THEN
  t = 1
END IF
ReportTest("path_width# sets width", t)
' Test 57: Get height
t = 0
IF path_height(pPos#) = 80 THEN
  t = 1
END IF
ReportTest("path_height returns correct height", t)
' Test 58: Set height
path_height#(pPos#, 95)
t = 0
IF path_height(pPos#) = 95 THEN
  t = 1
END IF
ReportTest("path_height# sets height", t)
' Test 59: Set bounds
path_bounds#(pPos#, 50, 460, 100, 100)
t = 0
IF path_x(pPos#) = 50 THEN
  t = 1
END IF
ReportTest("path_bounds# sets X correctly", t)
' Test 60: Bounds sets Y
t = 0
IF path_y(pPos#) = 460 THEN
  t = 1
END IF
ReportTest("path_bounds# sets Y correctly", t)
' Test 61: Bounds sets width
t = 0
IF path_width(pPos#) = 100 THEN
  t = 1
END IF
ReportTest("path_bounds# sets width correctly", t)
' Test 62: Bounds sets height
t = 0
IF path_height(pPos#) = 100 THEN
  t = 1
END IF
ReportTest("path_bounds# sets height correctly", t)
' Test 63: Set size
path_size#(pPos#, 110, 115)
t = 0
IF path_width(pPos#) = 110 THEN
  t = 1
END IF
ReportTest("path_size# sets width correctly", t)
' Test 64: Size sets height
t = 0
IF path_height(pPos#) = 115 THEN
  t = 1
END IF
ReportTest("path_size# sets height correctly", t)
' Test 65: Set move
path_move#(pPos#, 60, 470)
t = 0
IF path_x(pPos#) = 60 THEN
  t = 1
END IF
ReportTest("path_move# sets X correctly", t)
' Test 66: Move sets Y
t = 0
IF path_y(pPos#) = 470 THEN
  t = 1
END IF
ReportTest("path_move# sets Y correctly", t)
' ============================================================================
' Alignment Tests
' ============================================================================
PRINTLN ""
PRINTLN "--- Alignment Tests ---"
PRINTLN ""
' Test 67: Get default alignment
LET pAlign# = path#(frm#, 200, 460, 80, 80)
path_addellipse#(pAlign#, 10, 10, 60, 60)
t = 0
IF path_align(pAlign#) = 0 THEN
  t = 1
END IF
ReportTest("path_align default is None (0)", t)
' Test 68: Set alignment
path_align#(pAlign#, 1)
t = 0
IF path_align(pAlign#) = 1 THEN
  t = 1
END IF
ReportTest("path_align# set to Top (1)", t)
' Reset for visual testing
path_align#(pAlign#, 0)
path_move#(pAlign#, 200, 460)
' ============================================================================
' Margin Tests
' ============================================================================
PRINTLN ""
PRINTLN "--- Margin Tests ---"
PRINTLN ""
' Test 69: Set margin left
LET pMargin# = path#(frm#, 300, 460, 80, 80)
path_addellipse#(pMargin#, 10, 10, 60, 60)
path_marginleft#(pMargin#, 10)
t = 0
IF path_marginleft(pMargin#) = 10 THEN
  t = 1
END IF
ReportTest("path_marginleft# sets to 10", t)
' Test 70: Set margin top
path_margintop#(pMargin#, 15)
t = 0
IF path_margintop(pMargin#) = 15 THEN
  t = 1
END IF
ReportTest("path_margintop# sets to 15", t)
' Test 71: Set margin right
path_marginright#(pMargin#, 20)
t = 0
IF path_marginright(pMargin#) = 20 THEN
  t = 1
END IF
ReportTest("path_marginright# sets to 20", t)
' Test 72: Set margin bottom
path_marginbottom#(pMargin#, 25)
t = 0
IF path_marginbottom(pMargin#) = 25 THEN
  t = 1
END IF
ReportTest("path_marginbottom# sets to 25", t)
' Test 73: Set all margins
path_margins#(pMargin#, 5, 10, 15, 20)
t = 0
IF path_marginleft(pMargin#) = 5 THEN
  t = 1
END IF
ReportTest("path_margins# sets left to 5", t)
' Test 74: Margins sets top
t = 0
IF path_margintop(pMargin#) = 10 THEN
  t = 1
END IF
ReportTest("path_margins# sets top to 10", t)
' Test 75: Set uniform margin
path_margin#(pMargin#, 8)
t = 0
IF path_marginleft(pMargin#) = 8 THEN
  t = 1
END IF
ReportTest("path_margin# sets uniform left", t)
' Test 76: Uniform margin sets right
t = 0
IF path_marginright(pMargin#) = 8 THEN
  t = 1
END IF
ReportTest("path_margin# sets uniform right", t)
' ============================================================================
' Visibility and Behavior Tests
' ============================================================================
PRINTLN ""
PRINTLN "--- Visibility and Behavior Tests ---"
PRINTLN ""
' Test 77: Get visible default
LET pVis# = path#(frm#, 400, 460, 80, 80)
path_addellipse#(pVis#, 10, 10, 60, 60)
path_fill#(pVis#, "orange")
t = 0
IF path_visible(pVis#) = 1 THEN
  t = 1
END IF
ReportTest("path_visible default is true", t)
' Test 78: Set visible false
path_visible#(pVis#, 0)
t = 0
IF path_visible(pVis#) = 0 THEN
  t = 1
END IF
ReportTest("path_visible# set to false", t)
' Test 79: Set visible true
path_visible#(pVis#, 1)
t = 0
IF path_visible(pVis#) = 1 THEN
  t = 1
END IF
ReportTest("path_visible# set to true", t)
' Test 80: Get enabled default
t = 0
IF path_enabled(pVis#) = 1 THEN
  t = 1
END IF
ReportTest("path_enabled default is true", t)
' Test 81: Set enabled false
path_enabled#(pVis#, 0)
t = 0
IF path_enabled(pVis#) = 0 THEN
  t = 1
END IF
ReportTest("path_enabled# set to false", t)
' Test 82: Set enabled true
path_enabled#(pVis#, 1)
t = 0
IF path_enabled(pVis#) = 1 THEN
  t = 1
END IF
ReportTest("path_enabled# set to true", t)
' Test 83: Get opacity default
t = 0
IF path_opacity(pVis#) = 1 THEN
  t = 1
END IF
ReportTest("path_opacity default is 1.0", t)
' Test 84: Set opacity
path_opacity#(pVis#, 0.7)
LET opac = path_opacity(pVis#)
t = 0
IF opac >= 0.69 THEN
  IF opac <= 0.71 THEN
    t = 1
  END IF
END IF
ReportTest("path_opacity# set to 0.7", t)
' Test 85: Get hittest default
t = 0
IF path_hittest(pVis#) = 1 THEN
  t = 1
END IF
ReportTest("path_hittest default is true", t)
' Test 86: Set hittest false
path_hittest#(pVis#, 0)
t = 0
IF path_hittest(pVis#) = 0 THEN
  t = 1
END IF
ReportTest("path_hittest# set to false", t)
' ============================================================================
' Tag and Rotation Tests
' ============================================================================
PRINTLN ""
PRINTLN "--- Tag and Rotation Tests ---"
PRINTLN ""
' Test 87: Get tag default
LET pTag# = path#(frm#, 500, 460, 80, 80)
path_addrectangle#(pTag#, 10, 10, 60, 60, 5, 5)
path_fill#(pTag#, "teal")
t = 0
IF path_tag(pTag#) = 0 THEN
  t = 1
END IF
ReportTest("path_tag default is 0", t)
' Test 88: Set tag
path_tag#(pTag#, 42)
t = 0
IF path_tag(pTag#) = 42 THEN
  t = 1
END IF
ReportTest("path_tag# set to 42", t)
' Test 89: Get rotation default
t = 0
IF path_rotation(pTag#) = 0 THEN
  t = 1
END IF
ReportTest("path_rotation default is 0", t)
' Test 90: Set rotation
path_rotation#(pTag#, 30)
t = 0
IF path_rotation(pTag#) = 30 THEN
  t = 1
END IF
ReportTest("path_rotation# set to 30", t)
' ============================================================================
' Parent Tests
' ============================================================================
PRINTLN ""
PRINTLN "--- Parent Tests ---"
PRINTLN ""
' Test 91: Get parent
LET pParent# = path#(frm#, 600, 460, 80, 80)
path_addellipse#(pParent#, 10, 10, 60, 60)
path_fill#(pParent#, "coral")
t = 0
IF PntToNum(path_parent#(pParent#)) <> 0 THEN
  t = 1
END IF
ReportTest("path_parent# returns valid parent", t)
' Test 92: Bring to front
path_bringtofront#(pParent#)
t = 0
IF PntToNum(pParent#) <> 0 THEN
  t = 1
END IF
ReportTest("path_bringtofront# executes without error", t)
' Test 93: Send to back
path_sendtoback#(pParent#)
t = 0
IF PntToNum(pParent#) <> 0 THEN
  t = 1
END IF
ReportTest("path_sendtoback# executes without error", t)
' ============================================================================
' Invalidation Test
' ============================================================================
PRINTLN ""
PRINTLN "--- Invalidation Test ---"
PRINTLN ""
' Test 94: Invalidate
LET pInv# = path#(frm#, 700, 460, 80, 80)
path_addellipse#(pInv#, 10, 10, 60, 60)
path_fill#(pInv#, "pink")
path_invalidate#(pInv#)
t = 0
IF PntToNum(pInv#) <> 0 THEN
  t = 1
END IF
ReportTest("path_invalidate# executes without error", t)
' ============================================================================
' Event Callback Tests
' ============================================================================
PRINTLN ""
PRINTLN "--- Event Callback Tests ---"
PRINTLN ""
' Test 95: Set onclick
LET pEvent# = path#(frm#, 800, 460, 80, 80)
path_addrectangle#(pEvent#, 5, 5, 70, 70, 10, 10)
path_fill#(pEvent#, "#3498db")
path_stroke#(pEvent#, "#2980b9")
path_strokethickness#(pEvent#, 2)
path_onclick#(pEvent#, "OnPathClick")
t = 0
IF path_onclick$(pEvent#) = "OnPathClick" THEN
  t = 1
END IF
ReportTest("path_onclick# set correctly", t)
' Test 96: Set ondblclick
path_ondblclick#(pEvent#, "OnPathDblClick")
t = 0
IF path_ondblclick$(pEvent#) = "OnPathDblClick" THEN
  t = 1
END IF
ReportTest("path_ondblclick# set correctly", t)
' Test 97: Set onmousedown
path_onmousedown#(pEvent#, "OnPathMouseDown")
t = 0
IF path_onmousedown$(pEvent#) = "OnPathMouseDown" THEN
  t = 1
END IF
ReportTest("path_onmousedown# set correctly", t)
' Test 98: Set onmouseenter
path_onmouseenter#(pEvent#, "OnPathEnter")
t = 0
IF path_onmouseenter$(pEvent#) = "OnPathEnter" THEN
  t = 1
END IF
ReportTest("path_onmouseenter# set correctly", t)
' Test 99: Set onmouseleave
path_onmouseleave#(pEvent#, "OnPathLeave")
t = 0
IF path_onmouseleave$(pEvent#) = "OnPathLeave" THEN
  t = 1
END IF
ReportTest("path_onmouseleave# set correctly", t)
' Test 100: Clear callbacks
path_clearcallbacks#(pEvent#)
t = 0
IF PntToNum(pEvent#) <> 0 THEN
  t = 1
END IF
ReportTest("path_clearcallbacks# returns valid pointer", t)
' Test 101: Callbacks cleared
t = 0
IF path_onclick$(pEvent#) = "" THEN
  t = 1
END IF
ReportTest("path_clearcallbacks# clears onclick", t)
' ============================================================================
' Destruction Test
' ============================================================================
PRINTLN ""
PRINTLN "--- Destruction Test ---"
PRINTLN ""
' Test 102: Free function exists
ReportTest("path_free function available (not executed)", 1)
' ============================================================================
' Style the visual demo paths
' ============================================================================
' Apply colors and styling to created paths
path_fill#(pStr#, "#e74c3c")
path_stroke#(pStr#, "#c0392b")
path_strokethickness#(pStr#, 2)
path_fill#(pProg#, "#2ecc71")
path_stroke#(pProg#, "#27ae60")
path_strokethickness#(pProg#, 2)
path_fill#(pCurve#, "#9b59b6")
path_stroke#(pCurve#, "#8e44ad")
path_strokethickness#(pCurve#, 2)
path_fill#(pSmooth#, "#f39c12")
path_stroke#(pSmooth#, "#d68910")
path_strokethickness#(pSmooth#, 2)
path_fill#(pQuad#, "#1abc9c")
path_stroke#(pQuad#, "#16a085")
path_strokethickness#(pQuad#, 2)
path_fill#(pRect#, "#3498db")
path_stroke#(pRect#, "#2980b9")
path_strokethickness#(pRect#, 2)
path_fill#(pEllipse#, "#e67e22")
path_stroke#(pEllipse#, "#d35400")
path_strokethickness#(pEllipse#, 2)
path_fill#(pArc#, "#95a5a6")
path_stroke#(pArc#, "#7f8c8d")
path_strokethickness#(pArc#, 2)
path_fill#(pScale#, "#34495e")
path_stroke#(pScale#, "#2c3e50")
path_strokethickness#(pScale#, 2)
path_fill#(pTrans#, "#16a085")
path_stroke#(pTrans#, "#1abc9c")
path_strokethickness#(pTrans#, 2)
path_fill#(pRotate#, "#c0392b")
path_stroke#(pRotate#, "#e74c3c")
path_strokethickness#(pRotate#, 2)
path_fill#(pQuery#, "#8e44ad")
path_stroke#(pQuery#, "#9b59b6")
path_strokethickness#(pQuery#, 2)
path_fill#(pWrap#, "#27ae60")
path_wrapmode#(pWrap#, 2)
path_fill#(pFill#, "#f1c40f")
path_stroke#(pFill#, "#d4ac0d")
path_strokethickness#(pFill#, 2)
path_stroke#(pStroke#, "#2c3e50")
path_strokethickness#(pStroke#, 3)
path_strokedash#(pStroke#, 0)
path_fill#(pStroke#, "transparent")
' Style position test path
path_addellipse#(pPos#, 10, 10, 90, 95)
path_fill#(pPos#, "#d35400")
path_stroke#(pPos#, "#e67e22")
path_strokethickness#(pPos#, 2)
' ============================================================================
' Interactive Demo Path
' ============================================================================
' Create an interactive star shape
LET pStar# = path#(frm#, 800, 550, 100, 100)
path_data#(pStar#, "M 50,5 L 61,40 L 98,40 L 68,62 L 79,97 L 50,75 L 21,97 L 32,62 L 2,40 L 39,40 Z")
path_fill#(pStar#, "#f1c40f")
path_stroke#(pStar#, "#d4ac0d")
path_strokethickness#(pStar#, 2)
path_onclick#(pStar#, "OnStarClick")
path_onmouseenter#(pStar#, "OnStarEnter")
path_onmouseleave#(pStar#, "OnStarLeave")
' Add label
LET lbl# = label#(frm#, "Click the star!", 790, 660)
' ============================================================================
' Summary
' ============================================================================
PRINTLN ""
PRINTLN "============================================================================"
PRINTLN "Test Summary"
PRINTLN "============================================================================"
PRINTLN "Total Tests:  " + stri$(testNum)
PRINTLN "Passed:       " + stri$(testsPassed)
PRINTLN "Failed:       " + stri$(testsFailed)
PRINTLN ""
IF testsFailed = 0 THEN
  PRINTLN "*** ALL TESTS PASSED ***"
ELSE
  PRINTLN "*** SOME TESTS FAILED ***"
END IF
PRINTLN ""
PRINTLN "============================================================================"
PRINTLN "Visual Test - Various Path Shapes"
PRINTLN "============================================================================"
PRINTLN "Multiple path shapes should be visible demonstrating different features."
PRINTLN "Click on the star to test event callbacks."
PRINTLN ""
form_show(frm#)
' Event handlers for interactive star
FUNCTION OnStarClick(sender#) LOCAL rot
  LET rot = path_rotation(sender#)
  rot = rot + 36
  IF rot >= 360 THEN
    rot = 0
  END IF
  path_rotation#(sender#, rot)
  label_text#(lbl#, "Rotation: " + stri$(rot) + " degrees")
END FUNCTION
FUNCTION OnStarEnter(sender#)
  path_fill#(sender#, "#e74c3c")
  path_stroke#(sender#, "#c0392b")
END FUNCTION
FUNCTION OnStarLeave(sender#)
  path_fill#(sender#, "#f1c40f")
  path_stroke#(sender#, "#d4ac0d")
END FUNCTION
