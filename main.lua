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

composer.setVariable("perfectHitSound", audio.loadSound("sounds/" .. settings.style .. "/perfect_hit.mp3"))
composer.setVariable("addWidthSound", audio.loadSound("sounds/" .. settings.style .. "/add_width.mp3"))

audio.setVolume(0.4)

-- Go to the menu screen
composer.gotoScene("menu")