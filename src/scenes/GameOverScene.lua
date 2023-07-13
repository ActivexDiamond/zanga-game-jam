local middleclass = require "libs.middleclass"
local PhysicsScene = require "scenes.PhysicsScene"

local EventSystem = require "cat-paw.core.patterns.event.EventSystem"
local EvKeyPress = require "cat-paw.core.patterns.event.keyboard.EvKeyPress"

------------------------------ Helpers ------------------------------

------------------------------ Constructor ------------------------------
local GameOverScene = middleclass("GameOverScreen", PhysicsScene)
function GameOverScene:initialize(...)
    PhysicsScene.initialize(self, ...)
    GAME:getEventSystem():attach(self, EventSystem.ATTACH_TO_ALL)
end

------------------------------ Core API ------------------------------
function GameOverScene:draw(g2d)
    PhysicsScene.draw(self, g2d)

    g2d.push()
    g2d.scale(2)
    g2d.print("Game Over!", GAME.windowW / 2 - 50, GAME.windowH / 2)
    g2d.pop()
end

------------------------------ Events ------------------------------
GameOverScene[EvKeyPress] = function(self, e)
	if DEBUG.ALLOW_QUICK_EXIT and e.key == 'escape' then
		love.event.quit()
	end
end
------------------------------ Getters / Setters ------------------------------

return GameOverScene