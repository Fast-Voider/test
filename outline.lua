local OutlineESP = {}
local players = game:GetService("Players")
local runService = game:GetService("RunService")
local camera = workspace.CurrentCamera

local espEnabled = false
local outlines = {}

-- Function to create the 3D box components for a character
local function create3DBox()
    local box = {}

    -- Lines for the 3D box
    for i = 1, 12 do
        box["line" .. i] = Drawing.new("Line")
        box["line" .. i].Color = Color3.fromRGB(0, 255, 0)  -- Green lines
        box["line" .. i].Thickness = 2
        box["line" .. i].Transparency = 1
        box["line" .. i].Visible = false
    end

    -- Health bar
    box.healthBar = Drawing.new("Line")
    box.healthBar.Color = Color3.fromRGB(255, 0, 0)  -- Red color for health
    box.healthBar.Thickness = 2
    box.healthBar.Transparency = 1
    box.healthBar.Visible = false

    -- Username
    box.username = Drawing.new("Text")
    box.username.Color = Color3.fromRGB(255, 255, 255)  -- White color for text
    box.username.Size = 18
    box.username.Center = true
    box.username.Outline = true
    box.username.Visible = false

    -- Health percentage
    box.healthText = Drawing.new("Text")
    box.healthText.Color = Color3.fromRGB(255, 255, 255)  -- White text for health percentage
    box.healthText.Size = 16
    box.healthText.Center = true
    box.healthText.Outline = true
    box.healthText.Visible = false

    return box
end

-- Function to draw the 3D bounding box for a character
local function draw3DBox(player, character)
    local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
    local humanoid = character:FindFirstChild("Humanoid")
    
    if humanoidRootPart and humanoid then
        -- Create a 3D box if not already created
        outlines[character] = outlines[character] or create3DBox()
        local box = outlines[character]

        -- Character's bounding box size
        local size = Vector3.new(4, 6, 2)  -- Adjust to fit player character size (Width, Height, Depth)

        -- Define 8 corners of the 3D box
        local corners = {
            -- Bottom corners
            humanoidRootPart.Position + Vector3.new(-size.X/2, -size.Y/2, -size.Z/2),
            humanoidRootPart.Position + Vector3.new(size.X/2, -size.Y/2, -size.Z/2),
            humanoidRootPart.Position + Vector3.new(size.X/2, -size.Y/2, size.Z/2),
            humanoidRootPart.Position + Vector3.new(-size.X/2, -size.Y/2, size.Z/2),
            -- Top corners
            humanoidRootPart.Position + Vector3.new(-size.X/2, size.Y/2, -size.Z/2),
            humanoidRootPart.Position + Vector3.new(size.X/2, size.Y/2, -size.Z/2),
            humanoidRootPart.Position + Vector3.new(size.X/2, size.Y/2, size.Z/2),
            humanoidRootPart.Position + Vector3.new(-size.X/2, size.Y/2, size.Z/2),
        }

        -- Convert 3D corners to 2D screen positions
        local screenCorners = {}
        local isVisible = true
        for i, corner in ipairs(corners) do
            local screenPos, visible = camera:WorldToViewportPoint(corner)
            screenCorners[i] = Vector2.new(screenPos.X, screenPos.Y)
            if not visible then
                isVisible = false
            end
        end

        -- If character is visible and on screen
        if isVisible and screenCorners[1].X > 0 then
            -- Draw the 3D box (12 lines connecting the 8 corners)
            box.line1.From, box.line1.To = screenCorners[1], screenCorners[2] -- Bottom front
            box.line2.From, box.line2.To = screenCorners[2], screenCorners[3] -- Bottom right
            box.line3.From, box.line3.To = screenCorners[3], screenCorners[4] -- Bottom back
            box.line4.From, box.line4.To = screenCorners[4], screenCorners[1] -- Bottom left

            box.line5.From, box.line5.To = screenCorners[5], screenCorners[6] -- Top front
            box.line6.From, box.line6.To = screenCorners[6], screenCorners[7] -- Top right
            box.line7.From, box.line7.To = screenCorners[7], screenCorners[8] -- Top back
            box.line8.From, box.line8.To = screenCorners[8], screenCorners[5] -- Top left

            box.line9.From, box.line9.To = screenCorners[1], screenCorners[5] -- Vertical front-left
            box.line10.From, box.line10.To = screenCorners[2], screenCorners[6] -- Vertical front-right
            box.line11.From, box.line11.To = screenCorners[3], screenCorners[7] -- Vertical back-right
            box.line12.From, box.line12.To = screenCorners[4], screenCorners[8] -- Vertical back-left

            -- Make all lines visible
            for i = 1, 12 do
                box["line" .. i].Visible = true
            end

            -- Update the health bar (right side of the box)
            local healthRatio = humanoid.Health / humanoid.MaxHealth
            box.healthBar.From = screenCorners[3] + Vector2.new(5, 0)  -- Start at the bottom right corner
            box.healthBar.To = screenCorners[7] + Vector2.new(5, -(screenCorners[7].Y - screenCorners[3].Y) * (1 - healthRatio))
            box.healthBar.Visible = true

            -- Update the username display (above the box)
            box.username.Position = (screenCorners[5] + screenCorners[6]) / 2 + Vector2.new(0, -20)
            box.username.Text = player.Name
            box.username.Visible = true

            -- Update health percentage display (above the health bar)
            box.healthText.Position = screenCorners[7] + Vector2.new(5, -15)
            box.healthText.Text = string.format("%d%%", math.floor(healthRatio * 100))
            box.healthText.Visible = true
        else
            -- Hide the 3D box and health bar if character is not visible
            for i = 1, 12 do
                box["line" .. i].Visible = false
            end
            box.healthBar.Visible = false
            box.username.Visible = false
            box.healthText.Visible = false
        end
    end
end

-- Function to remove ESP components when a player leaves/dies
local function remove3DBox(character)
    if outlines[character] then
        for i = 1, 12 do
            outlines[character]["line" .. i]:Remove()
        end
        outlines[character].healthBar:Remove()
        outlines[character].username:Remove()
        outlines[character].healthText:Remove()
        outlines[character] = nil
    end
end

-- Function to update the 3D boxes for all players
local function updateOutlineESP()
    while espEnabled do
        for _, player in pairs(players:GetPlayers()) do
            if player ~= players.LocalPlayer then
                local character = player.Character
                if character and character:FindFirstChild("Humanoid") and character.Humanoid.Health > 0 then
                    draw3DBox(player, character)
                else
                    remove3DBox(character)
                end
            end
        end
        runService.RenderStepped:Wait() -- Update every frame
    end
end

-- Cleanup when a player dies or leaves
players.PlayerRemoving:Connect(function(player)
    if player.Character then
        remove3DBox(player.Character)
    end
end)

players.PlayerAdded:Connect(function(player)
    player.CharacterRemoving:Connect(function(character)
        remove3DBox(character)
    end)
end)

-- Method to start the 3D box ESP
function OutlineESP.start()
    if not espEnabled then
        espEnabled = true
        updateOutlineESP()
    end
end

-- Method to stop the 3D box ESP
function OutlineESP.stop()
    espEnabled = false
    -- Hide and clean up all boxes
    for _, box in pairs(outlines) do
        for i = 1, 12 do
            box["line" .. i]:Remove()
        end
        box.healthBar:Remove()
        box.username:Remove()
        box.healthText:Remove()
    end
    outlines = {}
end

return OutlineESP
