-- Variables
local players = game:GetService("Players")
local localPlayer = players.LocalPlayer
local playerGui = localPlayer:WaitForChild("PlayerGui")
 
local chamsEnabled = false
 
-- Create the ScreenGui
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "ChamsScreenGui"
screenGui.Parent = playerGui  -- Attach the ScreenGui to the player's GUI
 
-- Create the ToggleButton
local toggleButton = Instance.new("TextButton")
toggleButton.Name = "ToggleButton"
toggleButton.Text = "Enable Chams"
toggleButton.Position = UDim2.new(0.4, 0, 0.1, 0)  -- Centered on the screen
toggleButton.Size = UDim2.new(0.2, 0, 0.1, 0)
toggleButton.TextColor3 = Color3.new(1, 1, 1)  -- White text
toggleButton.BackgroundColor3 = Color3.new(0, 0, 0)  -- Black background
toggleButton.Parent = screenGui  -- Attach the button to the ScreenGui
 
-- Function to add Chams (BoxHandleAdornment)
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
                chams.Color3 = Color3.new(0, 1, 0)  -- Green color (you can change this)
                chams.Transparency = 0.3  -- Adjust transparency (lower is more visible)
                chams.Size = part.Size + Vector3.new(0.1, 0.1, 0.1)  -- Slightly larger than the part
                chams.Parent = part  -- Parent it to the part so it stays with the character
            end
        end
    end
end
 
-- Function to remove Chams (BoxHandleAdornment)
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
 
-- Function to toggle Chams for all players
local function toggleChams()
    if chamsEnabled then
        -- Disable Chams
        for _, player in pairs(players:GetPlayers()) do
            if player ~= localPlayer then
                removeChams(player)
            end
        end
    else
        -- Enable Chams
        for _, player in pairs(players:GetPlayers()) do
            if player ~= localPlayer then
                addChams(player)
            end
        end
    end
    chamsEnabled = not chamsEnabled
    toggleButton.Text = chamsEnabled and "Disable Chams" or "Enable Chams"
end
 
-- Toggle Chams on button click
toggleButton.MouseButton1Click:Connect(function()
    toggleChams()
end)
 
-- Add Chams when a new player joins the game
players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function()
        if chamsEnabled then
            addChams(player)
        end
    end)
end)
 
-- Remove Chams when a player leaves the game
players.PlayerRemoving:Connect(function(player)
    removeChams(player)
end)
