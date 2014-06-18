local tween = require 'tween'

local families = { "Quad", "Cubic", "Quart", "Quint", "Expo", "Sine", "Circ", "Back", "Bounce", "Elastic" }
local variants = { "in", "out", "inOut", "outIn"}
local allVariants = { "linear", "in", "out", "inOut", "outIn"}
local variantColors = {
  ['linear'] = {61,153,112},
  ['in']     = {255,65,54},
  ['out']    = {0,116,217},
  ['inOut']  = {117,13,201},
  ['outIn']  = {255,133,27}
}


local easingNames, len = { "linear" }, 1

for _,f in ipairs(families) do
  for _,v in ipairs(variants) do
    len = len + 1
    easingNames[len] = v .. f
  end
end

local easingValues = {}

local screen_w, screen_h = love.graphics.getDimensions()

local drawEasing = function(l,t,w,h, values, color)
  local x_unit = w/#values

  local points = {}
  local x,y

  for i=1, #values do
    x = l + x_unit * i
    y = t + h - (h * values[i])
    points[i*2-1] = x
    points[i*2]   = y
  end

  love.graphics.setColor(color)
  love.graphics.setLineWidth(2)
  love.graphics.line(points)
end


local drawGraph = function(l,t,w,h, family)
  if family == 'Linear' then
    drawEasing(l,t,w,h, easingValues.linear, variantColors.linear)
  else
    for _,v in ipairs(variants) do
      drawEasing(l,t,w,h, easingValues[v..family], variantColors[v])
    end
  end
end

local font
local fontHeight = 16

local getGraphRect = function(index)
  local table_rows    = 3
  local table_columns = 4

  local x_margin = 10
  local y_margin = 35

  local table_w = screen_w - 2*x_margin
  local table_h = screen_h - 2*y_margin

  local cell_w = table_w / table_columns
  local cell_h = table_h / table_rows
  local cell_x = index % table_columns
  local cell_y = (index - cell_x) / table_columns
  local cell_l = x_margin + cell_x * cell_w
  local cell_t = y_margin + cell_y * cell_h

  local w = cell_w - 2*x_margin
  local h = cell_h - 2*y_margin
  local l = cell_l + x_margin
  local t = cell_t + y_margin

  return l,t,w,h
end

local drawFamily = function(index, family)

  local l,t,w,h = getGraphRect(index)

  love.graphics.setLineWidth(1)
  love.graphics.setColor(0,0,0)
  love.graphics.line(l+w, t+h, l, t+h)
  love.graphics.line(l,   t,   l, t+h)

  drawGraph(l, t, w, h, family)

  love.graphics.setColor(0,0,0)
  love.graphics.printf(family, l, t+h-fontHeight-5, w, 'right')
end

local drawVariantLegend = function(l,t,w,h, variant)

  local lineWidth = w * 0.15
  local lineMargin = w * 0.025

  love.graphics.setColor(variantColors[variant])
  love.graphics.setLineWidth(2)
  love.graphics.line(l+lineMargin, t+h/2, l+lineWidth, t+h/2)

  love.graphics.setColor(0,0,0)
  love.graphics.print(variant, l+lineWidth+2*lineMargin, t + h/2 - fontHeight/2)
end


local drawLegend = function()
  local gl,gt,gw,gh = getGraphRect(#families + 1)

  local h = gh / #allVariants

  for i,v in ipairs(allVariants) do
    drawVariantLegend(gl, gt + h*(i-1), gw, h, v)
  end
end


function love.load()
  font = love.graphics.newFont(fontHeight)

  local steps = 200
  local t, subject, values
  for _,easingName in ipairs(easingNames) do
    subject = {0}
    t       = tween.new(1, subject, {1}, easingName)
    values  = {0}

    for i=1, steps do
      t:update(1/steps)
      values[i+1] = subject[1]
    end

    easingValues[easingName] = values
  end
end

function love.draw()
  love.graphics.setFont(font)
  love.graphics.setColor(255,255,255)
  love.graphics.rectangle('fill', 0,0,screen_w, screen_h)
  drawFamily(0, 'Linear')
  for i,f in ipairs(families) do
    drawFamily(i, f)
  end
  drawLegend()
end

function love.keypressed()
  love.event.quit()
end
