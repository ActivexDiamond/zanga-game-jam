local middleclass = require "libs.middleclass"
local PhysicsScene = require "scenes.PhysicsScene"

local EventSystem = require "cat-paw.core.patterns.event.EventSystem"
local EvKeyPress = require "cat-paw.core.patterns.event.keyboard.EvKeyPress"

------------------------------ Helpers ------------------------------

------------------------------ Constructor ------------------------------
local MainMenuScene = middleclass("MainMenuScene", PhysicsScene)
function MainMenuScene:initialize(...)
	PhysicsScene.initialize(self, ...)
	GAME:getEventSystem():attach(self, EventSystem.ATTACH_TO_ALL)
end

------------------------------ Core API ------------------------------
function MainMenuScene:enter(from, ...)
	PhysicsScene.enter(self, from, ...)
	print("At MainMenuScene.")
end

------------------------------ Events ------------------------------
MainMenuScene[EvKeyPress] = function(self, e)
	if DEBUG.ALLOW_QUICK_EXIT and e.key == 'escape' then
		love.event.quit()
	end
end
------------------------------ Getters / Setters ------------------------------

return MainMenuScene