local middleclass = require "libs.middleclass"
local Scene = require "scenes.Scene"

local EventSystem = require "cat-paw.core.patterns.event.EventSystem"
local EvKeyPress = require "cat-paw.core.patterns.event.keyboard.EvKeyPress"

------------------------------ Helpers ------------------------------

------------------------------ Constructor ------------------------------
local MainMenuScene = middleclass("MainMenuScene", Scene)
function MainMenuScene:initialize(...)
	Scene.initialize(self, ...)
	GAME:getEventSystem():attach(self, EventSystem.ATTACH_TO_ALL)
end

------------------------------ Core API ------------------------------
function MainMenuScene:enter(from, ...)
	Scene.enter(self, from, ...)
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