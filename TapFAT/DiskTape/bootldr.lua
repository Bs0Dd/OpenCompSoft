local computer = computer
local component = component
local unicode = unicode
local filedescript = {}
local ramdisk

for k in component.list('filesystem') do
	local fs = component.proxy(k)
	if fs.getLabel() == 'tmpfs' then
		ramdisk = fs
		break
	end
end

local function ser(value)
	local id = "^[%a_][%w_]*$"
	local ts = {}
	local result_pack = {}
	local function recurse(current_value, depth)
		local t = type(current_value)
		if t == "number" then
			if current_value ~= current_value then
				table.insert(result_pack, "0/0")
			elseif current_value == math.huge then
				table.insert(result_pack, "math.huge")
			elseif current_value == -math.huge then
				table.insert(result_pack, "-math.huge")
			else
				table.insert(result_pack, tostring(current_value))
			end
		elseif t == "string" then
			table.insert(result_pack, (string.format("%q", current_value):gsub("\\\n","\\n")))
		elseif
			t == "nil" or
			t == "boolean" then
			table.insert(result_pack, tostring(current_value))
		elseif t == "table" then
			ts[current_value] = true
			local f
		local mt = getmetatable(current_value)
			f = table.pack((mt and mt.__pairs or pairs)(current_value))
			local i = 1
			local first = true
			table.insert(result_pack, "{")
			for k, v in table.unpack(f) do
				if not first then
					table.insert(result_pack, ",")
				end
				first = nil
				local tk = type(k)
				if tk == "number" and k == i then
					i = i + 1
					recurse(v, depth + 1)
				else
					if tk == "string" and string.match(k, id) then
						table.insert(result_pack, k)
					else
						table.insert(result_pack, "[")
						recurse(k, depth + 1)
						table.insert(result_pack, "]")
					end
					table.insert(result_pack, "=")
					recurse(v, depth + 1)
				end
			end
			ts[current_value] = nil
			table.insert(result_pack, "}")
		else
			error("unsupported type: " .. t,0)
		end
	end
	recurse(value, 1)
	local result = table.concat(result_pack)
	return result
end

local function unser(data)
	local result, reason = load("return " .. data, "=data", nil, {math={huge=math.huge}})
	if not result then
		return nil, reason
	end
	local ok, output = pcall(result)
	if not ok then
		return nil, output
	end
	return output
end

local function copytb(source)
	local result = {}
	for k, p in pairs(source) do
		result[k] = p
	end
	return result
end

local function segments(path)
	local parts = {}
	for part in path:gmatch("[^\\/]+") do
		local current, up = part:find("^%.?%.$")
		if current then
			if up == 2 then
				table.remove(parts)
			end
		else
			table.insert(parts, part)
		end
	end
	return parts
end

local function canonical(path)
	local result = table.concat(segments(path), "/")
	if unicode.sub(path, 1, 1) == "/" then
		return "/" .. result
	else
		return result
	end
end

local function gettim(driveprops)
	if not driveprops.stordate then return 0 end
	local name = 'lt'
	local f = ramdisk.open(name, "w")
	ramdisk.close(f)
	local time = ramdisk.lastModified(name)
	ramdisk.remove(name)
	return math.ceil(time)
end

local function oprval(ptab, filtab, wrt, val)
	if #ptab < 1 then return filtab end
	local i = 1
	local scan = filtab
	while i < #ptab do
		if scan[ptab[i]] == nil then
			return false
		end
		scan = scan[ptab[i]]
		i = i+1
	end
	if not wrt then return scan[ptab[i]] or false
	else scan[ptab[i]] = val return true end
end

local function setval(ptab, filtab, val)
	return oprval(ptab, filtab, true, val)
end

local function allocd(filtab, space)
	space = space or 0
	for _, elem in pairs(filtab) do
		if type(elem) == "table" then
			if elem[1] == -1 then
				space = allocd(elem, space)
			else
				space = space + elem[1]
			end
		end
	end
	return space
end

local function mkrdir(ptab, filtab, driveprops, num)
	if num > #ptab then return true end
	local checks = {}
	local i = 0
	while i<num do
		table.insert(checks, ptab[i+1])
		i = i+1
	end
	dir = oprval(checks, filtab)
	if dir == false then
		setval(checks, filtab, {-1, gettim(driveprops)})
	end
	return mkrdir(ptab, filtab, driveprops, num+1)
end

local function remdir(fil, fat, seg)
	for k, file in pairs(fil) do
		if type(k) ~= 'number' then
			if file[1] == -1 then
				local cseg = copytb(seg)
				table.insert(cseg, k)
				local sfil = oprval(cseg, fat[1])
				if not sfil then return sfil end
				if not remdir(sfil, fat, cseg) then return false end
			else
				for _, block in pairs(file[3]) do
					table.insert(fat[2], block)
				end				
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
		bsiz = bsiz + blocks[i][2]
		if psiz <= pos and bsiz >= pos then return i end
	end
	return false
end

local function blockssiz(fb, lb, fil)
	local bsiz = 0
	while fb <= lb do
		bsiz = bsiz + fil[3][fb][2]
		fb = fb+1
	end
	return bsiz
end

local function custsr(a, b)
	if a[1] < b[1] then return true
	else return false end
end

local function wrinew(fil, fat, stb, data, address)
	while true do
		if #fat[2] == 0 then
			fil[1] = blockssiz(1, #fil[3], fil)
			local res, err = stb(fat)
			if not res then return res, err else return true end
		elseif fat[2][1][2] < #data then
			table.insert(fil[3], {fat[2][1][1], fat[2][1][2]})
			component.invoke(address, "seek", -math.huge)
			component.invoke(address, "seek", fat[2][1][1])
			component.invoke(address, "write", data:sub(0,fat[2][1][2]))
			data = data:sub(fat[2][1][2]+1)
			table.remove(fat[2], 1)
		else
			table.insert(fil[3], {fat[2][1][1], #data})
			component.invoke(address, "seek", -math.huge)
			component.invoke(address, "seek", fat[2][1][1])
			component.invoke(address, "write", data)
			if #data == fat[2][1][2] then table.remove(fat[2], 1)
			else fat[2][1][1] = fat[2][1][1]+#data fat[2][1][2] = fat[2][1][2]-#data end
			break
		end
	end
	return 1
end

local function wrialloc(fil, data, address, seek)
	local strtbl = findblock(fil[3], seek)
	local endbl = #fil[3]
	if not endbl then endbl = #fil[3] end
	component.invoke(address, "seek", fil[3][strtbl][1]+seek-blockssiz(1, strtbl-1, fil))
	component.invoke(address, "write", data:sub(0,fil[3][strtbl][2]))
	data = data:sub(fil[3][strtbl][2])
	strtbl = strtbl + 1
	while strtbl < endbl + 1 do
		component.invoke(address, "seek", -math.huge)
		component.invoke(address, "seek", fil[3][strtbl][1])
		component.invoke(address, "write", data:sub(0,fil[3][strtbl][2]))
		data = data:sub(fil[3][strtbl][2])
		strtbl = strtbl + 1 
	end
end

local lzsscom, lzssdcom
if computer.getArchitecture() ~= "Lua 5.2" then
	lzsscom, lzssdcom = load([[return function(a)local b,c=1,{}local d=''local function e()for f=18,3,-1 do local g=string.sub(a,b,b+f-1)local h=string.find(d,g,1,true)if h then return h,g end end end;while b<=#a do local i,j=0,{}for f=0,7 do if b<=#a then local h,g=e()if h and#g>=3 then local k=h-1<<4|#g-3;j[#j+1]=string.pack('>I2',k)else i=i|(1<<f)g=string.sub(a,b,b)j[#j+1]=g end;d=string.sub(d..g,-4096)b=b+#g else break end end;if#j>0 then c[#c+1]=string.char(i)c[#c+1]=table.concat(j)end end;return table.concat(c)end,function(a)local b,c=1,{}local d=''while b<=#a do local i=string.byte(a,b)b=b+1;for f=1,8 do local g=nil;if i&1~=0 then if b<=#a then g=string.sub(a,b,b)b=b+1 end else if b+1<=#a then local k=string.unpack('>I2',a,b)b=b+2;local h=k>>4+1;local l=k&15+3;g=string.sub(d,h,h+l-1)end end;i=i>>1;if g then c[#c+1]=g;d=string.sub(d..g,-4096)end end end;return table.concat(c)end]])()
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
	local driveprops = {tabcom = false, stordate = true}
	component.invoke(address, "seek", -math.huge)
	local proxyObj = {}
	proxyObj.type = "filesystem"
	proxyObj.address = address:gsub("-","") .. "-tap"
	
	proxyObj.isReady = function()
		return component.invoke(address, "isReady")
	end
	
	proxyObj.setDriveProperty = function(proptype, value)
		checkArg(1,proptype,"string")
		checkArg(2,value,"number","string","boolean")
		if driveprops[proptype] == nil then return nil, 'Invalid property' end
		driveprops[proptype] = value
		return true
	end
	
	proxyObj.getDriveProperty = function(proptype)
		checkArg(1,proptype,"string")
		if driveprops[proptype] == nil then return nil, 'Invalid property' end
		return driveprops[proptype]
	end
	
	proxyObj.getTable = function()
		if not proxyObj.isReady() then error('Device is not ready',0) end
		component.invoke(address, "seek", -math.huge)
		local tabsec = component.invoke(address, "read", 8192)
		local rawtm
		if tabsec:sub(0,2) == "{{" then
			rawtm = tabsec:match("[^\0]+")
		elseif tabsec:sub(3,4) == "\120\156" then
			if not component.isAvailable('data') then error('inflate: Data card required',0) end
			if not string.unpack then error('string.unpack: Lua 5.3 or newer required',0) end
			rawtm = component.data.inflate(string.unpack('s2', tabsec))
		elseif tabsec:sub(0,2) ~= "\0\0" then
			if not lzssdcom then error('LZSS decompression: Lua 5.3 or newer required',0) end
			rawtm = lzssdcom(string.unpack('s2', tabsec))
		end
		if not rawtm or rawtm == "" then error('FAT corrupted: table not found',0) end
		local uns, err = unser(rawtm)
		if not uns then error('FAT corrupted: '..(err or 'unknown reason'),0)
		else return uns end
	end
	
	proxyObj.setTable = function(tab)
		checkArg(1,tab,"table")
		if not proxyObj.isReady() then error('Device is not ready',0) end
		local tstr = ser(tab)
		if driveprops.tabcom == 1 then
			if not lzsscom then error('LZSS compression: Lua 5.3 or newer required',0) end
			tstr = string.pack('s2', lzsscom(tstr))
		elseif driveprops.tabcom == 2 then
			if not component.isAvailable('data') then error('deflate: Data card required',0) end
			if not string.pack then error('string.pack: Lua 5.3 or newer required',0) end
			tstr = string.pack('s2', component.data.deflate(tstr))
		end
		if #tstr > 8192 then return nil, 'Not enough space for FAT' end
		if #tstr ~= 8192 then tstr = tstr.."\0" end
		component.invoke(address, "seek", -math.huge)
		component.invoke(address, "write", tstr)
		return #tstr
	end
	
	proxyObj.format = function(fast)
		fast = fast or false
		checkArg(1,fast,"boolean")
		if not proxyObj.isReady() then error('Device is not ready',0) end
		local siz = component.invoke(address, "getSize")
		if not fast then
			component.invoke(address, "seek", -math.huge)
			local ns = string.rep("\0", 8192)
			for i = 1, siz + 8191, 8192 do
				component.invoke(address, "write", ns)
			end
		end
		local res, err = proxyObj.setTable({{}, {{8192, math.ceil(siz)-8192}}})
		if not res then return res, err
		else
			if component.invoke(address, "getLabel") == "" then
				component.invoke(address, "setLabel", "TapFAT Data Tape")
			end
			return true
		end
	end
	
	proxyObj.isDirectory = function(path)
		checkArg(1,path,"string")
		if not proxyObj.isReady() then error('Device is not ready',0) end
		path = canonical(path)
		if path == '' then return true end
		local seg = segments(path)
		local fat = proxyObj.getTable()
		local list = oprval(seg, fat[1])
		if type(list) ~= 'table' then return false end
		if list[1] == -1 then return true else return false end
	end
	
	proxyObj.lastModified = function(path)
		checkArg(1,path,"string")
		path = canonical(path)
		if not proxyObj.isReady() then error('Device is not ready',0) end
		local fat = proxyObj.getTable()
		local seg = segments(path)
		local fil = oprval(seg, fat[1])
		if not fil then return 0 end
		return fil[2] or 0
	end
	
	proxyObj.list = function(path)
		checkArg(1,path,"string")
		path = canonical(path)
		if not proxyObj.isReady() then error('Device is not ready',0) end
		local fat = proxyObj.getTable()
		local seg = segments(path)
		local rlist = oprval(seg, fat[1])
		if rlist == false then return nil, 'no such file or directory: '..path end
		local list = {}
		if rlist[1] ~= -1 and #seg ~= 0 then return {seg[#seg], n=1} end
		for k, p in pairs(rlist) do
			if type(k) ~= 'number' then
				if p[1] == -1 then
					table.insert(list, k..'/')
				else
					table.insert(list, k)
				end
			end
		end
		list.n = #list
		return list
	end
	
	proxyObj.spaceTotal = function()
		if not proxyObj.isReady() then error('Device is not ready',0) end
		return component.invoke(address, "getSize")-8193
	end
	
	proxyObj.open = function(path,mode)
		mode = mode or 'r'
		checkArg(1,path,"string")
		checkArg(2,mode,"string")
		if not proxyObj.isReady() then error('Device is not ready',0) end
		local descrpt
		local fat = proxyObj.getTable()
		local seg = segments(path)
		if mode ~= "r" and mode ~= "rb" and mode ~= "w" and mode ~= "wb" and mode ~= "a" and mode ~= "ab" then
			error("unsupported mode",2)
		end
		local work = true
		while work do
			descrpt = math.random(1000000000,9999999999)
			if filedescript[descrpt] == nil then
				if mode == "r" or mode == "rb" then
					local fildat = oprval(seg, fat[1])
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
					local fildat = oprval(seg, fat[1])
					if fildat then
						for _, blk in pairs(fildat[3]) do
							table.insert(fat[2], blk)
						end
						table.sort(fat[2], custsr)
						local curb = 1
						while curb < #fat[2] do
							if fat[2][curb][1]+fat[2][curb][2] == fat[2][curb+1][1] then
								fat[2][curb][2] = fat[2][curb][2]+fat[2][curb+1][2]
								table.remove(fat[2], curb+1)
							else
								curb = curb + 1 
							end
						end
					elseif #fat[2] == 0 then return nil, "not enough space" end
					if not setval(seg, fat[1], {0, gettim(driveprops), {}}) then return false end
				elseif mode == "a" or mode == "ab" then
					local fildat = oprval(seg, fat[1])
					local sz
					if not fildat then
						if not setval(seg, fat[1], {0, gettim(driveprops), {}}) then return false end
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
		if not proxyObj.isReady() then error('Device is not ready',0) end
		path = canonical(path)
		if path == '' then return false end
		local fat = proxyObj.getTable()
		local seg = segments(path)
		local fil = oprval(seg, fat[1])
		if fil == false then return false end
		if fil[1] == -1 then
			remdir(fil, fat, seg)
		else
			for _, block in pairs(fil[3]) do
				table.insert(fat[2], block)
			end
			setval(seg, fat[1], nil)
		end
		table.sort(fat[2], custsr)
		local curb = 1
		while curb < #fat[2] do
			if fat[2][curb][1]+fat[2][curb][2] == fat[2][curb+1][1] then
				fat[2][curb][2] = fat[2][curb][2]+fat[2][curb+1][2]
				table.remove(fat[2], curb+1)
			else
				curb = curb + 1 
			end
		end
		local res, err = proxyObj.setTable(fat)
		if not res then return res, err else return true end
	end
	
	proxyObj.rename = function(path, newpath)
		checkArg(1,path,"string")
		checkArg(1,newpath,"string")
		if not proxyObj.isReady() then error('Device is not ready',0) end
		path = canonical(path)
		local fat = proxyObj.getTable()
		local seg = segments(path)
		local seg2 = segments(newpath)
		local fil = oprval(seg, fat[1])
		local fil2 = oprval(seg2, fat[1])
		if not fil or fil2 then return false end
		if fil[1] ~= -1 then seg2 = segments(newpath) end
		setval(seg, fat[1], nil)
		if not setval(seg2, fat[1], fil) then return false end
		local res, err = proxyObj.setTable(fat)
		if not res then return res, err else return true end
	end
	
	proxyObj.read = function(fd, count)
		count = count or 1
		checkArg(1,fd,"number")
		checkArg(2,count,"number")
		if not proxyObj.isReady() then error('Device is not ready',0) end
		if filedescript[fd] == nil or filedescript[fd].mode ~= "r" then
			return nil, "bad file descriptor"
		end
		local fat = proxyObj.getTable()
		local fil = oprval(filedescript[fd].path, fat[1])
		if not fil then filedescript[fd] = nil return nil, "bad file descriptor" end
		if fil[1] == 0 or fil[1] < filedescript[fd].seek+1 then return nil end
		if fil[1] >= filedescript[fd].seek+1 and fil[1] < filedescript[fd].seek+count then 
			count = fil[1]-filedescript[fd].seek 
		end
		component.invoke(address, "seek", -math.huge)
		local strtbl = findblock(fil[3], filedescript[fd].seek)
		local endbl = findblock(fil[3], filedescript[fd].seek + count)
		if not endbl then endbl = #fil[3] end
		component.invoke(address, "seek", fil[3][strtbl][1]+filedescript[fd].seek-blockssiz(1, strtbl-1, fil))
		local data = component.invoke(address, "read", fil[3][strtbl][2])
		strtbl = strtbl + 1
		while strtbl < endbl + 1 do
			component.invoke(address, "seek", -math.huge)
			component.invoke(address, "seek", fil[3][strtbl][1])
			data = data..component.invoke(address, "read", fil[3][strtbl][2])
			strtbl = strtbl + 1 
		end
		data = data:sub(0, count)
		filedescript[fd].seek = filedescript[fd].seek + #data
		return data
	end
	
	proxyObj.close = function(fd)
		checkArg(1,fd,"number")
		if not proxyObj.isReady() then error('Device is not ready',0) end
		if filedescript[fd] == nil then
			return nil, "bad file descriptor"
		end
		filedescript[fd] = nil
	end
	
	proxyObj.getLabel = function()
		if not proxyObj.isReady() then error('Device is not ready',0) end
		return component.invoke(address, "getLabel")
	end
	
	proxyObj.seek = function(fd,kind,offset)
		checkArg(1,fd,"number")
		checkArg(2,kind,"string")
		checkArg(3,offset,"number")
		if not proxyObj.isReady() then error('Device is not ready',0) end
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
		if not proxyObj.isReady() then error('Device is not ready',0) end
		path = canonical(path)
		if path == '' then return 0 end
		local fat = proxyObj.getTable()
		local seg = segments(path)
		local fil = oprval(seg, fat[1])
		if not fil or fil[1] == -1 then return 0 end
		return fil[1]
	end
	
	proxyObj.isReadOnly = function()
		if not proxyObj.isReady() then error('Device is not ready',0) end
		return false
	end
	
	proxyObj.setLabel = function(newlabel)
		if not proxyObj.isReady() then error('Device is not ready',0) end
		component.invoke(address, "setLabel", newlabel)
		return newlabel
	end
	
	proxyObj.makeDirectory = function(path)
		checkArg(1,path,"string")
		if not proxyObj.isReady() then error('Device is not ready',0) end
		path = canonical(path)
		local fat = proxyObj.getTable()
		local seg = segments(path)
		mkrdir(seg, fat[1], driveprops, 1)
		local res, err = proxyObj.setTable(fat)
		if not res then return res, err else return true end
	end
	
	proxyObj.exists = function(path)
		checkArg(1,path,"string")
		if not proxyObj.isReady() then error('Device is not ready',0) end
		path = canonical(path)
		if path == '' then return true end
		local seg = segments(path)
		local fat = proxyObj.getTable()
		local list = oprval(seg, fat[1])
		if list then return true else return list end
	end
	
	proxyObj.spaceUsed = function()
		if not proxyObj.isReady() then error('Device is not ready',0) end
		return allocd(proxyObj.getTable()[1])
	end
	
	proxyObj.write = function(fd,data)
		checkArg(1,fd,"number")
		checkArg(2,data,"string")
		if not proxyObj.isReady() then error('Device is not ready',0) end
		if filedescript[fd] == nil or filedescript[fd].mode == "r" then
			return nil, "bad file descriptor"
		end
		local fat = proxyObj.getTable()
		if #fat[2] == 0 then return nil, "not enough space" end
		local seg = filedescript[fd].path
		local fil = oprval(seg, fat[1])
		filedescript[fd].seek = filedescript[fd].seek + #data
		if filedescript[fd].seek > fil[1] or #fil[3] == 0 then
			fil[1] = fil[1] + #data
			local res, err = wrinew(fil, fat, proxyObj.setTable, data, address)
			if not res then return res, err elseif res ~= 1 then return true end
		elseif filedescript[fd].seek + #data > fil[1] then
			fil[1] = filedescript[fd].seek + #data
			wrialloc(fil, data, address, filedescript[fd].seek)
			local res, err = wrinew(fil, fat, proxyObj.setTable, data, address)
			if not res then return res, err elseif res ~= 1 then return true end
		else
			wrialloc(fil, data, address, filedescript[fd].seek)
		end
		local curb = 1
		while curb < #fil[3] do
			if fil[3][curb][1]+fil[3][curb][2] == fil[3][curb+1][1] then
				fil[3][curb][2] = fil[3][curb][2]+fil[3][curb+1][2]
				table.remove(fil[3], curb+1)
			else
				curb = curb + 1 
			end
		end
		setval(seg, fat[1], fil)
		local res, err = proxyObj.setTable(fat)
		if not res then return res, err else return true end
	end
	
	return proxyObj
end

local drive = tapfat.proxy(component.list('tape_drive')())
local oproxy = component.proxy
function component.proxy(address)
	checkArg(1,address,"string")
	if drive.address == address then
		return drive
	end
	return oproxy(address)
end

local olist = component.list
function component.list(filter, exact)
	local dlist = olist(filter, exact)
	if filter == nil or (exact and filter == 'filesystem') or (not exact and ('filesystem'):find(filter, nil, true)) then
		dlist[drive.address] = 'filesystem'
	end
	return dlist
end

local oinvoke = component.invoke
function component.invoke(address, method, ...)
	checkArg(1,address,"string")
	checkArg(2,method,"string")
	if drive.address == address then
		if drive[method] == nil then
			error("no such method",2)
		end
		return drive[method](...)
	end
	return oinvoke(address, method, ...)
end
