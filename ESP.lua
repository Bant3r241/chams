-- Variables
local players = game:GetService("Players")
local localPlayer = players.LocalPlayer
local playerGui = localPlayer:WaitForChild("PlayerGui")
local RunService = game:GetService("RunService")

local playerESPEnabled = false
local espObjects = {}

-- Create the ScreenGui
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "ESPScreenGui"
screenGui.Parent = playerGui  -- Attach the ScreenGui to the player's GUI

-- Create the ToggleButton for ESP
local toggleButton = Instance.new("TextButton")
toggleButton.Name = "ToggleButton"
toggleButton.Text = "Enable ESP"
toggleButton.Position = UDim2.new(0.4, 0, 0.1, 0)  -- Centered on the screen
toggleButton.Size = UDim2.new(0.2, 0, 0.1, 0)
toggleButton.TextColor3 = Color3.new(1, 1, 1)  -- White text
toggleButton.BackgroundColor3 = Color3.new(0, 0, 0)  -- Black background
toggleButton.Parent = screenGui  -- Attach the button to the ScreenGui

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
local function updatePlayerESP(state)
    playerESPEnabled = state
    if not state then
        for _, player in pairs(players:GetPlayers()) do
            if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                removeESP(player.Character.HumanoidRootPart)
            end
        end
        return
    end
    for _, player in pairs(players:GetPlayers()) do
        if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            createESP(player.Character.HumanoidRootPart, player.Name, Color3.fromRGB(128, 0, 128))  -- Purple color
        end
    end
end

-- Function to toggle ESP for all players
local function toggleESP()
    if playerESPEnabled then
        -- Disable ESP
        for _, player in pairs(players:GetPlayers()) do
            if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                removeESP(player.Character.HumanoidRootPart)
            end
        end
    else
        -- Enable ESP
        for _, player in pairs(players:GetPlayers()) do
            if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                createESP(player.Character.HumanoidRootPart, player.Name, Color3.fromRGB(128, 0, 128))  -- Purple color
            end
        end
    end
    playerESPEnabled = not playerESPEnabled
    toggleButton.Text = playerESPEnabled and "Disable ESP" or "Enable ESP"
end

-- Toggle ESP on button click
toggleButton.MouseButton1Click:Connect(function()
    toggleESP()
end)

-- Add ESP when a new player joins the game
players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function()
        if playerESPEnabled then
            createESP(player.Character.HumanoidRootPart, player.Name, Color3.fromRGB(128, 0, 128))  -- Purple color
        end
    end)
end)

-- Remove ESP when a player leaves the game
players.PlayerRemoving:Connect(function(player)
    removeESP(player.Character.HumanoidRootPart)
end)
