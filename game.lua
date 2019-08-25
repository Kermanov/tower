local composer = require("composer")
local widget = require("widget")
local physics = require("physics")
local utils = require("utilities")
local loadsave = require("loadsave")
local const = require("constants")
local styles = require("styles")

local scene = composer.newScene()

physics.start()
physics.setGravity(0, 9.8)

local style = composer.getVariable("style")

local blocksGroup
local bytesGroup
local effectsGroup
local actionGroup
local highscoreGroup

local backGroup
local frontGroup

-- -1 is left, 1 is right
local targetSide = 1
local lastSide = targetSide

local colors = styles[style].colors
local color = utils.shallowCopy(colors[1])
local nextColorInd
local deltaColor
if #colors > 1 then
	deltaColor = styles[style].deltaColor
	nextColorInd = 2
end
local afterRestartColor
local afterRestartNextColorInd

local counter = 0
local counterText
local comboText

local combo = 0
local maxCombo = 0
local perfectHits = 0
local gameOver = false

local removeBytesLoop

local buildButton
local curMinMoveTime = const.MOVE_TIME

local highscoreY
local highscoreFlag

local settings

local perfectHitSound = composer.getVariable("perfectHitSound")
local addWidthSound = composer.getVariable("addWidthSound")

local function styleUnlockedEffect(styleName)
	local text = display.newText(
		{
			parent = frontGroup,
			text = styleName .. " style unlocked!",
			x = display.contentCenterX,
			y = 400,
			width = 720,
			font = styles[style].font,
			fontSize = 50,
			align = "center"
		}
	)
	text.fill = styles[style].textFill

	transition.from(text, {time = 300, y = 350, alpha = 0})
	transition.to(
		text, 
		{
			time = 300, y = 450, delay = 2000, 
			alpha = 0, onComplete = function() text:removeSelf() end
		}
	)
end

local function checkForStyleUnlock()
	for styleName in pairs(styles) do
		if not utils.contains(settings.unlockedStyles, styleName) then
			local scores = 
			{
				score = counter,
				combo = combo,
				perfectHits = perfectHits
			}
			if styles[styleName].condition(scores) then
				styleUnlockedEffect(styleName)
				table.insert(settings.unlockedStyles, styleName)
				loadsave.saveTable(settings, "settings.json")
			end
		end
	end
end

local function setHighscoreLine()
	local highscore = loadsave.loadTable("highscore.json")
	if highscore then
		-- clean highscoreGroup
		highscoreGroup:removeSelf()
		highscoreGroup = display.newGroup()
		effectsGroup:insert(highscoreGroup)

		highscoreY = 1280 - const.BLOCK_HEIGHT * (highscore.score + 5)
		highscoreX = 0
		local line = display.newLine(
			highscoreGroup,
			highscoreX, highscoreY,
			highscoreX + 150, highscoreY
		)
		line:setStrokeColor(unpack(styles[style].textFill))
		line.strokeWidth = 4

		local highTitleText = display.newText(
			{
				parent = highscoreGroup,
				text = "highscore",
				x = highscoreX + 80,
				y = line.y - 90,
				font = styles[style].font,
				fontSize = 30,
				width = 150
			}
		)
		highTitleText.fill = styles[style].textFill

		local highText = display.newText(
			{
				parent = highscoreGroup,
				text = highscore.score,
				x = highscoreX + 80, 
				y = line.y - 35,
				font = styles[style].font,
				fontSize = 100,
				width = 150
			}
		)
		highText.fill = styles[style].textFill
	else
		highscoreFlag.isVisible = true
	end
end

local function createHighscore()
	local highscore =
	{
		score = counter,
		maxCombo = maxCombo,
		perfectHits = perfectHits
	}
	local bestTower = {}

	local last = blocksGroup.numChildren
	if not gameOver then last = last - 1 end

	for i = 1, last do
		bestTower[i] = 
		{
			x = blocksGroup[i].x,
			y = blocksGroup[i].y,
			width = blocksGroup[i].width
		}
	end
	return highscore, bestTower
end

local function saveHighscore()
	local oldHighscore = loadsave.loadTable("highscore.json")
	if not oldHighscore or counter > oldHighscore.score then
		local newHighscore, bestTower = createHighscore()
		loadsave.saveTable(newHighscore, "highscore.json")
		loadsave.saveTable(bestTower, "best_tower.json")
	end
end

local function onSuspendExit(event)
	if event.type == "applicationSuspend" or 
	event.type == "applicationExit" then
		saveHighscore()
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

local function gotoPause()
	pauseButton.isVisible = false
	transition.pause()
	physics.pause()

	if highscoreGroup.isVisible then
		transition.to(highscoreGroup, {x = -200, time = 400})
	end

	composer.showOverlay(
		"pause",
		{
			effect = "fromLeft",
			time = 400,
			isModal = true
		}
	)
end

function scene:continue()
	if highscoreGroup.isVisible then
		transition.to(highscoreGroup, {x = 0, time = 400})
	end

	pauseButton.isVisible = true
	transition.resume()
	physics.start()
end

local function changeSide()
	targetSide = lastSide == -1 and 1 or -1
	lastSide = targetSide
end

-- moving segment from side to side
local function move()
	local topBlock = blocksGroup[blocksGroup.numChildren]
	if targetSide == 1 then
		targetX = 720 - topBlock.width / 2
		targetSide = -1
	elseif targetSide == -1 then
		targetX = topBlock.width / 2
		targetSide = 1
	end

	transition.to(
		topBlock,
		{
			time = math.random(curMinMoveTime, curMinMoveTime + const.TIME_RANGE),
			x = targetX,
			onComplete = move,
			tag = "moving"
		}
	)
end

-- add new segment to tower
local function addNewSegment(x, y, width, height)
	local segment = display.newRect(
		blocksGroup,
		x, y, width, height
	)
	segment.fill = color
	changeColor()
end

-- create first moving block
local function createFirstBlock()
	addNewSegment(
		blocksGroup[blocksGroup.numChildren].width / 2,
		blocksGroup[blocksGroup.numChildren].y - const.BLOCK_HEIGHT,
		const.BLOCK_WIDTH,
		const.BLOCK_HEIGHT
	)
	targetSide = 1
	move()
end

-- add new falling block
local function newFallingBlock(x, y, width, height, vel, ang)
	local blockByte = display.newRect(
		bytesGroup,
		x, y, width, height
	)
	blockByte.fill = color
	physics.addBody(
		blockByte,
		"dynamic",
		{
			friction = 0.1,
			bounce = 0.4
		}
	)
	blockByte:setLinearVelocity(vel, 0)
	blockByte:applyAngularImpulse(ang)
end

local function removeBytes()
	for i = bytesGroup.numChildren, 1, -1 do
		if bytesGroup[i].y > 1500 then
			bytesGroup[i]:removeSelf()
		end
	end
end

-- actions on screen tap
local function build()
	local topBlock = blocksGroup[blocksGroup.numChildren]
	local secondBlock = blocksGroup[blocksGroup.numChildren - 1]

	-- hide highscore line
	if highscoreY and topBlock.y < highscoreY then
		transition.to(
			highscoreGroup,
			{
				x = - 200,
				time = 400,
				onComplete = function()
					highscoreGroup.isVisible = false
				end
			}
		)
		highscoreFlag.isVisible = true
	end

	-- move all tower down
	if topBlock.y <= const.CEIL then
		transition.to(
			actionGroup,
			{
				y = const.BLOCK_HEIGHT,
				delta = true,
				time = 500
			}
		)
	end

	local deltaX = topBlock.x - secondBlock.x
	local deltaXmod = math.abs(deltaX)

	-- check for perfect hit
	if deltaXmod <= const.MIN_SHIFT then
		deltaX = 0
		deltaXmod = 0
		topBlock.x = secondBlock.x
		combo = combo + 1
		perfectHits = perfectHits + 1

		local hitEffect = display.newRect(
			effectsGroup,
			topBlock.x, topBlock.y,
			topBlock.width, topBlock.height
		)
		hitEffect.fill = styles[style].perfectHitColor
		transition.to(
			hitEffect,
			{
				alpha = 0,
				time = 250,
				onComplete = function()
					hitEffect:removeSelf()
				end
			}
		)
	else
		if combo > maxCombo then
			maxCombo = combo
		end
		combo = 0
	end

	comboText.text = combo

	-- add bonus width if combo
	local commonWidth
	local addWidth
	if combo > 0 and combo % 3 == 0 and topBlock.width + const.BONUS_WIDTH <= const.BLOCK_WIDTH then
		commonWidth = topBlock.width + const.BONUS_WIDTH
		addWidth = true
	else
		commonWidth = topBlock.width - deltaXmod
		addWidth = false
	end

	-- check for hit
	if commonWidth >= const.MIN_WIDTH then
		counter = counter + 1
		counterText.text = counter

		comboText.x = counterText.x + (counterText.width + comboText.width) / 2

		if curMinMoveTime > const.MIN_MOVE_TIME + const.TIME_DECREMENT then
			curMinMoveTime = curMinMoveTime - const.TIME_DECREMENT
		end

		changeSide()

		-- set right pos and size to last block
		topBlock.x = topBlock.x - deltaX / 2

		if addWidth then
			transition.to(
				topBlock,
				{
					width = commonWidth,
					time = 250,
					transition = easing.inBack
				}
			)

			audio.play(addWidthSound)
		else
			topBlock.width = commonWidth

			if deltaXmod == 0 then
				audio.play(perfectHitSound)
			end
		end

		-- stop moving for last block
		transition.cancel("moving")

		-- add physic body for last block
		physics.addBody(
			topBlock,
			"static",
			{
				friction = 0.5,
				bounce = 0.3
			}
		)

		-- add falling byte of block and cut effect
		if deltaXmod > 0 then
			local blockByteX
			local lineX
			if deltaX > 0 then
				blockByteX = topBlock.x + (topBlock.width + deltaX) / 2
				lineX = secondBlock.x + secondBlock.width / 2 - 2
			elseif deltaX < 0 then
				blockByteX = topBlock.x + (deltaX - topBlock.width) / 2
				lineX = secondBlock.x - secondBlock.width / 2 + 2
			end

			newFallingBlock(
				blockByteX,
				topBlock.y,
				deltaXmod,
				const.BLOCK_HEIGHT,
				deltaX * 0.5,
				deltaX * 0.01
			)

			local cutEffect = display.newLine(
				effectsGroup,
				lineX, topBlock.y - const.BLOCK_HEIGHT / 2,
				lineX, topBlock.y + const.BLOCK_HEIGHT / 2
			)
			cutEffect:setStrokeColor(1, 1, 1, 0.8)
			cutEffect.strokeWidth = 4

			transition.to(
				cutEffect,
				{
					time = 200,
					alpha = 0,
					onComplete = function()
						cutEffect:removeSelf()
					end
				}
			)
		end

		-- add new block on top
		local newBlockX
		if targetSide == 1 then
			newBlockX = topBlock.width / 2
		else
			newBlockX = 720 - topBlock.width / 2
		end

		addNewSegment(
			newBlockX,
			topBlock.y - const.BLOCK_HEIGHT,
			commonWidth,
			const.BLOCK_HEIGHT
		)
		move()

		checkForStyleUnlock()
	else
		-- game over case
		gameOver = true
		pauseButton.isVisible = false

		-- add last falling block
		newFallingBlock(
			topBlock.x,
			topBlock.y,
			topBlock.width,
			const.BLOCK_HEIGHT,
			topBlock.width * -targetSide * 2,
			0
		)

		-- stop moving and remove last block
		transition.cancel("moving")
		topBlock:removeSelf()

		-- remove tap listener
		buildButton.isVisible = false

		-- change counterText font size
		transition.to(counterText, {size = 250, time = 800})

		-- fade out and remove all bytes
		transition.to(
			bytesGroup,
			{
				alpha = 0,
				time = 800,
				onComplete = function()
					timer.pause(removeBytesLoop)
					bytesGroup:removeSelf()
					bytesGroup = display.newGroup()
					actionGroup:insert(bytesGroup)
					timer.resume(removeBytesLoop)
				end
			}
		)

		-- show game over scene
		composer.showOverlay(
			"game_over",
			{
				effect = "fromLeft",
    			time = 800,
    			isModal = true,
    			params = 
    			{
    				isHighscore = highscoreFlag.isVisible
    			}
			}
		)

		highscoreFlag.isVisible = false
		comboText.isVisible = false
	end
end

function scene:restart()
	saveHighscore()

	pauseButton.isVisible = true

	local iterations = counter
	local timeForOne = 60
	local totalTime = iterations * timeForOne

	highscoreFlag.isVisible = false

	-- return text size to normal
	transition.to(counterText, {size = const.COUNTER_TEXT_SIZE, time = totalTime})

	-- move camera to tower start
	transition.to(actionGroup, {y = 0, time = totalTime})

	-- remove all static blocks and change counter to 0
	timer.performWithDelay(
		timeForOne,
		function()
			blocksGroup[blocksGroup.numChildren]:removeSelf()
			counter = counter - 1
			counterText.text = counter
		end,
		iterations
	)

	-- create first block
	-- set some values to start state
	timer.performWithDelay(
		totalTime + iterations * 10,
		function()
			bytesGroup.alpha = 1
			color = utils.shallowCopy(afterRestartColor)
			nextColorInd = afterRestartNextColorInd
			targetSide = 1
			lastSide = 1
			createFirstBlock()
			buildButton.isVisible = true
			comboText.isVisible = true
			comboText.x = counterText.x + (counterText.width + comboText.width) / 2
			maxCombo = 0
			perfectHits = 0
			gameOver = false
			curMinMoveTime = const.MOVE_TIME
			highscoreFlag.x = counterText.x + 75 - counterText.width / 2
			setHighscoreLine()
		end
	)
end

function scene:create(event)
	local sceneGroup = self.view

	backGroup = display.newGroup()
	sceneGroup:insert(backGroup)

	actionGroup = display.newGroup()
	sceneGroup:insert(actionGroup)

	blocksGroup = display.newGroup()
	actionGroup:insert(blocksGroup)

	bytesGroup = display.newGroup()
	actionGroup:insert(bytesGroup)

	effectsGroup = display.newGroup()
	actionGroup:insert(effectsGroup)

	highscoreGroup = display.newGroup()
	actionGroup:insert(highscoreGroup)

	frontGroup = display.newGroup()
	sceneGroup:insert(frontGroup)

	local background = display.newRect(
		backGroup, 
		display.contentCenterX,
		display.contentCenterY,
		720,
		1280
	)
	background.fill = styles[style].backgroundFill

	counterText = display.newText(
		{
			parent = frontGroup,
			text = counter,
			x = display.contentCenterX,
			y = 1280 * 0.2,
			font = styles[style].font,
			fontSize = const.COUNTER_TEXT_SIZE,
			align = "left"
		}
	)
	counterText.fill = styles[style].textFill

	comboText = display.newText(
		{
			parent = frontGroup,
			text = combo,
			x = counterText.x + counterText.width / 2 + 30,
			y = 1280 * 0.24,
			font = styles[style].font,
			fontSize = 60,
			align = "center"
		}
	)
	comboText.fill = styles[style].textFill

	highscoreFlag = display.newText(
		{
			parent = frontGroup,
			text = "highscore",
			x = display.contentCenterX,
			y = styles[style].highscoreFlagY,
			font = styles[style].font,
			fontSize = 35
		}
	)
	highscoreFlag.fill = styles[style].textFill
	highscoreFlag.isVisible = false

	buildButton = widget.newButton(
		{
			width = 720,
			height = 1280,
			x = display.contentCenterX,
			y = display.contentCenterY,
			parent = frontGroup,
			fillColor = { default={ 0, 0, 0, 0 }, over={ 0, 0, 0, 0 } },
			onPress = build
		}
	)
	buildButton.alpha = 0.01
	buildButton:toBack()

	pauseButton = widget.newButton(
		{
			x = 720 - 70,
			y = 70,
			width = 80,
			height = 80,
			defaultFile = styles[style].pauseButtonFile,
			onPress = gotoPause
		}
	)
	frontGroup:insert(pauseButton)

	setHighscoreLine()
	
	-- creating start tower
	for i = 1, 5 do
		addNewSegment(
			display.contentCenterX,
			1280 - const.BLOCK_HEIGHT / 2 - const.BLOCK_HEIGHT * (i - 1),
			const.BLOCK_WIDTH * (2 - i / 5),
			const.BLOCK_HEIGHT
		)
		physics.addBody(
			blocksGroup[blocksGroup.numChildren],
			"static",
			{
				friction = 0.5,
				bounce = 0.3
			}
		)
	end
	afterRestartColor = utils.shallowCopy(color)
	afterRestartNextColorInd = nextColorInd

	settings = loadsave.loadTable("settings.json")

	Runtime:addEventListener("system", onSuspendExit)

	-- display.save(sceneGroup, "screen_" .. style .. ".png")
end


-- show()
function scene:show( event )

	local sceneGroup = self.view
	local phase = event.phase

	if ( phase == "will" ) then
		-- Code here runs when the scene is still off screen (but is about to come on screen)

		-- creating first moving segment
		createFirstBlock()
		buildButton.isVisible = true

	elseif ( phase == "did" ) then
		-- Code here runs when the scene is entirely on screen
		removeBytesLoop = timer.performWithDelay(3000, removeBytes, 0)
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
	buildButton.isVisible = false
	saveHighscore()
	physics.stop()
	Runtime:removeEventListener("system", onSuspendExit)
	transition.cancel()
	timer.cancel(removeBytesLoop)
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
