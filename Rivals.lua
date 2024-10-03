-- Configuration
local FOV = 60 -- Field of view for aim assist
local AimSmoothness = 1 -- Smoothness of the aim assist (lower is faster snapping)
local ActivationKey = Enum.KeyCode.ButtonL2 -- Controller button for activation (L2 / ADS)
local MaxDistance = 1000 -- Max distance to aim at targets

-- Required Roblox services
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Camera = game.Workspace.CurrentCamera
local RunService = game:GetService("RunService")

-- Function to check if the player is visible and inside the FOV
local function IsVisibleAndInFOV(target)
    if target and target:FindFirstChild("HumanoidRootPart") then
        local screenPoint, onScreen = Camera:WorldToScreenPoint(target.HumanoidRootPart.Position)
        if onScreen then
            local mousePos = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
            local targetPos = Vector2.new(screenPoint.X, screenPoint.Y)
            local distance = (mousePos - targetPos).Magnitude
            
            -- Check if within FOV and visible
            if distance <= FOV then
                local rayOrigin = Camera.CFrame.Position
                local rayDirection = (target.HumanoidRootPart.Position - rayOrigin).Unit * MaxDistance
                local raycastParams = RaycastParams.new()
                raycastParams.FilterDescendantsInstances = {LocalPlayer.Character} -- Ignore own character
                
                local ray = workspace:Raycast(rayOrigin, rayDirection, raycastParams)
                if ray and ray.Instance and ray.Instance:IsDescendantOf(target) then
                    return true
                end
            end
        end
    end
    return false
end

-- Function to get the closest visible target within the FOV
local function GetClosestTarget()
    local closestTarget = nil
    local closestDistance = FOV
    
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local target = player.Character
            if IsVisibleAndInFOV(target) then
                local screenPoint = Camera:WorldToScreenPoint(target.HumanoidRootPart.Position)
                local mousePos = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
                local targetPos = Vector2.new(screenPoint.X, screenPoint.Y)
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

-- Main aim assist loop
RunService.RenderStepped:Connect(function()
    -- Check if the player is pressing L2 (ADS)
    if UserInputService:IsKeyDown(ActivationKey) then
        -- Get the closest target within the FOV
        local target = GetClosestTarget()
        if target then
            local aimAt = target.HumanoidRootPart.Position
            local currentCameraCFrame = Camera.CFrame.Position
            local aimDirection = (aimAt - currentCameraCFrame).Unit

            -- Calculate smooth aim by interpolating between current look direction and target
            local newLookVector = Camera.CFrame.LookVector:Lerp(aimDirection, AimSmoothness)
            Camera.CFrame = CFrame.new(currentCameraCFrame, currentCameraCFrame + newLookVector)
        end
    end
end)
