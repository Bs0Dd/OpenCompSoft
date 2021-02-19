--[[NyaDraw Graphic Engine v1.01 for OpenOS (Minified version)
	Standalone "Screen.lua" port from MineOS
	More info on: https://github.com/Bs0Dd/OpenCompSoft/blob/master/NyaDraw/README.md
	2015-2021 - ECS: https://github.com/IgorTimofeev
	2021 - Bs0Dd: https://github.com/Bs0Dd
]]
local a=require("unicode")local b=require("computer")local c,d;local e,f,g,h,i,j;local k,l,m,n;local o,p,q,r,s,t,u,v,w,x;local y,z,A,B=math.ceil,math.floor,math.modf,math.abs;local C,D=table.insert,table.concat;local E;local F,G=a.len,a.sub;local function H(I,J)return c*(J-1)+I end;local function K()return e,f,g end;local function L()return h,i,j end;local function M(N,O,P,Q)k,m,l,n=N,O,P,Q end;local function R()k,m,l,n=1,1,c,d end;local function S()return k,m,l,n end;local T={0x000000,0x000040,0x000080,0x0000BF,0x0000FF,0x002400,0x002440,0x002480,0x0024BF,0x0024FF,0x004900,0x004940,0x004980,0x0049BF,0x0049FF,0x006D00,0x006D40,0x006D80,0x006DBF,0x006DFF,0x009200,0x009240,0x009280,0x0092BF,0x0092FF,0x00B600,0x00B640,0x00B680,0x00B6BF,0x00B6FF,0x00DB00,0x00DB40,0x00DB80,0x00DBBF,0x00DBFF,0x00FF00,0x00FF40,0x00FF80,0x00FFBF,0x00FFFF,0x0F0F0F,0x1E1E1E,0x2D2D2D,0x330000,0x330040,0x330080,0x3300BF,0x3300FF,0x332400,0x332440,0x332480,0x3324BF,0x3324FF,0x334900,0x334940,0x334980,0x3349BF,0x3349FF,0x336D00,0x336D40,0x336D80,0x336DBF,0x336DFF,0x339200,0x339240,0x339280,0x3392BF,0x3392FF,0x33B600,0x33B640,0x33B680,0x33B6BF,0x33B6FF,0x33DB00,0x33DB40,0x33DB80,0x33DBBF,0x33DBFF,0x33FF00,0x33FF40,0x33FF80,0x33FFBF,0x33FFFF,0x3C3C3C,0x4B4B4B,0x5A5A5A,0x660000,0x660040,0x660080,0x6600BF,0x6600FF,0x662400,0x662440,0x662480,0x6624BF,0x6624FF,0x664900,0x664940,0x664980,0x6649BF,0x6649FF,0x666D00,0x666D40,0x666D80,0x666DBF,0x666DFF,0x669200,0x669240,0x669280,0x6692BF,0x6692FF,0x66B600,0x66B640,0x66B680,0x66B6BF,0x66B6FF,0x66DB00,0x66DB40,0x66DB80,0x66DBBF,0x66DBFF,0x66FF00,0x66FF40,0x66FF80,0x66FFBF,0x66FFFF,0x696969,0x787878,0x878787,0x969696,0x990000,0x990040,0x990080,0x9900BF,0x9900FF,0x992400,0x992440,0x992480,0x9924BF,0x9924FF,0x994900,0x994940,0x994980,0x9949BF,0x9949FF,0x996D00,0x996D40,0x996D80,0x996DBF,0x996DFF,0x999200,0x999240,0x999280,0x9992BF,0x9992FF,0x99B600,0x99B640,0x99B680,0x99B6BF,0x99B6FF,0x99DB00,0x99DB40,0x99DB80,0x99DBBF,0x99DBFF,0x99FF00,0x99FF40,0x99FF80,0x99FFBF,0x99FFFF,0xA5A5A5,0xB4B4B4,0xC3C3C3,0xCC0000,0xCC0040,0xCC0080,0xCC00BF,0xCC00FF,0xCC2400,0xCC2440,0xCC2480,0xCC24BF,0xCC24FF,0xCC4900,0xCC4940,0xCC4980,0xCC49BF,0xCC49FF,0xCC6D00,0xCC6D40,0xCC6D80,0xCC6DBF,0xCC6DFF,0xCC9200,0xCC9240,0xCC9280,0xCC92BF,0xCC92FF,0xCCB600,0xCCB640,0xCCB680,0xCCB6BF,0xCCB6FF,0xCCDB00,0xCCDB40,0xCCDB80,0xCCDBBF,0xCCDBFF,0xCCFF00,0xCCFF40,0xCCFF80,0xCCFFBF,0xCCFFFF,0xD2D2D2,0xE1E1E1,0xF0F0F0,0xFF0000,0xFF0040,0xFF0080,0xFF00BF,0xFF00FF,0xFF2400,0xFF2440,0xFF2480,0xFF24BF,0xFF24FF,0xFF4900,0xFF4940,0xFF4980,0xFF49BF,0xFF49FF,0xFF6D00,0xFF6D40,0xFF6D80,0xFF6DBF,0xFF6DFF,0xFF9200,0xFF9240,0xFF9280,0xFF92BF,0xFF92FF,0xFFB600,0xFFB640,0xFFB680,0xFFB6BF,0xFFB6FF,0xFFDB00,0xFFDB40,0xFFDB80,0xFFDBBF,0xFFDBFF,0xFFFF00,0xFFFF40,0xFFFF80,0xFFFFBF,0xFFFFFF}local function U(V)return T[V+1]end;if b.getArchitecture and b.getArchitecture()=="Lua 5.3"then E=load([[return function(color1, color2, transparency) local invertedTransparency = 1 - transparency return((color2 >> 16) * invertedTransparency + (color1 >> 16) * transparency) // 1 << 16 |((color2 >> 8 & 0xFF) * invertedTransparency + (color1 >> 8 & 0xFF) * transparency) // 1 << 8 |((color2 & 0xFF) * invertedTransparency + (color1 & 0xFF) * transparency) // 1 end]])()else E=function(W,X,Y)local Z=1-Y;local _,a0=W/65536,X/65536;local a1,a2=(W-_*65536)/256,(X-a0*65536)/256;_,a0,a1,a2=_-_%1,a0-a0%1,a1-a1%1,a2-a2%1;local a3,a4,a5=a0*Z+_*Y,a2*Z+a1*Y,(X-a0*65536-a2*256)*Z+(W-_*65536-a1*256)*Y;return(a3-a3%1)*65536+(a4-a4%1)*256+a5-a5%1 end end;local a6,a7,a8,a9;local function aa(ab,ac,...)local ad=ab;local ae=table.pack(...)for af=1,ae.n do ad=ac(ad,ae[af])end;return ad end;if b.getArchitecture and b.getArchitecture()=="Lua 5.3"then a6,a7,a8,a9=load([[local fold = ... return function(...) return fold(0, function(a, b) return a | b end, ...) end, function(...) return fold(0xFFFFFFFF, function(a, b) return a & b end, ...) end, function(x, disp) return (x << disp) & 0xFFFFFFFF end, function(x, disp) return (x >> disp) & 0xFFFFFFFF end]])(aa)else a6,a7,a8,a9=bit32.bor,bit32.band,bit32.lshift,bit32.rshift end;local function ag(ah)local ai={string.byte(ah:read(1))}local aj=0;for af=1,7 do if a7(a9(ai[1],8-af),0x1)==0x0 then aj=af;break end end;for af=1,aj-2 do table.insert(ai,string.byte(ah:read(1)))end;return string.char(table.unpack(ai))end;local function ak(ah,al)local am,ad={string.byte(ah:read(al)or"\x00",1,8)},0;for af=1,#am do ad=a6(a8(ad,8),am[af])end;return ad end;local function an(ao,I,J,ap,aq,ar,as)local at=4*(ao[1]*(J-1)+I)-1;ao[at],ao[at+1],ao[at+2],ao[at+3]=ap,aq,ar,as;return ao end;local au={}au[5]=function(ah,ao)ao[1]=ak(ah,2)ao[2]=ak(ah,2)for af=1,image.getWidth(ao)*image.getHeight(ao)do table.insert(ao,U(string.byte(ah:read(1))))table.insert(ao,U(string.byte(ah:read(1))))table.insert(ao,string.byte(ah:read(1))/255)table.insert(ao,ag(ah))end end;au[6]=function(ah,ao)ao[1]=string.byte(ah:read(1))ao[2]=string.byte(ah:read(1))local av,aw,ax,ay,az;local aA,aB,aC,aD,aE,aF;aA=string.byte(ah:read(1))for ar=1,aA do av=string.byte(ah:read(1))/255;aB=ak(ah,2)for as=1,aB do aw=ag(ah)aC=string.byte(ah:read(1))for ap=1,aC do ax=U(string.byte(ah:read(1)))aD=string.byte(ah:read(1))for aq=1,aD do ay=U(string.byte(ah:read(1)))aE=string.byte(ah:read(1))for J=1,aE do az=string.byte(ah:read(1))aF=string.byte(ah:read(1))for I=1,aF do an(ao,string.byte(ah:read(1)),az,ax,ay,av,aw)end end end end end end end;local function aG(aH)local ah,aI=io.open(aH,"rb")if ah then local aJ=ah:read(4)if aJ=="OCIF"then local aK=string.byte(ah:read(1))if au[aK]then local ao={}local ad,aI=xpcall(au[aK],debug.traceback,ah,ao)ah:close()if ad then return ao else return false,"Failed to load OCIF image: "..tostring(aI)end else ah:close()return false,"Failed to load OCIF image: encoding method \""..tostring(aK).."\" is not supported"end else ah:close()return false,"Failed to load OCIF image: binary signature \""..tostring(aJ).."\" is not valid"end else return false,"Failed to open file \""..tostring(aH).."\" for reading: "..tostring(aI)end end;local function aL(aM,aN)if not aM or not aN then aM,aN=p()end;e,f,g,h,i,j={},{},{},{},{},{}c=aM;d=aN;R()for J=1,d do for I=1,c do C(e,0x010101)C(f,0xFEFEFE)C(g," ")C(h,0x010101)C(i,0xFEFEFE)C(j," ")end end end;local function aO(aM,aN)q(aM,aN)aL(aM,aN)end;local function aP()return c,d end;local function aQ()return c end;local function aR()return d end;local function aS(aT,aU)local aV,aI=o.bind(aT,aU)if aV then if aU then aO(o.maxResolution())else aO(c,d)end else return aV,aI end end;local function aW()return o end;local function aX()v=o.get;p=o.getResolution;r=o.getBackground;s=o.getForeground;w=o.set;q=o.setResolution;t=o.setBackground;u=o.setForeground;x=o.fill end;local function aY(aZ)o=aZ;aX()aL()end;local function a_(b0)if not b0 or b0>1 then b0=1 elseif b0<0.1 then b0=0.1 end;local b1,b2=component.proxy(o.getScreen()).getAspectRatio()local b3,b4=o.maxResolution()local b5=2*(16*b1-4.5)/(16*b2-4.5)local aN=b0*math.min(b3/b5,b3,math.sqrt(b3*b4/b5))return math.floor(aN*b5),math.floor(aN)end;local function b6(at,ap,aq,as)h[at],i[at],j[at]=ap,aq,as end;local function b7(at)return h[at],i[at],j[at]end;local function b8(I,J)if I>=1 and J>=1 and I<=c and J<=d then local at=c*(J-1)+I;return h[at],i[at],j[at]else return 0x000000,0x000000," "end end;local function b9(I,J,ap,aq,as)if I>=k and J>=m and I<=l and J<=n then local at=c*(J-1)+I;h[at],i[at],j[at]=ap,aq,as end end;local function ba(I,J,aM,aN,ap,aq,as,Y)local at,bb=c*(J-1)+I,c-aM;for bc=J,J+aN-1 do if bc>=m and bc<=n then for af=I,I+aM-1 do if af>=k and af<=l then if Y then h[at],i[at]=E(h[at],ap,Y),E(i[at],ap,Y)else h[at],i[at],j[at]=ap,aq,as end end;at=at+1 end;at=at+bb else at=at+c end end end;local function bd(be,Y)ba(1,1,c,d,be or 0x0,0x000000," ",Y)end;local function bf(I,J,aM,aN)local bg,at={aM,aN}for bc=J,J+aN-1 do for af=I,I+aM-1 do if af>=1 and bc>=1 and af<=c and bc<=d then at=c*(bc-1)+af;C(bg,h[at])C(bg,i[at])C(bg,j[at])else C(bg,0x0)C(bg,0x0)C(bg," ")end end end;return bg end;local function bh(bi,bj,ao)local bk=ao[1]local bl,bm,bn=c*(bj-1)+bi,3,c-bk;for J=bj,bj+ao[2]-1 do if J>=m and J<=n then for I=bi,bi+bk-1 do if I>=k and I<=l then h[bl]=ao[bm]i[bl]=ao[bm+1]j[bl]=ao[bm+2]end;bl,bm=bl+1,bm+3 end;bl=bl+bn else bl,bm=bl+c,bm+bk*3 end end end;local function bo(N,O,P,Q,bp)local bq,br,bs,bt,bu,bv,bw=N,P,O,Q,false,B(P-N),B(Q-O)if bv<bw then bq,br,bs,bt,bu,bv,bw=O,Q,N,P,true,bw,bv end;if bs>bt then bs,bt=bt,bs;bq,br=br,bq end;local bx,by,bz=bs,1,bv/bw;local bA=bz;for bB=bq,br,bq<br and 1 or-1 do if bu then bp(bx,bB)else bp(bB,bx)end;by=by+1;if by>bA then bx,bA=bx+1,bA+bz end end end;local function bC(bD,bE,bF,bG,bp)local function bH(bI,bJ)bp(bD+bI,bE+bJ)bp(bD-bI,bE+bJ)bp(bD-bI,bE-bJ)bp(bD+bI,bE-bJ)end;local I,J,bK,bL,bM,bN,bO=bF,0,bG*bG*(1-2*bF),bF*bF,0,2*bF*bF,2*bG*bG;local bP,bQ=bO*bF,0;while bP>=bQ do bH(I,J)J,bQ,bM=J+1,bQ+bN,bM+bL;bL=bL+bN;if 2*bM+bK>0 then I,bP,bM=I-1,bP-bO,bM+bK;bK=bK+bO end end;I,J,bK,bL,bM,bP,bQ=0,bG,bG*bG,bF*bF*(1-2*bG),0,0,bN*bG;while bP<=bQ do bH(I,J)I,bP,bM=I+1,bP+bO,bM+bK;bK=bK+bO;if 2*bM+bL>0 then J,bQ,bM=J-1,bQ-bN,bM+bL;bL=bL+bN end end end;local function bR(N,O,P,Q,ap,aq,as)bo(N,O,P,Q,function(I,J)b9(I,J,ap,aq,as)end)end;local function bS(bD,bE,bF,bG,ap,aq,as)bC(bD,bE,bF,bG,function(I,J)b9(I,J,ap,aq,as)end)end;local function bT(I,J,bU,bV,Y)if J>=m and J<=n then local bW,bl=1,c*(J-1)+I;for bW=1,F(bV)do if I>=k and I<=l then if Y then i[bl]=E(h[bl],bU,Y)else i[bl]=bU end;j[bl]=G(bV,bW,bW)end;I,bl=I+1,bl+1 end end end;local function bX(bi,bj,ao,bY)local bl,bm,bk,ap,aq,ar,as=c*(bj-1)+bi,3,ao[1]local bn=c-bk;for J=bj,bj+ao[2]-1 do if J>=m and J<=n then for I=bi,bi+bk-1 do if I>=k and I<=l then ar,as=ao[bm+2],ao[bm+3]if ar==0 then h[bl],i[bl]=ao[bm],ao[bm+1]elseif ar>0 and ar<1 then h[bl]=E(h[bl],ao[bm],ar)if bY then i[bl]=E(i[bl],ao[bm+1],ar)else i[bl]=ao[bm+1]end elseif as~=" "then i[bl]=ao[bm+1]end;j[bl]=as end;bl,bm=bl+1,bm+4 end;bl=bl+bn else bl,bm=bl+c,bm+bk*4 end end end;local function bZ(I,J,aM,aN,be)local b_,c0,P="┌"..string.rep("─",aM-2).."┐","└"..string.rep("─",aM-2).."┘",I+aM-1;bT(I,J,be,b_)J=J+1;for af=1,aN-2 do bT(I,J,be,"│")bT(P,J,be,"│")J=J+1 end;bT(I,J,be,c0)end;local function c1(at,be,c2)local c3,c4,c5="▀","▄"," "local ap,aq,as=h[at],i[at],j[at]if c2 then if as==c3 then if be==aq then h[at],i[at],j[at]=be,aq,c5 else h[at],i[at],j[at]=be,aq,as end elseif as==c5 then if be~=ap then h[at],i[at],j[at]=ap,be,c4 end else h[at],i[at],j[at]=ap,be,c4 end else if as==c4 then if be==aq then h[at],i[at],j[at]=be,aq,c5 else h[at],i[at],j[at]=be,aq,as end elseif as==c5 then if be~=ap then h[at],i[at],j[at]=ap,be,c3 end else h[at],i[at],j[at]=ap,be,c3 end end end;local function c6(I,J,be)local c7=y(J/2)if I>=k and c7>=m and I<=l and c7<=n then c1(c*(c7-1)+I,be,J%2==0)end end;local function c8(I,J,aM,aN,be)local at,c9,ca,cb,cc=c*(y(J/2)-1)+I,c-aM,aM;for cd=J,J+aN-1 do cb=y(cd/2)if cb>=m and cb<=n then cc=cd%2==0;for ce=I,I+aM-1 do if ce>=k and ce<=l then c1(at,be,cc)end;at=at+1 end else at=at+aM end;if cc then at=at+c9 else at=at-ca end end end;local function cf(N,O,P,Q,be)bo(N,O,P,Q,function(I,J)c6(I,J,be)end)end;local function cg(bD,bE,bF,bG,be)bC(bD,bE,bF,bG,function(I,J)c6(I,J,be)end)end;local function ch(ci,cj,ck)return{x=ci.x+(cj.x-ci.x)*ck,y=ci.y+(cj.y-ci.y)*ck}end;local function cl(cm,ck)local cn={}for co=1,#cm-1 do C(cn,ch(cm[co],cm[co+1],ck))end;return cn end;local function cp(cm,ck)if#cm>1 then return cp(cl(cm,ck),ck)else return cm[1]end end;local function cq(cm,be,cr)local cs={}for ck=0,1,cr or 0.01 do C(cs,cp(cm,ck))end;for co=1,#cs-1 do cf(z(cs[co].x),z(cs[co].y),z(cs[co+1].x),z(cs[co+1].y),be)end end;local function ct(cu)local at,cv,cw=c*(m-1)+k,c-l+k-1,{}local I,cx,cy,cz,bW,ay;local cA,cB,cC,cD,cE;local cF;for J=m,n do I=k;while I<=l do if e[at]~=h[at]or f[at]~=i[at]or g[at]~=j[at]or cu then cA,cB,cC=h[at],i[at],j[at]e[at]=cA;f[at]=cB;g[at]=cC;cx,cy,cz,bW={cC},2,I+1,at+1;while cz<=l do if cA==h[bW]and(j[bW]==" "or cB==i[bW])then e[bW]=h[bW]f[bW]=i[bW]g[bW]=j[bW]cx[cy],cy=g[bW],cy+1 else break end;cz,bW=cz+1,bW+1 end;cw[cA]=cw[cA]or{}cD=cw[cA]cD[cB]=cD[cB]or{index=1}cE=cD[cB]cF=cE.index;cE[cF],cF=I,cF+1;cE[cF],cF=J,cF+1;cE[cF],cF=D(cx),cF+1;I,at,cE.index=I+cy-2,at+cy-2,cF end;I,at=I+1,at+1 end;at=at+cv end;for ap,cG in pairs(cw)do t(ap)for aq,cH in pairs(cG)do if ay~=aq then u(aq)ay=aq end;for af=1,#cH,3 do w(cH[af],cH[af+1],cH[af+2])end end end;cw=nil end;return{loadImage=aG,getIndex=H,setDrawLimit=M,resetDrawLimit=R,getDrawLimit=S,flush=aL,setResolution=aO,bind=aS,setGPUProxy=aY,getGPUProxy=aW,getScaledResolution=a_,getResolution=aP,getWidth=aQ,getHeight=aR,getCurrentFrameTables=K,getNewFrameTables=L,rawSet=b6,rawGet=b7,get=b8,set=b9,clear=bd,copy=bf,paste=bh,rasterizeLine=bo,rasterizeEllipse=bC,semiPixelRawSet=c1,semiPixelSet=c6,update=ct,drawRectangle=ba,drawLine=bR,drawEllipse=bS,drawText=bT,drawImage=bX,drawFrame=bZ,drawSemiPixelRectangle=c8,drawSemiPixelLine=cf,drawSemiPixelEllipse=cg,drawSemiPixelCurve=cq}