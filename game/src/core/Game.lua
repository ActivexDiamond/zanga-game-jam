local middleclass = require "libs.middleclass"
local Slab = require "libs.Slab"

local AbstractGame = require "cat-paw.engine.AbstractGame"

local MainMenuScene = require "scenes.MainMenuScene"
local LevelSelectMenuScene = require "scenes.LevelSelectMenuScene"
local InGameScene = require "scenes.InGameScene"

local EvWindowResize = require "cat-paw.core.patterns.event.os.EvWindowResize"
--local shack = require "libs.shack"

------------------------------ Constructor ------------------------------
local Game = middleclass("Game", AbstractGame)
function Game:initialize(title, targetWindowW, targetWindowH, seed)
	AbstractGame.initialize(self, title, targetWindowW, targetWindowH)
	self.SEED = seed or os.time()
	math.randomseed(self.SEED)
	self:_loadAllAssets()
	
	self.fonts = {
		love.graphics.newFont("assets/fonts/Alice_in_Wonderland_3.ttf"),
		love.graphics.newFont("assets/fonts/Mercy Christole.ttf"),
		love.graphics.newFont("assets/fonts/Minecrafter.Reg.ttf"),
		love.graphics.newFont("assets/fonts/OldLondon.ttf"),
		love.graphics.newFont("assets/fonts/Starborn.ttf"),
		love.graphics.newFont("assets/fonts/Alice_in_Wonderland_3.ttf"),
	}
	
--	for k, v in ipairs(self.fonts) do
--		v:setFilter('linear', 'nearest')
--	end
	
	self.currentFont = 3
	love.graphics.setFont(self.fonts[self.currentFont])
	
	Slab.Initialize()
	Slab.SetINIStatePath(nil)
	
	self.xOffset = 0
	self.yOffset = 0
	self.scale = 2
	
	GAME = self
	self:add(Game.MAIN_MENU_SCENE_ID, MainMenuScene())
	self:add(Game.LEVEL_SELECT_MENU_SCENE_ID, LevelSelectMenuScene())
	self:add(Game.IN_GAME_SCENE_ID, InGameScene())
	
	if DEBUG.DEV_MODE then
		self:goTo(Game.IN_GAME_SCENE_ID, "level1")
	else
		self:goTo(Game.MAIN_MENU_SCENE_ID)
	end
--	self:goTo(Game.LEVEL_SELECT_MENU_SCENE_ID)	
end

------------------------------ Constants ------------------------------
Game.MAIN_MENU_SCENE_ID = 0
Game.LEVEL_SELECT_MENU_SCENE_ID = 1
Game.IN_GAME_SCENE_ID = 2

Game.GRID_SIZE = 32

------------------------------ Core API ------------------------------
function Game:update(dt)
	Slab.Update(dt)
	AbstractGame.update(self, dt)
end

function Game:draw()
	local g2d = love.graphics
	AbstractGame.draw(self, g2d)
	g2d.push('all')
	Slab.Draw()
	g2d.pop()
end

------------------------------ Internals ------------------------------
function AbstractGame:_loadAllAssets()
	local tAll, tData, tInv, tObj, tGui
	local time = love.timer.getTime
	
	tAll = time() 
	local DataRegistry = require "core.DataRegistry"
	print "------------------------------ Loading Data... ------------------------------"
		tData = time(); DataRegistry:loadData(); tData = time() - tData
	print "Done!\n"
		
	local AssetRegistry = require "core.AssetRegistry"
	print "------------------------------ Loading Sprites (inv)... ------------------------------"
	tInv = time(); AssetRegistry:loadSprInv(); tInv = time() - tInv
	
	print "------------------------------ Loading Sprites (obj)... ------------------------------"
	tObj = time(); AssetRegistry:loadSprObj(); tObj = time() - tObj
	
	print "------------------------------ Loading Sprites (gui)... ------------------------------"
		tGui = time(); AssetRegistry:loadSprGui(); tGui = time() - tGui
	print "Done!"
	tAll = time() - tAll
	
local str = string.format([[
------------------------------------------------------------
	Loading dat took: %.2fms
	Loading Inv took: %.2fms
	Loading Obj took: %.2fms
	Loading Gui took: %.2fms
	>Total load-time: %.4fs
------------------------------------------------------------
	]], tData*1e3, tInv*1e3, tObj*1e3, tGui*1e3, tAll)
	print(str)
end

return Game
