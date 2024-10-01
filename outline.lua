local OutlineESP = {}
local players = game:GetService("Players")
local runService = game:GetService("RunService")
local camera = workspace.CurrentCamera

local espEnabled = false
local outlines = {}

-- Function to create the outline and UI components for a character
local function createOutline()
    local box = {}

    -- Create 12 lines for a 3D box
    for i = 1, 12 do
        box["line" .. i] = Drawing.new("Line")
        box["line" .. i].Color = Color3.fromRGB(0, 255, 0)  -- Green lines
        box["line" .. i].Thickness = 2
        box["line" .. i].Transparency = 1
        box["line" .. i].Visible = false
    end

    -- Health bar, 3D version
    box.healthBar = Instance.new("Part")
    box.healthBar.Anchored = true
    box.healthBar.CanCollide = false
    box.healthBar.Size = Vector3.new(0.2, 5, 0.2)  -- Adjustable size
    box.healthBar.Color = Color3.fromRGB(0, 255, 0)  -- Start with green
    box.healthBar.Parent = workspace

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

-- Function to update the outline, health bar, username, and health percentage
local function drawOutline(player, character)
    if not character then return end

    local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
    local head = character:FindFirstChild("Head")
    local humanoid = character:FindFirstChild("Humanoid")

    if humanoidRootPart and head and humanoid then
        -- Create an outline if not already created
        outlines[character] = outlines[character] or createOutline()

        local rootPos, rootVisible = camera:WorldToViewportPoint(humanoidRootPart.Position)
        local headPos = camera:WorldToViewportPoint(head.Position)

        -- Field of view check: If character is not visible, don't display the ESP
        if not rootVisible or rootPos.Z < 0 then
            outlines[character].username.Visible = false
            outlines[character].healthText.Visible = false
            for i = 1, 12 do
                outlines[character]["line" .. i].Visible = false
            end
            outlines[character].healthBar.Transparency = 1 -- Hide health bar
            return
        end

        -- Create box and 3D outline
        local size = character:GetExtentsSize() * 1.5
        local box = outlines[character]

        local corners = {
            humanoidRootPart.Position + Vector3.new(-size.X / 2, size.Y / 2, -size.Z / 2),  -- Top Left Front
            humanoidRootPart.Position + Vector3.new(size.X / 2, size.Y / 2, -size.Z / 2),   -- Top Right Front
            humanoidRootPart.Position + Vector3.new(size.X / 2, -size.Y / 2, -size.Z / 2),  -- Bottom Right Front
            humanoidRootPart.Position + Vector3.new(-size.X / 2, -size.Y / 2, -size.Z / 2), -- Bottom Left Front
            humanoidRootPart.Position + Vector3.new(-size.X / 2, size.Y / 2, size.Z / 2),   -- Top Left Back
            humanoidRootPart.Position + Vector3.new(size.X / 2, size.Y / 2, size.Z / 2),    -- Top Right Back
            humanoidRootPart.Position + Vector3.new(size.X / 2, -size.Y / 2, size.Z / 2),   -- Bottom Right Back
            humanoidRootPart.Position + Vector3.new(-size.X / 2, -size.Y / 2, size.Z / 2),  -- Bottom Left Back
        }

        -- Define the 12 lines for the 3D box
        local lines = {
            {1, 2}, {2, 3}, {3, 4}, {4, 1}, -- Front face
            {5, 6}, {6, 7}, {7, 8}, {8, 5}, -- Back face
            {1, 5}, {2, 6}, {3, 7}, {4, 8}, -- Connecting lines
        }

        for i, line in ipairs(lines) do
            local p1, p2 = camera:WorldToViewportPoint(corners[line[1]]), camera:WorldToViewportPoint(corners[line[2]])
            box["line" .. i].From = Vector2.new(p1.X, p1.Y)
            box["line" .. i].To = Vector2.new(p2.X, p2.Y)
            box["line" .. i].Visible = true
        end

        -- Update the health bar (3D)
        local healthRatio = humanoid.Health / humanoid.MaxHealth
        box.healthBar.Size = Vector3.new(0.2, 5 * healthRatio, 0.2)  -- Adjust size based on health
        box.healthBar.CFrame = CFrame.new(humanoidRootPart.Position + Vector3.new(size.X / 2 + 0.5, 2.5 * healthRatio, 0)) -- Position next to the box
        box.healthBar.Color = Color3.fromRGB(255 * (1 - healthRatio), 255 * healthRatio, 0) -- Gradient from red to green

        -- Update the username display (above the box)
        box.username.Position = Vector2.new(rootPos.X, rootPos.Y - 20)
        box.username.Text = player.Name
        box.username.Visible = true

        -- Update health percentage display (above the health bar)
        box.healthText.Position = Vector2.new(rootPos.X, rootPos.Y + 30)
        box.healthText.Text = string.format("%d%%", math.floor(healthRatio * 100))
        box.healthText.Visible = true
    else
        -- If character is missing or dead, hide everything
        removeOutline(character)
    end
end

-- Function to remove ESP components when a player leaves/dies
local function removeOutline(character)
    if outlines[character] then
        for i = 1, 12 do
            outlines[character]["line" .. i]:Remove()
        end
        if outlines[character].healthBar then
            outlines[character].healthBar:Destroy()
        end
        outlines[character].username:Remove()
        outlines[character].healthText:Remove()
        outlines[character] = nil
    end
end

-- Function to update the outlines for all players
local function updateOutlineESP()
    while espEnabled do
        for _, player in pairs(players:GetPlayers()) do
            if player ~= players.LocalPlayer then
                local character = player.Character
                if character and player.Character:FindFirstChild("Humanoid") and player.Character:FindFirstChild("Humanoid").Health > 0 then
                    drawOutline(player, character)
                else
                    removeOutline(player.Character)
                end
            end
        end
        runService.RenderStepped:Wait() -- Update every frame
    end
end

-- Cleanup when a player dies or leaves
players.PlayerRemoving:Connect(function(player)
    if player.Character then
        removeOutline(player.Character)
    end
end)

players.PlayerAdded:Connect(function(player)
    player.CharacterRemoving:Connect(function(character)
        removeOutline(character)
    end)
end)

-- Method to start the outline ESP
function OutlineESP.start()
    if not espEnabled then
        espEnabled = true
        updateOutlineESP()
    end
end

-- Method to stop the outline ESP
function OutlineESP.stop()
    espEnabled = false
    -- Hide and clean up all outlines
    for _, outline in pairs(outlines) do
        for i = 1, 12 do
            outline["line" .. i]:Remove()
        end
        outline.healthBar:Destroy()
        outline.username:Remove()
        outline.healthText:Remove()
    end
    -- Clear the outlines table
    outlines = {}
end

return OutlineESP
