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
	
	self.WIZARD = Wizard(self, 200, 200)
	self:addObject(self.WIZARD)
	self.currentLevel = nil
	--Load stats
	--Track stats, etc...
end

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

function InGameScene:enter(from, levelId)
	PhysicsScene.enter(self, from)
	print("Entering level:", levelId)
	
	self:clearObjects()
	self.currentLevel = Level:loadLevel(self, levelId)
	for k, obj in ipairs(self.currentLevel:getObjects()) do
		self:addObject(obj)
	end
end

------------------------------ Events ------------------------------
InGameScene[EvKeyPress] = function(self, e)
	if DEBUG.ALLOW_QUICK_EXIT and e.key == 'escape' then
		love.event.quit()
	end
end

------------------------------ Getters / Setters ------------------------------
	

return InGameScene