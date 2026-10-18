-- name: seth's Coordinates HUD
-- id: coordinates_day_count
-- version: 1.1.1
-- author: seth
-- description: Shows FPS, player coordinates, and biome.

settings.slider("x", { label = "X position", min = 0, max = 1200, step = 1, default = 30 })
settings.slider("y", { label = "Y position", min = 0, max = 1200, step = 1, default = 0 })
settings.toggle("show_fps", { label = "Show FPS", default = false })
settings.toggle("show_coords", { label = "Show coordinates", default = true })
settings.toggle("show_biome", { label = "Show biome", default = true })
settings.slider("coord_scale", { label = "HUD text size", min = 0.5, max = 1, step = 0.05, default = 1 })
settings.slider("text_align", {
	label = "Text alignment: 1=Left, 2=Center, 3=Right", min = 1, max = 3, step = 1, default = 2
})
settings.color("panel_color", { label = "Panel color", default = "#00000001" })
settings.color("text_color", { label = "Text color", default = "#FFFFFF" })

local function getValue(object, names)
	if object == nil then return nil end

	for _, name in ipairs(names) do
		local ok, value = pcall(function() return object[name] end)
		if ok and value ~= nil then
			if type(value) == "function" then
				local called, result = pcall(value, object)
				if not called or result == nil then
					called, result = pcall(value)
				end
				if called and result ~= nil then
					return result
				end
			else
				return value
			end
		end
	end

	return nil
end

local function getGlobal(name)
	local ok, value = pcall(function() return _G[name] end)
	if not ok or value == nil then return nil end
	if type(value) == "function" then
		local called, result = pcall(value)
		if called then return result end
		return nil
	end
	return value
end

local function add(list, value)
	if value ~= nil then
		list[#list + 1] = value
	end
end

local function getPlayerObjects()
	local objects = {}
	for _, name in ipairs({ "player", "entity", "game", "mc", "client" }) do
		local root = getGlobal(name)
		add(objects, root)
		add(objects, getValue(root, { "player", "getPlayer", "entity" }))
	end
	return objects
end

local function getWorldObjects()
	local objects = {}
	for _, name in ipairs({ "world", "game", "mc", "client" }) do
		local root = getGlobal(name)
		add(objects, root)
		local world = getValue(root, { "world", "level", "getWorld", "getLevel" })
		add(objects, world)
		add(objects, getValue(root, { "worldInfo", "getWorldInfo", "info" }))
		add(objects, getValue(world, { "worldInfo", "getWorldInfo", "info" }))
	end
	return objects
end

local function readNumber(object, names)
	local value = getValue(object, names)
	return tonumber(value)
end

local function getCoordinates()
	local xNames = { "x", "posX", "xCoord", "getX", "getPosX" }
	local yNames = { "y", "posY", "yCoord", "getY", "getPosY" }
	local zNames = { "z", "posZ", "zCoord", "getZ", "getPosZ" }

	for _, object in ipairs(getPlayerObjects()) do
		local x = readNumber(object, xNames)
		local y = readNumber(object, yNames)
		local z = readNumber(object, zNames)

		if x == nil or y == nil or z == nil then
			local position = getValue(object, { "position", "pos", "getPosition", "getPos" })
			x = x or readNumber(position, xNames)
			y = y or readNumber(position, yNames)
			z = z or readNumber(position, zNames)
		end

		if x ~= nil and y ~= nil and z ~= nil then
			return string.format("X: %d  Y: %d  Z: %d", math.floor(x), math.floor(y), math.floor(z))
		end
	end

	return "X --   Y --   Z --"
end

local function getFPS()
	local fps = tonumber(getGlobal("getFPS") or getGlobal("getFps") or getGlobal("fps"))
	if fps ~= nil then return tostring(math.floor(fps + 0.5)) end

	for _, name in ipairs({ "client", "mc", "game" }) do
		local root = getGlobal(name)
		fps = readNumber(root, { "fps", "currentFps", "getFPS", "getFps" })
		if fps ~= nil then return tostring(math.floor(fps + 0.5)) end
	end
	return "--"
end

local function getBiome()
	for _, object in ipairs(getPlayerObjects()) do
		local biome = getValue(object, { "biomeName", "biome", "getBiomeName", "getBiome" })
		if biome ~= nil then
			local name = getValue(biome, { "name", "id", "registryName", "translationKey", "getName", "getId" })
			biome = name or biome
			local text = tostring(biome):gsub("^minecraft:", "")
			if text ~= "" then return text end
		end
	end
	for _, world in ipairs(getWorldObjects()) do
		local biome = getValue(world, { "biomeName", "biome", "getBiomeName" })
		if biome ~= nil then return tostring(biome):gsub("^minecraft:", "") end
	end
	return "--"
end

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

local function getTextWidth(text)
	local width = 0
	for index = 1, #text do
		local character = string.sub(text, index, index)
		if character:match("[ilI1!|.,:]") then
			width = width + 2
		elseif character == " " then
			width = width + 4
		elseif character:match("[mwMW]") then
			width = width + 6
		else
			width = width + 5
		end
	end
	return width
end

local function drawCoordinateText(ctx, text, panelX, panelWidth, y, color)
	if not color then return end
	local scale = settings.coord_scale
	local scaled = false
	if scale ~= 1 and pcall(function() ctx:push() end) then
		scaled = pcall(function() ctx:scale(scale, scale) end)
		if not scaled then pcall(function() ctx:pop() end) end
	end
	local renderScale = scaled and scale or 1
	local textWidth = getTextWidth(text) * renderScale
	local centerX = panelX + panelWidth / 2
	if settings.text_align == 1 then
		centerX = panelX + 6 + textWidth / 2
	elseif settings.text_align == 3 then
		centerX = panelX + panelWidth - 6 - textWidth / 2
	end

	if not scaled then
		ctx:centeredText(text, centerX, y, color)
		return
	end

	ctx:centeredText(text, centerX / scale, y / scale, color)
	pcall(function() ctx:pop() end)
end

hud.add("coordinates_day_count", function(ctx)
	local x, y = settings.x, settings.y
	local panelWidth = 140
	local rowHeight = 6 + (4 * settings.coord_scale)
	local row = 0
	local panelColor = parseColor(settings.panel_color)
	local textColor = parseColor(settings.text_color)

	local function drawRow(text)
		local rowY = y + row * rowHeight
		if panelColor then ctx:rect(x, rowY, panelWidth, rowHeight, panelColor) end
		drawCoordinateText(ctx, text, x, panelWidth, rowY + 2, textColor)
		row = row + 1
	end

	if settings.show_fps then drawRow("FPS " .. getFPS()) end
	if settings.show_coords then drawRow(getCoordinates()) end
	if settings.show_biome then drawRow("Biome " .. getBiome()) end
end)
