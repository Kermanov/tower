-----------------------------------------------------------------------------------------
--
-- main.lua
--
-----------------------------------------------------------------------------------------

-- Your code here

local composer = require("composer")
local loadsave = require("loadsave")
local styles = require("styles")

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

composer.setVariable("perfectHitSound", audio.loadSound(styles[settings.style].sounds.perfectHit))
composer.setVariable("addWidthSound", audio.loadSound(styles[settings.style].sounds.addWidth))

audio.setVolume(0.4)

-- Go to the menu screen
composer.gotoScene("menu")