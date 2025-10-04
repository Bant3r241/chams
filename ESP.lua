-- Make sure _G.ESP is defined
if _G.ESP == nil then _G.ESP = true end

-- Variables
local players = game:GetService("Players")
local localPlayer = players.LocalPlayer
local playerGui = localPlayer:WaitForChild("PlayerGui")
local RunService = game:GetService("RunService")

local espObjects = {}
local chamsObjects = {}
local espConnection

-- Chams Adjustments
local ChamsAdjustments = {
    Enabled = true,
    OutlineColor = Color3.fromRGB(0, 60, 0),
    OutlineTransparency = 0,
    FillColor = Color3.fromRGB(0, 100, 0),
    FillTransparency = 0,
}

-- Create a dedicated folder for ESP BillboardGuis
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "ESPScreenGui"
screenGui.Parent = playerGui

-- Function to create ESP BillboardGui
local function createESP(part, labelText, color)
    if not part or not part:IsA("BasePart") or espObjects[part] then return end
    local billboard = Instance.new("BillboardGui")
    billboard.Adornee = part
    billboard.Size = UDim2.new(0, 100, 0, 30)
    billboard.StudsOffset = Vector3.new(0, 3, 0)
    billboard.AlwaysOnTop = true
    billboard.Name = "ESP_Billboard"
    billboard.Parent = screenGui

    local label = Instance.new("TextLabel")
    label.BackgroundTransparency = 1
    label.Size = UDim2.new(1, 0, 1, 0)
    label.Text = labelText
    label.TextColor3 = color
    label.TextStrokeTransparency = 0
    label.Font = Enum.Font.SourceSansBold
    label.TextScaled = true
    label.Parent = billboard

    espObjects[part] = billboard
end

-- Function to remove all ESP BillboardGuis
local function removeAllESP()
    for _, gui in pairs(espObjects) do
        if gui and gui.Parent then
            gui:Destroy()
        end
    end
    espObjects = {}
end

-- Add Chams
local function AddChams(player)
    if not player.Character then return end
    if player.Character:FindFirstChild(player.Name .. "_Chams") then return end

    local highlight = Instance.new("Highlight")
    highlight.Name = player.Name .. "_Chams"
    highlight.OutlineColor = ChamsAdjustments.OutlineColor
    highlight.OutlineTransparency = ChamsAdjustments.OutlineTransparency
    highlight.FillColor = ChamsAdjustments.FillColor
    highlight.FillTransparency = ChamsAdjustments.FillTransparency
    highlight.Adornee = player.Character
    highlight.Parent = player.Character

    chamsObjects[player] = highlight
end

-- Remove All Chams
local function RemoveAllChams()
    for _, player in pairs(players:GetPlayers()) do
        if player.Character then
            local chams = player.Character:FindFirstChild(player.Name .. "_Chams")
            if chams then
                chams:Destroy()
            end
        end
    end
    chamsObjects = {}
end

-- Enable ESP + Chams
local function EnableESP()
    if espConnection then espConnection:Disconnect() end

    espConnection = RunService.Stepped:Connect(function()
        if not _G.ESP then return end

        for _, player in pairs(players:GetPlayers()) do
            if player ~= localPlayer and player.Character then
                local hrp = player.Character:FindFirstChild("HumanoidRootPart")
                if hrp then
                    createESP(hrp, player.Name, Color3.fromRGB(0, 100, 0))
                end
                if ChamsAdjustments.Enabled then
                    AddChams(player)
                end
            end
        end
    end)
end

-- Disable ESP + Chams
local function DisableESP()
    if espConnection then
        espConnection:Disconnect()
        espConnection = nil
    end

    removeAllESP()
    RemoveAllChams()

    local existingGui = playerGui:FindFirstChild("ESPScreenGui")
    if existingGui then
        existingGui:Destroy()
    end
end

-- Start or stop based on _G.ESP
if _G.ESP then
    EnableESP()
else
    DisableESP()
end
