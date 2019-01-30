ByteStream = ZO_Object:Subclass()

--Event FF = reply, will be followed with user being replied to

-- header | 3 bytes
-- packetId | 2 bytes
-- eventId | 1 byte
-- isMulti | 1 bit

local currentPacketId = 0

function TestBS()
  local bs = ByteStream:New( 1, PacketTypes.chatMessage, {
    username = "alexdragian",
    messageBody = "test"
  } )

  local streams = bs:GenerateStreams()
  d( streams[1] )
  local bss = ByteStream:NewFromStream( streams[1] )
  local obj = bss:GetOutput()
  d( obj )

  --streams[1]
end

function ByteStream:New( eventId, def, data, packetId )
  local options = ZO_Object.New(self)
  options.streamData = ""
  options.signiture = "011101000110011101100011"
  options.packetId = packetId or self:NextPacketId()
  options.eventId = eventId

  for k, v in pairs(def) do
    options:InsertFromDef( v[2], data[v[1]] )
  end
  return options
end

function ByteStream:GetOutput()
  local output = {}
  local def = EventTypes[self.eventId]
  --FF is reply packet
  --00 can be something resevered

  for k, v in pairs(def) do
    output[v[1]] = self:GetFromDef( v[2] )
  end

  return output
end

function ByteStream:GetFromDef( type )
  if type == "string" then
    return self:GetString()
  elseif type == "byte" then
    return self:GetByte()
  elseif type == "sbyte" then
    return self:GetSByte()
  elseif type == "bool" then
    return self:GetBool()
  elseif type == "short" then
    return self:GetShort()
  elseif type == "ushort" then
    return self:GetUShort()
  end
end

function ByteStream:InsertFromDef( type, value )
  if type == "string" then
    self:AddString( value )
  elseif type == "byte" then
    self:AddByte( value )
  elseif type == "sbyte" then
    self:AddSByte( value )
  elseif type == "bool" then
    self:AddBool( value )
  elseif type == "short" then
    self:AddShort( value )
  elseif type == "ushort" then
    self:AddUShort( value )
  end
end

function ByteStream:NextPacketId()
  currentPacketId = currentPacketId + 1
  if currentPacketId > 63000 then
    currentPacketId = 1
  end
  return currentPacketId
end

function ByteStream:GenerateStreams()
  local breaks = math.ceil( self:Length() / 248 )
  local streams = {}
  local streamBackup = self.streamData
  self.streamData = self.signiture
  self:AddUShort( self.packetId )
  self:AddByte( self.eventId )
  self:AddBool( breaks > 1 )
  local header = self.streamData
  self.streamData = streamBackup

  for i=1,breaks do
    streams[i] =  LBE:encode( header .. streamBackup:sub( ( 284 * ( i - 1 ) ) + 1, ( i * 248 ) + 248 ) )
  end

  return streams
end

function ByteStream:NewFromStream(streamData)
  local options = ZO_Object.New(self)
  options.streamData = LBE:decode( streamData )
  options.position = 0
  options.position = options.position + ( 3 * 8 )
  options.packetId = options:GetUShort()
  options.eventId = options:GetByte()
  options.isMulti = options:GetBool()
  return options
end

function ByteStream:HasSigniture()
  if self.streamData:sub( 0, 24 ) == "011101000110011101100011" then
    return true
  else
    return false
  end
end

--Converts hexadecimal to binary
function ByteStream:HexToBin( hex )
  local unsignedDec = self:HexToDec( hex, false )
  return self:DecToBin( unsignedDec )
end

--Converts binary to hexadecimal
function ByteStream:BinToHex( bin )
  local unsignedDec = self:BinToDec( bin )
  return self:DecToHex( unsignedDec, 2 )
end

--Converts decimal to hexadecimal
function ByteStream:DecToHex( dec, size )
  local hex = string.format( "%4.4X", dec )
  local trimSize = hex:len() - size
  if trimSize > 0 then
    hex = hex:sub( trimSize + 1 )
  end

  return hex
end

--Converts hexadecimal to decimal
function ByteStream:HexToDec( hex, signed )
  local size = 0
  if hex:len() == 2 then
    size = 8
  elseif hex:len() == 4 then
    size = 16
  end

  local shift = size - 1

  if signed == true then
    return (tonumber("0X" .. hex, 16) + 2^shift) % 2^size - 2^shift
  else
    return tonumber("0X" .. hex, 16)
  end

end

--Converts binary to decimal
function ByteStream:BinToDec(binStr)
	binStr = binStr:reverse()
	local sum = 0
	for s = 1,binStr:len() do
		sum = sum + binStr:sub(s,s) * math.pow(2,s-1)
	end
	return sum
end

--Converts decimal to binary
function ByteStream:DecToBin(decNum)
  local bits={}   
  for b = 8, 1, -1 do
      bits[b] = math.fmod(decNum, 2)
      decNum = math.floor((decNum - bits[b]) / 2)
  end
  return table.concat(bits)
end

-- ADD

function ByteStream:AddShort( short )
  self:AddUShort( short )
end

function ByteStream:AddUShort( short )
  local shortHex = self:DecToHex( short, 4 )
  self.streamData = self.streamData .. self:HexToBin( shortHex:sub( 1, 2 ) ) .. self:HexToBin( shortHex:sub( 3, 4 ) )
end

function ByteStream:AddByte( byte )
  local bin = self:DecToBin( byte )
  self.streamData = self.streamData .. bin
end

function ByteStream:AddSByte( byte )
  self:AddByte( byte )
end

function ByteStream:Length()
  return math.ceil( self.streamData:len() / 8 )
end

function ByteStream:AddString( str )
  local sizeByte = self:AddByte( str:len() )
  for i=1,str:len() do
    self:AddByte( str:byte( i ) )
  end

end

function ByteStream:AddBool( bool )
  if bool == true then
    self.streamData = self.streamData .. "1"
  else
    self.streamData = self.streamData .. "0"
  end
end

-- GET

function ByteStream:GetShort()
  return self:HexToDec( self:BinToHex( self:GetHexByte() ) .. self:BinToHex( self:GetHexByte() ), true )
end

function ByteStream:GetUShort()
  return self:HexToDec( self:BinToHex( self:GetHexByte() ) .. self:BinToHex( self:GetHexByte() ), false )
end

function ByteStream:GetHexByte()
  local hexByte = self.streamData:sub( self.position + 1, self.position + 8 )
  self.position = self.position + 8
  return hexByte
end

function ByteStream:GetByte()
  return self:BinToDec( self:GetHexByte() )
end

function ByteStream:GetSByte()
  return self:HexToDec( self:BinToHex( self:GetHexByte() ), true )
end

function ByteStream:GetString()
  local sizeByte = self:GetByte()
  local stringOut = ""
  for i=1,sizeByte do
    local nextChar = self:GetByte()
    stringOut = stringOut .. string.char( nextChar )
  end

  return stringOut
end

function ByteStream:GetBool()
  local boolBin = self.streamData:sub( self.position + 1, self.position + 1 )
  self.position = self.position + 1
  if boolBin == "1" then
    return true
  else
    return false
  end
end