local OutlineESP = {}
local players = game:GetService("Players")
local runService = game:GetService("RunService")
local camera = workspace.CurrentCamera

local espEnabled = false
local outlines = {}

-- Function to create the outline and UI components for a character
local function createOutline()
    local box = {}
    
    -- Box around the player
    box.outline = Drawing.new("Quad")
    box.outline.Color = Color3.fromRGB(0, 255, 0)  -- Green box color
    box.outline.Thickness = 2
    box.outline.Transparency = 1
    box.outline.Visible = false
    
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
        local hrpPos, hrpVisible = camera:WorldToViewportPoint(humanoidRootPart.Position)

        -- If character is visible and in front of the camera
        if rootVisible and hrpPos.Z > 0 then
            local size = character:GetExtentsSize()
            local topLeft = camera:WorldToViewportPoint(humanoidRootPart.Position + Vector3.new(-size.X/2, size.Y/2, 0))
            local topRight = camera:WorldToViewportPoint(humanoidRootPart.Position + Vector3.new(size.X/2, size.Y/2, 0))
            local bottomLeft = camera:WorldToViewportPoint(humanoidRootPart.Position + Vector3.new(-size.X/2, -size.Y/2, 0))
            local bottomRight = camera:WorldToViewportPoint(humanoidRootPart.Position + Vector3.new(size.X/2, -size.Y/2, 0))
            
            -- Update the box outline
            local box = outlines[character]
            box.outline.PointA = Vector2.new(topLeft.X, topLeft.Y)
            box.outline.PointB = Vector2.new(topRight.X, topRight.Y)
            box.outline.PointC = Vector2.new(bottomRight.X, bottomRight.Y)
            box.outline.PointD = Vector2.new(bottomLeft.X, bottomLeft.Y)
            box.outline.Visible = true
            
            -- Update the health bar (right side of the box)
            local healthRatio = humanoid.Health / humanoid.MaxHealth
            box.healthBar.From = Vector2.new(bottomRight.X + 5, bottomRight.Y)
            box.healthBar.To = Vector2.new(bottomRight.X + 5, topRight.Y * healthRatio)
            box.healthBar.Visible = true
            
            -- Update the username display (above the box)
            box.username.Position = Vector2.new((topLeft.X + topRight.X) / 2, topLeft.Y - 20)
            box.username.Text = player.Name
            box.username.Visible = true
            
            -- Update health percentage display (above the health bar)
            box.healthText.Position = Vector2.new(bottomRight.X + 5, topRight.Y - 15)
            box.healthText.Text = string.format("%d%%", math.floor(healthRatio * 100))
            box.healthText.Visible = true
        else
            -- Hide the box, health bar, username, and health percentage if character is not visible
            outlines[character].outline.Visible = false
            outlines[character].healthBar.Visible = false
            outlines[character].username.Visible = false
            outlines[character].healthText.Visible = false
        end
    else
        -- If character is missing or dead, hide everything
        if outlines[character] then
            outlines[character].outline.Visible = false
            outlines[character].healthBar.Visible = false
            outlines[character].username.Visible = false
            outlines[character].healthText.Visible = false
        end
    end
end

-- Function to remove ESP components when a player leaves/dies
local function removeOutline(character)
    if outlines[character] then
        outlines[character].outline:Remove()
        outlines[character].healthBar:Remove()
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
        outline.outline:Remove()
        outline.healthBar:Remove()
        outline.username:Remove()
        outline.healthText:Remove()
    end
    -- Clear the outlines table
    outlines = {}
end

return OutlineESP
