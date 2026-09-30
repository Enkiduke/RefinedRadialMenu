----------------------------------------------------------------------------------------
-- Refined Radial Menu: Style
-- Description: Nine-slice border, glow, and pulse helpers for addon-owned slot buttons.
----------------------------------------------------------------------------------------

local _, RadialMenu = ...

local Private = RadialMenu.Private
local CreateFrame = CreateFrame
local floor = math.floor
local max = math.max
local pairs = pairs

----------------------------------------------------------------------------------------
-- Constants
----------------------------------------------------------------------------------------
local BORDER_FILE = Private.MEDIA_PATH .. "RefineBorder.blp"
local GLOW_FILE = Private.MEDIA_PATH .. "RefineGlow2.blp"
local GLOW_OFFSET = 2
local COORD_START = 0.0625
local PIECE_ORDER = {
    "TopLeftCorner", "TopRightCorner", "BottomLeftCorner", "BottomRightCorner",
    "TopEdge", "BottomEdge", "LeftEdge", "RightEdge",
}
-- ULx, ULy, LLx, LLy, URx, URy, LRx, LRy; "x"/"y" resolve to the repeat counts.
local PIECE_UVS = {
    TopLeftCorner = { 0.5078125, COORD_START, 0.5078125, 0.9375, 0.6171875, COORD_START, 0.6171875, 0.9375 },
    TopRightCorner = { 0.6328125, COORD_START, 0.6328125, 0.9375, 0.7421875, COORD_START, 0.7421875, 0.9375 },
    BottomLeftCorner = { 0.7578125, COORD_START, 0.7578125, 0.9375, 0.8671875, COORD_START, 0.8671875, 0.9375 },
    BottomRightCorner = { 0.8828125, COORD_START, 0.8828125, 0.9375, 0.9921875, COORD_START, 0.9921875, 0.9375 },
    TopEdge = { 0.2578125, "x", 0.3671875, "x", 0.2578125, COORD_START, 0.3671875, COORD_START },
    BottomEdge = { 0.3828125, "x", 0.4921875, "x", 0.3828125, COORD_START, 0.4921875, COORD_START },
    LeftEdge = { 0.0078125, COORD_START, 0.0078125, "y", 0.1171875, COORD_START, 0.1171875, "y" },
    RightEdge = { 0.1328125, COORD_START, 0.1328125, "y", 0.2421875, COORD_START, 0.2421875, "y" },
}

----------------------------------------------------------------------------------------
-- Private Helpers
----------------------------------------------------------------------------------------
local repeatX, repeatY = 0, 0

local function Resolve(value)
    if value == "x" then return repeatX end
    if value == "y" then return repeatY end
    return value
end

local function UpdateTexCoords(frame)
    local edgeSize = frame.EdgeSize
    local scale = frame:GetEffectiveScale()
    repeatX = max(0, (frame:GetWidth() / edgeSize) * scale - 2 - COORD_START)
    repeatY = max(0, (frame:GetHeight() / edgeSize) * scale - 2 - COORD_START)
    for name, uv in pairs(PIECE_UVS) do
        frame[name]:SetTexCoord(Resolve(uv[1]), Resolve(uv[2]), Resolve(uv[3]), Resolve(uv[4]),
            Resolve(uv[5]), Resolve(uv[6]), Resolve(uv[7]), Resolve(uv[8]))
    end
end

local function BuildPieces(frame, textureFile, blendMode, edgeSize)
    frame.EdgeSize = edgeSize
    frame.Pieces = {}
    for i = 1, #PIECE_ORDER do
        local tex = frame:CreateTexture(nil, "OVERLAY", nil, 7)
        tex:SetBlendMode(blendMode)
        tex:SetTexture(textureFile, true, true)
        frame[PIECE_ORDER[i]] = tex
        frame.Pieces[i] = tex
    end

    local tl, tr = frame.TopLeftCorner, frame.TopRightCorner
    local bl, br = frame.BottomLeftCorner, frame.BottomRightCorner
    tl:SetPoint("TOPLEFT")
    tr:SetPoint("TOPRIGHT")
    bl:SetPoint("BOTTOMLEFT")
    br:SetPoint("BOTTOMRIGHT")
    tl:SetSize(edgeSize, edgeSize)
    tr:SetSize(edgeSize, edgeSize)
    bl:SetSize(edgeSize, edgeSize)
    br:SetSize(edgeSize, edgeSize)

    frame.TopEdge:SetPoint("TOPLEFT", tl, "TOPRIGHT")
    frame.TopEdge:SetPoint("TOPRIGHT", tr, "TOPLEFT")
    frame.TopEdge:SetHeight(edgeSize)
    frame.BottomEdge:SetPoint("BOTTOMLEFT", bl, "BOTTOMRIGHT")
    frame.BottomEdge:SetPoint("BOTTOMRIGHT", br, "BOTTOMLEFT")
    frame.BottomEdge:SetHeight(edgeSize)
    frame.LeftEdge:SetPoint("TOPLEFT", tl, "BOTTOMLEFT")
    frame.LeftEdge:SetPoint("BOTTOMLEFT", bl, "TOPLEFT")
    frame.LeftEdge:SetWidth(edgeSize)
    frame.RightEdge:SetPoint("TOPRIGHT", tr, "BOTTOMRIGHT")
    frame.RightEdge:SetPoint("BOTTOMRIGHT", br, "TOPRIGHT")
    frame.RightEdge:SetWidth(edgeSize)

    frame:SetScript("OnSizeChanged", UpdateTexCoords)
    frame:HookScript("OnShow", UpdateTexCoords)
    UpdateTexCoords(frame)
end

----------------------------------------------------------------------------------------
-- Public Helpers
----------------------------------------------------------------------------------------
function Private.SetBorderColor(frame, r, g, b, a)
    for i = 1, #frame.Pieces do
        frame.Pieces[i]:SetVertexColor(r, g, b, a or 1)
    end
end

function Private.CreateBorder(owner, inset, edgeSize)
    local border = CreateFrame("Frame", nil, owner)
    border:SetPoint("TOPLEFT", owner, "TOPLEFT", -inset, inset)
    border:SetPoint("BOTTOMRIGHT", owner, "BOTTOMRIGHT", inset, -inset)
    border:SetFrameLevel(owner:GetFrameLevel() + 1)
    border:EnableMouse(false)
    BuildPieces(border, BORDER_FILE, "BLEND", edgeSize)
    Private.SetBorderColor(border, Private.GetDefaultBorderColor())
    owner.Border = border
    return border
end

function Private.CreateGlow(owner)
    local border = owner.Border
    local scale = border:GetEffectiveScale()
    local offset = scale > 0 and floor(GLOW_OFFSET * scale + 0.5) / scale or GLOW_OFFSET
    local glow = CreateFrame("Frame", nil, owner)
    glow:SetFrameLevel(max(0, border:GetFrameLevel() - 1))
    glow:SetPoint("TOPLEFT", border, "TOPLEFT", -offset, offset)
    glow:SetPoint("BOTTOMRIGHT", border, "BOTTOMRIGHT", offset, -offset)
    BuildPieces(glow, GLOW_FILE, "ADD", border.EdgeSize)
    Private.SetBorderColor(glow, 1, 0.82, 0, 1)
    glow:Hide()
    owner.Glow = glow
    return glow
end

function Private.CreatePulse(frame, from, to, duration)
    local animGroup = frame:CreateAnimationGroup()
    animGroup:SetLooping("BOUNCE")
    local alpha = animGroup:CreateAnimation("Alpha")
    alpha:SetFromAlpha(from)
    alpha:SetToAlpha(to)
    alpha:SetDuration(duration)
    alpha:SetSmoothing("IN_OUT")
    frame.PulseAnim = animGroup
    return animGroup
end
