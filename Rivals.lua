-- Script to highlight players with light blue color every second

local players = game.Players
local lightBlueColor = Color3.new(0.5, 0.8, 1)

-- Function to highlight players with light blue color
local function highlightPlayers()
    for _, player in pairs(players:GetPlayers()) do
        local humanoid = player.Character:WaitForChild("Humanoid")
        if humanoid then
            humanoid.DisplayDistance = 0 -- Set display distance to 0 to prevent clipping
            humanoid.Health = 1 -- Set health to 1 to prevent death
            humanoid.Color = lightBlueColor
        end
    end
end

-- Run the highlighting function initially
highlightPlayers()

-- Create a repeating function to update highlights every second
while true do
    wait(1)
    highlightPlayers()
end
