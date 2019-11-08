
local composer = require("composer")
local styles = require("styles")

local scene = composer.newScene()

local style = composer.getVariable("style")


function scene:create(event)

	local sceneGroup = self.view
	-- Code here runs when the scene is first created but has not yet appeared on screen

	local width = display.contentWidth * 0.9
	local height = display.contentHeight * 0.5

	local back = styles[style].alertBack(
		sceneGroup,
		width, height
	)

	local title = display.newText(
		{
			parent = sceneGroup,
			text = event.params.title,
			x = display.contentCenterX,
			y = height * 0.58,
			fontSize = 75,
			font = styles[style].font
		}
	)
	title.fill = styles[style].textFill

	local text = display.newText(
		{
			parent = sceneGroup,
			text = event.params.text,
			x = display.contentCenterX,
			y = display.contentCenterY,
			width = width * 0.93,
			height = height * 0.72,
			font = styles[style].font,
			fontSize = 40,
			align = "left"
		}
	)
	text.fill = styles[style].textFill

	local closeButton = styles[style].redButton(
		display.contentWidth * 0.5,
		height * 1.4,
		200, "close", function() composer.hideOverlay("zoomOutIn", 100) end
	)
	sceneGroup:insert(closeButton)

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
