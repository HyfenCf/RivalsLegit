-- Configuration
local FOV = 60 -- Field of view for aim assist
local ActivationKey = Enum.KeyCode.ButtonL2 -- Controller button for activation (L2 / ADS)

-- Required Roblox services
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Camera = game.Workspace.CurrentCamera
local RunService = game:GetService("RunService")

-- Function to create an in-game notification
local function createTargetNotification(message, color)
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "TargetNotification"
    screenGui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")

    local textLabel = Instance.new("TextLabel")
    textLabel.Parent = screenGui
    textLabel.Text = message
    textLabel.Size = UDim2.new(0, 300, 0, 50)
    textLabel.Position = UDim2.new(0.5, -150, 0.85, 0) -- Centered closer to the bottom
    textLabel.BackgroundTransparency = 0.5
    textLabel.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    textLabel.TextColor3 = color
    textLabel.TextScaled = true
    textLabel.Font = Enum.Font.SourceSansBold

    wait(2)
    for i = 1, 10 do
        textLabel.TextTransparency = i * 0.1
        wait(0.1)
    end
    screenGui:Destroy()
end

-- Simplified target detection (No visibility checks, just detecting players)
local function GetClosestTarget()
    local closestTarget = nil
    local closestDistance = FOV
    
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local target = player.Character
            local screenPoint, onScreen = Camera:WorldToScreenPoint(target.HumanoidRootPart.Position)
            
            -- Check if the target is on-screen and within FOV
            if onScreen then
                local mousePos = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
                local targetPos = Vector2.new(screenPoint.X, screenPoint.Y)
                local distance = (mousePos - targetPos).Magnitude
                
                -- Simple FOV check
                if distance <= FOV then
                    createTargetNotification("Target in FOV: " .. target.Name, Color3.fromRGB(0, 255, 0))
                    closestTarget = target
                    break -- Stop after finding the first target in FOV
                else
                    createTargetNotification("Target not in FOV", Color3.fromRGB(255, 0, 0))
                end
            end
        end
    end
    
    return closestTarget
end

-- Main loop to detect targets when L2 (ADS) is pressed
RunService.RenderStepped:Connect(function()
    if UserInputService:IsKeyDown(ActivationKey) then
        GetClosestTarget()
    end
end)
