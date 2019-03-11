local ARMOR_HEAD = 3000
local ARMOR_SHOLDER = 3001
local ARMOR_CHEST = 3002
local ARMOR_ARM = 3003
local ARMOR_SHIELD = 3004
local ARMOR_BELT = 3005
local ARMOR_LEG = 3006
local ARMOR_FEET = 3007
local JEWEL_NECK = 3008
local JEWEL_RING = 3009
local WEAPON_AXE = 3010
local WEAPON_TWOHAND_AXE = 3011
local WEAPON_BOW = 3012
local WEAPON_DAGGER = 3013
local WEAPON_FIRE_STAFF = 3014
local WEAPON_ICE_STAFF = 3015
local WEAPON_LIGHTNING_STAFF = 3016
local WEAPON_HEALING_STAFF = 3017
local WEAPON_HAMMER = 3018
local WEAPON_TWOHAND_HAMMER = 3019
local WEAPON_SWORD = 3020
local WEAPON_TWOHAND_SWORD = 3021
local ALL_EQUIPMENT = 3022

local TRAIT_INFUSED = 2000
local TRAIT_IMPENETRABLE = 2001
local TRAIT_INFUSED = 2002
local TRAIT_NIRNHONED = 2003
local TRAIT_REINFORCED = 2004
local TRAIT_STURDY = 2005
local TRAIT_INVIGORATING = 2006
local TRAIT_REINFORCED = 2007
local TRAIT_TRAINING = 2008
local TRAIT_STURDY = 2009
local TRAIT_WELLFITTED = 2010
local TRAIT_POWERED = 2011
local TRAIT_CHARGED = 2012
local TRAIT_PRECISE = 2013
local TRAIT_DEFENDING = 2014
local TRAIT_SHARPENED = 2015
local TRAIT_DECISIVE = 2016
local TRAIT_ARCANE = 2017
local TRAIT_HEALTHY = 2018
local TRAIT_ROBUST = 2019
local TRAIT_TRIUNE = 2020
local TRAIT_PROTECTIVE = 2021
local TRAIT_SWIFT = 2022
local TRAIT_HARMONY = 2023
local TRAIT_BLOODTHIRSTY = 2024
local TRAIT_DIVINE = 2025

local ROLE_TANK = 4000
local ROLE_MAGIC_DPS = 4001
local ROLE_STAMINA_DPS = 4002
local ROLE_HEALER = 4003
local ROLE_SUPPORT = 4004

local ENV_PVP = 5000
local ENV_PVE = 5001

local PLAYER_LEVEL_EASY = 6000
local PLAYER_LEVEL_INTERMEDIATE = 6001
local PLAYER_LEVEL_EXPERT = 6002
local PLAYER_LEVEL_UNKNOWN = 6003

local SET_TYPE_MONSTER = 7000
local SET_TYPE_DUNGEON = 7001
local SET_TYPE_OVERWORLD = 7002
local SET_TYPE_CRAFTED = 7003
local SET_TYPE_PVP = 7004
local SET_TYPE_TRIAL = 7005
local SET_TYPE_ARENA = 7006

local UNDAUNTED_CHEST_MAJ = 8000
local UNDAUNTED_CHEST_GLIRION = 8001
local UNDAUNTED_CHEST_URGALARG = 8002

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
    if ESOMRL.ASV.aOpts.inventoryIT then
      control:SetMouseEnabled(true)
      AddIconTooltips(control, text)
    else
      control:SetMouseEnabled(false)
      RemoveIconTooltips(control)
    end
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
      return ARMOR_CHEST
    elseif equipType == EQUIP_TYPE_FEET then
      return ARMOR_FEET
    elseif equipType == EQUIP_TYPE_HAND then
      return ARMOR_ARM
    elseif equipType == EQUIP_TYPE_HEAD then
      return ARMOR_HEAD
    elseif equipType == EQUIP_TYPE_LEGS then
      return ARMOR_LEG
    elseif equipType == EQUIP_TYPE_NECK then
      return JEWEL_NECK
    elseif equipType == EQUIP_TYPE_OFF_HAND then
      return ARMOR_SHIELD
    elseif equipType == EQUIP_TYPE_RING then
      return JEWEL_RING
    elseif equipType == EQUIP_TYPE_SHOULDERS then
      return ARMOR_SHOLDER
    elseif equipType == EQUIP_TYPE_WAIST then
      return ARMOR_BELT
    end
  elseif itemType == ITEMTYPE_WEAPON then
    local weaponType = GetItemWeaponType( bagID, slotIndex )
    if weaponType == WEAPONTYPE_TWO_HANDED_AXE then
      return WEAPON_TWOHAND_AXE
    elseif weaponType == WEAPONTYPE_AXE then
      return WEAPON_AXE
    elseif weaponType == WEAPONTYPE_BOW then
      return WEAPON_BOW
    elseif weaponType == WEAPONTYPE_DAGGER then
      return WEAPON_DAGGER
    elseif weaponType == WEAPONTYPE_FIRE_STAFF then
      return WEAPON_FIRE_STAFF
    elseif weaponType == WEAPONTYPE_FROST_STAFF then
      return WEAPON_ICE_STAFF
    elseif weaponType == WEAPONTYPE_LIGHTNING_STAFF then
      return WEAPON_LIGHTNING_STAFF
    elseif weaponType == WEAPONTYPE_HEALING_STAFF then
      return WEAPON_HEALING_STAFF
    elseif weaponType == WEAPONTYPE_TWO_HANDED_HAMMER then
      return WEAPON_TWOHAND_HAMMER
    elseif weaponType == WEAPONTYPE_HAMMER then
      return WEAPON_HAMMER
    elseif weaponType == WEAPONTYPE_SHIELD then
      return ARMOR_SHIELD
    elseif weaponType == WEAPONTYPE_TWO_HANDED_SWORD then
      return WEAPON_TWOHAND_SWORD
    elseif weaponType == WEAPONTYPE_SWORD then
      return WEAPON_SWORD
    end
  end
  
end

TGC.setDb = {
  ["Balorgh"] = {
    type = SET_TYPE_MONSTER,
    helmLocation = "March of Sacrifices",
    shoulderChest = UNDAUNTED_CHEST_URGALARG,
    playerLevel = PLAYER_LEVEL_EXPERT,
    gear = {
      TGC.DecribeSet( ENV_PVP, ROLE_MAGIC_DPS, { "Bomb" }, {
        [ARMOR_HEAD] = { TRAIT_INFUSED, TRAIT_IMPENETRABLE },
        [ARMOR_SHOLDER] = { TRAIT_DIVINE, TRAIT_IMPENETRABLE }
      } ),
      TGC.DecribeSet( ENV_PVP, ROLE_STAMINA_DPS, { "Hammer of Justice" }, {
        [ARMOR_HEAD] = { TRAIT_IMPENETRABLE },
        [ARMOR_SHOLDER] = { TRAIT_IMPENETRABLE }
      } ),
      TGC.DecribeSet( "Research", "Werewolf" )
    }
  },
  ["Blood Spawn"] = {
    type = SET_TYPE_MONSTER,
    helmLocation = "Spindleclutch 2",
    shoulderChest = UNDAUNTED_CHEST_MAJ,
    playerLevel = PLAYER_LEVEL_EASY,
    gear = {
      TGC.DecribeSet( ENV_PVE, ROLE_TANK, { "Capacitor", "Catalyst", "Frostbite", "Paladin", "Siphoner", "Spartan" }, {
        [ARMOR_HEAD] = { TRAIT_INFUSED, TRAIT_STURDY },
        [ARMOR_SHOLDER] = { TRAIT_STURDY }
      } ),
      TGC.DecribeSet( ENV_PVP, ROLE_STAMINA_DPS, { "Assassin", "Hammer of Justice", "Spectre" }, {
        [ARMOR_HEAD] = { TRAIT_IMPENETRABLE, TRAIT_WELLFITTED },
        [ARMOR_SHOLDER] = { TRAIT_IMPENETRABLE, TRAIT_WELLFITTED }
      } ),
      TGC.DecribeSet( ENV_PVP, ROLE_MAGIC_DPS, { "Storm" }, {
        [ARMOR_HEAD] = { TRAIT_IMPENETRABLE },
        [ARMOR_SHOLDER] = { TRAIT_IMPENETRABLE }
      } ),
      TGC.DecribeSet( ENV_PVP, ROLE_HEALER, { "Guardplar" }, {
        [ARMOR_HEAD] = { TRAIT_STURDY },
        [ARMOR_SHOLDER] = { TRAIT_STURDY }
      } ),
      TGC.DecribeSet( ENV_PVP, ROLE_SUPPORT, { "Ritualist" }, {
        [ARMOR_HEAD] = { TRAIT_STURDY },
        [ARMOR_SHOLDER] = { TRAIT_STURDY }
      } )
    } 
  },
  ["Chokethorn"] = {
    type = SET_TYPE_MONSTER,
    helmLocation = "Elden Hollow 1",
    shoulderChest = UNDAUNTED_CHEST_MAJ,
    playerLevel = PLAYER_LEVEL_UNKNOWN,
    gear = {
      TGC.DecribeSet( ENV_PVE, ROLE_TANK, { "Guardian", "Darkness", "Spartan", "Patron" }, {
        [ARMOR_HEAD] = { TRAIT_STURDY },
        [ARMOR_SHOLDER] = { TRAIT_STURDY }
      } ),
      TGC.DecribeSet( ENV_PVE, ROLE_HEALER, { "Blossom" }, {
        [ARMOR_HEAD] = { TRAIT_INFUSED },
        [ARMOR_SHOLDER] = { TRAIT_DIVINE }
      } )
      
    }
  },
  ["Domihaus"] = {
    type = SET_TYPE_MONSTER,
    helmLocation = "Falkreath Hold",
    shoulderChest = UNDAUNTED_CHEST_URGALARG,
    playerLevel = PLAYER_LEVEL_UNKNOWN,
    gear = {
      TGC.DecribeSet( ENV_PVE, ROLE_STAMINA_DPS, { "Blooddrinker" }, {
        [ARMOR_HEAD] = { TRAIT_DIVINE },
        [ARMOR_SHOLDER] = { TRAIT_DIVINE }
      } ),
      TGC.DecribeSet( ENV_PVP, ROLE_MAGIC_DPS, { "Wrath" }, {
        [ARMOR_HEAD] = { TRAIT_INFUSED },
        [ARMOR_SHOLDER] = { TRAIT_IMPENETRABLE }
      } )
    }
  },
  ["Earthgore"] = {
    type = SET_TYPE_MONSTER,
    helmLocation = "Bloodroot Forge",
    shoulderChest = UNDAUNTED_CHEST_URGALARG,
    playerLevel = PLAYER_LEVEL_EASY,
    gear = {
      TGC.DecribeSet( ENV_PVE, ROLE_HEALER, { "Obsidian", "Illusion", "Surge", "Reliever", "Blossom" }, {
        [ARMOR_HEAD] = { TRAIT_INFUSED },
        [ARMOR_SHOLDER] = { TRAIT_DIVINE }
      } ),
      TGC.DecribeSet( ENV_PVP, ROLE_STAMINA_DPS, { "Rage", "Shepherd" }, {
        [ARMOR_HEAD] = { TRAIT_IMPENETRABLE },
        [ARMOR_SHOLDER] = { TRAIT_IMPENETRABLE }
      } )
    }
  },
  ["Engine Guardian"] = {
    type = SET_TYPE_MONSTER,
    helmLocation = "Darkshade Caverns 2",
    shoulderChest = UNDAUNTED_CHEST_MAJ,
    playerLevel = PLAYER_LEVEL_UNKNOWN,
    isTrash = true
  },
  ["Grothdarr"] = {
    type = SET_TYPE_MONSTER,
    helmLocation = "Vaults of Madness",
    shoulderChest = UNDAUNTED_CHEST_GLIRION,
    playerLevel = PLAYER_LEVEL_UNKNOWN,
    gear = {
      TGC.DecribeSet( ENV_PVE, ROLE_MAGIC_DPS, { "Valakas", "Azure", "Beamplar", "Ice & Fire" }, {
        [ARMOR_HEAD] = { TRAIT_DIVINE },
        [ARMOR_SHOLDER] = { TRAIT_DIVINE }
      } )
    }
  },
  ["Iceheart"] = {
    type = SET_TYPE_MONSTER,
    helmLocation = "Direfrost Keep",
    shoulderChest = UNDAUNTED_CHEST_GLIRION,
    playerLevel = PLAYER_LEVEL_UNKNOWN,
    isTrash = true
  },
  ["Ilambris"] = {
    type = SET_TYPE_MONSTER,
    helmLocation = "Crypt of Hearts 1",
    shoulderChest = UNDAUNTED_CHEST_GLIRION,
    playerLevel = PLAYER_LEVEL_UNKNOWN,
    gear = {
      TGC.DecribeSet( ENV_PVE, ROLE_MAGIC_DPS, { "Ice & Fire" }, {
        [ARMOR_HEAD] = { TRAIT_DIVINE },
        [ARMOR_SHOLDER] = { TRAIT_DIVINE }
      } ),
      TGC.DecribeSet( ENV_PVP, ROLE_MAGIC_DPS, { "Wrath" }, {
        [ARMOR_HEAD] = { TRAIT_INFUSED },
        [ARMOR_SHOLDER] = { TRAIT_IMPENETRABLE }
      } )
    }
  },
  ["Infernal Guardian"] = {
    type = SET_TYPE_MONSTER,
    helmLocation = "City of Ash 1",
    shoulderChest = UNDAUNTED_CHEST_GLIRION,
    playerLevel = PLAYER_LEVEL_UNKNOWN,
    isTrash = true
  },
  ["Kra'gh"] = {
    type = SET_TYPE_MONSTER,
    helmLocation = "Fungal Grotto 1",
    shoulderChest = UNDAUNTED_CHEST_MAJ,
    playerLevel = PLAYER_LEVEL_UNKNOWN,
    isTrash = true
  },
  ["Lord Warden"] = {
    type = SET_TYPE_MONSTER,
    helmLocation = "Imperial City Prison",
    shoulderChest = UNDAUNTED_CHEST_URGALARG,
    playerLevel = PLAYER_LEVEL_UNKNOWN,
    gear = {
      TGC.DecribeSet( ENV_PVE, ROLE_TANK, { "Capacitor", "Catalyst", "Pulse", "Siphoner", "Spartan" }, {
        [ARMOR_HEAD] = { TRAIT_INFUSED, TRAIT_STURDY },
        [ARMOR_SHOLDER] = { TRAIT_STURDY }
      } )
    }
  },
  ["Maw of the Infernal"] = {
    type = SET_TYPE_MONSTER,
    helmLocation = "The Banished Cells II",
    shoulderChest = UNDAUNTED_CHEST_MAJ,
    playerLevel = PLAYER_LEVEL_UNKNOWN,
    isTrash = true
  },
  ["Mighty Chudan"] = {
    type = SET_TYPE_MONSTER,
    helmLocation = "Ruins of Mazzatun",
    shoulderChest = UNDAUNTED_CHEST_URGALARG,
    playerLevel = PLAYER_LEVEL_UNKNOWN,
    gear = {
      TGC.DecribeSet( ENV_PVE, ROLE_TANK, { "Catalyst" }, {
        [ARMOR_HEAD] = { TRAIT_INFUSED },
        [ARMOR_SHOLDER] = { TRAIT_STURDY }
      } )
    }
  },
  ["Molag Kena"] = {
    type = SET_TYPE_MONSTER,
    helmLocation = "White-Gold Tower",
    shoulderChest = UNDAUNTED_CHEST_URGALARG,
    playerLevel = PLAYER_LEVEL_UNKNOWN,
    gear = {
      TGC.DecribeSet( ENV_PVE, ROLE_HEALER, { "Obsidian", "Surge", "Reliever", "Illusion" }, {
        [ARMOR_HEAD] = { TRAIT_INFUSED },
        [ARMOR_SHOLDER] = { TRAIT_DIVINE }
      } ),
      TGC.DecribeSet( ENV_PVE, ROLE_STAMINA_DPS, { "Claws" }, {
        [ARMOR_HEAD] = { TRAIT_DIVINE },
        [ARMOR_SHOLDER] = { TRAIT_DIVINE }
      } ),
      TGC.DecribeSet( ENV_PVE, ROLE_MAGIC_DPS, { "Azure" }, {
        [ARMOR_HEAD] = { TRAIT_DIVINE },
        [ARMOR_SHOLDER] = { TRAIT_DIVINE }
      } ),
      TGC.DecribeSet( ENV_PVP, ROLE_STAMINA_DPS, { "Silencium" }, {
        [ARMOR_HEAD] = { TRAIT_DIVINE },
        [ARMOR_SHOLDER] = { TRAIT_DIVINE }
      } )
    }
  },
  ["Nerien'eth"] = {
    type = SET_TYPE_MONSTER,
    helmLocation = "Crypt of Hearts 2",
    shoulderChest = UNDAUNTED_CHEST_GLIRION,
    playerLevel = PLAYER_LEVEL_UNKNOWN,
    gear = {
      TGC.DecribeSet( ENV_PVE, ROLE_MAGIC_DPS, { "Caluurion" }, {
        [ARMOR_HEAD] = { TRAIT_DIVINE },
        [ARMOR_SHOLDER] = { TRAIT_DIVINE }
      } )
    }
  },
  ["Nightflame"] = {
    type = SET_TYPE_MONSTER,
    helmLocation = "Elden Hollow 2",
    shoulderChest = UNDAUNTED_CHEST_MAJ,
    playerLevel = PLAYER_LEVEL_UNKNOWN,
    gear = {
      TGC.DecribeSet( ENV_PVE, ROLE_HEALER, { "Surge", "Reliever" }, {
        [ARMOR_HEAD] = { TRAIT_INFUSED },
        [ARMOR_SHOLDER] = { TRAIT_DIVINE }
      } )
    }
  },
  ["Pirate Skeleton"] = {
    type = SET_TYPE_MONSTER,
    helmLocation = "Blackheart Haven",
    shoulderChest = UNDAUNTED_CHEST_GLIRION,
    playerLevel = PLAYER_LEVEL_UNKNOWN,
    isTrash = true
  },
  ["Scourge Harvester"] = {
    type = SET_TYPE_MONSTER,
    helmLocation = "Wayrest Sewers 2",
    shoulderChest = UNDAUNTED_CHEST_MAJ,
    playerLevel = PLAYER_LEVEL_UNKNOWN,
    isTrash = true
  },
  ["Selene"] = {
    type = SET_TYPE_MONSTER,
    helmLocation = "Selene's Web",
    shoulderChest = UNDAUNTED_CHEST_GLIRION,
    playerLevel = PLAYER_LEVEL_UNKNOWN,
    gear = {
      TGC.DecribeSet( ENV_PVE, ROLE_STAMINA_DPS, { "Venom", "Claws", "Windwalker", "Jabsmania", "Rampage", "Guardian" }, {
        [ARMOR_HEAD] = { TRAIT_DIVINE },
        [ARMOR_SHOLDER] = { TRAIT_DIVINE }
      } ),
      TGC.DecribeSet( ENV_PVP, ROLE_STAMINA_DPS, { "Rage" }, {
        [ARMOR_HEAD] = { TRAIT_IMPENETRABLE },
        [ARMOR_SHOLDER] = { TRAIT_IMPENETRABLE }
      } )
    }
  },
  ["Sellistrix"] = {
    type = SET_TYPE_MONSTER,
    helmLocation = "Arx Corinium",
    shoulderChest = UNDAUNTED_CHEST_GLIRION,
    playerLevel = PLAYER_LEVEL_UNKNOWN,
    isTrash = true
  },
  ["Sentinel of Rkugamz"] = {
    type = SET_TYPE_MONSTER,
    helmLocation = "Darkshade Caverns 1",
    shoulderChest = UNDAUNTED_CHEST_MAJ,
    playerLevel = PLAYER_LEVEL_UNKNOWN,
    gear = {
      TGC.DecribeSet( ENV_PVE, ROLE_TANK, { "Capacitor", "Paladin" }, {
        [ARMOR_HEAD] = { TRAIT_INFUSED },
        [ARMOR_SHOLDER] = { TRAIT_STURDY }
      } )
    }
  },
  ["Shadowrend"] = {
    type = SET_TYPE_MONSTER,
    helmLocation = "The Banished Cells 1",
    shoulderChest = UNDAUNTED_CHEST_MAJ,
    playerLevel = PLAYER_LEVEL_UNKNOWN,
    gear = {
      TGC.DecribeSet( ENV_PVE, ROLE_TANK, { "Darkness", "Guardian", "Spartan", "Patron" }, {
        [ARMOR_HEAD] = { TRAIT_STURDY, TRAIT_INFUSED },
        [ARMOR_SHOLDER] = { TRAIT_STURDY }
      } )
    }
  },
  ["Slimecraw"] = {
    type = SET_TYPE_MONSTER,
    helmLocation = "Wayrest Sewers 1",
    shoulderChest = UNDAUNTED_CHEST_MAJ,
    playerLevel = PLAYER_LEVEL_UNKNOWN,
    gear = {
      TGC.DecribeSet( ENV_PVE, ROLE_MAGIC_DPS, { "Ice & Fire" }, {
        [ARMOR_HEAD] = { TRAIT_DIVINE },
        [ARMOR_SHOLDER] = { TRAIT_DIVINE }
      } )
    }
  },
  ["Spawn of Mephala"] = {
    type = SET_TYPE_MONSTER,
    helmLocation = "Fungal Grotto 2",
    shoulderChest = UNDAUNTED_CHEST_MAJ,
    playerLevel = PLAYER_LEVEL_UNKNOWN,
    isTrash = true
  },
  ["Stonekeeper"] = {
    type = SET_TYPE_MONSTER,
    helmLocation = "Frostvault",
    shoulderChest = UNDAUNTED_CHEST_URGALARG,
    playerLevel = PLAYER_LEVEL_UNKNOWN,
    gear = {
      TGC.DecribeSet( "Research", "New" )
    }
  },
  ["Stormfist"] = {
    type = SET_TYPE_MONSTER,
    helmLocation = "Tempest Island",
    shoulderChest = UNDAUNTED_CHEST_GLIRION,
    playerLevel = PLAYER_LEVEL_UNKNOWN,
    gear = {
      TGC.DecribeSet( ENV_PVE, ROLE_STAMINA_DPS, { "Venom", "Serpent", "Rampage", "Deathstroke", "Windwalker", "Jabsmania", "Racer", "Guardian" }, {
        [ARMOR_HEAD] = { TRAIT_DIVINE },
        [ARMOR_SHOLDER] = { TRAIT_DIVINE }
      } )
    }
  },
  ["Swarm Mother"] = {
    type = SET_TYPE_MONSTER,
    helmLocation = "Spindleclutch 1",
    shoulderChest = UNDAUNTED_CHEST_MAJ,
    playerLevel = PLAYER_LEVEL_UNKNOWN,
    gear = {
      TGC.DecribeSet( ENV_PVE, ROLE_TANK, { "Siphoner", "Paladin", "Capacitor", "Frostbite" }, {
        [ARMOR_HEAD] = { TRAIT_INFUSED },
        [ARMOR_SHOLDER] = { TRAIT_STURDY }
      } )
    }
  },
  ["Symphony of Blades"] = {
    type = SET_TYPE_MONSTER,
    helmLocation = "Depths of Malatar",
    shoulderChest = UNDAUNTED_CHEST_URGALARG,
    playerLevel = PLAYER_LEVEL_UNKNOWN,
    gear = {
      TGC.DecribeSet( "Research", "New" )
    }
  },
  ["The Troll King"] = {
    type = SET_TYPE_MONSTER,
    helmLocation = "Blessed Crucible",
    shoulderChest = UNDAUNTED_CHEST_GLIRION,
    playerLevel = PLAYER_LEVEL_UNKNOWN,
    gear = {
      TGC.DecribeSet( ENV_PVP, ROLE_STAMINA_DPS, { "Gladiator", "Rage", "Hammer of Justice" }, {
        [ARMOR_HEAD] = { TRAIT_WELLFITTED, TRAIT_IMPENETRABLE },
        [ARMOR_SHOLDER] = { TRAIT_WELLFITTED, TRAIT_IMPENETRABLE }
      } ),
      TGC.DecribeSet( "Research", "Werewolf" )
    }
  },
  ["Thurvokun"] = {
    type = SET_TYPE_MONSTER,
    helmLocation = "Fang Lair",
    shoulderChest = UNDAUNTED_CHEST_URGALARG,
    playerLevel = PLAYER_LEVEL_UNKNOWN,
    gear = {
      TGC.DecribeSet( ENV_PVE, ROLE_TANK, { "Paladin" }, {
        [ARMOR_HEAD] = { TRAIT_INFUSED },
        [ARMOR_SHOLDER] = { TRAIT_STURDY }
      } )
    }
  },
  ["Tremorscale"] = {
    type = SET_TYPE_MONSTER,
    helmLocation = "Volenfell",
    shoulderChest = UNDAUNTED_CHEST_GLIRION,
    playerLevel = PLAYER_LEVEL_UNKNOWN,
    isTrash = true
  },
  ["Valkyn Skoria"] = {
    type = SET_TYPE_MONSTER,
    helmLocation = "City of Ash 2",
    shoulderChest = UNDAUNTED_CHEST_GLIRION,
    playerLevel = PLAYER_LEVEL_EASY,
    gear = {
      TGC.DecribeSet( ENV_PVE, ROLE_MAGIC_DPS, { "Valakas", "Azure", "Beamplar", "Ice & Fire" }, {
        [ARMOR_HEAD] = { TRAIT_DIVINE },
        [ARMOR_SHOLDER] = { TRAIT_DIVINE }
      } ),
      TGC.DecribeSet( ENV_PVP, ROLE_MAGIC_DPS, { "Eruption", "Dot-Doc", "Freezer", "Spectral" }, {
        [ARMOR_HEAD] = { TRAIT_IMPENETRABLE },
        [ARMOR_SHOLDER] = { TRAIT_IMPENETRABLE }
      } ),
      TGC.DecribeSet( ENV_PVP, ROLE_STAMINA_DPS, { "Dot-Doc" }, {
        [ARMOR_HEAD] = { TRAIT_IMPENETRABLE },
        [ARMOR_SHOLDER] = { TRAIT_IMPENETRABLE }
      } )
    }
  },
  ["Velidreth"] = {
    type = SET_TYPE_MONSTER,
    helmLocation = "Cradle of Shadows",
    shoulderChest = UNDAUNTED_CHEST_URGALARG,
    playerLevel = PLAYER_LEVEL_INTERMEDIATE,
    gear = {
      TGC.DecribeSet( ENV_PVE, ROLE_STAMINA_DPS, { "Venom", "Serpent", "Rampage", "Windwalker", "Jabsmania", "Guardian" }, {
        [ARMOR_HEAD] = { TRAIT_DIVINE },
        [ARMOR_SHOLDER] = { TRAIT_DIVINE }
      } ),
      TGC.DecribeSet( ENV_PVP, ROLE_STAMINA_DPS, { "Assassin", "Silencium" }, {
        [ARMOR_HEAD] = { TRAIT_IMPENETRABLE, TRAIT_DIVINE },
        [ARMOR_SHOLDER] = { TRAIT_IMPENETRABLE, TRAIT_DIVINE }
      } )
    }
  },
  ["Vykosa"] = {
    type = SET_TYPE_MONSTER,
    helmLocation = "Moon Hunter Keep",
    shoulderChest = UNDAUNTED_CHEST_URGALARG,
    playerLevel = PLAYER_LEVEL_UNKNOWN,
    isTrash = true
  },
  ["Zaan"] = {
    type = SET_TYPE_MONSTER,
    helmLocation = "Scalecaller Peak",
    shoulderChest = UNDAUNTED_CHEST_URGALARG,
    playerLevel = PLAYER_LEVEL_INTERMEDIATE,
    gear = {
      TGC.DecribeSet( ENV_PVE, ROLE_MAGIC_DPS, { "Valakas", "Azure", "Ice & Fire", "Beamplar" }, {
        [ARMOR_HEAD] = { TRAIT_DIVINE },
        [ARMOR_SHOLDER] = { TRAIT_DIVINE }
      } ),
      TGC.DecribeSet( ENV_PVP, ROLE_MAGIC_DPS, { "Eruption", "Purification" }, {
        [ARMOR_HEAD] = { TRAIT_IMPENETRABLE },
        [ARMOR_SHOLDER] = { TRAIT_IMPENETRABLE }
      } )
    }
  },
  ----LIGHT SETS--------------
  ["Almalexia's Mercy"] = {
    type = SET_TYPE_PVP,
    location = "Cyrodiil",
    playerLevel = PLAYER_LEVEL_UNKNOWN,
    isTrash = true
  },
  ["Amber Plasm"] = {
    type = SET_TYPE_DUNGEON,
    location = "Ruins of Mazzatun",
    playerLevel = PLAYER_LEVEL_UNKNOWN,
    isTrash = true
  },
  ["Armor of the Trainee"] = {
    type = SET_TYPE_OVERWORLD,
    location = "Stros M'Kai, Khenarthi's Roost, Bleakrock Isle, Betnikh, and Bal Foyen",
    playerLevel = PLAYER_LEVEL_UNKNOWN,
    isTrash = true
  },
  ["Auroran's Thunder"] = {
    type = SET_TYPE_DUNGEON,
    location = "Depths of Malatar",
    playerLevel = PLAYER_LEVEL_UNKNOWN,
    gear = {
      TGC.DecribeSet( "Research", "New" )
    }
  },
  ["Bahraha's Curse"] = {
    type = SET_TYPE_OVERWORLD,
    location = "Hew's Bane",
    playerLevel = PLAYER_LEVEL_UNKNOWN,
    isTrash = true
  },
  ["Bloodthorn's Touch"] = {
    type = SET_TYPE_OVERWORLD,
    location = "Glenumbra",
    playerLevel = PLAYER_LEVEL_UNKNOWN,
    gear = {
      TGC.DecribeSet( ENV_PVP, ROLE_MAGIC_DPS, { "Purification" }, {
        [ARMOR_CHEST] = { TRAIT_REINFORCED },
        [ARMOR_BELT] = { TRAIT_IMPENETRABLE },
        [ARMOR_FEET] = { TRAIT_IMPENETRABLE },
        [ARMOR_LEG] = { TRAIT_IMPENETRABLE },
        [ARMOR_ARM] = { TRAIT_IMPENETRABLE },
        [JEWEL_NECK] = { TRAIT_ARCANE },
        [JEWEL_RING] = { TRAIT_ARCANE },
        [WEAPON_FIRE_STAFF] = { TRAIT_NIRNHONED },
        [WEAPON_SWORD] = {
          traits = { TRAIT_DECISIVE },
          options = {
            WEAPON_AXE,
            WEAPON_HAMMER,
            WEAPON_DAGGER,
          }
        },
        [ARMOR_SHIELD] = { TRAIT_INFUSED }
      } )
    }
  },
  ["Bright-Throat's Boast"] = {
    type = SET_TYPE_OVERWORLD,
    location = "Murkmire",
    playerLevel = PLAYER_LEVEL_UNKNOWN,
    isTrash = true
  },
  ["Buffer of the Swift"] = {
    type = SET_TYPE_PVP,
    location = "Cyrodiil, and Rewards of the Worthy",
    playerLevel = PLAYER_LEVEL_UNKNOWN,
    isTrash = true
  },
  ["Burning Spellweave"] = {
    type = SET_TYPE_DUNGEON,
    location = "City of Ash",
    playerLevel = PLAYER_LEVEL_UNKNOWN,
    gear = {
      TGC.DecribeSet( ENV_PVP, ROLE_MAGIC_DPS, { "Eruption" }, {
        [ARMOR_CHEST] = { TRAIT_IMPENETRABLE },
        [ARMOR_BELT] = { TRAIT_IMPENETRABLE },
        [ARMOR_FEET] = { TRAIT_IMPENETRABLE },
        [ARMOR_LEG] = { TRAIT_IMPENETRABLE },
        [ARMOR_ARM] = { TRAIT_IMPENETRABLE },
        [JEWEL_NECK] = { TRAIT_TRIUNE },
        [JEWEL_RING] = { TRAIT_TRIUNE },
        [WEAPON_FIRE_STAFF] = { TRAIT_NIRNHONED }
      } ),
      TGC.DecribeSet( ENV_PVE, ROLE_MAGIC_DPS, { "Valakas", "Azure", "Ice & Fire", "Beamplar" }, {
        [ARMOR_CHEST] = { TRAIT_DIVINE },
        [ARMOR_BELT] = { TRAIT_DIVINE },
        [ARMOR_FEET] = { TRAIT_DIVINE },
        [ARMOR_LEG] = { TRAIT_DIVINE },
        [ARMOR_ARM] = { TRAIT_DIVINE },
        [JEWEL_NECK] = { TRAIT_ARCANE, TRAIT_BLOODTHIRSTY },
        [JEWEL_RING] = { TRAIT_ARCANE, TRAIT_BLOODTHIRSTY },
        [WEAPON_FIRE_STAFF] = { TRAIT_INFUSED, TRAIT_PRECISE }
      } )
    }
  },
  ["Caluurion's Legacy"] = {
    type = SET_TYPE_DUNGEON,
    location = "Fang Lair",
    playerLevel = PLAYER_LEVEL_UNKNOWN,
    gear = {
      TGC.DecribeSet( ENV_PVE, ROLE_MAGIC_DPS, { "Caluurion" }, {
        [ARMOR_CHEST] = { TRAIT_DIVINE },
        [ARMOR_BELT] = { TRAIT_DIVINE },
        [ARMOR_FEET] = { TRAIT_DIVINE },
        [ARMOR_LEG] = { TRAIT_DIVINE },
        [ARMOR_ARM] = { TRAIT_DIVINE },
        [JEWEL_NECK] = { TRAIT_ARCANE },
        [JEWEL_RING] = { TRAIT_ARCANE },
        [WEAPON_FIRE_STAFF] = { TRAIT_INFUSED },
        [WEAPON_LIGHTNING_STAFF] = { TRAIT_INFUSED }
      } )
    }
  },
  ["Combat Physician"] = {
    type = SET_TYPE_DUNGEON,
    location = "Wayrest Sewers",
    playerLevel = PLAYER_LEVEL_UNKNOWN,
    isTrash = true
  },
  ["Curse Eater"] = {
    type = SET_TYPE_PVP,
    location = "Cyrodiil",
    playerLevel = PLAYER_LEVEL_UNKNOWN,
    isTrash = true
  },
  ["Desert Rose"] = {
    type = SET_TYPE_PVP,
    location = "Cyrodiil",
    playerLevel = PLAYER_LEVEL_UNKNOWN,
    gear = {
      TGC.DecribeSet( ENV_PVP, ROLE_HEALER, { "Guardplar" }, {
        [ARMOR_CHEST] = { TRAIT_STURDY },
        [ARMOR_BELT] = { TRAIT_STURDY },
        [ARMOR_FEET] = { TRAIT_STURDY },
        [ARMOR_LEG] = { TRAIT_STURDY },
        [ARMOR_ARM] = { TRAIT_STURDY },
        [JEWEL_NECK] = { TRAIT_ARCANE },
        [JEWEL_RING] = { TRAIT_ARCANE },
        [WEAPON_SWORD] = { TRAIT_POWERED },
        [ARMOR_SHIELD] = { TRAIT_STURDY },
        [WEAPON_HEALING_STAFF] = { TRAIT_INFUSED }
      } )
    }
  },
  ["Destructive Mage"] = {
    type = SET_TYPE_TRIAL,
    location = "Hel Ra Citadel",
    playerLevel = PLAYER_LEVEL_UNKNOWN,
    isTrash = true
  },
  ["Draugr's Rest"] = {
    type = SET_TYPE_DUNGEON,
    location = "Falkreath Hold",
    playerLevel = PLAYER_LEVEL_UNKNOWN,
    isTrash = true
  },
  ["Dreamer's Mantle"] = {
    type = SET_TYPE_OVERWORLD,
    location = "Stormhaven",
    playerLevel = PLAYER_LEVEL_UNKNOWN,
    isTrash = true
  },
  ["Elemental Succession"] = {
    type = SET_TYPE_ARENA,
    location = "Maelstrom Arena",
    playerLevel = PLAYER_LEVEL_UNKNOWN,
    isTrash = true
  },
  ["Flame Blossom"] = {
    type = SET_TYPE_DUNGEON,
    location = "Bloodroot Forge",
    playerLevel = PLAYER_LEVEL_UNKNOWN,
    isTrash = true
  },
  ["Galerion's Revenge"] = {
    type = SET_TYPE_PVP,
    location = "Imperial Sewers",
    playerLevel = PLAYER_LEVEL_UNKNOWN,
    isTrash = true
  },
  ["Gossamer"] = {
    type = SET_TYPE_DUNGEON,
    location = "Cradle of Shadows",
    playerLevel = PLAYER_LEVEL_UNKNOWN,
    gear = {
      TGC.DecribeSet( ENV_PVE, ROLE_HEALER, { "Illusion" }, {
        [ARMOR_CHEST] = { TRAIT_INFUSED },
        [ARMOR_BELT] = { TRAIT_DIVINE },
        [ARMOR_FEET] = { TRAIT_DIVINE },
        [ARMOR_LEG] = { TRAIT_INFUSED },
        [ARMOR_ARM] = { TRAIT_DIVINE },
        [JEWEL_NECK] = { TRAIT_ARCANE },
        [JEWEL_RING] = { TRAIT_ARCANE },
        [WEAPON_HEALING_STAFF] = { TRAIT_POWERED },
        [WEAPON_LIGHTNING_STAFF] = { TRAIT_CHARGED }
      } )
    }
  },
  ["Hanu's Compassion"] = {
    type = SET_TYPE_DUNGEON,
    location = "March of Sacrifices",
    playerLevel = PLAYER_LEVEL_UNKNOWN,
    gear = {
      TGC.DecribeSet( "Research", "Wolf hunter" )
    }
  },
  ["Healer's Habit"] = {
    type = SET_TYPE_ARENA,
    location = "Dragonstar Arena",
    playerLevel = PLAYER_LEVEL_UNKNOWN,
    isTrash = true
  },
  ["Healing Mage"] = {
    type = SET_TYPE_TRIAL,
    location = "Aetherian Archive",
    playerLevel = PLAYER_LEVEL_UNKNOWN,
    gear = {
      TGC.DecribeSet( ENV_PVE, ROLE_HEALER, { "Obsidian", "Illusion", "Surge", "Reliever", "Blossom" }, {
        [ARMOR_CHEST] = { TRAIT_INFUSED },
        [ARMOR_BELT] = { TRAIT_DIVINE },
        [ARMOR_FEET] = { TRAIT_DIVINE },
        [ARMOR_LEG] = { TRAIT_INFUSED },
        [ARMOR_ARM] = { TRAIT_DIVINE },
        [JEWEL_NECK] = { TRAIT_ARCANE },
        [JEWEL_RING] = { TRAIT_ARCANE },
        [WEAPON_HEALING_STAFF] = { TRAIT_POWERED },
        [WEAPON_LIGHTNING_STAFF] = { TRAIT_CHARGED }
      } )
    }
  },
  ["Icy Conjuror"] = {
    type = SET_TYPE_DUNGEON,
    location = "Frostvault",
    playerLevel = PLAYER_LEVEL_UNKNOWN,
    gear = {
      TGC.DecribeSet( "Research", "New" )
    }
  },
  ["Imperial Physique"] = {
    type = SET_TYPE_PVP,
    location = "Imperial Sewers",
    playerLevel = PLAYER_LEVEL_UNKNOWN,
    gear = {
      TGC.DecribeSet( ENV_PVP, ROLE_STAMINA_DPS, { "Hammer of Justice" }, {
        [ARMOR_CHEST] = { TRAIT_IMPENETRABLE },
        [ARMOR_BELT] = { TRAIT_IMPENETRABLE },
        [ARMOR_FEET] = { TRAIT_IMPENETRABLE },
        [ARMOR_LEG] = { TRAIT_IMPENETRABLE },
        [ARMOR_ARM] = { TRAIT_IMPENETRABLE },
        [JEWEL_NECK] = { TRAIT_TRIUNE, TRAIT_SWIFT },
        [JEWEL_RING] = { TRAIT_TRIUNE, TRAIT_SWIFT },
        [WEAPON_SWORD] = { TRAIT_SHARPENED, TRAIT_SHARPENED },
        [WEAPONTYPE_TWO_HANDED_SWORD] = { TRAIT_NIRNHONED }
      } )
    }
  },
  ["Indomitable Fury"] = {
    type = SET_TYPE_PVP,
    location = "Cyrodiil",
    playerLevel = PLAYER_LEVEL_UNKNOWN,
    isTrash = true
  },
  ["Infallible Mage"] = {
    type = SET_TYPE_TRIAL,
    location = "Hel Ra Citadel, Aetherian Archive, and Sanctum Ophidia",
    playerLevel = PLAYER_LEVEL_UNKNOWN,
    gear = {
      TGC.DecribeSet( ENV_PVE, ROLE_HEALER, { "Surge", "Reliever", "Blossom" }, {
        [ARMOR_CHEST] = { TRAIT_INFUSED },
        [ARMOR_BELT] = { TRAIT_DIVINE },
        [ARMOR_FEET] = { TRAIT_DIVINE },
        [ARMOR_LEG] = { TRAIT_INFUSED },
        [ARMOR_ARM] = { TRAIT_DIVINE },
        [JEWEL_NECK] = { TRAIT_ARCANE },
        [JEWEL_RING] = { TRAIT_ARCANE },
        [WEAPON_HEALING_STAFF] = { TRAIT_POWERED },
        [WEAPON_LIGHTNING_STAFF] = { TRAIT_CHARGED }
      } )
    }
  },
  ["Inventor's Guard"] = {
    type = SET_TYPE_TRIAL,
    location = "Halls of Fabrication",
    playerLevel = PLAYER_LEVEL_UNKNOWN,
    isTrash = true
  },
  ["Jorvuld's Guidance"] = {
    type = SET_TYPE_DUNGEON,
    location = "Scalecaller Peak",
    playerLevel = PLAYER_LEVEL_UNKNOWN,
    gear = {
      TGC.DecribeSet( ENV_PVE, ROLE_HEALER, { "Obsidian", "Illusion", "Surge", "Reliever", "Blossom" }, {
        [ARMOR_CHEST] = { TRAIT_INFUSED },
        [ARMOR_BELT] = { TRAIT_DIVINE },
        [ARMOR_FEET] = { TRAIT_DIVINE },
        [ARMOR_LEG] = { TRAIT_INFUSED },
        [ARMOR_ARM] = { TRAIT_DIVINE },
        [JEWEL_NECK] = { TRAIT_ARCANE },
        [JEWEL_RING] = { TRAIT_ARCANE },
        [WEAPON_HEALING_STAFF] = { TRAIT_POWERED },
        [WEAPON_LIGHTNING_STAFF] = { TRAIT_CHARGED }
      } )
    }
  },
  ["Knight Slayer"] = {
    type = SET_TYPE_PVP,
    location = "Battlegrounds",
    playerLevel = PLAYER_LEVEL_UNKNOWN,
    isTrash = true
  },
  ["Lamia's Song"] = {
    type = SET_TYPE_DUNGEON,
    location = "Arx Corinium",
    playerLevel = PLAYER_LEVEL_UNKNOWN,
    isTrash = true
  },
  ["Light of Cyrodiil"] = {
    type = SET_TYPE_PVP,
    location = "Cyrodiil",
    playerLevel = PLAYER_LEVEL_UNKNOWN,
    isTrash = true
  },
  ["Light Speaker"] = {
    type = SET_TYPE_DUNGEON,
    location = "Elden Hollow",
    playerLevel = PLAYER_LEVEL_UNKNOWN,
    isTrash = true
  },
  ["Mad Tinkerer"] = {
    type = SET_TYPE_OVERWORLD,
    location = "The Clockwork City",
    playerLevel = PLAYER_LEVEL_UNKNOWN,
    isTrash = true
  },
  ["Magicka Furnace"] = {
    type = SET_TYPE_DUNGEON,
    location = "Direfrost Keep",
    playerLevel = PLAYER_LEVEL_UNKNOWN,
    isTrash = true
  },
  ["Mantle of Siroria"] = {
    type = SET_TYPE_TRIAL,
    location = "Cloudrest",
    playerLevel = PLAYER_LEVEL_UNKNOWN,
    gear = {
      TGC.DecribeSet( ENV_PVE, ROLE_MAGIC_DPS, { "Valakas", "Azure", "Ice & Fire", "Beamplar" }, {
        [ARMOR_CHEST] = { TRAIT_DIVINE },
        [ARMOR_BELT] = { TRAIT_DIVINE },
        [ARMOR_FEET] = { TRAIT_DIVINE },
        [ARMOR_LEG] = { TRAIT_DIVINE },
        [ARMOR_ARM] = { TRAIT_DIVINE },
        [JEWEL_NECK] = { TRAIT_ARCANE, TRAIT_BLOODTHIRSTY },
        [JEWEL_RING] = { TRAIT_ARCANE, TRAIT_BLOODTHIRSTY },
        [WEAPON_FIRE_STAFF] = { TRAIT_PRECISE, TRAIT_INFUSED },
        [WEAPON_LIGHTNING_STAFF] = { TRAIT_PRECISE, TRAIT_INFUSED }
      } )
    }
  },
  ["Master Architect"] = {
    type = SET_TYPE_TRIAL,
    location = "Halls of Fabrication",
    playerLevel = PLAYER_LEVEL_UNKNOWN,
    gear = {
      TGC.DecribeSet( ENV_PVE, ROLE_MAGIC_DPS, { "Azure", "Ice & Fire", "Beamplar" }, {
        [ARMOR_CHEST] = { TRAIT_DIVINE },
        [ARMOR_BELT] = { TRAIT_DIVINE },
        [ARMOR_FEET] = { TRAIT_DIVINE },
        [ARMOR_LEG] = { TRAIT_DIVINE },
        [ARMOR_ARM] = { TRAIT_DIVINE },
        [JEWEL_NECK] = { TRAIT_ARCANE, TRAIT_BLOODTHIRSTY },
        [JEWEL_RING] = { TRAIT_ARCANE, TRAIT_BLOODTHIRSTY },
        [WEAPON_FIRE_STAFF] = { TRAIT_PRECISE, TRAIT_INFUSED },
        [WEAPON_LIGHTNING_STAFF] = { TRAIT_PRECISE, TRAIT_INFUSED }
      } )
    }
  },
  ["Meritorious Service"] = {
    type = SET_TYPE_PVP,
    location = "Imperial Sewers",
    playerLevel = PLAYER_LEVEL_UNKNOWN,
    isTrash = true
  },
  ["Moon Hunter"] = {
    type = SET_TYPE_DUNGEON,
    location = "Moon Hunter Keep",
    playerLevel = PLAYER_LEVEL_UNKNOWN,
    gear = {
      TGC.DecribeSet( "Research", "Wolf hunter" )
    }
  },
  ["Moondancer"] = {
    type = SET_TYPE_TRIAL,
    location = "Maw of Lorkhaj",
    playerLevel = PLAYER_LEVEL_UNKNOWN,
    gear = {
      TGC.DecribeSet( ENV_PVE, ROLE_MAGIC_DPS, { "Valakas", "Azure", "Beamplar" }, {
        [ARMOR_CHEST] = { TRAIT_DIVINE },
        [ARMOR_BELT] = { TRAIT_DIVINE },
        [ARMOR_FEET] = { TRAIT_DIVINE },
        [ARMOR_LEG] = { TRAIT_DIVINE },
        [ARMOR_ARM] = { TRAIT_DIVINE },
        [JEWEL_NECK] = { TRAIT_ARCANE, TRAIT_BLOODTHIRSTY },
        [JEWEL_RING] = { TRAIT_ARCANE, TRAIT_BLOODTHIRSTY },
        [WEAPON_FIRE_STAFF] = { TRAIT_PRECISE, TRAIT_INFUSED },
        [WEAPON_LIGHTNING_STAFF] = { TRAIT_PRECISE, TRAIT_INFUSED }
      } )
    }
  },
  ["Mother's Sorrow"] = {
    type = SET_TYPE_OVERWORLD,
    location = "Deshaan",
    playerLevel = PLAYER_LEVEL_UNKNOWN,
    gear = {
      TGC.DecribeSet( ENV_PVE, ROLE_MAGIC_DPS, { "Valakas", "Azure", "Beamplar", "Ice & Fire" }, {
        [ARMOR_CHEST] = { TRAIT_DIVINE },
        [ARMOR_BELT] = { TRAIT_DIVINE },
        [ARMOR_FEET] = { TRAIT_DIVINE },
        [ARMOR_LEG] = { TRAIT_DIVINE },
        [ARMOR_ARM] = { TRAIT_DIVINE },
        [JEWEL_NECK] = { TRAIT_ARCANE, TRAIT_BLOODTHIRSTY },
        [JEWEL_RING] = { TRAIT_ARCANE, TRAIT_BLOODTHIRSTY },
        [WEAPON_FIRE_STAFF] = { TRAIT_PRECISE, TRAIT_INFUSED },
        [WEAPON_LIGHTNING_STAFF] = { TRAIT_PRECISE, TRAIT_INFUSED }
      } )
    }
  },
  ["Necropotence"] = {
    type = SET_TYPE_OVERWORLD,
    location = "Rivenspire",
    playerLevel = PLAYER_LEVEL_UNKNOWN,
    gear = {
      TGC.DecribeSet( ENV_PVE, ROLE_MAGIC_DPS, { "Freezer", "Ice & Fire", "One Bar Sorc" }, {
        [ARMOR_CHEST] = { TRAIT_DIVINE, TRAIT_INFUSED },
        [ARMOR_BELT] = { TRAIT_DIVINE },
        [ARMOR_FEET] = { TRAIT_DIVINE },
        [ARMOR_LEG] = { TRAIT_DIVINE, TRAIT_INFUSED },
        [ARMOR_ARM] = { TRAIT_DIVINE },
        [JEWEL_NECK] = { TRAIT_ARCANE, TRAIT_BLOODTHIRSTY },
        [JEWEL_RING] = { TRAIT_ARCANE, TRAIT_BLOODTHIRSTY },
        [WEAPON_FIRE_STAFF] = { TRAIT_PRECISE, TRAIT_INFUSED },
        [WEAPON_LIGHTNING_STAFF] = { TRAIT_PRECISE, TRAIT_INFUSED }
      } )
    }
  },
  ["Netch's Touch"] = {
    type = SET_TYPE_DUNGEON,
    location = "Darkshade Caverns",
    playerLevel = PLAYER_LEVEL_UNKNOWN,
    isTrash = true
  },
  ["Noble Duelist's Silks"] = {
    type = SET_TYPE_DUNGEON,
    location = "Blessed Crucible",
    playerLevel = PLAYER_LEVEL_UNKNOWN,
    isTrash = true
  },
  ["Overwhelming Surge"] = {
    type = SET_TYPE_DUNGEON,
    location = "Tempest Island",
    playerLevel = PLAYER_LEVEL_UNKNOWN,
    isTrash = true
  },
  ["Perfect Mantle of Siroria"] = {
    type = SET_TYPE_TRIAL,
    location = "Cloudrest Veteran",
    playerLevel = PLAYER_LEVEL_UNKNOWN,
    gear = {
      TGC.DecribeSet( ENV_PVE, ROLE_MAGIC_DPS, { "Valakas", "Azure", "Ice & Fire", "Beamplar" }, {
        [ARMOR_CHEST] = { TRAIT_DIVINE },
        [ARMOR_BELT] = { TRAIT_DIVINE },
        [ARMOR_FEET] = { TRAIT_DIVINE },
        [ARMOR_LEG] = { TRAIT_DIVINE },
        [ARMOR_ARM] = { TRAIT_DIVINE },
        [JEWEL_NECK] = { TRAIT_ARCANE, TRAIT_BLOODTHIRSTY },
        [JEWEL_RING] = { TRAIT_ARCANE, TRAIT_BLOODTHIRSTY },
        [WEAPON_FIRE_STAFF] = { TRAIT_PRECISE, TRAIT_INFUSED },
        [WEAPON_LIGHTNING_STAFF] = { TRAIT_PRECISE, TRAIT_INFUSED }
      } )
    }
  },
  ["Perfect Vestment of Olorime"] = {
    type = SET_TYPE_TRIAL,
    location = "Cloudrest Veteran",
    playerLevel = PLAYER_LEVEL_UNKNOWN,
    gear = {
      TGC.DecribeSet( ENV_PVE, ROLE_HEALER, { "Obsidian", "Illusion", "Surge", "Reliever", "Blossom" }, {
        [ARMOR_CHEST] = { TRAIT_INFUSED },
        [ARMOR_BELT] = { TRAIT_DIVINE },
        [ARMOR_FEET] = { TRAIT_DIVINE },
        [ARMOR_LEG] = { TRAIT_INFUSED },
        [ARMOR_ARM] = { TRAIT_DIVINE },
        [JEWEL_NECK] = { TRAIT_ARCANE },
        [JEWEL_RING] = { TRAIT_ARCANE },
        [WEAPON_HEALING_STAFF] = { TRAIT_POWERED },
        [WEAPON_LIGHTNING_STAFF] = { TRAIT_CHARGED }
      } )
    }
  },
  ["Phoenix"] = {
    type = SET_TYPE_PVP,
    location = "Imperial Sewers",
    playerLevel = PLAYER_LEVEL_UNKNOWN,
    isTrash = true
  },
  ["Prayer Shawl"] = {
    type = SET_TYPE_DUNGEON,
    location = "Spindleclutch",
    playerLevel = PLAYER_LEVEL_UNKNOWN,
    isTrash = true
  },
  ["Prisoner's Rags"] = {
    type = SET_TYPE_OVERWORLD,
    location = "Coldharbour",
    playerLevel = PLAYER_LEVEL_UNKNOWN,
    gear = {
      TGC.DecribeSet( "Research", "Werewolf" )
    }
  },
  ["Queen's Elegance"] = {
    type = SET_TYPE_OVERWORLD,
    location = "Auridon",
    playerLevel = PLAYER_LEVEL_UNKNOWN,
    isTrash = true
  },
  ["Robes of Alteration Mastery"] = {
    type = SET_TYPE_PVP,
    location = "Cyrodiil",
    playerLevel = PLAYER_LEVEL_UNKNOWN,
    isTrash = true
  },
  ["Robes of Destruction Mastery"] = {
    type = SET_TYPE_ARENA,
    location = "Dragonstar Arena",
    playerLevel = PLAYER_LEVEL_UNKNOWN,
    isTrash = true
  },
  ["Robes of the Hist"] = {
    type = SET_TYPE_OVERWORLD,
    location = "Shadowfen",
    playerLevel = PLAYER_LEVEL_UNKNOWN,
    isTrash = true
  },
  ["Robes of the Withered Hand"] = {
    type = SET_TYPE_OVERWORLD,
    location = "Alik'r Desert",
    playerLevel = PLAYER_LEVEL_UNKNOWN,
    isTrash = true
  },
  ["Robes of Transmutation"] = {
    type = SET_TYPE_PVP,
    location = "Cyrodiil",
    playerLevel = PLAYER_LEVEL_UNKNOWN,
    gear = {
      TGC.DecribeSet( ENV_PVP, ROLE_SUPPORT, { "Ritualist" }, {
        [ARMOR_CHEST] = { TRAIT_STURDY },
        [ARMOR_BELT] = { TRAIT_STURDY },
        [ARMOR_FEET] = { TRAIT_STURDY },
        [ARMOR_LEG] = { TRAIT_STURDY },
        [ARMOR_ARM] = { TRAIT_STURDY },
        [JEWEL_NECK] = { TRAIT_TRIUNE },
        [JEWEL_RING] = { TRAIT_TRIUNE },
        [WEAPON_SWORD] = { TRAIT_DECISIVE },
        [ARMOR_SHIELD] = { TRAIT_STURDY },
        [WEAPON_HEALING_STAFF] = { TRAIT_INFUSED }
      } )
    }
  },
  ["Sanctuary"] = {
    type = SET_TYPE_DUNGEON,
    location = "The Banished Cells",
    playerLevel = PLAYER_LEVEL_UNKNOWN,
    gear = {
      TGC.DecribeSet( ENV_PVE, ROLE_HEALER, { "Obsidian", "Illusion", "Surge", "Reliever", "Blossom" }, {
        [ARMOR_CHEST] = { TRAIT_INFUSED },
        [ARMOR_BELT] = { TRAIT_DIVINE },
        [ARMOR_FEET] = { TRAIT_DIVINE },
        [ARMOR_LEG] = { TRAIT_INFUSED },
        [ARMOR_ARM] = { TRAIT_DIVINE },
        [JEWEL_NECK] = { TRAIT_ARCANE },
        [JEWEL_RING] = { TRAIT_ARCANE },
        [WEAPON_HEALING_STAFF] = { TRAIT_POWERED },
        [WEAPON_LIGHTNING_STAFF] = { TRAIT_CHARGED }
      } )
    }
  },
  ["Scathing Mage"] = {
    type = SET_TYPE_DUNGEON,
    location = "Imperial City Prison",
    playerLevel = PLAYER_LEVEL_UNKNOWN,
    isTrash = true
  },
  ["Shadow Dancer's Raiment"] = {
    type = SET_TYPE_OVERWORLD,
    location = "Greenshade",
    playerLevel = PLAYER_LEVEL_UNKNOWN,
    isTrash = true
  },
  ["Shroud of the Lich"] = {
    type = SET_TYPE_DUNGEON,
    location = "Crypt of Hearts",
    playerLevel = PLAYER_LEVEL_UNKNOWN,
    gear = {
      TGC.DecribeSet( ENV_PVP, ROLE_MAGIC_DPS, { "Wrath" }, {
        [ARMOR_CHEST] = { TRAIT_INFUSED },
        [ARMOR_BELT] = { TRAIT_IMPENETRABLE },
        [ARMOR_FEET] = { TRAIT_IMPENETRABLE },
        [ARMOR_LEG] = { TRAIT_INFUSED },
        [ARMOR_ARM] = { TRAIT_IMPENETRABLE },
        [JEWEL_NECK] = { TRAIT_ARCANE },
        [JEWEL_RING] = { TRAIT_ARCANE },
        [WEAPON_FIRE_STAFF] = { TRAIT_INFUSED },
        [WEAPON_HEALING_STAFF] = { TRAIT_INFUSED }
      } )
    }
  },
  ["Silks of the Sun"] = {
    type = SET_TYPE_OVERWORLD,
    location = "Stonefalls",
    playerLevel = PLAYER_LEVEL_UNKNOWN,
    gear = {
      TGC.DecribeSet( ENV_PVE, ROLE_MAGIC_DPS, { "Valakas" }, {
        [ARMOR_CHEST] = { TRAIT_DIVINE },
        [ARMOR_BELT] = { TRAIT_DIVINE },
        [ARMOR_FEET] = { TRAIT_DIVINE },
        [ARMOR_LEG] = { TRAIT_DIVINE },
        [ARMOR_ARM] = { TRAIT_DIVINE },
        [JEWEL_NECK] = { TRAIT_ARCANE, TRAIT_BLOODTHIRSTY },
        [JEWEL_RING] = { TRAIT_ARCANE, TRAIT_BLOODTHIRSTY },
        [WEAPON_FIRE_STAFF] = { TRAIT_PRECISE, TRAIT_INFUSED },
        [WEAPON_LIGHTNING_STAFF] = { TRAIT_PRECISE, TRAIT_INFUSED }
      } )
    }
  },
  ["Sithis' Touch"] = {
    type = SET_TYPE_OVERWORLD,
    location = "The Gold Coast",
    playerLevel = PLAYER_LEVEL_UNKNOWN,
    isTrash = true
  },
  ["Skooma Smuggler"] = {
    type = SET_TYPE_OVERWORLD,
    location = "Reaper's March",
    playerLevel = PLAYER_LEVEL_UNKNOWN,
    isTrash = true
  },
  ["Spell Power Cure"] = {
    type = SET_TYPE_DUNGEON,
    location = "White-Gold Tower",
    playerLevel = PLAYER_LEVEL_UNKNOWN,
    gear = {
      TGC.DecribeSet( ENV_PVE, ROLE_HEALER, { "Obsidian", "Illusion", "Surge", "Reliever", "Blossom" }, {
        [ARMOR_CHEST] = { TRAIT_INFUSED },
        [ARMOR_BELT] = { TRAIT_DIVINE },
        [ARMOR_FEET] = { TRAIT_DIVINE },
        [ARMOR_LEG] = { TRAIT_INFUSED },
        [ARMOR_ARM] = { TRAIT_DIVINE },
        [JEWEL_NECK] = { TRAIT_ARCANE },
        [JEWEL_RING] = { TRAIT_ARCANE },
        [WEAPON_HEALING_STAFF] = { TRAIT_POWERED },
        [WEAPON_LIGHTNING_STAFF] = { TRAIT_CHARGED }
      } ),
      TGC.DecribeSet( ENV_PVE, ROLE_TANK, { "Darkness" }, {
        [JEWEL_NECK] = { TRAIT_ARCANE },
        [JEWEL_RING] = { TRAIT_ARCANE },
        [WEAPON_SWORD] = {
          traits = { TRAIT_INFUSED },
          count = 2,
          options = {
            WEAPON_AXE,
            WEAPON_HAMMER,
            WEAPON_DAGGER,
          }
        },
        [ARMOR_SHIELD] = {
          traits = { TRAIT_STURDY },
          count = 2,
        }
      } )
    }
  },
  ["Spell Strategist"] = {
    type = SET_TYPE_PVP,
    location = "Cyrodiil",
    playerLevel = PLAYER_LEVEL_UNKNOWN,
    gear = {
      TGC.DecribeSet( ENV_PVE, ROLE_MAGIC_DPS, { "Valakas", "Azure", "Ice & Fire", "Beamplar" }, {
        [ARMOR_CHEST] = { TRAIT_DIVINE },
        [ARMOR_BELT] = { TRAIT_DIVINE },
        [ARMOR_FEET] = { TRAIT_DIVINE },
        [ARMOR_LEG] = { TRAIT_DIVINE },
        [ARMOR_ARM] = { TRAIT_DIVINE },
        [JEWEL_NECK] = { TRAIT_ARCANE, TRAIT_BLOODTHIRSTY },
        [JEWEL_RING] = { TRAIT_ARCANE, TRAIT_BLOODTHIRSTY },
        [WEAPON_FIRE_STAFF] = { TRAIT_PRECISE, TRAIT_INFUSED },
        [WEAPON_LIGHTNING_STAFF] = { TRAIT_PRECISE, TRAIT_INFUSED }
      } )
    }
  },
  ["Spider Cultist Cowl"] = {
    type = SET_TYPE_DUNGEON,
    location = "Fungal Grotto",
    playerLevel = PLAYER_LEVEL_UNKNOWN,
    isTrash = true
  },
  ["Spinner's Garments"] = {
    type = SET_TYPE_OVERWORLD,
    location = "Malabal Tor",
    playerLevel = PLAYER_LEVEL_UNKNOWN,
    gear = {
      TGC.DecribeSet( ENV_PVE, ROLE_MAGIC_DPS, { "Valakas", "Caluurion", "Ice & Fire" }, {
        [ARMOR_CHEST] = { TRAIT_DIVINE },
        [ARMOR_BELT] = { TRAIT_DIVINE },
        [ARMOR_FEET] = { TRAIT_DIVINE },
        [ARMOR_LEG] = { TRAIT_DIVINE },
        [ARMOR_ARM] = { TRAIT_DIVINE },
        [JEWEL_NECK] = { TRAIT_ARCANE, TRAIT_BLOODTHIRSTY },
        [JEWEL_RING] = { TRAIT_ARCANE, TRAIT_BLOODTHIRSTY },
        [WEAPON_FIRE_STAFF] = { TRAIT_PRECISE, TRAIT_INFUSED },
        [WEAPON_LIGHTNING_STAFF] = { TRAIT_PRECISE, TRAIT_INFUSED }
      } ),
      TGC.DecribeSet( ENV_PVP, ROLE_MAGIC_DPS, { "Bomb" }, {
        [ARMOR_CHEST] = { TRAIT_INFUSED },
        [ARMOR_BELT] = { TRAIT_DIVINE },
        [ARMOR_FEET] = { TRAIT_DIVINE },
        [ARMOR_LEG] = { TRAIT_INFUSED },
        [ARMOR_ARM] = { TRAIT_DIVINE },
        [JEWEL_NECK] = { TRAIT_ARCANE, TRAIT_INFUSED },
        [JEWEL_RING] = { TRAIT_ARCANE, TRAIT_INFUSED },
        [WEAPON_HEALING_STAFF] = { TRAIT_INFUSED },
        [WEAPON_SWORD] = {
          traits = { TRAIT_NIRNHONED, TRAIT_SHARPENED },
          count = 2,
          options = {
            WEAPON_AXE,
            WEAPON_HAMMER,
            WEAPON_DAGGER,
          }
        },
      } )
    }
  },
  ["Stendarr's Embrace"] = {
    type = SET_TYPE_OVERWORLD,
    location = "Eastmarch",
    playerLevel = PLAYER_LEVEL_UNKNOWN,
    isTrash = true
  },
  ["Syrabane's Grip"] = {
    type = SET_TYPE_OVERWORLD,
    location = "Grahtwood",
    playerLevel = PLAYER_LEVEL_UNKNOWN,
    isTrash = true
  },
  ["Syvarra's Scales"] = {
    type = SET_TYPE_OVERWORLD,
    location = "Hew's Bane",
    playerLevel = PLAYER_LEVEL_UNKNOWN,
    isTrash = true
  },
  ["The Arch-Mage"] = {
    type = SET_TYPE_PVP,
    location = "Cyrodiil",
    playerLevel = PLAYER_LEVEL_UNKNOWN,
    isTrash = true
  },
  ["The Worm's Raiment"] = {
    type = SET_TYPE_DUNGEON,
    location = "Vaults of Madness",
    playerLevel = PLAYER_LEVEL_UNKNOWN,
    gear = {
      TGC.DecribeSet( ENV_PVE, ROLE_HEALER, { "Obsidian", "Illusion", "Surge", "Reliever", "Blossom" }, {
        [ARMOR_CHEST] = { TRAIT_INFUSED },
        [ARMOR_BELT] = { TRAIT_DIVINE },
        [ARMOR_FEET] = { TRAIT_DIVINE },
        [ARMOR_LEG] = { TRAIT_INFUSED },
        [ARMOR_ARM] = { TRAIT_DIVINE },
        [JEWEL_NECK] = { TRAIT_ARCANE },
        [JEWEL_RING] = { TRAIT_ARCANE },
        [WEAPON_HEALING_STAFF] = { TRAIT_POWERED },
        [WEAPON_LIGHTNING_STAFF] = { TRAIT_CHARGED }
      } )
    }
  },
  ["Treasure Hunter"] = {
    type = SET_TYPE_DUNGEON,
    location = "Volenfell",
    playerLevel = PLAYER_LEVEL_UNKNOWN,
    isTrash = true
  },
  ["Trinimac's Valor"] = {
    type = SET_TYPE_OVERWORLD,
    location = "Wrothgar",
    playerLevel = PLAYER_LEVEL_UNKNOWN,
    isTrash = true
  },
  ["Twilight Remedy"] = {
    type = SET_TYPE_TRIAL,
    location = "Maw of Lorkhaj",
    playerLevel = PLAYER_LEVEL_UNKNOWN,
    isTrash = true
  },
  ["Undaunted Unweaver"] = {
    type = SET_TYPE_DUNGEON,
    location = "Blackheart Haven",
    playerLevel = PLAYER_LEVEL_UNKNOWN,
    isTrash = true
  },
  ["Vampire Lord"] = {
    type = SET_TYPE_OVERWORLD,
    location = "Bangkorai",
    playerLevel = PLAYER_LEVEL_UNKNOWN,
    isTrash = true
  },
  ["Vestment of Olorime"] = {
    type = SET_TYPE_TRIAL,
    location = "Cloudrest",
    playerLevel = PLAYER_LEVEL_UNKNOWN,
    gear = {
      TGC.DecribeSet( ENV_PVE, ROLE_HEALER, { "Obsidian", "Illusion", "Surge", "Reliever", "Blossom" }, {
        [ARMOR_CHEST] = { TRAIT_INFUSED },
        [ARMOR_BELT] = { TRAIT_DIVINE },
        [ARMOR_FEET] = { TRAIT_DIVINE },
        [ARMOR_LEG] = { TRAIT_INFUSED },
        [ARMOR_ARM] = { TRAIT_DIVINE },
        [JEWEL_NECK] = { TRAIT_ARCANE },
        [JEWEL_RING] = { TRAIT_ARCANE },
        [WEAPON_HEALING_STAFF] = { TRAIT_POWERED },
        [WEAPON_LIGHTNING_STAFF] = { TRAIT_CHARGED }
      } )
    }
  },
  ["Vestments of the Warlock"] = {
    type = SET_TYPE_DUNGEON,
    location = "Selene's Web",
    playerLevel = PLAYER_LEVEL_UNKNOWN,
    isTrash = true
  },
  ["Vicious Death"] = {
    type = SET_TYPE_PVP,
    location = "Cyrodiil",
    playerLevel = PLAYER_LEVEL_UNKNOWN,
    gear = {
      TGC.DecribeSet( ENV_PVP, ROLE_MAGIC_DPS, { "Bomb" }, {
        [ARMOR_CHEST] = { TRAIT_INFUSED },
        [ARMOR_BELT] = { TRAIT_DIVINE },
        [ARMOR_FEET] = { TRAIT_DIVINE },
        [ARMOR_LEG] = { TRAIT_INFUSED },
        [ARMOR_ARM] = { TRAIT_DIVINE },
        [JEWEL_NECK] = { TRAIT_ARCANE, TRAIT_INFUSED },
        [JEWEL_RING] = { TRAIT_ARCANE, TRAIT_INFUSED },
        [WEAPON_HEALING_STAFF] = { TRAIT_INFUSED },
        [WEAPON_SWORD] = {
          traits = { TRAIT_NIRNHONED, TRAIT_SHARPENED },
          count = 2,
          options = {
            WEAPON_AXE,
            WEAPON_HAMMER,
            WEAPON_DAGGER,
          }
        },
      } ),
      TGC.DecribeSet( ENV_PVP, ROLE_STAMINA_DPS, { "Hammer of Justice" }, {
        [ARMOR_BELT] = { TRAIT_DIVINE },
        [JEWEL_NECK] = { TRAIT_ARCANE, TRAIT_INFUSED },
        [JEWEL_RING] = { TRAIT_ARCANE, TRAIT_INFUSED },
        [WEAPON_TWOHAND_SWORD] = {
          traits = { TRAIT_NIRNHONED },
          options = {
            WEAPON_TWOHAND_AXE,
            WEAPON_TWOHAND_HAMMER
          }
        },
        [WEAPON_SWORD] = {
          traits = { TRAIT_SHARPENED },
          count = 2,
          options = {
            WEAPON_AXE,
            WEAPON_HAMMER,
            WEAPON_DAGGER,
          }
        },
      } )
    }
  },
  ["War Maiden"] = {
    type = SET_TYPE_OVERWORLD,
    location = "Vvardenfell",
    playerLevel = PLAYER_LEVEL_UNKNOWN,
    gear = {
      TGC.DecribeSet( ENV_PVP, ROLE_MAGIC_DPS, { "Bomb" }, {
        [ARMOR_CHEST] = { TRAIT_INFUSED },
        [ARMOR_BELT] = { TRAIT_DIVINE },
        [ARMOR_FEET] = { TRAIT_DIVINE },
        [ARMOR_LEG] = { TRAIT_INFUSED },
        [ARMOR_ARM] = { TRAIT_DIVINE },
        [JEWEL_NECK] = { TRAIT_ARCANE, TRAIT_INFUSED },
        [JEWEL_RING] = { TRAIT_ARCANE, TRAIT_INFUSED },
        [WEAPON_HEALING_STAFF] = { TRAIT_INFUSED },
        [WEAPON_SWORD] = {
          traits = { TRAIT_NIRNHONED, TRAIT_SHARPENED },
          count = 2,
          options = {
            WEAPON_AXE,
            WEAPON_HAMMER,
            WEAPON_DAGGER,
          }
        },
      } ),
    }
  },
  ["Way of Martial Knowledge"] = {
    type = SET_TYPE_OVERWORLD,
    location = "Craglorn",
    playerLevel = PLAYER_LEVEL_UNKNOWN,
    isTrash = true
  },
  ["Winterborn"] = {
    type = SET_TYPE_ARENA,
    location = "Maelstrom Arena",
    playerLevel = PLAYER_LEVEL_UNKNOWN,
    isTrash = true
  },
  ["Wisdom of Vanus"] = {
    type = SET_TYPE_OVERWORLD,
    location = "Summerset",
    playerLevel = PLAYER_LEVEL_UNKNOWN,
    isTrash = true
  },
  ["Wise Mage"] = {
    type = SET_TYPE_TRIAL,
    location = "Sanctum Ophidia",
    playerLevel = PLAYER_LEVEL_UNKNOWN,
    isTrash = true
  },
  ["Wizard's Riposte"] = {
    type = SET_TYPE_PVP,
    location = "Battlegrounds",
    playerLevel = PLAYER_LEVEL_UNKNOWN,
    gear = {
      TGC.DecribeSet( ENV_PVP, ROLE_MAGIC_DPS, { "Wrath" }, {
        [ARMOR_CHEST] = { TRAIT_INFUSED },
        [ARMOR_BELT] = { TRAIT_IMPENETRABLE },
        [ARMOR_FEET] = { TRAIT_IMPENETRABLE },
        [ARMOR_LEG] = { TRAIT_INFUSED },
        [ARMOR_ARM] = { TRAIT_IMPENETRABLE },
        [JEWEL_NECK] = { TRAIT_ARCANE },
        [JEWEL_RING] = { TRAIT_ARCANE },
        [WEAPON_FIRE_STAFF] = { TRAIT_INFUSED },
        [WEAPON_HEALING_STAFF] = { TRAIT_INFUSED }
      } )
    }
  },
  ["Ysgramor's Birthright"] = {
    type = SET_TYPE_OVERWORLD,
    location = "The Rift",
    playerLevel = PLAYER_LEVEL_UNKNOWN,
    isTrash = true
  },

  ----MED SETS----------------


  ----HEAVY SETS--------------
  ["Embershield"] = {
    type = SET_TYPE_DUNGEON,
    location = "City of Ash",
    isTrash = true
  },
  ["Sunderflame"] = {
    type = SET_TYPE_DUNGEON,
    location = "City of Ash"
  }
}