-----------------------------------------------------------------------------------------------------------------------
-- tween.lua - v0.1 (2011-05)
-- Enrique García Cota - enrique.garcia.cota [AT] gmail [DOT] com
-- tweening functions for lua
-- inspired by jquery's animate function
-----------------------------------------------------------------------------------------------------------------------


local tween = {}


tween.start = function(time, subject, target, easing, callback, ...)
  assert(type(time) == 'number' and time > 0, "time must be a positive number")
  assert(type(subject) == 'table', "subject must be a table")
  assert(type(target) == 'table', "subject must be a table")

  easing = easing or "linear"
  if type(easing) == 'string' then
    assert(type(tween.easing[easing]) == 'function', "The easing function name '" .. easing .. "' is invalid")
    easing = tween.easing[easing]
  end

  assert(type(easing) == 'function', "Easing must be a valid function or easing function name")

  for k,v in pairs(target) do
    assert(type(v) == 'number', "Parameter '" .. k .. "' must be a number")
    local sk = subject[k]
    assert(type(sk) == 'number', "Paramter '" .. k .. "' not found on subject, or incorrect type found")
  end

  return true
end

tween.easing = {}

tween.easing.linear = function()
end

return tween

