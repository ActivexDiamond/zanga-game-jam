local middleclass = require "libs.middleclass"
local WorldObject = require "core.WorldObject"


------------------------------ Constructor ------------------------------
local Projectile = middleclass("Projectile", WorldObject)
function Projectile:initialize(scene, x, y, dir, parent, opt)
	WorldObject.initialize(self, "projectile", scene, x, y)
	self.direction = dir
	for k, v in pairs(opt) do
		self[k] = v
	end
	self.parent = parent
	self:setSpriteOffset(self.SPRITE_CENTER)
end

------------------------------ Core API ------------------------------
function Projectile:update(dt)
	local x, y = self.position.x, self.position.y
	local w = self.scene.currentLevel.w * GAME.GRID_SIZE
	local h = self.scene.currentLevel.h * GAME.GRID_SIZE
	if self.position.x < 0 or self.position.x + self.w > w or
			self.position.y < 0 or self.position.y + self.h > h then
		self:_remove()
	end	 
	self.rotation = self.rotation + math.pi * 0.1
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

------------------------------ Internals ------------------------------
function Projectile:_remove()
	self.scene:removeObject(self)
	self.parent:_onProjectileRemoval()
end

------------------------------ Getters / Setters ------------------------------

return Projectile