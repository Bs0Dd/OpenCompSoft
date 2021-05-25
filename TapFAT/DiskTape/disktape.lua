local c, p, int = component, computer
local gu, ci, ep = c.proxy(c.list('gpu')()), c.invoke, c.list("eeprom")()

local function un(dat)
  local rs, rn = load("return " .. dat, "=data", nil, {math={huge=math.huge}})
  if not rs then
    return nil, rn
  end
  local ok, ou = pcall(rs)
  if not ok then
    return nil, ou
  end
  return ou
end

local lzd
if p.getArchitecture() == "Lua 5.3" then
	lzd = load([[return function(a)local b,c=1,{}local d=''while b<=#a do local e=string.byte(a,b)b=b+1;for f=1,8 do local g=nil;if e&1~=0 then if b<=#a then g=string.sub(a,b,b)b=b+1 end else if b+1<=#a then local h=string.unpack('>I2',a,b)b=b+2;local i=h>>4+1;local j=h&15+3;g=string.sub(d,i,i+j-1)end end;e=e>>1;if g then c[#c+1]=g;d=string.sub(d..g,-4096)end end end;return table.concat(c)end]])()
end

local function fb(b, p)
	local i, z = 0, 0
	while i < #b do
		i = i+1
		local d = z
		z = z + (b[i][2] - b[i][1])
		if d <= p and z >= p then return i end
	end
	return false
end

local function bs(f, l, i)
	local z = 0
	while f <= l do
		z = z + (i[3][f][2] - i[3][f][1])
		f = f+1
	end
	return z
end

local function gt(ad)
		ci(ad, "seek", -math.huge)
		local ts, rtm = ci(ad, "read", 8192)
		if ts:sub(0,2) == "{{" then
			rtm = ts:match("[^\0]+")
		elseif ts:sub(3,4) == "\120\156" then
			if not c.list('data')() then error('inflate: Data card required',0) end
			rtm = c.proxy(c.list('data')()).inflate(string.unpack('s2', ts))
		else
			if not lzd then error('LZSS decompression: Lua 5.3 required',0) end
			rtm = lzd(string.unpack('s2', ts))
		end
		if not rtm or rtm == "" then error('FAT corrupted: table not found',0) end
		local uns, err = un(rtm)
		if not uns then error('FAT corrupted: '..(err or 'unknown reason'),0)
		else return uns end
end

local function gb(ad)
		local ft = gt(ad)
		local f = ft[1]['bootldr.sys']
		if not f then error("File bootldr.sys is not found", 0) end
		if f[1] == 0 then error("Incorrect bootldr.sys", 0) end
		ci(ad, "seek", -math.huge)
		local sb, eb = fb(f[3], 0), fb(f[3], 0 + f[1]-1)
		if not eb then eb = #f[3] end
		ci(ad, "seek", f[3][sb][1]-bs(1, sb-1, f))
		local dt = ci(ad, "read", f[3][sb][2] - f[3][sb][1])
		sb = sb + 1
		while sb < eb + 1 do
			ci(ad, "seek", -math.huge)
			ci(ad, "seek", f[3][sb][1])
			dt = dt..ci(ad, "read", f[3][sb][2] - f[3][sb][1])
			sb = sb + 1 
		end
		dt = dt:sub(0, f[1])
		return dt
end

gu.setBackground(0x000000)
gu.setForeground(0xFFFFFF)
gu.fill(1,1,300,300, ' ')
gu.set(1,1,'<--[DiskTape Lua BIOS]-->')
gu.set(1,2,"2021 (C) Compys S&N Systems")
p.beep(1000,0.2)
gu.set(1,4,"Looking for streamer...")

if c.list('tape_drive')() then
  gu.set(25,4,'found!')
  local srm, skp = c.proxy(c.list('tape_drive')())
  while not srm.isReady() do
	gu.set(1,5,"Insert tape or press any key to skip streamer!")
	local t = p.pullSignal(1)
	if t == 'key_down' then skp = true break end
  end
  if not skp then
	load(gb(srm.address))()
	c.proxy(ep).setData(srm.address:gsub("-","").."-tap")
  end
else 
  gu.set(25,4,'not found!')
  gu.set(1,5,'Booting from standard devices...') 
end
p.pullSignal(1)

do
  local function biv(ar, mt, ...)
    local rs = table.pack(pcall(c.invoke, ar, mt, ...))
    if not rs[1] then
      return nil, rs[2]
    else
      return table.unpack(rs, 2, rs.n)
    end
  end

  p.getBootAddress = function()
    return biv(ep, "getData")
  end
  p.setBootAddress = function(address)
    return biv(ep, "setData", address)
  end

  do
    local scr = c.list("screen")()
    if gu and screen then
      biv(gu, "bind", scr)
    end
  end
  local function tlf(ar)
    local hdl = biv(ar, "open", "/init.lua")
    if not hdl then
	  hdl = biv(ar, "open", "/OS.lua")
	  if not hdl then
	    return nil, "/init.lua or /OS.lua"
	  end
    end
    local bf = ""
    repeat
      local dat, rs = biv(ar, "read", hdl, math.huge)
      if not dat and rs then
        return nil, rs
      end
      bf = bf .. (dat or "")
    until not data
    biv(ar, "close", hdl)
    return load(bf, "=init")
  end
  local rs
  if p.getBootAddress() then
    int, rs = tlf(p.getBootAddress())
  end
  if not int then
    p.setBootAddress()
    for ar in c.list("filesystem") do
      int, rs = tlf(ar)
      if int then
        p.setBootAddress(ar)
        break
      end
    end
  end
  if not int then
    error("No bootable medium found" .. (rs and (": " .. tostring(rs)) or ""), 0)
  end
end
int()
