local ease = {}

local TAU = math.pi * 2
local B1 = 1 / 2.75
local B2 = 2 / 2.75
local B3 = 1.5 / 2.75
local B4 = 2.5 / 2.75
local B5 = 2.25 / 2.75
local B6 = 2.625 / 2.75

function ease.quadIn(t)
  return t * t
end

function ease.quadOut(t)
  return -t * (t - 2)
end

function ease.quadInOut(t)
  if t <= .5 then
    return t * t * 2
  else
    t = t - 1
    return 1 - t * t * 2
  end
end

function ease.cubeIn(t)
  return t * t * t
end

function ease.cubeOut(t)
  t = t - 1
  return 1 + t * t * t
end

function ease.cubeInOut(t)
  if t <= .5 then
    return t * t * t * 4
  else
    t = t - 1
    return 1 + t * t * t * 4
  end
end

function ease.quartIn(t)
  return t * t * t * t
end

function ease.quartOut(t)
  t = t - 1
  return 1 - t * t * t * t
end

function ease.quartInOut(t)
  if t <= .5 then
    return t * t * t * t * 8
  else
    t = t * 2 - 2
    return (1 - t * t * t * t) / 2 + .5
  end
end

function ease.quintIn(t)
  return t * t * t * t * t
end

function ease.quintOut(t)
  t = t - 1
  return t * t * t * t * t + 1
end

function ease.quintInOut(t)
  t = t * 2
  if t < 1 then
    return (t * t * t * t * t) / 2
  else
    t = t - 2
    return (t * t * t * t * t + 2) / 2
  end
end

function ease.sineIn(t)
  return -math.cos(TAU / 4 * t) + 1
end

function ease.sineOut(t)
  return math.sin(TAU / 4 * t)
end

function ease.sineInOut(t)
  return -math.cos(math.pi * t) / 2 + .5
end

function ease.bounceIn(t)
  t = 1 - t
  if t < B1 then return 1 - 7.5625 * t * t end
  if t < B2 then return 1 - (7.5625 * (t - B3) * (t - B3) + .75) end
  if t < B4 then return 1 - (7.5625 * (t - B5) * (t - B5) + .9375) end
  return 1 - (7.5625 * (t - B6) * (t - B6) + .984375)
end

function ease.bounceOut(t)
  if t < B1 then return 7.5625 * t * t end
  if t < B2 then return 7.5625 * (t - B3) * (t - B3) + .75 end
  if t < B4 then return 7.5625 * (t - B5) * (t - B5) + .9375 end
  return 7.5625 * (t - B6) * (t - B6) + .984375
end

function ease.bounceInOut(t)
  if t < .5 then
    t = 1 - t * 2
    if t < B1 then return (1 - 7.5625 * t * t) / 2 end
    if t < B2 then return (1 - (7.5625 * (t - B3) * (t - B3) + .75)) / 2 end
    if t < B4 then return (1 - (7.5625 * (t - B5) * (t - B5) + .9375)) / 2 end
    return (1 - (7.5625 * (t - B6) * (t - B6) + .984375)) / 2
  else
    t = t * 2 - 1
    if t < B1 then return (7.5625 * t * t) / 2 + .5 end
    if t < B2 then return (7.5625 * (t - B3) * (t - B3) + .75) / 2 + .5 end
    if t < B4 then return (7.5625 * (t - B5) * (t - B5) + .9375) / 2 + .5 end
    return (7.5625 * (t - B6) * (t - B6) + .984375) / 2 + .5
  end
end

function ease.circIn(t)
  return -(math.sqrt(1 - t * t) - 1)
end

function ease.circOut(t)
  return math.sqrt(1 - (t - 1) * (t - 1))
end

function ease.circInOut(t)
  if t <= .5 then
    return (math.sqrt(1 - t * t * 4) - 1) / -2
  else
    return (math.sqrt(1 - (t * 2 - 2) * (t * 2 - 2)) + 1) / 2
  end
end

function ease.expoIn(t)
  return math.pow(2, 10 * (t - 1))
end

function ease.expoOut(t)
  return -math.pow(2, -10 * t) + 1
end

function ease.expoInOut(t)
  if t < .5 then
    return math.pow(2, 10 * (t * 2 - 1)) / 2
  else
    return (-math.pow(2, -10 * (t * 2 - 1)) + 2) / 2
  end
end

function ease.backIn(t)
  return t * t * (2.70158 * t - 1.70158)
end

function ease.backOut(t)
  t = t - 1
  return 1 - t * t * (-2.70158 * t - 1.70158)
end

function ease.backInOut(t)
  t = t * 2
  if t < 1 then return t * t * (2.70158 * t - 1.70158) / 2 end
  t = t - 2
  return (1 - t * t * (-2.70158 * t - 1.70158)) / 2 + .5
end

return ease
