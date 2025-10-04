-- Global flag: whether ESP is enabled
if _G.ESP == nil then _G.ESP = true end

-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- Create or get the main ScreenGui container
local screenGui = PlayerGui:FindFirstChild("ESPScreenGui")
if not screenGui then
    screenGui = Instance.new("ScreenGui")
    screenGui.Name = "ESPScreenGui"
    screenGui.ResetOnSpawn = false
    screenGui.Parent = PlayerGui
end

-- Chams settings
local ChamsAdjustments = {
    Enabled = true,
    OutlineColor = Color3.fromRGB(0, 60, 0),
    OutlineTransparency = 0,
    FillColor = Color3.fromRGB(0, 100, 0),
    FillTransparency = 0
}

-- Add chams (Highlight) to a player's character
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

-- Remove chams from a player's character
local function RemoveChams(player)
    if not player.Character then return end
    local cham = player.Character:FindFirstChild(player.Name .. "_Chams")
    if cham then cham:Destroy() end
end

-- Remove all chams from all players
local function RemoveAllChams()
    for _, player in ipairs(Players:GetPlayers()) do
        RemoveChams(player)
    end
end

-- Create ESP name tag for a part
local function CreateESP(part, playerName)
    if not part or not part:IsA("BasePart") then return end

    -- Avoid duplicates
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

-- Remove all ESP name tags (BillboardGuis)
local function RemoveAllNameTags()
    if not screenGui then return end
    for _, child in pairs(screenGui:GetChildren()) do
        if child:IsA("BillboardGui") and child.Name == "ESP_Billboard" then
            child:Destroy()
        end
    end
end

-- Main loop connection holder
local espConnection

local function EnableESP()
    -- Start updating ESP each frame
    espConnection = RunService.Stepped:Connect(function()
        if not _G.ESP then return end

        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                -- Create name ESP
                CreateESP(player.Character.HumanoidRootPart, player.Name)

                -- Add chams if enabled
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
    -- Stop the loop
    if espConnection then
        espConnection:Disconnect()
        espConnection = nil
    end

    -- Remove everything
    RemoveAllNameTags()
    RemoveAllChams()

    -- Extra: clear ScreenGui children (should be empty now)
    if screenGui then
        screenGui:ClearAllChildren()
    end
end

-- Player joined - add chams on spawn if ESP enabled
Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function()
        if _G.ESP and ChamsAdjustments.Enabled then
            AddChams(player)
        end
    end)
end)

-- Player leaving - remove chams cleanup
Players.PlayerRemoving:Connect(function(player)
    RemoveChams(player)
end)

-- Init on script run
if _G.ESP then
    EnableESP()
else
    DisableESP()
end
