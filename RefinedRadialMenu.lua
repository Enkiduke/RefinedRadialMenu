----------------------------------------------------------------------------------------
-- Refined Radial Menu
-- Description: Absolute-Strata Secure Action Bar with Macro-based Execution
----------------------------------------------------------------------------------------

local _, RadialMenu = ...

----------------------------------------------------------------------------------------
-- Lua / WoW Upvalues
----------------------------------------------------------------------------------------
local InCombatLockdown = InCombatLockdown
local GetBindingKey = GetBindingKey
local GetBindingAction = GetBindingAction
local SetBinding = SetBinding
local SaveBindings = SaveBindings
local GetCurrentBindingSet = GetCurrentBindingSet

local Private = RadialMenu.Private

----------------------------------------------------------------------------------------
-- Binding Labels
----------------------------------------------------------------------------------------
_G.BINDING_HEADER_REFINEDRADIALMENU = "Refined Radial Menu"
_G["BINDING_NAME_" .. Private.CLICK_BINDING_ACTION] = "Open Radial Menu"

----------------------------------------------------------------------------------------
-- Constants
----------------------------------------------------------------------------------------
local EVENTS = {
    "CURSOR_CHANGED",
    "ACTIONBAR_SHOWGRID",
    "ACTIONBAR_HIDEGRID",
    "PLAYER_REGEN_ENABLED",
    "UPDATE_MACROS",
}

----------------------------------------------------------------------------------------
-- Public Methods
----------------------------------------------------------------------------------------
function RadialMenu:Print(...)
    print("|cffffd200Refined|r Radial Menu:", ...)
end

function RadialMenu:ResetMainRing()
    if InCombatLockdown() then
        self._pendingResetMainRing = true
        self:Print("Reset queued until combat ends.")
        return
    end

    self.db.Rings.Main = Private.GetDefaultMainRing()

    if self.Core then
        self:BuildRing("Main")
    end
    self:Print("Reset.")
end

function RadialMenu:HandleSlash(msg)
    msg = (msg or ""):lower():match("^%s*(.-)%s*$")

    if msg == "reset" then
        self:ResetMainRing()
        return
    end

    if InCombatLockdown() then
        self._pendingToggle = not self._pendingToggle
        self:Print("Toggle queued until combat ends.")
        return
    end

    if not self.Core then
        return
    end

    if self.mode ~= "closed" then
        self:CloseRing()
    elseif Private.IsSupportedActionType(GetCursorInfo()) then
        self:CURSOR_CHANGED()
    else
        self:OpenRing()
    end
end

function RadialMenu:HandleEvent(event, ...)
    if self[event] then
        self[event](self, ...)
    end
end

----------------------------------------------------------------------------------------
-- Lifecycle
----------------------------------------------------------------------------------------
function RadialMenu:OnInitialize()
    local bindingAction = Private.CLICK_BINDING_ACTION

    local db = RefinedRadialMenuDB or {}
    RefinedRadialMenuDB = db
    db.Rings = type(db.Rings) == "table" and db.Rings or {}
    if type(db.Rings.Main) ~= "table" then
        db.Rings.Main = Private.GetDefaultMainRing()
    end
    self.db = db

    self.Buttons = {}

    -- Default Bind (only if not set)
    if not InCombatLockdown() and not GetBindingKey(bindingAction) then
        local f8Binding = GetBindingAction("F8")
        if not f8Binding or f8Binding == "" then
            SetBinding("F8", bindingAction)
            SaveBindings(GetCurrentBindingSet())
        end
    end

    SLASH_REFINEDRADIALMENU1 = "/radial"
    SLASH_REFINEDRADIALMENU2 = "/rrm"
    SlashCmdList.REFINEDRADIALMENU = function(msg)
        RadialMenu:HandleSlash(msg)
    end
end

function RadialMenu:OnEnable()
    self:SetupCore()
    self:SetupVisuals()
    self:BuildRing("Main")

    local eventFrame = CreateFrame("Frame")
    for _, event in ipairs(EVENTS) do
        eventFrame:RegisterEvent(event)
    end
    eventFrame:SetScript("OnEvent", function(_, event, ...)
        RadialMenu:HandleEvent(event, ...)
    end)
    self:CURSOR_CHANGED()
end

function RadialMenu:PLAYER_REGEN_ENABLED()
    local pendingRing = self._pendingBuildRing
    self._pendingBuildRing = nil
    if self._pendingResetMainRing then
        self._pendingResetMainRing = nil
        self:ResetMainRing()
    elseif pendingRing then
        self:BuildRing(pendingRing)
    end

    -- Cursor/grid events can arrive during lockdown; reconcile current state now.
    self:CURSOR_CHANGED()

    if self._pendingToggle then
        self._pendingToggle = nil
        self:HandleSlash("")
    end
end

function RadialMenu:UPDATE_MACROS()
    self:BuildRing(self.activeRing or "Main")
end

----------------------------------------------------------------------------------------
-- Startup
----------------------------------------------------------------------------------------
local loader = CreateFrame("Frame")
loader:RegisterEvent("PLAYER_LOGIN")
loader:SetScript("OnEvent", function(self)
    self:UnregisterEvent("PLAYER_LOGIN")
    RadialMenu:OnInitialize()
    RadialMenu:OnEnable()
end)
