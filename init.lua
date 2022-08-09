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

----------------
-- Configuration
----------------

-- Make the alerts look nicer.
hs.alert.defaultStyle.strokeColor = {white = 1, alpha = 0}
hs.alert.defaultStyle.fillColor = {white = 0.05, alpha = 0.75}
hs.alert.defaultStyle.radius = 10

-- Disable the slow default window animations.
hs.window.animationDuration = 0

-- Modifier sets that I use
local mashApp = {"cmd", "ctrl"}

---------------------
-- Window positioning
---------------------

function moveLeftHalf()
  local win = hs.window.focusedWindow()
  local f = win:frame()
  local max = win:screen():frame()
  f.x = max.x
  f.y = max.y
  f.w = max.w / 2
  f.h = max.h
  win:setFrame(f)
end

function moveRightHalf()
  local win = hs.window.focusedWindow()
  local f = win:frame()
  local max = win:screen():frame()
  f.x = max.x + (max.w / 2)
  f.y = max.y
  f.w = max.w / 2
  f.h = max.h
  win:setFrame(f)
end

function center()
  local win = hs.window.focusedWindow()
  local f = win:frame()
  local max = win:screen():frame()
  local width = max.w / 2
  -- Position this on the second external display
  f.x = max.x + width / 2
  f.y = max.y
  f.w = width
  f.h = max.h
  win:setFrame(f)
end

function maximize()
  local win = hs.window.focusedWindow()
  local f = win:frame()
  local max = win:screen():frame()
  f.x = max.x
  f.y = max.y
  f.w = max.w
  f.h = max.h
  win:setFrame(f)
end

function moveToScreen(screenPos)
  window = hs.window.focusedWindow()
  screen = hs.screen.find({x=screenPos, y=0})
  window:moveToScreen(screen)
end

-- Toggle the window width to take up 1/3 of the screen vs. 2/3. This is useful for ultrawide monitors.
function toggleThirds()
  local win = hs.window.focusedWindow()
  local f = win:frame()
  local max = win:screen():frame()
  if f.w >= max.w / 2 then
    f.w = max.w / 3
  else
    f.w = max.w / 3 * 2
  end
  if f.x ~= 0 then
    f.x = max.x + (max.w - f.w)
  end
  win:setFrame(f)
end

hs.hotkey.bind(mashApp, "1", function() moveToScreen(0) moveLeftHalf() end)
hs.hotkey.bind(mashApp, "2", function() moveToScreen(0) moveRightHalf() end)
hs.hotkey.bind(mashApp, "3", function() moveToScreen(1) moveLeftHalf() end)
hs.hotkey.bind(mashApp, "4", function() moveToScreen(1) moveRightHalf() end)
hs.hotkey.bind(mashApp, "5", function() center() end)
hs.hotkey.bind(mashApp, "M", maximize)
hs.hotkey.bind({"cmd", "ctrl", "shift"}, "1", toggleThirds)

---------------------------------
-- Application focusing shortcuts
---------------------------------

-- Similar to hs.application.launchOrFocus, except that if an app is open and has many windows, this will
-- raise just the most recently-used window, rather than all of the windows of that app. This is IMO essential
-- for keeping applications with many windows (like Chrome) from stomping over typical tiling setups.
-- Note that "appName" needs to be a full path to the .app if the app is a symlink, which is the case for all
-- apps created via `homebrew linkapps`. hs.appfinder.appFromName uses spotlight to find apps, and Spotlight
-- doesn't index apps which are symlinks. See https://github.com/Homebrew/legacy-homebrew/issues/49033.
-- Reference: https://github.com/Hammerspoon/hammerspoon/issues/304
function myLaunchOrFocus(appName)
  local app = hs.appfinder.appFromName(appName)
  if not app then
    hs.application.launchOrFocus(appName)
  else
    windows = app:allWindows()
    if windows[1] then
      windows[1]:focus()
    else
      -- This will focus the app and, if there are no windows open, it will open a new window.
      hs.application.launchOrFocus(appName)
    end
  end
end

hs.hotkey.bind(mashApp, "L", function() myLaunchOrFocus("Google Chrome") end)
hs.hotkey.bind(mashApp, "J", function() myLaunchOrFocus("Emacs") end)
hs.hotkey.bind(mashApp, "K", function() myLaunchOrFocus("/Applications/iTerm.app") end)
hs.hotkey.bind(mashApp, "U", function() myLaunchOrFocus("SuperHuman") end)
-- hs.hotkey.bind(mashApp, "U", function() myLaunchOrFocus("Boxy for Gmail") end)
hs.hotkey.bind(mashApp, "Y", function() myLaunchOrFocus("Firefox") end)
hs.hotkey.bind(mashApp, ",", function() myLaunchOrFocus("Slack") end)
hs.hotkey.bind(mashApp, "N", function() myLaunchOrFocus("Terminal") end)
hs.hotkey.bind({"cmd", "ctrl", "shift"}, 'N', function () myLaunchOrFocus("Spotify") end)
hs.hotkey.bind(mashApp, "O", function() myLaunchOrFocus("Org") end)
hs.hotkey.bind(mashApp, "C", function() myLaunchOrFocus("Singlebox") end)
hs.hotkey.bind(mashApp, "V", function() myLaunchOrFocus("VLC") end)
hs.hotkey.bind(mashApp, "A", function() myLaunchOrFocus("Anylist") end)
hs.hotkey.bind(mashApp, "S", function() myLaunchOrFocus("SimpleNote") end)

-----------------
-- Key remappings
-----------------

function onAppFocusChange(appName, onFocus, onUnfocus)
  hs.window.filter.new(appName)
  :subscribe(hs.window.filter.windowFocused, function() onFocus() end)
  :subscribe(hs.window.filter.windowUnfocused, function() onUnfocus() end)
end

-- Binds a hotkey only when an app comes into focus.
-- @param hotkey: a binding as returned by hs.hotkey.new()
function bindHotkeyOnAppFocus(appName, hotkey)
  onAppFocusChange(appName, function() hotkey:enable() end, function() hotkey:disable() end)
end

-- Remaps a key only in the given app.
-- Reference: https://github.com/Hammerspoon/hammerspoon/issues/664
function remapInApp(appName, fromMods, fromKey, toMods, toKey)
  local binding = hs.hotkey.new(fromMods, fromKey, lib.keypress(toMods, toKey), nil, lib.keypress(toMods, toKey))
  bindHotkeyOnAppFocus(appName, binding)
end

-- Remaps a key, except for the app provided.
-- Reference: https://github.com/Hammerspoon/hammerspoon/issues/664
-- TODO(phil): I don't think I need this.
function remapInAppWithBlacklist(appName, fromMods, fromKey, toMods, toKey)
  local binding = hs.hotkey.new(fromMods, fromKey, lib.keypress(toMods, toKey), nil, lib.keypress(toMods, toKey))
  -- TODO: check here to see if the currently focused app is appName. If so, don't enable this binding.
  binding:enable()
  onAppFocusChange(appName, function() binding:disable() end, function() binding:enable() end)
end

-- I map "," and "." to emit hyphen and underscore because I use these letters often when programming, and my
-- Ergodox keyboard doesn't have convenient standalone keys for them.
hs.hotkey.bind("Ctrl", ",", lib.keypress("-"), nil, lib.keypress("-"))
hs.hotkey.bind("Ctrl", ".", lib.keypress("shift", "-"), nil, lib.keypress("shift", "-")) -- Underscore.

-- Make Ctrl-w behave as "delete word" throughout all of OSX. I don't need this rebound in Emacs, because I
-- already have it bound to backdelete there.
-- NOTE: I've disabled this because it's flaky: sometimes this hotkey won't get properly bound or unbound when
-- switching apps. There must be a race condition. I've reimplemented this rule in Karabiner Elements instead.
-- remapInAppWithBlacklist({"Emacs", "Org"}, "Ctrl", "W", "Alt", "Delete")

-- Make Cmd-J and Cmd-K switch tabs in all OSX apps.
-- NOTE: I'd like to express these in Karabiner Elements for consistency, but I couldn't get this working.
-- It also doesn't seem like I need this. Tmxu window switching works fine without iTerm special-casing.
-- remapInAppWithBlacklist("iTerm", {"cmd"}, "J", {"Cmd", "Alt"}, "left")
-- remapInAppWithBlacklist("iTerm", {"cmd"}, "K", {"Cmd", "Alt"}, "right")
hs.hotkey.bind("Cmd", "J", lib.keypress({"Cmd", "Alt"}, "left"), nil, lib.keypress({"Cmd", "Alt"}, "left"))
hs.hotkey.bind("Cmd", "K", lib.keypress({"Cmd", "Alt"}, "right"), nil, lib.keypress({"Cmd", "Alt"}, "right"))
-- remapInApp("iTerm2", "Cmd", "J", "Cmd", "J")

remapInApp("Sketch", "Ctrl", "D", nil, "delete")

remapInApp("Spotify", "Shift", ".", "Cmd", "right") -- "Previous track"
remapInApp("Spotify", "Shift", ",", "Cmd", "left") -- "Next track"

-- Returns a function which types the tmux prefix key prior to typing `keypress`.
function withTmuxPrefix(keypress)
  return function()
    lib.keyStroke("ctrl", "Y")
    keypress()
  end
end

-- iTerm: Remap alt-{s, d, f, e} to {5, 6, 7, 8} (but each prefixed with Tmux's prefix key) so they can be
-- bound by tmux.
bindHotkeyOnAppFocus("iTerm2", hs.hotkey.new("alt", "S", withTmuxPrefix(lib.keypress("5"))))
bindHotkeyOnAppFocus("iTerm2", hs.hotkey.new("alt", "D", withTmuxPrefix(lib.keypress("6"))))
bindHotkeyOnAppFocus("iTerm2", hs.hotkey.new("alt", "F", withTmuxPrefix(lib.keypress("7"))))
bindHotkeyOnAppFocus("iTerm2", hs.hotkey.new("alt", "E", withTmuxPrefix(lib.keypress("8"))))

-- Bind C-; to C-y (the tmux prefix key). C-; is easier to type. Unfortunately in tmux, you can't directly
-- bind C-; as the prefix key directly.
remapInApp("iTerm2", "ctrl", ";", "ctrl", "y")

-- Make Cmd-H rewind playback by 10s, and Cmd-L advance by 10s.
remapInApp("VLC", "cmd", "H", {"cmd", "Alt"}, "left")
remapInApp("VLC", "cmd", "L", {"cmd", "Alt"}, "right")

-----------------
-- Window layouts
-----------------

local leftScreen = hs.screen{x=0,y=0}
local centerScreen = hs.screen{x=1,y=0}
local rightScreen = hs.screen{x=2,y=0}

local threeScreenLayout = {
  {"Emacs", nil, centerScreen, hs.layout.maximized, nil, nil},
  {"Google Chrome", nil, leftScreen, hs.layout.maximized, nil, nil},
  {"iTerm2", nil, leftScreen, hs.layout.maximized, nil, nil},
  {"Gmail", nil, leftScreen, hs.layout.maximized, nil, nil},
  {"SuperHuman", nil, leftScreen, hs.layout.left50, nil, nil},
  {"Boxy for Gmail", nil, leftScreen, hs.layout.left50, nil, nil},
  {"Firefox", nil, leftScreen, hs.layout.right50, nil, nil},
  {"GmailPersonal", nil, leftScreen, hs.layout.right50, nil, nil},
  -- {"GCalendar", nil, centerScreen, hs.layout.left50, nil, nil},
  {"Singlebox", nil, centerScreen, hs.layout.left50, nil, nil},
  {"Slack", nil, leftScreen, hs.layout.right50, nil, nil},
  {"MacVim", nil, leftScreen, hs.layout.right50, nil, nil},
  {"Org", nil, leftScreen, hs.layout.left50, nil, nil},
  {"Xcode", nil, centerScreen, hs.layout.right50, nil, nil},
  {"Finder", nil, centerScreen, hs.layout.left50, nil, nil},
  {"Preview", nil, centerScreen, hs.layout.left50, nil, nil},
  {"OmniGraffle 6", nil, centerScreen, hs.layout.maximized, nil, nil},
  {"Terminal", nil, centerScreen, hs.layout.left50, nil, nil},
  {"Spotify", nil, centerScreen, hs.layout.left50, nil, nil},
  {"PowerPoint", nil, leftScreen, hs.layout.left50, nil, nil},
  {"Calendar", nil, leftScreen, hs.layout.maximized, nil, nil},
  {"System Preferences", nil, leftScreen, hs.layout.left50, nil, nil}
}

local twoScreenLayout = {
  {"Emacs", nil, leftScreen, hs.layout.maximized, nil, nil},
  {"Google Chrome", nil, leftScreen, hs.layout.left50, nil, nil},
  {"iTerm2", nil, leftScreen, hs.layout.maximized, nil, nil},
  {"Gmail", nil, leftScreen, hs.layout.left50, nil, nil},
  {"SuperHuman", nil, leftScreen, hs.layout.left50, nil, nil},
  {"Boxy for Gmail", nil, leftScreen, hs.layout.left50, nil, nil},
  {"Firefox", nil, leftScreen, hs.layout.left50, nil, nil},
  {"GmailPersonal", nil, leftScreen, hs.layout.left50, nil, nil},
  -- {"GCalendar", nil, leftScreen, hs.layout.left50, nil, nil},
  {"Singlebox", nil, leftScreen, hs.layout.left50, nil, nil},
  {"Slack", nil, leftScreen, hs.layout.right50, nil, nil},
  {"MacVim", nil, leftScreen, hs.layout.right50, nil, nil},
  {"Org", nil, leftScreen, hs.layout.left50, nil, nil},
  {"Xcode", nil, leftScreen, hs.layout.right50, nil, nil},
  {"Finder", nil, leftScreen, hs.layout.left50, nil, nil},
  {"Preview", nil, leftScreen, hs.layout.left50, nil, nil},
  {"OmniGraffle 6", nil, leftScreen, hs.layout.maximized, nil, nil},
  {"Terminal", nil, leftScreen, hs.layout.left50, nil, nil},
  {"Spotify", nil, leftScreen, hs.layout.left50, nil, nil},
  {"PowerPoint", nil, leftScreen, hs.layout.left50, nil, nil},
  {"Calendar", nil, leftScreen, hs.layout.left50, nil, nil},
  {"System Preferences", nil, leftScreen, hs.layout.left50, nil, nil}
}

function switchLayout()
  local numScreens = #hs.screen.allScreens()
  local layout = {}
  if numScreens == 1 then
    layout = twoScreenLayout
  elseif numScreens == 2 then
    layout = twoScreenLayout
  elseif numScreens == 3 then
    layout = threeScreenLayout
  end
  hs.layout.apply(layout)
end

hs.hotkey.bind(mashApp, "'", switchLayout)

-------------------
-- Other shortcuts
-------------------

-- This is an Alfred/Launchbar replacement I've strung together using fzf, Kitty, and some scripting.
-- This could possibly be instead built on top of fzf and hs.chooser.
function launchFuzzyFinder()
  local attempts = 0
  local maxAttempts = 100
  local checkInterval = 0.005

  local app = hs.application.get("kitty")
  if (app) then
    -- Close any existing windows, so that one can't hit this hotkey many types and get overlapping windows.
    local windows = app:allWindows()
    for i = 1, #windows do
      windows[i].close()
    end
  end

  -- Record which screen is active, so we can open this application chooser window on that same screen.
  local currentWin = hs.window.focusedWindow()
  local activeScreen
  if (currentWin) then
    activeScreen = currentWin:screen()
  end

  os.execute("/Users/phil/scripts/macos/file-chooser/invoke-kitty.sh &", true)

  -- Move the window as soon as its opened.
  -- I've also tried implementing this using hs.application.watcher (ala
  -- https://gist.github.com/tmandry/a5b1ab6d6ea012c1e8c5) but it has the same latency. The polling approach
  -- below makes for more straightforward code.
  hs.timer.doUntil(
    function()
      return (attempts >= maxAttempts)
    end,
    function()
      local win = hs.window.focusedWindow()
      if (win and win:application():name() == "kitty") then
        local winFrame = win:frame()
        local screenFrame = activeScreen:frame()
        local width = screenFrame.w / 2
        winFrame.x = screenFrame.x + (screenFrame.w - winFrame.w / 2) - winFrame.w
        winFrame.y = screenFrame.h / 5
        win:setFrame(winFrame)
        attempts = maxAttempts
      else
        attempts = attempts + 1
      end
    end,
    checkInterval)
end

-- Open a fuzzy file finder, similar to Alfred and Launchbar. This is my replacement for those apps. Neither
-- worked well for my basic use case of opening files and applications without ceremony.
hs.hotkey.bind({"cmd"}, "space", function()
    launchFuzzyFinder()
  end)

-- Lock the screen. This may also be possible with hs.caffeinate.lockScreen.
hs.hotkey.bind({"cmd", "shift", "ctrl"}, "l", function()
    os.execute("/Users/phil/scripts/macos/lock_screen.sh")
  end)

-- Hide every app which is not the frontmost.
hs.hotkey.bind({"cmd", "shift"}, "h", function()
    -- I'm enumerating through the visible windows because going through hs.application.runningApplications()
    -- surfaces some applications which hang Hammerspoon when you invoke hide() on them. They may be special
    -- applications, like Finder. I didn't bother to investigate which applications are hanging Hammerspoon,
    -- but that's easy to do using print statements and seeing where the hang occurs.
    local frontmostApp = hs.application.frontmostApplication()
    local windows = hs.window.visibleWindows()
    for i = 1, #windows do
      local w = windows[i]
      local app = w:application()
      if app:pid() ~= frontmostApp:pid() then
        app:hide()
      end
    end
  end)

function getVolumeIncrement()
  local volume = hs.audiodevice.current().volume
  -- When the volume gets near zero, change it in smaller increments. Otherwise even the first increment
  -- above zero may be too loud.
  -- NOTE(phil): I noticed that using a decimal smaller than 0.4 will sometimes result in the volume remaining
  -- unchanged after calling setVolume, as if OSX only lets you change the volume by large increments.
  if volume < 2 then return 0.4 else return 2 end
end

hs.hotkey.bind(mashApp, "9", function()
    hs.audiodevice.defaultOutputDevice():setVolume(hs.audiodevice.current().volume - getVolumeIncrement())
  end)

hs.hotkey.bind(mashApp, "0", function()
    hs.audiodevice.defaultOutputDevice():setVolume(hs.audiodevice.current().volume + getVolumeIncrement())
  end)

-- Show date time and battery
hs.hotkey.bind(mashApp, 'T', function()
    local seconds = 3
    local message = os.date("%I:%M%p") .. "\n" .. os.date("%a %b %d") .. "\nBattery: " ..
    hs.battery.percentage() .. "%"
    hs.alert.show(message, seconds)
  end)

hs.alert.show("Config loaded")
