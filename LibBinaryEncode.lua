local LibBinaryEncode = {
name = "LibBinaryEncode",
author = "Rhyono",
version = 8}

LBE = {}

--Converts binary to decimal
local function bin_dec(binStr)
	binStr = binStr:reverse()
	local sum = 0
	for s = 1,binStr:len() do
		sum = sum + binStr:sub(s,s) * math.pow(2,s-1)
	end
	return sum	
end

--Converts decimal to binary
local function dec_bin(decNum)
    local bits={}   
    for b = 8, 1, -1 do
        bits[b] = math.fmod(decNum, 2)
        decNum = math.floor((decNum - bits[b]) / 2)
    end
    return table.concat(bits)
end

--Checks if a value is true; allow global due to its usage scope
function IsTrue(val,strict)
	if (strict and (val == 1 or val == '1' or val == true)) or (not strict and (val ~= 0 and val ~= '0' and val ~= nil and val ~= '' and val ~= false)) then
		return true
	end
	return false
end

--For those that like consistency
function LBE:IsTrue(val,strict)
	IsTrue(val,strict)
end

--Converts boolean value to a number
function NumBool(val,strict)
	return IsTrue(val,strict) and 1 or 0
end

--For those that like consistency
function LBE:NumBool(val,strict)
	NumBool(val,strict)
end

--Converts string to table
function LBE:SplitString(inStr, sep)
	sep = sep or "%s"
	local t={}
	local i=1
	for str in string.gmatch(inStr, "([^"..sep.."])") do
			t[i] = str
			i = i + 1
	end
	return t
end

--Pointer for decoding special positions
local charset_pointer = {
	[256]=0,[257]=1,[260]=2,[261]=3,[262]=4,[263]=5,[264]=6,[265]=7,[274]=8,[275]=9,
	[280]=10,[281]=11,[284]=12,[285]=13,[286]=14,[287]=15,[292]=16,[293]=17,[298]=18,[299]=19,
	[304]=20,[305]=21,[308]=22,[309]=23,[321]=24,[322]=25,[323]=26,[324]=27,[332]=28,[333]=29,
	[338]=30,[339]=31,[346]=127,[347]=128,[350]=129,[351]=130,[352]=131,[353]=132,[362]=133,[363]=134,
	[372]=135,[373]=136,[374]=137,[375]=138,[376]=139,[377]=140,[378]=141,[379]=142,[380]=143,[381]=144,
	[382]=145,[1040]=146,[1041]=147,[1042]=148,[1043]=149,[1044]=150,[1045]=151,[1046]=152,[1047]=153,[1048]=154,
	[1049]=155,[1050]=156,[1051]=157,[1052]=158,[1053]=159,[1054]=160,[1055]=162,[1056]=170,[1057]=172,[1058]=173,
	[1059]=175,[1060]=184,[1061]=185,[1062]=186,[1063]=188,[1064]=190
}	
--Custom special character set to handle 0x00-0x31, 0x7F-0x9F, several others being unusable 
local charset = {[0]='Ā','ā','Ą','ą','Ć','ć','Ĉ','ĉ','Ē','ē','Ę','ę','Ĝ','ĝ','Ğ','ğ','Ĥ','ĥ','Ī','ī','İ','ı','Ĵ','ĵ','Ł','ł','Ń','ń','Ō','ō','Œ','œ',
[127]='Ś',[128]='ś',[129]='Ş',[130]='ş',[131]='Š',[132]='š',[133]='Ū',[134]='ū',[135]='Ŵ',[136]='ŵ',
[137]='Ŷ',[138]='ŷ',[139]='Ÿ',[140]='Ź',[141]='ź',[142]='Ż',[143]='ż',[144]='Ž',[145]='ž',[146]='А',
[147]='Б',[148]='В',[149]='Г',[150]='Д',[151]='Е',[152]='Ж',[153]='З',[154]='И',[155]='Й',[156]='К',
[157]='Л',[158]='М',[159]='Н',[160]='О',
--original
[161]='¡',
--replacement
[162]='П',
--original
[163]='£',[164]='¤',[165]='¥',[166]='¦',[167]='§',[168]='¨',[169]='©',
--replacement
[170]='Р',
--original
[171]='«',
--replacement
[172]='С',[173]='Т',
--original
[174]='®',
--replacement
[175]='У',
--original
[176]='°',[177]='±',[178]='²',[179]='³',[180]='´',[181]='µ',[182]='¶',[183]='·',
--replacement
[184]='Ф',[185]='Х',[186]='Ц',
--original
[187]='»',
--replacement
[188]='Ч',
--original
[189]='½',
--replacement
[190]='Ш',
--original
[191]='¿',[192]='À',[193]='Á',[194]='Â',[195]='Ã',[196]='Ä',[197]='Å',[198]='Æ',[199]='Ç',[200]='È',
[201]='É',[202]='Ê',[203]='Ë',[204]='Ì',[205]='Í',[206]='Î',[207]='Ï',[208]='Ð',[209]='Ñ',[210]='Ò',
[211]='Ó',[212]='Ô',[213]='Õ',[214]='Ö',[215]='×',[216]='Ø',[217]='Ù',[218]='Ú',[219]='Û',[220]='Ü',
[221]='Ý',[222]='Þ',[223]='ß',[224]='à',[225]='á',[226]='â',[227]='ã',[228]='ä',[229]='å',[230]='æ',
[231]='ç',[232]='è',[233]='é',[234]='ê',[235]='ë',[236]='ì',[237]='í',[238]='î',[239]='ï',[240]='ð',
[241]='ñ',[242]='ò',[243]='ó',[244]='ô',[245]='õ',[246]='ö',[247]='÷',[248]='ø',[249]='ù',[250]='ú',
[251]='û',[252]='ü',[253]='ý',[254]='þ',[255]='ÿ'
}

--Converts binary to pseudo base 256
function LBE:encode(binStr)
	local temp = {}
	--Convert table to binary string
	if type(binStr) == 'table' then
		for t=1,#binStr do
			temp[t] = IsTrue(binStr[t]) and 1 or 0
		end
		binStr = table.concat(temp)
	--If passed as a number, convert it to a text string of the number
	elseif type(binStr) == 'number' or type(binStr) == 'string' then
		binStr = tostring(binStr)
		for t=1,binStr:len() do
	    	temp[t] = binStr:sub(t,t) == '1' and 1 or 0
		end
		binStr = table.concat(temp)		
	end
	local enStr = {} 
	--Ensure length, pad right unlike math
	while math.fmod(binStr:len(),8) ~= 0 do
		binStr = binStr .. 0
	end
	
	for e=1,binStr:len()-7,8 do
		local charPos = bin_dec(binStr:sub(e,e+7))
		--Handle special substitutions
		if charPos < 32 or charPos > 126 then
			enStr[#enStr+1] = charset[charPos]
		else	
			enStr[#enStr+1] = string.char(charPos)
		end
	end
	
	return table.concat(enStr)
end

function LBE:decode(baseStr,tableOutput)
	if type(baseStr) == "number" then
		baseStr = tostring(baseStr)
	elseif type(baseStr) ~= "string" then
		return
	end
	local deStr = {} 
	
	--Skips a byte after dealing with unicode
	local skip = false
	for c=1,baseStr:len() do
		if not skip then
			local char1 = baseStr:byte(c)
			local char2 = nil
			if baseStr:byte(c) >= 194 then
				char1, char2 = baseStr:byte(c, c+1)
				skip = true
			end	
			if char2 == nil then
				deStr[#deStr+1] = dec_bin(char1)
			else
				local preNum = 0
				--194 starts at 0xA0
				if char1 >= 194 then
					preNum = char2+((char1-194)*64)
				end	
				--Use the pointer table to find the imitated value
				if charset_pointer[preNum] ~= nil then
					deStr[#deStr+1] = dec_bin(charset_pointer[preNum])
				else
					deStr[#deStr+1] = dec_bin(preNum)
				end	
			end	
		else
			skip = false
		end	
	end
	
	local outStr = table.concat(deStr)
	if tableOutput then
		return LBE:SplitString(outStr)
	else	
		return outStr
	end	
end