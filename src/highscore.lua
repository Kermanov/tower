
local composer = require( "composer" )
local loadsave = require( "loadsave" )
local styles = require("styles")
local const = require("constants")
local utils = require("utilities")
local gpgs = require("plugin.gpgs")
local secret = require("secret")

local scene = composer.newScene()

-- -----------------------------------------------------------------------------------
-- Code outside of the scene event functions below will only be executed ONCE unless
-- the scene is removed entirely (not recycled) via "composer.removeScene()"
-- -----------------------------------------------------------------------------------

local style = composer.getVariable("style")

local blocksGroup
local frontGroup
local scoreText
local maxComboText
local accuracyText

local blocksTimer
local scoreTimer
local maxComboTimer
local accuracyTimer

local colors = styles[style].colors
local color = utils.shallowCopy(colors[1])
local nextColorInd
local deltaColor
if #colors > 1 then
	deltaColor = styles[style].deltaColor
	nextColorInd = 2
end

local function gotoMenu()
	composer.gotoScene("menu", { effect = "slideLeft", time = const.SCENE_TRANS_SPEED } )
end

local function gotoLeaders()
	if gpgs.isConnected() then
		gpgs.leaderboards.show(
			{
				leaderboardId = secret.leaderboardID,
				timeSpan = "all time"
			}
		)
	else
		function loginListener(event)
			if event.phase == "logged in" then
				gotoLeaders()
			end
		end
		gpgs.login({listener = loginListener, userInitiated = true})
	end
end

local function changeColor()
	if #colors > 1 then
		local colorsDone = 0
		for i = 1, 3 do
			if math.abs(color[i] - colors[nextColorInd][i]) <= deltaColor then
				color[i] = colors[nextColorInd][i]
				colorsDone = colorsDone + 1

			elseif color[i] < colors[nextColorInd][i] then
				color[i] = color[i] + deltaColor

			elseif color[i] > colors[nextColorInd][i] then
				color[i] = color[i] - deltaColor

			end
		end

		if colorsDone == 3 then
			nextColorInd = nextColorInd + 1
			if nextColorInd > #colors then
				nextColorInd = nextColorInd - #colors
			end
		end
	end
end

local function loadHighscore()
	local highscore = loadsave.loadTable("highscore.json")

	if highscore then
		local bestTower = loadsave.loadTable("best_tower.json")
		for i = 1, #bestTower do
			local block = display.newRect(
				blocksGroup,
				bestTower[i].x,
				bestTower[i].y,
				bestTower[i].width,
				const.BLOCK_HEIGHT
			)
			block.fill = color
			block.isVisible = false
			changeColor()
		end

		local ceil = 75
		local scale = 1 / 3
		local screenHeight = 1280

		if blocksGroup.contentHeight > (screenHeight - ceil) * 2 then
			scale = (screenHeight - ceil) / blocksGroup.contentHeight
		end

		blocksGroup.yScale = scale
		blocksGroup.xScale = scale
		blocksGroup.y = screenHeight * (1 - scale)
		blocksGroup.x = 720 * 0.2 - blocksGroup.contentWidth / 2

		local time = 1500

		local blockInd = 1
		blocksTimer = timer.performWithDelay(
			math.floor(time / blocksGroup.numChildren),
			function()
				blocksGroup[blockInd].isVisible = true
				blockInd = blockInd + 1
			end,
			blocksGroup.numChildren
		)

		local curScore = 1
		scoreTimer = timer.performWithDelay(
			math.floor(time / highscore.score),
			function()
				scoreText.text = curScore
				curScore = curScore + 1
			end,
			highscore.score
		)

		local curMaxCombo = 1
		maxComboTimer = timer.performWithDelay(
			math.floor(time / highscore.maxCombo),
			function()
				maxComboText.text = curMaxCombo
				curMaxCombo = curMaxCombo + 1
			end,
			highscore.maxCombo
		)

		if highscore.score > 0 then
			local accuracy = utils.round(highscore.perfectHits / highscore.score, 3) * 100
			local accuracySteps = {}
			local steps = 25
			for i = 1, steps do
				accuracySteps[i] = utils.round(i * accuracy / steps, 1)
			end

			local accuracyInt = math.floor(accuracy)
			local step = 1
			accuracyTimer = timer.performWithDelay(
				math.floor(time / steps),
				function()
					accuracyText.text = string.format("%.1f", accuracySteps[step]) .. "%"
					step = step + 1
				end,
				steps
			)
		end
	else
		frontGroup.isVisible = false
		frontGroup2.isVisible = true
	end
end

local function reset()
	local destDir = system.DocumentsDirectory
	os.remove(system.pathForFile("highscore.json", destDir))
	os.remove(system.pathForFile("best_tower.json", destDir))

	gotoMenu()
end

local function confirmReset()
	composer.showOverlay(
		"confirmation",
		{
			effect = "zoomOutIn",
			time = 100,
			isModal = true,
			params = 
			{
				agreeButtonFunc = reset
			}
		}
	)
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

	blocksGroup = display.newGroup()
	sceneGroup:insert(blocksGroup)

	frontGroup = display.newGroup()
	sceneGroup:insert(frontGroup)

	scoreText = display.newText(
		{
			parent = frontGroup,
			text = 0,
			x = 720 * 0.66,
			y = 1280 * 0.15,
			font = styles[style].font,
			fontSize = 260,
			width = display.contentWidth * 0.5,
			align = "left"
		}
	)
	scoreText.fill = styles[style].textFill

	local maxComboTitle = display.newText(
		{
			parent = frontGroup,
			text = "max combo",
			x = 720 * 0.66,
			y = 1280 * 0.3,
			font = styles[style].font,
			fontSize = 50,
			width = display.contentWidth * 0.5,
			align = "left"
		}
	)
	maxComboTitle.fill = styles[style].textFill

	maxComboText = display.newText(
		{
			parent = frontGroup,
			text = 0,
			x = 720 * 0.66,
			y = 1280 * 0.37,
			font = styles[style].font,
			fontSize = 140,
			width = display.contentWidth * 0.5,
			align = "left"
		}
	)
	maxComboText.fill = styles[style].textFill

	local accuracyTitle = display.newText(
		{
			parent = frontGroup,
			text = "accuracy",
			x = 720 * 0.66,
			y = 1280 * 0.47,
			font = styles[style].font,
			fontSize = 50,
			width = display.contentWidth * 0.5,
			align = "left"
		}
	)
	accuracyTitle.fill = styles[style].textFill

	accuracyText = display.newText(
		{
			parent = frontGroup,
			text = "0%",
			x = 720 * 0.66,
			y = 1280 * 0.54,
			font = styles[style].font,
			fontSize = 140,
			width = display.contentWidth * 0.5,
			align = "left"
		}
	)
	accuracyText.fill = styles[style].textFill

	local leaderboardButton = styles[style].baseButton(
		display.contentWidth * 0.41 + 170,
		1280 * 0.7,
		340, 120, "leaders", gotoLeaders, {0.5, 0.5, 1}
	)
	frontGroup:insert(leaderboardButton)

	local menuButton = styles[style].whiteButton(
		display.contentWidth * 0.41 + 170,
		leaderboardButton.y + 130,
		340, "menu", gotoMenu
	)
	frontGroup:insert(menuButton)

	local resetButton = styles[style].redButton(
		display.contentWidth * 0.41 + 170, 
		menuButton.y + 110,
		340, "reset", confirmReset
	)
	frontGroup:insert(resetButton)

	frontGroup2 = display.newGroup()
	sceneGroup:insert(frontGroup2)
	frontGroup2.isVisible = false

	local noHighscoreText = display.newText(
		{
			parent = frontGroup2,
			text = "no highscore yet",
			x = 720 * 0.5,
			y = 1280 * 0.46,
			font = styles[style].font,
			fontSize = 75
		}
	)
	noHighscoreText.fill = styles[style].textFill

	local menuButton = styles[style].whiteButton(
		720 * 0.5, 1280 * 0.54,
		300, "menu", gotoMenu
	)
	frontGroup2:insert(menuButton)
end


-- show()
function scene:show( event )

	local sceneGroup = self.view
	local phase = event.phase

	if ( phase == "will" ) then
		-- Code here runs when the scene is still off screen (but is about to come on screen)

		loadHighscore()

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

	elseif ( phase == "did" ) then
		-- Code here runs immediately after the scene goes entirely off screen

	end
end


-- destroy()
function scene:destroy( event )

	local sceneGroup = self.view
	-- Code here runs prior to the removal of scene's view
	if blocksTimer then timer.cancel(blocksTimer) end
	if scoreTimer then timer.cancel(scoreTimer) end
	if maxComboTimer then timer.cancel(maxComboTimer) end
	if accuracyTimer then timer.cancel(accuracyTimer) end
	if accuracyLastTimer then timer.cancel(accuracyLastTimer) end

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
