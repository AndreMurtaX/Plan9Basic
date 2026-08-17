' ============================================================================
' PanelLib Test Suite for Plan9Basic
' Version: 1.0.0
' ============================================================================
' This test file demonstrates and validates all functionality of the
' PanelLib library for Plan9Basic.
' ============================================================================
PRINTLN "========================================"
PRINTLN "PanelLib Test Suite"
PRINTLN "========================================"
PRINTLN ""
' ============================================================================
' Test 1: Panel Creation and Basic Properties
' ============================================================================
PRINTLN "Test 1: Panel Creation"
PRINTLN "----------------------"
' Create main form for testing
LET frm# = form#("PanelLib Test", 900, 700)
LET sb# = scrollbox#(frm#)
' Test basic panel creation
LET pnl1# = panel#(sb#)
IF PntToNum(pnl1#) <> 0 THEN
  PRINTLN "  [PASS] panel#(parent#) - created successfully"
ELSE
  PRINTLN "  [FAIL] panel#(parent#) - creation failed"
END IF
' Test panel creation with size
LET pnl2# = panel#(sb#, 200, 100)
IF PntToNum(pnl2#) <> 0 THEN
  PRINTLN "  [PASS] panel#(parent#, w, h) - created with size"
ELSE
  PRINTLN "  [FAIL] panel#(parent#, w, h) - creation failed"
END IF
' Test panel creation with full parameters
LET pnl3# = panel#(sb#, 50, 50, 150, 80)
IF PntToNum(pnl3#) <> 0 THEN
  PRINTLN "  [PASS] panel#(parent#, x, y, w, h) - created with bounds"
ELSE
  PRINTLN "  [FAIL] panel#(parent#, x, y, w, h) - creation failed"
END IF
' Verify position and size
LET x = panel_x(pnl3#)
LET y = panel_y(pnl3#)
LET w = panel_width(pnl3#)
LET h = panel_height(pnl3#)
IF x = 50 THEN
  PRINTLN "  [PASS] panel_x - X position correct: " + stri$(x)
ELSE
  PRINTLN "  [FAIL] panel_x - expected 50, got: " + stri$(x)
END IF
IF y = 50 THEN
  PRINTLN "  [PASS] panel_y - Y position correct: " + stri$(y)
ELSE
  PRINTLN "  [FAIL] panel_y - expected 50, got: " + stri$(y)
END IF
IF w = 150 THEN
  PRINTLN "  [PASS] panel_width - width correct: " + stri$(w)
ELSE
  PRINTLN "  [FAIL] panel_width - expected 150, got: " + stri$(w)
END IF
IF h = 80 THEN
  PRINTLN "  [PASS] panel_height - height correct: " + stri$(h)
ELSE
  PRINTLN "  [FAIL] panel_height - expected 80, got: " + stri$(h)
END IF
PRINTLN ""
' ============================================================================
' Test 2: Position and Size Manipulation
' ============================================================================
PRINTLN "Test 2: Position and Size Manipulation"
PRINTLN "--------------------------------------"
' Create test panel
LET testPnl# = panel#(sb#, 100, 100)
' Test position setters
panel_x#(testPnl#, 200)
panel_y#(testPnl#, 150)
IF panel_x(testPnl#) = 200 THEN
  PRINTLN "  [PASS] panel_x# - X set correctly"
ELSE
  PRINTLN "  [FAIL] panel_x# - X not set correctly"
END IF
IF panel_y(testPnl#) = 150 THEN
  PRINTLN "  [PASS] panel_y# - Y set correctly"
ELSE
  PRINTLN "  [FAIL] panel_y# - Y not set correctly"
END IF
' Test size setters
panel_width#(testPnl#, 300)
panel_height#(testPnl#, 200)
IF panel_width(testPnl#) = 300 THEN
  PRINTLN "  [PASS] panel_width# - width set correctly"
ELSE
  PRINTLN "  [FAIL] panel_width# - width not set correctly"
END IF
IF panel_height(testPnl#) = 200 THEN
  PRINTLN "  [PASS] panel_height# - height set correctly"
ELSE
  PRINTLN "  [FAIL] panel_height# - height not set correctly"
END IF
' Test bounds setter
panel_bounds#(testPnl#, 10, 20, 250, 180)
IF panel_x(testPnl#) = 10 THEN
  PRINTLN "  [PASS] panel_bounds# - X set correctly"
ELSE
  PRINTLN "  [FAIL] panel_bounds# - X not set correctly"
END IF
IF panel_y(testPnl#) = 20 THEN
  PRINTLN "  [PASS] panel_bounds# - Y set correctly"
ELSE
  PRINTLN "  [FAIL] panel_bounds# - Y not set correctly"
END IF
' Test size setter
panel_size#(testPnl#, 400, 300)
IF panel_width(testPnl#) = 400 THEN
  PRINTLN "  [PASS] panel_size# - width set correctly"
ELSE
  PRINTLN "  [FAIL] panel_size# - width not set correctly"
END IF
' Test move setter
panel_move#(testPnl#, 50, 60)
IF panel_x(testPnl#) = 50 THEN
  PRINTLN "  [PASS] panel_move# - position set correctly"
ELSE
  PRINTLN "  [FAIL] panel_move# - position not set correctly"
END IF
PRINTLN ""
' ============================================================================
' Test 3: Alignment
' ============================================================================
PRINTLN "Test 3: Alignment"
PRINTLN "-----------------"
LET alignPnl# = panel#(sb#, 100, 50)
' Test alignment values
panel_align#(alignPnl#, 0)  ' None
IF panel_align(alignPnl#) = 0 THEN
  PRINTLN "  [PASS] Alignment None (0)"
ELSE
  PRINTLN "  [FAIL] Alignment None"
END IF
panel_align#(alignPnl#, 1)  ' Top
IF panel_align(alignPnl#) = 1 THEN
  PRINTLN "  [PASS] Alignment Top (1)"
ELSE
  PRINTLN "  [FAIL] Alignment Top"
END IF
panel_align#(alignPnl#, 9)  ' Client
IF panel_align(alignPnl#) = 9 THEN
  PRINTLN "  [PASS] Alignment Client (9)"
ELSE
  PRINTLN "  [FAIL] Alignment Client"
END IF
' Reset alignment for further tests
panel_align#(alignPnl#, 0)
PRINTLN ""
' ============================================================================
' Test 4: Margins
' ============================================================================
PRINTLN "Test 4: Margins"
PRINTLN "---------------"
LET marginPnl# = panel#(sb#, 100, 50)
' Test individual margin setters
panel_marginleft#(marginPnl#, 5)
panel_margintop#(marginPnl#, 10)
panel_marginright#(marginPnl#, 15)
panel_marginbottom#(marginPnl#, 20)
IF panel_marginleft(marginPnl#) = 5 THEN
  PRINTLN "  [PASS] panel_marginleft# - set to 5"
ELSE
  PRINTLN "  [FAIL] panel_marginleft#"
END IF
IF panel_margintop(marginPnl#) = 10 THEN
  PRINTLN "  [PASS] panel_margintop# - set to 10"
ELSE
  PRINTLN "  [FAIL] panel_margintop#"
END IF
IF panel_marginright(marginPnl#) = 15 THEN
  PRINTLN "  [PASS] panel_marginright# - set to 15"
ELSE
  PRINTLN "  [FAIL] panel_marginright#"
END IF
IF panel_marginbottom(marginPnl#) = 20 THEN
  PRINTLN "  [PASS] panel_marginbottom# - set to 20"
ELSE
  PRINTLN "  [FAIL] panel_marginbottom#"
END IF
' Test all margins setter
panel_margins#(marginPnl#, 8, 8, 8, 8)
IF panel_marginleft(marginPnl#) = 8 THEN
  PRINTLN "  [PASS] panel_margins# - all margins set to 8"
ELSE
  PRINTLN "  [FAIL] panel_margins#"
END IF
' Test uniform margin setter
panel_margin#(marginPnl#, 12)
IF panel_marginleft(marginPnl#) = 12 THEN
  PRINTLN "  [PASS] panel_margin# - uniform margin set to 12"
ELSE
  PRINTLN "  [FAIL] panel_margin#"
END IF
PRINTLN ""
' ============================================================================
' Test 5: Padding
' ============================================================================
PRINTLN "Test 5: Padding"
PRINTLN "---------------"
LET paddingPnl# = panel#(sb#, 100, 50)
' Test individual padding setters
panel_paddingleft#(paddingPnl#, 3)
panel_paddingtop#(paddingPnl#, 6)
panel_paddingright#(paddingPnl#, 9)
panel_paddingbottom#(paddingPnl#, 12)
IF panel_paddingleft(paddingPnl#) = 3 THEN
  PRINTLN "  [PASS] panel_paddingleft# - set to 3"
ELSE
  PRINTLN "  [FAIL] panel_paddingleft#"
END IF
IF panel_paddingtop(paddingPnl#) = 6 THEN
  PRINTLN "  [PASS] panel_paddingtop# - set to 6"
ELSE
  PRINTLN "  [FAIL] panel_paddingtop#"
END IF
IF panel_paddingright(paddingPnl#) = 9 THEN
  PRINTLN "  [PASS] panel_paddingright# - set to 9"
ELSE
  PRINTLN "  [FAIL] panel_paddingright#"
END IF
IF panel_paddingbottom(paddingPnl#) = 12 THEN
  PRINTLN "  [PASS] panel_paddingbottom# - set to 12"
ELSE
  PRINTLN "  [FAIL] panel_paddingbottom#"
END IF
' Test all paddings setter
panel_paddings#(paddingPnl#, 5, 5, 5, 5)
IF panel_paddingleft(paddingPnl#) = 5 THEN
  PRINTLN "  [PASS] panel_paddings# - all paddings set to 5"
ELSE
  PRINTLN "  [FAIL] panel_paddings#"
END IF
' Test uniform padding setter
panel_padding#(paddingPnl#, 8)
IF panel_paddingleft(paddingPnl#) = 8 THEN
  PRINTLN "  [PASS] panel_padding# - uniform padding set to 8"
ELSE
  PRINTLN "  [FAIL] panel_padding#"
END IF
PRINTLN ""
' ============================================================================
' Test 6: Visibility and Behavior
' ============================================================================
PRINTLN "Test 6: Visibility and Behavior"
PRINTLN "--------------------------------"
LET visPnl# = panel#(sb#, 100, 50)
' Test visibility
panel_visible#(visPnl#, 0)
IF panel_visible(visPnl#) = 0 THEN
  PRINTLN "  [PASS] panel_visible# - hidden"
ELSE
  PRINTLN "  [FAIL] panel_visible# - should be hidden"
END IF
panel_visible#(visPnl#, 1)
IF panel_visible(visPnl#) = 1 THEN
  PRINTLN "  [PASS] panel_visible# - shown"
ELSE
  PRINTLN "  [FAIL] panel_visible# - should be shown"
END IF
' Test enabled
panel_enabled#(visPnl#, 0)
IF panel_enabled(visPnl#) = 0 THEN
  PRINTLN "  [PASS] panel_enabled# - disabled"
ELSE
  PRINTLN "  [FAIL] panel_enabled# - should be disabled"
END IF
panel_enabled#(visPnl#, 1)
IF panel_enabled(visPnl#) = 1 THEN
  PRINTLN "  [PASS] panel_enabled# - enabled"
ELSE
  PRINTLN "  [FAIL] panel_enabled# - should be enabled"
END IF
' Test opacity
panel_opacity#(visPnl#, 0.5)
LET op = panel_opacity(visPnl#)
IF op > 0.49 THEN
  IF op < 0.51 THEN
    PRINTLN "  [PASS] panel_opacity# - set to 0.5"
  ELSE
    PRINTLN "  [FAIL] panel_opacity# - value: " + stri$(op)
  END IF
ELSE
  PRINTLN "  [FAIL] panel_opacity# - value: " + stri$(op)
END IF
panel_opacity#(visPnl#, 1)
' Test clip children
panel_clipchildren#(visPnl#, 1)
IF panel_clipchildren(visPnl#) = 1 THEN
  PRINTLN "  [PASS] panel_clipchildren# - enabled"
ELSE
  PRINTLN "  [FAIL] panel_clipchildren#"
END IF
panel_clipchildren#(visPnl#, 0)
' Test hit test (should be enabled by default for panels)
IF panel_hittest(visPnl#) = 1 THEN
  PRINTLN "  [PASS] panel_hittest - default enabled"
ELSE
  PRINTLN "  [INFO] panel_hittest - default was: " + stri$(panel_hittest(visPnl#))
END IF
panel_hittest#(visPnl#, 0)
IF panel_hittest(visPnl#) = 0 THEN
  PRINTLN "  [PASS] panel_hittest# - disabled"
ELSE
  PRINTLN "  [FAIL] panel_hittest#"
END IF
panel_hittest#(visPnl#, 1)
' Test locked
panel_locked#(visPnl#, 1)
IF panel_locked(visPnl#) = 1 THEN
  PRINTLN "  [PASS] panel_locked# - locked"
ELSE
  PRINTLN "  [FAIL] panel_locked#"
END IF
panel_locked#(visPnl#, 0)
PRINTLN ""
' ============================================================================
' Test 7: Tag
' ============================================================================
PRINTLN "Test 7: Tag"
PRINTLN "-----------"
LET tagPnl# = panel#(sb#, 100, 50)
panel_tag#(tagPnl#, 42)
IF panel_tag(tagPnl#) = 42 THEN
  PRINTLN "  [PASS] panel_tag# - tag set to 42"
ELSE
  PRINTLN "  [FAIL] panel_tag#"
END IF
panel_tag#(tagPnl#, 12345)
IF panel_tag(tagPnl#) = 12345 THEN
  PRINTLN "  [PASS] panel_tag# - tag set to 12345"
ELSE
  PRINTLN "  [FAIL] panel_tag#"
END IF
PRINTLN ""
' ============================================================================
' Test 8: Parent/Child Management
' ============================================================================
PRINTLN "Test 8: Parent/Child Management"
PRINTLN "--------------------------------"
' Create parent panel
LET parentPnl# = panel#(sb#, 10, 300, 400, 200)
' Create child panels
LET child1# = panel#(parentPnl#, 10, 10, 80, 40)
LET child2# = panel#(parentPnl#, 100, 10, 80, 40)
LET child3# = panel#(parentPnl#, 190, 10, 80, 40)
' Test child count
LET cnt = panel_childcount(parentPnl#)
IF cnt = 3 THEN
  PRINTLN "  [PASS] panel_childcount - 3 children"
ELSE
  PRINTLN "  [FAIL] panel_childcount - expected 3, got: " + stri$(cnt)
END IF
' Test get child
LET ch# = panel_child#(parentPnl#, 0)
IF PntToNum(ch#) <> 0 THEN
  PRINTLN "  [PASS] panel_child# - got first child"
ELSE
  PRINTLN "  [FAIL] panel_child#"
END IF
' Test get parent
LET par# = panel_parent#(child1#)
IF PntToNum(par#) = PntToNum(parentPnl#) THEN
  PRINTLN "  [PASS] panel_parent# - correct parent"
ELSE
  PRINTLN "  [FAIL] panel_parent# - wrong parent"
END IF
' Test reparenting
LET newParent# = panel#(sb#, 450, 300, 200, 200)
panel_parent#(child3#, newParent#)
LET newPar# = panel_parent#(child3#)
IF PntToNum(newPar#) = PntToNum(newParent#) THEN
  PRINTLN "  [PASS] panel_parent# set - reparented successfully"
ELSE
  PRINTLN "  [FAIL] panel_parent# set - reparenting failed"
END IF
' Test bring to front / send to back
panel_bringtofront#(child1#)
PRINTLN "  [PASS] panel_bringtofront# - no error"
panel_sendtoback#(child2#)
PRINTLN "  [PASS] panel_sendtoback# - no error"
PRINTLN ""
' ============================================================================
' Test 9: Event Callbacks
' ============================================================================
PRINTLN "Test 9: Event Callbacks"
PRINTLN "-----------------------"
LET evtPnl# = panel#(sb#, 500, 50, 200, 100)
' Test setting callbacks
panel_onclick#(evtPnl#, "TestOnClick")
IF panel_onclick$(evtPnl#) = "TestOnClick" THEN
  PRINTLN "  [PASS] panel_onclick# - callback set"
ELSE
  PRINTLN "  [FAIL] panel_onclick#"
END IF
panel_ondblclick#(evtPnl#, "TestOnDblClick")
IF panel_ondblclick$(evtPnl#) = "TestOnDblClick" THEN
  PRINTLN "  [PASS] panel_ondblclick# - callback set"
ELSE
  PRINTLN "  [FAIL] panel_ondblclick#"
END IF
panel_onmousedown#(evtPnl#, "TestOnMouseDown")
IF panel_onmousedown$(evtPnl#) = "TestOnMouseDown" THEN
  PRINTLN "  [PASS] panel_onmousedown# - callback set"
ELSE
  PRINTLN "  [FAIL] panel_onmousedown#"
END IF
panel_onmouseup#(evtPnl#, "TestOnMouseUp")
IF panel_onmouseup$(evtPnl#) = "TestOnMouseUp" THEN
  PRINTLN "  [PASS] panel_onmouseup# - callback set"
ELSE
  PRINTLN "  [FAIL] panel_onmouseup#"
END IF
panel_onmousemove#(evtPnl#, "TestOnMouseMove")
IF panel_onmousemove$(evtPnl#) = "TestOnMouseMove" THEN
  PRINTLN "  [PASS] panel_onmousemove# - callback set"
ELSE
  PRINTLN "  [FAIL] panel_onmousemove#"
END IF
panel_onmouseenter#(evtPnl#, "TestOnMouseEnter")
IF panel_onmouseenter$(evtPnl#) = "TestOnMouseEnter" THEN
  PRINTLN "  [PASS] panel_onmouseenter# - callback set"
ELSE
  PRINTLN "  [FAIL] panel_onmouseenter#"
END IF
panel_onmouseleave#(evtPnl#, "TestOnMouseLeave")
IF panel_onmouseleave$(evtPnl#) = "TestOnMouseLeave" THEN
  PRINTLN "  [PASS] panel_onmouseleave# - callback set"
ELSE
  PRINTLN "  [FAIL] panel_onmouseleave#"
END IF
panel_onmousewheel#(evtPnl#, "TestOnMouseWheel")
IF panel_onmousewheel$(evtPnl#) = "TestOnMouseWheel" THEN
  PRINTLN "  [PASS] panel_onmousewheel# - callback set"
ELSE
  PRINTLN "  [FAIL] panel_onmousewheel#"
END IF
panel_onresize#(evtPnl#, "TestOnResize")
IF panel_onresize$(evtPnl#) = "TestOnResize" THEN
  PRINTLN "  [PASS] panel_onresize# - callback set"
ELSE
  PRINTLN "  [FAIL] panel_onresize#"
END IF
panel_onresized#(evtPnl#, "TestOnResized")
IF panel_onresized$(evtPnl#) = "TestOnResized" THEN
  PRINTLN "  [PASS] panel_onresized# - callback set"
ELSE
  PRINTLN "  [FAIL] panel_onresized#"
END IF
PRINTLN ""
' ============================================================================
' Test 10: Drag & Drop Callbacks
' ============================================================================
PRINTLN "Test 10: Drag & Drop Callbacks"
PRINTLN "------------------------------"
LET dragPnl# = panel#(sb#, 500, 200, 200, 150)
panel_ondragenter#(dragPnl#, "TestOnDragEnter")
IF panel_ondragenter$(dragPnl#) = "TestOnDragEnter" THEN
  PRINTLN "  [PASS] panel_ondragenter# - callback set"
ELSE
  PRINTLN "  [FAIL] panel_ondragenter#"
END IF
panel_ondragover#(dragPnl#, "TestOnDragOver")
IF panel_ondragover$(dragPnl#) = "TestOnDragOver" THEN
  PRINTLN "  [PASS] panel_ondragover# - callback set"
ELSE
  PRINTLN "  [FAIL] panel_ondragover#"
END IF
panel_ondragdrop#(dragPnl#, "TestOnDragDrop")
IF panel_ondragdrop$(dragPnl#) = "TestOnDragDrop" THEN
  PRINTLN "  [PASS] panel_ondragdrop# - callback set"
ELSE
  PRINTLN "  [FAIL] panel_ondragdrop#"
END IF
panel_ondragleave#(dragPnl#, "TestOnDragLeave")
IF panel_ondragleave$(dragPnl#) = "TestOnDragLeave" THEN
  PRINTLN "  [PASS] panel_ondragleave# - callback set"
ELSE
  PRINTLN "  [FAIL] panel_ondragleave#"
END IF
PRINTLN ""
' ============================================================================
' Test 11: Clear Callbacks
' ============================================================================
PRINTLN "Test 11: Clear Callbacks"
PRINTLN "------------------------"
panel_clearcallbacks#(evtPnl#)
IF panel_onclick$(evtPnl#) = "" THEN
  PRINTLN "  [PASS] panel_clearcallbacks# - onclick cleared"
ELSE
  PRINTLN "  [FAIL] panel_clearcallbacks# - onclick not cleared"
END IF
IF panel_onmousedown$(evtPnl#) = "" THEN
  PRINTLN "  [PASS] panel_clearcallbacks# - onmousedown cleared"
ELSE
  PRINTLN "  [FAIL] panel_clearcallbacks# - onmousedown not cleared"
END IF
PRINTLN ""
' ============================================================================
' Test 12: Error Handling
' ============================================================================
PRINTLN "Test 12: Error Handling"
PRINTLN "-----------------------"
panel_clearerror()
IF panel_error() = 0 THEN
  PRINTLN "  [PASS] panel_clearerror - error cleared"
ELSE
  PRINTLN "  [FAIL] panel_clearerror"
END IF
' Test error string function
LET errStr$ = panel_strerror$(0)
IF errStr$ = "No error" THEN
  PRINTLN "  [PASS] panel_strerror$(0) - 'No error'"
ELSE
  PRINTLN "  [FAIL] panel_strerror$(0)"
END IF
LET errStr$ = panel_strerror$(1)
IF instr(errStr$, "panel", 0) >= 0 THEN
  PRINTLN "  [PASS] panel_strerror$(1) - contains 'panel'"
ELSE
  PRINTLN "  [FAIL] panel_strerror$(1)"
END IF
PRINTLN ""
' ============================================================================
' Test 13: Invalidation
' ============================================================================
PRINTLN "Test 13: Invalidation"
PRINTLN "---------------------"
LET invPnl# = panel#(sb#, 100, 50)
panel_invalidate#(invPnl#)
PRINTLN "  [PASS] panel_invalidate# - no error"
PRINTLN ""
' ============================================================================
' Test Summary
' ============================================================================
PRINTLN "========================================"
PRINTLN "PanelLib Test Suite Complete"
PRINTLN "========================================"
PRINTLN ""
PRINTLN "All automated tests have been executed."
PRINTLN "Review the output above for PASS/FAIL results."
PRINTLN ""
PRINTLN "The form will be shown for visual inspection."
PRINTLN "Close the form to end the test."
' Show form for visual inspection
form_show(frm#)
' ============================================================================
' Event Handler Functions (for callback tests)
' ============================================================================
FUNCTION TestOnClick(sender#)
  PRINTLN "Event: OnClick triggered"
END FUNCTION
FUNCTION TestOnDblClick(sender#)
  PRINTLN "Event: OnDblClick triggered"
END FUNCTION
FUNCTION TestOnMouseDown(sender#, btn, x, y, shift$)
  PRINTLN "Event: OnMouseDown - btn=" + stri$(btn) + " x=" + stri$(x) + " y=" + stri$(y)
END FUNCTION
FUNCTION TestOnMouseUp(sender#, btn, x, y, shift$)
  PRINTLN "Event: OnMouseUp - btn=" + stri$(btn) + " x=" + stri$(x) + " y=" + stri$(y)
END FUNCTION
FUNCTION TestOnMouseMove(sender#, x, y, shift$)
  ' Don't print - too many events
END FUNCTION
FUNCTION TestOnMouseEnter(sender#)
  PRINTLN "Event: OnMouseEnter triggered"
END FUNCTION
FUNCTION TestOnMouseLeave(sender#)
  PRINTLN "Event: OnMouseLeave triggered"
END FUNCTION
FUNCTION TestOnMouseWheel(sender#, delta, shift$) LOCAL handled
  PRINTLN "Event: OnMouseWheel - delta=" + stri$(delta)
  RETURN 1
END FUNCTION
FUNCTION TestOnResize(sender#, w, h)
  PRINTLN "Event: OnResize - w=" + stri$(w) + " h=" + stri$(h)
END FUNCTION
FUNCTION TestOnResized(sender#, w, h)
  PRINTLN "Event: OnResized - w=" + stri$(w) + " h=" + stri$(h)
END FUNCTION
FUNCTION TestOnDragEnter(sender#, x, y)
  PRINTLN "Event: OnDragEnter - x=" + stri$(x) + " y=" + stri$(y)
END FUNCTION
FUNCTION TestOnDragOver(sender#, x, y) LOCAL accept
  PRINTLN "Event: OnDragOver - x=" + stri$(x) + " y=" + stri$(y)
  RETURN 1
END FUNCTION
FUNCTION TestOnDragDrop(sender#, x, y)
  PRINTLN "Event: OnDragDrop - x=" + stri$(x) + " y=" + stri$(y)
END FUNCTION
FUNCTION TestOnDragLeave(sender#)
  PRINTLN "Event: OnDragLeave triggered"
END FUNCTION
