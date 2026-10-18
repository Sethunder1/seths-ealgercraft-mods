-- name: Seth's Keystrokes
-- id: keystrokes
-- version: 1.5.4
-- author: seth
-- description: Shows which movement keys and mouse buttons you are pressing. i recommnd y 195 on 1x and y 220 on 0.75x (gui2) (350)

local sprintKeyOptions = { "Q", "R", "F", "G" }
local customKeyOptions = {}
for key in string.gmatch("ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890.", ".") do
  customKeyOptions[#customKeyOptions + 1] = key
end

settings.slider("x", { label = "X position", min = 0, max = 1200, step = 1, default = 4 })
settings.slider("y", { label = "Y position", min = 0, max = 1200, step = 1, default = 220 })
settings.slider("keystroke_scale", {
    label = "Keystrokes size", min = 0.25, max = 2, step = 0.05, default = 0.75
})
settings.toggle("show_cps", { label = "Show CPS", default = true })
settings.toggle("show_sprint", { label = "Show Sprint", default = true })
settings.toggle("show_outlines", { label = "Show outlines", default = true })
settings.choice("sprint_key", { label = "Sprint key", options = sprintKeyOptions, default = "Q" })
settings.toggle("show_extra_1", { label = "Show extra key 1", default = true })
settings.choice("extra_key_1", { label = "Extra key 1", options = customKeyOptions, default = "1" })
settings.toggle("show_extra_2", { label = "Show extra key 2", default = true })
settings.choice("extra_key_2", { label = "Extra key 2", options = customKeyOptions, default = "2" })
settings.toggle("show_extra_3", { label = "Show extra key 3", default = true })
settings.choice("extra_key_3", { label = "Extra key 3", options = customKeyOptions, default = "3" })
settings.toggle("show_extra_4", { label = "Show extra key 4", default = true })
settings.choice("extra_key_4", { label = "Extra key 4", options = customKeyOptions, default = "P" })

settings.color("active_color", { label = "Active key color", default = "#FF3D3D" })


local function parseColor(color)
  if type(color) == "number" then
    return color
  end
  if type(color) ~= "string" then
    return nil
  end

  local hex = color:gsub("^#", ""):gsub("^0[xX]", "")
  if #hex ~= 6 and #hex ~= 8 then
    return nil
  end

  local value = tonumber(hex, 16)
  if not value then
    return nil
  end
  if #hex == 6 then
    return 4278190080 + value
  end

  local red = math.floor(value / 16777216)
  local green = math.floor(value / 65536) % 256
  local blue = math.floor(value / 256) % 256
  local alpha = value % 256
  return alpha * 16777216 + red * 65536 + green * 256 + blue
end

settings.color("inactive_color", { label = "Inactive key color", default = "#1F1F1F" })


local function parseColor(color)
  if type(color) == "number" then
    return color
  end
  if type(color) ~= "string" then
    return nil
  end

  local hex = color:gsub("^#", ""):gsub("^0[xX]", "")
  if #hex ~= 6 and #hex ~= 8 then
    return nil
  end

  local value = tonumber(hex, 16)
  if not value then
    return nil
  end
  if #hex == 6 then
    return 4278190080 + value
  end

  local red = math.floor(value / 16777216)
  local green = math.floor(value / 65536) % 256
  local blue = math.floor(value / 256) % 256
  local alpha = value % 256
  return alpha * 16777216 + red * 65536 + green * 256 + blue
end

settings.color("text_color", { label = "Text color", default = "#FFFFFF" })


local function parseColor(color)
  if type(color) == "number" then
    return color
  end
  if type(color) ~= "string" then
    return nil
  end

  local hex = color:gsub("^#", ""):gsub("^0[xX]", "")
  if #hex ~= 6 and #hex ~= 8 then
    return nil
  end

  local value = tonumber(hex, 16)
  if not value then
    return nil
  end
  if #hex == 6 then
    return 4278190080 + value
  end

  local red = math.floor(value / 16777216)
  local green = math.floor(value / 65536) % 256
  local blue = math.floor(value / 256) % 256
  local alpha = value % 256
  return alpha * 16777216 + red * 65536 + green * 256 + blue
end

settings.color("active_outline_color", { label = "Active outline color", default = "#FFFFFF" })


local function parseColor(color)
  if type(color) == "number" then
    return color
  end
  if type(color) ~= "string" then
    return nil
  end

  local hex = color:gsub("^#", ""):gsub("^0[xX]", "")
  if #hex ~= 6 and #hex ~= 8 then
    return nil
  end

  local value = tonumber(hex, 16)
  if not value then
    return nil
  end
  if #hex == 6 then
    return 4278190080 + value
  end

  local red = math.floor(value / 16777216)
  local green = math.floor(value / 65536) % 256
  local blue = math.floor(value / 256) % 256
  local alpha = value % 256
  return alpha * 16777216 + red * 65536 + green * 256 + blue
end

settings.color("inactive_outline_color", { label = "Inactive outline color", default = "#A0A0A0BF" })

local function parseColor(color)
  if type(color) == "number" then
    return color
  end
  if type(color) ~= "string" then
    return nil
  end

  local hex = color:gsub("^#", ""):gsub("^0[xX]", "")
  if #hex ~= 6 and #hex ~= 8 then
    return nil
  end

  local value = tonumber(hex, 16)
  if not value then
    return nil
  end
  if #hex == 6 then
    return 4278190080 + value
  end

  local red = math.floor(value / 16777216)
  local green = math.floor(value / 65536) % 256
  local blue = math.floor(value / 256) % 256
  local alpha = value % 256
  return alpha * 16777216 + red * 65536 + green * 256 + blue
end

local function getTheme()
  return {
    active = parseColor(settings.active_color),
    inactive = parseColor(settings.inactive_color),
    activeOutline = parseColor(settings.active_outline_color),
    inactiveOutline = parseColor(settings.inactive_outline_color),
    text = parseColor(settings.text_color)
  }
end

local fadeStates = {}
local function getFadeAmount(label, x, y, width, down)
  local key = table.concat({ label, x, y, width }, ":")
  local now = os.clock() * 1000
  local target = down and 1 or 0
  local state = fadeStates[key]
  if not state then
    fadeStates[key] = { from = target, target = target, started = now, value = target }
    return target
  end
  if state.target ~= target then
    state.from = state.value
    state.target = target
    state.started = now
  end
  local progress = math.min(1, (now - state.started) / 160)
  local eased = 1 - ((1 - progress) ^ 3)
  state.value = state.from + (state.target - state.from) * eased
  return state.value
end

local function mixColor(from, to, amount)
  from = from or 0
  to = to or 0
  local function channel(color, shift)
    return math.floor(color / (2 ^ shift)) % 256
  end
  local alpha = math.floor(channel(from, 24) + (channel(to, 24) - channel(from, 24)) * amount + 0.5)
  local red = math.floor(channel(from, 16) + (channel(to, 16) - channel(from, 16)) * amount + 0.5)
  local green = math.floor(channel(from, 8) + (channel(to, 8) - channel(from, 8)) * amount + 0.5)
  local blue = math.floor(channel(from, 0) + (channel(to, 0) - channel(from, 0)) * amount + 0.5)
  return alpha * 16777216 + red * 65536 + green * 256 + blue
end

local leftClicks = {}
local rightClicks = {}
local lastLeftDown = false
local lastRightDown = false

local function pruneClicks(clicks, now)
  local i = 1
  while i <= #clicks do
    if now - clicks[i] > 1000 then
      table.remove(clicks, i)
    else
      i = i + 1
    end
  end
end

local function updateClickCounter(clicks, down, lastDown, now)
  if down and not lastDown then
    table.insert(clicks, now)
  end

  pruneClicks(clicks, now)
  return #clicks
end

local function box(ctx, label, x, y, w, down)
  local theme = getTheme()
  local amount = getFadeAmount(label, x, y, w, down)
  local bg = mixColor(theme.inactive, theme.active, amount)
  local outline = mixColor(theme.inactiveOutline, theme.activeOutline, amount)
  if bg then ctx:rect(x, y, w, 18, bg) end
  if settings.show_outlines and outline then
    ctx:rect(x, y, w, 1, outline)
    ctx:rect(x, y + 17, w, 1, outline)
    ctx:rect(x, y, 1, 18, outline)
    ctx:rect(x + w - 1, y, 1, 18, outline)
  end
  if theme.text then ctx:centeredText(label, x + w // 2, y + 5, theme.text) end
end

local function cpsText(label, value)
  return label .. " " .. value
end

local function selectedKey(value, options, fallback)
  if type(value) == "number" then
    value = options[math.floor(value)]
  end
  if type(value) ~= "string" then
    return fallback
  end

  local key = string.lower(value)
  for _, option in ipairs(options) do
    if key == string.lower(option) then
      return key
    end
  end
  return fallback
end

local function getKeyLabel(key)
  return string.upper(key)
end

hud.add("keystrokes", function(ctx)
  if game.screen() then return end

  local x, y = settings.x, settings.y
  local scale = settings.keystroke_scale
  local scaled = false
  if scale ~= 1 and pcall(function() ctx:push() end) then
    scaled = pcall(function() ctx:scale(scale, scale) end)
    if scaled then
      x, y = x / scale, y / scale
    else
      pcall(function() ctx:pop() end)
    end
  end
  local now = os.clock() * 1000

  local leftDown = mouse.isDown("left")
  local rightDown = mouse.isDown("right")

  local leftCps = updateClickCounter(leftClicks, leftDown, lastLeftDown, now)
  local rightCps = updateClickCounter(rightClicks, rightDown, lastRightDown, now)

  lastLeftDown = leftDown
  lastRightDown = rightDown

  box(ctx, "W", x + 20, y, 18, keys.isDown("w"))
  box(ctx, "A", x, y + 20, 18, keys.isDown("a"))
  box(ctx, "S", x + 20, y + 20, 18, keys.isDown("s"))
  box(ctx, "D", x + 40, y + 20, 18, keys.isDown("d"))

  box(ctx, "-----", x, y + 40, 58, keys.isDown("space"))

  local sprintKey = selectedKey(settings.sprint_key, sprintKeyOptions, "q")
  if settings.show_sprint then
    box(ctx, "SPRINT", x + 60, y + 40, 52, keys.isDown(sprintKey))
  end

  local mouseY = y + 60
  box(ctx, "LMB", x, mouseY, 52, leftDown)
  box(ctx, "RMB", x + 56, mouseY, 52, rightDown)
  local extraKey4 = selectedKey(settings.extra_key_4, customKeyOptions, ".")
  if settings.show_extra_4 then
    box(ctx, getKeyLabel(extraKey4), x + 112, mouseY, 18, keys.isDown(extraKey4))
  end

  local extraKeysY = mouseY + 20

  local extraKeys = {
    { enabled = settings.show_extra_1, key = selectedKey(settings.extra_key_1, customKeyOptions, "1") },
    { enabled = settings.show_extra_2, key = selectedKey(settings.extra_key_2, customKeyOptions, "2") },
    { enabled = settings.show_extra_3, key = selectedKey(settings.extra_key_3, customKeyOptions, "3") }
  }
  for index, extra in ipairs(extraKeys) do
    if extra.enabled then
      box(ctx, getKeyLabel(extra.key), x + 112 + ((index - 1) * 20), extraKeysY, 18, keys.isDown(extra.key))
    end
  end

  if settings.show_cps then
    local cpsY = mouseY + 20
    box(ctx, cpsText("CPS", leftCps), x, cpsY, 52, false)
    box(ctx, cpsText("CPS", rightCps), x + 56, cpsY, 52, false)
  end
  if scaled then pcall(function() ctx:pop() end) end
end)

-- ~215 for non fullscreen
-- eagler craftttt