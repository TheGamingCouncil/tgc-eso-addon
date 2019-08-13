local sceneName = "tgcGuildMenu"
local descriptor = "tgcGuildMenu"
local listData = nil

function TGC.SetGuildTabHook( LMM2 )

  TGC.GuildTabCreateScene()
 
  -- Add to main menu
  local categoryLayoutInfo =
  {
      binding = "TGC_GUILD_MENU",
      categoryName = SI_BINDING_NAME_TGC_GUILD_MENU,
      callback = function(buttonData)
          if not SCENE_MANAGER:IsShowing(sceneName) then
              SCENE_MANAGER:Show(sceneName)
          else
              SCENE_MANAGER:ShowBaseScene()
          end

          listData:RefreshData()
      end,
      visible = function(buttonData) return true end,
  
      normal = "esoui/art/journal/journal_tabicon_achievements_up.dds",
      pressed = "esoui/art/journal/journal_tabicon_achievements_down.dds",
      highlight = "esoui/art/journal/journal_tabicon_achievements_over.dds",
      disabled = "esoui/art/journal/journal_tabicon_achievements_disabled.dds",
  }

  local leaderboards = {
    activeTabText = SI_BINDING_NAME_TGC_GUILD_MENU_LEADERBOARD,
    categoryName = SI_BINDING_NAME_TGC_GUILD_MENU_LEADERBOARD,
    descriptor = "recruitmentLeaderboards",
    normal = "esoui/art/campaign/campaign_tabicon_leaderboard_up.dds",
    pressed = "esoui/art/campaign/campaign_tabicon_leaderboard_down.dds",
    highlight = "esoui/art/campaign/campaign_tabicon_leaderboard_over.dds",
    disabled = "esoui/art/campaign/campaign_tabicon_leaderboard_down.dds",
    callback = function()
      if SCENE_MANAGER:IsShowing(sceneName) then
        --TgcGuildMenuLeaderboard.title:SetText("test")
      end
    end,
  }

  local modeBar = TgcGuildMenu:GetNamedChild("ModeMenuBar")
  ZO_MenuBar_AddButton(modeBar, leaderboards)
  
  LMM2:AddMenuItem(descriptor, sceneName, categoryLayoutInfo, nil)

  listData = guildRecruitLeaderboardList:New(TgcGuildMenuLeaderboard)
  
end


function TGC.GuildTabCreateScene()

  TGCGUILDMENU_SCENE = ZO_Scene:New(sceneName, SCENE_MANAGER)

	TGCGUILDMENU_SCENE:AddFragmentGroup(FRAGMENT_GROUP.MOUSE_DRIVEN_UI_WINDOW)
	TGCGUILDMENU_SCENE:AddFragment(RIGHT_PANEL_BG_FRAGMENT)

	TGCGUILDMENU_SCENE:AddFragment(FRAME_EMOTE_FRAGMENT_MAP)
	TGCGUILDMENU_SCENE:AddFragment(ZO_WindowSoundFragment:New(SOUNDS.ALCHEMY_OPENED, SOUNDS.ALCHEMY_CLOSED))

	TGCGUILDMENU_FRAGMENT = ZO_FadeSceneFragment:New(TgcGuildMenu, false, 0)
  TGCGUILDMENU_FRAGMENT:RegisterCallback("StateChange", function(oldState, newState)
    
  end )

  TGCGUILDMENU_SCENE:AddFragment(TGCGUILDMENU_FRAGMENT)

	SCENE_MANAGER:AddSceneGroup("TgcGuildMenuSceneGroup", ZO_SceneGroup:New(descriptor))
  
end

guildRecruitLeaderboardList = ZO_SortFilterList:Subclass()

function guildRecruitLeaderboardList:New(control)
    
  ZO_SortFilterList.InitializeSortFilterList(self, control)
  
  local sorterKeys =
  {
      ["playername"] = {},
      ["thisweek"] = {isNumeric = true}, -- the default column.
      ["lastweek"] = {isNumeric = true},
  }
  
  self.masterList = {}
  ZO_ScrollList_AddDataType(self.list, 1, "GuildRecruitLeaderboardRowTemplate", 32, function(control, data) self:SetupEntry(control, data) end)
  ZO_ScrollList_EnableHighlight(self.list, "ZO_ThinListHighlight")
  self.currentSortKey = "thisweek"
  self.sortFunction = function(listEntry1, listEntry2) return ZO_TableOrderingFunction(listEntry1.data, listEntry2.data, self.currentSortKey, sorterKeys, self.currentSortOrder) end
  --self:SetAlternateRowBackgrounds(true)
  
  return self
  
end

function guildRecruitLeaderboardList:SetupEntry(control, data)
  control.data = data
  control.playername = GetControl(control, "PlayerName")
  control.thisweek = GetControl(control, "ThisWeek")
  control.lastweek = GetControl(control, "LastWeek")
  
  -- You can reformat how ever you want.

  control.playername:SetText(data.playername)
  control.thisweek:SetText(data.thisweek)
  control.lastweek:SetText(data.lastweek)
  
  ZO_SortFilterList.SetupRow(self, control, data)
  
end

function guildRecruitLeaderboardList:BuildMasterList()
  self.masterList = {}

  local trimList = {}
  local maxSecondsLast = 60 * 60 * 24 * 7 * 3
  --trim saved list
  for k, v in ipairs(TGC.rosterDb.invitedHistory) do 
    if TGC.rosterDb.invitedHistory[k].timeStamp > GetTimeStamp() - maxSecondsLast then
      table.insert( trimList, TGC.rosterDb.invitedHistory[k] )
    end
  end

  --TGC.rosterDb.invitedHistory = trimList

  local currentDateTime = os.date("!*t")
  --each set is from wday 2 - hour 6 
  local day = 60 * 60 * 24
  local currentDayStart = os.time({year=currentDateTime.year, month=currentDateTime.month, day=currentDateTime.day, hour=6, minute=0})
  local endOfCurrentWeek = 0
  if currentDateTime.wday == 2 then
    if( currentDateTime.hour < 6 ) then
      endOfCurrentWeek = currentDayStart
    else
      endOfCurrentWeek = currentDayStart + ( day * 7 )
    end
  elseif currentDateTime.wday == 1 then
    endOfCurrentWeek = currentDayStart + day
  else
    endOfCurrentWeek = currentDayStart + ( day * ( 7 - ( currentDateTime.wday - 2 ) ) )
  end

  local startOfCurrentWeek = endOfCurrentWeek - ( day * 7 )
  local startOfLastWeek = endOfCurrentWeek - ( day * 14 )

  local dropListCW = {}
  local dropListLW = {}
  for k, v in pairs(TGC.rosterDb.priorMembers) do
    if TGC.rosterDb.priorMembers[k].eventType == 8 and TGC.rosterDb.priorMembers[k].member ~= nil then
      local gmtTimeStamp = os.time( os.date("!*t", TGC.rosterDb.priorMembers[k].timeStamp ) )
      if gmtTimeStamp > startOfCurrentWeek then
        dropListCW[TGC.rosterDb.priorMembers[k].member] = true
      elseif gmtTimeStamp > startOfLastWeek then
        dropListLW[TGC.rosterDb.priorMembers[k].member] = true
      end
    end
  end

  local playerList = {}

  for k, v in ipairs(TGC.rosterDb.invitedHistory) do

    local gmtTimeStamp = os.time( os.date("!*t", TGC.rosterDb.invitedHistory[k].timeStamp ) )
    if gmtTimeStamp > startOfCurrentWeek and dropListCW[TGC.rosterDb.invitedHistory[k].invitee] == nil then
      if playerList[TGC.rosterDb.invitedHistory[k].member] == nil then
        playerList[TGC.rosterDb.invitedHistory[k].member] = { thisweek = 0, lastweek = 0 }
      end
      playerList[TGC.rosterDb.invitedHistory[k].member].thisweek = playerList[TGC.rosterDb.invitedHistory[k].member].thisweek + 1
    elseif gmtTimeStamp > startOfLastWeek and dropListLW[TGC.rosterDb.invitedHistory[k].invitee] == nil then
      if playerList[TGC.rosterDb.invitedHistory[k].member] == nil then
        playerList[TGC.rosterDb.invitedHistory[k].member] = { thisweek = 0, lastweek = 0 }
      end
      playerList[TGC.rosterDb.invitedHistory[k].member].lastweek = playerList[TGC.rosterDb.invitedHistory[k].member].lastweek + 1
    end
  end

  for k, v in pairs(playerList) do
    table.insert(self.masterList, { playername = k, thisweek = v.thisweek, lastweek = v.lastweek } )
  end

  --local killingBlows = db.KillingBlowList -- My SV
  --if killingBlows then
    --for k, v in ipairs(killingBlows) do
    --  local data = v
      --table.insert(self.masterList, { playername = "@alexdragian", thisweek = 5, lastweek = 10 } )
      --table.insert(self.masterList, { playername = "@arc", thisweek = 2, lastweek = 3 } )
      --table.insert(self.masterList, { playername = "@chance", thisweek = -5002, lastweek = -303 } )
    --end
  --end
  
end

function guildRecruitLeaderboardList:SortScrollList()
  local scrollData = ZO_ScrollList_GetDataList(self.list)
  table.sort(scrollData, self.sortFunction)
end

function guildRecruitLeaderboardList:FilterScrollList()
  local scrollData = ZO_ScrollList_GetDataList(self.list)
  ZO_ClearNumericallyIndexedTable(scrollData)

  for i = 1, #self.masterList do
    local data = self.masterList[i]
    table.insert(scrollData, ZO_ScrollList_CreateDataEntry(1, data))
  end
end

function guildRecruitLeaderboardListMouseEnter(control)
	listData:Row_OnMouseEnter(control)
end

function guildRecruitLeaderboardListMouseExit(control)
	listData:Row_OnMouseExit(control)
end

function guildRecruitLeaderboardListMouseUp(control, button, upInside)
	d("something something")
end