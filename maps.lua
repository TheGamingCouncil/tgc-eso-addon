TGC.hideTamriel = false

local original = GetFastTravelNodeInfo

GetFastTravelNodeInfo = function(nodeIndex, ...)

  local known, name, normalizedX, normalizedY, icon, glowIcon, poiType, isShownInCurrentMap, linkedCollectibleIsLocked = original(nodeIndex, ...)

  if GetMapType() == MAPTYPE_WORLD then
    if TGC.hideTamriel then -- Everything
      return false, name, normalizedX, normalizedY, icon, glowIcon, poiType, isShownInCurrentMap, linkedCollectibleIsLocked
    end

    return known, name, normalizedX, normalizedY, icon, glowIcon, poiType, isShownInCurrentMap, linkedCollectibleIsLocked

  end

  return known, name, normalizedX, normalizedY, icon, glowIcon, poiType, isShownInCurrentMap, linkedCollectibleIsLocked

end

function TGC.HideMapClutter()
  if TGC.hideTamriel then
    TGC.hideTamriel = false
    ZO_WorldMap_UpdateMap()
  else
    TGC.hideTamriel = true
    ZO_WorldMap_UpdateMap()
  end
end