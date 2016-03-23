package = "tween"
version = "2.1.1-1"
source = {
   url = "git://github.com/kikito/tween.lua",
   dir = "tween.lua",
   tag = "v2.1.1"
}
description = {
   summary = "tweening functions for lua",
   detailed = [[
tween.lua is a small library to perform tweening in Lua, inspired by JQuery's
animate() method. It has a minimal interface, and it comes with several
easing functions.]],
   homepage = "http://github.com/kikito/tween.lua",
   license = "MIT"
}
dependencies = {
   "lua >= 5.1"
}
build = {
   type = "builtin",
   modules = {
      tween = "tween.lua"
   }
}
