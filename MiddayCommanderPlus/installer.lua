--WebWyse 1.0 installer by Compys S&N Systems (2022). 
--Configuration zone.

--Name of the product being installed.
local PRODUCTNAME = 'Midday Commander Plus'

--Strings for small background window. nil for disabled. Max 4 lines.
local BACKWINTEXT = {'Midday Commander Plus', '', 'Not Copyright (C) 2015-2016 Zer0Galaxy, Neo, Totoro', '            2020-2022 Compys S&N Systems'}

--The text that will be shown in the console after a successful installation. nil for disabled.
local EXITNOTE = "Type \"mc\" to run it"

--License for product. nil to use LICENSEURL or disabled.
local LICENSE = [[For more information go to:
https://github.com/Bs0Dd/OpenCompSoft/blob/master/MiddayCommanderPlus/README.md

------------------------
                 
MIT License

Copyright (c) 2018 

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.]]

--URL for license to download from network. nil for disabled.
local LICENSEURL = nil

--Default installation path. nil for empty.
local INSTALLPATH = '/usr/bin/'

--Minimum space (in bytes) required for installation. nil for disable checking.
local MINSPACE = 23552

--Minimal requirements for installation. nil for disable checking.
local MINREQ = {
    CPU = 1, --Minimal CPU tier required for installation. nil for disable checking.
    VIDEO = 1, --Minimal videosystem tier required for installation. nil for disable checking
    RAM = 262144, --Minimum RAM size required for installation. nil for disable checking.
    COMPONENTS = nil --Components required for installation. nil for none.
}

--Colors for Tier 3 Videosystem.
local T3BACKCOL = 0xFFFFFF -- Color for the background.
local T3NORMALCOL = {0xFFFFFF, 0x006DFF} --Text and background colors for the windows.
local T3BUTTCOL = {0xFFFFFF, 0x5A5A5A} --Text and background colors for the buttons.
local T3FORMCOL = {0x000000, 0xE1E1E1} --Text and background colors for the forms (license view, path input).
local T3FSELCOL = {0xFFFFFF, 0x5A5A5A} --Text and background colors for selected item in the form.
local T3ERRCOL = {0xFFFFFF, 0xFF0000} --Text and background colors for the error windows.
local T3REQOKCOL = {0x00FF00, 0x006DFF} --Text and background colors for components that meets minimal requirements.
local T3REQERCOL = {0xFFFFFF, 0xFF0000} --Text and background colors for components that does not meet minimal requirements.
local T3PROGRBLK = 0xFFFFFF -- Color for the blank part of the progress bar.
local T3PROGRFIL = 0x00FF00 -- Color for the filled part of the progress bar.

--Colors for Tier 2 Videosystem.
local T2BACKCOL = 0xFFFFFF -- Color for the background.
local T2NORMALCOL = {0xFFFFFF, 0x006DFF} --Text and background colors for the windows.
local T2BUTTCOL = {0xFFFFFF, 0x3C3C3C} --Text and background colors for the buttons.
local T2FORMCOL = {0x000000, 0xE1E1E1} --Text and background colors for the forms (license view, path input).
local T2FSELCOL = {0xFFFFFF, 0x3C3C3C} --Text and background colors for selected item in the form.
local T2ERRCOL = {0xFFFFFF, 0xFF0000} --Text and background colors for the error windows.
local T2REQOKCOL = {0x00FF00, 0x006DFF} --Text and background colors for components that meets minimal requirements.
local T2REQERCOL = {0xFFFFFF, 0xFF0000} --Text and background colors for components that does not meet minimal requirements.
local T2PROGRBLK = 0xFFFFFF -- Color for the blank part of the progress bar.
local T2PROGRFIL = 0x00FF00 -- Color for the filled part of the progress bar.

--Colors for Tier 1 Videosystem. Not recommended to change.
local T1NORMALCOL = {0x000000, 0xFFFFFF} --Text and background colors for the windows.
local T1BUTTCOL = {0xFFFFFF, 0x000000} --Text and background colors for the buttons.
local T1FORMCOL = {0xFFFFFF, 0x000000} --Text and background colors for the forms (license view, path input).
local T1FSELCOL = {0x000000, 0xFFFFFF} --Text and background colors for selected item in the form.
local T1ERRCOL = {0x000000, 0xFFFFFF} --Text and background colors for the error windows.
local T1REQOKCOL = {0x000000, 0xFFFFFF} --Text and background colors for components that meets minimal requirements.
local T1REQERCOL = {0xFFFFFF, 0x000000} --Text and background colors for components that does not meet minimal requirements.
local T1PROGRBLK = 0x000000 -- Color for the blank part of the progress bar.
local T1PROGRFIL = 0xFFFFFF -- Color for the filled part of the progress bar.

--Basic files to download to your computer.
local FILES = {
    {
        url = "https://raw.githubusercontent.com/Bs0Dd/OpenCompSoft/master/MiddayCommanderPlus/mc.lua",
        path = "mc.lua",
        absolute = false
    },
    {
        url = "https://raw.githubusercontent.com/Bs0Dd/OpenCompSoft/master/MiddayCommanderPlus/Files/english.mcl",
        path = "/usr/misc/english.mcl",
        absolute = true
    },
    {
        url = "https://raw.githubusercontent.com/Bs0Dd/OpenCompSoft/master/MiddayCommanderPlus/Files/standard.mct",
        path = "/usr/misc/standard.mct",
        absolute = true
    }
}

--Additional components to download to your computer.
local ADDITIONAL = {
    {
        name = "Install Russian language",
        selected = true,
        size = 2822,
        files = {
                 {
                    url = "https://raw.githubusercontent.com/Bs0Dd/OpenCompSoft/master/MiddayCommanderPlus/Files/russian.mcl",
                    path = "/usr/misc/russian.mcl",
                    absolute = true
                 }
        }
    },
    {
        name = "Install additional themes",
        selected = true,
        size = 326,
        files = {
                 {
                    url = "https://raw.githubusercontent.com/Bs0Dd/OpenCompSoft/master/MiddayCommanderPlus/Files/redstone.mct",
                    path = "/usr/misc/redstone.mct",
                    absolute = true
                 },
                 {
                    url = "https://raw.githubusercontent.com/Bs0Dd/OpenCompSoft/master/MiddayCommanderPlus/Files/darkness.mct",
                    path = "/usr/misc/darkness.mct",
                    absolute = true
                 }
                }
    },
    {
        name = "Install Blyadian language",
        selected = false,
        size = 2780,
        files = {
                 {
                    url = "https://raw.githubusercontent.com/Bs0Dd/OpenCompSoft/master/MiddayCommanderPlus/Files/blyadian.mcl",
                    path = "/usr/misc/blyadian.mcl",
                    absolute = true
                 }
        }
    }
}

---------------------------------------------------------------------------------------------------------------

local a=require('component')local b=require('computer')local c=require('filesystem')local d=require('term')local e=require('event')local f=require('unicode')local g=f.len;local h=f.sub;local i=require('keyboard')local j=a.gpu;if not a.isAvailable('internet')then io.stderr:write("ERROR: Internet card is not found\n\n")return end;local k=a.internet;local l,m=j.maxResolution()j.setDepth(j.maxDepth())j.setResolution(l,m)local n,o=1,1;local p=1;local q,r;local s,t;local u,v,w=1,1,1;local x=INSTALLPATH or''local y,z,A,B;local C,D,E,F,G=true,true,true,true;local H,I=1,1;local J,K,L,M,N=0,0,0,0;if j.maxDepth()>1 then n,o=math.ceil((l-50)/2),math.ceil(m/2)-4 end;local O,P,Q,R,S;local T,U,V,W,X;if j.maxDepth()==8 then O=T3NORMALCOL;P=T3BUTTCOL;Q=T3FORMCOL;R=T3FSELCOL;S=T3ERRCOL;T=T3BACKCOL;U=T3REQOKCOL;V=T3REQERCOL;W=T3PROGRBLK;X=T3PROGRFIL elseif j.maxDepth()==4 then O=T2NORMALCOL;P=T2BUTTCOL;Q=T2FORMCOL;R=T2FSELCOL;S=T2ERRCOL;T=T2BACKCOL;U=T2REQOKCOL;V=T2REQERCOL;W=T2PROGRBLK;X=T2PROGRFIL else O=T1NORMALCOL;P=T1BUTTCOL;Q=T1FORMCOL;R=T1FSELCOL;S=T1ERRCOL;T=O[2]U=T1REQOKCOL;V=T1REQERCOL;W=T1PROGRBLK;X=T1PROGRFIL end;local function Y(Z)j.setForeground(Z[1])j.setBackground(Z[2])end;local function _(a0)local a1=0;for a2,a3 in ipairs(a0)do if g(a3)>a1 then a1=g(a3)end end;return a1 end;local function a4(a5)if a5:sub(-1)~="\n"then a5=a5 .."\n"end;return a5:gmatch("(.-)\n")end;local function a6(a7)local a8={"Kb","Mb","Gb"}if a7<1024 then return a7 .."b"end;local a9=0;while a7>=1024 and a9<#a8 do a9=a9+1;a7=a7/1024 end;return math.floor(a7*10)/10 ..a8[a9]end;local function aa(ab,ac,ad,a0,ae)Y(ae)j.set(ab,ac,string.rep(' ',ad+2))for af,a3 in ipairs(a0)do if g(a3)<ad then local ag,ah=(ad-g(a3))/2;if ag%1==0 then ah=ag else ag=math.ceil(ag)ah=ag-1 end;a3=string.rep(' ',ag)..a3 ..string.rep(' ',ah)end;j.set(ab,ac+af,' '..a3 ..' ')end;if j.maxDepth()==1 then return end;j.set(ab,ac+#a0+1,string.rep(' ',ad+2))Y({T,0x000000})j.fill(ab+ad+2,ac+1,1,#a0+1,' ')j.set(ab+2,ac+#a0+2,string.rep('▄',ad+1))end;local function ai()local aj=n+50;Y({T,0x000000})j.fill(aj,o+1,1,15,' ')j.set(n+2,o+16,string.rep('▄',49))end;local function ak()Y(O)j.fill(n,o,50,16,' ')j.fill(n,o,50,16,' ')j.set(n+2,o+13,string.rep('─',46))end;local function al(am)if BACKWINTEXT and j.maxDepth()>1 then if#BACKWINTEXT>4 then while#BACKWINTEXT>4 do table.remove(BACKWINTEXT)end end;local an=_(BACKWINTEXT)local ab,ac=math.ceil((l-an-2)/2),math.ceil(m/10)-1;aa(ab,ac,an,BACKWINTEXT,O)end;if not am then ai()end end;local function ao(ap,aq)table.insert(ap,'')table.insert(ap,'')j.setBackground(T)j.fill(1,1,l,m,' ')local an=_(ap)local ab,ac=math.ceil((l-an)/2),math.ceil(m/2)al(true)aa(ab,ac,an,ap,aq)return ab,ac,an end;local function ar(ap,aq)local ab,ac,an=ao(ap,aq)Y(P)local as=math.ceil(ab+an/2-3)j.set(as,ac+#ap,"   Ok   ")while true do local at,a2,au,av=e.pull()if at=="key_down"and au==13 or at=="touch"and av==ac+#ap and au>=as and au<=as+7 then j.setBackground(T)j.fill(1,1,l,m,' ')al()ak()q[p]()return end end end;local function aw(ap)local ab,ac=ao(ap,S)Y(P)j.set(ab+3,ac+#ap," (Y)es  ")j.set(ab+17,ac+#ap,"  (N)o  ")while true do local at,a2,au,av=e.pull()if at=="key_down"then if au==78 or au==110 then al()ak()q[p]()return true elseif au==89 or au==121 then return false end elseif at=="touch"then if av==ac+#ap and au>=ab+3 and au<=ab+10 then return false elseif av==ac+#ap and au>=ab+17 and au<=ab+24 then al()ak()q[p]()return true end end end end;local function ax(ay)if ay then if aw({" Are you sure you want to ","abort the installation?"})then return end end;Y({0xFFFFFF,0x000000})d.clear()print("WebWyse 1.0 - 2022 (c) Compys S&N Systems\n")if not ay and EXITNOTE then print(EXITNOTE.."\n")end;os.exit()end;local function az()j.set(n+6,o+1,"Welcome to the WebWyse 1.0 installer!")j.set(n+7,o+3,"This installer will help to install")j.set(n+25-g(PRODUCTNAME)/2,o+4,PRODUCTNAME)j.set(n+17,o+5,"on your computer.")j.set(n+6,o+8,"Follow WebWyse instructions to install")j.set(n+12,o+9,"and configure the software.")j.set(n+10,o+10,"Press \"Next →\" (→) to continue")j.set(n+11,o+11,"or \"Cancel\" (ALT-X) to exit.")Y(P)j.set(n+3,o+14," Cancel ")j.set(n+39,o+14," Next → ")end;local function aA()while true do local at,a2,au,av=e.pull()if at=="key_down"then if i.isAltDown()and(au==88 or au==120)then ax(true)elseif av==205 then return end elseif at=="touch"then if av==o+14 and au>=n+3 and au<=n+10 then ax(true)elseif av==o+14 and au>=n+39 and au<=n+46 then return end end end end;local function aB()j.fill(n+3,o+3,44,10,' ')for aC=0,9 do j.set(n+3,o+aC+3,s[v+aC]and h(s[v+aC],u,u+43)or'')end end;local function aD()Y(Q)s={"Loading from internet..."}aB()local aE="Failed to get license text: "local aF,aG=pcall(k.request,LICENSEURL)if not aF then LICENSE=aE..aG.."."return end;if not aG then LICENSE=aE.."invalid URL-address."return end;local aH,aI=aG.finishConnect()local aJ=b.uptime()while aH==false do aH,aI=aG.finishConnect()if b.uptime()>aJ+40 then break end end;if aH==nil then LICENSE=aE..(aI==LICENSEURL and"can't get file."or aI..".")return end;local aK,aL=aG.response()local aJ=b.uptime()while aK==nil do aK,aL=aG.response()if b.uptime()>aJ+40 then break end end;if aK==nil then LICENSE=aE.."timeout expired."return elseif aK~=200 then LICENSE=aE.."received code "..math.floor(aK).." ("..aL..")."return end;LICENSE=""while true do local aM,aI=aG.read(math.huge)if aM then LICENSE=LICENSE..aM else aG:close()if aI then LICENSE=aE..aI.."."else return end end end end;local function aN()j.set(n+9,o+1,"Do you agree with this license?")Y(P)j.set(n+3,o+14,"  (N)o  ")j.set(n+30,o+14," (B)ack ")j.set(n+39,o+14," (Y)es  ")if not s then if not LICENSE and LICENSEURL then aD()end;s={}for aO in a4(LICENSE)do table.insert(s,aO)end;w=_(s)end;t=#s>9 and#s-9 or#s;Y(Q)aB()end;local function aP()while true do local at,a2,au,av,aQ=e.pull()if at=="key_down"then if au==78 or au==110 then ax(true)elseif au==66 or au==98 then p=p-2;return elseif au==89 or au==121 then return elseif av==200 then v=v-1<1 and 1 or v-1;aB()elseif av==208 then v=v+1>t and t or v+1;aB()elseif av==203 then u=u-1<1 and 1 or u-1;aB()elseif av==205 then u=u+1>w-43 and w-43 or u+1;aB()elseif av==199 then u=1;aB()elseif av==207 then u=w-43;aB()elseif av==201 then v=v-10<1 and 1 or v-10;aB()elseif av==209 then v=v+10>t and t or v+10;aB()end elseif at=="touch"then if av==o+14 and au>=n+3 and au<=n+10 then ax(true)elseif av==o+14 and au>=n+30 and au<=n+37 then p=p-2;return elseif av==o+14 and au>=n+39 and au<=n+46 then return end elseif at=="scroll"then v=v-aQ>t and t or v-aQ<1 and 1 or v-aQ;aB()end end end;local function aR(aS,aT,aU,aV)local ap={}if aS==nil or type(aS)=='table'and#aS==0 then ap[1]="Required: Not defined"elseif aU==3 then local aW="Required: "local aX="You have: "for a2,aY in pairs(aS)do if#aW+#aY>49 then table.insert(ap,aW:sub(1,-2))aW=""end;aW=aW..aY..", "end;table.insert(ap,aW:sub(1,-3))for a2,aY in pairs(aT)do if#aX+#aY>49 then table.insert(ap,aX:sub(1,-2))aX=""end;aX=aX..aY..", "end;table.insert(ap,#aT==0 and aX.."<none>"or aX:sub(1,-3))elseif aU==2 then ap[1]="Required: "..a6(aS)ap[2]="You have: "..a6(aT)else ap[1]="Required: Tier "..aS;ap[2]="You have: Tier "..aT end;ar(ap,aV and O or S)end;local function aZ()G=true;if MINREQ.CPU and type(MINREQ.CPU)=='number'then local a_=b.getDeviceInfo()for a2,b0 in pairs(a_)do if b0.description=="CPU"or b0.description=="APU"then y=tonumber(b0.product:match('%d'))break end end;C=y>=MINREQ.CPU;if not C then G=false end end;if MINREQ.VIDEO and type(MINREQ.VIDEO)=='number'then local b1=j.maxDepth()z=b1==8 and 3 or b1==4 and 2 or 1;D=z>=MINREQ.VIDEO;if not D then G=false end end;if MINREQ.RAM and type(MINREQ.RAM)=='number'then A=b.totalMemory()E=A>=MINREQ.RAM;if not E then G=false end end;if MINREQ.COMPONENTS and type(MINREQ.COMPONENTS)=='table'then B={}for a2,b2 in pairs(MINREQ.COMPONENTS)do if a.isAvailable(b2)then table.insert(B,b2)end end;F=#B==#MINREQ.COMPONENTS;if not F then G=false end end;if G then j.set(n+12,o+1,"Your computer fully meets")else j.set(n+11,o+1,"Your computer does not meet")j.set(n+5,o+3,"Select the desired section for details.")end;j.set(n+12,o+2,"the minimum requirements.")j.set(n+10,o+5,"(P)rocessor   :")j.set(n+10,o+7,"(M)emory      :")j.set(n+10,o+9,"(V)ideosystem :")j.set(n+10,o+11,"(С)omponents  :")local b3,aC={C,E,D,F},5;for a2,b0 in pairs(b3)do Y(b0 and U or V)j.set(n+26,o+aC,b0 and"Meets"or"Does not meet")aC=aC+2 end;Y(P)j.set(n+3,o+14," Cancel ")j.set(n+30,o+14," ← Back ")j.set(n+39,o+14," Next → ")end;local function b4()while true do local at,a2,au,av,aQ=e.pull()if at=="key_down"then if i.isAltDown()and(au==88 or au==120)then ax(true)elseif av==203 then p=p-2;return elseif av==205 or au==13 then if G then return elseif not aw({"Are you sure you want to","install this software?","","It may not work correctly!"})then al()ak()return end elseif au==112 or au==80 then aR(MINREQ.CPU,y,1,C)elseif au==109 or au==77 then aR(MINREQ.RAM,A,2,E)elseif au==118 or au==86 then aR(MINREQ.VIDEO,z,1,D)elseif au==99 or au==67 then aR(MINREQ.COMPONENTS,B,3,F)end elseif at=="touch"then if av==o+14 and au>=n+3 and au<=n+10 then ax(true)elseif av==o+14 and au>=n+30 and au<=n+37 then p=p-2;return elseif av==o+14 and au>=n+39 and au<=n+46 then if G then return elseif not aw({"Are you sure you want to","install this software?","","It may not work correctly!"})then al()ak()return end elseif av==o+5 and au>=n+10 and au<=n+38 then aR(MINREQ.CPU,y,1,C)elseif av==o+7 and au>=n+10 and au<=n+38 then aR(MINREQ.RAM,A,2,E)elseif av==o+9 and au>=n+10 and au<=n+38 then aR(MINREQ.VIDEO,z,1,D)elseif av==o+11 and au>=n+10 and au<=n+38 then aR(MINREQ.COMPONENTS,B,3,F)end end end end;local function b5()j.fill(n+3,o+3,44,10,' ')for aC=0,#ADDITIONAL-I<9 and#ADDITIONAL-I or 9 do if aC+1==H then Y(R)j.fill(n+3,o+aC+3,44,1," ")end;j.set(n+6,o+aC+3,g(ADDITIONAL[I+aC].name)>39 and h(ADDITIONAL[I+aC].name,0,39)..".."or ADDITIONAL[I+aC].name)if ADDITIONAL[I+aC].selected then if j.maxDepth()>1 then j.setForeground(0x00FF00)end;j.set(n+4,o+aC+3,"√")else if j.maxDepth()>1 then j.setForeground(0xFF0000)end;j.set(n+4,o+aC+3,"╳")end;if aC+1==H then j.setBackground(Q[2])end;j.setForeground(Q[1])end end;local function b6()if I>1 then I=I-1;b5()else if H>1 then H=H-1;b5()end end end;local function b7()local b8=#ADDITIONAL<10 and#ADDITIONAL or 10;if H+1>b8 then if I+9<#ADDITIONAL then I=I+1;b5()end else H=H+1;b5()end end;local function b9()j.set(n+6,o+1,"You can install additional components:")Y(P)j.set(n+3,o+14," Cancel ")j.set(n+30,o+14," ← Back ")j.set(n+39,o+14," Next → ")Y(Q)b5()end;local function ba()while true do local at,a2,au,av,aQ=e.pull()if at=="key_down"then if i.isAltDown()and(au==88 or au==120)then ax(true)elseif av==203 then p=p-2;return elseif av==205 then return elseif av==200 then b6()elseif av==208 then b7()elseif av==57 or av==28 then ADDITIONAL[H+I-1].selected=not ADDITIONAL[H+I-1].selected;b5()end elseif at=="touch"then if av==o+14 and au>=n+3 and au<=n+10 then ax(true)elseif av==o+14 and au>=n+30 and au<=n+37 then p=p-2;return elseif av==o+14 and au>=n+39 and au<=n+46 then return elseif av>=o+3 and av<=o+12 and au>=n+3 and au<=n+46 then local bb=av-o-3+I;if#ADDITIONAL>=bb then H=bb-I+1;ADDITIONAL[bb].selected=not ADDITIONAL[bb].selected;b5()end end elseif at=="scroll"then if aQ==1 then b6()else b7()end end end end;local function bc()if x==""then ar({"Installation path cannot be empty!","Please enter the path."},S)return false end;if not c.exists(x)then local bd,be=c.makeDirectory(x)if not bd then ar({"Failed to make directory:",be..".","Please check if path is correct and try again."},S)return false end;return true end;local bf=c.get(x)if bf.isReadOnly()then ar({"This disk is write protected!","Please unprotect the disk and try again."},S)return false end;if MINSPACE then local bg=bf.spaceTotal()-bf.spaceUsed()if bg<MINSPACE then ar({"Not enough space for installation!","Please free at least "..a6(MINSPACE-bg),"of space and try again."},S)return false end end;return true end;local function bh()local bi;if g(x)>43 then bi='..'..h(x,-41)else bi=x end;d.setCursor(n+3+g(bi),o+9)j.fill(n+3,o+9,44,1,' ')j.set(n+3,o+9,bi)end;local function bj()j.set(n+4,o+1,"Select a folder to install program files.")j.set(n+3,o+4,"Be aware that some files (such as libraries)")j.set(n+8,o+5,"may be installed in system folders.")j.set(n+3,o+8,"Install to:")local bk=MINSPACE or 0;if ADDITIONAL and#ADDITIONAL>0 then for a2,b0 in pairs(ADDITIONAL)do if b0.selected then bk=bk+b0.size end end end;if bk>0 then j.set(n+3,o+11,"Space required: "..a6(bk))end;Y(P)j.set(n+3,o+14," Cancel ")j.set(n+30,o+14," ← Back ")j.set(n+39,o+14," Next → ")Y(Q)bh()end;local function bl()while true do local at,a2,au,av,aQ=d.pull()if at=="key_down"then if i.isAltDown()and(au==88 or au==120)then ax(true)elseif av==203 then p=p-2;return elseif av==205 or au==13 then if bc()then return end elseif au==8 then x=h(x,1,-2)bh()elseif au==0 or au==9 or au==127 then else x=x..f.char(au)bh()end elseif at=="touch"then if av==o+14 and au>=n+3 and au<=n+10 then ax(true)elseif av==o+14 and au>=n+30 and au<=n+37 then p=p-2;return elseif av==o+14 and au>=n+39 and au<=n+46 then if bc()then return end end elseif eve=="clipboard"then x=x..au;bh()end end end;local function bm()j.set(n+12,o+1,"WebWyse is ready to install")j.set(n+25-g(PRODUCTNAME)/2,o+2,PRODUCTNAME)j.set(n+17,o+3,"to your computer.")j.set(n+9,o+6,"Click \"Go\" to begin installation.")j.set(n+13,o+9,"Or click \"Back\" to change")j.set(n+15,o+10,"installation options.")Y(P)j.set(n+3,o+14," Cancel ")j.set(n+30,o+14," ← Back ")j.set(n+39,o+14,"   Go   ")end;local function bn()while true do local at,a2,au,av,aQ=e.pull()if at=="key_down"then if i.isAltDown()and(au==88 or au==120)then ax(true)elseif av==203 then p=p-2;return elseif au==13 then return end elseif at=="touch"then if av==o+14 and au>=n+3 and au<=n+10 then ax(true)elseif av==o+14 and au>=n+30 and au<=n+37 then p=p-2;return elseif av==o+14 and au>=n+39 and au<=n+46 then return end end end end;local function bo()j.set(n+2,o+5,string.rep(" ",46))j.set(n+2,o+7,string.rep(" ",46))j.setForeground(O[1])local bp="Downloading file: "..N;if g(bp)>46 then bp=bp:sub(1,44)..".."end;j.set(n+25-g(bp)/2,o+5,bp)local bq="Downloaded data: "..a6(M).."/"..a6(L)j.set(n+25-g(bq)/2,o+7,bq)local br="Downloaded files: "..K.."/"..J;j.set(n+25-g(br)/2,o+11,br)j.setForeground(W)j.set(n+4,o+6,string.rep("━",42))j.set(n+4,o+10,string.rep("━",42))j.setForeground(X)if L>0 then local bs=math.ceil(42*M/L)j.set(n+4,o+6,string.rep("━",bs))end;local bt=math.ceil(42*K/J)j.set(n+4,o+10,string.rep("━",bt))end;local function bu(bv,ap)ar({"Failed to "..bv..":",ap..".","The installer will close."},S)end;local function bw()j.set(n+9,o+1,"WebWyse downloads the necessary")j.set(n+13,o+2,"files to your computer.")if ADDITIONAL then for a2,b0 in pairs(ADDITIONAL)do if b0.selected then for a2,bx in pairs(b0.files)do table.insert(FILES,bx)end end end end;J=#FILES end;local function by()for a2,bz in pairs(FILES)do N=c.name(bz.path)bo()local bA=bz.absolute and bz.path or c.concat(x,bz.path)if not c.exists(c.path(bA))then local bB,aI=c.makeDirectory(c.path(bA))if not bB then bu("create directory",aI)EXITNOTE=nil;ax()end end;local bC,aI=io.open(bA,"w")if not bC then bu("create file",aI)EXITNOTE=nil;ax()end;local aF,aG=pcall(k.request,bz.url)if not aF then bu("make internet request",aG)EXITNOTE=nil;ax()end;if not aG then bu("make internet request","invalid URL-address")EXITNOTE=nil;ax()end;local aH,aI=aG.finishConnect()local aJ=b.uptime()while aH==false do aH,aI=aG.finishConnect()if b.uptime()>aJ+40 then break end end;if aH==nil then bu("connect",aI==bz.url and"can't get file"or aI)EXITNOTE=nil;ax()end;local aK,aL,bD=aG.response()local aJ=b.uptime()while aK==nil do aK,aL,bD=aG.response()if b.uptime()>aJ+40 then break end end;if aK==nil then bu("connect","timeout expired")EXITNOTE=nil;ax()elseif aK~=200 then bu("connect","received code "..math.floor(aK).." ("..aL..")")EXITNOTE=nil;ax()end;if bD and bD["Content-Length"]then L=tonumber(bD["Content-Length"][1])else L=0 end;M=0;bo()while true do local aM,aI=aG.read(math.huge)if aM then M=M+#aM;bC:write(aM)bo()else aG:close()if aI then bu("get file",aI)EXITNOTE=nil;ax()else bC:close()break end end end;K=K+1;bo()end end;local function bE()j.set(n+25-g(PRODUCTNAME)/2,o+4,PRODUCTNAME)j.set(n+10,o+5,"has been successfully installed")j.set(n+17,o+6,"on your computer.")j.set(n+9,o+9,"Click \"Ok\" to exit the installer.")Y(P)j.set(n+39,o+14,"   Ok   ")end;local function bF()while true do local at,a2,au,av,aQ=e.pull()if at=="key_down"and au==13 or at=="touch"and av==o+14 and au>=n+39 and au<=n+46 then return end end end;j.setBackground(T)j.fill(1,1,l,m,' ')al()q={az}r={aA}if LICENSE or LICENSEURL then table.insert(q,aN)table.insert(r,aP)end;if MINREQ and(MINREQ.CPU or MINREQ.VIDEO or MINREQ.RAM or MINREQ.COMPONENTS)then table.insert(q,aZ)table.insert(r,b4)end;if ADDITIONAL and#ADDITIONAL>0 then table.insert(q,b9)table.insert(r,ba)end;table.insert(q,bj)table.insert(r,bl)table.insert(q,bm)table.insert(r,bn)table.insert(q,bw)table.insert(r,by)table.insert(q,bE)table.insert(r,bF)while p<=#q do ak()q[p]()r[p]()p=p+1 end;ax()
