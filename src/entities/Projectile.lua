local middleclass = require "libs.middleclass"
local WorldObject = require "core.WorldObject"


------------------------------ Constructor ------------------------------
local Projectile = middleclass("Projectile", WorldObject)
function Projectile:initialize(scene, x, y, dir, opt)
	WorldObject.initialize(self, "projectile", scene, x, y)
	self.direction = dir
	for k, v in pairs(opt) do
		self[k] = v
	end
end

------------------------------ Core API ------------------------------
function Projectile:update(dt)
	self.velocity = self.direction * self.speed
end
------------------------------ Physics ------------------------------
function Projectile:collisionFilter(other)
	if other.ID == "wizard" or other.ID == "projectile" then
		return nil
	end
	for id, filter in pairs(self.filters) do
		if other.ID == id then return filter end
	end
	
	return 'slide'
end

function Projectile:onCollision(other, info)
	for id, skill in pairs(self.rules) do
		if other.ID == id then skill(self, other, info) end
	end
end

------------------------------ Getters / Setters ------------------------------

return Projectile