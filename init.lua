-----------------------------------------------------------------------
-- References:
-- https://github.com/apesic/dotfiles/blob/master/.hammerspoon/init.lua
-- http://stevelosh.com/blog/2012/10/a-modern-space-cadet/
-- https://learnxinyminutes.com/docs/lua/
-- https://github.com/jasonrudolph/keyboard
-----------------------------------------------------------------------

require("vim")
lib = require("lib")
hs.timer = require("hs.timer")
log = hs.logger.new("phil", "debug")

-- Shortcut to reload this hammerspoon config.
-- This is bound early so that the hotkey for reloading the config still works even if there's an issue later
-- on in the file.
hs.hotkey.bind({"cmd", "shift", "ctrl"}, "R", function() hs.reload() end)
