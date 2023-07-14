local middleclass = require "libs.middleclass"
local WorldObject = require "core.WorldObject"

local Vector = require "libs.Vector"

------------------------------ Helpers ------------------------------

------------------------------ Constructor ------------------------------
local Goal = middleclass("Goal", WorldObject)
function Goal:initialize(scene, x, y)
	WorldObject.initialize(self, "goal", scene, x, y)
end

------------------------------ Core API ------------------------------
function Goal:update(dt)
	WorldObject.update(self, dt)
end


function Goal:draw(g2d)
	WorldObject.draw(self, g2d)
end

------------------------------ API ------------------------------


------------------------------ Getters / Setters ------------------------------

return Goal