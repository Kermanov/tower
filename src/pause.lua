
local composer = require( "composer" )
local styles = require("styles")
local uiElements = require("ui_elements")
local utils = require("utilities")
local const = require("constants")

local scene = composer.newScene()

-- -----------------------------------------------------------------------------------
-- Code outside of the scene event functions below will only be executed ONCE unless
-- the scene is removed entirely (not recycled) via "composer.removeScene()"
-- -----------------------------------------------------------------------------------

local style = composer.getVariable("style")

local isContinue = false

local function gotoMenu()
	composer.gotoScene("menu", { effect = "slideRight", time = const.SCENE_TRANS_SPEED } )
end

local function continue()
	isContinue = true
	composer.hideOverlay("slideRight", const.SCENE_TRANS_SPEED)
end

-- -----------------------------------------------------------------------------------
-- Scene event functions
-- -----------------------------------------------------------------------------------

-- create()
function scene:create( event )

	local sceneGroup = self.view
	-- Code here runs when the scene is first created but has not yet appeared on screen

	local pauseText = display.newText(
		{
			parent = sceneGroup,
			text = "pause",
			x = display.contentCenterX,
			y = 1280 * 0.3,
			font = styles[style].font,
			fontSize = 100
		}
	)
	pauseText.fill = styles[style].textFill

	local continueButton = styles[style].whiteButton(
		720 * 0.25, 1280 * 0.4,
		300, "continue", continue
	)
	sceneGroup:insert(continueButton)

	local menuButton = styles[style].whiteButton(
		720 * 0.75, 1280 * 0.4,
		300, "menu", gotoMenu
	)
	sceneGroup:insert(menuButton)

	local soundCheckbox = uiElements.newSoundCheckbox(
		display.contentWidth - 70, 1280 * 0.5, styles[style].soundCheckboxSheet
	)
	sceneGroup:insert(soundCheckbox)
end


-- show()
function scene:show( event )

	local sceneGroup = self.view
	local phase = event.phase

	if ( phase == "will" ) then
		-- Code here runs when the scene is still off screen (but is about to come on screen)

	elseif ( phase == "did" ) then
		-- Code here runs when the scene is entirely on screen

	end
end


-- hide()
function scene:hide( event )

	local sceneGroup = self.view
	local phase = event.phase

	if ( phase == "will" ) then
		-- Code here runs when the scene is on screen (but is about to go off screen)
		if isContinue then
			event.parent:continue()
		end

	elseif ( phase == "did" ) then
		-- Code here runs immediately after the scene goes entirely off screen

	end
end


-- destroy()
function scene:destroy( event )

	local sceneGroup = self.view
	-- Code here runs prior to the removal of scene's view

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
