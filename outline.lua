local OutlineESP = {}
local players = game:GetService("Players")
local runService = game:GetService("RunService")
local camera = workspace.CurrentCamera
local localPlayer = players.LocalPlayer

local espEnabled = false
local outlines = {}

-- Function to create the 3D box components for a character
local function create3DBox()
    local box = {}

    -- Lines for the 3D box (we'll have 12 in total for a cube)
    for i = 1, 12 do
        box["line" .. i] = Drawing.new("Line")
        box["line" .. i].Color = Color3.fromRGB(0, 255, 0) -- Clean green lines for clarity
        box["line" .. i].Thickness = 1.5 -- Make lines slightly thicker for visibility
        box["line" .. i].Transparency = 1
        box["line" .. i].Visible = false
    end

    -- Health bar
    box.healthBar = Drawing.new("Line")
    box.healthBar.Thickness = 4
    box.healthBar.Transparency = 1
    box.healthBar.Visible = false

    -- Username display
    box.username = Drawing.new("Text")
    box.username.Size = 20
    box.username.Center = true
    box.username.Outline = true
    box.username.Color = Color3.fromRGB(255, 255, 255)
    box.username.Visible = false

    -- Health percentage text
    box.healthText = Drawing.new("Text")
    box.healthText.Size = 18
    box.healthText.Center = true
    box.healthText.Outline = true
    box.healthText.Color = Color3.fromRGB(255, 255, 255)
    box.healthText.Visible = false

    return box
end

-- Function to update the 3D box, health bar, username, and health percentage
local function draw3DBox(player, character)
    if not character then return end

    local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
    local head = character:FindFirstChild("Head")
    local humanoid = character:FindFirstChild("Humanoid")

    if humanoidRootPart and head and humanoid then
        -- Create a box if not already created
        outlines[character] = outlines[character] or create3DBox()

        -- Get 8 corners of the 3D bounding box
        local size = character:GetExtentsSize()
        local halfSize = size / 2
        local corners = {
            humanoidRootPart.CFrame * Vector3.new(halfSize.X, halfSize.Y, halfSize.Z),
            humanoidRootPart.CFrame * Vector3.new(-halfSize.X, halfSize.Y, halfSize.Z),
            humanoidRootPart.CFrame * Vector3.new(halfSize.X, -halfSize.Y, halfSize.Z),
            humanoidRootPart.CFrame * Vector3.new(-halfSize.X, -halfSize.Y, halfSize.Z),
            humanoidRootPart.CFrame * Vector3.new(halfSize.X, halfSize.Y, -halfSize.Z),
            humanoidRootPart.CFrame * Vector3.new(-halfSize.X, halfSize.Y, -halfSize.Z),
            humanoidRootPart.CFrame * Vector3.new(halfSize.X, -halfSize.Y, -halfSize.Z),
            humanoidRootPart.CFrame * Vector3.new(-halfSize.X, -halfSize.Y, -halfSize.Z)
        }

        -- Project the 3D positions to 2D screen positions
        local screenPositions = {}
        local inFOV = false
        for i, corner in ipairs(corners) do
            local screenPos, visible = camera:WorldToViewportPoint(corner)
            screenPositions[i] = screenPos
            if visible and screenPos.Z > 0 then
                inFOV = true
            end
        end

        -- If the character is visible and in the field of view
        if inFOV then
            local box = outlines[character]

            -- Draw the 12 lines of the box (from corner to corner)
            local pairsOfCorners = {
                {1, 2}, {1, 3}, {1, 5}, {2, 4}, {2, 6}, {3, 4},
                {3, 7}, {4, 8}, {5, 6}, {5, 7}, {6, 8}, {7, 8}
            }
            for i, pair in ipairs(pairsOfCorners) do
                box["line" .. i].From = Vector2.new(screenPositions[pair[1]].X, screenPositions[pair[1]].Y)
                box["line" .. i].To = Vector2.new(screenPositions[pair[2]].X, screenPositions[pair[2]].Y)
                box["line" .. i].Visible = true
            end

            -- Update the health bar (adjust size according to health)
            local healthRatio = humanoid.Health / humanoid.MaxHealth
            box.healthBar.Color = Color3.fromRGB(255 * (1 - healthRatio), 255 * healthRatio, 0) -- Gradient from red to green
            box.healthBar.From = Vector2.new(screenPositions[4].X + 5, screenPositions[4].Y)
            box.healthBar.To = Vector2.new(screenPositions[4].X + 5, screenPositions[1].Y * healthRatio)
            box.healthBar.Visible = true

            -- Update the username display (above the box)
            box.username.Position = Vector2.new((screenPositions[1].X + screenPositions[2].X) / 2, screenPositions[1].Y - 20)
            box.username.Text = player.Name
            box.username.Visible = true

            -- Update health percentage display (next to the health bar)
            box.healthText.Position = Vector2.new(screenPositions[4].X + 5, screenPositions[1].Y - 15)
            box.healthText.Text = string.format("%d%%", math.floor(healthRatio * 100))
            box.healthText.Visible = true
        else
            -- Hide all components if the player is out of FOV
            local box = outlines[character]
            for i = 1, 12 do
                box["line" .. i].Visible = false
            end
            box.healthBar.Visible = false
            box.username.Visible = false
            box.healthText.Visible = false
        end
    else
        -- Hide everything if the character is missing or dead
        if outlines[character] then
            for i = 1, 12 do
                outlines[character]["line" .. i].Visible = false
            end
            outlines[character].healthBar.Visible = false
            outlines[character].username.Visible = false
            outlines[character].healthText.Visible = false
        end
    end
end

-- Function to remove 3D box when a player leaves/dies
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

-- Function to update the ESP for all players
local function updateOutlineESP()
    while espEnabled do
        for _, player in pairs(players:GetPlayers()) do
            if player ~= localPlayer then
                local character = player.Character
                if character and character:FindFirstChild("Humanoid") and character:FindFirstChild("Humanoid").Health > 0 then
                    draw3DBox(player, character)
                else
                    remove3DBox(character)
                end
            end
        end
        runService.RenderStepped:Wait() -- Update every frame
    end
end

-- Cleanup when a player leaves or dies
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
    -- Hide and clean up all outlines
    for _, outline in pairs(outlines) do
        for i = 1, 12 do
            outline["line" .. i]:Remove()
        end
        outline.healthBar:Remove()
        outline.username:Remove()
        outline.healthText:Remove()
    end
    -- Clear the outlines table
    outlines = {}
end

return OutlineESP
