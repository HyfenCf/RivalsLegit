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
    FOVCircleColor = Color3.fromRGB(128, 0, 128), -- Purple color for FOV outline
}

-- Variables for UI
local FOVCircle
local MenuFrame
local IsDragging = false
local DragStart = nil
local StartPos = nil

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

-- Function to create the menu
local function CreateMenu()
    MenuFrame = Instance.new("Frame")
    MenuFrame.Size = UDim2.new(0, 300, 0, 200)
    MenuFrame.Position = UDim2.new(0.5, -150, 0.5, -100)
    MenuFrame.BackgroundTransparency = 0.5
    MenuFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    MenuFrame.BorderSizePixel = 0
    MenuFrame.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")

    -- Close Button
    local closeButton = Instance.new("TextButton", MenuFrame)
    closeButton.Size = UDim2.new(0, 80, 0, 30)
    closeButton.Position = UDim2.new(1, -90, 0, 10)
    closeButton.Text = "Close"
    closeButton.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
    
    closeButton.MouseButton1Click:Connect(function()
        MenuFrame.Visible = false
    end)

    -- Smoothing Slider
    local smoothingLabel = Instance.new("TextLabel", MenuFrame)
    smoothingLabel.Size = UDim2.new(1, 0, 0, 30)
    smoothingLabel.Position = UDim2.new(0, 0, 0.2, 0)
    smoothingLabel.Text = "Smoothing: " .. AimSettings.Smoothing
    smoothingLabel.BackgroundTransparency = 1

    local increaseSmoothingButton = Instance.new("TextButton", MenuFrame)
    increaseSmoothingButton.Size = UDim2.new(1, 0, 0, 30)
    increaseSmoothingButton.Position = UDim2.new(0, 0, 0.3, 0)
    increaseSmoothingButton.Text = "Increase Smoothing"

    increaseSmoothingButton.MouseButton1Click:Connect(function()
        AimSettings.Smoothing = AimSettings.Smoothing + 1
        smoothingLabel.Text = "Smoothing: " .. AimSettings.Smoothing
    end)

    -- FOV Slider
    local fovLabel = Instance.new("TextLabel", MenuFrame)
    fovLabel.Size = UDim2.new(1, 0, 0, 30)
    fovLabel.Position = UDim2.new(0, 0, 0.4, 0)
    fovLabel.Text = "FOV: " .. AimSettings.FOV
    fovLabel.BackgroundTransparency = 1

    local increaseFOVButton = Instance.new("TextButton", MenuFrame)
    increaseFOVButton.Size = UDim2.new(1, 0, 0, 30)
    increaseFOVButton.Position = UDim2.new(0, 0, 0.5, 0)
    increaseFOVButton.Text = "Increase FOV"

    increaseFOVButton.MouseButton1Click:Connect(function()
        AimSettings.FOV = AimSettings.FOV + 10
        fovLabel.Text = "FOV: " .. AimSettings.FOV
    end)

    -- Make the menu draggable
    MenuFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            IsDragging = true
            DragStart = input.Position
            StartPos = MenuFrame.Position

            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    IsDragging = false
                end
            end)
        end
    end)

    MenuFrame.InputChanged:Connect(function(input)
        if IsDragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - DragStart
            MenuFrame.Position = StartPos + UDim2.new(0, delta.X, 0, delta.Y)
        end
    end)
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
