-- Variables
local players = game:GetService("Players")
local localPlayer = players.LocalPlayer
local playerGui = localPlayer:WaitForChild("PlayerGui")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local espObjects = {}

-- Chams Adjustments (Enabled by default)
local ChamsAdjustments = {
    Enabled = true,  -- Chams will be on by default
    OutlineColor = Color3.fromRGB(0, 60, 0),  -- Dark green outline
    OutlineTransparency = 0,
    FillColor = Color3.fromRGB(0, 100, 0),  -- Dark green fill
    FillTransparency = 0,
}

-- Create the ScreenGui for ESP
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "ESPScreenGui"
screenGui.Parent = playerGui  -- Attach the ScreenGui to the player's GUI

-- Function to create ESP for players
local function createESP(part, labelText, color)
    if not part or not part:IsA("BasePart") or espObjects[part] then return end
    local billboard = Instance.new("BillboardGui")
    billboard.Adornee = part
    billboard.Size = UDim2.new(0, 100, 0, 30)
    billboard.StudsOffset = Vector3.new(0, 3, 0)
    billboard.AlwaysOnTop = true
    billboard.Parent = part
    local label = Instance.new("TextLabel", billboard)
    label.BackgroundTransparency = 1
    label.Size = UDim2.new(1, 0, 1, 0)
    label.Text = labelText
    label.TextColor3 = color
    label.TextStrokeTransparency = 0
    label.Font = Enum.Font.SourceSansBold
    label.TextScaled = true
    espObjects[part] = {label = billboard}
end

-- Function to remove ESP for players
local function removeESP(part)
    local esp = espObjects[part]
    if esp then
        if esp.label then esp.label:Destroy() end
        espObjects[part] = nil
    end
end

-- Function to update ESP for all players
local function updatePlayerESP()
    for _, player in pairs(players:GetPlayers()) do
        if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            createESP(player.Character.HumanoidRootPart, player.Name, Color3.fromRGB(0, 100, 0))  -- Dark green color
        end
    end
end

-- Function to add Chams (Highlight effect)
local function AddChams(v)
    if v and v.Character and not v.Character:FindFirstChild(v.Name.."_Chams") then
        local ChamsESP = Instance.new("Highlight")
        ChamsESP.Name = v.Name.."_Chams"
        ChamsESP.OutlineColor = ChamsAdjustments.OutlineColor
        ChamsESP.OutlineTransparency = ChamsAdjustments.OutlineTransparency
        ChamsESP.FillColor = ChamsAdjustments.FillColor
        ChamsESP.FillTransparency = ChamsAdjustments.FillTransparency
        ChamsESP.Parent = v.Character
        ChamsESP.Adornee = v.Character
    end
end

-- Function to update Chams
local function UpdateChams(v)
    if v and v.Character and v.Character:FindFirstChild(v.Name.."_Chams") then
        local ChamsESP = v.Character:FindFirstChild(v.Name.."_Chams")
        ChamsESP.Enabled = ChamsAdjustments.Enabled
        ChamsESP.OutlineColor = ChamsAdjustments.OutlineColor
        ChamsESP.OutlineTransparency = ChamsAdjustments.OutlineTransparency
        ChamsESP.FillColor = ChamsAdjustments.FillColor
        ChamsESP.FillTransparency = ChamsAdjustments.FillTransparency
    end
end

-- Function to remove Chams
local function RemoveChams(v)
    if v and v.Character and v.Character:FindFirstChild(v.Name.."_Chams") then
        v.Character:FindFirstChild(v.Name.."_Chams"):Destroy()
    end
end

-- Add Chams and ESP when a new player joins the game
players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function()
        updatePlayerESP()  -- Add ESP for the new player
        if ChamsAdjustments.Enabled then
            AddChams(player)  -- Add Chams for the new player if enabled
        end
    end)
end)

-- Remove ESP and Chams when a player leaves the game
players.PlayerRemoving:Connect(function(player)
    removeESP(player.Character.HumanoidRootPart)  -- Remove ESP
    RemoveChams(player)  -- Remove Chams
end)

-- Initially update ESP for all players
updatePlayerESP()

-- Continuously update ESP and Chams for all players
RunService.Stepped:Connect(function()
    for _, player in pairs(players:GetPlayers()) do
        if player ~= localPlayer and player.Character then
            -- Update ESP for the player
            if player.Character:FindFirstChild("HumanoidRootPart") then
                createESP(player.Character.HumanoidRootPart, player.Name, Color3.fromRGB(0, 100, 0))  -- Dark green color
            end
            -- Update Chams for the player if enabled
            if ChamsAdjustments.Enabled then
                if not player.Character:FindFirstChild(player.Name.."_Chams") then
                    AddChams(player)
                elseif player.Character:FindFirstChild(player.Name.."_Chams") then
                    UpdateChams(player)
                end
            else
                RemoveChams(player)
            end
        end
    end
end)
