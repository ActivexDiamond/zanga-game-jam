local middleclass = require "libs.middleclass"

local PhysicsScene = require "scenes.PhysicsScene"

local AssetRegistry = require "core.AssetRegistry"

local EventSystem = require "cat-paw.core.patterns.event.EventSystem"
local EvKeyPress = require "cat-paw.core.patterns.event.keyboard.EvKeyPress"

local Level = require "core.Level"
local Wizard = require "entities.Wizard"
local Spellbook = require "entities.Spellbook"

------------------------------ Helpers ------------------------------
local function drawBackground(self, g2d, initX, initY)
	local obj = {ID = "background_tile", w = 32, h = 32}
	local spr, sx, sy = AssetRegistry:getSprObj(obj)

	local x = initX + 32
	local y = initY + 32
	local ox = spr:getWidth() 
	local oy = spr:getHeight()
	
	g2d.draw(spr, x, y, self.rotation, sx, sy, ox, oy)
end

------------------------------ Constructor ------------------------------
local InGameScene = middleclass("InGameScene", PhysicsScene)
function InGameScene:initialize(...)
	PhysicsScene.initialize(self, ...)
	GAME:getEventSystem():attach(self, EventSystem.ATTACH_TO_ALL)
	
	--The level object itself.
	self.currentLevel = nil
	--The level number, used for normal levels.
	self.currentLevelNumber = 1
	--The level ID, used for the DataRegistry and will be indepedant from
	--	levelNumber for special levels. 
	self.levelId = "level1"
	self.levels = {}
	
	local levelsInDir = love.filesystem.getDirectoryItems("assets/levels")
	print("Found " .. #levelsInDir .. " levels.")
	InGameScene.MAX_NORMAL_LEVELS = #levelsInDir - 1
	for k, v in pairs(levelsInDir) do
		local levelId = v:sub(1, -5)
		print("Storing level ID for:", levelId)
		self.levels[levelId] = true
	end	
	--Load stats
	--Track stats, etc...
	
	self.SPELLBOOK = Spellbook()
end

------------------------------ Constants ------------------------------

------------------------------ Core API ------------------------------
function InGameScene:draw(g2d)
	g2d.push('all')
	local SW, SH = love.window.getMode()
--	GAME.xOff = (SW - self.currentLevel.w * GAME.GRID_SIZE) / 2
--	GAME.yOff = (SH - self.currentLevel.h * GAME.GRID_SIZE) / 2
	
	g2d.translate(GAME.xOffset, GAME.yOffset)
	g2d.scale(GAME.scale)
	
	g2d.setColor(0.3, 0.3, 0.3)
	for x = 0, self.currentLevel.w - 1 do
		for y = 0, self.currentLevel.h - 1 do 
			drawBackground(self, g2d, x * GAME.GRID_SIZE,
					y * GAME.GRID_SIZE)
		end
	end
	g2d.setColor(1, 1, 1)
	
	for obj, _ in pairs(self.objects) do
		obj:draw(g2d)
	end
	self.currentLevel.signManager:draw(g2d)
	
	local str;
	if self.currentLevelNumber > 0 then
		print "x"
		str = self.currentLevelNumber .. ": " .. (self.currentLevel.name or "")
	else
		str = self.currentLevel.name or ""
	end
	g2d.print(str, 0, 0)

	if DEBUG.DRAW_LEVEL_OUTLINE then
		local x, y = 0, 0
		local w = self.currentLevel.w * GAME.GRID_SIZE
		local h = self.currentLevel.h * GAME.GRID_SIZE
		g2d.rectangle('line', x, y, w, h)
	end
	g2d.pop()
end

function InGameScene:enter(from, levelNumberOrId)
	PhysicsScene.enter(self, from)
	if levelNumberOrId then self:switchToLevel(levelNumberOrId) end
end

------------------------------ API ------------------------------
function InGameScene:switchToLevel(levelNumberOrId, fullReload)
	--Used to revert state in case the safety check fails.
	local oldId, oldNumber = self.levelId, self.currentLevelNumber
	
	--If number, inc. If over max, go to win and set current to negative itself
	--	to indicate being at a special level.
	if type(levelNumberOrId) == 'number' then
		if levelNumberOrId > InGameScene.MAX_NORMAL_LEVELS then
			self.levelId = "level_win"
			self.currentLevelNumber = -self.currentLevelNumber
		else
			self.levelId = "level" .. levelNumberOrId
			self.currentLevelNumber = levelNumberOrId
		end
	elseif self.levelId ~= levelNumberOrId then
		self.levelId = levelNumberOrId
		--Set current to negative itself indicate being at a special level.
		self.currentLevelNumber = -self.currentLevelNumber
	end
	
	--Sanity check.
	if not self.levels[self.levelId] then
		print("ERROR: Invalid level ID  passed to `switchToLevel`! Ignoring!")
		self.levelId = oldId
		self.currentLevelNumber = oldNumber
		return false
	end
	
	print("Entering level:", self.levelId)
	self:clearObjects()
	self.currentLevel = Level:loadLevel(self, self.levelId)
	for k, obj in ipairs(self.currentLevel:getObjects()) do
		self:addObject(obj)
	end
	self.SPELLBOOK:updateState(fullReload)	
	return true
end

function InGameScene:gotoNextLevel()
	--abs -> If at special, go back to last normal level.
	self:switchToLevel(math.abs(self.currentLevelNumber) + 1, true)
end

function InGameScene:reloadLevel()
	--abs -> If at special, go back to last normal level.
	self:switchToLevel(self.levelId, false)
end

------------------------------ Events ------------------------------
InGameScene[EvKeyPress] = function(self, e)
	if e.key == 'escape' then
		if DEBUG.ALLOW_QUICK_EXIT then love.event.quit()
		else GAME:goTo(GAME.MAIN_MENU_SCENE_ID) end
	elseif DEBUG.DEV_MODE and e.key == 't' then
		self:switchToLevel("level_test", true)
	elseif DEBUG.DEV_MODE and e.key == 'g' then
		self:switchToLevel(self.currentLevelNumber + 1, true)
	elseif DEBUG.DEV_MODE and e.key == 'f' then
		self:switchToLevel(math.max(1, self.currentLevelNumber - 1), true)
	elseif e.key == 'k' then
		GAME.currentFont = GAME.currentFont + 1
		if GAME.currentFont > #GAME.fonts then
			GAME.currentFont = 1
		end
		love.graphics.setFont(GAME.fonts[GAME.currentFont])
	end 
end

------------------------------ Getters / Setters ------------------------------

return InGameScene