function TGC.SetTrackerBagHook()
	for k,v in pairs(PLAYER_INVENTORY.inventories) do
    local listView = v.listView
		if ( listView and listView.dataTypes and listView.dataTypes[1] ) then
			ZO_PreHook(listView.dataTypes[1], "setupCallback", function(control, slot)
				local itemLink = GetItemLink(control.dataEntry.data.bagId, control.dataEntry.data.slotIndex, LINK_STYLE_BRACKETS)
				TGC.AddSetIndicator(control, control.dataEntry.data.bagId, control.dataEntry.data.slotIndex, itemLink, RIGHT, 1)
			end)
		end
  end
  
  ZO_PreHook(ZO_SmithingTopLevelDeconstructionPanelInventoryBackpack.dataTypes[1], "setupCallback", function(control, slot)
    local itemLink = GetItemLink(control.dataEntry.data.bagId, control.dataEntry.data.slotIndex, LINK_STYLE_BRACKETS)
    TGC.AddSetIndicator(control, control.dataEntry.data.bagId, control.dataEntry.data.slotIndex, itemLink, RIGHT, 1)
  end)
end

--            <Label name="$(parent)Name" width="200" height="25" font="ZoFontGameLargeBold" inheritAlpha="true" color="EFEFEF"
--wrapMode="TRUNCATE" verticalAlignment="TOP" horizontalAlignment="LEFT" text="Recruitment Leader Boards">
--<Anchor point="TOP" relativeTo="$(parent)" relativePoint="TOP" offsetX="150" />
--</Label>

function TGC.AddSetIndicator(control, bagID, slotIndex, itemLink, relativePoint, opt)
	local function CreateSetKeepControl(parent)
		local control = WINDOW_MANAGER:CreateControl(parent:GetName() .. 'SetKeepControl', parent, CT_TEXTURE)
		control:SetDrawTier(DT_HIGH)
		control:SetHidden(true)
		return control
	end
	local function CreateSetTrashControl(parent)
		local control = WINDOW_MANAGER:CreateControl(parent:GetName() .. 'SetTrashControl', parent, CT_TEXTURE)
		control:SetDrawTier(DT_HIGH)
		control:SetHidden(true)
		return control
  end
  
  -- functions to manipulate tooltips for icons
	local function AddIconTooltips(control, text)
    control:SetHandler("OnMouseEnter", function(self) ZO_Tooltips_ShowTextTooltip(self, TOP, text) end)
    control:SetHandler("OnMouseExit", function(self) ZO_Tooltips_HideTextTooltip() end)
  end
  local function RemoveIconTooltips(control)
    control:SetHandler("OnMouseEnter", nil)
    control:SetHandler("OnMouseExit", nil)
  end
  local function HandleTooltips(control, text)
    control:SetMouseEnabled(true)
    AddIconTooltips(control, text)
  end
  local function SetInventoryIcon(control, size, icon, icontext)
    control:SetDimensions(size, size)
    control:SetTexture(icon)
    control:SetHidden(false)
    HandleTooltips(control, icontext)
  end



	local KeepControl = control:GetNamedChild('SetKeepControl')
  local TrashControl = control:GetNamedChild('SetTrashControl')
  if not KeepControl then KeepControl = CreateSetKeepControl(control) end
	if not TrashControl then TrashControl = CreateSetTrashControl(control) end
	KeepControl:SetHidden(true)
  TrashControl:SetHidden(true)

  local IsGridViewEnabled = false
  if ( control.isGrid or ( control:GetWidth() - control:GetHeight() < 5 ) ) then
		IsGridViewEnabled = true else IsGridViewEnabled = false
	end
  
  local itemType = GetItemLinkItemType(itemLink)
  --local itemId = GetItemIdFromLink(itemLink)
  if itemType == ITEMTYPE_ARMOR or itemType == ITEMTYPE_WEAPON then
    local name = GetItemName( bagID, slotIndex )
    local level = GetItemRequiredLevel( bagID, slotIndex )
    local champLevel = GetItemRequiredChampionPoints( bagID, slotIndex )
    local linkName = ""
    local linkText = ""
    local setData = {}
    local hasSet, setName = GetItemLinkSetInfo( itemLink, false )
    local creator = GetItemCreatorName( bagID, slotIndex )
    if creator == nil or creator == "" then
      if level < 50 or champLevel < 160 then
        if hasSet then
          linkName = "trash"
          linkText = "|cff0000Trash|r\nBelow CP160"
        else
          linkName = "trash"
          linkText = "|cff0000Trash|r\nBelow CP160\nNot in a set"
        end
      else
        if hasSet then
          linkName, linkText = TGC.CheckSetDatabase( setName, TGC.NormaliseEquipType( itemType, bagID, slotIndex, itemLink ) )
        else
          linkName = "trash"
          linkText = "|cff0000Trash|r\nNot in a set"
        end
      end
    else
      linkName = "crafted"
      if hasSet then
        _, linkText = TGC.CheckSetDatabase( setName, TGC.NormaliseEquipType( itemType, bagID, slotIndex, itemLink ), true )
      else
        linkText = "|c4444ffCrafted|"
      end

      linkText = "|c4444ffCrafted|r\n" .. linkText
    end
    
    if linkName ~= "" and linkName ~= nil then
      -- handle positioning icons from saved variables
      local controlName = WINDOW_MANAGER:GetControlByName(control:GetName() .. 'Name')
      TrashControl:ClearAnchors()
      TrashControl:SetAnchor(LEFT, controlName, relativePoint, 9, 0)
      SetInventoryIcon(TrashControl, 32, "/TGC/assets/" .. linkName .. ".dds", linkText )
    end

    --d( name .. " " .. level .. " " .. champLevel )
  end
  --d( itemType )
end

function TGC.EquipmentTooltip()

end

function TGC.DecribeSet( env, role, knownBuilds, traits )
  if env == "Research" or env == "Utility" then
    return {
      env = env,
      purpose = stat
    }
  else
    return {
      env = env,
      role = role,
      stat = stat,
      class = class,
      knownBuilds = knownBuilds,
      traits = traits
    }
  end
end

function TGC.NormaliseTrait( apiTrait )

end

function TGC.EquipmentText( setData, ignoreTrash )
  local text = ""
  if( setData["isTrash"] and ignoreTrash == false ) then
    text = "|cff0000Trash|r\n"
  end
  text = text .. "|c55ffffTypes|r: " .. setData["itemTypesText"]

  if setData["type"] == TGC.enums.setTypes.monster then
    text = text .. "\n" .. "|c55ffffHelm|r: " .. TGC.enums.undauntedChestText[setData["shoulderChest"]]
    text = text .. "\n" .. "|c55ffffShoulder|r: " .. setData["helmLocation"]
  else
    text = text .. "\n" .. "|c55ffffLocation|r: " .. setData["location"]
  end

  text = text .. "\n" .. "|c55ffffPlayer Level|r: " .. TGC.enums.playerLevelText[setData["playerLevel"]]

  if setData["builds"] and #setData["builds"] > 0 then
    --for build in setData["builds"] do
    local builds = {};
    for i, build in ipairs(setData["builds"]) do
       builds[#builds+1] = build.name
    end
    table.sort(builds)
    text = text .. "\n" .. "|c55ffffBuilds|r: " .. table.concat(builds, ", ")
  end

  return text
end

function TGC.CheckBuildHasType( type, types )

end

function TGC.CheckSetDatabase( setName, itemType, ignoreTrash )
  
  if ignoreTrash == nil then
    ignoreTrash = false
  end

  if TGC.setDb[setName] ~= nil and TGC.setDb[setName]["isTrash"] then
    return "trash", TGC.EquipmentText( TGC.setDb[setName], ignoreTrash )
  elseif TGC.setDb[setName] ~= nil and TGC.setDb[setName]["research"] ~= nil then
    return "research", TGC.EquipmentText( TGC.setDb[setName], ignoreTrash )
  elseif TGC.setDb[setName] ~= nil and TGC.setDb[setName]["builds"] then
    local builds = TGC.setDb[setName]["builds"]
    local buildTypes = {}
    for kb, vb in pairs(builds) do
      buildTypes[#buildTypes+1] = builds[kb]["type"]
    end
    --d( "is a build" )
    if itemType.type == TGC.enums.itemType.weapon and ignoreTrash == false then
      --d( "is weapon not ignored" )

      --Basic logic here -- Shilds are only for tank builds
      --Bows are only for stam dps
      --Melee weapons are only for dps classes
      --Staffs are only for magic users unless resto then ok for tanks
      return "set", TGC.EquipmentText( TGC.setDb[setName], ignoreTrash )
    else
      --d( "is set returning" )
      return "set", TGC.EquipmentText( TGC.setDb[setName], ignoreTrash )
    end
  else
    if TGC.setDb[setName] then
      --d( "No builds found" )
      local p = 'm'
    else
      return "unknown", "|cffff00Unknown Set|r"
    end
  end
end

function TGC.NormaliseEquipType( itemType, bagID, slotIndex, itemLink )
  if itemType == ITEMTYPE_ARMOR then
    local equipType = GetItemLinkEquipType( itemLink )
    if equipType == EQUIP_TYPE_CHEST then
      return { type = TGC.enums.itemType.armor, subType = TGC.enums.armor.chest }
    elseif equipType == EQUIP_TYPE_FEET then
      return { type = TGC.enums.itemType.armor, subType = TGC.enums.armor.feet }
    elseif equipType == EQUIP_TYPE_HAND then
      return { type = TGC.enums.itemType.armor, subType = TGC.enums.armor.hands }
    elseif equipType == EQUIP_TYPE_HEAD then
      return { type = TGC.enums.itemType.armor, subType = TGC.enums.armor.head }
    elseif equipType == EQUIP_TYPE_LEGS then
      return { type = TGC.enums.itemType.armor, subType = TGC.enums.armor.legs }
    elseif equipType == EQUIP_TYPE_NECK then
      return { type = TGC.enums.itemType.jewelry, subType = TGC.enums.jewelry.neck }
    elseif equipType == EQUIP_TYPE_OFF_HAND then
      return { type = TGC.enums.itemType.armor, subType = TGC.enums.armor.shield }
    elseif equipType == EQUIP_TYPE_RING then
      return { type = TGC.enums.itemType.jewelry, subType = TGC.enums.jewelry.ring }
    elseif equipType == EQUIP_TYPE_SHOULDERS then
      return { type = TGC.enums.itemType.armor, subType = TGC.enums.armor.shoulder }
    elseif equipType == EQUIP_TYPE_WAIST then
      return { type = TGC.enums.itemType.armor, subType = TGC.enums.armor.belt }
    end
  elseif itemType == ITEMTYPE_WEAPON then
    local weaponType = GetItemWeaponType( bagID, slotIndex )
    if weaponType == WEAPONTYPE_TWO_HANDED_AXE then
      return { type = TGC.enums.itemType.weapon, subType = TGC.enums.weapons.axeTwoHand }
    elseif weaponType == WEAPONTYPE_AXE then
      return { type = TGC.enums.itemType.weapon, subType = TGC.enums.weapons.axe }
    elseif weaponType == WEAPONTYPE_BOW then
      return { type = TGC.enums.itemType.weapon, subType = TGC.enums.weapons.bow }
    elseif weaponType == WEAPONTYPE_DAGGER then
      return { type = TGC.enums.itemType.weapon, subType = TGC.enums.weapons.dagger }
    elseif weaponType == WEAPONTYPE_FIRE_STAFF then
      return { type = TGC.enums.itemType.weapon, subType = TGC.enums.weapons.fireStaff }
    elseif weaponType == WEAPONTYPE_FROST_STAFF then
      return { type = TGC.enums.itemType.weapon, subType = TGC.enums.weapons.iceStaff }
    elseif weaponType == WEAPONTYPE_LIGHTNING_STAFF then
      return { type = TGC.enums.itemType.weapon, subType = TGC.enums.weapons.lightningStaff }
    elseif weaponType == WEAPONTYPE_HEALING_STAFF then
      return { type = TGC.enums.itemType.weapon, subType = TGC.enums.weapons.healingStaff }
    elseif weaponType == WEAPONTYPE_TWO_HANDED_HAMMER then
      return { type = TGC.enums.itemType.weapon, subType = TGC.enums.weapons.hammerTwoHand }
    elseif weaponType == WEAPONTYPE_HAMMER then
      return { type = TGC.enums.itemType.weapon, subType = TGC.enums.weapons.hammer }
    elseif weaponType == WEAPONTYPE_SHIELD then
      return { type = TGC.enums.itemType.weapon, subType = TGC.enums.armor.shield }
    elseif weaponType == WEAPONTYPE_TWO_HANDED_SWORD then
      return { type = TGC.enums.itemType.weapon, subType = TGC.enums.weapons.swordTwoHand }
    elseif weaponType == WEAPONTYPE_SWORD then
      return { type = TGC.enums.itemType.weapon, subType = TGC.enums.weapons.sword }
    end
  end
  
end