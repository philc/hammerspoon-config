-- Vim style modal bindings
-- Adapted from https://github.com/apesic/dotfiles/blob/master/.hammerspoon/vim.lua

-- TODO(phil): Use ESC to exit modes, rather than ctrl-[

lib = require("lib")

-- Normal mode

local inNormalMode = false

local normal = hs.hotkey.modal.new()
function normal:entered() inNormalMode = true end
function normal:exited() inNormalMode = false end

local visual = hs.hotkey.modal.new()

function exitAllModes()
  visual:exit()
  normal:exit()
end

function notifyModeChange(message)
  -- Show this alert in the lower edge of the screen, and make it less pronounced than my default styles.
  style = {table.unpack(hs.alert.defaultStyle)} -- Copy by value the default style table.
  style.atScreenEdge = 2
  style.textSize = 18
  style.fillColor = {white = 0.05, alpha = 1} -- Use an alpha of 1 because the alerts overlay each other.
  style.radius = 0
  hs.alert.show(message, style)
end

function toggleModes()
  if (inNormalMode) then
    exitAllModes()
    notifyModeChange('Insert mode')
  else
    normal:enter()
    notifyModeChange('Normal mode')
  end
end

-- Toggle between insert and normal mode by tapping the Cmd key. Tapping it again exits the mode. Note that
-- I've mapped a single tap of "cmd" to F17 using Karabiner-Elements.
enterNormal = hs.hotkey.bind(nil, "F17", toggleModes)

function left() lib.keyStroke({}, "Left") end
normal:bind({}, 'h', left, nil, left)

function right() lib.keyStroke({}, "Right") end
normal:bind({}, 'l', right, nil, right)

function up() lib.keyStroke({}, "Up") end
normal:bind({}, 'k', up, nil, up)

function down() lib.keyStroke({}, "Down") end
normal:bind({}, 'j', down, nil, down)

-- Move to the next word.
function word() lib.keyStroke({"alt"}, "Right") end
normal:bind({}, 'w', word, nil, word)
normal:bind({}, 'e', word, nil, word)

-- Move to the previous word.
function back() lib.keyStroke({"alt"}, "Left") end
normal:bind({}, 'b', back, nil, back)

-- Move to the beginning of the line
normal:bind({}, '0', function() lib.keyStroke({"cmd"}, "Left") end)

normal:bind({"shift"}, 'h', function() lib.keyStroke({"cmd"}, "Left") end)

-- Move to the end of the line
normal:bind({"shift"}, '4', function() lib.keyStroke({"cmd"}, "Right") end)

normal:bind({"shift"}, 'l', function() lib.keyStroke({"cmd"}, "Right") end)

-- Move to beginning of text
normal:bind({}, 'g', function() lib.keyStroke({"cmd"}, "Up") end)

-- Move to the end of text
normal:bind({"shift"}, 'g', function() lib.keyStroke({"cmd"}, "Down") end)

-- Center cursor
normal:bind({}, 'z', function() lib.keyStroke({"ctrl"}, "L") end)

-- Page down
normal:bind({"ctrl"}, "f", function() lib.keyStroke({}, "pagedown") end)

-- Page up
normal:bind({"ctrl"}, "b", function() lib.keyStroke({}, "pageup") end)

-- Insert

-- i - insert at cursor
normal:bind({}, 'i', function()
    normal:exit()
    notifyModeChange('Insert mode')
  end)

-- I - insert at beggining of line
normal:bind({"shift"}, 'i', function()
    lib.keyStroke({"cmd"}, "Left")
    normal:exit()
    notifyModeChange('Insert mode')
  end)

-- a - append after cursor
normal:bind({}, 'a', function()
    lib.keyStroke({}, "Right")
    normal:exit()
    notifyModeChange('Insert mode')
  end)

-- A - append to end of line
normal:bind({"shift"}, 'a', function()
    lib.keyStroke({"cmd"}, "Right")
    normal:exit()
    notifyModeChange('Insert mode')
  end)

-- o - open new line below cursor
normal:bind({}, 'o', nil, function()
    local app = hs.application.frontmostApplication()
    if app:name() == "Finder" then
      lib.keyStroke({"cmd"}, "o")
    else
      lib.keyStroke({"cmd"}, "Right")
      normal:exit()
      lib.keyStroke({}, "Return")
      notifyModeChange('Insert mode')
    end
  end)

-- O - open new line above cursor
normal:bind({"shift"}, 'o', nil, function()
    local app = hs.application.frontmostApplication()
    if app:name() == "Finder" then
      lib.keyStroke({"cmd", "shift"}, "o")
    else
      lib.keyStroke({"cmd"}, "Left")
      normal:exit()
      lib.keyStroke({}, "Return")
      lib.keyStroke({}, "Up")
      notifyModeChange('Insert mode')
    end
  end)

-- d - delete character before the cursor
local function delete() lib.keyStroke({}, "delete") end
normal:bind({}, 'd', delete, nil, delete)

-- x - delete character after the cursor
local function fndelete()
  lib.keyStroke({}, "Right")
  lib.keyStroke({}, "delete")
end
normal:bind({}, 'x', fndelete, nil, fndelete)

-- D - delete until end of line
normal:bind({"shift"}, 'D', nil, function()
    normal:exit()
    lib.keyStroke({"ctrl"}, "k")
    normal:enter()
  end)

-- f, s - call Shortcat
normal:bind({}, 'f', function()
    normal:exit()
    notifyModeChange('Insert mode')
    lib.keyStroke({"alt"}, "space")
  end)

normal:bind({}, 's', function()
    normal:exit()
    notifyModeChange('Insert mode')
    lib.keyStroke({"alt"}, "space")
  end)

-- / - search
normal:bind({}, '/', function() lib.keyStroke({"cmd"}, "f") end)

-- u - undo
normal:bind({}, 'u', function() lib.keyStroke({"cmd"}, "z") end)

-- <c-r> - redo
normal:bind({"ctrl"}, 'r', function() lib.keyStroke({"cmd", "shift"}, "z") end)

-- y - yank
normal:bind({}, 'y', function() lib.keyStroke({"cmd"}, "c") end)

-- p - paste
normal:bind({}, 'p', function() lib.keyStroke({"cmd"}, "v") end)

-- Visual mode

-- v - enter Visual mode
normal:bind({}, 'v', function() normal:exit() visual:enter() end)
function visual:entered() notifyModeChange('Visual mode') end

-- <c-[> - exit Visual mode
visual:bind({"ctrl"}, '[', function()
    visual:exit()
    normal:exit()
    lib.keyStroke({}, "Right")
    notifyModeChange('Normal mode')
  end)

-- Movements

-- h - move left
function vleft() lib.keyStroke({"shift"}, "Left") end
visual:bind({}, 'h', vleft, nil, vleft)

-- l - move right
function vright() lib.keyStroke({"shift"}, "Right") end
visual:bind({}, 'l', vright, nil, vright)

-- k - move up
function vup() lib.keyStroke({"shift"}, "Up") end
visual:bind({}, 'k', vup, nil, vup)

-- j - move down
function vdown() lib.keyStroke({"shift"}, "Down") end
visual:bind({}, 'j', vdown, nil, vdown)

-- w - move to next word
function word() lib.keyStroke({"alt", "shift"}, "Right") end
visual:bind({}, 'w', word, nil, word)
visual:bind({}, 'e', word, nil, word)

-- b - move to previous word
function back() lib.keyStroke({"alt", "shift"}, "Left") end
visual:bind({}, 'b', back, nil, back)

-- 0, H - move to beginning of line
visual:bind({}, '0', function() lib.keyStroke({"cmd", "shift"}, "Left") end)

visual:bind({"shift"}, 'h', function() lib.keyStroke({"cmd", "shift"}, "Left") end)

-- $, L - move to end of line
visual:bind({"shift"}, '4', function() lib.keyStroke({"cmd", "shift"}, "Right") end)

visual:bind({"shift"}, 'l', function() lib.keyStroke({"cmd", "shift"}, "Right") end)

-- g - move to beginning of text
visual:bind({}, 'g', function() lib.keyStroke({"shift", "cmd"}, "Up") end)

-- G - move to end of line
visual:bind({"shift"}, 'g', function() lib.keyStroke({"shift", "cmd"}, "Down") end)

-- d, x - delete character before the cursor
visual:bind({}, 'd', delete, nil, delete)
visual:bind({}, 'x', delete, nil, delete)

-- y - yank
visual:bind({}, 'y', function()
    lib.keyStroke({"cmd"}, "c")
    hs.timer.doAfter(0.1, function()
        visual:exit()
        normal:enter()
        lib.keyStroke({}, "Right")
        notifyModeChange('Normal mode')
      end)
  end)

-- p - paste
visual:bind({}, 'p', function()
    lib.keyStroke({"cmd"}, "v")
    visual:exit()
    normal:enter()
    lib.keyStroke({}, "Right")
    notifyModeChange('Normal mode')
  end)

hs.window.filter.new('Emacs')
:subscribe(hs.window.filter.windowFocused, function()
    exitAllModes()
    enterNormal:disable()
  end)
:subscribe(hs.window.filter.windowUnfocused, function() enterNormal:enable() end)

hs.window.filter.new('iTerm')
:subscribe(hs.window.filter.windowFocused, function()
    exitAllModes()
    enterNormal:disable()
  end)
:subscribe(hs.window.filter.windowUnfocused, function() enterNormal:enable() end)
