local tween = require 'tween'

local balls = {}
local balls_final_radius = 8
local balls_rows         = 20
local balls_columns      = 20
local balls_final_color  = {255,255,255}

local duration = 10

local screen_w,screen_h = love.graphics.getDimensions()

local function get_keys(tbl)
  local keys,len = {},0
  for k in pairs(tbl) do
    len = len + 1
    keys[len] = k
  end
  return keys
end

local easing_keys = get_keys(tween.easing)

local function pad(x, min, max)
  return math.max(math.min(x, max), min)
end

local function get_ball_target(column, row)
  local x = screen_w/2 - balls_final_radius * balls_columns + balls_final_radius * column * 2
  local y = screen_h/2 - balls_final_radius * balls_rows    + balls_final_radius * row * 2

  return {x=x, y=y, radius = balls_final_radius}
end

local function create_ball(column, row)
  local ball = {
    radius = math.random(balls_final_radius / 2, balls_final_radius * 2),
    x = math.random(0, screen_w),
    y = math.random(0, screen_h),
    r = math.random(0,255),
    g = math.random(0,255),
    b = math.random(0,255)
  }

  local target      = get_ball_target(column, row)
  local dur         = duration + duration * (1-math.random()) / 2
  local easing_key  = easing_keys[math.random(1, #easing_keys)]
  local easing      = tween.easing[easing_key]

  ball.tweens = {
    tween.new(dur, ball, target, easing),
    tween.new(dur, ball, {r=255,g=255,b=255}, 'inExpo')
  }

  return ball
end

function love.load()
  local len = 0
  for column=1, balls_columns do
    for row=1, balls_rows do
      len = len + 1
      balls[len] = create_ball(column, row)
    end
  end
end

function love.update(dt)
  if love.keyboard.isDown(' ') then dt = -dt end
  for i=1, #balls do
    for j=1, #balls[i].tweens do
      balls[i].tweens[j]:update(dt)
    end
  end
end

function love.draw()
  local ball, r,g,b
  for i=1, #balls do
    ball = balls[i]
    r,g,b = pad(ball.r, 0, 255), pad(ball.g, 0, 255), pad(ball.b, 0, 255)
    love.graphics.setColor(r,g,b)
    love.graphics.circle('fill', ball.x, ball.y, ball.radius)
    love.graphics.setColor(0,0,0)
    love.graphics.circle('line', ball.x, ball.y, ball.radius)
  end
end

function love.keypressed(k)
  if k == 'escape' then love.event.quit() end
end


