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
                    createTargetNotification("Target in FOV: " .. target.Name, Color3.fromRGB(0, 255, 0))
                    return true
                else
                    createTargetNotification("Target NOT Visible: " .. target.Name, Color3.fromRGB(255, 0, 0))
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
