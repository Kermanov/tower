
local composer = require("composer")
local styles = require("styles")

local scene = composer.newScene()


local text
local agreeButton
local declineButton

local style = composer.getVariable("style")


function scene:create(event)

	local sceneGroup = self.view
	-- Code here runs when the scene is first created but has not yet appeared on screen

	local back = styles[style].confirmationBack(sceneGroup)

	text = display.newText(
		{
			parent = sceneGroup,
			text = "Are you shure?",
			x = display.contentCenterX,
			y = display.contentCenterY,
			width = display.contentWidth * 0.8,
			height = display.contentHeight * 0.2,
			font = styles[style].font,
			fontSize = 75,
			align = "center"
		}
	)
	text.fill = styles[style].textFill

	agreeButton = styles[style].whiteButton(
		display.contentWidth * 0.3,
		display.contentHeight * 0.58,
		200, "yes", event.params.agreeButtonFunc
	)
	sceneGroup:insert(agreeButton)

	declineButton = styles[style].redButton(
		display.contentWidth * 0.7,
		display.contentHeight * 0.58,
		200, "no", function() composer.hideOverlay("zoomOutIn", 100) end
	)
	sceneGroup:insert(declineButton)

end


function scene:show(event)

	local sceneGroup = self.view
	local phase = event.phase

	if (phase == "will") then
		-- Code here runs when the scene is still off screen (but is about to come on screen)

	elseif (phase == "did") then
		-- Code here runs when the scene is entirely on screen

	end
end


function scene:hide(event)

	local sceneGroup = self.view
	local phase = event.phase

	if (phase == "will") then
		-- Code here runs when the scene is on screen (but is about to go off screen)

	elseif (phase == "did") then
		-- Code here runs immediately after the scene goes entirely off screen

	end
end


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
