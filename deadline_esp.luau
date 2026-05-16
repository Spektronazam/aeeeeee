--!optimize 2
--!native
-- Deadline ESP + Chams | Made By: vana0x1
-- Improved version: same behavior, faster hot loop, leak-free.

local Players          = game:GetService("Players")
local Workspace        = game:GetService("Workspace")
local RunService       = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local Camera      = Workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer
local CharFolder  = Workspace:WaitForChild("characters")

-- ===== Config =================================================================
local CONFIG = {
    BoxColor        = Color3.fromRGB(0,   255, 255), -- Cyan
    NameColor       = Color3.fromRGB(255, 255, 100), -- Yellow
    TracerColor     = Color3.fromRGB(255, 0,   0),   -- Red
    ChamsFill       = Color3.fromRGB(255, 165, 0),   -- Orange
    ChamsOutline    = Color3.fromRGB(255, 200, 0),

    BoxThickness    = 1,
    TracerThickness = 1,
    TracerAlpha     = 0.75,

    NameSize        = 13,
    NameFont        = 2, -- Plex
    NameYOffset     = 20,

    BoxTopOffset    = Vector3.new(0,  2.5, 0),
    BoxBottomOffset = Vector3.new(0,  3,   0),
    BoxWidthRatio   = 0.6,

    FillTransparency    = 0.65,
    OutlineTransparency = 0,

    SpawnDelay      = 0.3,
    ToggleKey       = Enum.KeyCode.Insert,
    DestroyKey      = Enum.KeyCode.End,
}

-- ===== Localized hot-path refs ================================================
local pairs, ipairs        = pairs, ipairs
local mfloor, mabs, mmin   = math.floor, math.abs, math.min
local V2new                = Vector2.new
local Drawing_new          = Drawing.new
local Instance_new         = Instance.new

-- ===== State ==================================================================
local ESP_ENABLED        = true
local DRAWINGS           = {}
local CHAMS              = {}
local AddedConnection    = nil
local RemovedConnection  = nil
local RenderConnection   = nil
local InputConnection    = nil

print("Deadline ESP + CHAMS | Loaded")

-- ===== Helpers ================================================================
local function getRoot(model)
    return model:FindFirstChild("HumanoidRootPart")
        or model:FindFirstChildWhichIsA("BasePart", true)
end

local function setVisible(drawings, state)
    for _, d in pairs(drawings) do
        d.Visible = state
    end
end

local function destroyDrawings(drawings)
    for _, d in pairs(drawings) do
        pcall(d.Remove, d)
    end
end

local function createESP(model)
    if DRAWINGS[model] then return end

    local box    = Drawing_new("Square")
    box.Thickness    = CONFIG.BoxThickness
    box.Filled       = false
    box.Transparency = 1
    box.Color        = CONFIG.BoxColor

    local name   = Drawing_new("Text")
    name.Size    = CONFIG.NameSize
    name.Center  = true
    name.Outline = true
    name.Font    = CONFIG.NameFont
    name.Color   = CONFIG.NameColor

    local tracer = Drawing_new("Line")
    tracer.Thickness    = CONFIG.TracerThickness
    tracer.Transparency = CONFIG.TracerAlpha
    tracer.Color        = CONFIG.TracerColor

    DRAWINGS[model] = { Box = box, Name = name, Tracer = tracer }
end

local function createChams(model)
    if CHAMS[model] then return end
    local highlight = Instance_new("Highlight")
    highlight.FillColor           = CONFIG.ChamsFill
    highlight.OutlineColor        = CONFIG.ChamsOutline
    highlight.FillTransparency    = CONFIG.FillTransparency
    highlight.OutlineTransparency = CONFIG.OutlineTransparency
    highlight.DepthMode           = Enum.HighlightDepthMode.AlwaysOnTop
    highlight.Adornee             = model
    highlight.Parent              = model
    CHAMS[model] = highlight
end

local function removeEntity(model)
    local d = DRAWINGS[model]
    if d then
        destroyDrawings(d)
        DRAWINGS[model] = nil
    end
    local h = CHAMS[model]
    if h then
        pcall(h.Destroy, h)
        CHAMS[model] = nil
    end
end

-- ===== Per-frame update =======================================================
local function updateESP()
    -- Read once per frame, not once per entity.
    local viewport = Camera.ViewportSize
    local halfX    = viewport.X * 0.5
    local botY     = viewport.Y

    -- Resolve self-root once per frame for distance calcs.
    local selfChar = LocalPlayer.Character
    local selfRoot = selfChar and selfChar:FindFirstChild("HumanoidRootPart")
    local selfPos  = selfRoot and selfRoot.Position

    for model, drawings in pairs(DRAWINGS) do
        local root = model.Parent and getRoot(model)
        if not root or not ESP_ENABLED then
            setVisible(drawings, false)
            continue
        end

        local rootWorldPos = root.Position
        local rootPos, onScreen = Camera:WorldToViewportPoint(rootWorldPos)
        if not onScreen or rootPos.Z < 0 then
            setVisible(drawings, false)
            continue
        end

        -- Box
        local topPos    = Camera:WorldToViewportPoint(rootWorldPos + CONFIG.BoxTopOffset)
        local bottomPos = Camera:WorldToViewportPoint(rootWorldPos - CONFIG.BoxBottomOffset)
        local boxHeight = mabs(topPos.Y - bottomPos.Y)
        local boxWidth  = boxHeight * CONFIG.BoxWidthRatio
        local boxTopY   = mmin(topPos.Y, bottomPos.Y)

        local box = drawings.Box
        box.Size     = V2new(boxWidth, boxHeight)
        box.Position = V2new(rootPos.X - boxWidth * 0.5, boxTopY)
        box.Visible  = true

        -- Name
        local dist = selfPos and mfloor((rootWorldPos - selfPos).Magnitude) or 0
        local nameDraw = drawings.Name
        nameDraw.Text     = model.Name .. " [" .. dist .. "m]"
        nameDraw.Position = V2new(rootPos.X, boxTopY - CONFIG.NameYOffset)
        nameDraw.Visible  = true

        -- Tracer
        local tracer = drawings.Tracer
        tracer.From    = V2new(halfX, botY)
        tracer.To      = V2new(rootPos.X, bottomPos.Y)
        tracer.Visible = true
    end
end

-- ===== Wire up ================================================================
local function tryRegister(model)
    if getRoot(model) then
        createESP(model)
        createChams(model)
    end
end

-- Initial scan
for _, model in ipairs(CharFolder:GetChildren()) do
    tryRegister(model)
end

-- New characters: small delay to let parts replicate, then register.
AddedConnection = CharFolder.ChildAdded:Connect(function(model)
    task.wait(CONFIG.SpawnDelay)
    if model.Parent then
        tryRegister(model)
    end
end)

-- Free per-model resources when a character despawns (prevents table growth).
RemovedConnection = CharFolder.ChildRemoved:Connect(removeEntity)

RenderConnection = RunService.RenderStepped:Connect(updateESP)

-- ===== Master destroy =========================================================
local function destroyAll()
    print("END pressed - DESTROY")

    if RenderConnection  then RenderConnection:Disconnect();  RenderConnection  = nil end
    if AddedConnection   then AddedConnection:Disconnect();   AddedConnection   = nil end
    if RemovedConnection then RemovedConnection:Disconnect(); RemovedConnection = nil end

    for _, drawings in pairs(DRAWINGS) do destroyDrawings(drawings) end
    for _, h in pairs(CHAMS)            do pcall(h.Destroy, h)      end

    -- Sweep any leftover Highlights we didn't track.
    for _, model in ipairs(CharFolder:GetChildren()) do
        for _, obj in ipairs(model:GetDescendants()) do
            if obj:IsA("Highlight") then
                pcall(obj.Destroy, obj)
            end
        end
    end

    DRAWINGS    = {}
    CHAMS       = {}
    ESP_ENABLED = false
    print("All ESP + Chams destroyed..")
end

-- ===== Hotkeys ================================================================
InputConnection = UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end

    local key = input.KeyCode
    if key == CONFIG.ToggleKey then
        ESP_ENABLED = not ESP_ENABLED
        for _, h in pairs(CHAMS) do
            if h and h.Parent then h.Enabled = ESP_ENABLED end
        end
        print("ESP + Chams Toggled ->", ESP_ENABLED)

    elseif key == CONFIG.DestroyKey then
        destroyAll()
        if InputConnection then
            InputConnection:Disconnect()
            InputConnection = nil
        end
    end
end)

print("Controls:")
print("   INS  -> Toggle ESP + Chams")
print("   END  -> Completely destroy everything")
