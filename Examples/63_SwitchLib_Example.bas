' =============================================================================
' SwitchLib Example - Settings Panel Demo
' =============================================================================
' This example demonstrates the SwitchLib functionality by creating a
' settings panel with multiple switches for various options.
' =============================================================================
' Global variables for controls
LET frm# = Pointer#(0)
LET lblTitle# = Pointer#(0)
LET lblStatus# = Pointer#(0)
' Settings switches
LET swNotifications# = Pointer#(0)
LET swDarkMode# = Pointer#(0)
LET swAutoSave# = Pointer#(0)
LET swSound# = Pointer#(0)
LET swLocation# = Pointer#(0)
' Labels for switches
LET lblNotifications# = Pointer#(0)
LET lblDarkMode# = Pointer#(0)
LET lblAutoSave# = Pointer#(0)
LET lblSound# = Pointer#(0)
LET lblLocation# = Pointer#(0)
' Settings state tracking
LET countOn = 0
' Main program
Main()
END 'Main applet ending
' =============================================================================
' Main Subroutine
' =============================================================================
FUNCTION Main() LOCAL y, btnAll#, btnNone#, btnToggle#
  ' Create the main form
  frm# = form#("Settings Panel", 400, 450)
  ' Title label
  lblTitle# = label#(frm#, "Application Settings")
  label_move#(lblTitle#, 20, 20)
  label_fontsize#(lblTitle#, 18)
  label_bold#(lblTitle#, 1)
  ' Create setting rows
  y = 70
  ' Notifications setting
  lblNotifications# = label#(frm#, "Enable Notifications")
  label_move#(lblNotifications#, 20, y + 3)
  label_width#(lblNotifications#, 200)
  swNotifications# = switch#(frm#)
  switch_move#(swNotifications#, 300, y)
  switch_ischecked#(swNotifications#, 1)
  switch_tag#(swNotifications#, 1)
  switch_onswitch#(swNotifications#, "OnSettingChanged")
  y = y + 50
  ' Dark Mode setting
  lblDarkMode# = label#(frm#, "Dark Mode")
  label_move#(lblDarkMode#, 20, y + 3)
  label_width#(lblDarkMode#, 200)
  swDarkMode# = switch#(frm#)
  switch_move#(swDarkMode#, 300, y)
  switch_ischecked#(swDarkMode#, 0)
  switch_tag#(swDarkMode#, 2)
  switch_onswitch#(swDarkMode#, "OnSettingChanged")
  y = y + 50
  ' Auto-Save setting
  lblAutoSave# = label#(frm#, "Auto-Save Documents")
  label_move#(lblAutoSave#, 20, y + 3)
  label_width#(lblAutoSave#, 200)
  swAutoSave# = switch#(frm#)
  switch_move#(swAutoSave#, 300, y)
  switch_ischecked#(swAutoSave#, 1)
  switch_tag#(swAutoSave#, 3)
  switch_onswitch#(swAutoSave#, "OnSettingChanged")
  y = y + 50
  ' Sound setting
  lblSound# = label#(frm#, "Sound Effects")
  label_move#(lblSound#, 20, y + 3)
  label_width#(lblSound#, 200)
  swSound# = switch#(frm#)
  switch_move#(swSound#, 300, y)
  switch_ischecked#(swSound#, 1)
  switch_tag#(swSound#, 4)
  switch_onswitch#(swSound#, "OnSettingChanged")
  y = y + 50
  ' Location setting
  lblLocation# = label#(frm#, "Share Location")
  label_move#(lblLocation#, 20, y + 3)
  label_width#(lblLocation#, 200)
  swLocation# = switch#(frm#)
  switch_move#(swLocation#, 300, y)
  switch_ischecked#(swLocation#, 0)
  switch_tag#(swLocation#, 5)
  switch_onswitch#(swLocation#, "OnSettingChanged")
  y = y + 70
  ' Status label
  lblStatus# = label#(frm#, "")
  label_move#(lblStatus#, 20, y)
  label_width#(lblStatus#, 360)
  label_fontsize#(lblStatus#, 12)
  ' Create action buttons
  y = y + 40
  btnAll# = button#(frm#, "Enable All")
  button_move#(btnAll#, 20, y)
  button_width#(btnAll#, 100)
  button_onclick#(btnAll#, "OnEnableAll")
  btnNone# = button#(frm#, "Disable All")
  button_move#(btnNone#, 140, y)
  button_width#(btnNone#, 100)
  button_onclick#(btnNone#, "OnDisableAll")
  btnToggle# = button#(frm#, "Toggle All")
  button_move#(btnToggle#, 260, y)
  button_width#(btnToggle#, 100)
  button_onclick#(btnToggle#, "OnToggleAll")
  ' Update initial status
  UpdateStatus()
  ' Show the form
  form_show(frm#)
END FUNCTION
' =============================================================================
' Event Handlers
' =============================================================================
' Called when any setting switch changes
FUNCTION OnSettingChanged(sender#) LOCAL settingId, state, settingName$
  settingId = switch_tag(sender#)
  state = switch_ischecked(sender#)
  ' Determine which setting changed
  IF settingId = 1 THEN
    settingName$ = "Notifications"
  END IF
  IF settingId = 2 THEN
    settingName$ = "Dark Mode"
  END IF
  IF settingId = 3 THEN
    settingName$ = "Auto-Save"
  END IF
  IF settingId = 4 THEN
    settingName$ = "Sound Effects"
  END IF
  IF settingId = 5 THEN
    settingName$ = "Location Sharing"
  END IF
  ' Log the change
  IF state = 1 THEN
    PRINTLN settingName$ + " enabled"
  ELSE
    PRINTLN settingName$ + " disabled"
  END IF
  ' Update status display
  UpdateStatus()
END FUNCTION
' Enable all settings
FUNCTION OnEnableAll(sender#)
  switch_ischecked#(swNotifications#, 1)
  switch_ischecked#(swDarkMode#, 1)
  switch_ischecked#(swAutoSave#, 1)
  switch_ischecked#(swSound#, 1)
  switch_ischecked#(swLocation#, 1)
  PRINTLN "All settings enabled"
  UpdateStatus()
END FUNCTION
' Disable all settings
FUNCTION OnDisableAll(sender#)
  switch_ischecked#(swNotifications#, 0)
  switch_ischecked#(swDarkMode#, 0)
  switch_ischecked#(swAutoSave#, 0)
  switch_ischecked#(swSound#, 0)
  switch_ischecked#(swLocation#, 0)
  PRINTLN "All settings disabled"
  UpdateStatus()
END FUNCTION
' Toggle all settings
FUNCTION OnToggleAll(sender#)
  switch_toggle#(swNotifications#)
  switch_toggle#(swDarkMode#)
  switch_toggle#(swAutoSave#)
  switch_toggle#(swSound#)
  switch_toggle#(swLocation#)
  PRINTLN "All settings toggled"
  UpdateStatus()
END FUNCTION
' =============================================================================
' Helper Functions
' =============================================================================
' Update the status label to show current state
FUNCTION UpdateStatus() LOCAL msg$
  countOn = 0
  IF switch_ischecked(swNotifications#) = 1 THEN
    countOn = countOn + 1
  END IF
  IF switch_ischecked(swDarkMode#) = 1 THEN
    countOn = countOn + 1
  END IF
  IF switch_ischecked(swAutoSave#) = 1 THEN
    countOn = countOn + 1
  END IF
  IF switch_ischecked(swSound#) = 1 THEN
    countOn = countOn + 1
  END IF
  IF switch_ischecked(swLocation#) = 1 THEN
    countOn = countOn + 1
  END IF
  msg$ = str$(countOn) + " of 5 settings enabled"
  label_text#(lblStatus#, msg$)
END FUNCTION
