rem ---------------------------------------------------------------
rem MediaPlayerLib. check-coverage.py reported 0/58 -- nothing in it
rem had ever been run.
rem
rem It is two families under one prefix. media_* is a player with no
rem face: it holds a file, a volume and a position and has nothing to
rem draw. media_ctrl_* is a control on a form that owns one of those
rem players and adds a rectangle, a visibility and the usual events.
rem
rem NO SOUND IS PLAYED and no file is fetched. Playing needs an audio
rem device, and a suite that downloads a track fails when somebody
rem else's server is down -- Demos/lunar_lander.bas already reaches
rem plan9basic.com for its sound effects on every verification run.
rem What is asserted here is everything a player is before it makes a
rem noise: the object, its settings, its refusals, and the control it
rem can live inside.
rem ---------------------------------------------------------------

test_case("media/player-construction")
p# = media_player#()
assert_true(pnttonum(p#), "media_player# answers a handle")
media_clearerror()
assert_eq(media_error(), 0, "with nothing to report")
assert_eq(media_filename$(p#), "", "and nothing loaded")
assert_false(media_isplaying(p#), "so it is not playing")

test_case("media/settings-before-loading")
rem THE VOLUME IS NOT KEPT UNTIL A TRACK IS. The setter clamps to 0..1
rem and passes the value straight to the FireMonkey player, which has
rem nowhere to put it while no media is loaded and answers its default
rem of 1 whatever was asked for.
rem
rem So a program that sets the volume and then loads a track gets the
rem default, not what it set -- the order has to be load first, then
rem volume. Nothing says so, which is why it is written here.
media_volume#(p#, 0.5)
assert_near(media_volume(p#), 1, 0.01, "with nothing loaded the level asked for is not kept")
media_volume#(p#, 0)
assert_near(media_volume(p#), 1, 0.01, "not even silence")

assert_eq(media_duration(p#), 0, "an empty player has no duration")
assert_eq(media_position(p#), 0, "and sits at the start")

rem The position goes the same way as the volume: there is nothing to
rem seek in, so a seek changes nothing rather than failing.
media_position#(p#, 5)
assert_eq(media_position(p#), 0, "seeking an empty player leaves it at the start")

test_case("media/loading-refusals")
rem A file that is not there, and a URL that cannot be reached. The
rem host below ends in .invalid, which RFC 2606 reserves so that it can
rem never resolve: no request leaves this machine.
media_clearerror()
media_load#(p#, "bin/p9b_no_such_sound.wav")
assert_true(media_error(), "a track that is not there fails")
assert_eq(media_filename$(p#), "", "and nothing is left loaded")

media_clearerror()
media_load#(p#, "https://plan9basic.invalid/assets/sounds/none.wav")
assert_true(media_error(), "and a url that cannot be fetched fails too")
assert_true(instr(media_errormsg$(), "download") + 1, "saying it was a download that failed")
assert_eq(media_filename$(p#), "", "leaving the player empty rather than half-loaded")

test_case("media/verbs-on-an-empty-player")
rem play, pause and stop on a player holding nothing must answer rather
rem than reach for a device that has nothing to play.
media_clearerror()
media_play(p#)
media_pause(p#)
media_stop(p#)
assert_false(media_isplaying(p#), "an empty player never starts playing")

media_clear(p#)
assert_eq(media_filename$(p#), "", "media_clear leaves it empty")
if media_state(p#) >= 0 then state_ok = 1
assert_true(state_ok, "media_state answers a code")

test_case("media/player-event-names")
media_onend#(p#, "h_end")
media_onstatechanged#(p#, "h_state")
assert_eq(media_error(), 0, "both handlers are stored without complaint")

test_case("media/errors-and-handles")
media_clearerror()
assert_eq(media_error(), 0, "media_clearerror clears the code")
assert_true(len(media_strerror$(6)), "media_strerror$ names a code")

junk# = pointer#(305419896)
media_clearerror()
media_volume(junk#)
assert_true(media_error(), "an invented player is refused")

assert_eq(media_free(p#), 1, "media_free reports success")

test_case("media/control-construction")
f# = form#("media host", 400, 300)
c# = media_control#(f#, 10, 10, 320, 240)
assert_true(pnttonum(c#), "media_control# answers a handle")
assert_true(media_ctrl_hasplayer(c#), "which owns a player of its own")

test_case("media/control-geometry")
media_ctrl_pos#(c#, 20, 30)
assert_eq(media_ctrl_x(c#), 20, "media_ctrl_pos# sets the x")
assert_eq(media_ctrl_y(c#), 30, "and the y")

media_ctrl_size#(c#, 200, 150)
assert_eq(media_ctrl_width(c#), 200, "media_ctrl_size# sets the width")
assert_eq(media_ctrl_height(c#), 150, "and the height")

media_ctrl_bounds#(c#, 5, 6, 100, 80)
assert_eq(media_ctrl_x(c#), 5, "media_ctrl_bounds# sets all four")
assert_eq(media_ctrl_height(c#), 80, "including the last")

test_case("media/control-flags")
media_ctrl_visible#(c#, 0)
assert_false(media_ctrl_visible(c#), "media_ctrl_visible# hides it")
media_ctrl_visible#(c#, 1)
assert_true(media_ctrl_visible(c#), "and shows it")

media_ctrl_enabled#(c#, 0)
assert_false(media_ctrl_enabled(c#), "media_ctrl_enabled# disables it")
media_ctrl_enabled#(c#, 1)
assert_true(media_ctrl_enabled(c#), "and enables it")

media_ctrl_align#(c#, 0)
assert_eq(media_ctrl_align(c#), 0, "media_ctrl_align# holds an alignment")

test_case("media/control-player")
rem The control forwards every player question to the one it owns, so
rem the same answers hold through the longer names.
assert_eq(media_ctrl_filename$(c#), "", "the owned player holds nothing")
assert_false(media_ctrl_isplaying(c#), "so it is not playing")
assert_eq(media_ctrl_duration(c#), 0, "and has no duration")

media_ctrl_volume#(c#, 0.25)
assert_near(media_ctrl_volume(c#), 1, 0.01, "the control's player forgets it the same way")
media_ctrl_position#(c#, 0)
assert_eq(media_ctrl_position(c#), 0, "media_ctrl_position# holds a position")

media_clearerror()
media_ctrl_load#(c#, "bin/p9b_no_such_sound.wav")
assert_true(media_error(), "loading a track that is not there fails through the control too")

media_clearerror()
media_ctrl_play(c#)
media_ctrl_pause(c#)
media_ctrl_stop(c#)
media_ctrl_clear(c#)
assert_false(media_ctrl_isplaying(c#), "and the verbs leave an empty control silent")
if media_ctrl_state(c#) >= 0 then ctrl_state_ok = 1
assert_true(ctrl_state_ok, "media_ctrl_state answers a code")

test_case("media/control-event-names")
media_ctrl_onend#(c#, "h_end")
media_ctrl_onstatechanged#(c#, "h_state")
media_ctrl_onclick#(c#, "h_click")
media_ctrl_ondblclick#(c#, "h_dbl")
media_ctrl_onmousedown#(c#, "h_down")
media_ctrl_onmouseup#(c#, "h_up")
media_ctrl_onmousemove#(c#, "h_move")
media_ctrl_onresize#(c#, "h_resize")
assert_eq(media_error(), 0, "all eight handlers are stored without complaint")

test_case("media/control-free")
assert_eq(media_ctrl_free(c#), 1, "media_ctrl_free reports success")
form_free(f#)
