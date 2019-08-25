local widget = require("widget")

local style = {}

function style.baseButton(x, y, width, height, label, onRelease, color)
	local button = widget.newButton(
		{
			x = x,
			y = y,
			onRelease = onRelease,
			label = label,
			shape = "rect",
			width = width,
			height = height,
			fillColor = { default={ color[1], color[2], color[3] }, over={ color[1], color[2], color[3], 0.7 } },
			fontSize = 75,
			labelColor = {default={0, 0, 0}, over={0, 0, 0}},
			font = "fonts/DisposableDroidBB.ttf"
		}
	)
	return button
end

function style.whiteButton(x, y, width, label, onRelease)
	return style.baseButton(x, y, width, 80, label, onRelease, { 1, 1, 1 })
end

function style.redButton(x, y, width, label, onRelease)
	return style.baseButton(x, y, width, 80, label, onRelease, { 1, 0.5, 0.5 })
end

style.textFill = {1, 1, 1}

style.backgroundFill = {0, 0, 0}

style.colors = {{1, 1, 1}}

style.perfectHitColor = {0, 1, 0, 0.6}

style.font = "fonts/DisposableDroidBB.ttf"

style.highscoreFlagY = 1280 * 0.13

style.conditionText = "score: 75"

style.condition = function(scores)
	return scores.score >= 75
end

function style.confirmationBack(group)
	local back = display.newRect(
		group, 
		display.contentCenterX,
		display.contentCenterY,
		display.contentWidth * 0.8,
		display.contentHeight * 0.3
	)
	back.strokeWidth = 5,
	back:setStrokeColor(unpack(style.textFill))
	back.fill = {0, 0, 0}

	return back
end

style.pauseButtonFile = "images/pause_button_retro.png"

style.sounds = {}
style.sounds.perfectHit = "sounds/retro/perfect_hit.mp3"
style.sounds.addWidth = "sounds/retro/add_width.mp3"

return style