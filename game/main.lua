--============================ Env Setup ==============================
print("Setting stdout's vbuf mode to 'no'. This is needed for some consoles to work properly.")
io.stdout:setvbuf("no")

local extraPaths = "src/?.lua;src/?/init.lua;"
package.path = extraPaths .. package.path
--Love adds 2 extra loaders which are used for searching the .love archive and what not.
--They are not affected by `package.path`.
love.filesystem.setRequirePath(extraPaths .. love.filesystem.getRequirePath())

--[===[
local lovebird = require "libs.lovebird"
--Call update immediately to not miss any prints from the creation of objects or importing of files.
lovebird:update()
--]===]


--============================ Version Printers ==============================
local version = require "cat-paw.version"

print("============================================================")
print("Running Lua version:      ", _VERSION)
if jit then
	print("Running Luajit version:   ", jit.version)
end

print("Running Love2d version: ", love.getVersion())
print("Running CatPaw version: ", version)
print("\nCurrently using the following 3rd-party libraries (and possibly more):")
print("middleclass\tBy Kikito\tSingle inheritance OOP in Lua\t[MIT License]")
print("bump\t\tBy Kikito\tSimple platformer physics.\t[MIT License]")
print("suit\t\tBy vrld\t\tImGUIs for Lua/Love2D\t\t[MIT License]")
print("Huge thanks to (Kikito and vrld) for their wonderful contributions to the community; and for releasing their work under such open licenses!")
print("============================================================")	

------------------------------ Globals ------------------------------
DEBUG = {
	ALLOW_QUICK_EXIT = true,
	ALLOW_MOVEMENT = true,
	DEV_MODE = false,
	MULTI_SHOT = true,
	DRAW_LEVEL_OUTLINE = true,
}

------------------------------ Entry Point ------------------------------
local Game = require "core.Game"

local GAME_NAME = "Spellcaster"
local TARGET_WINDOW_W = -1--1280
local TARGET_WINDOW_H = -1--800

Game(GAME_NAME, TARGET_WINDOW_W, TARGET_WINDOW_H)

