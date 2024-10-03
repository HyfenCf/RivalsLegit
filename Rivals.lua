-- ESP Library
local ESPLibrary = {}
ESPLibrary.__index = ESPLibrary

function ESPLibrary:Visualize()
    -- Check if the ESP is enabled
    if not Fluent then
        return ClearVisuals() -- Clear visuals if not enabled
    elseif not self.Character then
        return self:Disconnect() -- Disconnect if the character doesn't exist
    end

    local Head = self.Character:FindFirstChild("Head")
    local HumanoidRootPart = self.Character:FindFirstChild("HumanoidRootPart")
    local Humanoid = self.Character:FindFirstChildWhichIsA("Humanoid")

    -- Ensure the character parts are valid
    if Head and HumanoidRootPart and Humanoid then
        local IsCharacterReady = true
        if Configuration.SmartESP then
            IsCharacterReady = IsReady(self.Character) -- Check if the character is ready
        end

        local HumanoidRootPartPosition, IsInViewport = workspace.CurrentCamera:WorldToViewportPoint(HumanoidRootPart.Position)

        -- Calculate positions for the ESP box and name
        local TopPosition = workspace.CurrentCamera:WorldToViewportPoint(Head.Position + Vector3.new(0, 0.5, 0))
        local BottomPosition = workspace.CurrentCamera:WorldToViewportPoint(HumanoidRootPart.Position - Vector3.new(0, 3, 0))

        if IsInViewport then
            -- Set the size and position of the ESP box
            self.ESPBox.Size = Vector2.new(2350 / HumanoidRootPartPosition.Z, TopPosition.Y - BottomPosition.Y)
            self.ESPBox.Position = Vector2.new(HumanoidRootPartPosition.X - self.ESPBox.Size.X / 2, HumanoidRootPartPosition.Y - self.ESPBox.Size.Y / 2)
            self.ESPBox.Thickness = Configuration.ESPThickness
            self.ESPBox.Transparency = Configuration.ESPTransparency

            -- Set Name ESP
            self.NameESP.Text = self.Player.Name
            self.NameESP.Size = 13 -- Set the name ESP size to 13
            self.NameESP.Transparency = Configuration.ESPTransparency
            self.NameESP.Position = Vector2.new(HumanoidRootPartPosition.X, (HumanoidRootPartPosition.Y + self.ESPBox.Size.Y / 2) - 25)

            -- Color settings
            if Configuration.ESPUseTeamColour and not Configuration.RainbowVisuals then
                local TeamColour = self.Player.TeamColor.Color
                self.ESPBox.Color = TeamColour
                self.NameESP.Color = TeamColour
            else
                self.ESPBox.Color = Configuration.ESPColour
                self.NameESP.Color = Configuration.ESPColour
            end
        end

        -- Control visibility of ESP elements
        self.ESPBox.Visible = Configuration.ESPBox and IsCharacterReady and IsInViewport
        self.NameESP.Visible = Configuration.NameESP and IsCharacterReady and IsInViewport
    else
        -- Hide the ESP elements if character parts are not valid
        self.ESPBox.Visible = false
        self.NameESP.Visible = false
    end
end

function ESPLibrary:Disconnect()
    self.Player = nil
    self.Character = nil
    ClearVisual(self.ESPBox)
    ClearVisual(self.NameESP)
end

return ESPLibrary
