-- Ensure global flag is defined
if _G.ESP == nil then _G.ESP = true end

-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- ESP Container
local screenGui = PlayerGui:FindFirstChild("ESPScreenGui")
if not screenGui then
    screenGui = Instance.new("ScreenGui")
    screenGui.Name = "ESPScreenGui"
    screenGui.ResetOnSpawn = false
    screenGui.Parent = PlayerGui
end

-- Chams Configuration
local ChamsAdjustments = {
    Enabled = true,
    OutlineColor = Color3.fromRGB(0, 60, 0),
    OutlineTransparency = 0,
    FillColor = Color3.fromRGB(0, 100, 0),
    FillTransparency = 0
}

-- Chams Handler
local function AddChams(player)
    if not player.Character then return end
    if player.Character:FindFirstChild(player.Name .. "_Chams") then return end

    local highlight = Instance.new("Highlight")
    highlight.Name = player.Name .. "_Chams"
    highlight.Adornee = player.Character
    highlight.FillColor = ChamsAdjustments.FillColor
    highlight.FillTransparency = ChamsAdjustments.FillTransparency
    highlight.OutlineColor = ChamsAdjustments.OutlineColor
    highlight.OutlineTransparency = ChamsAdjustments.OutlineTransparency
    highlight.Parent = player.Character
end

local function RemoveChams(player)
    if not player.Character then return end
    local cham = player.Character:FindFirstChild(player.Name .. "_Chams")
    if cham then cham:Destroy() end
end

local function RemoveAllChams()
    for _, player in ipairs(Players:GetPlayers()) do
        RemoveChams(player)
    end
end

-- Name ESP
local function CreateESP(part, playerName)
    if not part or not part:IsA("BasePart") then return end

    -- Check if this part already has ESP
    for _, gui in pairs(screenGui:GetChildren()) do
        if gui:IsA("BillboardGui") and gui.Adornee == part then
            return
        end
    end

    local billboard = Instance.new("BillboardGui")
    billboard.Name = "ESP_Billboard"
    billboard.Adornee = part
    billboard.Size = UDim2.new(0, 100, 0, 30)
    billboard.StudsOffset = Vector3.new(0, 3, 0)
    billboard.AlwaysOnTop = true
    billboard.Parent = screenGui

    local label = Instance.new("TextLabel")
    label.Name = "ESPLabel"
    label.BackgroundTransparency = 1
    label.Size = UDim2.new(1, 0, 1, 0)
    label.Text = playerName
    label.TextColor3 = Color3.fromRGB(0, 255, 0)
    label.TextStrokeTransparency = 0
    label.Font = Enum.Font.SourceSansBold
    label.TextScaled = true
    label.Parent = billboard
end

local function RemoveAllNameTags()
    for _, child in pairs(screenGui:GetChildren()) do
        if child:IsA("BillboardGui") and child.Name == "ESP_Billboard" then
            child:Destroy()
        end
    end
end

-- Main ESP Loop Handler
local espConnection

local function EnableESP()
    -- Start render loop
    espConnection = RunService.Stepped:Connect(function()
        if not _G.ESP then return end

        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                -- Name ESP
                CreateESP(player.Character.HumanoidRootPart, player.Name)

                -- Chams
                if ChamsAdjustments.Enabled then
                    AddChams(player)
                else
                    RemoveChams(player)
                end
            end
        end
    end)
end

local function DisableESP()
    -- Disconnect loop
    if espConnection then
        espConnection:Disconnect()
        espConnection = nil
    end

    -- Clean up
    RemoveAllNameTags()
    RemoveAllChams()

    local existing = PlayerGui:FindFirstChild("ESPScreenGui")
    if existing then
        existing:ClearAllChildren()
    end
end

-- PlayerAdded/Removed Handling
Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function()
        if _G.ESP and ChamsAdjustments.Enabled then
            AddChams(player)
        end
    end)
end)

Players.PlayerRemoving:Connect(function(player)
    RemoveChams(player)
end)

-- INIT
if _G.ESP then
    EnableESP()
else
    DisableESP()
end
