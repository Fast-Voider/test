local esp = {}

function esp.start()
    esp.isActive = true

    local Players = game:GetService("Players")
    local LocalPlayer = Players.LocalPlayer

    -- Function to create a 3D box and health bar for a player
    local function createESP(player)
        local box = Instance.new("BoxHandleAdornment")
        box.Size = Vector3.new(2, 5, 1) -- Size of the box
        box.Adornee = player.Character
        box.Color3 = Color3.new(0, 1, 0) -- Green color for the box
        box.Transparency = 0.5
        box.ZIndex = 0
        box.AlwaysOnTop = true
        box.Parent = player.Character

        -- Create health bar
        local healthBarGui = Instance.new("BillboardGui")
        healthBarGui.Size = UDim2.new(1, 0, 0.2, 0) -- Health bar size
        healthBarGui.Adornee = player.Character.Head
        healthBarGui.ExtentsOffset = Vector3.new(0, 2, 0) -- Position above head
        healthBarGui.Parent = player.Character

        local healthBar = Instance.new("Frame")
        healthBar.Size = UDim2.new(1, 0, 1, 0)
        healthBar.BackgroundColor3 = Color3.new(1, 0, 0) -- Red for the health bar
        healthBar.Parent = healthBarGui

        local healthLabel = Instance.new("TextLabel")
        healthLabel.Size = UDim2.new(1, 0, 0.5, 0)
        healthLabel.Position = UDim2.new(0, 0, 0, 0)
        healthLabel.BackgroundTransparency = 1
        healthLabel.TextColor3 = Color3.new(1, 1, 1)
        healthLabel.TextScaled = true
        healthLabel.Parent = healthBarGui

        return box, healthBar, healthLabel
    end

    -- Function to update the ESP for a player
    local function updateESP(player, box, healthBar, healthLabel)
        local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            box.Size = Vector3.new(2, humanoid.Health / humanoid.MaxHealth * 5, 1) -- Adjust box height based on health
            healthBar.Size = UDim2.new(1, 0, humanoid.Health / humanoid.MaxHealth, 0) -- Adjust health bar size
            healthLabel.Text = string.format("%.0f%%", (humanoid.Health / humanoid.MaxHealth) * 100) -- Show health percentage
        else
            box:Destroy()
            healthBar:Destroy()
        end
    end

    -- Function to handle when a player is added
    local function onPlayerAdded(player)
        player.CharacterAdded:Connect(function(character)
            local box, healthBar, healthLabel = createESP(player)

            -- Update ESP while the player is in the game
            while esp.isActive and player.Character do
                updateESP(player, box, healthBar, healthLabel)
                wait(0.1)
            end

            -- Cleanup when the player leaves
            box:Destroy()
            healthBar:Destroy()
        end)
    end

    -- Connect to existing players
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            onPlayerAdded(player)
        end
    end

    -- Connect to player joining
    Players.PlayerAdded:Connect(onPlayerAdded)
end

function esp.stop()
    esp.isActive = false
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            -- Clean up any ESP components
            local box = player.Character:FindFirstChildOfClass("BoxHandleAdornment")
            if box then
                box:Destroy()
            end
            local healthBarGui = player.Character:FindFirstChildOfClass("BillboardGui")
            if healthBarGui then
                healthBarGui:Destroy()
            end
        end
    end
end

return esp
