-- Feel free to use this library --
-- but do not modify without sending a pm to me (votan at www.esoui.com) to avoid version conflicts --

-- Register with LibStub
local MAJOR, MINOR = "LibMainMenu-2.0", 4.2
local lib, oldminor = LibStub and LibStub:NewLibrary(MAJOR, MINOR)
if LibStub and not lib then
	return
end -- the same or newer version of this lib is already loaded into memory
lib = lib or {}

local function GetMainMenu()
	return MAIN_MENU_KEYBOARD
end

local function InitMenu()
	GetMainMenu().categoryBarFragment.duration = 250
	EVENT_MANAGER:UnregisterForEvent(MAJOR, EVENT_SECURE_RENDER_MODE_CHANGED)
	EVENT_MANAGER:RegisterForEvent(
		MAJOR,
		EVENT_SECURE_RENDER_MODE_CHANGED,
		function(eventCode, enabled)
			if not enabled and GetMainMenu().lastCategory == MENU_CATEGORY_MARKET then
				GetMainMenu().lastCategory = MENU_CATEGORY_INVENTORY
				ZO_MenuBar_ClearSelection(GetMainMenu().categoryBar)
			end
		end
	)
end

function lib:Init()
	if not lib.initialized then
		lib.initialized = true
		InitMenu()
	end
end

do
	local function AddButton(descriptor, categoryLayoutInfo)
		-- descriptor does not need to be an integer
		categoryLayoutInfo.descriptor = descriptor
		ZO_MenuBar_AddButton(GetMainMenu().categoryBar, categoryLayoutInfo)
	end
	local function AddScene(descriptor, sceneName, categoryLayoutInfo, sceneGroupName)
		local menu = GetMainMenu()
		local subcategoryBar =
			CreateControlFromVirtual("ZO_MainMenuSubcategoryBar", menu.control, "ZO_MainMenuSubcategoryBar", descriptor)
		subcategoryBar:SetAnchor(TOP, menu.categoryBar, BOTTOM, 0, 7)

		-- No animation => instant hide is important, otherwise you get "access private function StopAllMovement" :)
		local subcategoryBarFragment = ZO_FadeSceneFragment:New(subcategoryBar, false, 0)
		local categoryInfo = {
			barControls = {},
			subcategoryBar = subcategoryBar,
			subcategoryBarFragment = subcategoryBarFragment,
			sceneName = sceneName
		}
		menu.categoryInfo[descriptor] = categoryInfo

		-- category must be known => choose a best matching => MENU_CATEGORY_INVENTORY
		local category = MENU_CATEGORY_INVENTORY

		local sceneInfo = {
			category = category,
			sceneName = sceneName,
			sceneGroupName = sceneGroupName
		}
		menu.sceneInfo[sceneName] = sceneInfo

		local scene = SCENE_MANAGER:GetScene(sceneName)
		scene:AddFragment(categoryInfo.subcategoryBarFragment)
		for i, categoryAreaFragment in ipairs(menu.categoryAreaFragments) do
			scene:AddFragment(categoryAreaFragment)
		end

		scene:RegisterCallback(
			"StateChange",
			function(oldState, newState)
				if newState == SCENE_SHOWING then
					menu.ignoreCallbacks = true

					local skipAnimation = not menu:IsShowing()
					ZO_MenuBar_SelectDescriptor(menu.categoryBar, descriptor, skipAnimation)
					menu.lastCategory = category

					if sceneGroupName then
						local sceneGroup = SCENE_MANAGER:GetSceneGroup(sceneGroupName)
						sceneGroup:SetActiveScene(sceneName)
					else
						menu:SetLastSceneName(categoryInfo, sceneName)
					end

					menu.ignoreCallbacks = false
				end
			end
		)
	end
	local function AddButtonWithScene(descriptor, sceneName, categoryLayoutInfo, sceneGroupName)
		AddButton(descriptor, categoryLayoutInfo)
		AddScene(descriptor, sceneName, categoryLayoutInfo, sceneGroupName)
	end
	function lib:AddMenuItem(a, b, c, d)
		if c then
			AddButtonWithScene(a, b, c, d)
		else
			AddButton(a, b)
		end
	end
end

function lib:SelectMenuItem(descriptor)
	if WINDOW_MANAGER:IsSecureRenderModeEnabled() then
		return
	end

	local categoryInfo = GetMainMenu().categoryInfo[descriptor]
	assert(categoryInfo ~= nil, "descriptor not found")

	local button = GetMainMenu().categoryBar.m_object:ButtonObjectForDescriptor(descriptor)
	if button == nil then
		return
	end
	local buttonData = button.m_buttonData

	local visible = buttonData.visible
	visible = visible ~= nil and visible(buttonData) or (visible == nil)

	if visible then
		if ZO_MenuBar_GetSelectedDescriptor(GetMainMenu().categoryBar) == descriptor then
			if buttonData.callback then
				buttonData.callback(buttonData)
			end
		else
			ZO_MenuBar_SelectDescriptor(GetMainMenu().categoryBar, descriptor, true)
		end
	else
		ZO_MenuBar_ClearSelection(GetMainMenu().categoryBar)
		if buttonData.callback then
			buttonData.callback(buttonData)
		end
	end
end

function lib:Refresh()
	ZO_MenuBar_UpdateButtons(GetMainMenu().categoryBar)
end

LibMainMenu2 = lib
