local middleclass = require "libs.middleclass"
local PhysicsScene = require "scenes.PhysicsScene"

local EventSystem = require "cat-paw.core.patterns.event.EventSystem"
local EvKeyPress = require "cat-paw.core.patterns.event.keyboard.EvKeyPress"

------------------------------ Helpers ------------------------------
local function mouseInRect(self, t)
	local x, y = love.mouse.getPosition()
	x = x / self.scale - self.xOffset
	y = y / self.scale - self.yOffset
	
	return t.x <= x and x <= t.x + t.w and t.y <= y and y <= t.y + t.h
end

------------------------------ Constructor ------------------------------
local LevelSelectMenuScene = middleclass("LevelSelectMenuScene", PhysicsScene)
function LevelSelectMenuScene:initialize(...)
	PhysicsScene.initialize(self, ...)
	GAME:getEventSystem():attach(self, EventSystem.ATTACH_TO_ALL)
	self.bgSpr = love.graphics.newImage("assets/spr/gui/level_select_menu_cropped.png")

	self.scale = 0.8
	local SW, SH = love.window.getMode()
	local w, h = self.bgSpr:getDimensions()
	self.xOffset = -(SH - w) / 8 + 20
	self.yOffset = 0
--	self.d = true
	self.levels = {
		{x = 40, y = 350, w = 220, h = 220},
		{x = 440, y = 350, w = 220, h = 220},
		{x = 800, y = 350, w = 220, h = 220},
		{x = 1100, y = 350, w = 220, h = 220},

		{x = 40, y = 650, w = 220, h = 220},
		{x = 440, y = 650, w = 220, h = 220},
		{x = 800, y = 650, w = 220, h = 220},
		{x = 1100, y = 650, w = 220, h = 220},
	}
end

------------------------------ Core API ------------------------------
function LevelSelectMenuScene:update(dt)
	self.cooldown = self.cooldown - dt
	if self.cooldown > 0 then return end
	if not love.mouse.isDown(1) then return end

	for k, r in ipairs(self.levels) do
		if mouseInRect(self, r) then
--			local id = "level" .. k
			GAME:goTo(GAME.IN_GAME_SCENE_ID, k)
			return 
		end	
	end	
end

function LevelSelectMenuScene:draw(g2d)
	g2d.push('all')
	g2d.scale(self.scale)
	g2d.translate(self.xOffset, self.yOffset)

	g2d.draw(self.bgSpr, 0, 0)

	if self.d then	
		for _, r in ipairs(self.levels) do
			g2d.rectangle('fill', r.x, r.y, r.w, r.h)
		end
	end
	
	g2d.pop()
end

function LevelSelectMenuScene:enter(args)
	self.cooldown = 0.5
end
------------------------------ Events ------------------------------
LevelSelectMenuScene[EvKeyPress] = function(self, e)
	if e.key == 'escape' then
--		love.event.quit()
	end
end
------------------------------ Getters / Setters ------------------------------

return LevelSelectMenuScene