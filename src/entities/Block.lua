local middleclass = require "libs.middleclass"
local WorldObject = require "core.WorldObject"

local Vector = require "libs.Vector"

------------------------------ Helpers ------------------------------

------------------------------ Constructor ------------------------------
local Block = middleclass("Block", WorldObject)
function Block:initialize(scene, id, x, y)
	WorldObject.initialize(self, id, scene, x, y)
end

------------------------------ Core API ------------------------------
function Block:update(dt)
	WorldObject.update(self, dt)
end


function Block:draw(g2d)
	WorldObject.draw(self, g2d)
end

------------------------------ API ------------------------------


------------------------------ Getters / Setters ------------------------------

return Block