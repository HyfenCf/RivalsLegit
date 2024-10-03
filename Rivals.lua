-- Services
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Camera = game.Workspace.CurrentCamera
local GuiService = game:GetService("GuiService")

-- Configurable Variables
local AimSettings = {
    Smoothing = 5, -- Adjust the aim speed for smoothness (higher = slower)
    FOV = 100, -- Field of view for aimbot
    AimbotEnabled = false, -- Toggle for aimbot
    DrawFOV = true, -- Toggle for drawing FOV circle
    FOVCircleColor = Color3.fromRGB(0, 255, 0),
}

-- Variables for UI
local FOVCircle

-- Function to create and update the FOV circle
local function UpdateFOVCircle()
    if AimSettings.DrawFOV then
        if not FOVCircle then
            FOVCircle = Drawing.new("Circle")
            FOVCircle.Thickness = 2
            FOVCircle.Color = AimSettings.FOVCircleColor
            FOVCircle.NumSides = 100
        end
        FOVCircle.Visible = true
        FOVCircle.Radius = AimSettings.FOV
        FOVCircle.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    else
        if FOVCircle then
            FOVCircle.Visible = false
        end
    end
end

-- Function to check if the target is within FOV
local function IsTargetInFOV(target)
    if target and target:FindFirstChild("HumanoidRootPart") then
        local screenPoint, onScreen = Camera:WorldToScreenPoint(target.HumanoidRootPart.Position)
        if onScreen then
            local mousePos = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
            local targetPos = Vector2.new(screenPoint.X, screenPoint.Y)
            local distance = (mousePos - targetPos).Magnitude
            return distance <= AimSettings.FOV
        end
    end
    return false
end

-- Function to aim at the target with smoothing
local function AimAt(target)
    if target and target:FindFirstChild("HumanoidRootPart") then
        local screenPoint = Camera:WorldToScreenPoint(target.HumanoidRootPart.Position)
        local targetPos = Vector2.new(screenPoint.X, screenPoint.Y)
        local mousePos = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
        
        -- Smoothing calculation
        local aimPos = mousePos:Lerp(targetPos, 1 / AimSettings.Smoothing)
        mousemoverel(aimPos.X - mousePos.X, aimPos.Y - mousePos.Y)
    end
end

-- Function to get the closest target in the FOV
local function GetClosestTarget()
    local closestTarget = nil
    local closestDistance = AimSettings.FOV
    
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local target = player.Character
            if IsTargetInFOV(target) then
                local screenPoint = Camera:WorldToScreenPoint(target.HumanoidRootPart.Position)
                local targetPos = Vector2.new(screenPoint.X, screenPoint.Y)
                local mousePos = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
                local distance = (mousePos - targetPos).Magnitude
                
                if distance < closestDistance then
                    closestDistance = distance
                    closestTarget = target
                end
            end
        end
    end
    
    return closestTarget
end

-- Menu for adjusting settings (just an example, you can customize the GUI more)
local function CreateMenu()
    local screenGui = Instance.new("ScreenGui", game.Players.LocalPlayer:WaitForChild("PlayerGui"))
    screenGui.Name = "AimbotMenu"
    
    -- Smoothing Slider
    local smoothingLabel = Instance.new("TextLabel", screenGui)
    smoothingLabel.Size = UDim2.new(0, 200, 0, 50)
    smoothingLabel.Position = UDim2.new(0.05, 0, 0.05, 0)
    smoothingLabel.Text = "Smoothing: " .. AimSettings.Smoothing
    
    local smoothingButton = Instance.new("TextButton", screenGui)
    smoothingButton.Size = UDim2.new(0, 200, 0, 50)
    smoothingButton.Position = UDim2.new(0.05, 0, 0.12, 0)
    smoothingButton.Text = "Increase Smoothing"
    
    smoothingButton.MouseButton1Click:Connect(function()
        AimSettings.Smoothing = AimSettings.Smoothing + 1
        smoothingLabel.Text = "Smoothing: " .. AimSettings.Smoothing
    end)
    
    -- FOV Slider
    local fovLabel = Instance.new("TextLabel", screenGui)
    fovLabel.Size = UDim2.new(0, 200, 0, 50)
    fovLabel.Position = UDim2.new(0.05, 0, 0.2, 0)
    fovLabel.Text = "FOV: " .. AimSettings.FOV
    
    local fovButton = Instance.new("TextButton", screenGui)
    fovButton.Size = UDim2.new(0, 200, 0, 50)
    fovButton.Position = UDim2.new(0.05, 0, 0.27, 0)
    fovButton.Text = "Increase FOV"
    
    fovButton.MouseButton1Click:Connect(function()
        AimSettings.FOV = AimSettings.FOV + 10
        fovLabel.Text = "FOV: " .. AimSettings.FOV
    end)
    
    return screenGui
end

-- Main loop to check for the closest target and aim at them
RunService.RenderStepped:Connect(function()
    if AimSettings.AimbotEnabled then
        local target = GetClosestTarget()
        if target then
            AimAt(target)
        end
    end
    
    UpdateFOVCircle() -- Draw/update the FOV circle every frame
end)

-- Example to toggle aimbot on/off with a button
UserInputService.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.ButtonL2 then -- L2 for controller aiming
        AimSettings.AimbotEnabled = not AimSettings.AimbotEnabled
        print("Aimbot Toggled: ", AimSettings.AimbotEnabled)
    end
end)

-- Create menu
CreateMenu()
