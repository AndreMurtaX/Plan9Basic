rem ---------------------------------------------------------------
rem A control finds the engine it belongs to by walking up its parents
rem until it reaches the form, which is what holds it.
rem
rem Before this, every library kept a ModuleEngine unit variable that
rem RegisterXxxFuncs filled in once, and every constructor copied it into
rem the object. The engine was therefore per-process: a second one could
rem not exist beside the first.
rem
rem A callback firing is the observable proof -- it needs the engine to
rem run the BASIC function, and it can only have got it from the form.
rem ---------------------------------------------------------------

fired = 0

f# = form#()

test_case("engine/found-through-the-parent")
b# = button#(f#)
p# = button_onclick#(b#, "onFire")
assert_eq(button_error(), 0, "a callback binds on a control one level down")

test_case("engine/found-through-two-levels")
rem A control inside a panel is two steps from the form, and the walk has
rem to keep going rather than stopping at the first parent.
pn# = panel#(f#)
inner# = button#(pn#)
p# = button_onclick#(inner#, "onFire")
assert_eq(button_error(), 0, "and on one two levels down")

test_case("engine/animation-uses-its-target")
rem An animation is a TComponent with no Parent of its own, so it asks the
rem control it animates instead.
r# = rectangle#(f#)
a# = floatani#(r#)
assert_eq(floatani_error(), 0, "an animation reaches the engine through its target")

function onFire(sender#)
  fired = fired + 1
  return 0
end function
