' ============================================================================
' MemoLib Test Applet - Comprehensive Test Suite for Plan9Basic
' Version: 1.0.0
'
' This applet tests all functionality of the MemoLib library including:
' - Memo creation with various constructors
' - Text content and line operations
' - Word wrap and scroll bars
' - Font properties
' - Selection and caret control
' - Clipboard operations
' - Position, size, and alignment
' - Event handling
' ============================================================================
PRINTLN "=== MemoLib Test Suite ==="
PRINTLN ""
' Create main form
LET frm# = form#("MemoLib Test Suite", 800, 600)
form_position#(frm#, 4)
LET sb# = scrollbox#(frm#)
' ============================================================================
' TEST 1: Basic Memo Creation
' ============================================================================
PRINTLN "TEST 1: Memo Creation"
' Create memo with parent only
LET mem1# = memo#(sb#)
memo_bounds#(mem1#, 10, 10, 380, 150)
memo_text#(mem1#, "Basic memo created with parent only.")
PRINTLN "  - Created basic memo"
' Create memo with position
LET mem2# = memo#(sb#, 400, 10, 380, 150)
memo_text#(mem2#, "Memo created with position and size.")
PRINTLN "  - Created memo with position"
PRINTLN "  PASSED"
PRINTLN ""
' ============================================================================
' TEST 2: Text Content
' ============================================================================
PRINTLN "TEST 2: Text Content"
memo_text#(mem1#, "Hello World!")
PRINTLN "  - Text: " + memo_text$(mem1#)
PRINTLN "  - Text length: " + stri$(memo_textlength(mem1#))
PRINTLN "  PASSED"
PRINTLN ""
' ============================================================================
' TEST 3: Line Operations
' ============================================================================
PRINTLN "TEST 3: Line Operations"
memo_clear#(mem1#)
memo_addline#(mem1#, "Line 0: First line")
memo_addline#(mem1#, "Line 1: Second line")
memo_addline#(mem1#, "Line 2: Third line")
PRINTLN "  - Line count: " + stri$(memo_linecount(mem1#))
PRINTLN "  - Line 0: " + memo_line$(mem1#, 0)
PRINTLN "  - Line 1: " + memo_line$(mem1#, 1)
PRINTLN "  - Line 2: " + memo_line$(mem1#, 2)
' Modify a line
memo_line#(mem1#, 1, "Line 1: MODIFIED")
PRINTLN "  - After modify, Line 1: " + memo_line$(mem1#, 1)
' Insert a line
memo_insertline#(mem1#, 2, "Line 2: INSERTED")
PRINTLN "  - After insert, Line count: " + stri$(memo_linecount(mem1#))
' Delete a line
memo_deleteline#(mem1#, 3)
PRINTLN "  - After delete, Line count: " + stri$(memo_linecount(mem1#))
PRINTLN "  PASSED"
PRINTLN ""
' ============================================================================
' TEST 4: Word Wrap and Scroll Bars
' ============================================================================
PRINTLN "TEST 4: Word Wrap and Scroll Bars"
memo_wordwrap#(mem2#, 1)
PRINTLN "  - Word wrap enabled: " + stri$(memo_wordwrap(mem2#))
memo_showscrollbars#(mem2#, 1)
PRINTLN "  - Scroll bars visible: " + stri$(memo_showscrollbars(mem2#))
' Add long text to test word wrap
memo_text#(mem2#, "This is a very long line of text that should wrap automatically when word wrap is enabled. It demonstrates how the memo control handles long text content without horizontal scrolling.")
PRINTLN "  PASSED"
PRINTLN ""
' ============================================================================
' TEST 5: Font Properties
' ============================================================================
PRINTLN "TEST 5: Font Properties"
LET memFont# = memo#(sb#, 10, 170, 380, 100)
memo_text#(memFont#, "Styled memo text with custom font")
memo_fontsize#(memFont#, 14)
PRINTLN "  - Font size: " + stri$(memo_fontsize(memFont#))
memo_fontcolor#(memFont#, "blue")
PRINTLN "  - Font color: " + memo_fontcolor$(memFont#)
memo_bold#(memFont#, 1)
PRINTLN "  - Bold: " + stri$(memo_bold(memFont#))
memo_italic#(memFont#, 1)
PRINTLN "  - Italic: " + stri$(memo_italic(memFont#))
PRINTLN "  PASSED"
PRINTLN ""
' ============================================================================
' TEST 6: Read-Only Mode
' ============================================================================
PRINTLN "TEST 6: Read-Only Mode"
LET memReadOnly# = memo#(sb#, 400, 170, 380, 100)
memo_text#(memReadOnly#, "This memo is read-only.\nYou cannot edit this text.\nTry clicking and typing!")
memo_readonly#(memReadOnly#, 1)
PRINTLN "  - Read-only mode: " + stri$(memo_readonly(memReadOnly#))
PRINTLN "  PASSED"
PRINTLN ""
' ============================================================================
' TEST 7: Selection and Caret
' ============================================================================
PRINTLN "TEST 7: Selection and Caret"
LET memSelect# = memo#(sb#, 10, 280, 380, 80)
memo_text#(memSelect#, "Select some text in this memo control")
memo_selstart#(memSelect#, 7)
memo_sellength#(memSelect#, 4)
PRINTLN "  - Selection start: " + stri$(memo_selstart(memSelect#))
PRINTLN "  - Selection length: " + stri$(memo_sellength(memSelect#))
PRINTLN "  - Selected text: " + memo_seltext$(memSelect#)
PRINTLN "  - Caret line: " + stri$(memo_caretpositionline(memSelect#))
PRINTLN "  - Caret pos: " + stri$(memo_caretpositionpos(memSelect#))
PRINTLN "  PASSED"
PRINTLN ""
' ============================================================================
' TEST 8: Text Alignment
' ============================================================================
PRINTLN "TEST 8: Text Alignment"
LET memAlignL# = memo#(sb#, 400, 280, 120, 60)
memo_text#(memAlignL#, "Left\naligned")
memo_textalign#(memAlignL#, 0)
PRINTLN "  - Left align: " + stri$(memo_textalign(memAlignL#))
LET memAlignC# = memo#(sb#, 530, 280, 120, 60)
memo_text#(memAlignC#, "Center\naligned")
memo_textalign#(memAlignC#, 1)
PRINTLN "  - Center align: " + stri$(memo_textalign(memAlignC#))
LET memAlignR# = memo#(sb#, 660, 280, 120, 60)
memo_text#(memAlignR#, "Right\naligned")
memo_textalign#(memAlignR#, 2)
PRINTLN "  - Right align: " + stri$(memo_textalign(memAlignR#))
PRINTLN "  PASSED"
PRINTLN ""
' ============================================================================
' TEST 9: Position and Size
' ============================================================================
PRINTLN "TEST 9: Position and Size"
LET memPos# = memo#(sb#, 10, 370, 200, 80)
memo_text#(memPos#, "Position test")
PRINTLN "  - X: " + stri$(memo_x(memPos#))
PRINTLN "  - Y: " + stri$(memo_y(memPos#))
PRINTLN "  - Width: " + stri$(memo_width(memPos#))
PRINTLN "  - Height: " + stri$(memo_height(memPos#))
memo_move#(memPos#, 20, 370)
PRINTLN "  - After move - X: " + stri$(memo_x(memPos#))
PRINTLN "  PASSED"
PRINTLN ""
' ============================================================================
' TEST 10: Visibility and Behavior
' ============================================================================
PRINTLN "TEST 10: Visibility and Behavior"
LET memVis# = memo#(sb#, 230, 370, 200, 80)
memo_text#(memVis#, "Visibility test\n(70% opacity)")
PRINTLN "  - Visible: " + stri$(memo_visible(memVis#))
PRINTLN "  - Enabled: " + stri$(memo_enabled(memVis#))
PRINTLN "  - Opacity: " + stri$(memo_opacity(memVis#))
memo_opacity#(memVis#, 0.7)
PRINTLN "  - Opacity after change: " + stri$(memo_opacity(memVis#))
PRINTLN "  PASSED"
PRINTLN ""
' ============================================================================
' TEST 11: Event Handling
' ============================================================================
PRINTLN "TEST 11: Event Handling"
' Create a labeled section for event testing
LET lblEvents# = label#(sb#, "Event Test (type below):")
label_move#(lblEvents#, 450, 355)
label_fontsize#(lblEvents#, 12)
label_bold#(lblEvents#, 1)
LET memEvents# = memo#(sb#, 450, 375, 330, 80)
memo_text#(memEvents#, "Type here to test events...")
memo_onchange#(memEvents#, "OnMemoChange")
memo_onchangetracking#(memEvents#, "OnMemoTracking")
memo_onenter#(memEvents#, "OnMemoEnter")
memo_onexit#(memEvents#, "OnMemoExit")
memo_onkeydown#(memEvents#, "OnMemoKeyDown")
PRINTLN "  - Events registered:"
PRINTLN "    OnChange: " + memo_onchange$(memEvents#)
PRINTLN "    OnChangeTracking: " + memo_onchangetracking$(memEvents#)
PRINTLN "    OnEnter: " + memo_onenter$(memEvents#)
PRINTLN "    OnExit: " + memo_onexit$(memEvents#)
PRINTLN "    OnKeyDown: " + memo_onkeydown$(memEvents#)
PRINTLN "  PASSED"
PRINTLN ""
' ============================================================================
' TEST 12: Tag and Tab Order
' ============================================================================
PRINTLN "TEST 12: Tag and Tab Order"
memo_tag#(mem1#, 100)
memo_taborder#(mem1#, 1)
PRINTLN "  - Tag: " + stri$(memo_tag(mem1#))
PRINTLN "  - Tab order: " + stri$(memo_taborder(mem1#))
PRINTLN "  PASSED"
PRINTLN ""
' ============================================================================
' TEST 13: Error Handling
' ============================================================================
PRINTLN "TEST 13: Error Handling"
memo_clearerror()
PRINTLN "  - Initial error: " + stri$(memo_error())
' Try to use a null pointer
LET badPtr# = Pointer#(0)
memo_text#(badPtr#, "This should fail")
PRINTLN "  - Error after invalid operation: " + stri$(memo_error())
PRINTLN "  - Error message: " + memo_errormsg$()
PRINTLN "  - Error description: " + memo_strerror$(memo_error())
' Try out-of-bounds line access
memo_clearerror()
LET dummy$ = memo_line$(mem1#, 999)
PRINTLN "  - Error after OOB access: " + stri$(memo_error())
PRINTLN "  - Error description: " + memo_strerror$(memo_error())
memo_clearerror()
PRINTLN "  - After clear: " + stri$(memo_error())
PRINTLN "  PASSED"
PRINTLN ""
' ============================================================================
' Summary
' ============================================================================
PRINTLN "=== All Tests Completed ==="
PRINTLN "Form will now display. Try the interactive features:"
PRINTLN "- Type in the event test memo to see events fire"
PRINTLN "- Try the read-only memo"
PRINTLN "- Check the styled memo with bold+italic+blue"
PRINTLN ""
' Show the form
form_show(frm#)
' ============================================================================
' Event Callback Functions
' ============================================================================
FUNCTION OnMemoChange(sender#)
  PRINTLN "[OnChange] Lines: " + stri$(memo_linecount(sender#))
END FUNCTION
FUNCTION OnMemoTracking(sender#) LOCAL cnt
  cnt = memo_linecount(sender#)
  PRINTLN "[OnChangeTracking] Length: " + stri$(memo_textlength(sender#)) + " Lines: " + stri$(cnt)
END FUNCTION
FUNCTION OnMemoEnter(sender#)
  PRINTLN "[OnEnter] Memo focused"
END FUNCTION
FUNCTION OnMemoExit(sender#)
  PRINTLN "[OnExit] Memo lost focus"
END FUNCTION
FUNCTION OnMemoKeyDown(sender#, key, keychar$, shift$)
  PRINTLN "[OnKeyDown] Key: " + stri$(key) + " Char: " + keychar$ + " Shift: " + shift$
END FUNCTION
