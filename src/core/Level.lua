local middleclass = require "libs.middleclass"

local DataRegistry = require "core.DataRegistry"

local SignManager = require "entities.SignManager"
local Wizard = require "entities.Wizard"
local Goal = require "entities.Goal"
local Block = require "entities.Block"

------------------------------ Private Constants ------------------------------
local SECRET = {}
local HEX_FORMAT_STR = "#%02X%02X%02X"
local LEVEL_PATH = "assets/levels/"
local LEGEND = {
	["#000000"] = function(scene, x, y) return nil end,
	
	["#0000F0"] = function(scene, x, y) return Wizard(scene, x, y) end,
	["#FFFF00"] = function(scene, x, y) return Goal(scene, x, y) end,
	["#595959"] = function(scene, x, y) return Block(scene, "void_tile", x, y) end,
	
	["#F000F0"] = function(scene, x, y) return Block(scene, "amethyst_tile", x, y) end,
	["#FF8000"] = function(scene, x, y) return Block(scene, "carnelian_tile", x, y) end,
	["#00F000"] = function(scene, x, y) return Block(scene, "emerald_tile", x, y) end,
	["#1A1A38"] = function(scene, x, y) return Block(scene, "lapis_tile", x, y) end,
	
--	["#FF000D"] = function(scene, x, y) return Collectible(scene, "collectible1", x, y) end,
--	["#4C0004"] = function(scene, x, y) return Collectible(scene, "collectible2", x, y) end,
}

------------------------------ Helpers ------------------------------
local floor = math.floor		--Used often, this improves performance.
local function rgbToHex(r, g, b)
	return HEX_FORMAT_STR:format(
		floor(r * 255),
		floor(g * 255),
		floor(b * 255)
	)
end
------------------------------ Constructor ------------------------------
local Level = middleclass("Level")
function Level:initialize(internal)
	assert(internal == SECRET, "Use Level:loadLevel to get new levels!")
end

------------------------------ Static API ------------------------------
function Level.static:loadLevel(scene, levelId)
	local level = Level(SECRET)
	local mapPng = love.image.newImageData(LEVEL_PATH .. levelId .. ".png")
	local metadata = {ID = levelId}
	DataRegistry:applyStats(metadata)
	
	level.name = metadata.name
	level.skills = metadata.skills
	level.objects, level.uniqueTiles = Level:_objectsFromPng(scene, mapPng)
--	level.uniqueTiles = {x = "hello", y = "test"}
	level.signManager = SignManager(scene, metadata.signs)
	level.w, level.h = mapPng:getDimensions()
	return level
end
------------------------------ Core API ------------------------------

------------------------------ Internals ------------------------------
function Level.static:_objectsFromPng(scene, mapPng)
	local t = {}
	local unique = {}
	local w, h = mapPng:getDimensions()
	for x = 0, w - 1 do
		for y = 0, h - 1 do
			local color = rgbToHex(mapPng:getPixel(x, y))
			assert(LEGEND[color], "Invalid tile found in map. Double check tile at (" ..
					x .. ", " .. y .. ") in level: " .. scene.levelId)
			local inst = LEGEND[color](scene, x * GAME.GRID_SIZE, y * GAME.GRID_SIZE) 
			if inst then 
				t[#t + 1] = inst
				if inst.name then
					unique[inst.ID] = inst.name
				end
			end
		end
	end
	return t, unique
end

------------------------------ Getters / Setters ------------------------------
function Level:getObjects()
	return self.objects
end

return Level