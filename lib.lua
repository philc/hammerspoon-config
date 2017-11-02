-- Library/utility functions used by my config.

local M = {}

-- Emits a keystroke like hs.eventtap.keyStroke, except that there is no delay between when this function is
-- called and when the keystroke is omitted. The default implementation of hs.eventtap.keyStroke makes
-- keystrokes emitted by the keyStroke function laggy (intentionally so). See:
-- https://github.com/Hammerspoon/hammerspoon/issues/1011#issuecomment-261114434
function M.keyStroke(modifiers, character)
  local event = require("hs.eventtap").event
  event.newKeyEvent(modifiers, string.lower(character), true):post()
  event.newKeyEvent(modifiers, string.lower(character), false):post()
end

-- A function which, when invoked, triggers a keystroke.
function M.keypress(modifiers, character)
  if character == nil then
    character = modifiers
    modifiers = nil
  end
  return function() M.keyStroke(modifiers, character) end
end

return M
