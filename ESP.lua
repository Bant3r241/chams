-- Variables
local players = game:GetService("Players")
local localPlayer = players.LocalPlayer
local playerGui = localPlayer:WaitForChild("PlayerGui")
local RunService = game:GetService("RunService")

local playerESPEnabled = false
local chamsEnabled = false
local espObjects = {}

-- Create the ScreenGui
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "ESPChamsScreenGui"
screenGui.Parent = playerGui  -- Attach the ScreenGui to the player's GUI

-- Create the ToggleButton for ESP and Chams
local toggleButton = Instance.new("TextButton")
toggleButton.Name = "ToggleButton"
toggleButton.Text = "Enable ESP & Chams"
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

-- Function to add Chams (BoxHandleAdornment) for players
local function addChams(player)
    if player.Character then
        for _, part in pairs(player.Character:GetChildren()) do
            if part:IsA("BasePart") then
                -- Create the BoxHandleAdornment
                local chams = Instance.new("BoxHandleAdornment")
                chams.Name = "Chams"
                chams.AlwaysOnTop = true  -- Makes it visible through walls
                chams.ZIndex = 0  -- Layering control
                chams.Adornee = part  -- Attach it to the player's body part
                chams.Color3 = Color3.fromRGB(128, 0, 128)  -- Purple color
                chams.Transparency = 0.3  -- Adjust transparency (lower is more visible)
                chams.Size = part.Size + Vector3.new(0.1, 0.1, 0.1)  -- Slightly larger than the part
                chams.Parent = part  -- Parent it to the part so it stays with the character
            end
        end
    end
end

-- Function to remove Chams (BoxHandleAdornment) for players
local function removeChams(player)
    if player.Character then
        for _, part in pairs(player.Character:GetChildren()) do
            if part:IsA("BasePart") then
                local cham = part:FindFirstChild("Chams")
                if cham then
                    cham:Destroy()  -- Remove the Chams adornment
                end
            end
        end
    end
end

-- Function to toggle ESP & Chams for all players
local function toggleESPChams()
    if playerESPEnabled and chamsEnabled then
        -- Disable ESP & Chams
        for _, player in pairs(players:GetPlayers()) do
            if player ~= localPlayer then
                removeESP(player.Character.HumanoidRootPart)
                removeChams(player)
            end
        end
    else
        -- Enable ESP & Chams
        for _, player in pairs(players:GetPlayers()) do
            if player ~= localPlayer then
                if playerESPEnabled then
                    createESP(player.Character.HumanoidRootPart, player.Name, Color3.fromRGB(128, 0, 128))  -- Purple color
                end
                if chamsEnabled then
                    addChams(player)
                end
            end
        end
    end
    playerESPEnabled = not playerESPEnabled
    chamsEnabled = not chamsEnabled
    toggleButton.Text = (playerESPEnabled and chamsEnabled) and "Disable ESP & Chams" or "Enable ESP & Chams"
end

-- Toggle ESP & Chams on button click
toggleButton.MouseButton1Click:Connect(function()
    toggleESPChams()
end)

-- Add ESP & Chams when a new player joins the game
players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function()
        if playerESPEnabled then
            createESP(player.Character.HumanoidRootPart, player.Name, Color3.fromRGB(128, 0, 128))  -- Purple color
        end
        if chamsEnabled then
            addChams(player)
        end
    end)
end)

-- Remove ESP & Chams when a player leaves the game
players.PlayerRemoving:Connect(function(player)
    removeESP(player.Character.HumanoidRootPart)
    removeChams(player)
end)
