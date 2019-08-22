
local composer = require("composer")
local widget = require("widget")
local styles = require("styles")
local loadsave = require("loadsave")
local utils = require("utilities")

local scene = composer.newScene()

-- -----------------------------------------------------------------------------------
-- Code outside of the scene event functions below will only be executed ONCE unless
-- the scene is removed entirely (not recycled) via "composer.removeScene()"
-- -----------------------------------------------------------------------------------

local style = composer.getVariable("style")

local styleButtonsGroup
local frontGroup
local currentStyle = composer.getVariable("style")
local lastStyle = currentStyle

local BUTTON_WIDTH = 700
local BUTTON_HEIGHT = 250

local background
local menuButton

local styleButtons = {}

local settings

local function saveStyle()
	local settings = loadsave.loadTable("settings.json")
	settings.style = currentStyle
	loadsave.saveTable(settings, "settings.json")
end

local function gotoMenu()
	saveStyle()
	composer.setVariable("style", currentStyle)
	composer.removeHidden()
	composer.gotoScene( "menu", { time=300, effect="crossFade" } )
end

local function updateStyle()
	background.fill = styles[currentStyle].backgroundFill
	menuButton:removeSelf()
	menuButton = styles[currentStyle].whiteButton(
		display.contentCenterX,
		1200,
		350, "menu", gotoMenu
	)
	frontGroup:insert(menuButton)
end

local function createStyleButton(styleName)
	local isUnlocked = utils.contains(settings.unlockedStyles, styleName)
	local label = styleName
	local labelColor = styles[styleName].textFill

	local function touchHandler(event)
		if event.phase == "ended" then
			lastStyle = currentStyle
			currentStyle = styleName
			if lastStyle ~= currentStyle then
				updateStyle()

				event.target.borderImage:removeSelf()
				event.target.borderImage = display.newImage(
					event.target.parent,
					"images/styles/border_selected.png",
					event.target[1].x, event.target[1].y
				)	

				styleButtons[lastStyle].borderImage:removeSelf()
				styleButtons[lastStyle].borderImage = display.newImage(
					styleButtons[lastStyle],
					"images/styles/border_default.png",
					styleButtons[lastStyle][1].x,
					styleButtons[lastStyle][1].y
				)	
			end
		end
	end

	local button = display.newGroup()
	local margin = 10

	local styleImage = display.newImage(
		button, "images/styles/" .. styleName .. ".png",
		display.contentCenterX,
		(BUTTON_HEIGHT + margin) * (styleButtonsGroup.numChildren + 0.5)
	)

	local borderFilename
	if styleName == style then
		borderFilename = "images/styles/border_selected.png"
	else
		borderFilename = "images/styles/border_default.png"
	end

	local borderImage = display.newImage(
		button, borderFilename,
		styleImage.x, styleImage.y
	)

	button.borderImage = borderImage

	if not isUnlocked then
		label = "locked"
		labelColor = {1, 0.3, 0.3}

		local buttonCond = display.newText(
			{
				parent = button,
				text = styles[styleName].conditionText,
				x = display.contentCenterX,
				y = (BUTTON_HEIGHT + margin) * (styleButtonsGroup.numChildren + 0.85),
				font = styles[styleName].font,
				fontSize = 50,
				align = "center"
			}
		)
		buttonCond:setFillColor(0, 0, 0)
	else
		button:addEventListener("touch", touchHandler)
	end

	local buttonLabel = display.newText(
		{
			parent = button,
			text = label,
			x = display.contentCenterX,
			y = (BUTTON_HEIGHT + margin) * (styleButtonsGroup.numChildren + 0.25),
			font = styles[styleName].font,
			fontSize = 70,
			align = "center"
		}
	)
	buttonLabel.fill = labelColor

	styleButtons[styleName] = button
	styleButtonsGroup:insert(button)
end
-- -----------------------------------------------------------------------------------
-- Scene event functions
-- -----------------------------------------------------------------------------------

-- create()
function scene:create(event)

	local sceneGroup = self.view
	-- Code here runs when the scene is first created but has not yet appeared on screen

	background = display.newRect(
		sceneGroup, 
		display.contentCenterX,
		display.contentCenterY,
		720,
		1280
	)
	background.fill = styles[style].backgroundFill

	frontGroup = display.newGroup()
	sceneGroup:insert(frontGroup)

	menuButton = styles[style].whiteButton(
		display.contentCenterX,
		1200,
		350, "menu", gotoMenu
	)
	frontGroup:insert(menuButton)

	styleButtonsGroup = display.newGroup()
	sceneGroup:insert(styleButtonsGroup)

	settings = loadsave.loadTable("settings.json")

	for styleName in pairs(styles) do
		createStyleButton(styleName)
	end

end


-- show()
function scene:show(event)

	local sceneGroup = self.view
	local phase = event.phase

	if (phase == "will") then
		-- Code here runs when the scene is still off screen (but is about to come on screen)

	elseif (phase == "did") then
		-- Code here runs when the scene is entirely on screen

	end
end


-- hide()
function scene:hide(event)

	local sceneGroup = self.view
	local phase = event.phase

	if (phase == "will") then
		-- Code here runs when the scene is on screen (but is about to go off screen)

	elseif (phase == "did") then
		-- Code here runs immediately after the scene goes entirely off screen

	end
end


-- destroy()
function scene:destroy(event)

	local sceneGroup = self.view
	-- Code here runs prior to the removal of scene's view

end


-- -----------------------------------------------------------------------------------
-- Scene event function listeners
-- -----------------------------------------------------------------------------------
scene:addEventListener("create", scene)
scene:addEventListener("show", scene)
scene:addEventListener("hide", scene)
scene:addEventListener("destroy", scene)
-- -----------------------------------------------------------------------------------

return scene
