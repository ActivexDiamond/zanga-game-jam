local middleclass = require "libs.middleclass"
local WorldObject = require "core.WorldObject"

local Vector = require "libs.Vector"

local EvMousePress = require "cat-paw.core.patterns.event.mouse.EvMousePress"

local Projectile = require "entities.Projectile"

------------------------------ Skills ------------------------------
local function destroy(prj, other, info)
	prj.scene:removeObject(other)
end

local function deflect(prj, other, info)
	local n = Vector(info.normal.x, info.normal.y).angle
	if info.normal.x == -1 then	
		prj.direction.angle = n - prj.direction.angle
	elseif info.normal.y == -1 then
		prj.direction.angle = n - prj.direction.angle + math.pi/2
	else	--If normal.x==1 or normal.y==1 
		prj.direction.angle = n + (n - prj.direction.angle) + math.pi
	end
end

local function SKILL(prj, other)

end

--The collision filter for each skill.
local FILTERS = {
	[destroy] = "cross",
	[deflect] = "slide",
}

------------------------------ Constructor ------------------------------
local Wizard = middleclass("Wizard", WorldObject)
function Wizard:initialize(scene, x, y)
	WorldObject.initialize(self, "wizard", scene, x, y)
	print("Spawned wizard at: ", self.position)
end

------------------------------ Core API ------------------------------
function Wizard:update(dt)
	WorldObject.update(self, dt)
	local isDown = love.keyboard.isDown 
	if DEBUG.ALLOW_MOVEMENT or self.scene.levelId == "level_win" then
		local dirX, dirY = 0, 0
		if isDown('w') then dirY = dirY - 1 end
		if isDown('s') then dirY = dirY + 1 end
		if isDown('d') then dirX = dirX + 1 end
		if isDown('a') then dirX = dirX - 1 end
		self.velocity = Vector(dirX * self.speed, dirY * self.speed)
	end 
end


function Wizard:draw(g2d)
	WorldObject.draw(self, g2d)
end

------------------------------ Physics ------------------------------
function Wizard:collisionFilter(other)
	if other.ID == "projectile" then
		return nil
	end
	return 'slide'
end

------------------------------ Internals ------------------------------
function Wizard:_spawnProjectile(towards)
	local pos = self:getCenter()
	local dir = (towards - pos).normalized
	self.scene:addObject(Projectile(self.scene, pos.x, pos.y, dir,
			self:_getProjectileOpt()))	
end

function Wizard:_getProjectileOpt()
	local t = {
		speed = self.projectileSpeed,
		rules = {
			--object_id = callback for skill
			wood_tile = deflect,
			stone_tile = destroy,
		}
	}
	
	t.filters = {}
	for id, skill in pairs(t.rules) do
		t.filters[id] = FILTERS[skill]
	end
	
	return t
end
------------------------------ Callbacks ------------------------------
Wizard[EvMousePress] = function(self, e)
	if e.button == 1 then
		--Account for translate needed to center the level.
		--TODO: Just use cameras!
		local SW, SH = love.window.getMode()
		local xOff = (SW - GAME.GRID_SIZE * self.scene.currentLevel.w) / 2
		local yOff = (SH - GAME.GRID_SIZE * self.scene.currentLevel.h) / 2 
	
		self:_spawnProjectile(Vector(e.x - xOff, e.y - yOff))
	end

end

------------------------------ Getters / Setters ------------------------------

return Wizard