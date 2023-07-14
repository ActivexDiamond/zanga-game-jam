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
	
	for i = 1, InGameScene.MAX_NORMAL_LEVELS do
		self.levels[i] = Level:loadLevel(self, "level" .. i)
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
	local xOff = (SW - GAME.GRID_SIZE * self.currentLevel.w) / 2
	local yOff = (SH - GAME.GRID_SIZE * self.currentLevel.h) / 2
	g2d.translate(xOff, yOff)
	PhysicsScene.draw(self, g2d)
	g2d.pop()
end

function InGameScene:enter(from, levelNumberOrId)
	PhysicsScene.enter(self, from)
	if levelNumberOrId then self:switchToLevel(levelNumberOrId) end
end

------------------------------ API ------------------------------
function InGameScene:switchToLevel(levelNumberOrId)
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
	
	
	print("Entering level:", self.levelId)
	self:clearObjects()
	self.currentLevel = Level:loadLevel(self, self.levelId)
	for k, obj in ipairs(self.currentLevel:getObjects()) do
		self:addObject(obj)
	end
end

function InGameScene:gotoNextLevel()
	--abs -> If at special, go back to last normal level.
	self:switchToLevel(math.abs(self.currentLevelNumber) + 1)
end

------------------------------ Events ------------------------------
InGameScene[EvKeyPress] = function(self, e)
	if DEBUG.ALLOW_QUICK_EXIT and e.key == 'escape' then
		love.event.quit()
	end
end

------------------------------ Getters / Setters ------------------------------

return InGameScene