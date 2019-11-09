
local composer = require("composer")
local styles = require("styles")
local utils = require("utilities")
local uiElements = require("ui_elements")
local const = require("constants")
local widget = require("widget")

local scene = composer.newScene()

-- -----------------------------------------------------------------------------------
-- Code outside of the scene event functions below will only be executed ONCE unless
-- the scene is removed entirely (not recycled) via "composer.removeScene()"
-- -----------------------------------------------------------------------------------

local style = composer.getVariable("style")

local soundCheckbox

local function gotoGame()
	composer.gotoScene( "game", { time=const.SCENE_TRANS_SPEED, effect="slideLeft" } )
end

local function gotoHighscore()
	composer.gotoScene( "highscore", { time=const.SCENE_TRANS_SPEED, effect="slideRight" } )
end

local function gotoStyles()
	composer.gotoScene( "styles_screen", { time=const.SCENE_TRANS_SPEED, effect="crossFade" } )
end

local function gotoInfo()
	composer.showOverlay(
		"alert",
		{
			effect = "zoomOutIn",
			time = 100,
			isModal = true,
			params = 
			{
				title = "about",
				text = 	"This simple game was designed to test the capabilities of the Corona SDK framework.\n" ..
						"If you notice any bugs or shortcomings, please write about this in the reviews.\n" ..
						"All the best and enjoy the game!"
			}
		}
	)
end

local function onSuspendExit(event)
	if event.type == "applicationSuspend" or 
	event.type == "applicationExit" then
		utils.saveSettings({sounds = audio.getVolume() > 0})
	end
end

-- -----------------------------------------------------------------------------------
-- Scene event functions
-- -----------------------------------------------------------------------------------

-- create()
function scene:create( event )

	local sceneGroup = self.view
	-- Code here runs when the scene is first created but has not yet appeared on screen

	local background = display.newRect(
		sceneGroup, 
		display.contentCenterX,
		display.contentCenterY,
		720,
		1280
	)
	background.fill = styles[style].backgroundFill

	local title = display.newText(
		{
			parent = sceneGroup,
			text = "tower",
			x = display.contentCenterX,
			y = 1280 * 0.25,
			font = styles[style].font,
			fontSize = 250
		}
	)
	title.fill = styles[style].textFill
	
	local startButton = styles[style].baseButton(
		display.contentCenterX,
		display.contentCenterY,
		350, 120, "play", gotoGame, {0.5, 1, 0.5}
	)
	sceneGroup:insert(startButton)

	local highscoreButton = styles[style].whiteButton(
		display.contentCenterX,
		startButton.y + 130,
		350, "highscore", gotoHighscore
	)
	sceneGroup:insert(highscoreButton)

	local stylesButton = styles[style].whiteButton(
		display.contentCenterX,
		highscoreButton.y + 110,
		350, "styles", gotoStyles
	)
	sceneGroup:insert(stylesButton)

	soundCheckbox = uiElements.newSoundCheckbox(
		70, display.contentHeight - 70,
		styles[style].soundCheckboxSheet
	)
	sceneGroup:insert(soundCheckbox)

	local infoButton = widget.newButton(
		{
			x = display.contentWidth - 70,
			y = display.contentHeight - 70,
			width = 80,
			height = 80,
			defaultFile = styles[style].infoButtonFile,
			onPress = gotoInfo
		}
	)
	sceneGroup:insert(infoButton)

	Runtime:addEventListener("system", onSuspendExit)
end


-- show()
function scene:show( event )

	local sceneGroup = self.view
	local phase = event.phase

	if ( phase == "will" ) then
		-- Code here runs when the scene is still off screen (but is about to come on screen)

		soundCheckbox:setState({isOn = audio.getVolume() > 0})

	elseif ( phase == "did" ) then
		-- Code here runs when the scene is entirely on screen
		composer.removeHidden()

	end
end


-- hide()
function scene:hide( event )

	local sceneGroup = self.view
	local phase = event.phase

	if ( phase == "will" ) then
		-- Code here runs when the scene is on screen (but is about to go off screen)

	elseif ( phase == "did" ) then
		-- Code here runs immediately after the scene goes entirely off screen

	end
end


-- destroy()
function scene:destroy( event )

	local sceneGroup = self.view
	-- Code here runs prior to the removal of scene's view

	Runtime:removeEventListener("system", onSuspendExit)
end


-- -----------------------------------------------------------------------------------
-- Scene event function listeners
-- -----------------------------------------------------------------------------------
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )
-- -----------------------------------------------------------------------------------

return scene
