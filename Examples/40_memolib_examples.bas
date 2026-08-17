' ============================================================================
' MemoLib Examples - Practical Use Cases for Plan9Basic
' Demonstrates multi-line text editing capabilities
' ============================================================================
' ============================================================================
' EXAMPLE 1: Simple Text Editor
' ============================================================================
PRINTLN "=== Example 1: Simple Text Editor ==="
LET frmEditor# = form#("Simple Text Editor", 500, 400)
form_position#(frmEditor#, 4)
LET sbEditor# = scrollbox#(frmEditor#)
' Title
LET lblTitle# = label#(sbEditor#, "Simple Text Editor")
label_move#(lblTitle#, 10, 10)
label_fontsize#(lblTitle#, 16)
label_bold#(lblTitle#, 1)
' Main memo editor
LET memEditor# = memo#(sbEditor#, 10, 40, 480, 310)
memo_wordwrap#(memEditor#, 1)
memo_showscrollbars#(memEditor#, 1)
memo_fontfamily#(memEditor#, "Segoe UI")
memo_fontsize#(memEditor#, 12)
' Status bar
LET lblStatus# = label#(sbEditor#, "Lines: 0 | Characters: 0")
label_move#(lblStatus#, 10, 360)
label_fontsize#(lblStatus#, 10)
label_fontcolor#(lblStatus#, "gray")
memo_onchangetracking#(memEditor#, "UpdateEditorStatus")
form_show(frmEditor#)
FUNCTION UpdateEditorStatus(sender#) LOCAL lines, chars
  lines = memo_linecount(sender#)
  chars = memo_textlength(sender#)
  PRINTLN "Editor: Lines=" + stri$(lines) + " Chars=" + stri$(chars)
END FUNCTION
' ============================================================================
' EXAMPLE 2: Log Viewer (Read-Only)
' ============================================================================
PRINTLN ""
PRINTLN "=== Example 2: Log Viewer ==="
LET frmLog# = form#("Application Log", 450, 300)
form_position#(frmLog#, 4)
form_move#(frmLog#, 520, 50)
LET sbLog# = scrollbox#(frmLog#)
' Log memo (read-only, monospace font)
LET memLog# = memo#(sbLog#, 10, 10, 430, 250)
memo_readonly#(memLog#, 1)
memo_wordwrap#(memLog#, 0)
memo_showscrollbars#(memLog#, 1)
memo_fontfamily#(memLog#, "Consolas")
memo_fontsize#(memLog#, 10)
memo_fontcolor#(memLog#, "darkgreen")
' Add log entries
memo_addline#(memLog#, "[2025-01-06 10:00:00] INFO  Application started")
memo_addline#(memLog#, "[2025-01-06 10:00:01] DEBUG Loading configuration...")
memo_addline#(memLog#, "[2025-01-06 10:00:02] INFO  Configuration loaded successfully")
memo_addline#(memLog#, "[2025-01-06 10:00:03] DEBUG Initializing database connection")
memo_addline#(memLog#, "[2025-01-06 10:00:04] INFO  Connected to database: localhost:5432")
memo_addline#(memLog#, "[2025-01-06 10:00:05] DEBUG Loading user preferences")
memo_addline#(memLog#, "[2025-01-06 10:00:06] INFO  User preferences loaded")
memo_addline#(memLog#, "[2025-01-06 10:00:07] INFO  Application ready")
memo_addline#(memLog#, "[2025-01-06 10:00:10] DEBUG Processing request from user")
memo_addline#(memLog#, "[2025-01-06 10:00:11] INFO  Request completed successfully")
' Scroll to end
memo_scrolltoend#(memLog#)
' Status
LET lblLogStatus# = label#(sbLog#, "Showing latest entries (read-only)")
label_move#(lblLogStatus#, 10, 270)
label_fontsize#(lblLogStatus#, 9)
label_fontcolor#(lblLogStatus#, "gray")
form_show(frmLog#)
' ============================================================================
' EXAMPLE 3: Code Editor Style
' ============================================================================
PRINTLN ""
PRINTLN "=== Example 3: Code Editor ==="
LET frmCode# = form#("Code Editor", 500, 350)
form_position#(frmCode#, 4)
form_move#(frmCode#, 50, 420)
LET sbCode# = scrollbox#(frmCode#)
' Code memo (no word wrap, monospace)
LET memCode# = memo#(sbCode#, 10, 10, 480, 300)
memo_wordwrap#(memCode#, 0)
memo_showscrollbars#(memCode#, 1)
memo_fontfamily#(memCode#, "Consolas")
memo_fontsize#(memCode#, 11)
memo_fontcolor#(memCode#, "navy")
' Add sample code
memo_addline#(memCode#, "' Sample Plan9Basic Program")
memo_addline#(memCode#, "' Demonstrates basic syntax")
memo_addline#(memCode#, "")
memo_addline#(memCode#, "let x = 10")
memo_addline#(memCode#, "let y = 20")
memo_addline#(memCode#, "let sum = x + y")
memo_addline#(memCode#, "")
memo_addline#(memCode#, "println \"Sum = \" + stri$(sum)")
memo_addline#(memCode#, "")
memo_addline#(memCode#, "for i = 1 to 5")
memo_addline#(memCode#, "  println \"i = \" + stri$(i)")
memo_addline#(memCode#, "next")
' Line info
LET lblCodeInfo# = label#(sbCode#, "")
label_move#(lblCodeInfo#, 10, 320)
label_fontsize#(lblCodeInfo#, 9)
label_fontcolor#(lblCodeInfo#, "gray")
memo_onchangetracking#(memCode#, "UpdateCodeInfo")
form_show(frmCode#)
FUNCTION UpdateCodeInfo(sender#) LOCAL lc
  lc = memo_linecount(sender#)
  PRINTLN "Code: " + stri$(lc) + " lines"
END FUNCTION
' ============================================================================
' EXAMPLE 4: Notes with Different Styles
' ============================================================================
PRINTLN ""
PRINTLN "=== Example 4: Styled Notes ==="
LET frmNotes# = form#("Styled Notes", 400, 450)
form_position#(frmNotes#, 4)
form_move#(frmNotes#, 570, 370)
LET sbNotes# = scrollbox#(frmNotes#)
' Normal style
LET lblNormal# = label#(sbNotes#, "Normal:")
label_move#(lblNormal#, 10, 10)
label_fontsize#(lblNormal#, 10)
LET memNormal# = memo#(sbNotes#, 10, 30, 380, 80)
memo_text#(memNormal#, "Normal text with default styling.\nMultiple lines supported.")
memo_fontsize#(memNormal#, 11)
' Bold style
LET lblBold# = label#(sbNotes#, "Bold:")
label_move#(lblBold#, 10, 120)
label_fontsize#(lblBold#, 10)
LET memBold# = memo#(sbNotes#, 10, 140, 380, 80)
memo_text#(memBold#, "Bold text stands out.\nUse for important notes.")
memo_fontsize#(memBold#, 11)
memo_bold#(memBold#, 1)
' Italic style
LET lblItalic# = label#(sbNotes#, "Italic:")
label_move#(lblItalic#, 10, 230)
label_fontsize#(lblItalic#, 10)
LET memItalic# = memo#(sbNotes#, 10, 250, 380, 80)
memo_text#(memItalic#, "Italic text for emphasis.\nOften used for quotes.")
memo_fontsize#(memItalic#, 11)
memo_italic#(memItalic#, 1)
' Colored style
LET lblColored# = label#(sbNotes#, "Colored (Blue, Bold+Italic):")
label_move#(lblColored#, 10, 340)
label_fontsize#(lblColored#, 10)
LET memColored# = memo#(sbNotes#, 10, 360, 380, 80)
memo_text#(memColored#, "Blue, bold, italic text.\nMaximum emphasis!")
memo_fontsize#(memColored#, 12)
memo_bold#(memColored#, 1)
memo_italic#(memColored#, 1)
memo_fontcolor#(memColored#, "blue")
form_show(frmNotes#)
' ============================================================================
' EXAMPLE 5: Text Alignment Demo
' ============================================================================
PRINTLN ""
PRINTLN "=== Example 5: Text Alignment ==="
LET frmAlign# = form#("Text Alignment", 450, 200)
form_position#(frmAlign#, 4)
form_move#(frmAlign#, 100, 50)
LET sbAlign# = scrollbox#(frmAlign#)
' Left aligned
LET memLeft# = memo#(sbAlign#, 10, 10, 135, 80)
memo_text#(memLeft#, "Left\nAligned\nText")
memo_textalign#(memLeft#, 0)
memo_fontsize#(memLeft#, 12)
' Center aligned
LET memCenter# = memo#(sbAlign#, 155, 10, 135, 80)
memo_text#(memCenter#, "Center\nAligned\nText")
memo_textalign#(memCenter#, 1)
memo_fontsize#(memCenter#, 12)
' Right aligned
LET memRight# = memo#(sbAlign#, 300, 10, 135, 80)
memo_text#(memRight#, "Right\nAligned\nText")
memo_textalign#(memRight#, 2)
memo_fontsize#(memRight#, 12)
' Labels
LET lblL# = label#(sbAlign#, "Left (0)")
label_move#(lblL#, 45, 100)
label_fontsize#(lblL#, 9)
LET lblC# = label#(sbAlign#, "Center (1)")
label_move#(lblC#, 185, 100)
label_fontsize#(lblC#, 9)
LET lblR# = label#(sbAlign#, "Right (2)")
label_move#(lblR#, 335, 100)
label_fontsize#(lblR#, 9)
' Word wrap demo
LET lblWrap# = label#(sbAlign#, "Word Wrap Demo:")
label_move#(lblWrap#, 10, 130)
label_fontsize#(lblWrap#, 10)
LET memWrap# = memo#(sbAlign#, 10, 150, 425, 40)
memo_text#(memWrap#, "This is a long line of text that demonstrates word wrapping in action. The text automatically wraps to the next line.")
memo_wordwrap#(memWrap#, 1)
memo_fontsize#(memWrap#, 10)
form_show(frmAlign#)
PRINTLN ""
PRINTLN "=== All examples are now running ==="
PRINTLN "Each form demonstrates different MemoLib features:"
PRINTLN "- Text Editor: typing with status updates"
PRINTLN "- Log Viewer: read-only monospace display"
PRINTLN "- Code Editor: no word wrap, code-style"
PRINTLN "- Styled Notes: font variations"
PRINTLN "- Text Alignment: left/center/right"
