-----------------------------------------------------------------------------------------------------------------------
-- tween.lua - v0.1 (2011-05)
-- Enrique García Cota - enrique.garcia.cota [AT] gmail [DOT] com
-- tweening functions for lua
-- inspired by jquery's animate function
-----------------------------------------------------------------------------------------------------------------------

local tween = {}

local tweens = setmetatable({}, {__mode = "k"})

local function isCallable(f)
  local tf = type(f)
  if tf == 'function' then return true end
  if tf == 'table' then
    local mt = getmetatable(f)
    return type(mt) == 'table' and type(mt.__call) == 'function'
  end
  return false
end

local function checkStartParams(time, subject, target, easing, callback)
  assert(type(time) == 'number' and time > 0, "time must be a positive number.")
  assert(type(subject) == 'table', "subject must be a table.")
  assert(type(target)== 'table', "target must be a table.")
  assert(isCallable(easing), "easing must be a function or functable.")
  assert(callback==nil or isCallable(callback), "callback must be nil, a function or functable.")

  for k,v in pairs(target) do
    assert(type(v) == 'number', "Parameter '" .. k .. "' must be a number")
    local sk = subject[k]
    assert(type(sk) == 'number', "Parameter '" .. k .. "' not found on subject, or incorrect type found")
  end
end

local function getEasing(easing)
  easing = easing or "linear"
  if type(easing) == 'string' then
    assert(type(tween.easing[easing]) == 'function', "The easing function name '" .. easing .. "' is invalid")
    easing = tween.easing[easing]
  end
  return easing
end

local function copyTables(destination, keysTable, valuesTable)
  for k,_ in pairs(keysTable) do destination[k] = valuesTable[k] end
  return destination
end

local function newTween(time, subject, target, easing, callback, args)
  local self = { time = time, subject = subject, target = target, easing = easing, callback = callback, args = args }
  self.initial = copyTables({}, target, subject)
  self.running = 0
  tweens[self] = self
  return self
end

local function performEasing(self)
  local t,b,c,d
  for k,v in pairs(self.target) do
    t,b,c,d = self.running, self.initial[k], v - self.initial[k], self.time
    self.subject[k] = self.easing(t,b,c,d)
  end
end

local function updateTween(self, dt)
  self.running = self.running + dt

  if self.running >= self.time then
    copyTables(self.subject, self.target, self.target)
    if self.callback then self.callback(unpack(self.args)) end
    return true
  end

  performEasing(self)
  return false
end


-- public functions

function tween.start(time, subject, target, easing, callback, ...)
  easing = getEasing(easing)
  checkStartParams(time, subject, target, easing, callback)
  return newTween(time, subject, target, easing, callback, {...})
end

setmetatable(tween, { __call = function(t, ...) tween.start(...) end })

function tween.reset(id)
  if id == nil then
    tweens = setmetatable({}, {__mode = "k"})
  else
    tweens[id] = nil
  end
end

function tween.update(dt)
  assert(type(dt) == 'number' and dt > 0, "dt must be a positive number")
  local expired = {}
  for _,t in pairs(tweens) do
    if updateTween(t, dt) then table.insert(expired, t) end
  end
  for i=1, #expired do tweens[expired[i]] = nil end
end

-- easing

-- Adapted from https://github.com/EmmanuelOga/easing. See LICENSE.txt for credits.
-- For all easing functions:
-- t = time
-- b = begin
-- c = change == ending - beginning
-- d = duration

local pow, sin, cos, pi, sqrt, abs, asin = math.pow, math.sin, math.cos, math.pi, math.sqrt, math.abs, math.asin

tween.easing = {
  linear = function(t, b, c, d) return c * t / d + b end,
  inQuad = function(t, b, c, d) return c * pow(t / d, 2) + b end,
  outQuad = function(t, b, c, d)
    t = t / d
    return -c * t * (t - 2) + b
  end,
  inOutQuad = function(t, b, c, d)
    t = t / d * 2
    if t < 1 then return c / 2 * pow(t, 2) + b end
    return -c / 2 * ((t - 1) * (t - 3) - 1) + b
  end,
  inCubic  = function(t, b, c, d) return c * pow(t / d, 3) + b end,
  outCubic = function(t, b, c, d) return c * (pow(t / d - 1, 3) + 1) + b end,
  inOutCubic = function(t, b, c, d)
    t = t / d * 2
    if t < 1 then return c / 2 * t * t * t + b end
    t = t - 2
    return c / 2 * (t * t * t + 2) + b
  end,
  outInCubic = function(t, b, c, d)
    if t < d / 2 then return tween.easing.outCubic(t * 2, b, c / 2, d) end
    return tween.easing.inCubic((t * 2) - d, b + c / 2, c / 2, d)
  end,
  inQuart = function(t, b, c, d) return c * pow(t / d, 4) + b end,
  outQuart = function(t, b, c, d) return -c * (pow(t / d - 1, 4) - 1) + b end,
  inOutQuart = function(t, b, c, d)
    t = t / d * 2
    if t < 1 then return c / 2 * pow(t, 4) + b end
    return -c / 2 * (pow(t - 2, 4) - 2) + b
  end,
  outInQuart = function(t, b, c, d)
    if t < d / 2 then return tween.easing.outQuart(t * 2, b, c / 2, d) end
    return tween.easing.inQuart((t * 2) - d, b + c / 2, c / 2, d)
  end,
  inQuint = function(t, b, c, d) return c * pow(t / d, 5) + b end,
  outQuint = function(t, b, c, d) return c * (pow(t / d - 1, 5) + 1) + b end,
  inOutQuint = function(t, b, c, d)
    t = t / d * 2
    if t < 1 then return c / 2 * pow(t, 5) + b end
    return c / 2 * (pow(t - 2, 5) + 2) + b
  end,
  outInQuint = function(t, b, c, d)
    if t < d / 2 then return tween.easing.outQuint(t * 2, b, c / 2, d) end
    return tween.easing.inQuint((t * 2) - d, b + c / 2, c / 2, d)
  end,
  inSine = function(t, b, c, d) return -c * cos(t / d * (pi / 2)) + c + b end,
  outSine = function(t, b, c, d) return c * sin(t / d * (pi / 2)) + b end,
  inOutSine = function(t, b, c, d) return -c / 2 * (cos(pi * t / d) - 1) + b end,
  outInSine = function(t, b, c, d)
    if t < d / 2 then return tween.easing.outSine(t * 2, b, c / 2, d) end
    return tween.easing.inSine((t * 2) -d, b + c / 2, c / 2, d)
  end,
  inExpo = function(t, b, c, d)
    if t == 0 then return b end
    return c * pow(2, 10 * (t / d - 1)) + b - c * 0.001
  end,
  outExpo = function(t, b, c, d)
    if t == d then return b + c end
    return c * 1.001 * (-pow(2, -10 * t / d) + 1) + b
  end,
  inOutExpo = function(t, b, c, d)
    if t == 0 then return b end
    if t == d then return b + c end
    t = t / d * 2
    if t < 1 then return c / 2 * pow(2, 10 * (t - 1)) + b - c * 0.0005 end
    return c / 2 * 1.0005 * (-pow(2, -10 * (t - 1)) + 2) + b
  end,
  outInExpo = function(t, b, c, d)
    if t < d / 2 then return tween.easing.outExpo(t * 2, b, c / 2, d) end
    return tween.easing.inExpo((t * 2) - d, b + c / 2, c / 2, d)
  end,
  inCirc = function(t, b, c, d) return(-c * (sqrt(1 - pow(t / d, 2)) - 1) + b) end,
  outCirc = function(t, b, c, d)  return(c * sqrt(1 - pow(t / d - 1, 2)) + b) end,
  inOutCirc = function(t, b, c, d)
    t = t / d * 2
    if t < 1 then return -c / 2 * (sqrt(1 - t * t) - 1) + b end
    t = t - 2
    return c / 2 * (sqrt(1 - t * t) + 1) + b
  end,
  outInCirc = function(t, b, c, d)
    if t < d / 2 then return tween.easing.outCirc(t * 2, b, c / 2, d) end
    return tween.easing.inCirc((t * 2) - d, b + c / 2, c / 2, d)
  end,
  inElastic = function(t, b, c, d, a, p)
    if t == 0 then return b end
    t = t / d
    if t == 1  then return b + c end
    p, a = p or d * 0.3, a or 0
    local s
    if a < abs(c) then
      a = c
      s = p / 4
    else
      s = p / (2 * pi) * asin(c/a)
    end
    t = t - 1
    return -(a * pow(2, 10 * t) * sin((t * d - s) * (2 * pi) / p)) + b
  end,
  outElastic = function(t, b, c, d, a, p)
    if t == 0 then return b end
    t = t / d
    if t == 1 then return b + c end
    p, a = p or d * 0.3, a or 0
    local s
    if a < abs(c) then
      a, s = c, p / 4
    else
      s = p / (2 * pi) * asin(c/a)
    end
    return a * pow(2, -10 * t) * sin((t * d - s) * (2 * pi) / p) + c + b
  end,
  inOutElastic = function(t, b, c, d, a, p)
    if t == 0 then return b end
    t = t / d * 2
    if t == 2 then return b + c end
    p, a = p or d * 0.3, a or 0
    local s
    if a < abs(c) then
      a, s = c, p / 4
    else
      s = p / (2 * pi) * asin(c / a)
    end
    t = t - 1
    if t < 0 then return -0.5 * (a * pow(2, 10 * t) * sin((t * d - s) * (2 * pi) / p)) + b end
    return a * pow(2, -10 * t) * sin((t * d - s) * (2 * pi) / p ) * 0.5 + c + b
  end,
  outInElastic = function(t, b, c, d, a, p)
    if t < d / 2 then return tween.easing.outElastic(t * 2, b, c / 2, d, a, p) end
    return tween.easing.inElastic((t * 2) - d, b + c / 2, c / 2, d, a, p)
  end,
  inBack = function(t, b, c, d, s)
    s = s or 1.70158
    t = t / d
    return c * t * t * ((s + 1) * t - s) + b
  end,
  outBack = function(t, b, c, d, s)
    s = s or 1.70158
    t = t / d - 1
    return c * (t * t * ((s + 1) * t + s) + 1) + b
  end,
  inOutBack = function(t, b, c, d, s)
    s = (s or 1.70158) * 1.525
    t = t / d * 2
    if t < 1 then return c / 2 * (t * t * ((s + 1) * t - s)) + b end
    t = t - 2
    return c / 2 * (t * t * ((s + 1) * t + s) + 2) + b
  end,
  outInBack = function(t, b, c, d, s)
    if t < d / 2 then return tween.easing.outBack(t * 2, b, c / 2, d, s) end
    return tween.easing.inBack((t * 2) - d, b + c / 2, c / 2, d, s)
  end,
  outBounce = function(t, b, c, d)
    t = t / d
    if t < 1 / 2.75 then return c * (7.5625 * t * t) + b end
    if t < 2 / 2.75 then
      t = t - (1.5 / 2.75)
      return c * (7.5625 * t * t + 0.75) + b
    elseif t < 2.5 / 2.75 then
      t = t - (2.25 / 2.75)
      return c * (7.5625 * t * t + 0.9375) + b
    end
    t = t - (2.625 / 2.75)
    return c * (7.5625 * t * t + 0.984375) + b
  end,
  inBounce = function(t, b, c, d)
    return c - tween.easing.outBounce(d - t, 0, c, d) + b
  end,
  inOutBounce = function(t, b, c, d)
    if t < d / 2 then return tween.easing.inBounce(t * 2, 0, c, d) * 0.5 + b end
    return tween.easing.outBounce(t * 2 - d, 0, c, d) * 0.5 + c * .5 + b
  end,
  outInBounce = function(t, b, c, d)
    if t < d / 2 then return tween.easing.outBounce(t * 2, b, c / 2, d) end
    return tween.easing.inBounce((t * 2) - d, b + c / 2, c / 2, d)
  end
}
return tween

