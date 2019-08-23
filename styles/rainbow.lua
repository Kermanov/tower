local widget = require("widget")

local style = {}

function style.baseButton(x, y, width, height, label, onRelease, color)
	local button = widget.newButton(
		{
			x = x, y = y, width = width, height = height,
			label = label, onRelease = onRelease,
			fillColor = {default = {color[1], color[2], color[3]}, over = {0.35, 0.35, 0.35}},
			fontSize = 60,
			shape = "roundedRect",
			cornerRadius = 40,
			strokeWidth = 5,
			strokeColor = {default = {0.35, 0.35, 0.35}, over = {0.35, 0.35, 0.35}},
			labelColor = {default = {0.35, 0.35, 0.35}, over = {1, 1, 1}},
			font = "fonts/Rajdhani-Medium.ttf"
		}
	)
	return button
end

function style.whiteButton(x, y, width, label, onRelease)
	return style.baseButton(x, y, width, 80, label, onRelease, {1, 1, 1})
end

function style.redButton(x, y, width, label, onRelease)
	return style.baseButton(x, y, width, 80, label, onRelease, {1, 0.5, 0.5})
end

style.textFill = {0.35, 0.35, 0.35}

style.backgroundFill = {1, 1, 1}

style.colors = 
{
	{1.00, 0.70, 0.74},
	{1.00, 0.71, 0.61},
	{1.00, 0.89, 0.47},
	{0.65, 0.98, 0.48},
	{0.57, 0.98, 1.00},
	{0.61, 0.83, 0.99},
	{0.94, 0.71, 1.00}
}

style.deltaColor = 0.02

style.perfectHitColor = {0.5, 0.5, 0.5}

style.font = "fonts/Rajdhani-Medium.ttf"

style.highscoreFlagY = 1280 * 0.13

style.conditionText = "combo: 20"

style.condition = function(scores)
	return scores.combo >= 20
end

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
	back.fill = {1, 1, 1}

	return back
end

return style