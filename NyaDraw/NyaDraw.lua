--[[NyaDraw Graphic Engine v1.04 for OpenOS
	Standalone "Screen.lua" port from MineOS
	More info on: https://github.com/Bs0Dd/OpenCompSoft/blob/master/NyaDraw/README.md
	2015-2021 - ECS: https://github.com/IgorTimofeev
	2021 - Bs0Dd: https://github.com/Bs0Dd
]]

local unicode = require("unicode")
local computer = require("computer")

--------------------------------------------------------------------------------

local bufferWidth, bufferHeight
local currentFrameBackgrounds, currentFrameForegrounds, currentFrameSymbols, newFrameBackgrounds, newFrameForegrounds, newFrameSymbols
local drawLimitX1, drawLimitX2, drawLimitY1, drawLimitY2
local GPUProxy, GPUProxyGetResolution, GPUProxySetResolution, GPUProxyGetBackground, GPUProxyGetForeground, GPUProxySetBackground, GPUProxySetForeground, GPUProxyGet, GPUProxySet, GPUProxyFill

local mathCeil, mathFloor, mathModf, mathAbs = math.ceil, math.floor, math.modf, math.abs
local tableInsert, tableConcat = table.insert, table.concat
local colorBlend
local unicodeLen, unicodeSub = unicode.len, unicode.sub

--------------------------------------------------------------------------------

local function getIndex(x, y)
	return bufferWidth * (y - 1) + x
end

local function getCurrentFrameTables()
	return currentFrameBackgrounds, currentFrameForegrounds, currentFrameSymbols
end

local function getNewFrameTables()
	return newFrameBackgrounds, newFrameForegrounds, newFrameSymbols
end

--------------------------------------------------------------------------------

local function setDrawLimit(x1, y1, x2, y2)
	drawLimitX1, drawLimitY1, drawLimitX2, drawLimitY2 = x1, y1, x2, y2
end

local function resetDrawLimit()
	drawLimitX1, drawLimitY1, drawLimitX2, drawLimitY2 = 1, 1, bufferWidth, bufferHeight
end

local function getDrawLimit()
	return drawLimitX1, drawLimitY1, drawLimitX2, drawLimitY2
end

--------------------------------------------------------------------------------
--Color Subsystem (Ported by Bs()Dd)

local palette = {0x000000, 0x000040, 0x000080, 0x0000BF, 0x0000FF, 0x002400, 0x002440, 0x002480, 0x0024BF, 0x0024FF, 0x004900, 0x004940,
0x004980, 0x0049BF, 0x0049FF, 0x006D00, 0x006D40, 0x006D80, 0x006DBF, 0x006DFF, 0x009200, 0x009240, 0x009280, 0x0092BF, 0x0092FF, 0x00B600,
0x00B640, 0x00B680, 0x00B6BF, 0x00B6FF, 0x00DB00, 0x00DB40, 0x00DB80, 0x00DBBF, 0x00DBFF, 0x00FF00, 0x00FF40, 0x00FF80, 0x00FFBF, 0x00FFFF,
0x0F0F0F, 0x1E1E1E, 0x2D2D2D, 0x330000, 0x330040, 0x330080, 0x3300BF, 0x3300FF, 0x332400, 0x332440, 0x332480, 0x3324BF, 0x3324FF, 0x334900,
0x334940, 0x334980, 0x3349BF, 0x3349FF, 0x336D00, 0x336D40, 0x336D80, 0x336DBF, 0x336DFF, 0x339200, 0x339240, 0x339280, 0x3392BF, 0x3392FF,
0x33B600, 0x33B640, 0x33B680, 0x33B6BF, 0x33B6FF, 0x33DB00, 0x33DB40, 0x33DB80, 0x33DBBF, 0x33DBFF, 0x33FF00, 0x33FF40, 0x33FF80, 0x33FFBF,
0x33FFFF, 0x3C3C3C, 0x4B4B4B, 0x5A5A5A, 0x660000, 0x660040, 0x660080, 0x6600BF, 0x6600FF, 0x662400, 0x662440, 0x662480, 0x6624BF, 0x6624FF,
0x664900, 0x664940, 0x664980, 0x6649BF, 0x6649FF, 0x666D00, 0x666D40, 0x666D80, 0x666DBF, 0x666DFF, 0x669200, 0x669240, 0x669280, 0x6692BF,
0x6692FF, 0x66B600, 0x66B640, 0x66B680, 0x66B6BF, 0x66B6FF, 0x66DB00, 0x66DB40, 0x66DB80, 0x66DBBF, 0x66DBFF, 0x66FF00, 0x66FF40, 0x66FF80,
0x66FFBF, 0x66FFFF, 0x696969, 0x787878, 0x878787, 0x969696, 0x990000, 0x990040, 0x990080, 0x9900BF, 0x9900FF, 0x992400, 0x992440, 0x992480,
0x9924BF, 0x9924FF, 0x994900, 0x994940, 0x994980, 0x9949BF, 0x9949FF, 0x996D00, 0x996D40, 0x996D80, 0x996DBF, 0x996DFF, 0x999200, 0x999240,
0x999280, 0x9992BF, 0x9992FF, 0x99B600, 0x99B640, 0x99B680, 0x99B6BF, 0x99B6FF, 0x99DB00, 0x99DB40, 0x99DB80, 0x99DBBF, 0x99DBFF, 0x99FF00,
0x99FF40, 0x99FF80, 0x99FFBF, 0x99FFFF, 0xA5A5A5, 0xB4B4B4, 0xC3C3C3, 0xCC0000, 0xCC0040, 0xCC0080, 0xCC00BF, 0xCC00FF, 0xCC2400, 0xCC2440,
0xCC2480, 0xCC24BF, 0xCC24FF, 0xCC4900, 0xCC4940, 0xCC4980, 0xCC49BF, 0xCC49FF, 0xCC6D00, 0xCC6D40, 0xCC6D80, 0xCC6DBF, 0xCC6DFF, 0xCC9200,
0xCC9240, 0xCC9280, 0xCC92BF, 0xCC92FF, 0xCCB600, 0xCCB640, 0xCCB680, 0xCCB6BF, 0xCCB6FF, 0xCCDB00, 0xCCDB40, 0xCCDB80, 0xCCDBBF, 0xCCDBFF,
0xCCFF00, 0xCCFF40, 0xCCFF80, 0xCCFFBF, 0xCCFFFF, 0xD2D2D2, 0xE1E1E1, 0xF0F0F0, 0xFF0000, 0xFF0040, 0xFF0080, 0xFF00BF, 0xFF00FF, 0xFF2400,
0xFF2440, 0xFF2480, 0xFF24BF, 0xFF24FF, 0xFF4900, 0xFF4940, 0xFF4980, 0xFF49BF, 0xFF49FF, 0xFF6D00, 0xFF6D40, 0xFF6D80, 0xFF6DBF, 0xFF6DFF,
0xFF9200, 0xFF9240, 0xFF9280, 0xFF92BF, 0xFF92FF, 0xFFB600, 0xFFB640, 0xFFB680, 0xFFB6BF, 0xFFB6FF, 0xFFDB00, 0xFFDB40, 0xFFDB80, 0xFFDBBF,
0xFFDBFF, 0xFFFF00, 0xFFFF40, 0xFFFF80, 0xFFFFBF, 0xFFFFFF}

local function to24Bit(color8Bit)
	return palette[color8Bit + 1]
end

if computer.getArchitecture and computer.getArchitecture() == "Lua 5.3" then
	colorBlend = load([[return function(color1, color2, transparency)
		local invertedTransparency = 1 - transparency
		return
			((color2 >> 16) * invertedTransparency + (color1 >> 16) * transparency) // 1 << 16 |
			((color2 >> 8 & 0xFF) * invertedTransparency + (color1 >> 8 & 0xFF) * transparency) // 1 << 8 |
			((color2 & 0xFF) * invertedTransparency + (color1 & 0xFF) * transparency) // 1
	end]])()
else
	colorBlend = function(color1, color2, transparency)
		local invertedTransparency = 1 - transparency
		local r1, r2 = color1 / 65536, color2 / 65536
		local g1, g2 = (color1 - r1 * 65536) / 256, (color2 - r2 * 65536) / 256
		r1, r2, g1, g2 = r1 - r1 % 1, r2 - r2 % 1, g1 - g1 % 1, g2 - g2 % 1
		local r, g, b = r2 * invertedTransparency + r1 * transparency, g2 * invertedTransparency + g1 * transparency,
			(color2 - r2 * 65536 - g2 * 256) * invertedTransparency + (color1 - r1 * 65536 - g1 * 256) * transparency
		return (r - r % 1) * 65536 + (g - g % 1) * 256 + (b - b % 1)
		end
end

--------------------------------------------------------------------------------
--AdvancedRead Subsystem (Ported by Bs()Dd)

local bor, band, lshift, rshift

local function fold(init, op, ...)
  local result = init
  local args = table.pack(...)
  for i = 1, args.n do
    result = op(result, args[i])
  end
  return result
end

if computer.getArchitecture and computer.getArchitecture() == "Lua 5.3" then --bit32 isn't exists in Lua 5.3, why?
	bor, band, lshift, rshift = load([[local fold = ... return
	function(...) return fold(0, function(a, b) return a | b end, ...) end,
	function(...) return fold(0xFFFFFFFF, function(a, b) return a & b end, ...) end,
	function(x, disp) return (x << disp) & 0xFFFFFFFF end,
	function(x, disp) return (x >> disp) & 0xFFFFFFFF end]])(fold)
else bor, band, lshift, rshift = bit32.bor, bit32.band, bit32.lshift, bit32.rshift end

local function readUnicodeChar(file)
	local byteArray = {string.byte(file:read(1))}
	local nullBitPosition = 0
	for i = 1, 7 do
		if band(rshift(byteArray[1], 8 - i), 0x1) == 0x0 then
			nullBitPosition = i
			break
		end
	end
	for i = 1, nullBitPosition - 2 do
		table.insert(byteArray, string.byte(file:read(1)))
	end
	return string.char(table.unpack(byteArray))
end

local function readBytes(file, count)
	local bytes, result = {string.byte(file:read(count) or "\x00", 1, 8)}, 0
	for i = 1, #bytes do
		result = bor(lshift(result, 8), bytes[i])
	end
	return result
end

--------------------------------------------------------------------------------
--ImageLoader Subsystem (Ported by Bs0Dd)

local function iset(picture, x, y, background, foreground, alpha, symbol)
	local index = 4 * (picture[1] * (y - 1) + x) - 1
	picture[index], picture[index + 1], picture[index + 2], picture[index + 3] = background, foreground, alpha, symbol
	return picture
end

local function multiLoad(file, picture, mode) --MultiLoader for OCIF6 and OCIF7. Set mode = 0 to OCIF6, mode = 1 to OCIF7.
	picture[1] = string.byte(file:read(1))
	picture[2] = string.byte(file:read(1))
	local currentAlpha, currentSymbol, currentBackground, currentForeground, currentY
	for alpha = 1, string.byte(file:read(1)) + mode do
		currentAlpha = string.byte(file:read(1)) / 255
		for symbol = 1, readBytes(file, 2) + mode do
			currentSymbol = readUnicodeChar(file)
			for background = 1, string.byte(file:read(1)) + mode do
				currentBackground = to24Bit(string.byte(file:read(1)))
				for foreground = 1, string.byte(file:read(1)) + mode do
					currentForeground = to24Bit(string.byte(file:read(1)))
					for y = 1, string.byte(file:read(1)) + mode do
						currentY = string.byte(file:read(1))
						for x = 1, string.byte(file:read(1)) + mode do
							iset(
								picture,
								string.byte(file:read(1)),
								currentY,
								currentBackground,
								currentForeground,
								currentAlpha,
								currentSymbol
							)
						end
					end
				end
			end
		end
	end
end

local Loader = {}

Loader[5] = function(file, picture)
	picture[1] = readBytes(file, 2)
	picture[2] = readBytes(file, 2)
	for i = 1, picture[1] * picture[2] do
		table.insert(picture, to24Bit(string.byte(file:read(1))))
		table.insert(picture, to24Bit(string.byte(file:read(1))))
		table.insert(picture, string.byte(file:read(1)) / 255)
		table.insert(picture, readUnicodeChar(file))
	end
end

Loader[6] = function(file, picture)
	multiLoad(file, picture, 0)
end

Loader[7] = function(file, picture)
	multiLoad(file, picture, 1)
end

local function loadImage(path)
	local file, reason = io.open(path, "rb")
	if file then
		local readedSignature = file:read(4)
		if readedSignature == "OCIF" then
			local encodingMethod = string.byte(file:read(1))
			if Loader[encodingMethod] then
				local picture = {}
				local result, reason = xpcall(Loader[encodingMethod], debug.traceback, file, picture)
				file:close()
				if result then
					return picture
				else
					return false, "Failed to load OCIF image: " .. tostring(reason)
				end
			else
				file:close()
				return false, "Failed to load OCIF image: encoding method \"" .. tostring(encodingMethod) .. "\" is not supported"
			end
		else
			file:close()
			return false, "Failed to load OCIF image: binary signature \"" .. tostring(readedSignature) .. "\" is not valid"
		end
	else
		return false, "Failed to open file \"" .. tostring(path) .. "\" for reading: " .. tostring(reason)
	end
end

--------------------------------------------------------------------------------

local function flush(width, height)
	if not width or not height then
		width, height = GPUProxyGetResolution()
	end

	currentFrameBackgrounds, currentFrameForegrounds, currentFrameSymbols, newFrameBackgrounds, newFrameForegrounds, newFrameSymbols = {}, {}, {}, {}, {}, {}
	bufferWidth = width
	bufferHeight = height
	resetDrawLimit()

	for y = 1, bufferHeight do
		for x = 1, bufferWidth do
			tableInsert(currentFrameBackgrounds, 0x010101)
			tableInsert(currentFrameForegrounds, 0xFEFEFE)
			tableInsert(currentFrameSymbols, " ")

			tableInsert(newFrameBackgrounds, 0x010101)
			tableInsert(newFrameForegrounds, 0xFEFEFE)
			tableInsert(newFrameSymbols, " ")
		end
	end
end

local function setResolution(width, height)
	GPUProxySetResolution(width, height)
	flush(width, height)
end

local function getResolution()
	return bufferWidth, bufferHeight
end

local function getWidth()
	return bufferWidth
end

local function getHeight()
	return bufferHeight
end

local function bind(address, reset)
	local success, reason = GPUProxy.bind(address, reset)
	if success then
		if reset then
			setResolution(GPUProxy.maxResolution())
		else
			setResolution(bufferWidth, bufferHeight)
		end
	else
		return success, reason
	end
end

local function getGPUProxy()
	return GPUProxy
end

local function updateGPUProxyMethods()
	GPUProxyGet = GPUProxy.get
	GPUProxyGetResolution = GPUProxy.getResolution
	GPUProxyGetBackground = GPUProxy.getBackground
	GPUProxyGetForeground = GPUProxy.getForeground

	GPUProxySet = GPUProxy.set
	GPUProxySetResolution = GPUProxy.setResolution
	GPUProxySetBackground = GPUProxy.setBackground
	GPUProxySetForeground = GPUProxy.setForeground

	GPUProxyFill = GPUProxy.fill
end

local function setGPUProxy(proxy)
	GPUProxy = proxy
	updateGPUProxyMethods()
	flush()
end

local function getScaledResolution(scale)
	if not scale or scale > 1 then
		scale = 1
	elseif scale < 0.1 then
		scale = 0.1
	end

	local aspectWidth, aspectHeight = component.proxy(GPUProxy.getScreen()).getAspectRatio()
	local maxWidth, maxHeight = GPUProxy.maxResolution()
	local proportion = 2 * (16 * aspectWidth - 4.5) / (16 * aspectHeight - 4.5)
	 
	local height = scale * math.min(
		maxWidth / proportion,
		maxWidth,
		math.sqrt(maxWidth * maxHeight / proportion)
	)

	return math.floor(height * proportion), math.floor(height)
end

--------------------------------------------------------------------------------

local function rawSet(index, background, foreground, symbol)
	newFrameBackgrounds[index], newFrameForegrounds[index], newFrameSymbols[index] = background, foreground, symbol
end

local function rawGet(index)
	return newFrameBackgrounds[index], newFrameForegrounds[index], newFrameSymbols[index]
end

local function get(x, y)
	if x >= 1 and y >= 1 and x <= bufferWidth and y <= bufferHeight then
		local index = bufferWidth * (y - 1) + x
		return newFrameBackgrounds[index], newFrameForegrounds[index], newFrameSymbols[index]
	else
		return 0x000000, 0x000000, " "
	end
end

local function set(x, y, background, foreground, symbol)
	if x >= drawLimitX1 and y >= drawLimitY1 and x <= drawLimitX2 and y <= drawLimitY2 then
		local index = bufferWidth * (y - 1) + x
		newFrameBackgrounds[index], newFrameForegrounds[index], newFrameSymbols[index] = background, foreground, symbol
	end
end

local function drawRectangle(x, y, width, height, background, foreground, symbol, transparency) 
	local index, indexStepOnReachOfSquareWidth = bufferWidth * (y - 1) + x, bufferWidth - width
	for j = y, y + height - 1 do
		if j >= drawLimitY1 and j <= drawLimitY2 then
			for i = x, x + width - 1 do
				if i >= drawLimitX1 and i <= drawLimitX2 then
					if transparency then
						newFrameBackgrounds[index], newFrameForegrounds[index] =
							colorBlend(newFrameBackgrounds[index], background, transparency),
							colorBlend(newFrameForegrounds[index], background, transparency)
					else
						newFrameBackgrounds[index], newFrameForegrounds[index], newFrameSymbols[index] = background, foreground, symbol
					end
				end

				index = index + 1
			end

			index = index + indexStepOnReachOfSquareWidth
		else
			index = index + bufferWidth
		end
	end
end

local function clear(color, transparency)
	drawRectangle(1, 1, bufferWidth, bufferHeight, color or 0x0, 0x000000, " ", transparency)
end

local function copy(x, y, width, height)
	local copyArray, index = { width, height }

	for j = y, y + height - 1 do
		for i = x, x + width - 1 do
			if i >= 1 and j >= 1 and i <= bufferWidth and j <= bufferHeight then
				index = bufferWidth * (j - 1) + i
				tableInsert(copyArray, newFrameBackgrounds[index])
				tableInsert(copyArray, newFrameForegrounds[index])
				tableInsert(copyArray, newFrameSymbols[index])
			else
				tableInsert(copyArray, 0x0)
				tableInsert(copyArray, 0x0)
				tableInsert(copyArray, " ")
			end
		end
	end

	return copyArray
end

local function paste(startX, startY, picture)
	local imageWidth = picture[1]
	local bufferIndex, pictureIndex, bufferIndexStepOnReachOfImageWidth = bufferWidth * (startY - 1) + startX, 3, bufferWidth - imageWidth

	for y = startY, startY + picture[2] - 1 do
		if y >= drawLimitY1 and y <= drawLimitY2 then
			for x = startX, startX + imageWidth - 1 do
				if x >= drawLimitX1 and x <= drawLimitX2 then
					newFrameBackgrounds[bufferIndex] = picture[pictureIndex]
					newFrameForegrounds[bufferIndex] = picture[pictureIndex + 1]
					newFrameSymbols[bufferIndex] = picture[pictureIndex + 2]
				end

				bufferIndex, pictureIndex = bufferIndex + 1, pictureIndex + 3
			end

			bufferIndex = bufferIndex + bufferIndexStepOnReachOfImageWidth
		else
			bufferIndex, pictureIndex = bufferIndex + bufferWidth, pictureIndex + imageWidth * 3
		end
	end
end

local function rasterizeLine(x1, y1, x2, y2, method)
	local inLoopValueFrom, inLoopValueTo, outLoopValueFrom, outLoopValueTo, isReversed, inLoopValueDelta, outLoopValueDelta = x1, x2, y1, y2, false, mathAbs(x2 - x1), mathAbs(y2 - y1)
	if inLoopValueDelta < outLoopValueDelta then
		inLoopValueFrom, inLoopValueTo, outLoopValueFrom, outLoopValueTo, isReversed, inLoopValueDelta, outLoopValueDelta = y1, y2, x1, x2, true, outLoopValueDelta, inLoopValueDelta
	end

	if outLoopValueFrom > outLoopValueTo then
		outLoopValueFrom, outLoopValueTo = outLoopValueTo, outLoopValueFrom
		inLoopValueFrom, inLoopValueTo = inLoopValueTo, inLoopValueFrom
	end

	local outLoopValue, outLoopValueCounter, outLoopValueTriggerIncrement = outLoopValueFrom, 1, inLoopValueDelta / outLoopValueDelta
	local outLoopValueTrigger = outLoopValueTriggerIncrement
	for inLoopValue = inLoopValueFrom, inLoopValueTo, inLoopValueFrom < inLoopValueTo and 1 or -1 do
		if isReversed then
			method(outLoopValue, inLoopValue)
		else
			method(inLoopValue, outLoopValue)
		end

		outLoopValueCounter = outLoopValueCounter + 1
		if outLoopValueCounter > outLoopValueTrigger then
			outLoopValue, outLoopValueTrigger = outLoopValue + 1, outLoopValueTrigger + outLoopValueTriggerIncrement
		end
	end
end

local function rasterizeEllipse(centerX, centerY, radiusX, radiusY, method)
	local function rasterizeEllipsePoints(XP, YP)
		method(centerX + XP, centerY + YP)
		method(centerX - XP, centerY + YP)
		method(centerX - XP, centerY - YP)
		method(centerX + XP, centerY - YP) 
	end

	local x, y, changeX, changeY, ellipseError, twoASquare, twoBSquare = radiusX, 0, radiusY * radiusY * (1 - 2 * radiusX), radiusX * radiusX, 0, 2 * radiusX * radiusX, 2 * radiusY * radiusY
	local stoppingX, stoppingY = twoBSquare * radiusX, 0

	while stoppingX >= stoppingY do
		rasterizeEllipsePoints(x, y)
		
		y, stoppingY, ellipseError = y + 1, stoppingY + twoASquare, ellipseError + changeY
		changeY = changeY + twoASquare

		if (2 * ellipseError + changeX) > 0 then
			x, stoppingX, ellipseError = x - 1, stoppingX - twoBSquare, ellipseError + changeX
			changeX = changeX + twoBSquare
		end
	end

	x, y, changeX, changeY, ellipseError, stoppingX, stoppingY = 0, radiusY, radiusY * radiusY, radiusX * radiusX * (1 - 2 * radiusY), 0, 0, twoASquare * radiusY

	while stoppingX <= stoppingY do 
		rasterizeEllipsePoints(x, y)
		
		x, stoppingX, ellipseError = x + 1, stoppingX + twoBSquare, ellipseError + changeX
		changeX = changeX + twoBSquare
		
		if (2 * ellipseError + changeY) > 0 then
			y, stoppingY, ellipseError = y - 1, stoppingY - twoASquare, ellipseError + changeY
			changeY = changeY + twoASquare
		end
	end
end

local function drawLine(x1, y1, x2, y2, background, foreground, symbol)
	rasterizeLine(x1, y1, x2, y2, function(x, y)
		set(x, y, background, foreground, symbol)
	end)
end

local function drawEllipse(centerX, centerY, radiusX, radiusY, background, foreground, symbol)
	rasterizeEllipse(centerX, centerY, radiusX, radiusY, function(x, y)
		set(x, y, background, foreground, symbol)
	end)
end

local function drawText(x, y, textColor, data, transparency)
	if y >= drawLimitY1 and y <= drawLimitY2 then
		local charIndex, bufferIndex = 1, bufferWidth * (y - 1) + x
		
		for charIndex = 1, unicodeLen(data) do
			if x >= drawLimitX1 and x <= drawLimitX2 then
				if transparency then
					newFrameForegrounds[bufferIndex] = colorBlend(newFrameBackgrounds[bufferIndex], textColor, transparency)
				else
					newFrameForegrounds[bufferIndex] = textColor
				end

				newFrameSymbols[bufferIndex] = unicodeSub(data, charIndex, charIndex)
			end

			x, bufferIndex = x + 1, bufferIndex + 1
		end
	end
end

local function drawImage(startX, startY, picture, blendForeground)
	local bufferIndex, pictureIndex, imageWidth, background, foreground, alpha, symbol = bufferWidth * (startY - 1) + startX, 3, picture[1]
	local bufferIndexStepOnReachOfImageWidth = bufferWidth - imageWidth

	for y = startY, startY + picture[2] - 1 do
		if y >= drawLimitY1 and y <= drawLimitY2 then
			for x = startX, startX + imageWidth - 1 do
				if x >= drawLimitX1 and x <= drawLimitX2 then
					alpha, symbol = picture[pictureIndex + 2], picture[pictureIndex + 3]
					
					-- If it's fully transparent pixel
					if alpha == 0 then
						newFrameBackgrounds[bufferIndex], newFrameForegrounds[bufferIndex] = picture[pictureIndex], picture[pictureIndex + 1]
					-- If it has some transparency
					elseif alpha > 0 and alpha < 1 then
						newFrameBackgrounds[bufferIndex] = colorBlend(newFrameBackgrounds[bufferIndex], picture[pictureIndex], alpha)
						
						if blendForeground then
							newFrameForegrounds[bufferIndex] = colorBlend(newFrameForegrounds[bufferIndex], picture[pictureIndex + 1], alpha)
						else
							newFrameForegrounds[bufferIndex] = picture[pictureIndex + 1]
						end
					-- If it's not transparent with whitespace
					elseif symbol ~= " " then
						newFrameForegrounds[bufferIndex] = picture[pictureIndex + 1]
					end

					newFrameSymbols[bufferIndex] = symbol
				end

				bufferIndex, pictureIndex = bufferIndex + 1, pictureIndex + 4
			end

			bufferIndex = bufferIndex + bufferIndexStepOnReachOfImageWidth
		else
			bufferIndex, pictureIndex = bufferIndex + bufferWidth, pictureIndex + imageWidth * 4
		end
	end
end

local function drawFrame(x, y, width, height, color)
	local stringUp, stringDown, x2 = "┌" .. string.rep("─", width - 2) .. "┐", "└" .. string.rep("─", width - 2) .. "┘", x + width - 1
	
	drawText(x, y, color, stringUp); y = y + 1
	for i = 1, height - 2 do
		drawText(x, y, color, "│")
		drawText(x2, y, color, "│")
		y = y + 1
	end
	drawText(x, y, color, stringDown)
end

--------------------------------------------------------------------------------

local function semiPixelRawSet(index, color, yPercentTwoEqualsZero)
	local upperPixel, lowerPixel, bothPixel = "▀", "▄", " "
	local background, foreground, symbol = newFrameBackgrounds[index], newFrameForegrounds[index], newFrameSymbols[index]

	if yPercentTwoEqualsZero then
		if symbol == upperPixel then
			if color == foreground then
				newFrameBackgrounds[index], newFrameForegrounds[index], newFrameSymbols[index] = color, foreground, bothPixel
			else
				newFrameBackgrounds[index], newFrameForegrounds[index], newFrameSymbols[index] = color, foreground, symbol
			end
		elseif symbol == bothPixel then
			if color ~= background then
				newFrameBackgrounds[index], newFrameForegrounds[index], newFrameSymbols[index] = background, color, lowerPixel
			end
		else
			newFrameBackgrounds[index], newFrameForegrounds[index], newFrameSymbols[index] = background, color, lowerPixel
		end
	else
		if symbol == lowerPixel then
			if color == foreground then
				newFrameBackgrounds[index], newFrameForegrounds[index], newFrameSymbols[index] = color, foreground, bothPixel
			else
				newFrameBackgrounds[index], newFrameForegrounds[index], newFrameSymbols[index] = color, foreground, symbol
			end
		elseif symbol == bothPixel then
			if color ~= background then
				newFrameBackgrounds[index], newFrameForegrounds[index], newFrameSymbols[index] = background, color, upperPixel
			end
		else
			newFrameBackgrounds[index], newFrameForegrounds[index], newFrameSymbols[index] = background, color, upperPixel
		end
	end
end

local function semiPixelSet(x, y, color)
	local yFixed = mathCeil(y / 2)
	if x >= drawLimitX1 and yFixed >= drawLimitY1 and x <= drawLimitX2 and yFixed <= drawLimitY2 then
		semiPixelRawSet(bufferWidth * (yFixed - 1) + x, color, y % 2 == 0)
	end
end

local function drawSemiPixelRectangle(x, y, width, height, color)
	local index, evenYIndexStep, oddYIndexStep, realY, evenY =
		bufferWidth * (mathCeil(y / 2) - 1) + x,
		(bufferWidth - width),
		width

	for pseudoY = y, y + height - 1 do
		realY = mathCeil(pseudoY / 2)

		if realY >= drawLimitY1 and realY <= drawLimitY2 then
			evenY = pseudoY % 2 == 0
			
			for pseudoX = x, x + width - 1 do
				if pseudoX >= drawLimitX1 and pseudoX <= drawLimitX2 then
					semiPixelRawSet(index, color, evenY)
				end

				index = index + 1
			end
		else
			index = index + width
		end

		if evenY then
			index = index + evenYIndexStep
		else
			index = index - oddYIndexStep
		end
	end
end

local function drawSemiPixelLine(x1, y1, x2, y2, color)
	rasterizeLine(x1, y1, x2, y2, function(x, y)
		semiPixelSet(x, y, color)
	end)
end

local function drawSemiPixelEllipse(centerX, centerY, radiusX, radiusY, color)
	rasterizeEllipse(centerX, centerY, radiusX, radiusY, function(x, y)
		semiPixelSet(x, y, color)
	end)
end

--------------------------------------------------------------------------------

local function getPointTimedPosition(firstPoint, secondPoint, time)
	return {
		x = firstPoint.x + (secondPoint.x - firstPoint.x) * time,
		y = firstPoint.y + (secondPoint.y - firstPoint.y) * time
	}
end

local function getConnectionPoints(points, time)
	local connectionPoints = {}
	for point = 1, #points - 1 do
		tableInsert(connectionPoints, getPointTimedPosition(points[point], points[point + 1], time))
	end
	return connectionPoints
end

local function getMainPointPosition(points, time)
	if #points > 1 then
		return getMainPointPosition(getConnectionPoints(points, time), time)
	else
		return points[1]
	end
end

local function drawSemiPixelCurve(points, color, precision)
	local linePoints = {}
	for time = 0, 1, precision or 0.01 do
		tableInsert(linePoints, getMainPointPosition(points, time))
	end
	
	for point = 1, #linePoints - 1 do
		drawSemiPixelLine(mathFloor(linePoints[point].x), mathFloor(linePoints[point].y), mathFloor(linePoints[point + 1].x), mathFloor(linePoints[point + 1].y), color)
	end
end

--------------------------------------------------------------------------------

local function update(force)	
	local index, indexStepOnEveryLine, changes = bufferWidth * (drawLimitY1 - 1) + drawLimitX1, (bufferWidth - drawLimitX2 + drawLimitX1 - 1), {}
	local x, equalChars, equalCharsIndex, charX, charIndex, currentForeground
	local currentFrameBackground, currentFrameForeground, currentFrameSymbol, changesCurrentFrameBackground, changesCurrentFrameBackgroundCurrentFrameForeground

	local changesCurrentFrameBackgroundCurrentFrameForegroundIndex

	for y = drawLimitY1, drawLimitY2 do
		x = drawLimitX1
		while x <= drawLimitX2 do			
			-- Determine if some pixel data was changed (or if <force> argument was passed)
			if
				currentFrameBackgrounds[index] ~= newFrameBackgrounds[index] or
				currentFrameForegrounds[index] ~= newFrameForegrounds[index] or
				currentFrameSymbols[index] ~= newFrameSymbols[index] or
				force
			then
				-- Make pixel at both frames equal
				currentFrameBackground, currentFrameForeground, currentFrameSymbol = newFrameBackgrounds[index], newFrameForegrounds[index], newFrameSymbols[index]
				currentFrameBackgrounds[index] = currentFrameBackground
				currentFrameForegrounds[index] = currentFrameForeground
				currentFrameSymbols[index] = currentFrameSymbol

				-- Look for pixels with equal chars from right of current pixel
				equalChars, equalCharsIndex, charX, charIndex = {currentFrameSymbol}, 2, x + 1, index + 1
				while charX <= drawLimitX2 do
					-- Pixels becomes equal only if they have same background and (whitespace char or same foreground)
					if	
						currentFrameBackground == newFrameBackgrounds[charIndex] and
						(
							newFrameSymbols[charIndex] == " " or
							currentFrameForeground == newFrameForegrounds[charIndex]
						)
					then
						-- Make pixel at both frames equal
					 	currentFrameBackgrounds[charIndex] = newFrameBackgrounds[charIndex]
					 	currentFrameForegrounds[charIndex] = newFrameForegrounds[charIndex]
					 	currentFrameSymbols[charIndex] = newFrameSymbols[charIndex]

					 	equalChars[equalCharsIndex], equalCharsIndex = currentFrameSymbols[charIndex], equalCharsIndex + 1
					else
						break
					end

					charX, charIndex = charX + 1, charIndex + 1
				end

				-- Group pixels that need to be drawn by background and foreground
				changes[currentFrameBackground] = changes[currentFrameBackground] or {}
				changesCurrentFrameBackground = changes[currentFrameBackground]
				changesCurrentFrameBackground[currentFrameForeground] = changesCurrentFrameBackground[currentFrameForeground] or {index = 1}
				changesCurrentFrameBackgroundCurrentFrameForeground = changesCurrentFrameBackground[currentFrameForeground]
				changesCurrentFrameBackgroundCurrentFrameForegroundIndex = changesCurrentFrameBackgroundCurrentFrameForeground.index
				
				changesCurrentFrameBackgroundCurrentFrameForeground[changesCurrentFrameBackgroundCurrentFrameForegroundIndex], changesCurrentFrameBackgroundCurrentFrameForegroundIndex = x, changesCurrentFrameBackgroundCurrentFrameForegroundIndex + 1
				changesCurrentFrameBackgroundCurrentFrameForeground[changesCurrentFrameBackgroundCurrentFrameForegroundIndex], changesCurrentFrameBackgroundCurrentFrameForegroundIndex = y, changesCurrentFrameBackgroundCurrentFrameForegroundIndex + 1
				changesCurrentFrameBackgroundCurrentFrameForeground[changesCurrentFrameBackgroundCurrentFrameForegroundIndex], changesCurrentFrameBackgroundCurrentFrameForegroundIndex = tableConcat(equalChars), changesCurrentFrameBackgroundCurrentFrameForegroundIndex + 1
				
				x, index, changesCurrentFrameBackgroundCurrentFrameForeground.index = x + equalCharsIndex - 2, index + equalCharsIndex - 2, changesCurrentFrameBackgroundCurrentFrameForegroundIndex
			end

			x, index = x + 1, index + 1
		end

		index = index + indexStepOnEveryLine
	end
	
	-- Draw grouped pixels on screen
	for background, foregrounds in pairs(changes) do
		GPUProxySetBackground(background)

		for foreground, pixels in pairs(foregrounds) do
			if currentForeground ~= foreground then
				GPUProxySetForeground(foreground)
				currentForeground = foreground
			end

			for i = 1, #pixels, 3 do
				GPUProxySet(pixels[i], pixels[i + 1], pixels[i + 2])
			end
		end
	end

	changes = nil
end

--------------------------------------------------------------------------------

return {
	loadImage = loadImage,

	getIndex = getIndex,
	setDrawLimit = setDrawLimit,
	resetDrawLimit = resetDrawLimit,
	getDrawLimit = getDrawLimit,
	flush = flush,
	setResolution = setResolution,
	bind = bind,
	setGPUProxy = setGPUProxy,
	getGPUProxy = getGPUProxy,
	getScaledResolution = getScaledResolution,
	getResolution = getResolution,
	getWidth = getWidth,
	getHeight = getHeight,
	getCurrentFrameTables = getCurrentFrameTables,
	getNewFrameTables = getNewFrameTables,

	rawSet = rawSet,
	rawGet = rawGet,
	get = get,
	set = set,
	clear = clear,
	copy = copy,
	paste = paste,
	rasterizeLine = rasterizeLine,
	rasterizeEllipse = rasterizeEllipse,
	semiPixelRawSet = semiPixelRawSet,
	semiPixelSet = semiPixelSet,
	update = update,

	drawRectangle = drawRectangle,
	drawLine = drawLine,
	drawEllipse = drawEllipse,
	drawText = drawText,
	drawImage = drawImage,
	drawFrame = drawFrame,

	drawSemiPixelRectangle = drawSemiPixelRectangle,
	drawSemiPixelLine = drawSemiPixelLine,
	drawSemiPixelEllipse = drawSemiPixelEllipse,
	drawSemiPixelCurve = drawSemiPixelCurve,
}
