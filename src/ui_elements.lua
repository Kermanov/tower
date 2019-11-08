local widget = require("widget")

local M = {}

M.newCheckbox = function(x, y, sheetFile, initialState, onRelease)
	local checkboxSheet = graphics.newImageSheet(
		sheetFile,
		{
			width = 100, height = 100, numFrames = 2,
			sheetContentWidth = 200,
			sheetContentHeight = 100
		}
	)

	local soundCheckbox = widget.newSwitch(
		{
			x = x, y = y,
			width = 80, height = 80,
			initialSwitchState = initialState,
			style = "checkbox",
			sheet = checkboxSheet,
			frameOn = 2,
			frameOff = 1,
			onRelease = onRelease
		}
	)
	return soundCheckbox
end

M.newSoundCheckbox = function(x, y, sheetFile)
	return M.newCheckbox(
		x, y, sheetFile,
		audio.getVolume() > 0,
		function()
			if audio.getVolume() > 0 then
				audio.setVolume(0)
			else
				audio.setVolume(0.4)
			end
		end
	)
end

return M