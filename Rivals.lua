-- LocalScript

-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

-- Highlight Color
local highlightColor = Color3.fromRGB(173, 216, 230) -- Light Blue

-- Function to create highlights for players
local function HighlightPlayers()
    for _, player in ipairs(Players:GetPlayers()) do
        if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local highlight = Instance.new("Highlight")
            highlight.Adornee = player.Character.HumanoidRootPart
            highlight.FillColor = highlightColor
            highlight.OutlineColor = Color3.new(1, 1, 1) -- White outline
            highlight.Parent = player.Character

            -- Remove existing highlights if they already exist
            if player.Character:FindFirstChild("Highlight") then
                player.Character.Highlight:Destroy()
            end
        end
    end
end

-- Function to refresh highlights
local function RefreshHighlights()
    for _, player in ipairs(Players:GetPlayers()) do
        if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            if not player.Character:FindFirstChild("Highlight") then
                HighlightPlayers()
            end
        end
    end
end

-- Initial highlighting
HighlightPlayers()

-- Set up a loop to check for changes every second
RunService.Heartbeat:Connect(function()
    wait(1)
    RefreshHighlights()
end)

-- Also check for new players joining the game
Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function()
        HighlightPlayers()
    end)
end)
