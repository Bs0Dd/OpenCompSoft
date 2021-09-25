local GUI = require("GUI")
local system = require("System")
local computer = require("Computer")

---------------------------------------------------------------------------------

local workspace, window, menu = system.addWindow(GUI.filledWindow(1, 1, 111, 15, 0x262626))
window.actionButtons.maximize.hidden = true


local whiteKeys = 27

local xWStart, xBStart, yConst = 3, 5, 5


local blockThree = true
local blockSub = true
local beforeBlack = 2


local function makeKey(x, y, w, h, color, freq, parentObj)
	local obj = GUI.panel(x, y, w, h, color)
	
	parentObj:addChild(obj).eventHandler = function(_, obj, event)
		if event == "touch" then
			local oldcol = obj.colors.background
			obj.colors.background = 0x33DB40
			workspace:draw()
			computer.beep(freq)
			obj.colors.background = oldcol
			workspace:draw()
		end
	end
end

local wKeyFPos = 1
local bKeyFPos = 2
for i=1,whiteKeys do
	makeKey(xWStart, yConst, 3, 10, 0xFFFFFF, math.pow(2, (wKeyFPos - 49) / 12) * 440, window)
	wKeyFPos = wKeyFPos + 2
	xWStart = xWStart + 4
	beforeBlack = beforeBlack - 1
	if beforeBlack == 0 then
		local x = (blockSub and 1) or (blockThree and 3) or 2
		for i=1,x do
			makeKey(xBStart, yConst, 3, 5, 0x000000, math.pow(2, (bKeyFPos - 49) / 12) * 440, window)
			bKeyFPos = bKeyFPos + 2
			xBStart = xBStart + 4
		end
		xBStart = xBStart + 4
		bKeyFPos = bKeyFPos + 1
		wKeyFPos = wKeyFPos - 1
		blockSub = false
		blockThree = not blockThree
		beforeBlack = blockThree and 4 or 3
	end
end

---------------------------------------------------------------------------------

workspace:draw()
