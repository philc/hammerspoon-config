-----------------------------------------------------------------------
-- References:
-- https://github.com/apesic/dotfiles/blob/master/.hammerspoon/init.lua
-- http://stevelosh.com/blog/2012/10/a-modern-space-cadet/
-- https://learnxinyminutes.com/docs/lua/
-- https://github.com/jasonrudolph/keyboard
-----------------------------------------------------------------------

require("vim")
lib = require("lib")

-- Shortcut to reload this hammerspoon config.
-- This is bound early so that the hotkey for reloading the config still works even if there's an issue later
-- on in the file.
hs.hotkey.bind({"cmd", "shift", "ctrl"}, "R", function() hs.reload() end)

-- In terminals, make Cmd-V paste images when the clipboard holds an image. Terminals only paste text on
-- Cmd-V, but Claude Code and Pi read images from the clipboard when they receive Ctrl-V. So if the clipboard
-- holds an image, translate Cmd-V into Ctrl-V. Text pastes are unaffected. Some apps (e.g. Excel) put both
-- text and an image of the selection on the clipboard; in that case, prefer pasting the text.
local terminalBundleIds = { ["org.alacritty"] = true, ["com.mitchellh.ghostty"] = true }
-- This is global so it doesn't get garbage collected.
imagePasteTap = hs.eventtap.new({hs.eventtap.event.types.keyDown}, function(event)
  if event:getKeyCode() ~= hs.keycodes.map.v then return false end
  if not event:getFlags():containExactly({"cmd"}) then return false end
  local app = hs.application.frontmostApplication()
  if not (app and terminalBundleIds[app:bundleID()]) then return false end
  if hs.pasteboard.readImage() == nil or hs.pasteboard.readString() ~= nil then return false end
  lib.keyStroke({"ctrl"}, "v")
  return true
end)
imagePasteTap:start()
