# v2.1.1

* Fixes an error where you could not call `:set` inmediately after creating a tween, without calling `:update` first.

# v2.1.0

* The tweens now initialize the value of the subject on the first call to `:update` instead of when the tween is created.
  This allows creating several tweens which act on the same subject, and apply one after the other when the previous one completes.
  (Issue #14)

# v2.0.0:

* the library no longer has "an internal list of tweens". Instead, `tween.new` returns an individual tween, which
  must be updated individually with `t:update(dt)`
* tweens can go forwards and backwards (trying to set the internal clock to a negative number makes it zero)

