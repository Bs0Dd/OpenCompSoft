local component = require('component')
local shell = require('shell')
local filesystem = require('filesystem')

print('SecuCODEX EEPROM Creator')
print('Read more on: https://github.com/Bs0Dd/OpenCompSoft/blob/master/SecuCODEX/README.md')
print()

local ans, lb = ''
while ans:lower() ~= 'm' and ans:lower() ~= 'c' do
io.write( 'What type of system you wants to use? [M]ono/[C]olor: ')
ans = io.read()
end

print('Downloading EEPROM image...')
if ans:lower() == 'm' then
	shell.execute('wget -q https://github.com/Bs0Dd/OpenCompSoft/raw/master/SecuCODEX/Mono/bios.lua /sctemp.lua')
	lb = 'SecuCODEX Mono'
elseif ans:lower() == 'c' then
	shell.execute('wget -q https://github.com/Bs0Dd/OpenCompSoft/raw/master/SecuCODEX/Color/bios.lua /sctemp.lua')
	lb = 'SecuCODEX Color'
end
print('OK!\n')

local file = assert(io.open('/sctemp.lua', "rb"))
local bios = file:read("*a")
file:close()
filesystem.remove('/sctemp.lua')
print("Insert the EEPROM you would like to flash.")
print("When ready to write, type `y` to confirm.")
repeat
  local response = io.read()
until response and response:lower():sub(1, 1) == "y"
print("Beginning to flash EEPROM.")
local eeprom = component.eeprom
print("Flashing EEPROM " .. eeprom.address .. ".")
print("Please do NOT power down or restart your computer during this operation!")
eeprom.set(bios)
eeprom.setLabel(lb)
print("All done! You can remove the EEPROM and re-insert the previous one now.")
print("Remember to switch the access system processor to Lua 5.3 mode!")