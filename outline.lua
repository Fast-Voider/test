local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- Function to create ESP for a player
local function createESP(player)
    if player ~= LocalPlayer then
        local character = player.Character
        if character and character:FindFirstChild("HumanoidRootPart") then
            local humanoidRootPart = character.HumanoidRootPart
            local head = character:FindFirstChild("Head")
            local humanoid = character:FindFirstChild("Humanoid")

            -- Create BillboardGui for username and health percentage
            local billboardGui = Instance.new("BillboardGui")
            billboardGui.Adornee = head
            billboardGui.Size = UDim2.new(0, 100, 0, 50)
            billboardGui.AlwaysOnTop = true
            billboardGui.StudsOffset = Vector3.new(0, 3, 0)

            -- Add username label
            local usernameLabel = Instance.new("TextLabel", billboardGui)
            usernameLabel.Size = UDim2.new(1, 0, 0.5, 0)
            usernameLabel.BackgroundTransparency = 1
            usernameLabel.Text = player.Name
            usernameLabel.TextColor3 = Color3.new(1, 1, 1) -- White color
            usernameLabel.TextStrokeTransparency = 0.5
            usernameLabel.TextScaled = true

            -- Add health percentage label
            local healthLabel = Instance.new("TextLabel", billboardGui)
            healthLabel.Size = UDim2.new(1, 0, 0.5, 0)
            healthLabel.Position = UDim2.new(0, 0, 0.5, 0)
            healthLabel.BackgroundTransparency = 1
            healthLabel.TextColor3 = Color3.new(0, 1, 0) -- Green color for health percentage
            healthLabel.TextStrokeTransparency = 0.5
            healthLabel.TextScaled = true

            -- Create a health bar
            local healthBar = Instance.new("Frame", billboardGui)
            healthBar.Size = UDim2.new(0.2, 0, 1, 0) -- Health bar size
            healthBar.Position = UDim2.new(1.1, 0, 0, 0) -- Position it to the right of the character
            healthBar.BackgroundTransparency = 0.3
            healthBar.BackgroundColor3 = Color3.new(1, 0, 0) -- Red color for health bar background

            local healthBarFill = Instance.new("Frame", healthBar)
            healthBarFill.Size = UDim2.new(humanoid.Health / humanoid.MaxHealth, 0, 1, 0) -- Set based on current health
            healthBarFill.BackgroundColor3 = Color3.new(0, 1, 0) -- Green color for health bar fill

            -- 3D Box ESP
            local boxAdornment = Instance.new("BoxHandleAdornment")
            boxAdornment.Adornee = humanoidRootPart
            boxAdornment.Size = humanoidRootPart.Size + Vector3.new(1, 2, 1)
            boxAdornment.AlwaysOnTop = true
            boxAdornment.ZIndex = 5
            boxAdornment.Color3 = Color3.new(0, 1, 0) -- Green box color
            boxAdornment.Transparency = 0.3
            boxAdornment.Parent = humanoidRootPart

            -- Update health and box constantly
            local function updateESP()
                while character and character.Parent do
                    healthBarFill.Size = UDim2.new(humanoid.Health / humanoid.MaxHealth, 0, 1, 0)
                    healthLabel.Text = math.floor((humanoid.Health / humanoid.MaxHealth) * 100) .. "%"
                    boxAdornment.Size = humanoidRootPart.Size + Vector3.new(1, 2, 1) -- Keeps box size updated
                    wait(0.1)
                end
            end

            -- Cleanup ESP when player dies or leaves
            humanoid.Died:Connect(function()
                billboardGui:Destroy()
                boxAdornment:Destroy()
            end)

            -- Parent everything to character
            billboardGui.Parent = character
            boxAdornment.Parent = character

            spawn(updateESP)
        end
    end
end

-- Function to remove ESP
local function removeESP(player)
    if player.Character then
        for _, v in pairs(player.Character:GetChildren()) do
            if v:IsA("BillboardGui") or v:IsA("BoxHandleAdornment") then
                v:Destroy()
            end
        end
    end
end

-- Enable ESP for all players
local function enableESP()
    for _, player in pairs(Players:GetPlayers()) do
        createESP(player)
    end

    -- Add ESP to new players joining
    Players.PlayerAdded:Connect(function(player)
        player.CharacterAdded:Connect(function()
            createESP(player)
        end)
    end)
end

-- Disable ESP for all players
local function disableESP()
    for _, player in pairs(Players:GetPlayers()) do
        removeESP(player)
    end
end

