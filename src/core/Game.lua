local middleclass = require "libs.middleclass"

local AbstractGame = require "cat-paw.engine.AbstractGame"

local MainMenuScene = require "scenes.MainMenuScene"
local InGameScene = require "scenes.InGameScene"

--local shack = require "libs.shack"


------------------------------ Constructor ------------------------------
local Game = middleclass("Game", AbstractGame)
function Game:initialize(seed, ...)
	AbstractGame.initialize(self, ...)
	self.SEED = seed or os.time()
	math.randomseed(self.SEED)
	self:_loadAllAssets()
	
	GAME = self
	self:add(Game.MAIN_MENU_SCENE_ID, MainMenuScene())
	self:add(Game.IN_GAME_SCENE_ID, InGameScene())
	
	self:goTo(Game.MAIN_MENU_SCENE_ID)
	--self:goTo(Game.IN_GAME_SCENE_ID)
end

------------------------------ Constants ------------------------------
Game.MAIN_MENU_SCENE_ID = 0
Game.IN_GAME_SCENE_ID = 1

------------------------------ Core API ------------------------------
--[[
function Game:update(dt)
	AbstractGame.update(self, dt)
	shack:update(dt)
end

function Game:draw()
	local g2d = love.graphics
	shack:apply()
	AbstractGame.draw(self, g2d)
end
--]]
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

------------------------------ Getters / Setters ------------------------------

return Game
