' ============================================================
'  Space Mines - Plan9Basic
' ============================================================
'
'  After the type-in listing on page 24 of "Computer Spacegames"
'  (Usborne Publishing, 1982), written there for a ZX81 in 71
'  numbered lines. The rules below are that program's rules; what
'  changed is the surface it presents them through.
'
'  You lead a mining colony on Astron for ten years. Each year the
'  mines produce ore, the market sets a price for ore and for
'  mines, and you make four decisions in this order:
'
'      1. how much ore to sell
'      2. how many mines to sell
'      3. how much to spend on food
'      4. how many mines to buy
'
'  The order matters and is the original's: money from the ore you
'  sell is available to buy food, and money you did not spend on
'  food is available for mines.
'
'  Then the colony answers. Feed people well and satisfaction
'  rises, output per mine rises and settlers arrive. Feed them
'  badly and all three go the other way. Fall below 0.6 and they
'  revolt. Work fewer than ten people to a mine and the colony
'  breaks. Drop below thirty people and there is nothing left.
'
'  WHERE THIS DEPARTS FROM THE 1982 LISTING, and why:
'
'    * Line 40 computes a food price FP and no later line ever
'      reads it. Satisfaction keys off fixed thresholds of $120
'      and $80 a head instead. FP is dropped here rather than
'      wired up, because inventing a use for it would change the
'      balance of a game that has been played as written for
'      forty years.
'
'    * Line 520 evaluates P/L. Sell every mine and L is zero, and
'      the ZX81 stops with an arithmetic error rather than ending
'      the game. Selling your last mine is now simply a way to
'      lose, which is what it means.
'
'    * Lines 510 and 610 can drive output per mine below zero
'      after a run of bad years, and negative production then eats
'      the ore in store. Output is held at zero.
'
'    * Line 600 announces "MARKET GLUT - PRICE DROPS" and line 610
'      halves CE, the yield per mine. The message is reworded to
'      match what the code does. The arithmetic is untouched.
'
'  Everything else -- the ranges, the thresholds, the 1% chance of
'  a radioactive leak, the market glut at 150 tons, the ten-year
'  term -- is as printed.
'
'  TWO THINGS ABOUT THE DIALECT, both measured while writing this
'  rather than assumed, and both easy to get wrong:
'
'    * A function that answers a POINTER carries # on its own name,
'      exactly as a variable does. "function Card#(...)" at the
'      foot of this file is one. Without the suffix it is a numeric
'      function, and assigning its result to a "#" variable answers
'      "Pointer expected" -- which reads like a fault at the call
'      rather than in the declaration.
'
'    * mid$ is 0-BASED, as instr is. Walking a string backwards
'      runs from len-1 down to 0, not from len down to 1.
'
'    * NAMES ARE CASE-INSENSITIVE, and the type suffix is part of
'      the name. So S and s$ are two variables, but BAD$ and bad$
'      are one. A local named bad$ inside Preview held the reason a
'      plan was refused -- and so overwrote the global BAD$ that
'      holds the colour to print it in. The warning came out black
'      on a dark panel, which looks like a palette that was chosen
'      badly rather than a variable that was clobbered. Locals here
'      avoid the palette's names.
'
' ============================================================

randomize()

' --- Layout ---------------------------------------------------
let WIN_W = 940
let WIN_H = 700
let COL_L = 24
let COL_R = 484
let COL_W = 432

' --- Palette --------------------------------------------------
let BG$      = "#0b1020"
let PANEL$   = "#151d38"
let EDGE$    = "#2b3a6b"
let INK$     = "#dfe6ff"
let DIM$     = "#8fa0d0"
let GOLD$    = "#ffc247"
let GOOD$    = "#5fd38d"
let WARN$    = "#ffa726"
let BAD$     = "#ef5350"
let ACCENT$  = "#4fc3f7"

' --- Colony state ---------------------------------------------
let L = 0          ' mines
let P = 0          ' people
let M = 0          ' money
let CE = 0         ' ore produced per mine per year
let C = 0          ' ore in store
let S = 1          ' satisfaction factor
let Y = 1          ' year, 1 through 10
let LP = 0         ' price of one mine this year
let CP = 0         ' price of one ton of ore this year
let OVER = 0       ' 1 once the game has ended
let TERM = 10

' What the colony looked like when the last year was committed, so each
' figure can show what a year of your decisions did to it. SHOWDELTA is 0
' until a year has actually been committed, because "+0" against a state
' nobody chose is noise.
let WASP = 0
let WASL = 0
let WASM = 0
let WASC = 0
let WASCE = 0
let SHOWDELTA = 0

' ============================================================
'  THE WINDOW
'
'  Built with the four helpers at the foot of this file, which are
'  defined below the code that calls them. The engine resolves the
'  call either way.
' ============================================================

frm# = form#("Space Mines - Colony of Astron", WIN_W, WIN_H)
form_fill#(frm#, BG$)

lblTitle# = label#(frm#, "SPACE MINES", COL_L, 18, 460, 40)
label_fontsize#(lblTitle#, 30)
label_bold#(lblTitle#, 1)
label_fontcolor#(lblTitle#, GOLD$)

lblSub# = label#(frm#, "Colony of Astron", COL_L, 56, 460, 22)
label_fontsize#(lblSub#, 14)
label_fontcolor#(lblSub#, DIM$)

lblYear# = label#(frm#, "", COL_R, 22, COL_W, 34)
label_fontsize#(lblYear#, 22)
label_bold#(lblYear#, 1)
label_fontcolor#(lblYear#, ACCENT$)
label_textalign#(lblYear#, 2)

lblTerm# = label#(frm#, "", COL_R, 56, COL_W, 22)
label_fontsize#(lblTerm#, 13)
label_fontcolor#(lblTerm#, DIM$)
label_textalign#(lblTerm#, 2)

' --- The colony -----------------------------------------------
cardCol# = Card#(COL_L, 92, COL_W, 196)
hdrCol#  = Heading#(COL_L + 18, 104, "THE COLONY")

capPeople# = Caption#(COL_L + 18, 134, "People")
valPeople# = Figure#(COL_L + 18, 152)
dltPeople# = Delta#(COL_L + 18, 134)
capMines#  = Caption#(COL_L + 228, 134, "Mines")
valMines#  = Figure#(COL_L + 228, 152)
dltMines#  = Delta#(COL_L + 228, 134)
capStore#  = Caption#(COL_L + 18, 196, "Ore in store")
valStore#  = Figure#(COL_L + 18, 214)
dltStore#  = Delta#(COL_L + 18, 196)
capOut#    = Caption#(COL_L + 228, 196, "Output per mine")
valOut#    = Figure#(COL_L + 228, 214)
dltOut#    = Delta#(COL_L + 228, 196)

' --- The market -----------------------------------------------
cardMkt# = Card#(COL_R, 92, COL_W, 196)
hdrMkt#  = Heading#(COL_R + 18, 104, "THE MARKET, THIS YEAR")

capOreP#  = Caption#(COL_R + 18, 134, "Ore, per ton")
valOreP#  = Figure#(COL_R + 18, 152)
capMineP# = Caption#(COL_R + 228, 134, "Mines, each")
valMineP# = Figure#(COL_R + 228, 152)

capCash# = Caption#(COL_R + 18, 196, "Treasury")
dltCash# = Delta#(COL_R + 18, 196)
valCash# = label#(frm#, "", COL_R + 18, 212, 390, 40)
label_fontsize#(valCash#, 28)
label_bold#(valCash#, 1)
label_fontcolor#(valCash#, GOLD$)

' --- Satisfaction ---------------------------------------------
cardSat# = Card#(COL_L, 300, 892, 78)
hdrSat#  = Heading#(COL_L + 18, 312, "SATISFACTION")

barSat# = progressbar#(frm#, COL_L + 18, 342, 640, 18)
progressbar_min#(barSat#, 0)
progressbar_max#(barSat#, 200)

valSat# = label#(frm#, "", COL_L + 676, 330, 216, 34)
label_fontsize#(valSat#, 20)
label_bold#(valSat#, 1)

' --- Decisions ------------------------------------------------
cardDec# = Card#(COL_L, 390, 892, 148)
hdrDec#  = Heading#(COL_L + 18, 402, "YOUR DECISIONS, IN THIS ORDER")

capD1#   = Caption#(COL_L + 18, 430, "1. Tons of ore to sell")
edSell#  = edit#(frm#, COL_L + 18, 450, 190, 32)
capD2#   = Caption#(COL_L + 236, 430, "2. Mines to sell")
edMSell# = edit#(frm#, COL_L + 236, 450, 190, 32)
capD3#   = Caption#(COL_L + 454, 430, "3. Spend on food")
edFood#  = edit#(frm#, COL_L + 454, 450, 190, 32)
capD4#   = Caption#(COL_L + 672, 430, "4. Mines to buy")
edBuy#   = edit#(frm#, COL_L + 672, 450, 190, 32)

lblHint# = label#(frm#, "", COL_L + 18, 488, 640, 20)
label_fontsize#(lblHint#, 13)
label_fontcolor#(lblHint#, DIM$)

' Updated on every keystroke, so the consequences of a plan are visible
' before it is committed rather than discovered in the chronicle after.
lblPrev# = label#(frm#, "", COL_L + 18, 510, 640, 20)
label_fontsize#(lblPrev#, 13)
label_bold#(lblPrev#, 1)
label_fontcolor#(lblPrev#, ACCENT$)

btnGo# = button#(frm#, "COMMIT THE YEAR", COL_L + 672, 490, 190, 34)
button_fontsize#(btnGo#, 14)
button_bold#(btnGo#, 1)

' --- Chronicle ------------------------------------------------
hdrLog# = Heading#(COL_L, 550, "CHRONICLE")
memLog# = memo#(frm#, COL_L, 574, 892, 100)
memo_fontsize#(memLog#, 13)

' ============================================================
'  PRESENTATION
' ============================================================

' Money with thousands separators, because a colony treasury runs
' to six figures and "184500" is harder to read at a glance than
' "$184,500" when the question is how much of it to spend.
function Money$(n) local v, s$, out$, i, c$, k
  v = cint(n)
  s$ = str$(v)
  if v < 0 then s$ = str$(-v)
  out$ = ""
  k = 0
  ' mid$ is 0-based, so this runs from len-1 down to 0. Starting at
  ' len drops the leading digit and reads one past the end, which
  ' is how "$100" first came back as "$00".
  for i = len(s$) - 1 to 0 step -1
    c$ = mid$(s$, i, 1)
    out$ = c$ + out$
    k = k + 1
    if k = 3 then
      if i > 0 then
        out$ = "," + out$
        k = 0
      end if
    end if
  next i
  if v < 0 then return "-$" + out$
  return "$" + out$
end function

' "Bought 1 mines" is the sort of thing nobody notices until it is on a
' public page. One mine, two mines.
function Mines$(n)
  if n = 1 then return " mine"
  return " mines"
end function

function Say(line$)
  memo_addline#(memLog#, line$)
  memo_scrolltoend#(memLog#)
  return 0
end function

function Refresh() local pct, satCol$, word$
  label_text#(valPeople#, str$(cint(P)))
  label_text#(valMines#, str$(cint(L)))
  label_text#(valStore#, str$(cint(C)) + " t")
  label_text#(valOut#, str$(cint(CE)) + " t")
  label_text#(valOreP#, Money$(CP))
  label_text#(valMineP#, Money$(LP))
  label_text#(valCash#, Money$(M))

  ' What the year did to each figure. This is the whole point of a panel over
  ' a scrolling terminal: the numbers are in the same place every year, so the
  ' movement between years is the thing the eye can actually follow.
  PaintDelta(dltPeople#, P - WASP, 0)
  PaintDelta(dltMines#, L - WASL, 0)
  PaintDelta(dltStore#, C - WASC, 0)
  PaintDelta(dltOut#, CE - WASCE, 0)
  PaintDelta(dltCash#, M - WASM, 1)

  if OVER = 0 then
    label_text#(lblYear#, "YEAR " + str$(cint(Y)) + " OF " + str$(TERM))
    label_text#(lblTerm#, "of your ten-year term")
  end if

  pct = cint(S * 100)
  if pct < 0 then pct = 0
  if pct > 200 then pct = 200
  progressbar_value#(barSat#, pct)

  satCol$ = GOOD$
  word$ = "content"
  if S < 0.9 then
    satCol$ = WARN$
    word$ = "restless"
  end if
  if S < 0.6 then
    satCol$ = BAD$
    word$ = "mutinous"
  end if
  if S > 1.1 then
    satCol$ = ACCENT$
    word$ = "thriving"
  end if
  label_fontcolor#(valSat#, satCol$)
  label_text#(valSat#, str$(pct) + "%  " + word$)

  ' The original printed "APPR. $100 EA." and left the rest to you.
  ' Same advice, with the arithmetic already done.
  label_text#(lblHint#, "Feeding " + str$(cint(P)) + " people well costs about " + Money$(P * 120) + ". Below " + Money$(P * 80) + " they suffer.")
  return 0
end function

' ============================================================
'  THE YEAR
' ============================================================

function NewGame()
  L = cint(rnd() * 3 + 5)
  P = cint(rnd() * 60 + 40)
  M = cint(rnd() * 50 + 10) * P
  CE = cint(rnd() * 40 + 80)
  C = 0
  S = 1
  Y = 1
  OVER = 0
  SHOWDELTA = 0
  WASP = 0
  WASL = 0
  WASM = 0
  WASC = 0
  WASCE = 0
  memo_clear#(memLog#)
  label_fontcolor#(lblYear#, ACCENT$)
  button_text#(btnGo#, "COMMIT THE YEAR")
  Say("You are the newly elected leader of the mining colony on Astron.")
  Say("Ten years. " + str$(cint(P)) + " people, " + str$(cint(L)) + " mines, " + Money$(M) + " in the treasury.")
  NewYear()
  return 0
end function

function NewYear() local produced
  LP = cint(rnd() * 2000 + 2000)
  CP = cint(rnd() * 12 + 7)
  produced = CE * L
  C = C + produced
  Say("")
  Say("--- Year " + str$(cint(Y)) + " ---")
  Say("The mines yielded " + str$(cint(produced)) + " tons. Ore fetches " + Money$(CP) + " a ton; a mine costs " + Money$(LP) + ".")
  edit_text#(edSell#, "0")
  edit_text#(edMSell#, "0")
  edit_text#(edFood#, str$(cint(P * 100)))
  edit_text#(edBuy#, "0")
  Refresh()
  Preview(frm#)
  return 0
end function

' Reads one field as a whole number of at least zero, or -1 when it is not
' one, so the caller can name the field instead of treating rubbish as nought.
'
' NOT val() ALONE. val is lenient in three ways that all bite here:
'
'   val("abc")   is 0     -- letters would silently mean "sell nothing"
'   val("40abc") is 40    -- trailing rubbish is ignored rather than refused
'   val("1,000") is 1     -- it stops at the separator
'
' The last one is this program's own fault: the panels print money as $8,160,
' so typing it back with the comma is the natural thing to do, and it would
' have quietly become 1. Separators and spaces are stripped, and then every
' character left has to be a digit.
function Amount(e#) local t$, c$, i, clean$
  t$ = trim$(edit_text$(e#))
  if len(t$) = 0 then return 0

  clean$ = ""
  for i = 0 to len(t$) - 1
    c$ = mid$(t$, i, 1)
    if c$ = "," then c$ = ""
    if c$ = "." then c$ = ""
    if c$ = " " then c$ = ""
    if c$ = "$" then c$ = ""
    clean$ = clean$ + c$
  next i
  if len(clean$) = 0 then return -1

  for i = 0 to len(clean$) - 1
    c$ = mid$(clean$, i, 1)
    if instr("0123456789", c$) < 0 then return -1
  next i
  return cint(val(clean$))
end function

function Refuse(why$)
  Say("REFUSED, nothing changed: " + why$)
  Projection("This plan cannot run: " + why$, BAD$)
  Refresh()
  return 0
end function

' Answers why a plan cannot be carried out, or "" when it can.
'
' NOTHING IS APPLIED HERE. The first version of Commit mutated the colony as
' it validated, so a plan whose food budget was refused had already sold the
' ore -- the chronicle said "sold 400 tons" and "REFUSED" one after the other,
' and the panels still showed the ore. Four decisions entered together are one
' plan, and half a plan is not a smaller plan.
'
' The money is walked forward exactly as the 1982 listing walks it, because the
' order is the rule: ore money pays for food, and food money not spent buys
' mines.
function Why$(cs, ls, fb, lb) local money, ore, mines
  money = M
  ore = C
  mines = L

  if cs > ore then return "you only have " + str$(cint(ore)) + " tons of ore."
  ore = ore - cs
  money = money + cs * CP

  if ls > mines then return "you only have " + str$(cint(mines)) + " mines."
  mines = mines - ls
  money = money + ls * LP

  if fb > money then return "food would cost " + Money$(fb) + " and the plan leaves " + Money$(money) + "."
  money = money - fb

  if lb * LP > money then return str$(lb) + Mines$(lb) + " cost " + Money$(lb * LP) + " and the plan leaves " + Money$(money) + "."
  return ""
end function

' The same walk again, for the line under the fields. Answers the state a plan
' would leave, packed as text, and says nothing about whether it is allowed --
' Why$ is what refuses.
function Preview(sender#) local cs, ls, fb, lb, money, ore, mines, perHead, refusal$
  if OVER = 1 then
    label_text#(lblPrev#, "")
    return 0
  end if
  cs = Amount(edSell#)
  ls = Amount(edMSell#)
  fb = Amount(edFood#)
  lb = Amount(edBuy#)
  if cs < 0 then return Projection("one of the four is not a whole number", BAD$)
  if ls < 0 then return Projection("one of the four is not a whole number", BAD$)
  if fb < 0 then return Projection("one of the four is not a whole number", BAD$)
  if lb < 0 then return Projection("one of the four is not a whole number", BAD$)

  refusal$ = Why$(cs, ls, fb, lb)
  if len(refusal$) > 0 then return Projection("This plan cannot run: " + refusal$, BAD$)

  money = M + cs * CP + ls * LP - fb - lb * LP
  ore = C - cs
  mines = L - ls + lb
  perHead = 0
  if P > 0 then perHead = fb / P
  return Projection("This plan leaves " + Money$(money) + ", " + str$(cint(ore)) + " tons and " + str$(cint(mines)) + " mines, feeding at " + Money$(perHead) + " a head.", ACCENT$)
end function

function Projection(t$, col$)
  label_fontcolor#(lblPrev#, col$)
  label_text#(lblPrev#, t$)
  return 0
end function

function Commit(sender#) local cs, ls, fb, lb, perHead, refusal$
  if OVER = 1 then
    NewGame()
    return 0
  end if

  cs = Amount(edSell#)
  ls = Amount(edMSell#)
  fb = Amount(edFood#)
  lb = Amount(edBuy#)

  if cs < 0 then return Refuse("the ore to sell must be a whole number of tons.")
  if ls < 0 then return Refuse("the mines to sell must be a whole number.")
  if fb < 0 then return Refuse("the food budget must be a whole number of dollars.")
  if lb < 0 then return Refuse("the mines to buy must be a whole number.")

  refusal$ = Why$(cs, ls, fb, lb)
  if len(refusal$) > 0 then return Refuse(refusal$)

  ' Only now, with the whole plan known to hold.
  WASP = P
  WASL = L
  WASM = M
  WASC = C
  WASCE = CE
  SHOWDELTA = 1

  C = C - cs
  M = M + cs * CP
  if cs > 0 then Say("Sold " + str$(cs) + " tons for " + Money$(cs * CP) + ".")

  L = L - ls
  M = M + ls * LP
  if ls > 0 then Say("Sold " + str$(ls) + Mines$(ls) + " for " + Money$(ls * LP) + ".")

  M = M - fb
  perHead = 0
  if P > 0 then perHead = fb / P
  Say("Spent " + Money$(fb) + " on food, " + Money$(perHead) + " a head.")
  if perHead > 120 then S = S + 0.1
  if perHead < 80 then S = S - 0.2

  L = L + lb
  M = M - lb * LP
  if lb > 0 then Say("Bought " + str$(lb) + Mines$(lb) + " for " + Money$(lb * LP) + ".")

  Resolve()
  return 0
end function

' ============================================================
'  WHAT THE COLONY DOES BACK
' ============================================================

function Resolve() local d
  if S < 0.6 then return Finish("THE PEOPLE REVOLTED", "You were driven off Astron in year " + str$(cint(Y)) + ".")

  if S > 1.1 then
    d = cint(rnd() * 20 + 1)
    CE = CE + d
    Say("Well fed, the crews cut " + str$(d) + " more tons per mine.")
  end if
  if S < 0.9 then
    d = cint(rnd() * 20 + 1)
    CE = CE - d
    if CE < 0 then CE = 0
    Say("Hungry crews cut " + str$(d) + " tons less per mine.")
  end if

  ' Selling the last mine is a way to lose, not an arithmetic error.
  if L < 1 then return Finish("NO MINES LEFT", "A mining colony with no mines is people on a rock.")
  if P / L < 10 then return Finish("YOU'VE OVERWORKED EVERYONE", "Fewer than ten people to a mine. The colony broke.")

  if S > 1.1 then
    d = cint(rnd() * 10 + 1)
    P = P + d
    Say(str$(d) + " settlers arrived.")
  end if
  if S < 0.9 then
    d = cint(rnd() * 10 + 1)
    P = P - d
    Say(str$(d) + " people left for better colonies.")
  end if

  if P < 30 then return Finish("NOT ENOUGH PEOPLE LEFT", "Under thirty souls. Astron was abandoned.")

  ' The population is NOT re-checked after this. Line 550 tests it before the
  ' leak and line 590 carries straight on, so a leak that leaves twenty people
  ' alive still buys you one more year of decisions -- the rule only catches up
  ' at the next year's test. An earlier draft added the check here and ended
  ' the game a year early, which is a different game.
  if rnd() <= 0.01 then
    P = cint(P / 2)
    Say("RADIOACTIVE LEAK. Many die. " + str$(cint(P)) + " remain.")
  end if

  ' Line 600 prints "MARKET GLUT - PRICE DROPS" and line 610 then halves CE,
  ' which is the yield per mine, not the price. The message is reworded to say
  ' what the code does; the arithmetic is untouched.
  if CE >= 150 then
    CE = cint(CE / 2)
    Say("MARKET GLUT - the yield per mine is halved.")
  end if

  Y = Y + 1
  if Y > TERM then return Finish("YOU SURVIVED YOUR TERM OF OFFICE", "Ten years, " + str$(cint(P)) + " people, " + str$(cint(L)) + " mines and " + Money$(M) + " in hand.")

  NewYear()
  return 0
end function

function Finish(head$, tail$)
  OVER = 1
  Say("")
  Say("*** " + head$ + " ***")
  Say(tail$)
  Refresh()
  label_text#(lblYear#, head$)
  label_fontcolor#(lblYear#, GOLD$)
  label_text#(lblTerm#, tail$)
  button_text#(btnGo#, "PLAY AGAIN")
  return 0
end function

' ============================================================
'  THE FOUR BUILDERS
'
'  Each answers a handle, so each carries # on its name.
' ============================================================

' A signed figure, green up and red down, or nothing at all before the first
' year has been committed.
function PaintDelta(h#, d, money) local t$
  if SHOWDELTA = 0 then
    label_text#(h#, "")
    return 0
  end if
  if d = 0 then
    label_fontcolor#(h#, DIM$)
    label_text#(h#, "no change")
    return 0
  end if
  if money = 1 then
    t$ = Money$(abs(d))
  else
    t$ = str$(cint(abs(d)))
  end if
  if d > 0 then
    label_fontcolor#(h#, GOOD$)
    label_text#(h#, "+" + t$)
  else
    label_fontcolor#(h#, BAD$)
    label_text#(h#, "-" + t$)
  end if
  return 0
end function

function Delta#(x, y) local h#
  h# = label#(frm#, "", x, y, 190, 18)
  label_fontsize#(h#, 12)
  label_bold#(h#, 1)
  label_textalign#(h#, 2)
  return h#
end function

function Card#(x, y, w, h) local r#
  r# = rectangle#(frm#, x, y, w, h)
  rectangle_fill#(r#, PANEL$)
  rectangle_stroke#(r#, EDGE$)
  rectangle_xradius#(r#, 10)
  rectangle_yradius#(r#, 10)
  return r#
end function

function Heading#(x, y, t$) local h#
  h# = label#(frm#, t$, x, y, 320, 22)
  label_fontsize#(h#, 13)
  label_bold#(h#, 1)
  label_fontcolor#(h#, DIM$)
  return h#
end function

function Caption#(x, y, t$) local h#
  h# = label#(frm#, t$, x, y, 200, 18)
  label_fontsize#(h#, 12)
  label_fontcolor#(h#, DIM$)
  return h#
end function

function Figure#(x, y) local h#
  h# = label#(frm#, "", x, y, 200, 34)
  label_fontsize#(h#, 24)
  label_bold#(h#, 1)
  label_fontcolor#(h#, INK$)
  return h#
end function

' ============================================================
'  GO
' ============================================================

button_onclick#(btnGo#, "Commit")

' Every keystroke in any of the four fields redraws the projection, so the
' consequence of a plan is on screen before the year is committed.
edit_onchangetracking#(edSell#, "Preview")
edit_onchangetracking#(edMSell#, "Preview")
edit_onchangetracking#(edFood#, "Preview")
edit_onchangetracking#(edBuy#, "Preview")

form_show(frm#)
NewGame()
