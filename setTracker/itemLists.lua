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
    local setData = {}
    if level < 50 or champLevel < 160 then
      local creator = GetItemCreatorName( bagID, slotIndex )
      if creator == nil or creator == "" then
        linkName = "Trash"
      end
    else
      local hasSet, setName = GetItemLinkSetInfo( itemLink, false )
      
      if hasSet then
        linkName, setData = TGC.CheckSetDatabase( setName, TGC.NormaliseEquipType( itemType, bagID, slotIndex, itemLink ) )
      else
        linkName = "Trash"
      end
    end
    
    if linkName == "Trash" then
      -- handle positioning icons from saved variables
      local controlName = WINDOW_MANAGER:GetControlByName(control:GetName() .. 'Name')
      TrashControl:ClearAnchors()
      TrashControl:SetAnchor(LEFT, controlName, relativePoint, 9, 0)
      SetInventoryIcon(TrashControl, 32, "/TGC/assets/trash.dds", linkName )
    elseif linkName == "Question" then
      -- handle positioning icons from saved variables
      local controlName = WINDOW_MANAGER:GetControlByName(control:GetName() .. 'Name')
      TrashControl:ClearAnchors()
      TrashControl:SetAnchor(LEFT, controlName, relativePoint, 9, 0)
      SetInventoryIcon(TrashControl, 32, "/TGC/assets/trash.dds", linkName )
    end

    --d( name .. " " .. level .. " " .. champLevel )
  end
  --d( itemType )
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

function TGC.CheckSetDatabase( setName, itemType, itemEquipType, weaponType )
  

  for k, v in pairs(TGC.setDb) do
    if k == setName then
      if TGC.setDb[setName]["isTrash"] then
        return "Trash", TGC.setDb[setName]
      elseif TGC.setDb[setName]["gear"] then
        local doStuffWithBuildGear = ""
      end
    end
  end
end

function TGC.NormaliseEquipType( itemType, bagID, slotIndex, itemLink )
  if itemType == ITEMTYPE_ARMOR then
    local equipType = GetItemLinkEquipType( itemLink )
    if equipType == EQUIP_TYPE_CHEST then
      return TGC.enums.armor.chest
    elseif equipType == EQUIP_TYPE_FEET then
      return TGC.enums.armor.feet
    elseif equipType == EQUIP_TYPE_HAND then
      return TGC.enums.armor.hands
    elseif equipType == EQUIP_TYPE_HEAD then
      return TGC.enums.armor.head
    elseif equipType == EQUIP_TYPE_LEGS then
      return TGC.enums.armor.legs
    elseif equipType == EQUIP_TYPE_NECK then
      return TGC.enums.jewelry.neck
    elseif equipType == EQUIP_TYPE_OFF_HAND then
      return TGC.enums.armor.shield
    elseif equipType == EQUIP_TYPE_RING then
      return TGC.enums.jewelry.ring
    elseif equipType == EQUIP_TYPE_SHOULDERS then
      return TGC.enums.armor.shoulder
    elseif equipType == EQUIP_TYPE_WAIST then
      return TGC.enums.armor.belt
    end
  elseif itemType == ITEMTYPE_WEAPON then
    local weaponType = GetItemWeaponType( bagID, slotIndex )
    if weaponType == WEAPONTYPE_TWO_HANDED_AXE then
      return TGC.enums.weapons.axeTwoHand
    elseif weaponType == WEAPONTYPE_AXE then
      return TGC.enums.weapons.axe
    elseif weaponType == WEAPONTYPE_BOW then
      return TGC.enums.weapons.bow
    elseif weaponType == WEAPONTYPE_DAGGER then
      return TGC.enums.weapons.dagger
    elseif weaponType == WEAPONTYPE_FIRE_STAFF then
      return TGC.enums.weapons.fireStaff
    elseif weaponType == WEAPONTYPE_FROST_STAFF then
      return TGC.enums.weapons.iceStaff
    elseif weaponType == WEAPONTYPE_LIGHTNING_STAFF then
      return TGC.enums.weapons.lightningStaff
    elseif weaponType == WEAPONTYPE_HEALING_STAFF then
      return TGC.enums.weapons.healingStaff
    elseif weaponType == WEAPONTYPE_TWO_HANDED_HAMMER then
      return TGC.enums.weapons.hammerTwoHand
    elseif weaponType == WEAPONTYPE_HAMMER then
      return TGC.enums.weapons.hammer
    elseif weaponType == WEAPONTYPE_SHIELD then
      return TGC.enums.armor.shield
    elseif weaponType == WEAPONTYPE_TWO_HANDED_SWORD then
      return TGC.enums.weapons.swordTwoHand
    elseif weaponType == WEAPONTYPE_SWORD then
      return TGC.enums.weapons.sword
    end
  end
  
end