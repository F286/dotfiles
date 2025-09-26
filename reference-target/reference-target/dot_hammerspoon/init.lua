-- Map Cmd+Arrows/Delete to Option equivalents in target apps
-- Works in Chrome page content; Safari is included as a fallback (remove if not desired).

local targets = {
  ["com.google.Chrome"] = true,   -- Chrome
  ["com.apple.Safari"]  = true,   -- Safari (optional)
  -- Add others if you want:
  -- ["com.microsoft.edgemac"] = true,
  -- ["com.brave.Browser"] = true,
  -- ["company.thebrowser.Browser"] = true, -- Arc
}

local keyDown   = hs.eventtap.event.types.keyDown
local keyRepeat = hs.eventtap.event.types.keyRepeat

local function frontIsTarget()
  local app = hs.application.frontmostApplication()
  return app and targets[app:bundleID()] == true
end

local function handle(e)
  local t = e:getType()
  if t ~= keyDown and t ~= keyRepeat then return false end
  if not frontIsTarget() then return false end

  local flags = e:getFlags()
  -- Only when Command is down (Shift allowed), not when Option/Ctrl already down
  if not flags.cmd or flags.alt or flags.ctrl then return false end

  local kc = e:getKeyCode()
  local map = hs.keycodes.map
  local mods = {"alt"}
  if flags.shift then table.insert(mods, "shift") end

  if kc == map.left then
    hs.eventtap.keyStroke(mods, "left", 0)         -- ⌥← or ⌥⇧←
    return true
  elseif kc == map.right then
    hs.eventtap.keyStroke(mods, "right", 0)        -- ⌥→ or ⌥⇧→
    return true
  elseif kc == map.delete then
    hs.eventtap.keyStroke({"alt"}, "delete", 0)    -- ⌥⌫ (delete word backward)
    return true
  elseif kc == map.forwarddelete then
    hs.eventtap.keyStroke({"alt"}, "forwarddelete", 0) -- ⌥ForwardDelete
    return true
  end
  return false
end

hs.eventtap.new({keyDown, keyRepeat}, handle):start()
