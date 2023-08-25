local middleclass = require "libs.middleclass"
local WorldObject = require "core.WorldObject"

local AssetRegistry = require "core.AssetRegistry"

local Vector = require "libs.Vector"

local EvMousePress = require "cat-paw.core.patterns.event.mouse.EvMousePress"
local EvKeyPress = require "cat-paw.core.patterns.event.keyboard.EvKeyPress"

local Projectile = require "entities.Projectile"

------------------------------ Constructor ------------------------------
local Wizard = middleclass("Wizard", WorldObject)
function Wizard:initialize(scene, x, y)
	WorldObject.initialize(self, "wizard", scene, x, y)
	self.canShoot = true
	self.jump = 0
	
	self.mainSprite = self.spr
	self.idleCapeAnimation = {
		frames = AssetRegistry:getSprObj({ID = "wizard_idle_cape", currentFrame = 0, w = self.w, h = self.h}),
		fps = 7,
	}
	self.idleOrbAnimation = {
		frames = AssetRegistry:getSprObj({ID = "wizard_idle_orb", currentFrame = 0, w = self.w, h = self.h}),
		fps = 7,
	}
	
	self.attackAnimation = {
		frames = AssetRegistry:getSprObj({ID = "wizard_attack", currentFrame = 0, w = self.w, h = self.h}),
		first = 1,
		fps = 4,
	}
	self.flipSpriteX = -1
	self.spriteOffset.x = 0.5
	print("Spawned wizard at: ", self.position)
end

------------------------------ Core API ------------------------------
function Wizard:update(dt)
	WorldObject.update(self, dt)
	self:_updateAnimation(dt)
	
	if not self.activeAnimation and math.random() < 0.02 then
		local anim = math.random(1, 2) == 1 
				and self.idleCapeAnimation or self.idleOrbAnimation
		self:startAnimation(anim)
	end
	
	local isDown = love.keyboard.isDown 
	if DEBUG.ALLOW_MOVEMENT or self.scene.levelId == "level_win" then
		local dirX = 0
		if isDown('d') then dirX = dirX + 1 end
		if isDown('a') then dirX = dirX - 1 end
		local y = self.gravity
		if self.jump > 0 then
			y = y - self.jumpPower
		end
		self.jump = self.jump - 1
		self.velocity = Vector(dirX * self.speed, y)
	end 
if self.showSpellbook then self.scene.SPELLBOOK:update(dt) end

if self.shouldReload then self.scene:reloadLevel() end
end


function Wizard:draw(g2d)
	WorldObject.draw(self, g2d)
end

------------------------------ Animation ------------------------------
function Wizard:startAnimation(anim)
	self.animationFirstFrame = anim.first or 0
	self.animationLastFrame = anim.last or #anim.frames
	self.animationTime = 0
	
	self.animationInterval = 1 / anim.fps
	self.spr = anim.frames
	self.currentFrame = self.animationFirstFrame
	self.activeAnimation = anim
end

function Wizard:cancelAnimation()
	self.spr = self.mainSprite
	self.activeAnimation = nil
	self.currentFrame = 0
end

function Wizard:_updateAnimation(dt)
	if not self.activeAnimation then return end
	self.animationTime = self.animationTime + dt
	if self.animationTime >= self.animationInterval then
		self.currentFrame = self.currentFrame + 1
		self.animationTime = 0
		if self.currentFrame > self.animationLastFrame then 
			self:cancelAnimation() 
		end
	end
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
	pos.x = pos.x + GAME.GRID_SIZE * 0.5
	local dir = (towards - pos).normalized
	local prj = Projectile(self.scene, pos.x, pos.y, dir,
			self, self.scene.SPELLBOOK:_getProjectileOpt())
--	prj.position.x = prj.position.x - prj.w
--	prj.position.y = prj.position.y - prj.h
	 
	self.scene:addObject(prj)
	
	self:cancelAnimation()
	self:startAnimation(self.attackAnimation)
	self.canShoot = false	
end

function Wizard:_onProjectileRemoval()
	self.canShoot = true
	self.shouldReload = true
end
------------------------------ Callbacks ------------------------------
Wizard[EvKeyPress] = function(self, e)
	if e.key == 'e' then
		self.showSpellbook = not self.showSpellbook
	elseif e.key == 'space' and self.jump <= self.jumpCooldown then
		self.jump = self.jumpFrames
	end
end

Wizard[EvMousePress] = function(self, e)
	if self.showSpellbook then return end
	
	if e.button == 1 and (self.canShoot or self.scene.levelId == "level_win" or DEBUG.MULTI_SHOT) then
		--Account for translate needed to center the level.
		--TODO: Just use cameras!
		local x = e.x / GAME.scale - GAME.xOffset
		local y = e.y / GAME.scale - GAME.yOffset
		self:_spawnProjectile(Vector(x, y))
	end

end

------------------------------ Getters / Setters ------------------------------

return Wizard