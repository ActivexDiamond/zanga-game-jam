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
	if self.complete then self.scene:gotoNextLevel() end
end
------------------------------ Physics ------------------------------
function Goal:collisionFilter(other)
	return other.ID == "projectile" and 'touch' or nil
end

function Goal:onCollision(other, info)
	--Other should always be "projectile" due to the filter, but just to be safe.
	if other.ID == "projectile" then
		print("Level complete! Moving on...") 
		self.complete = true
	end
end


------------------------------ Getters / Setters ------------------------------

return Goal