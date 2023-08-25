local middleclass = require "libs.middleclass"
local State = require "cat-paw.core.patterns.state.State"
local utils = require "libs.utils"
local bump = require "libs.bump"

local WorldObject = require "core.WorldObject"

local Event = require "cat-paw.core.patterns.event.Event"
local EvSceneObjectAdd = require "events.EvSceneObjectAdd"
local EvSceneObjectRemove = require "events.EvSceneObjectRemove"

------------------------------ Helpers ------------------------------

------------------------------ Constructor ------------------------------
local PhysicsScene = middleclass("PhysicsScene", State)
function PhysicsScene:initialize()
	State.initialize(self)
	--GAME:getEventSystem():attach(self, {Event})
	self.objects = {}
	self.bumpWorld = bump.newWorld()
	self.objectsToAdd = {}
	self.objectsToRemove = {}
end

------------------------------ Core API ------------------------------
local function defaultCollisionFilter() return "cross" end

function PhysicsScene:update(dt)
	State.update(self, dt)
	
	for obj, _ in pairs(self.objects) do
		obj:update(dt)
	end
	
	for k, obj in ipairs(self.bumpWorld:getItems()) do
		local targetPos = obj.position + obj.velocity * dt
		local x, y, cols, len = self.bumpWorld:move(obj, targetPos.x, targetPos.y, 
				obj.collisionFilter or defaultCollisionFilter)
		obj:setPosition(x, y)
		if len > 0 then 
			for k, col in ipairs(cols) do
				if obj.onCollision then obj:onCollision(col.other, col) end
				if col.other.onCollision then col.other:onCollision(obj, col) end
			end	
		end
	end
	self:_processQueuedObjects()
end

function PhysicsScene:draw(g2d)
	State.draw(self, g2d)
--	local depthSorted = self.bumpWorld:getItems()
--	table.sort(depthSorted, function(a, b)
--		if not (a.depth and b.depth) then 
--			return true		--Doesn't really matter, they don't have depth values.
--		end
--		return a.depth < b.depth
--	end)
	for obj, _ in pairs(self.objects) do
		obj:draw(g2d)
	end
end

------------------------------ API ------------------------------
function PhysicsScene:enter(from, ...)
	State.enter(self, from, ...)
	for obj, _ in pairs(self.objects) do
		if obj.onSceneEnter then obj:onSceneEnter(from, ...) end
	end
end

function PhysicsScene:leave(to)
	State.leave(self, to)
	for obj, _ in pairs(self.objects) do
		if obj.onSceneLeave then obj:onSceneLeave(to) end
	end
end

function PhysicsScene:activate(fsm)
	State.activate(self, fsm)
	for obj, _ in pairs(self.objects) do
		if obj.onSceneActivate then obj:onSceneActivate(fsm) end
	end
end

function PhysicsScene:destroy()
	State.destroy(self)
	for obj, _ in pairs(self.objects) do
		if obj.onSceneDestroy then obj:onSceneDestroy() end
	end
end

------------------------------ Object API ------------------------------
function PhysicsScene:addObject(obj)
	self.objectsToAdd[obj] = true
end

function PhysicsScene:removeObject(obj)
	self.objectsToRemove[obj] = true
end

------------------------------ Internals ------------------------------
function PhysicsScene:_processQueuedObjects()
	for obj, _ in pairs(self.objectsToRemove) do
		if not self.objects[obj] then goto continue end
		self.objects[obj] = nil
		if self.bumpWorld:hasItem(obj) then
			self.bumpWorld:remove(obj)
		end
		GAME:getEventSystem():queue(EvSceneObjectRemove(self, obj))
		::continue::
	end
	--TODO: Check if removing the objects is faster than resetting the table.
	self.objectsToRemove = {}

	for obj, _ in pairs(self.objectsToAdd) do
		self.objects[obj] = true
		if obj:isInstanceOf(WorldObject) then
			self.bumpWorld:add(obj, obj.position.x, obj.position.y, obj.w, obj.h)
		end
		GAME:getEventSystem():queue(EvSceneObjectAdd(self, obj))
	end
	self.objectsToAdd = {}
end

------------------------------ Getters / Setters ------------------------------
-- Returns a direct reference to its internal buffer. Changes will be reflected!
function PhysicsScene:getObjects() return self.bumpWorld:getItems() end

-- `protection` Just in case someone confuses this with `removeObject`.
-- Note calling this will also invalidate any reference to the buffer previously
-- gotten through `getObjects()`
function PhysicsScene:clearObjects(protection)
	if protection then
		error("You seem to have passed something. Did you mean to call `Scene:removeObject(obj`)?"
				.. "\nCareful, this clears the entire object buffer!")
	end
	
	for obj, _ in pairs(self.objects) do
		obj:onRemove()
	end
	
	self.bumpWorld = bump.newWorld(32)
	self.objects = {}
	self.bumpWorld = bump.newWorld()
	self.objectsToAdd = {}
	self.objectsToRemove = {}	
end

return PhysicsScene