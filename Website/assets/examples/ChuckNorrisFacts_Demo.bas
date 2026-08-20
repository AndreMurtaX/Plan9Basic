' ============================================================================
' Chuck Norris Facts - Plan9Basic Demo Application
' ============================================================================
' Responsive layout: single codebase for Desktop and Android/iOS.
' On desktop: two-column layout (sidebar + content).
' On mobile:  single-column layout, larger touch targets, vertical scroll.
' Showcases: FormLib, ButtonLib, LabelLib, MemoLib, EditLib, ListBoxLib,
'            RectangleLib, CircleLib, HttpLib, JsonLib
' ============================================================================
PRINTLN "Chuck Norris Facts - Loading..."
PRINTLN ""
' ============================================================================
' Platform Detection and Layout Variables
' ============================================================================
LET isMobile = 0
IF os_name$() = "Android" OR os_name$() = "iOS" THEN isMobile = 1
LET margin = 10
LET sw = form_screenwidth()
LET sh = form_screenheight()
IF isMobile = 1 THEN
  LET formW = sw
  LET formH = sh
  LET hdrH = 70
  LET catH = 90
  LET jokeH = 220
  LET btnH = 48
  LET fntSm = 11
  LET fntMd = 14
  LET fntLg = 16
  LET sideW = 0
ELSE
  LET formW = 716
  LET formH = 618
  LET hdrH = 80
  LET catH = 70
  LET jokeH = 200
  LET btnH = 35
  LET fntSm = 10
  LET fntMd = 12
  LET fntLg = 16
  LET sideW = 150
END IF
LET contentW = formW - margin * 2
IF isMobile = 1 THEN
  LET rightX = margin
  LET rightW = contentW
ELSE
  LET rightX = margin + sideW + margin
  LET rightW = contentW - sideW - margin
END IF
' ============================================================================
' Create Main Form
' ============================================================================
LET frm# = form#("Chuck Norris Facts", formW, formH)
LET sb# = scrollbox#(frm#)
' ============================================================================
' Background
' ============================================================================
LET bgRect# = rectangle#(sb#, 0, 0, formW, 2000)
rectangle_fill#(bgRect#, "#1a1a2e")
rectangle_stroke#(bgRect#, "#1a1a2e")
rectangle_hittest#(bgRect#, 0)
' ============================================================================
' Header Panel (full width)
' ============================================================================
LET headerPanel# = rectangle#(sb#, margin, margin, contentW, hdrH)
rectangle_fill#(headerPanel#, "#16213e")
rectangle_stroke#(headerPanel#, "#e94560")
rectangle_strokethickness#(headerPanel#, 2)
rectangle_corners#(headerPanel#, 15, 15)
LET titleX = margin + contentW / 2 - 130
LET lblTitle# = label#(sb#, "CHUCK NORRIS FACTS", titleX, 22)
label_fontsize#(lblTitle#, 28)
label_fontcolor#(lblTitle#, "#e94560")
label_bold#(lblTitle#, 1)
LET subtitleX = margin + contentW / 2 - 160
LET lblSubtitle# = label#(sb#, "The Internet's #1 source for Chuck Norris wisdom", subtitleX, 58)
label_fontsize#(lblSubtitle#, 11)
label_fontcolor#(lblSubtitle#, "#a0a0a0")
' ============================================================================
' Y cursor: start of content rows (below header)
' ============================================================================
LET curY = margin + hdrH + margin
' ============================================================================
' Left Sidebar (desktop only): Avatar + Did You Know?
' ============================================================================
IF isMobile = 0 THEN
  ' Avatar Panel
  LET avatarPanel# = rectangle#(sb#, margin, curY, sideW, 180)
  rectangle_fill#(avatarPanel#, "#0f3460")
  rectangle_stroke#(avatarPanel#, "#e94560")
  rectangle_strokethickness#(avatarPanel#, 2)
  rectangle_corners#(avatarPanel#, 10, 10)
  LET circle1# = circle#(sb#, margin+5, curY+5, 40, 40)
  circle_fill#(circle1#, "#e94560")
  circle_stroke#(circle1#, "#e94560")
  circle_opacity#(circle1#, 0.3)
  LET circle2# = circle#(sb#, margin+125, curY+145, 50, 50)
  circle_fill#(circle2#, "#e94560")
  circle_stroke#(circle2#, "#e94560")
  circle_opacity#(circle2#, 0.2)
  LET lblCN# = label#(sb#, "CN", margin+35, curY+40)
  label_fontsize#(lblCN#, 48)
  label_fontcolor#(lblCN#, "#e94560")
  label_bold#(lblCN#, 1)
  LET lblAvatar# = label#(sb#, "The Legend", margin+42, curY+145)
  label_fontsize#(lblAvatar#, 12)
  label_fontcolor#(lblAvatar#, "#ffffff")
  label_italic#(lblAvatar#, 1)
  ' Did You Know Panel (below stats, in sidebar)
  LET funY = curY + 390
  LET funFactPanel# = rectangle#(sb#, margin, funY, sideW, 180)
  rectangle_fill#(funFactPanel#, "#0f3460")
  rectangle_stroke#(funFactPanel#, "#e94560")
  rectangle_strokethickness#(funFactPanel#, 1)
  rectangle_corners#(funFactPanel#, 10, 10)
  LET lblFunTitle# = label#(sb#, "Did You Know?", margin+20, funY+10)
  label_fontsize#(lblFunTitle#, 12)
  label_fontcolor#(lblFunTitle#, "#e94560")
  label_bold#(lblFunTitle#, 1)
  LET lblFunFact# = label#(sb#, "Chuck Norris doesn't", margin+10, funY+35)
  label_fontsize#(lblFunFact#, 10)
  label_fontcolor#(lblFunFact#, "#ffffff")
  LET lblFunFact2# = label#(sb#, "read books. He stares", margin+10, funY+50)
  label_fontsize#(lblFunFact2#, 10)
  label_fontcolor#(lblFunFact2#, "#ffffff")
  LET lblFunFact3# = label#(sb#, "them down until he", margin+10, funY+65)
  label_fontsize#(lblFunFact3#, 10)
  label_fontcolor#(lblFunFact3#, "#ffffff")
  LET lblFunFact4# = label#(sb#, "gets the information", margin+10, funY+80)
  label_fontsize#(lblFunFact4#, 10)
  label_fontcolor#(lblFunFact4#, "#ffffff")
  LET lblFunFact5# = label#(sb#, "he wants.", margin+10, funY+95)
  label_fontsize#(lblFunFact5#, 10)
  label_fontcolor#(lblFunFact5#, "#ffffff")
  LET star1# = circle#(sb#, margin+120, funY+120, 10, 10)
  circle_fill#(star1#, "#ffd700")
  circle_stroke#(star1#, "#ffd700")
  LET star2# = circle#(sb#, margin+100, funY+140, 8, 8)
  circle_fill#(star2#, "#ffd700")
  circle_stroke#(star2#, "#ffd700")
  LET star3# = circle#(sb#, margin+135, funY+150, 6, 6)
  circle_fill#(star3#, "#ffd700")
  circle_stroke#(star3#, "#ffd700")
END IF
' ============================================================================
' Category Selection (right column)
' ============================================================================
LET categoryPanel# = rectangle#(sb#, rightX, curY, rightW, catH)
rectangle_fill#(categoryPanel#, "#16213e")
rectangle_stroke#(categoryPanel#, "#0f3460")
rectangle_strokethickness#(categoryPanel#, 1)
rectangle_corners#(categoryPanel#, 10, 10)
LET lblCategory# = label#(sb#, "Select Category:", rightX+15, curY+10)
label_fontsize#(lblCategory#, fntMd)
label_fontcolor#(lblCategory#, "#ffffff")
' Custom dropdown (Edit + arrow Button) and Get Fact button.
' Sizes adapt to available width on each platform.
IF isMobile = 1 THEN
  LET cmbW = (rightW - 30) / 2
  LET btnGetW = rightW - cmbW - 30
ELSE
  LET cmbW = 200
  LET btnGetW = 180
END IF
LET arrowW = 30
LET cmbY = curY + catH - 38
LET btnY = curY + (catH - btnH) / 2
' Readonly edit shows the selected category
LET edtCategory# = edit#(sb#, rightX+15, cmbY, cmbW - arrowW, 30)
edit_readonly#(edtCategory#, 1)
edit_text#(edtCategory#, "random")
IF isMobile = 1 THEN edit_fontcolor#(edtCategory#, "#ffffff")
' Arrow button toggles the popup listbox
LET btnArrow# = button#(sb#, rightX+15+cmbW-arrowW, cmbY, arrowW, 30)
button_text#(btnArrow#, "▼")
IF isMobile = 1 THEN button_fontcolor#(btnArrow#, "#ffffff")
button_onclick#(btnArrow#, "OnToggleDropdown")
IF isMobile = 1 THEN
  LET btnGetFact# = button#(sb#, "Get CN Fact!", rightX+cmbW+25, btnY, btnGetW, btnH)
ELSE
  LET btnGetFact# = button#(sb#, "Get Chuck Norris Fact!", rightX+cmbW+25, btnY, btnGetW, btnH)
END IF
IF isMobile = 1 THEN button_fontcolor#(btnGetFact#, "#ffffff")
button_onclick#(btnGetFact#, "OnGetFact")
' ============================================================================
' Joke Display (right column)
' ============================================================================
LET jokeY = curY + catH + margin
LET jokePanel# = rectangle#(sb#, rightX, jokeY, rightW, jokeH)
rectangle_fill#(jokePanel#, "#0f3460")
rectangle_stroke#(jokePanel#, "#e94560")
rectangle_strokethickness#(jokePanel#, 2)
rectangle_corners#(jokePanel#, 15, 15)
LET quoteCircle1# = circle#(sb#, rightX+15, jokeY+15, 16, 16)
circle_fill#(quoteCircle1#, "#e94560")
circle_stroke#(quoteCircle1#, "#e94560")
LET quoteCircle2# = circle#(sb#, rightX+35, jokeY+15, 16, 16)
circle_fill#(quoteCircle2#, "#e94560")
circle_stroke#(quoteCircle2#, "#e94560")
LET memoJoke# = memo#(sb#, rightX+15, jokeY+40, rightW-25, jokeH-50)
memo_readonly#(memoJoke#, 1)
memo_wordwrap#(memoJoke#, 1)
memo_fontsize#(memoJoke#, fntLg)
memo_fontcolor#(memoJoke#, "#000000")

memo_text#(memoJoke#, "Click 'Get Chuck Norris Fact!' to receive wisdom from the legend himself...")
' ============================================================================
' Statistics Panel
' Desktop: left sidebar (below avatar).  Mobile: right column (below joke).
' NOTE: lblFactsLoaded# and lblLastCategory# are always created here so
'       event handlers can reference them regardless of platform.
' ============================================================================
IF isMobile = 1 THEN
  LET statX = rightX
  LET statY = jokeY + jokeH + margin
  LET statW = rightW
  LET statH = 65
ELSE
  LET statX = margin
  LET statY = curY + 190
  LET statW = sideW
  LET statH = 90
END IF
LET statsPanel# = rectangle#(sb#, statX, statY, statW, statH)
rectangle_fill#(statsPanel#, "#16213e")
rectangle_stroke#(statsPanel#, "#0f3460")
rectangle_strokethickness#(statsPanel#, 1)
rectangle_corners#(statsPanel#, 10, 10)
LET lblStatsTitle# = label#(sb#, "Statistics", statX+15, statY+8)
label_fontsize#(lblStatsTitle#, 13)
label_fontcolor#(lblStatsTitle#, "#e94560")
label_bold#(lblStatsTitle#, 1)
LET lblFactsLoaded# = label#(sb#, "Facts loaded: 0", statX+15, statY+34)
label_fontsize#(lblFactsLoaded#, fntMd)
label_fontcolor#(lblFactsLoaded#, "#ffffff")
IF isMobile = 1 THEN
  LET lblLastCategory# = label#(sb#, "Last: -", statX+200, statY+34)
ELSE
  LET lblLastCategory# = label#(sb#, "Last: -", statX+15, statY+56)
END IF
label_fontsize#(lblLastCategory#, fntMd)
label_fontcolor#(lblLastCategory#, "#a0a0a0")
' ============================================================================
' Action Buttons
' Desktop: one row of 4.  Mobile: two rows of 2 (wider touch targets).
' ============================================================================
IF isMobile = 1 THEN
  LET actY = statY + statH + margin
  LET halfW = (rightW - margin) / 2
  LET actPanelH = btnH * 2 + margin * 3
  LET actionsPanel# = rectangle#(sb#, rightX, actY, rightW, actPanelH)
  rectangle_fill#(actionsPanel#, "#16213e")
  rectangle_stroke#(actionsPanel#, "#0f3460")
  rectangle_strokethickness#(actionsPanel#, 1)
  rectangle_corners#(actionsPanel#, 10, 10)
  LET btnRandom# = button#(sb#, "Random Fact",  rightX+5, actY+margin, halfW-5, btnH)
  LET btnDevJoke# = button#(sb#, "Dev Joke", rightX+halfW+10, actY+margin, halfW-5, btnH)
  LET btnScienceJoke#= button#(sb#, "Science Joke", rightX+5, actY+btnH+margin*2, halfW-5, btnH)
  LET btnClear# = button#(sb#, "Clear", rightX+halfW+10, actY+btnH+margin*2, halfW-5, btnH)
  LET statusY = actY + actPanelH + margin
ELSE
  LET actY = jokeY + jokeH + margin
  LET actPanelH = 60
  LET actionsPanel# = rectangle#(sb#, rightX, actY, rightW, actPanelH)
  rectangle_fill#(actionsPanel#, "#16213e")
  rectangle_stroke#(actionsPanel#, "#0f3460")
  rectangle_strokethickness#(actionsPanel#, 1)
  rectangle_corners#(actionsPanel#, 10, 10)
  LET btnRandom# = button#(sb#, "Random Fact", rightX+15,  actY+12, 120, btnH)
  LET btnDevJoke# = button#(sb#, "Dev Joke", rightX+145, actY+12, 100, btnH)
  LET btnScienceJoke#= button#(sb#, "Science Joke", rightX+255, actY+12, 110, btnH)
  LET btnClear# = button#(sb#, "Clear", rightX+375, actY+12,  80, btnH)
  LET statusY = actY + actPanelH + margin
END IF
IF isMobile = 1 THEN
  button_fontcolor#(btnRandom#, "#ffffff")
  button_fontcolor#(btnDevJoke#, "#ffffff")
  button_fontcolor#(btnScienceJoke#, "#ffffff")
  button_fontcolor#(btnClear#, "#ffffff")
END IF
button_onclick#(btnRandom#, "OnRandomFact")
button_onclick#(btnDevJoke#, "OnDevJoke")
button_onclick#(btnScienceJoke#, "OnScienceJoke")
button_onclick#(btnClear#, "OnClear")
' ============================================================================
' Status Bar (right column)
' ============================================================================
LET statusBar# = rectangle#(sb#, rightX, statusY, rightW, 110)
rectangle_fill#(statusBar#, "#1a1a2e")
rectangle_stroke#(statusBar#, "#16213e")
LET lblStatus# = label#(sb#, "Ready to deliver Chuck Norris wisdom...", rightX+10, statusY+10)
label_fontsize#(lblStatus#, fntSm)
label_fontcolor#(lblStatus#, "#a0a0a0")
LET lblApiInfo# = label#(sb#, "Powered by api.chucknorris.io", rightX+10, statusY+30)
label_fontsize#(lblApiInfo#, 9)
label_fontcolor#(lblApiInfo#, "#606060")
LET lblDemo# = label#(sb#, "Plan9Basic Demo - Showcasing: FormLib, ButtonLib, LabelLib,", rightX+10, statusY+60)
label_fontsize#(lblDemo#, 9)
label_fontcolor#(lblDemo#, "#505050")
LET lblDemo2# = label#(sb#, "MemoLib, EditLib, ListBoxLib, RectangleLib, CircleLib, HttpLib, JsonLib", rightX+10, statusY+75)
label_fontsize#(lblDemo2#, 9)
label_fontcolor#(lblDemo2#, "#505050")
' ============================================================================
' Category Dropdown Popup — CREATED LAST so FMX z-order places it on top
' of every other control. Visibility is toggled by OnToggleDropdown.
' ============================================================================
LET dropListH = 185
' Background rectangle behind popup — gives the dropdown a dark fill
' since listbox background cannot be set directly (TStyledControl limitation).
' Created just before lstCategory# so it sits immediately behind it in z-order.
LET lstBg# = rectangle#(sb#, rightX+15, cmbY+32, cmbW, dropListH)
rectangle_fill#(lstBg#, "#0f3460")
rectangle_stroke#(lstBg#, "#e94560")
rectangle_strokethickness#(lstBg#, 1)
rectangle_corners#(lstBg#, 4, 4)
rectangle_visible#(lstBg#, 0)
LET lstCategory# = listbox#(sb#, rightX+15, cmbY+32, cmbW, dropListH)
listbox_add(lstCategory#, "random")
listbox_add(lstCategory#, "animal")
listbox_add(lstCategory#, "career")
listbox_add(lstCategory#, "celebrity")
listbox_add(lstCategory#, "dev")
listbox_add(lstCategory#, "explicit")
listbox_add(lstCategory#, "fashion")
listbox_add(lstCategory#, "food")
listbox_add(lstCategory#, "history")
listbox_add(lstCategory#, "money")
listbox_add(lstCategory#, "movie")
listbox_add(lstCategory#, "music")
listbox_add(lstCategory#, "political")
listbox_add(lstCategory#, "religion")
listbox_add(lstCategory#, "science")
listbox_add(lstCategory#, "sport")
listbox_add(lstCategory#, "travel")
listbox_fontcolor#(lstCategory#, "#ffffff")
listbox_fontsize#(lstCategory#, fntMd)
listbox_visible#(lstCategory#, 0)
' Use onchange (single-pointer @# callback) rather than onitemclick (@##)
' so the handler signature matches every other event handler in this file.
listbox_onchange#(lstCategory#, "OnCategorySelected")
' ============================================================================
' Global Variables
' ============================================================================
LET factsLoaded = 0
LET dropdownOpen = 0
LET selectedCategory$ = "random"
LET http# = http_client#()
' ============================================================================
' Show the form
' ============================================================================
PRINTLN "Application ready!"
PRINTLN
PRINTLN "Click buttons to fetch Chuck Norris facts from the web!"
PRINTLN
form_show(frm#)
IF os_name$() = "Android" OR os_name$() = "iOS" THEN
  PRINTLN "Note: HTTP requests are synchronous and may cause a brief"
  PRINTLN "UI pause on mobile while fetching data from the network."
  PRINTLN
END IF
' ============================================================================
' Event Handlers
' ============================================================================
FUNCTION OnGetFact(sender#) LOCAL status, category$, url$, response$, json#, joke$
  category$ = selectedCategory$
  label_text#(lblStatus#, "Fetching fact for category: " + category$ + "...")
  IF category$ = "random" THEN
    LET url$ = "https://api.chucknorris.io/jokes/random"
  ELSE
    LET url$ = "https://api.chucknorris.io/jokes/random?category=" + category$
  END IF
  response$ = http_get$(http#, url$)
  status = http_status(http#)
  IF status = 200 THEN
    LET json# = json_parse#(response$)
    LET joke$ = json_gets$(json#, "value")
    memo_text#(memoJoke#, joke$)
    factsLoaded = factsLoaded + 1
    label_text#(lblFactsLoaded#, "Facts loaded: " + stri$(factsLoaded))
    label_text#(lblLastCategory#, "Last: " + category$)
    label_text#(lblStatus#, "Fact loaded successfully!")
    PRINTLN "Loaded fact #" + stri$(factsLoaded) + " from category: " + category$
  ELSE
    memo_text#(memoJoke#, "Error: Could not fetch fact. HTTP Status: " + stri$(status))
    label_text#(lblStatus#, "Error fetching fact. Try again!")
    PRINTLN "Error: HTTP " + stri$(status)
  END IF
END FUNCTION
FUNCTION OnRandomFact(sender#) LOCAL status, url$, response$, json#, joke$
  label_text#(lblStatus#, "Fetching random fact...")
  url$ = "https://api.chucknorris.io/jokes/random"
  response$ = http_get$(http#, url$)
  status = http_status(http#)
  IF status = 200 THEN
    json# = json_parse#(response$)
    joke$ = json_gets$(json#, "value")
    memo_text#(memoJoke#, joke$)
    factsLoaded = factsLoaded + 1
    label_text#(lblFactsLoaded#, "Facts loaded: " + stri$(factsLoaded))
    label_text#(lblLastCategory#, "Last: random")
    label_text#(lblStatus#, "Random fact loaded!")
    PRINTLN "Loaded random fact #" + stri$(factsLoaded)
  ELSE
    memo_text#(memoJoke#, "Error fetching fact!")
    label_text#(lblStatus#, "Error! Try again.")
  END IF
END FUNCTION
FUNCTION OnDevJoke(sender#) LOCAL status, url$, response$, json#, joke$
  label_text#(lblStatus#, "Fetching dev joke for programmers...")
  url$ = "https://api.chucknorris.io/jokes/random?category=dev"
  response$ = http_get$(http#, url$)
  status = http_status(http#)
  IF status = 200 THEN
    json# = json_parse#(response$)
    joke$ = json_gets$(json#, "value")
    memo_text#(memoJoke#, joke$)
    factsLoaded = factsLoaded + 1
    label_text#(lblFactsLoaded#, "Facts loaded: " + stri$(factsLoaded))
    label_text#(lblLastCategory#, "Last: dev")
    label_text#(lblStatus#, "Dev joke loaded! Happy coding!")
    PRINTLN "Loaded dev joke #" + stri$(factsLoaded)
  ELSE
    memo_text#(memoJoke#, "Error fetching dev joke!")
    label_text#(lblStatus#, "Error! Try again.")
  END IF
END FUNCTION
FUNCTION OnScienceJoke(sender#) LOCAL status, url$, response$, json#, joke$
  label_text#(lblStatus#, "Fetching science fact...")
  url$ = "https://api.chucknorris.io/jokes/random?category=science"
  response$ = http_get$(http#, url$)
  status = http_status(http#)
  IF status = 200 THEN
    json# = json_parse#(response$)
    joke$ = json_gets$(json#, "value")
    memo_text#(memoJoke#, joke$)
    factsLoaded = factsLoaded + 1
    label_text#(lblFactsLoaded#, "Facts loaded: " + stri$(factsLoaded))
    label_text#(lblLastCategory#, "Last: science")
    label_text#(lblStatus#, "Science fact loaded! Mind = Blown!")
    PRINTLN "Loaded science fact #" + stri$(factsLoaded)
  ELSE
    memo_text#(memoJoke#, "Error fetching science fact!")
    label_text#(lblStatus#, "Error! Try again.")
  END IF
END FUNCTION
FUNCTION OnClear(sender#)
  memo_text#(memoJoke#, "Click any button to receive more Chuck Norris wisdom...")
  label_text#(lblStatus#, "Cleared. Ready for more facts!")
  PRINTLN "Display cleared"
END FUNCTION
' ----------------------------------------------------------------------------
' Custom dropdown handlers
' ----------------------------------------------------------------------------
FUNCTION OnToggleDropdown(sender#)
  IF dropdownOpen = 0 THEN
    listbox_visible#(lstCategory#, 1)
    rectangle_visible#(lstBg#, 1)
    LET dropdownOpen = 1
  ELSE
    listbox_visible#(lstCategory#, 0)
    rectangle_visible#(lstBg#, 0)
    LET dropdownOpen = 0
  END IF
END FUNCTION
FUNCTION OnCategorySelected(sender#)
  LET selectedCategory$ = listbox_selected$(sender#)
  edit_text#(edtCategory#, selectedCategory$)
  listbox_visible#(lstCategory#, 0)
  rectangle_visible#(lstBg#, 0)
  LET dropdownOpen = 0
  label_text#(lblStatus#, "Category selected: " + selectedCategory$)
END FUNCTION
FUNCTION OnResize(sender#, Width, Height)
  form_caption#(sender#, "Width: "+Str$(form_width(sender#))+", Height: "+Str$(form_height(sender#)))
END FUNCTION
