local widget = require("widget")

local style = {}

function style.baseButton(x, y, width, height, label, onRelease, color)
	local button = widget.newButton(
		{
			x = x,
			y = y,
			onRelease = onRelease,
			label = label,
			shape = "roundedRect",
			width = width,
			height = height,
			cornerRadius = 40,
			fillColor = { default={ color[1], color[2], color[3], 0.4 }, over={ color[1], color[2], color[3], 0.7 } },
			fontSize = 60,
			labelColor = {default={ 1, 1, 1 }, over={ 0.21, 0.22, 0.42 }},
			font = "fonts/Rajdhani-Medium.ttf",
			strokeWidth = 5,
			strokeColor = { default={ 1, 1, 1 }, over={ 1, 1, 1 } }
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

style.backgroundFill = {
	type = "gradient",
	color1 = {0.43, 0.76, 0.81},
	color2 = {0.21, 0.22, 0.42},
	direction = "down"
}

style.colors =
{
	{ 0.89, 0.84, 0.37 },
	{ 0.87, 0.89, 0.36 }
}

style.deltaColor = 0.002

style.perfectHitColor = {1, 1, 1}

style.font = "fonts/Rajdhani-Medium.ttf"

style.highscoreFlagY = 1280 * 0.13

function style.confirmationBack(group)
	local back = display.newRoundedRect(
		group, 
		display.contentCenterX,
		display.contentCenterY,
		display.contentWidth * 0.8,
		display.contentHeight * 0.3,
		40
	)
	back.strokeWidth = 5,
	back:setStrokeColor(unpack(style.textFill))
	back.fill = {0.21, 0.22, 0.42, 0.9}

	return back
end

style.pauseButtonFile = "images/pause_button_classic.png"

style.sounds = {}
style.sounds.perfectHit = "sounds/classic/perfect_hit.mp3"
style.sounds.addWidth = "sounds/classic/add_width.mp3"

return style