local middleclass = require "libs.middleclass"
local Object = require "core.Object"

local AssetRegistry = require "core.AssetRegistry"

local Vector = require "libs.Vector"

------------------------------ Helpers ------------------------------

------------------------------ Constructor ------------------------------
local WorldObject = middleclass("WorldObject", Object)
function WorldObject:initialize(id, scene, x, y)
	Object.initialize(self, id)
	self.scene = scene
	self.position = Vector(x, y)
	
	self.velocity = Vector(0, 0)
	self.currentFrame = 0
	self.rotation = 0
	self.spriteOffset = {x = 0, y = 0}
	self.flash = 0	
	self.flashColor = {1, 0, 0, 1}
	
	self.flipSpriteX = 1
	self.flipSpriteY = 1

	self:updateDrawingInfo()	
end

------------------------------ Constants ------------------------------
WorldObject.SPRITE_CENTER = {0.5, 0.5}
WorldObject.SPRITE_BOTTOM_CENTER = {0.5, 1}

------------------------------ Core API ------------------------------
function WorldObject:draw(g2d)
	Object.draw(self, g2d)
	if self.rect then
		g2d.setColor(0.3, 0.3, 0.3, 0.7)
		local mode = self.filled and "fill" or "line"
		g2d.rectangle(mode, self:getBoundingBox())
		g2d.setColor(1, 1, 1, 1)
	end

	local frame;
	if self.spr[0] and self.spr[0].typeOf and self.spr[0]:typeOf("Drawable") then
		frame = self.spr[self.currentFrame]
	else
		frame = self.spr
	end

	local sx = self.sx * self.flipSpriteX
	local sy = self.sy * self.flipSpriteY
	local x = self.position.x + self.w * self.spriteOffset.x
	local y = self.position.y + self.h * self.spriteOffset.y
	local ox = frame:getWidth() * self.spriteOffset.x 
	local oy = frame:getHeight() * self.spriteOffset.y
	
	
	if self.flash > 0 then
		g2d.setColor(self.flashColor)
		self.flash = self.flash - 1
	end
	g2d.draw(frame, x, y, self.rotation, sx, sy, ox, oy)
	g2d.setColor(1, 1, 1, 1)
end

------------------------------ Internals ------------------------------
-- Can be called with no args (if used in `init`, info was updated elsewhere, etc...
function WorldObject:updateDrawingInfo(w, h, useInvSpr)
	self.w = w or self.w
	self.h = h or self.h
	self.useInvSpr = useInvSpr or self.useInvSpr

	if self.useInvSpr then
		self.spr, self.sx, self.sy = AssetRegistry:getSprInv(self)
	else
		self.spr, self.sx, self.sy = AssetRegistry:getSprObj(self)
	end
end

------------------------------ Getters / Setters ------------------------------
function WorldObject:getPosition() return self.position end
function WorldObject:getRotation() return self.rotation end
--function WorldObject:getSpriteOffset() return self.spriteOffset end

function WorldObject:getCenter()
	return Vector(self.position.x + self.w / 2, 
			self.position.y + self.h / 2)
end
function WorldObject:getBoundingBox()
	local x = self.position.x
	local y = self.position.y
	local w = self.w
	local h = self.h
	return x, y, w, h
end

function WorldObject:setPosition(x, y)
	self.position.x = x
	self.position.y = y
end

function WorldObject:setRotation(r)
	self.rotation = r
end

--Either x/y (factors to be multiplied by the sprite's pre-scaling size) or a SPRITE_ constant.
function WorldObject:setSpriteOffset(a, b)
	if type(a) == 'table' then
		self.spriteOffset.x = a[1]
		self.spriteOffset.y = a[2]
	else
		self.spriteOffset.x = a
		self.spriteOffset.y = b
	end
end

return WorldObject