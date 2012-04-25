local tween = require 'tween'

local fontSize = 80
local values = {alpha=0}

local sWidth, sHeight = love.graphics.getWidth(), love.graphics.getHeight()

function love.load()
  local font = love.graphics.newFont('fonts/Trocchi-Regular.ttf', fontSize)
  love.graphics.setFont(font)

  tween(3, values, {alpha=255})
end

function love.update(dt)
  tween.update(dt)
end

function love.draw()
  love.graphics.setColor(255, 255, 255, math.floor(values.alpha))
  love.graphics.printf("The Title", 0, sHeight/2 - fontSize-2, sWidth, 'center')
end


