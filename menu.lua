
local composer = require("composer")
local styles = require("styles")

local scene = composer.newScene()

-- -----------------------------------------------------------------------------------
-- Code outside of the scene event functions below will only be executed ONCE unless
-- the scene is removed entirely (not recycled) via "composer.removeScene()"
-- -----------------------------------------------------------------------------------

local style = composer.getVariable("style")

local function gotoGame()
	composer.gotoScene( "game", { time=800, effect="slideLeft" } )
end

local function gotoHighscore()
	composer.gotoScene( "highscore", { time=800, effect="slideRight" } )
end

local function gotoStyles()
	composer.gotoScene( "styles_screen", { time=300, effect="crossFade" } )
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
			y = 1280 * 0.3,
			font = styles[style].font,
			fontSize = 200
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
end


-- show()
function scene:show( event )

	local sceneGroup = self.view
	local phase = event.phase

	if ( phase == "will" ) then
		-- Code here runs when the scene is still off screen (but is about to come on screen)

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
