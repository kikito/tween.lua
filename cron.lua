-----------------------------------------------------------------------------------------------------------------------
-- cron.lua - v1.1 (2011-04)
-- Enrique García Cota - enrique.garcia.cota [AT] gmail [DOT] com
-- time-related functions for Lua.
-- inspired by Javascript's setTimeout and setInterval
-----------------------------------------------------------------------------------------------------------------------

-- Copyright (c) 2011 Enrique García Cota
-- Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
-- The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

local function isCallable(callback)
  local tc = type(callback)
  if tc == 'function' then return true end
  if tc == 'table' then
    local mt = getmetatable(callback)
    return type(mt) == 'table' and type(mt.__call) == 'function'
  end
  return false
end

local function checkTimeAndCallback(time, callback)
  assert(type(time) == "number" and time > 0, "time must be a positive number")
  assert(isCallable(callback), "callback must be a function")
end

local entries = setmetatable({}, {__mode = "k"})

local function newEntry(time, callback, update, ...)
  local entry = {
    time = time,
    callback = callback,
    args = {...},
    running = 0,
    update = update
  }
  entries[entry] = entry
  return entry
end

local function updateTimedEntry(self, dt) -- returns true if expired
  self.running = self.running + dt
  if self.running >= self.time then
    self.callback(unpack(self.args))
    return true
  end
end

local function updatePeriodicEntry(self, dt)
  self.running = self.running + dt

  while self.running >= self.time do
    self.callback(unpack(self.args))
    self.running = self.running - self.time
  end
end

local cron = {}

function cron.reset()
  entries = {}
end

function cron.cancel(id)
  entries[id] = nil
end

function cron.after(time, callback, ...)
  checkTimeAndCallback(time, callback)
  return newEntry(time, callback, updateTimedEntry, ...)
end

function cron.every(time, callback, ...)
  checkTimeAndCallback(time, callback)
  return newEntry(time, callback, updatePeriodicEntry, ...)
end

function cron.update(dt)
  assert(type(dt) == "number" and dt > 0, "dt must be a positive number")

  local expired = {}

  for _, entry in pairs(entries) do
    if entry:update(dt, runningTime) then table.insert(expired,entry) end
  end

  for i=1, #expired do entries[expired[i]] = nil end
end

return cron

