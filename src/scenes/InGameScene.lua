local middleclass = require "libs.middleclass"

local PhysicsScene = require "scenes.PhysicsScene"

local EventSystem = require "cat-paw.core.patterns.event.EventSystem"
local EvKeyPress = require "cat-paw.core.patterns.event.keyboard.EvKeyPress"

local Level = require "core.Level"
local Wizard = require "entities.Wizard"

------------------------------ Helpers ------------------------------

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
	for k, v in pairs(levelsInDir) do
		local levelId = v:sub(1, -5)
		print("Storing level ID for:", levelId)
		self.levels[levelId] = true
	end	
	--Load stats
	--Track stats, etc...
end

------------------------------ Constants ------------------------------
InGameScene.MAX_NORMAL_LEVELS = 1

------------------------------ Core API ------------------------------
function InGameScene:draw(g2d)
	g2d.push('all')
	local SW, SH = love.window.getMode()
	local xOff = (SW - self.currentLevel.w * GAME.GRID_SIZE) / 2
	local yOff = (SH - self.currentLevel.h * GAME.GRID_SIZE) / 2
	g2d.translate(xOff, yOff)
	for obj, _ in pairs(self.objects) do
		obj:draw(g2d)
	end
	self.currentLevel.signManager:draw(g2d)
	
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
function InGameScene:switchToLevel(levelNumberOrId)
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
	else
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
	
	return true
end

function InGameScene:gotoNextLevel()
	--abs -> If at special, go back to last normal level.
	self:switchToLevel(math.abs(self.currentLevelNumber) + 1)
end

------------------------------ Events ------------------------------
InGameScene[EvKeyPress] = function(self, e)
	if DEBUG.ALLOW_QUICK_EXIT and e.key == 'escape' then
		love.event.quit()
	elseif DEBUG.DEV_MODE and e.key == 't' then
		self:switchToLevel("level_test")
	end 
end

------------------------------ Getters / Setters ------------------------------

return InGameScene