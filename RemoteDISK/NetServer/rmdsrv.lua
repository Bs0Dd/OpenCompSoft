--[[ RemoteDISK NetServer v1.03.
Server program for make NetClient Network disks. Client connecting by port, hostname, login and password
Uses settings from "/etc/rmdsrv.cfg"
Author: Bs()Dd
]]
local component = require("component")
local computer = require("computer")
local fs = require("filesystem")
local io = require("io")
local event = require("event")
local shell = require("shell")
local seriz = require("serialization")

local args, options = shell.parse(...)

online = {}

ofdesc = {}

if component.list("modem")() == nil then io.stderr:write("No Network Card is detected.") end
local card = component.proxy(component.list("modem")())

local function isOnline(adrr)
  for accad, _ in pairs(online) do
    if accad == adrr then return true end
  end
  return false
end

print('RemoteDISK NetServer v1.03')

if not fs.exists('/etc/rmdsrv.cfg') then
  cfg =io.open('/etc/rmdsrv.cfg', "w")
  cfg:write([[{
  port = ,
  hostname= "",
  login= "",
  password= "",
  hddaddress= ""
}]])
  cfg:close()
  print('NO SETTINGS FOUND! Please, go to "/etc/rmdsrv.cfg" and fill it.')
  computer.beep()
  computer.beep()
  os.exit()
else
  cfg =io.open('/etc/rmdsrv.cfg', "r")
  xsd = cfg:read(512)
  if xsd== nil or xsd== '' then 
    cfg =io.open('/etc/rmdsrv.cfg', "w")
    cfg:write([[{
  port = ,
  hostname= "",
  login= "",
  password= "",
  hddaddress= ""
}]])
    cfg:close()
    print('NO SETTINGS FOUND! Please, go to "/etc/rmdsrv.cfg" and fill it.')
    computer.beep()
    computer.beep()
    os.exit()
  end
  tsets = seriz.unserialize(xsd)
  rfs = component.proxy(tsets.hddaddress)
  port = tsets.port
end

if options.h then
  print("Options:")
  print("  -v  verbose mode")
  print("  -b  off beep, when new user connected")
  print("  -h  show this help")
  print("\nConfig file located in '/etc/rmdsrv.cfg'")
  os.exit()
end

card.open(port)

print('Hard drive '..rfs.address..' selected')
print('Server "'..tsets.hostname..'", port '..port)

print('\nPress CTRL+ALT+C to stop\n')


while true do
  _,_,opp,_,_,call,one,two,thr,four = event.pull("modem_message")
  
  if call == 'RDCL' then 
    print('[CONNECT]: '..opp..' is connected')
    if not options.b then computer.beep() end
    if one == tsets.hostname then card.send(opp, port, 'RDAN')
      _,_,opp,_,_,call,one,two = event.pull("modem_message")
      if call == 'RDLG' and one == tsets.login and two == tsets.password then 
        card.send(opp, port, 'RDAU', 'OK')
        if not isOnline(opp) then online[opp] = true end
        print('[LOGIN]: '..opp..' is logged in') 
      elseif 
        call == 'RDLG' then card.send(opp, port, 'RDAU', 'FAIL') 
        print('[LOGIN]: '..opp..' is failed to log in') 
        end
    end
  end
  
  if not isOnline(opp) then card.send(opp, port, 'RDNAUT') call='' end
  
  if call == 'RDISDIR' then 
    card.send(opp, port, 'RDISDIRA', rfs.isDirectory(one))
    if options.v then print('[VERBOSE]: '..opp..' called isDirectory("'..one..'")') end
  end
  
  if call == 'RDLMOD' then 
    card.send(opp, port, 'RDLMODA', rfs.lastModified(one))
    if options.v then print('[VERBOSE]: '..opp..' called lastModified("'..one..'")') end
  end
  
  if call == 'RDLIST' then
    lst, err = rfs.list(one)
    if err ~= nil then card.send(opp, port, 'RDLISTA', nil, err) end
    if lst ~=nil then
      card.send(opp, port, 'RDLISTA', seriz.serialize(lst))
    else card.send(opp, port, 'RDLISTA', nil, nil) end
    if options.v then print('[VERBOSE]: '..opp..' called list("'..one..'")') end
  end
  
  if call == 'RDTOTL' then 
    card.send(opp, port, 'RDTOTLA', rfs.spaceTotal())
    if options.v then print('[VERBOSE]: '..opp..' called spaceTotal()') end
  end
  
  if call == 'RDOPEN' then 
    fdes, err = rfs.open(one, two)
    if err ~= nil then card.send(opp, port, 'RDOPENA', nil, err)
    else
      ofdesc[tonumber(tostring(fdes))]= fdes
      card.send(opp, port, 'RDOPENA', tonumber(tostring(fdes)))
    end
    if options.v then print('[VERBOSE]: '..opp..' called open("'..one..'", "'..two..'")') end
  end
  
  if call == 'RDRM' then 
     card.send(opp, port, 'RDRMA', rfs.remove(one))
     if options.v then print('[VERBOSE]: '..opp..' called remove("'..one..'")') end
  end
  
  if call == 'RDRN' then 
     card.send(opp, port, 'RDRNA', rfs.rename(one, two))
     if options.v then print('[VERBOSE]: '..opp..' called rename("'..one..'", "'..two..'")') end
  end
  
  if call == 'RDREAD' then 
    if ofdesc[one] ~= nil then
      sended = 0
      remain = two
      if two > 8000 then bread = 8000 else bread = two end
      while sended < two do
        rdd = rfs.read(ofdesc[one], bread)
        if rdd == nil then rdd = '' end
        os.sleep(0,0001)
        card.send(opp, port, 'RDREADA', rdd)
        sended = sended + 8000
        remain = remain - 8000
        if remain < 8000 then bread = remain end
      end
    else card.send(opp, port, 'RDREADA', nil, 'bad file descriptor') end
    if options.v then print('[VERBOSE]: '..opp..' called read('..one..', "'..two..'")') end
  end
  
  if call == 'RDCLS' then 
    if ofdesc[one] ~= nil then
      card.send(opp, port, 'RDCLSA', rfs.close(ofdesc[one]))
      ofdesc[one] = nil
    else card.send(opp, port, 'RDCLSA', nil, 'bad file descriptor') end
    if options.v then print('[VERBOSE]: '..opp..' called close('..one..')') end
  end
  
  if call == 'RDGLAB' then 
    card.send(opp, port, 'RDGLABA', rfs.getLabel())
    if options.v then print('[VERBOSE]: '..opp..' called getLabel()') end
  end
  
  if call == 'RDSEEK' then 
    card.send(opp, port, 'RDSEEKA', rfs.seek(one, two, thr))
    if options.v then print('[VERBOSE]: '..opp..' called seek('..one..', "'..two..'", '..thr..'') end
  end
  
  if call == 'RDFSIZ' then 
    card.send(opp, port, 'RDFSIZA', rfs.size(one))
    if options.v then print('[VERBOSE]: '..opp..' called size("'..one..'")') end
  end
    
  if call == 'RDISRO' then 
    card.send(opp, port, 'RDISROA', rfs.isReadOnly())
    if options.v then print('[VERBOSE]: '..opp..' called isReadOnly()') end
  end
  
  if call == 'RDSLAB' then 
    card.send(opp, port, 'RDSLABA', rfs.setLabel(one))
    if options.v then print('[VERBOSE]: '..opp..' called setLabel("'..one..'")') end
  end
  
  if call == 'RDMKDR' then
    card.send(opp, port, 'RDMKDRA', rfs.makeDirectory(one))
    if options.v then print('[VERBOSE]: '..opp..' called makeDirectory("'..one..'")') end
  end
  
  if call == 'RDISEX' then 
    card.send(opp, port, 'RDISEXA', rfs.exists(one))
    if options.v then print('[VERBOSE]: '..opp..' called exists("'..one..'")') end
  end
  
  if call == 'RDFREE' then 
    card.send(opp, port, 'RDFREEA', rfs.spaceUsed())
    if options.v then print('[VERBOSE]: '..opp..' called spaceUsed()') end
  end
  
  if call == 'RDWRT' then
    oneb = one
    if ofdesc[one] ~= nil then
      fhand = ofdesc[one]
      card.send(opp, port, 'RDWRTA')
      readed = 0
      rdata = ''
      while readed < two do
      _,_,opp,_,_,call,one = event.pull("modem_message")
      if one ~= nil then rdata = rdata..one end
      readed = readed + 8000
      end
      stat, err = rfs.write(fhand, rdata)
      card.send(opp, port, 'RDWRTPA', stat, err)
    else card.send(opp, port, 'RDWRTA', nil, 'bad file descriptor') end
    if options.v then print('[VERBOSE]: '..opp..' called write('..oneb..', data len: '..#rdata..')') end
  end
  
  if call == 'RDBYE' then 
    online[opp]= nil
    card.send(opp, port, 'RDBYEA', 'user logged off')
    print('[CONNECT]: '..opp..' disconnected')
  end
  
end


