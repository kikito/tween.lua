tween = require 'tween'

function love.update(dt)
  tween.update(dt)
end


local label = { text = "Tween!", x = 200, y = -10 }
local box = { x = 0, y = 300, color = { 0, 255, 255 }, width = 64, height = 64 }
local lights = { {0,0,0}, {0,0,0}, {0,0,0} }

function love.load()
  -- some useful colors.
  -- You can use it on the target, but not on the subject! Otherwise they'll be re-written
  local black,white = {0,0,0},{255,255,255}
  local red,amber,green = {255,0,0},{255,200,0},{0,255,0}
  local cyan,magenta = {0,255,255},{255,0,255}

  --text "falls down" from the top of the screen
  tween(3, label, { y = 300 }, 'outBounce')

  -- box
  -- * Move from left to right, then fall down bouncing, then move to left, then up
  -- * Doubles its width and height while moving to the right, halves it while moving to the left
  -- * Changes color when moving from left to right
  tween( 3, box, { x = 672, color = white, width = 128, height = 128 }, 'inOutQuad',
         tween, 1, box, { y = 470, color = magenta }, 'inOutSine',
         tween, 2, box, { x = 190, y = 534, color = cyan, width = 64, height = 64 }, 'inOutExpo',
         tween, 2, box, { y = 320 }, 'inOutBack')

  -- traffic light
  -- * change colors infinitely
  local greenLight, amberLight, redLight
  greenLight = function() tween(2, lights, { black, black, green }, 'linear', redLight) end
  amberLight = function() tween(2, lights, { black, amber, black }, 'linear', greenLight) end
  redLight   = function() tween(2, lights, { red,   black, black }, 'linear', amberLight) end

  redLight()
end

function love.draw()
  love.graphics.setColor(255, 255, 255)
  love.graphics.print(label.text, label.x, label.y)

  love.graphics.setColor(unpack(box.color))
  love.graphics.rectangle('fill', box.x, box.y, box.width, box.height)

  love.graphics.setColor(unpack(lights[1]))
  love.graphics.circle('fill', 600, 30, 20, 100)
  love.graphics.setColor(unpack(lights[2]))
  love.graphics.circle('fill', 650, 30, 20, 100)
  love.graphics.setColor(unpack(lights[3]))
  love.graphics.circle('fill', 700, 30, 20, 100)
end


