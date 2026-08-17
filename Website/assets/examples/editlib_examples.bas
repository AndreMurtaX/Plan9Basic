' ============================================================================
' EditLib Examples - Practical Use Cases for Plan9Basic
' Fixed version - correct local variable syntax
' ============================================================================
' ============================================================================
' EXAMPLE 1: Simple Search Box (Self-contained callbacks)
' ============================================================================
PRINTLN "=== Example 1: Search Box ==="
LET frmSearch# = form#("Search Demo", 400, 180)
form_position#(frmSearch#, 4)
LET sbSearch# = scrollbox#(frmSearch#)
' Search field
LET edtSearch# = edit#(sbSearch#, 20, 20, 360, 35)
edit_prompt#(edtSearch#, "Type to search...")
edit_fontsize#(edtSearch#, 14)
edit_onchangetracking#(edtSearch#, "OnSearchTyping")
' Results label
LET lblResults# = label#(sbSearch#, "Enter at least 3 characters to search")
label_move#(lblResults#, 20, 70)
label_fontsize#(lblResults#, 12)
label_fontcolor#(lblResults#, "gray")
edit_tag#(edtSearch#, 1)
' Character count label
LET lblCount# = label#(sbSearch#, "0 characters")
label_move#(lblCount#, 280, 130)
label_fontsize#(lblCount#, 10)
label_fontcolor#(lblCount#, "silver")
form_show(frmSearch#)
' Callback with local variables declared on same line as function
FUNCTION OnSearchTyping(sender#) LOCAL txt$, slen
  txt$ = edit_text$(sender#)
  slen = edit_textlength(sender#)
  ' Print status to console
  PRINTLN "Search: \"" + txt$ + "\" (" + stri$(slen) + " chars)"
  IF slen >= 3 THEN
    PRINTLN "  -> Would search for: " + txt$
  END IF
END FUNCTION
' ============================================================================
' EXAMPLE 2: Calculator with self-contained logic
' ============================================================================
PRINTLN ""
PRINTLN "=== Example 2: Calculator ==="
LET frmCalc# = form#("Calculator", 320, 220)
form_position#(frmCalc#, 4)
form_move#(frmCalc#, 420, 50)
LET sbCalc# = scrollbox#(frmCalc#)
' Instructions
LET lblInstr# = label#(sbCalc#, "Enter two numbers and press Enter to add")
label_move#(lblInstr#, 20, 15)
label_fontsize#(lblInstr#, 10)
label_fontcolor#(lblInstr#, "gray")
' Number 1
LET lblNum1# = label#(sbCalc#, "Number 1:")
label_move#(lblNum1#, 20, 45)
LET edtCalc1# = edit#(sbCalc#, 100, 40, 200, 30)
edit_prompt#(edtCalc1#, "0")
edit_filterchar#(edtCalc1#, "0123456789.-")
edit_textalign#(edtCalc1#, 2)
edit_fontsize#(edtCalc1#, 14)
edit_tag#(edtCalc1#, 1)
' Number 2
LET lblNum2# = label#(sbCalc#, "Number 2:")
label_move#(lblNum2#, 20, 85)
LET edtCalc2# = edit#(sbCalc#, 100, 80, 200, 30)
edit_prompt#(edtCalc2#, "0")
edit_filterchar#(edtCalc2#, "0123456789.-")
edit_textalign#(edtCalc2#, 2)
edit_fontsize#(edtCalc2#, 14)
edit_tag#(edtCalc2#, 2)
edit_onkeydown#(edtCalc2#, "OnCalcKeyDown")
' Result (readonly)
LET lblResultTitle# = label#(sbCalc#, "Result:")
label_move#(lblResultTitle#, 20, 130)
label_fontsize#(lblResultTitle#, 12)
label_bold#(lblResultTitle#, 1)
LET edtCalcResult# = edit#(sbCalc#, 100, 125, 200, 35)
edit_readonly#(edtCalcResult#, 1)
edit_textalign#(edtCalcResult#, 2)
edit_fontsize#(edtCalcResult#, 18)
edit_bold#(edtCalcResult#, 1)
edit_fontcolor#(edtCalcResult#, "blue")
edit_text#(edtCalcResult#, "0")
edit_tag#(edtCalcResult#, 3)
' Status
LET lblCalcStatus# = label#(sbCalc#, "Press Enter in Number 2 field to calculate")
label_move#(lblCalcStatus#, 20, 175)
label_fontsize#(lblCalcStatus#, 9)
label_fontcolor#(lblCalcStatus#, "gray")
form_show(frmCalc#)
' Key handler - no local vars needed
FUNCTION OnCalcKeyDown(sender#, key, keychar$, shift$)
  IF key = 13 THEN
    PRINTLN "Calculator: Enter pressed - calculation would happen here"
    PRINTLN "  (In a real app, we'd access the other fields)"
  END IF
END FUNCTION
' ============================================================================
' EXAMPLE 3: Password field demo
' ============================================================================
PRINTLN ""
PRINTLN "=== Example 3: Password Demo ==="
LET frmPass# = form#("Password Demo", 350, 180)
form_position#(frmPass#, 4)
form_move#(frmPass#, 50, 300)
LET sbPass# = scrollbox#(frmPass#)
LET lblPassTitle# = label#(sbPass#, "Password Entry Demo")
label_move#(lblPassTitle#, 20, 15)
label_fontsize#(lblPassTitle#, 14)
label_bold#(lblPassTitle#, 1)
LET lblPassInfo# = label#(sbPass#, "Type a password - it will be masked:")
label_move#(lblPassInfo#, 20, 45)
label_fontsize#(lblPassInfo#, 11)
LET edtPassDemo# = edit#(sbPass#, 20, 70, 310, 30)
edit_prompt#(edtPassDemo#, "Enter password...")
edit_password#(edtPassDemo#, 1)
edit_fontsize#(edtPassDemo#, 12)
edit_onchange#(edtPassDemo#, "OnPasswordEntered")
LET lblPassHint# = label#(sbPass#, "Press Tab or click outside to trigger OnChange")
label_move#(lblPassHint#, 20, 110)
label_fontsize#(lblPassHint#, 9)
label_fontcolor#(lblPassHint#, "gray")
LET lblPassLength# = label#(sbPass#, "")
label_move#(lblPassLength#, 20, 140)
label_fontsize#(lblPassLength#, 11)
label_fontcolor#(lblPassLength#, "blue")
form_show(frmPass#)
' Password callback with local variables on function line
FUNCTION OnPasswordEntered(sender#) LOCAL pass$, plen
  pass$ = edit_text$(sender#)
  plen = len(pass$)
  PRINTLN "Password entered: " + stri$(plen) + " characters"
  IF plen < 6 THEN
    PRINTLN "  Warning: Password is weak (less than 6 chars)"
  ELSE
    PRINTLN "  Password length OK"
  END IF
END FUNCTION
' ============================================================================
' EXAMPLE 4: Text formatting demo
' ============================================================================
PRINTLN ""
PRINTLN "=== Example 4: Text Formatting ==="
LET frmFormat# = form#("Text Formatting", 400, 280)
form_position#(frmFormat#, 4)
form_move#(frmFormat#, 450, 300)
LET sbFormat# = scrollbox#(frmFormat#)
LET lblFmtTitle# = label#(sbFormat#, "Font Style Examples")
label_move#(lblFmtTitle#, 20, 15)
label_fontsize#(lblFmtTitle#, 14)
label_bold#(lblFmtTitle#, 1)
' Normal
LET edtNormal# = edit#(sbFormat#, 20, 50, 360, 30)
edit_text#(edtNormal#, "Normal text")
edit_fontsize#(edtNormal#, 12)
' Bold
LET edtBold# = edit#(sbFormat#, 20, 90, 360, 30)
edit_text#(edtBold#, "Bold text")
edit_fontsize#(edtBold#, 12)
edit_bold#(edtBold#, 1)
' Italic
LET edtItalic# = edit#(sbFormat#, 20, 130, 360, 30)
edit_text#(edtItalic#, "Italic text")
edit_fontsize#(edtItalic#, 12)
edit_italic#(edtItalic#, 1)
' Bold + Italic + Color
LET edtStyled# = edit#(sbFormat#, 20, 170, 360, 35)
edit_text#(edtStyled#, "Bold + Italic + Blue")
edit_fontsize#(edtStyled#, 14)
edit_bold#(edtStyled#, 1)
edit_italic#(edtStyled#, 1)
edit_fontcolor#(edtStyled#, "blue")
' Large
LET edtLarge# = edit#(sbFormat#, 20, 220, 360, 40)
edit_text#(edtLarge#, "Large Text (20pt)")
edit_fontsize#(edtLarge#, 20)
edit_fontcolor#(edtLarge#, "darkgreen")
form_show(frmFormat#)
' ============================================================================
' EXAMPLE 5: Input restrictions demo
' ============================================================================
PRINTLN ""
PRINTLN "=== Example 5: Input Restrictions ==="
LET frmRestrict# = form#("Input Restrictions", 400, 220)
form_position#(frmRestrict#, 4)
form_move#(frmRestrict#, 100, 100)
LET sbRestrict# = scrollbox#(frmRestrict#)
LET lblRestTitle# = label#(sbRestrict#, "Restricted Input Examples")
label_move#(lblRestTitle#, 20, 15)
label_fontsize#(lblRestTitle#, 14)
label_bold#(lblRestTitle#, 1)
' Numbers only
LET lblNumOnly# = label#(sbRestrict#, "Numbers only (0-9):")
label_move#(lblNumOnly#, 20, 50)
LET edtNumOnly# = edit#(sbRestrict#, 180, 45, 200, 30)
edit_filterchar#(edtNumOnly#, "0123456789")
edit_prompt#(edtNumOnly#, "Type numbers...")
' Letters only
LET lblLetOnly# = label#(sbRestrict#, "Letters only (A-Z):")
label_move#(lblLetOnly#, 20, 90)
LET edtLetOnly# = edit#(sbRestrict#, 180, 85, 200, 30)
edit_filterchar#(edtLetOnly#, "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz")
edit_prompt#(edtLetOnly#, "Type letters...")
' Max length
LET lblMaxLen# = label#(sbRestrict#, "Max 5 characters:")
label_move#(lblMaxLen#, 20, 130)
LET edtMaxLen# = edit#(sbRestrict#, 180, 125, 200, 30)
edit_maxlength#(edtMaxLen#, 5)
edit_prompt#(edtMaxLen#, "Max 5 chars")
' Hex input
LET lblHex# = label#(sbRestrict#, "Hex only (0-9, A-F):")
label_move#(lblHex#, 20, 170)
LET edtHex# = edit#(sbRestrict#, 180, 165, 200, 30)
edit_filterchar#(edtHex#, "0123456789ABCDEFabcdef")
edit_prompt#(edtHex#, "e.g. FF00AA")
form_show(frmRestrict#)
PRINTLN ""
PRINTLN "=== All examples are now running ==="
PRINTLN "Each form demonstrates different EditLib features"
PRINTLN "Callbacks print status to this console"
