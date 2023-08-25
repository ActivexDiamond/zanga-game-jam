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
local MainMenuScene = middleclass("MainMenuScene", PhysicsScene)
function MainMenuScene:initialize(...)
	PhysicsScene.initialize(self, ...)
	GAME:getEventSystem():attach(self, EventSystem.ATTACH_TO_ALL)
	self.bgSpr = love.graphics.newImage("assets/spr/gui/main_menu.png")

	self.scale = 0.5
	local SW, SH = love.window.getMode()
	local w, h = self.bgSpr:getDimensions()
	self.xOffset = -(SH - w) / 8
	self.yOffset = 0
	self.btnStart = {x = 800, y = 800, w = 700, h = 250}
	self.btnExit = {x = 800, y = 1150, w = 700, h = 250}
end

------------------------------ Core API ------------------------------
function MainMenuScene:update(dt)
	if not love.mouse.isDown(1) then return end
	
	if mouseInRect(self, self.btnStart) then
		GAME:goTo(GAME.LEVEL_SELECT_MENU_SCENE_ID)
	end
	if mouseInRect(self, self.btnExit) then
		love.event.quit()
	end	
end

function MainMenuScene:draw(g2d)
	g2d.push('all')
	g2d.scale(self.scale)
	g2d.translate(self.xOffset, self.yOffset)

	g2d.draw(self.bgSpr, 0, 0)

	if self.d then	
		g2d.rectangle('fill', self.b1.x, self.b1.y, self.b1.w, self.b1.h)
		g2d.rectangle('fill', self.b2.x, self.b2.y, self.b2.w, self.b2.h)	
	end
	
	g2d.pop()
end
------------------------------ Events ------------------------------
MainMenuScene[EvKeyPress] = function(self, e)
	if e.key == 'escape' then
--		love.event.quit()
	end
end
------------------------------ Getters / Setters ------------------------------

return MainMenuScene