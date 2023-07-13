local middleclass = require "libs.middleclass"

local PhysicsScene = require "scenes.PhysicsScene"

local EventSystem = require "cat-paw.core.patterns.event.EventSystem"
local EvKeyPress = require "cat-paw.core.patterns.event.keyboard.EvKeyPress"

local Wizard = require "entities.Wizard"

------------------------------ Helpers ------------------------------

------------------------------ Constructor ------------------------------
local InGameScene = middleclass("InGameScene", PhysicsScene)
function InGameScene:initialize(...)
	PhysicsScene.initialize(self, ...)
	GAME:getEventSystem():attach(self, EventSystem.ATTACH_TO_ALL)
	
	self.WIZARD = Wizard(self, 200, 200)
	self:addObject(self.WIZARD)
end

------------------------------ Core API ------------------------------
function InGameScene:enter(from, ...)
	PhysicsScene.enter(self, from, ...)
	print("At MainMenuScene.")
end

------------------------------ Events ------------------------------
InGameScene[EvKeyPress] = function(self, e)
	if DEBUG.ALLOW_QUICK_EXIT and e.key == 'escape' then
		love.event.quit()
	end
end

------------------------------ Getters / Setters ------------------------------
	

return InGameScene