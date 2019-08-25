-----------------------------------------------------------------------------------------
--
-- main.lua
--
-----------------------------------------------------------------------------------------

-- Your code here

local composer = require("composer")
local loadsave = require("loadsave")
local styles = require("styles")
local graphics = require("graphics")

-- Hide status bar
display.setStatusBar( display.HiddenStatusBar )

-- read settings file and setup some variables
local settings = loadsave.loadTable("settings.json")
if settings then
	composer.setVariable("style", settings.style)
else
	settings = {}
	settings.style = "classic"
	settings.unlockedStyles = {"classic"}
	settings.sounds = true

	loadsave.saveTable(settings, "settings.json")
	composer.setVariable("style", "classic")
end

-- load sounds
composer.setVariable("perfectHitSound", audio.loadSound(styles[settings.style].sounds.perfectHit))
composer.setVariable("addWidthSound", audio.loadSound(styles[settings.style].sounds.addWidth))

if settings.sounds then
	audio.setVolume(0.4)
else
	audio.setVolume(0)
end

-- Go to the menu screen
composer.gotoScene("menu")