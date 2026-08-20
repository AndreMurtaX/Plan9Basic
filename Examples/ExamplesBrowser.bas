' =============================================================================
' Plan9BASIC Example Browser
' Fetches and displays examples from https://plan9basic.com/api/examples.json
' Downloads selected examples to the platform documents folder.
'
' Uses:
'   - HttpLib     : http_client#(), http_get$(), http_error(), http_errormsg$()
'   - JsonLib     : json_parse#(), json_get#(), json_len(), json_item#(), json_gets$()
'   - StringGridLib : stringgrid#(), stringgrid_addcolumn#(), etc.
'   - IOUtilsLib  : dir_exists(), dir_create(), path_combine$(), file_writealltext()
' =============================================================================
' Module-level variables
LET frm# = Pointer#(0)
LET grid# = Pointer#(0)
LET statusLbl# = Pointer#(0)
LET descLbl# = Pointer#(0)   ' mobile: shows description of the selected row
LET http# = Pointer#(0)
LET examplesJson# = Pointer#(0)
LET downloadFolder$ = ""
LET isMobile = 0              ' 1 on Android / iOS, set before CreateUI
' StringGrid column indices (desktop defaults; reassigned for mobile in CreateUI)
LET COL_NAME = 0
LET COL_DESC = 1   ' desktop only; -1 on mobile (no description column)
LET COL_CAT = 2
LET COL_DL = 3
' =============================================================================
' Main Program
' =============================================================================
PRINTLN "=========================="
PRINTLN "Plan9BASIC Example Browser"
PRINTLN "=========================="
PRINTLN ""
IF os_name$() = "Android" OR os_name$() = "iOS" THEN
  isMobile = 1
  PRINTLN "Note: HTTP requests are synchronous on mobile platforms."
  PRINTLN "The UI may pause briefly during network operations."
  PRINTLN ""
END IF
' Set download destination — mirrors GetBasePath() in UnitMain.pas:
'   Android / iOS : TPath.GetDocumentsPath          (no subdirectory)
'   Desktop       : TPath.GetDocumentsPath\Plan9Basic
IF isMobile = 1 THEN
  downloadFolder$ = documentspath$()
ELSE
  downloadFolder$ = path_combine$(documentspath$(), "Plan9Basic")
END IF
PRINTLN "Download folder: " + downloadFolder$
' Ensure the folder exists (needed for the desktop Plan9Basic subdirectory)
IF dir_exists(downloadFolder$) = 0 THEN
  IF dir_create(downloadFolder$) = 1 THEN
    PRINTLN "Created folder: " + downloadFolder$
  ELSE
    PRINTLN "WARNING: Could not create download folder."
    PRINTLN "  Path: " + downloadFolder$
  END IF
END IF
' Create persistent HTTP client
http# = http_client#()
GOSUB CreateUI
' Fetch the example list right away
LoadExamples()
form_show(frm#)
PRINTLN ""
PRINTLN "Example Browser running. Close the window to exit."
END
' =============================================================================
' Create User Interface
' =============================================================================
CreateUI:
IF isMobile = 1 THEN
  ' ---- Mobile layout (Android / iOS) ----
  ' Form fills the device screen; request a portrait-friendly size
  frm# = form#("Plan9BASIC Example Browser", 400, 700)
  ' Compact header
  LET titleLbl# = label#(frm#, "P9BASIC Examples", 5, 5, 280, 24)
  statusLbl# = label#(frm#, "Initializing...", 5, 32, 280, 22)
  LET refreshBtn# = button#(frm#, "Refresh", 295, 5, 100, 44)
  button_onclick#(refreshBtn#, "OnRefreshClick")
  ' 3 columns totalling ~380px — fits a typical phone screen with no horizontal scroll needed
  ' COL_NAME=0  COL_CAT=1 (reassigned)  COL_DL=2 (reassigned)  COL_DESC=-1 (no column)
  COL_DESC = -1
  COL_CAT  = 1
  COL_DL   = 2
  grid# = stringgrid#(frm#, 0, 57, 400, 490)
  stringgrid_showhdr#(grid#, 1)
  stringgrid_altcolors#(grid#, 1)
  stringgrid_editing#(grid#, 0)
  stringgrid_addcolumn#(grid#, "Name",     0, 160)
  stringgrid_addcolumn#(grid#, "Category", 0, 110)
  stringgrid_addcolumn#(grid#, "Download", 0, 110)
  ' Description label below the grid — updated on every row tap
  descLbl# = label#(frm#, "(tap any row to read its description)", 5, 553, 390, 60)
ELSE
  ' ---- Desktop layout (Windows / macOS / Linux) ----
  frm# = form#("Plan9BASIC Example Browser", 960, 640)
  LET titleLbl# = label#(frm#, "Plan9BASIC Example Browser", 10, 10, 700, 28)
  statusLbl# = label#(frm#, "Initializing...", 10, 48, 830, 22)
  LET refreshBtn# = button#(frm#, "Refresh", 855, 42, 92, 30)
  button_onclick#(refreshBtn#, "OnRefreshClick")
  ' COL_NAME=0  COL_DESC=1  COL_CAT=2  COL_DL=3 (default values, unchanged)
  grid# = stringgrid#(frm#, 10, 82, 935, 530)
  stringgrid_showhdr#(grid#, 1)
  stringgrid_altcolors#(grid#, 1)
  stringgrid_editing#(grid#, 0)
  stringgrid_addcolumn#(grid#, "Name",        0, 185)
  stringgrid_addcolumn#(grid#, "Description", 0, 440)
  stringgrid_addcolumn#(grid#, "Category",    0, 130)
  stringgrid_addcolumn#(grid#, "Download",    0, 120)
END IF
stringgrid_oncellclick#(grid#, "OnCellClick")
RETURN
' =============================================================================
' Load Examples from API
' =============================================================================
FUNCTION LoadExamples() LOCAL response$, parsed#, status$, count, i, item#, name$, desc$, cat$
  label_text#(statusLbl#, "Fetching example list from plan9basic.com ...")
  ' A file, fetched by GET. It was a PHP endpoint answering a POST, and
  ' neither half of that is served by static hosting -- see docs/PUBLISHING.md.
  PRINTLN "GET https://plan9basic.com/api/examples.json"
  response$ = http_get$(http#, "https://plan9basic.com/api/examples.json")
  IF http_error() <> 0 THEN
    label_text#(statusLbl#, "Network error: " + http_errormsg$())
    PRINTLN "HTTP error: " + http_errormsg$()
    RETURN 0
  END IF
  IF response$ = "" THEN
    label_text#(statusLbl#, "Error: Empty response from server.")
    PRINTLN "Empty response received."
    RETURN 0
  END IF
  ' Parse the outer envelope: { "status": "ok", "data": [...] } -- unchanged
  ' from what the endpoint sent, so nothing below had to move.
  parsed# = json_parse#(response$)
  IF PntToNum(parsed#) = 0 THEN
    label_text#(statusLbl#, "Error: Could not parse server response as JSON.")
    PRINTLN "JSON parse failed."
    RETURN 0
  END IF
  status$ = json_gets$(parsed#, "status")
  IF status$ <> "ok" THEN
    label_text#(statusLbl#, "Server error: status = " + status$)
    PRINTLN "Server returned status: " + status$
    RETURN 0
  END IF
  ' Extract the "data" array that holds the example records
  examplesJson# = json_get#(parsed#, "data")
  IF PntToNum(examplesJson#) = 0 THEN
    label_text#(statusLbl#, "Error: 'data' array missing from server response.")
    PRINTLN "json_get# 'data' returned null."
    RETURN 0
  END IF
  count = json_len(examplesJson#)
  PRINTLN "Received " + str$(count) + " examples from server."
  ' Populate the grid
  stringgrid_clearrows(grid#)
  stringgrid_rowcount#(grid#, count)
  FOR i = 0 TO count - 1
    item# = json_item#(examplesJson#, i)
    name$ = json_gets$(item#, "name")
    desc$ = json_gets$(item#, "description")
    cat$  = json_gets$(item#, "category")
    stringgrid_cell#(grid#, COL_NAME, i, name$)
    IF isMobile = 0 THEN
      stringgrid_cell#(grid#, COL_DESC, i, desc$)
    END IF
    stringgrid_cell#(grid#, COL_CAT,  i, cat$)
    stringgrid_cell#(grid#, COL_DL,   i, "[ Download ]")
  NEXT
  label_text#(statusLbl#, str$(count) + " examples loaded. Click [ Download ] to save an example.")
END FUNCTION
' =============================================================================
' Button Handlers
' =============================================================================
FUNCTION OnRefreshClick(sender#)
  LoadExamples()
END FUNCTION
' =============================================================================
' Grid Cell Click Handler
' =============================================================================
FUNCTION OnCellClick(sender#, col, row) LOCAL item#, filename$, name$, url$, code$, savePath$, msg$
  ' Guard: examples must be loaded and row in range
  IF PntToNum(examplesJson#) = 0 THEN
    label_text#(statusLbl#, "No examples loaded. Click Refresh to fetch the list.")
    RETURN 0
  END IF
  IF row < 0 OR row >= json_len(examplesJson#) THEN RETURN 0
  ' Retrieve the example record for this row
  item# = json_item#(examplesJson#, row)
  ' On mobile: any tap updates the description detail label below the grid
  IF isMobile = 1 AND PntToNum(descLbl#) <> 0 THEN
    label_text#(descLbl#, json_gets$(item#, "description"))
  END IF
  ' Only proceed with download when the Download column was tapped
  IF col <> COL_DL THEN RETURN 0
  filename$ = json_gets$(item#, "filename")
  name$ = json_gets$(item#, "name")
  IF filename$ = "" THEN
    label_text#(statusLbl#, "Error: No filename for '" + name$ + "'.")
    RETURN 0
  END IF
  ' Use the ready-made download_path field supplied by the API
  url$ = json_gets$(item#, "download_path")
  IF url$ = "" THEN
    label_text#(statusLbl#, "Error: No download_path for '" + name$ + "'.")
    RETURN 0
  END IF
  label_text#(statusLbl#, "Downloading: " + filename$ + " ...")
  PRINTLN "GET " + url$
  ' Download the file content
  code$ = http_get$(http#, url$)
  IF http_error() <> 0 THEN
    label_text#(statusLbl#, "Download failed: " + http_errormsg$())
    PRINTLN "HTTP error: " + http_errormsg$()
    RETURN 0
  END IF
  IF code$ = "" THEN
    label_text#(statusLbl#, "Error: Server returned an empty file for '" + filename$ + "'.")
    PRINTLN "Empty file received."
    RETURN 0
  END IF
  ' Make sure target folder still exists (user could have deleted it)
  IF dir_exists(downloadFolder$) = 0 THEN
    IF dir_create(downloadFolder$) = 0 THEN
      label_text#(statusLbl#, "Error: Cannot create folder: " + downloadFolder$)
      PRINTLN "dir_create failed: " + downloadFolder$
      RETURN 0
    END IF
  END IF
  ' Write to disk
  savePath$ = path_combine$(downloadFolder$, filename$)
  IF file_writealltext(savePath$, code$) = 1 THEN
    msg$ = "Saved: " + filename$ + "  (" + str$(len(code$)) + " bytes)"
    label_text#(statusLbl#, msg$)
    PRINTLN "Saved to: " + savePath$
  ELSE
    label_text#(statusLbl#, "Save error: " + iostrerror$())
    PRINTLN "file_writealltext error: " + iostrerror$()
  END IF
END FUNCTION
