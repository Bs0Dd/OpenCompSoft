--[[NyaDraw Graphic Engine v1.07 for OpenOS
	Standalone "Screen.lua" port from MineOS
	More info on: https://github.com/Bs0Dd/OpenCompSoft/blob/master/NyaDraw/README.md
	2015-2021 - ECS: https://github.com/IgorTimofeev
	2021 - Bs0Dd: https://github.com/Bs0Dd
]]

local unicode = require("unicode")
local computer = require("computer")
local bit32 = require("bit32")

--------------------------------------------------------------------------------

local bufferWidth, bufferHeight
local currentFrameBackgrounds, currentFrameForegrounds, currentFrameSymbols, newFrameBackgrounds, newFrameForegrounds, newFrameSymbols
local drawLimitX1, drawLimitX2, drawLimitY1, drawLimitY2
local GPUProxy, GPUProxyGetResolution, GPUProxySetResolution, GPUProxyGetBackground, GPUProxyGetForeground, GPUProxySetBackground, GPUProxySetForeground, GPUProxyGet, GPUProxySet, GPUProxyFill

local mathCeil, mathFloor, mathModf, mathAbs, mathMin, mathMax = math.ceil, math.floor, math.modf, math.abs, math.min, math.max
local tableInsert, tableConcat = table.insert, table.concat
local colorIntegerToRGB, colorRGBToInteger, colorBlend
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
	colorIntegerToRGB, colorRGBToInteger, colorBlend = load([[return function(integerColor)
		return integerColor >> 16, integerColor >> 8 & 0xFF, integerColor & 0xFF
	end,
	function(r, g, b)
		return r << 16 | g << 8 | b
	end,
	function(color1, color2, transparency)
		local invertedTransparency = 1 - transparency
		return
			((color2 >> 16) * invertedTransparency + (color1 >> 16) * transparency) // 1 << 16 |
			((color2 >> 8 & 0xFF) * invertedTransparency + (color1 >> 8 & 0xFF) * transparency) // 1 << 8 |
			((color2 & 0xFF) * invertedTransparency + (color1 & 0xFF) * transparency) // 1
	end]])()
else
	colorIntegerToRGB = function(integerColor)
		local r = integerColor / 65536
		r = r - r % 1
		local g = (integerColor - r * 65536) / 256
		g = g - g % 1
		return r, g, integerColor - r * 65536 - g * 256
	end
	colorRGBToInteger = function(r, g, b)
		return r * 65536 + g * 256 + b
	end
	colorBlend = function(color1, color2, transparency)
		local invertedTransparency = 1 - transparency
		local r1, r2 = color1 / 65536, color2 / 65536
		r1, r2 = r1 - r1 % 1, r2 - r2 % 1
		local g1, g2 = (color1 - r1 * 65536) / 256, (color2 - r2 * 65536) / 256
		g1, g2 = g1 - g1 % 1, g2 - g2 % 1
		local r, g, b = r2 * invertedTransparency + r1 * transparency, g2 * invertedTransparency + g1 * transparency,
			(color2 - r2 * 65536 - g2 * 256) * invertedTransparency + (color1 - r1 * 65536 - g1 * 256) * transparency
		return (r - r % 1) * 65536 + (g - g % 1) * 256 + (b - b % 1)
		end
end

--------------------------------------------------------------------------------
--AdvancedRead Subsystem (Ported by Bs()Dd)

local function fold(init, op, ...)
  local result = init
  local args = table.pack(...)
  for i = 1, args.n do
    result = op(result, args[i])
  end
  return result
end

local function readUnicodeChar(file)
	local byteArray = {string.byte(file:read(1))}
	local nullBitPosition = 0
	for i = 1, 7 do
		if bit32.band(bit32.rshift(byteArray[1], 8 - i), 0x1) == 0x0 then
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
		result = bit32.bor(bit32.lshift(result, 8), bytes[i])
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

local function multiLoad(file, picture, ocif7, ocif8) --MultiLoader for OCIF6-8.
	picture[1] = string.byte(file:read(1)) + ocif8
	picture[2] = string.byte(file:read(1)) + ocif8
	local currentAlpha, currentSymbol, currentBackground, currentForeground, currentY
	for alpha = 1, string.byte(file:read(1)) + ocif7 do
		currentAlpha = string.byte(file:read(1)) / 255
		for symbol = 1, readBytes(file, 2) + ocif7 do
			currentSymbol = readUnicodeChar(file)
			for background = 1, string.byte(file:read(1)) + ocif7 do
				currentBackground = to24Bit(string.byte(file:read(1)))
				for foreground = 1, string.byte(file:read(1)) + ocif7 do
					currentForeground = to24Bit(string.byte(file:read(1)))
					for y = 1, string.byte(file:read(1)) + ocif7 do
						currentY = string.byte(file:read(1))
						for x = 1, string.byte(file:read(1)) + ocif7 do
							iset(
								picture,
								string.byte(file:read(1)) + ocif8,
								currentY + ocif8,
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
	multiLoad(file, picture, 0, 0)
end

Loader[7] = function(file, picture)
	multiLoad(file, picture, 1, 0)
end

Loader[8] = function(file, picture)
	multiLoad(file, picture, 1, 1)
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
	 
	local height = scale * mathMin(
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
	local temp

	-- Clipping left
	if x < drawLimitX1 then
		width = width - drawLimitX1 + x
		x = drawLimitX1
	end

	-- Right
	temp = x + width - 1
	if temp > drawLimitX2 then
		width = width - temp + drawLimitX2
	end

	-- Top
	if y < drawLimitY1 then
		height = height - drawLimitY1 + y
		y = drawLimitY1
	end

	-- Bottom
	temp = y + height - 1
	if temp > drawLimitY2 then
		height = height - temp + drawLimitY2
	end

	temp = bufferWidth * (y - 1) + x
	local indexStepOnEveryLine = bufferWidth - width

	if transparency then
		for j = 1, height do
			for i = 1, width do
				newFrameBackgrounds[temp],
				newFrameForegrounds[temp] =
					colorBlend(newFrameBackgrounds[temp], background, transparency),
					colorBlend(newFrameForegrounds[temp], background, transparency)

				temp = temp + 1
			end

			temp = temp + indexStepOnEveryLine
		end
	else
		for j = 1, height do
			for i = 1, width do
				newFrameBackgrounds[temp],
				newFrameForegrounds[temp],
				newFrameSymbols[temp] = background, foreground, symbol

				temp = temp + 1
			end

			temp = temp + indexStepOnEveryLine
		end
	end
end

local function blur(x, y, width, height, radius, color, transparency)
	local temp

	-- Clipping left
	if x < drawLimitX1 then
		width = width - drawLimitX1 + x
		x = drawLimitX1
	end

	-- Right
	temp = x + width - 1
	if temp > drawLimitX2 then
		width = width - temp + drawLimitX2
	end

	-- Top
	if y < drawLimitY1 then
		height = height - drawLimitY1 + y
		y = drawLimitY1
	end

	-- Bottom
	temp = y + height - 1
	if temp > drawLimitY2 then
		height = height - temp + drawLimitY2
	end

	local screenIndex, indexStepOnEveryLine, buffer, bufferIndex, rSum, gSum, bSum, rSumFg, gSumFg, bSumFg, r, g, b =
		bufferWidth * (y - 1) + x,
		bufferWidth - width,
		{},
		1

	-- Copying
	temp = screenIndex

	if color then
		for j = 1, height do
			for i = 1, width do
				buffer[bufferIndex] = colorBlend(newFrameBackgrounds[temp], color, transparency)

				temp, bufferIndex = temp + 1, bufferIndex + 1
			end
			
			temp = temp + indexStepOnEveryLine
		end
else
		for j = 1, height do
			for i = 1, width do
				buffer[bufferIndex] = newFrameBackgrounds[temp]

				temp, bufferIndex = temp + 1, bufferIndex + 1
			end

			temp = temp + indexStepOnEveryLine
		end
	end

	-- Blurring
	local rSum, gSum, bSum, count, r, g, b

	for j = 1, height do
		for i = 1, width do
			rSum, gSum, bSum, count = 0, 0, 0, 0

			for jr = mathMax(1, j - radius), mathMin(j + radius, height) do
				for ir = mathMax(1, i - radius), mathMin(i + radius, width) do
					r, g, b = colorIntegerToRGB(buffer[width * (jr - 1) + ir])
					rSum, gSum, bSum, count = rSum + r, gSum + g, bSum + b, count + 1
				end
			end

			-- Calculatin average channels value
			r, g, b = rSum / count, gSum / count, bSum / count
			-- Faster than math.floor
			r, g, b = r - r % 1, g - g % 1, b - b % 1

			newFrameBackgrounds[screenIndex] = colorRGBToInteger(r, g, b)
			newFrameForegrounds[screenIndex] = 0x0
			newFrameSymbols[screenIndex] = " "

			screenIndex = screenIndex + 1
		end

		screenIndex = screenIndex + indexStepOnEveryLine
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
	local screenIndex, pictureIndex, screenIndexStepOnReachOfImageWidth = bufferWidth * (startY - 1) + startX, 3, bufferWidth - imageWidth

	for y = startY, startY + picture[2] - 1 do
		if y >= drawLimitY1 and y <= drawLimitY2 then
			for x = startX, startX + imageWidth - 1 do
				if x >= drawLimitX1 and x <= drawLimitX2 then
					newFrameBackgrounds[screenIndex] = picture[pictureIndex]
					newFrameForegrounds[screenIndex] = picture[pictureIndex + 1]
					newFrameSymbols[screenIndex] = picture[pictureIndex + 2]
				end

				screenIndex, pictureIndex = screenIndex + 1, pictureIndex + 3
			end

			screenIndex = screenIndex + screenIndexStepOnReachOfImageWidth
		else
			screenIndex, pictureIndex = screenIndex + bufferWidth, pictureIndex + imageWidth * 3
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

local function rasterizePolygon(centerX, centerY, startX, startY, countOfEdges, method)
	local degreeStep = 360 / countOfEdges

	local deltaX, deltaY = startX - centerX, startY - centerY
	local radius = math.sqrt(deltaX ^ 2 + deltaY ^ 2)
	local halfRadius = radius / 2
	local startDegree = math.deg(math.asin(deltaX / radius))

	local function round(num) 
		if num >= 0 then
			return math.floor(num + 0.5) 
		else
			return math.ceil(num - 0.5)
		end
	end

	local function calculatePosition(degree)
		local radDegree = math.rad(degree)
		local deltaX2 = math.sin(radDegree) * radius
		local deltaY2 = math.cos(radDegree) * radius
		return round(centerX + deltaX2), round(centerY + (deltaY >= 0 and deltaY2 or -deltaY2))
	end

	local xOld, yOld, xNew, yNew = calculatePosition(startDegree)

	for degree = (startDegree + degreeStep - 1), (startDegree + 360), degreeStep do
		xNew, yNew = calculatePosition(degree)
		rasterizeLine(xOld, yOld, xNew, yNew, method)
		xOld, yOld = xNew, yNew
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

local function drawPolygon(centerX, centerY, radiusX, radiusY, background, foreground, countOfEdges, symbol)
	rasterizePolygon(centerX, centerY, radiusX, radiusY, countOfEdges, function(x, y)
		set(x, y, background, foreground, symbol)
	end)
end

local function drawText(x, y, textColor, data, transparency)
	if y >= drawLimitY1 and y <= drawLimitY2 then
		local charIndex, screenIndex = 1, bufferWidth * (y - 1) + x
		
		for charIndex = 1, unicodeLen(data) do
			if x >= drawLimitX1 and x <= drawLimitX2 then
				if transparency then
					newFrameForegrounds[screenIndex] = colorBlend(newFrameBackgrounds[screenIndex], textColor, transparency)
				else
					newFrameForegrounds[screenIndex] = textColor
				end

				newFrameSymbols[screenIndex] = unicodeSub(data, charIndex, charIndex)
			end

			x, screenIndex = x + 1, screenIndex + 1
		end
	end
end

local function drawImage(x, y, picture, blendForeground)
	local imageWidth, imageHeight, pictureIndex, temp = picture[1], picture[2], 3
	local clippedImageWidth, clippedImageHeight = imageWidth, imageHeight

	-- Clipping left
	if x < drawLimitX1 then
		temp = drawLimitX1 - x
		clippedImageWidth, x, pictureIndex = clippedImageWidth - temp, drawLimitX1, pictureIndex + temp * 4
	end

	-- Right
	temp = x + clippedImageWidth - 1
	if temp > drawLimitX2 then
		clippedImageWidth = clippedImageWidth - temp + drawLimitX2
	end

	-- Top
	if y < drawLimitY1 then
		temp = drawLimitY1 - y
		clippedImageHeight, y, pictureIndex = clippedImageHeight - temp, drawLimitY1, pictureIndex + temp * imageWidth * 4
	end

	-- Bottom
	temp = y + clippedImageHeight - 1
	if temp > drawLimitY2 then
		clippedImageHeight = clippedImageHeight - temp + drawLimitY2
	end

	local
		screenIndex,
		screenIndexStep,
		pictureIndexStep,
		background,
		foreground,
		alpha,
		symbol = bufferWidth * (y - 1) + x, bufferWidth - clippedImageWidth, (imageWidth - clippedImageWidth) * 4

	for j = 1, clippedImageHeight do
		for i = 1, clippedImageWidth do
			alpha, symbol = picture[pictureIndex + 2], picture[pictureIndex + 3]

			-- If it's fully transparent pixel
			if alpha == 0 then
				newFrameBackgrounds[screenIndex], newFrameForegrounds[screenIndex] = picture[pictureIndex], picture[pictureIndex + 1]
			-- If it has some transparency
			elseif alpha > 0 and alpha < 1 then
				newFrameBackgrounds[screenIndex] = colorBlend(newFrameBackgrounds[screenIndex], picture[pictureIndex], alpha)

				if blendForeground then
					newFrameForegrounds[screenIndex] = colorBlend(newFrameForegrounds[screenIndex], picture[pictureIndex + 1], alpha)
				else
					newFrameForegrounds[screenIndex] = picture[pictureIndex + 1]
				end
			-- If it's not transparent with whitespace
			elseif symbol ~= " " then
				newFrameForegrounds[screenIndex] = picture[pictureIndex + 1]
			end

			newFrameSymbols[screenIndex] = symbol

			screenIndex, pictureIndex = screenIndex + 1, pictureIndex + 4
		end
	
		screenIndex, pictureIndex = screenIndex + screenIndexStep, pictureIndex + pictureIndexStep
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
				changesCurrentFrameBackground = changes[currentFrameBackground] or {}
				changes[currentFrameBackground] = changesCurrentFrameBackground
				changesCurrentFrameBackgroundCurrentFrameForeground = changesCurrentFrameBackground[currentFrameForeground] or {index = 1}
				changesCurrentFrameBackground[currentFrameForeground] = changesCurrentFrameBackgroundCurrentFrameForeground
				
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
	rasterizePolygon = rasterizePolygon,
	semiPixelRawSet = semiPixelRawSet,
	semiPixelSet = semiPixelSet,
	update = update,

	drawRectangle = drawRectangle,
	drawLine = drawLine,
	drawEllipse = drawEllipse,
	drawPolygon = drawPolygon,
	drawText = drawText,
	drawImage = drawImage,
	drawFrame = drawFrame,
	blur = blur,

	drawSemiPixelRectangle = drawSemiPixelRectangle,
	drawSemiPixelLine = drawSemiPixelLine,
	drawSemiPixelEllipse = drawSemiPixelEllipse,
	drawSemiPixelCurve = drawSemiPixelCurve,
}
