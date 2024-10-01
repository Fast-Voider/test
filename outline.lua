local ESP = {}
local players = game:GetService("Players")
local runService = game:GetService("RunService")
local camera = workspace.CurrentCamera

local espEnabled = false
local boxes = {}

-- Function to create a 3D box for each player
local function create3DBox(player)
    local box = {}

    -- Create the outline for a 3D box
    box.parts = {
        ["top"] = Drawing.new("Line"),
        ["bottom"] = Drawing.new("Line"),
        ["left"] = Drawing.new("Line"),
        ["right"] = Drawing.new("Line"),
        ["front"] = Drawing.new("Line"),
        ["back"] = Drawing.new("Line")
    }

    for _, part in pairs(box.parts) do
        part.Color = Color3.fromRGB(0, 255, 0)  -- Set box color (green)
        part.Thickness = 2
        part.Transparency = 1
        part.Visible = false
    end

    -- Additional elements: health bar and username
    box.healthBar = Drawing.new("Line")
    box.healthBar.Color = Color3.fromRGB(255, 0, 0)
    box.healthBar.Thickness = 2
    box.healthBar.Transparency = 1
    box.healthBar.Visible = false

    box.username = Drawing.new("Text")
    box.username.Size = 18
    box.username.Color = Color3.fromRGB(255, 255, 255)
    box.username.Center = true
    box.username.Outline = true
    box.username.Visible = false

    return box
end

-- Function to update the 3D box position and visibility
local function update3DBox(player, character)
    if not character then return end

    local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
    local head = character:FindFirstChild("Head")
    local humanoid = character:FindFirstChild("Humanoid")

    if humanoidRootPart and head and humanoid then
        local box = boxes[character] or create3DBox(player)
        boxes[character] = box

        local size = character:GetExtentsSize()
        local topLeftFront = humanoidRootPart.Position + Vector3.new(-size.X/2, size.Y/2, size.Z/2)
        local topRightFront = humanoidRootPart.Position + Vector3.new(size.X/2, size.Y/2, size.Z/2)
        local bottomLeftFront = humanoidRootPart.Position + Vector3.new(-size.X/2, -size.Y/2, size.Z/2)
        local bottomRightFront = humanoidRootPart.Position + Vector3.new(size.X/2, -size.Y/2, size.Z/2)

        local topLeftBack = humanoidRootPart.Position + Vector3.new(-size.X/2, size.Y/2, -size.Z/2)
        local topRightBack = humanoidRootPart.Position + Vector3.new(size.X/2, size.Y/2, -size.Z/2)
        local bottomLeftBack = humanoidRootPart.Position + Vector3.new(-size.X/2, -size.Y/2, -size.Z/2)
        local bottomRightBack = humanoidRootPart.Position + Vector3.new(size.X/2, -size.Y/2, -size.Z/2)

        -- Calculate screen positions for each corner
        local topLeftFront2D = camera:WorldToViewportPoint(topLeftFront)
        local topRightFront2D = camera:WorldToViewportPoint(topRightFront)
        local bottomLeftFront2D = camera:WorldToViewportPoint(bottomLeftFront)
        local bottomRightFront2D = camera:WorldToViewportPoint(bottomRightFront)

        local topLeftBack2D = camera:WorldToViewportPoint(topLeftBack)
        local topRightBack2D = camera:WorldToViewportPoint(topRightBack)
        local bottomLeftBack2D = camera:WorldToViewportPoint(bottomLeftBack)
        local bottomRightBack2D = camera:WorldToViewportPoint(bottomRightBack)

        -- Update 3D box drawing
        local parts = box.parts
        parts["top"].From = Vector2.new(topLeftFront2D.X, topLeftFront2D.Y)
        parts["top"].To = Vector2.new(topRightFront2D.X, topRightFront2D.Y)
        parts["bottom"].From = Vector2.new(bottomLeftFront2D.X, bottomLeftFront2D.Y)
        parts["bottom"].To = Vector2.new(bottomRightFront2D.X, bottomRightFront2D.Y)
        parts["left"].From = Vector2.new(topLeftFront2D.X, topLeftFront2D.Y)
        parts["left"].To = Vector2.new(bottomLeftFront2D.X, bottomLeftFront2D.Y)
        parts["right"].From = Vector2.new(topRightFront2D.X, topRightFront2D.Y)
        parts["right"].To = Vector2.new(bottomRightFront2D.X, bottomRightFront2D.Y)
        parts["front"].From = Vector2.new(topLeftFront2D.X, topLeftFront2D.Y)
        parts["front"].To = Vector2.new(topLeftBack2D.X, topLeftBack2D.Y)
        parts["back"].From = Vector2.new(topRightFront2D.X, topRightFront2D.Y)
        parts["back"].To = Vector2.new(topRightBack2D.X, topRightBack2D.Y)

        -- Health bar and username updates
        local healthRatio = humanoid.Health / humanoid.MaxHealth
        box.healthBar.From = Vector2.new(bottomRightFront2D.X + 5, bottomRightFront2D.Y)
        box.healthBar.To = Vector2.new(bottomRightFront2D.X + 5, topRightFront2D.Y * healthRatio)
        box.healthBar.Visible = true

        box.username.Position = Vector2.new((topLeftFront2D.X + topRightFront2D.X) / 2, topLeftFront2D.Y - 20)
        box.username.Text = player.Name
        box.username.Visible = true

        for _, part in pairs(parts) do
            part.Visible = true
        end
    else
        -- Hide box when character is not visible
        for _, part in pairs(boxes[character].parts) do
            part.Visible = false
        end
        boxes[character].healthBar.Visible = false
        boxes[character].username.Visible = false
    end
end

-- Function to remove the ESP box when the player leaves or dies
local function removeBox(character)
    if boxes[character] then
        for _, part in pairs(boxes[character].parts) do
            part:Remove()
        end
        boxes[character].healthBar:Remove()
        boxes[character].username:Remove()
        boxes[character] = nil
    end
end

-- Function to update ESP for all players
local function updateESP()
    while espEnabled do
        for _, player in pairs(players:GetPlayers()) do
            if player ~= players.LocalPlayer then
                local character = player.Character
                if character and player.Character:FindFirstChild("Humanoid") and player.Character:FindFirstChild("Humanoid").Health > 0 then
                    update3DBox(player, character)
                else
                    removeBox(player.Character)
                end
            end
        end
        runService.RenderStepped:Wait()
    end
end

-- Cleanup when a player leaves or dies
players.PlayerRemoving:Connect(function(player)
    if player.Character then
        removeBox(player.Character)
    end
end)

players.PlayerAdded:Connect(function(player)
    player.CharacterRemoving:Connect(function(character)
        removeBox(character)
    end)
end)

-- Start and stop methods for ESP
function ESP.start()
    if not espEnabled then
        espEnabled = true
        updateESP()
    end
end

function ESP.stop()
    espEnabled = false
    for _, box in pairs(boxes) do
        for _, part in pairs(box.parts) do
            part:Remove()
        end
        box.healthBar:Remove()
        box.username:Remove()
    end
    boxes = {}
end

return ESP
