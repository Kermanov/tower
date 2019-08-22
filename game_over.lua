
local composer = require( "composer" )
local styles = require("styles")

local scene = composer.newScene()

-- -----------------------------------------------------------------------------------
-- Code outside of the scene event functions below will only be executed ONCE unless
-- the scene is removed entirely (not recycled) via "composer.removeScene()"
-- -----------------------------------------------------------------------------------

local style = composer.getVariable("style")

local newHighscoreText
local isRestart = false

local function restart()
	isRestart = true
	composer.hideOverlay("slideRight", 800)
end

local function gotoMenu()
	composer.gotoScene("menu", { effect = "slideRight", time = 800 } )
end

-- -----------------------------------------------------------------------------------
-- Scene event functions
-- -----------------------------------------------------------------------------------

-- create()
function scene:create( event )

	local sceneGroup = self.view
	-- Code here runs when the scene is first created but has not yet appeared on screen

	local gameOverText = display.newText(
		{
			parent = sceneGroup,
			text = "game over",
			x = display.contentCenterX,
			y = 1280 * 0.3,
			font = styles[style].font,
			fontSize = 100
		}
	)
	gameOverText.fill = styles[style].textFill

	local restartButton = styles[style].whiteButton(
		720 * 0.25, 1280 * 0.4,
		250, "restart", restart
	)
	sceneGroup:insert(restartButton)

	local menuButton = styles[style].whiteButton(
		720 * 0.75, 1280 * 0.4,
		250, "menu", gotoMenu
	)
	sceneGroup:insert(menuButton)

	newHighscoreText = display.newText(
		{
			parent = sceneGroup,
			text = "new highscore!",
			x = display.contentCenterX,
			y = 1280 * 0.09,
			font = styles[style].font,
			fontSize = 60
		}
	)
	newHighscoreText.fill = styles[style].textFill
	newHighscoreText.isVisible = false

end


-- show()
function scene:show( event )

	local sceneGroup = self.view
	local phase = event.phase

	if ( phase == "will" ) then
		-- Code here runs when the scene is still off screen (but is about to come on screen)

	elseif ( phase == "did" ) then
		-- Code here runs when the scene is entirely on screen
		newHighscoreText.isVisible = event.params.isHighscore

		if newHighscoreText.isVisible then
			transition.from(
				newHighscoreText,
				{
					y = -50,
					time = 250
				}
			)
		end

	end
end


-- hide()
function scene:hide( event )

	local sceneGroup = self.view
	local phase = event.phase

	if ( phase == "will" ) then
		-- Code here runs when the scene is on screen (but is about to go off screen)

		if isRestart then
			event.parent:restart()
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
