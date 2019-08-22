-----------------------------------------------------------------------------------------
--
-- main.lua
--
-----------------------------------------------------------------------------------------

-- Your code here

local composer = require("composer")
local loadsave = require("loadsave")

-- Hide status bar
display.setStatusBar( display.HiddenStatusBar )

-- read settings file and setup some variables
local settings = loadsave.loadTable("settings.json")
if settings then
	composer.setVariable("style", settings.style)
else
	local settings = {}
	settings.style = "classic"
	settings.unlockedStyles = {"classic"}

	loadsave.saveTable(settings, "settings.json")
	composer.setVariable("style", "classic")
end

-- Go to the menu screen
composer.gotoScene("menu")