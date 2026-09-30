----------------------------------------------------------------------------------------
-- Refined Radial Menu: Shared
-- Description: Shared constants and helper functions for the radial menu components.
----------------------------------------------------------------------------------------

local _, RadialMenu = ...

----------------------------------------------------------------------------------------
-- Lua / WoW Upvalues
----------------------------------------------------------------------------------------
local _G = _G

----------------------------------------------------------------------------------------
-- Constants
----------------------------------------------------------------------------------------
local SUPPORTED_ACTION_TYPES = {
    spell = true,
    item = true,
    macro = true,
    mount = true,
}

----------------------------------------------------------------------------------------
-- Internal Shared State
----------------------------------------------------------------------------------------
local Private = {}
RadialMenu.Private = Private

Private.MEDIA_PATH = [[Interface\AddOns\RefinedRadialMenu\Media\]]
Private.DEFAULT_EMPTY_ICON = 134400
Private.BIND_EMPTY_SLOT_ATLAS = "cdm-empty"
Private.BIND_EMPTY_ICON_SCALE = 1.15
Private.REMOVE_ICON_ATLAS = "common-icon-redx"
Private.REMOVE_ICON_SCALE = 0.7
Private.ICON_TEX_MIN = 0.08
Private.ICON_TEX_MAX = 0.92
Private.ICON_USABLE_R = 1
Private.ICON_USABLE_G = 1
Private.ICON_USABLE_B = 1
Private.ICON_UNUSABLE_R = 1
Private.ICON_UNUSABLE_G = 0.2
Private.ICON_UNUSABLE_B = 0.2
Private.CLICK_BINDING_ACTION = "CLICK RefinedRadialMenuButton:LeftButton"
Private.CORE_FRAME_NAME = "RefinedRadialMenuButton"
Private.SLOT_COUNT = 4
Private.RING_RADIUS = 100
Private.INNER_RADIUS = 35
Private.CENTER_SIZE = 52
Private.SLICE_SIZE = 40
Private.CONTENT_SIZE = 400
Private.ARROW_SIZE = 32
Private.ARROW_RADIUS = 50
Private.TWO_PI = math.pi * 2

----------------------------------------------------------------------------------------
-- Private Helpers
----------------------------------------------------------------------------------------
local function IsSupportedActionType(actionType)
    return _G.type(actionType) == "string" and SUPPORTED_ACTION_TYPES[actionType] or false
end

local function IsPositiveInteger(value)
    return _G.type(value) == "number" and value > 0 and value < math.huge and value == math.floor(value)
end

local function IsNonEmptyString(value)
    return _G.type(value) == "string" and value:find("%S") ~= nil
end

local function GetSlotPrefix(index)
    return index == 0 and "center-" or "child" .. index .. "-"
end

-- Mirrors Core's GetSelection secure snippet.
local function GetSelection(angle, radius, innerRadius, count)
    if radius <= innerRadius or count <= 0 then
        return 0
    end
    local sliceAngle = Private.TWO_PI / count
    return math.floor(((angle + sliceAngle / 2) % Private.TWO_PI) / sliceAngle) + 1
end

local function GetDefaultBorderColor()
    return 0.6, 0.6, 0.6, 1
end

local function GetDefaultMainRing()
    return { Slices = {} }
end

----------------------------------------------------------------------------------------
-- Shared Exports
----------------------------------------------------------------------------------------
Private.IsSupportedActionType = IsSupportedActionType
Private.IsPositiveInteger = IsPositiveInteger
Private.IsNonEmptyString = IsNonEmptyString
Private.GetSlotPrefix = GetSlotPrefix
Private.GetSelection = GetSelection
Private.GetDefaultBorderColor = GetDefaultBorderColor
Private.GetDefaultMainRing = GetDefaultMainRing
