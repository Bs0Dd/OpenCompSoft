local component = require("component")
local unicode = require("unicode")
local fs = require("filesystem")
local event = require("event")
local tty = require("tty")
local gpu = component.gpu
local internet = component.internet
---------------------------------------------------------------------------------------------------------------------------------

tty.clear()
print('VychVyzhProm (ВычВыжПром)')
print('Copyright (C) 2019 CAT IN THE DARK')
print('Copyright (C) 2021 Compys S&N Systems')
print('For more information go to: https://github.com/Bs0Dd/OpenCompSoft/blob/master/VychVyzhProm/README.md\n')

print('Do you want to install TapFAT? Y/N')
		while true do
			local _, _, _, key = event.pull("key_up")
			if key == 21 then break
			elseif key == 49 then return end
		end

---------------------------------------------------------------------------------------------------------------------------------

local files = {
	{
		url = "https://raw.githubusercontent.com/Bs0Dd/OpenCompSoft/master/VychVyzhProm/Languages/English.lng",
		path = "/home/vvprom/Languages/English.lng"
	},
	{
		url = "https://raw.githubusercontent.com/Bs0Dd/OpenCompSoft/master/VychVyzhProm/Languages/Russian.lng",
		path = "/home/vvprom/Languages/Russian.lng"
	},
	{
		url = "https://raw.githubusercontent.com/Bs0Dd/OpenCompSoft/master/VychVyzhProm/Pictures/bcontr.pic",
		path = "/home/vvprom/Pictures/bcontr.pic"
	},
	{
		url = "https://raw.githubusercontent.com/Bs0Dd/OpenCompSoft/master/VychVyzhProm/Pictures/cidlogo.pic",
		path = "/home/vvprom/Pictures/cidlogo.pic"
	},
	{
		url = "https://raw.githubusercontent.com/Bs0Dd/OpenCompSoft/master/VychVyzhProm/Pictures/comlogo.pic",
		path = "/home/vvprom/Pictures/comlogo.pic"
	},
	{
		url = "https://raw.githubusercontent.com/Bs0Dd/OpenCompSoft/master/VychVyzhProm/Pictures/editor.pic",
		path = "/home/vvprom/Pictures/editor.pic"
	},
	{
		url = "https://raw.githubusercontent.com/Bs0Dd/OpenCompSoft/master/VychVyzhProm/Pictures/exit.pic",
		path = "/home/vvprom/Pictures/exit.pic"
	},
	{
		url = "https://raw.githubusercontent.com/Bs0Dd/OpenCompSoft/master/VychVyzhProm/Pictures/help.pic",
		path = "/home/vvprom/Pictures/help.pic"
	},
	{
		url = "https://raw.githubusercontent.com/Bs0Dd/OpenCompSoft/master/VychVyzhProm/Pictures/info.pic",
		path = "/home/vvprom/Pictures/info.pic"
	},
	{
		url = "https://raw.githubusercontent.com/Bs0Dd/OpenCompSoft/master/VychVyzhProm/Pictures/controls.pic",
		path = "/home/vvprom/Pictures/controls.pic"
	},
	{
		url = "https://raw.githubusercontent.com/Bs0Dd/OpenCompSoft/master/VychVyzhProm/Pictures/task.pic",
		path = "/home/vvprom/Pictures/task.pic"
	},
	{
		url = "https://raw.githubusercontent.com/Bs0Dd/OpenCompSoft/master/VychVyzhProm/Pictures/vvprom.pic",
		path = "/home/vvprom/Pictures/vvprom.pic"
	},
	{
		url = "https://raw.githubusercontent.com/Bs0Dd/OpenCompSoft/master/VychVyzhProm/Tasks/task1.vtf",
		path = "/home/vvprom/Tasks/task1.vtf"
	},
	{
		url = "https://raw.githubusercontent.com/Bs0Dd/OpenCompSoft/master/VychVyzhProm/Tasks/task2.vtf",
		path = "/home/vvprom/Tasks/task2.vtf"
	},
	{
		url = "https://raw.githubusercontent.com/Bs0Dd/OpenCompSoft/master/VychVyzhProm/Tasks/task3.vtf",
		path = "/home/vvprom/Tasks/task3.vtf"
	},
	{
		url = "https://raw.githubusercontent.com/Bs0Dd/OpenCompSoft/master/VychVyzhProm/Tasks/task4.vtf",
		path = "/home/vvprom/Tasks/task4.vtf"
	},
	{
		url = "https://raw.githubusercontent.com/Bs0Dd/OpenCompSoft/master/VychVyzhProm/Tasks/task5.vtf",
		path = "/home/vvprom/Tasks/task5.vtf"
	},
	{
		url = "https://raw.githubusercontent.com/Bs0Dd/OpenCompSoft/master/VychVyzhProm/Tasks/task6.vtf",
		path = "/home/vvprom/Tasks/task6.vtf"
	},
	{
		url = "https://raw.githubusercontent.com/Bs0Dd/OpenCompSoft/master/VychVyzhProm/Tasks/task7.vtf",
		path = "/home/vvprom/Tasks/task7.vtf"
	},
	{
		url = "https://raw.githubusercontent.com/Bs0Dd/OpenCompSoft/master/VychVyzhProm/Tasks/task8.vtf",
		path = "/home/vvprom/Tasks/task8.vtf"
	},
	{
		url = "https://raw.githubusercontent.com/Bs0Dd/OpenCompSoft/master/NyaDraw/NyaDrMini.lua",
		path = "/home/vvprom/NyaDraw/init.lua"
	},
	{
		url = "https://raw.githubusercontent.com/Bs0Dd/OpenCompSoft/master/VychVyzhProm/vvprom.lua",
		path = "/home/vvprom/vvprom.lua"
	},
}

local properties = {
	GUIElementsOffset = 2,
	localization = {
		title = "Installing VychVyzhProm game...",
		currentFile = "Downloading \"<currentFile>\"",
		totalProgress = "Total progress: <totalProgress>%",
		finished1 = "VychVyzhProm has been successfully installed",
		finished2 = "Type \"cd /home/vvprom\" and \"vvprom\"",
		finished3 = "to run a game",
		finished4 = "Press any key to quit",
	}
}

if gpu.maxResolution() < 80 then
	properties.windowWidth = 48
	properties.windowX = 2
	properties.colors = {
		window = {
			background = 1,
			text = 0,
			shadow = 0
		},
		title = {
			background = 0,
			text = 1,
		},
		progressBar = {
			active = 0,
			passive = 1
		}
	}
else
	properties.windowWidth = 56
	properties.colors = {
		window = {
			background = 0xEEEEEE,
			text = 0x999999,
			shadow = 0x3C3C3C
		},
		title = {
			background = 0xCCCCCC,
			text = 0x555555,
		},
		progressBar = {
			active = 0x0092FF,
			passive = 0xCCCCCC
		}
	}
end



---------------------------------------------------------------------------------------------------------------------------------

local screenWidth, screenHeight = gpu.getResolution()
properties.windowHeight = 8

if properties.windowWidth < 1 then
	properties.windowWidth = math.floor(screenWidth * properties.windowWidth)
end
progressBarWidth = properties.windowWidth - properties.GUIElementsOffset * 2

if not properties.windowX then
	properties.windowX = math.floor(screenWidth / 2 - properties.windowWidth / 2)
end

if not properties.windowY then
	properties.windowY = math.floor(screenHeight / 2 - properties.windowHeight / 2)
end

local currentBackground, currentForeground

---------------------------------------------------------------------------------------------------------------------------------

local function setBackground(color)
	if currentBackground ~= color then
		gpu.setBackground(color)
		currentBackground = color
	end
end

local function setForeground(color)
	if currentForeground ~= color then
		gpu.setForeground(color)
		currentForeground = color
	end
end

local function rectangle(x, y, width, height, color)
	setBackground(color)
	gpu.fill(x, y, width, height, " ")
end

local function centerizedText(y, color, text)
	local textLength = unicode.len(text)
	if textLength > progressBarWidth then
		text = unicode.sub(text, 1, progressBarWidth)
		textLength = progressBarWidth
	end

	setForeground(color)
	gpu.set(properties.windowX + properties.GUIElementsOffset, y, string.rep(" ", progressBarWidth))
	gpu.set(math.floor(properties.windowX + properties.GUIElementsOffset + progressBarWidth / 2 - textLength / 2), y, text)
end

local function progressBar(y, percent, text, totalProgress, currentProgress, currentFile)
	setForeground(properties.colors.progressBar.passive)
	gpu.set(properties.windowX + properties.GUIElementsOffset, y, string.rep("━", progressBarWidth))
	setForeground(properties.colors.progressBar.active)
	gpu.set(properties.windowX + properties.GUIElementsOffset, y, string.rep("━", math.ceil(progressBarWidth * percent)))

	text = text:gsub("<totalProgress>", totalProgress)
	text = text:gsub("<currentProgress>", currentProgress)
	text = text:gsub("<currentFile>", currentFile)

	centerizedText(y + 1, properties.colors.window.text, text)
end

local function download(url, path, totalProgress)
	fs.makeDirectory(fs.path(path))

	local file, fileReason = io.open(path, "w")
	if file then
		local pcallSuccess, requestHandle = pcall(internet.request, url)
		if pcallSuccess then
			if requestHandle then
				local y = properties.windowY + 2
				progressBar(y, 0, properties.localization.currentFile, totalProgress, "0", path)
				
				local responseCode, responseName, responseData
				repeat
					responseCode, responseName, responseData = requestHandle:response()
				until responseCode

				if responseData and responseData["Content-Length"] then
					local contentLength = tonumber(responseData["Content-Length"][1])
					local currentLength = 0
					while true do
						local data, reason = requestHandle.read(math.huge)
						if data then
							currentLength = currentLength + unicode.len(data)
							local percent = currentLength / contentLength
							progressBar(y, percent, properties.localization.currentFile, totalProgress, tostring(math.ceil(percent)), path)

							file:write(data)
						else
							requestHandle:close()
							if reason then
								error(reason)
							else
								file:close()
								return
							end
						end
					end
				else
					error("Response Content-Length header is missing: " .. tostring(responseCode) .. " " .. tostring(responseName))
				end
			else
				error("Invalid URL-address: " .. tostring(url))
			end 
		else
			error("Usage: component.internet.request(string url)")
		end

		file:close()
	else
		error("Failed to open file for writing: " .. tostring(fileReason))
	end
end

---------------------------------------------------------------------------------------------------------------------------------

local oldPixels = {}
for y = properties.windowY, properties.windowY + properties.windowHeight do
	oldPixels[y] = {}
	for x = properties.windowX, properties.windowX + properties.windowWidth do
		oldPixels[y][x] = { gpu.get(x, y) }
	end
end

local function shadowPixel(x, y, symbol)
	setBackground(oldPixels[y][x][3])
	gpu.set(x, y, symbol)
end

rectangle(properties.windowX + properties.windowWidth, properties.windowY + 1, 1, properties.windowHeight - 1, properties.colors.window.shadow)
setForeground(properties.colors.window.shadow)
shadowPixel(properties.windowX + properties.windowWidth, properties.windowY, "▄")

for i = properties.windowX + 1, properties.windowX + properties.windowWidth do
	shadowPixel(i, properties.windowY + properties.windowHeight, "▀")
end

rectangle(properties.windowX, properties.windowY + 1, properties.windowWidth, properties.windowHeight - 1, properties.colors.window.background)

rectangle(properties.windowX, properties.windowY, properties.windowWidth, 1, properties.colors.title.background)
centerizedText(properties.windowY, properties.colors.title.text, properties.localization.title)
setBackground(properties.colors.window.background)

local y = properties.windowY + 5
progressBar(y, 0, properties.localization.totalProgress, "0", "0", files[1].path)
for i = 1, #files do
	local percent = i / #files
	local totalProgress = tostring(math.ceil(percent * 100))
	download(files[i].url, files[i].path, totalProgress)
	progressBar(y, percent, properties.localization.totalProgress, totalProgress, "0", files[i].path)
end

if properties.localization.finished1 then
	rectangle(properties.windowX, properties.windowY + 1, properties.windowWidth, properties.windowHeight - 1, properties.colors.window.background)
	centerizedText(properties.windowY + 2, properties.colors.window.text, properties.localization.finished1)
	centerizedText(properties.windowY + 3, properties.colors.window.text, properties.localization.finished2)
	centerizedText(properties.windowY + 4, properties.colors.window.text, properties.localization.finished3)
	centerizedText(properties.windowY + 6, properties.colors.window.text, properties.localization.finished4)

	while true do
		local eventType = event.pull()
		if eventType == "key_down" or eventType == "touch" then
			break
		end
	end
end

for y = properties.windowY, properties.windowY + properties.windowHeight do
	for x = properties.windowX, properties.windowX + properties.windowWidth do
		setBackground(oldPixels[y][x][3])
		setForeground(oldPixels[y][x][2])
		gpu.set(x, y, oldPixels[y][x][1])
	end
end