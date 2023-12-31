------------------------------ Env Fixes & Console Setup ------------------------------
io.stdout:setvbuf('no')			--Fix for some terminals not flushing properly with Lua.
local lovebird = require "libs.lovebird"
--Call update immediately to not miss any prints from the creation of objects or importing of files.
lovebird:update()
------------------------------ Requires ------------------------------
local version = require "cat-paw.version"

------------------------------ Init Prints ------------------------------
print("CatPaw:", version)

------------------------------ Globals ------------------------------
DEBUG = {
	ALLOW_QUICK_EXIT = true,
	ALLOW_MOVEMENT = true,
	DEV_MODE = false,
	MULTI_SHOT = true,
	DRAW_LEVEL_OUTLINE = true,
}

------------------------------ Begin Execution ------------------------------
local Game = require "core.Game"

local GAME_NAME = "Spellcaster"
local TARGET_WINDOW_W = -1--1280
local TARGET_WINDOW_H = -1--800

Game(GAME_NAME, TARGET_WINDOW_W, TARGET_WINDOW_H)

