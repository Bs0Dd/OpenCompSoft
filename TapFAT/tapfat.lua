--[[Compys(TM) TapFAT v1.3 Shared Library
	2021 (C) Compys S&N Systems
    This is a driver library for a "Tape File Allocation Table" (or "TapFAT") system 
	With this system you can use Computronics Tapes as a file storage like Floppy
	The first 8Kb of a space is reserved for special FAT with info about files on tape
	Data fragmentation is supported to more effective space allocation on a tape
]]
local component = require("component")
local fs = require("filesystem")
local io = require("io")
local sz = require("serialization")

local ser = sz.serialize
local unser = sz.unserialize

local filedescript = {}

local function copytb(source)
	local result = {}
	for k, p in pairs(source) do
		result[k] = p
	end
	return result
end

local function setval(ptab, filtab, val, num)
	if num == nil then num = #ptab-1
	elseif num == -1 then return true end
	local i = 0
	local scan = filtab
	while i < #ptab - 1 do
		if ptab[i+1]:sub(-1)~='/' then ptab[i+1] = ptab[i+1]..'/' end
		i = i+1
	end
	i = 0
	while i < num do
		if scan[ptab[i+1]] == nil then return false end
		scan = scan[ptab[i+1]]
		i = i+1
	end
	scan[ptab[i+1]] = val
	return setval(ptab, filtab, scan, num-1)
end

local function getval(ptab, filtab)
	local i = 0
	local scan = filtab
	while i < #ptab - 1 do
		if ptab[i+1]:sub(-1)~='/' then ptab[i+1] = ptab[i+1]..'/' end
		i = i+1
	end
	i = 0
	while i < #ptab do
		if scan[ptab[i+1]] == nil then
			if i+1 == #ptab then
				ptab[i+1] = ptab[i+1]..'/'
				if scan[ptab[i+1]] == nil then return false end 
			else return false end
		end
		scan = scan[ptab[i+1]]
		i = i+1
	end
	return scan
end

local function mkrdir(ptab, filtab, num)
	if num > #ptab then return true end
	local checks = {}
	local i = 0
	while i<num do
		table.insert(checks, ptab[i+1])
		i = i+1
	end
	dir = getval(checks, filtab)
	if dir == false then
		setval(checks, filtab, {-1, math.ceil(os.time())})
	end
	return mkrdir(ptab, filtab, num+1)
end

local function remdir(fil, fat, seg)
	for k, file in pairs(fil) do
		if type(k) ~= 'number' then
			if file[1] == -1 then
				local cseg = copytb(seg)
				table.insert(cseg, k)
				local sfil = getval(cseg, fat[1])
				if not sfil then return sfil end
				if not remdir(sfil, fat, cseg) then return false end
			else
				for _, block in pairs(fil[3]) do
					table.insert(fat[2], block)
				end
				fat[3] = fat[3]-fil[1]
				
			end
		end
	end
	setval(seg, fat[1], nil)
	return true
end

local function findblock(blocks, pos)
	local i = 0
	local bsiz = 0
	while i < #blocks do
		i = i+1
		local psiz = bsiz
		bsiz = bsiz + (blocks[i][2] - blocks[i][1])
		if psiz <= pos and bsiz >= pos then return i end
	end
	return false
end

local function blockssiz(fb, lb, fil)
	local bsiz = 0
	while fb <= lb do
		bsiz = bsiz + (fil[3][fb][2] - fil[3][fb][1])
		fb = fb+1
	end
	return bsiz
end

local function custsr(a, b)
	if a[1] < b[1] then return true
	else return false end
end

local tapfat = {}
function tapfat.proxy(address)
	local found = false
	for k,v in component.list("tape_drive") do
		if k == address and v == "tape_drive" then
			found = true
			break
		end
	end
	if not found then
		error("No such component",2)
	end
	local label
	component.invoke(address, "seek", -math.huge)
	local proxyObj = {}
	proxyObj.type = "filesystem"
	proxyObj.address = "tap-" .. address:gsub("-","")
	
	proxyObj.isReady = function()
		return component.invoke(address, "isReady")
	end
	
	proxyObj.getTable = function()
		if not proxyObj.isReady() then return nil, 'Device is not ready' end
		component.invoke(address, "seek", -math.huge)
		local rawtab = component.invoke(address, "read", 8192)
		return unser(rawtab:match("[^\0]+"))
	end
	
	proxyObj.setTable = function(tab)
		checkArg(1,tab,"table")
		if not proxyObj.isReady() then return nil, 'Device is not ready' end
		local tstr = ser(tab)
		if #tstr > 8192 then 
			return nil, 'Not enough space for FAT'
		end
		component.invoke(address, "seek", -math.huge)
		component.invoke(address, "write", string.rep("\0", 8192))
		component.invoke(address, "seek", -math.huge)
		component.invoke(address, "write", tstr)
		return #tstr
	end
	
	proxyObj.format = function()
		if not proxyObj.isReady() then return nil, 'Device is not ready' end
		component.invoke(address, "seek", -math.huge)
		local ns = string.rep("\0", 8192)
		local siz = component.invoke(address, "getSize")
		for i = 1, siz + 8191, 8192 do
			component.invoke(address, "write", ns)
		end
		component.invoke(address, "seek", -math.huge)
		local emtabl = {{}, {{8193, math.ceil(siz)}}, 0}
		component.invoke(address, "write", ser(emtabl))
		return true
	end
	
	proxyObj.isDirectory = function(path)
		checkArg(1,path,"string")
		if not proxyObj.isReady() then return nil, 'Device is not ready' end
		path = fs.canonical(path)
		if path == '' then return true end
		local seg = fs.segments(path)
		local fat = proxyObj.getTable()
		local list = getval(seg, fat[1])
		if type(list) ~= 'table' then return false end
		if list[1] == -1 then return true else return false end
	end
	
	proxyObj.lastModified = function(path)
		checkArg(1,path,"string")
		path = fs.canonical(path)
		if not proxyObj.isReady() then return nil, 'Device is not ready' end
		local fat = proxyObj.getTable()
		local seg = fs.segments(path)
		local fil = getval(seg, fat[1])
		if fil == false then return 0 end
		return fil[2]
	end
	
	proxyObj.list = function(path)
		checkArg(1,path,"string")
		path = fs.canonical(path)
		if not proxyObj.isReady() then return nil, 'Device is not ready' end
		local fat = proxyObj.getTable()
		local seg = fs.segments(path)
		local rlist = getval(seg, fat[1])
		if rlist == false then return nil, 'no such file or directory: '..path end
		local list = {}
		if rlist[1] ~= -1 and path ~= '' then return {seg[#seg], n=1} end
		for k, p in pairs(rlist) do
			if type(k) ~= 'number' then
				table.insert(list, k)
			end
		end
		list.n = #list
		return list
	end
	
	proxyObj.spaceTotal = function()
		if not proxyObj.isReady() then return nil, 'Device is not ready' end
		return component.invoke(address, "getSize")-8192
	end
	
	proxyObj.open = function(path,mode)
		mode = mode or 'r'
		checkArg(1,path,"string")
		checkArg(2,mode,"string")
		if not proxyObj.isReady() then return nil, 'Device is not ready' end
		local descrpt
		local fat = proxyObj.getTable()
		local seg = fs.segments(path)
		if mode ~= "r" and mode ~= "rb" and mode ~= "w" and mode ~= "wb" and mode ~= "a" and mode ~= "ab" then
			error("unsupported mode",2)
		end
		local work = true
		while work do
			descrpt = math.random(1000000000,9999999999)
			if filedescript[descrpt] == nil then
				if mode == "r" or mode == "rb" then
					local fildat = getval(seg, fat[1])
					if not fildat or fildat[1] == -1 then return nil, path end
					filedescript[descrpt] = {
						seek = 0,
						mode = 'r',
						path = seg
					}
				elseif mode == "w" or mode == "wb" then
					filedescript[descrpt] = {
						seek = 0,
						mode = 'w',
						path = seg
					}
					if not setval(seg, fat[1], {0, math.ceil(os.time()), {}}) then return false end
				elseif mode == "a" or mode == "ab" then
					local fildat = getval(seg, fat[1])
					local sz
					if not fildat or fildat[1] == -1 then
						if not setval(seg, fat[1], {0, math.ceil(os.time()), {}}) then return false end
						sz = 0
					else sz = fildat[1]+1 end
					filedescript[descrpt] = {
						seek = sz,
						mode = 'a',
						path = seg
					}
				end
				work = false
			end
		end
		if mode == "a" or mode == "ab" or mode == "w" or mode == "wb" then
			local res, err = proxyObj.setTable(fat)
			if not res then return res, err else return descrpt end
		else
			return descrpt
		end
	end
	
	proxyObj.remove = function(path)
		checkArg(1,path,"string")
		if not proxyObj.isReady() then return nil, 'Device is not ready' end
		path = fs.canonical(path)
		if path == '' then return false end
		local fat = proxyObj.getTable()
		local seg = fs.segments(path)
		local fil = getval(seg, fat[1])
		if fil == false then return false end
		if fil[1] == -1 then
			remdir(fil, fat, seg)
		else
			for _, block in pairs(fil[3]) do
				table.insert(fat[2], block)
			end
			fat[3] = fat[3]-fil[1]
			setval(seg, fat[1], nil)
		end
		table.sort(fat[2], custsr)
		local res, err = proxyObj.setTable(fat)
		if not res then return res, err else return true end
		
	end
	
	proxyObj.rename = function(path, newpath)
		checkArg(1,path,"string")
		checkArg(1,newpath,"string")
		if not proxyObj.isReady() then return nil, 'Device is not ready' end
		path = fs.canonical(path)
		local fat = proxyObj.getTable()
		local seg = fs.segments(path)
		local seg2 = fs.segments(newpath)
		local fil = getval(seg, fat[1])
		local fil2 = getval(seg2, fat[1])
		if fil == false or fil2 ~= false then return false end
		setval(seg, fat[1], nil)
		setval(seg2, fat[1], fil)
		if not setval(seg2, fat[1], fil) then return false end
		local res, err = proxyObj.setTable(fat)
		if not res then return res, err else return true end
	end
	
	proxyObj.read = function(fd, count)
		count = count or 1
		checkArg(1,fd,"number")
		checkArg(2,count,"number")
		if not proxyObj.isReady() then return nil, 'Device is not ready' end
		if filedescript[fd] == nil or filedescript[fd].mode ~= "r" then
			return nil, "bad file descriptor"
		end
		local fat = proxyObj.getTable()
		local fil = getval(filedescript[fd].path, fat[1])
		if not fil then filedescript[fd] = nil return nil, "bad file descriptor" end
		if fil[1] == 0 or fil[1] < filedescript[fd].seek+1 then return nil end
		if fil[1] >= filedescript[fd].seek+1 and fil[1] < filedescript[fd].seek+count then 
			count = fil[1]-filedescript[fd].seek 
		end
		component.invoke(address, "seek", -math.huge)
		local strtbl = findblock(fil[3], filedescript[fd].seek)
		local endbl = findblock(fil[3], filedescript[fd].seek + count)
		if not endbl then endbl = #fil[3] end
		component.invoke(address, "seek", fil[3][strtbl][1]+filedescript[fd].seek-blockssiz(1, strtbl-1, fil)-1)
		local data = component.invoke(address, "read", fil[3][strtbl][2] - fil[3][strtbl][1]+1)
		strtbl = strtbl + 1
		while strtbl < endbl + 1 do
			component.invoke(address, "seek", -math.huge)
			component.invoke(address, "seek", fil[3][strtbl][1]-1)
			data = data..component.invoke(address, "read", fil[3][strtbl][2] - fil[3][strtbl][1]+1)
			strtbl = strtbl + 1 
		end
		data = data:sub(0, count)
		filedescript[fd].seek = filedescript[fd].seek + #data
		return data
	end
	
	proxyObj.close = function(fd)
		checkArg(1,fd,"number")
		if not proxyObj.isReady() then return nil, 'Device is not ready' end
		if filedescript[fd] == nil then
			return nil, "bad file descriptor"
		end
		filedescript[fd] = nil
	end
	
	proxyObj.getLabel = function()
		if not proxyObj.isReady() then return nil, 'Device is not ready' end
		return component.invoke(address, "getLabel")
	end
	
	proxyObj.seek = function(fd,kind,offset)
		checkArg(1,fd,"number")
		checkArg(2,kind,"string")
		checkArg(3,offset,"number")
		if not proxyObj.isReady() then return nil, 'Device is not ready' end
		if filedescript[fd] == nil then
			return nil, "bad file descriptor"
		end
		if kind ~= "set" and kind ~= "cur" and kind ~= "end" then
			error("invalid mode",2)
		end
		if offset < 0 then
			return nil, "Negative seek offset"
		end
		local newpos
		if kind == "set" then
			newpos = offset
		elseif kind == "cur" then
			newpos = filedescript[fd].seek + offset
		elseif kind == "end" then
			newpos = component.invoke(address, "getSize") + offset - 1
		end
		filedescript[fd].seek = math.min(math.max(newpos, 0), component.invoke(address, "getSize") - 1)
		return filedescript[fd].seek
	end
	
	proxyObj.size = function(path)
		checkArg(1,path,"string")
		if not proxyObj.isReady() then return nil, 'Device is not ready' end
		path = fs.canonical(path)
		local fat = proxyObj.getTable()
		local seg = fs.segments(path)
		local fil = getval(seg, fat[1])
		if fil == false or fil[1] == -1 then return 0 end
		return fil[1]
	end
	
	proxyObj.isReadOnly = function()
		if not proxyObj.isReady() then return nil, 'Device is not ready' end
		return false
	end
	
	proxyObj.setLabel = function(newlabel)
		if not proxyObj.isReady() then return nil, 'Device is not ready' end
		component.invoke(address, "setLabel", newlabel)
		return newlabel
	end
	
	proxyObj.makeDirectory = function(path)
		checkArg(1,path,"string")
		if not proxyObj.isReady() then return nil, 'Device is not ready' end
		path = fs.canonical(path)
		local fat = proxyObj.getTable()
		local seg = fs.segments(path)
		mkrdir(seg, fat[1], 1) 
		local res, err = proxyObj.setTable(fat)
		if not res then return res, err else return true end
	end
	
	proxyObj.exists = function(path)
		checkArg(1,path,"string")
		if not proxyObj.isReady() then return nil, 'Device is not ready' end
		path = fs.canonical(path)
		if path == '' then return true end
		local seg = fs.segments(path)
		local fat = proxyObj.getTable()
		local list = getval(seg, fat[1])
		if list then return true else return list end
	end
	
	proxyObj.spaceUsed = function()
		if not proxyObj.isReady() then return nil, 'Device is not ready' end
		return proxyObj.getTable()[3]
	end
	
	proxyObj.write = function(fd,data)
		-- checkArg(1,fd,"number")
		-- checkArg(2,data,"string")
		-- if not proxyObj.isReady() then return nil, 'Device is not ready' end
		-- if filedescript[fd] == nil or filedescript[fd].mode ~= "w" then
			-- return nil, "bad file descriptor"
		-- end

		-- component.invoke(address, "seek", -math.huge)
		-- component.invoke(address, "seek", filedescript[fd].seek)

		-- component.invoke(address, "write", data)
		-- filedescript[fd].seek = filedescript[fd].seek + #data
		-- return true
	end
	
	return proxyObj
end
return tapfat
