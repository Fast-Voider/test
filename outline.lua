-- Create a table to hold the ESP functionality
local OutlineESP = {}

-- Track enabled/disabled state and team check state
local espEnabled = false
local highlightInstances = {}
local teamCheck = false  -- Default is not to check teams

-- Get the local player (your player)
local localPlayer = game.Players.LocalPlayer

-- Function to check if a player is on the same team as the local player
local function isSameTeam(player)
    if not teamCheck then return false end  -- If teamCheck is off, ignore team comparison
    if player.Team == localPlayer.Team then
        return true
    end
    return false
end

-- Function to create an outline for a given model (like a player or NPC)
local function createOutline(target, player)
    -- Don't create an outline for the local player or same team players (if team check is enabled)
    if player == localPlayer or isSameTeam(player) then return end

    -- Create a Highlight instance
    local highlight = Instance.new("Highlight")
    highlight.Parent = target  -- Attach to the target model

    -- Customize the highlight to ONLY show the outline, no fill
    highlight.FillTransparency = 1  -- Fully transparent fill
    highlight.OutlineTransparency = 0  -- No transparency for the outline
    highlight.OutlineColor = Color3.new(1, 1, 1)  -- White outline color

    -- Ensure the outline is visible through walls
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop

    -- Store the highlight instance, keyed by the player it's applied to
    highlightInstances[player] = highlight
end

-- Function to remove the outline for a specific player
local function removeOutline(player)
    local highlight = highlightInstances[player]
    if highlight then
        highlight:Destroy()  -- Clean up the Highlight instance
        highlightInstances[player] = nil  -- Remove from the table
    end
end

-- Function to reapply the ESP outlines after a team check toggle
local function updateOutlines()
    -- Remove all existing outlines
    for player, _ in pairs(highlightInstances) do
        removeOutline(player)  -- Remove the highlight for each player
    end

    -- Reapply ESP to all players based on the current team check status
    for _, player in pairs(game.Players:GetPlayers()) do
        if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            createOutline(player.Character, player)
        end
    end
end

-- Function to handle a player's character spawning and apply the ESP
local function applyOutlineToPlayer(player)
    -- Apply ESP if the player is valid and not on the same team (if teamCheck is enabled)
    if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
        createOutline(player.Character, player)
    end

    -- Apply outline whenever the character respawns
    player.CharacterAdded:Connect(function(character)
        wait(1)  -- Optional: small delay to ensure all character parts are loaded
        createOutline(character, player)
    end)
end

-- Function to start the ESP
function OutlineESP.start()
    if espEnabled then return end  -- Prevent starting multiple times
    espEnabled = true

    -- Apply the ESP to all existing players
    for _, player in pairs(game.Players:GetPlayers()) do
        applyOutlineToPlayer(player)
    end

    -- Connect a function to apply ESP to players that join later
    game.Players.PlayerAdded:Connect(function(player)
        applyOutlineToPlayer(player)
    end)

    -- Remove ESP for players who leave the game
    game.Players.PlayerRemoving:Connect(function(player)
        removeOutline(player)  -- Remove the outline for that player's character
    end)
end

-- Function to stop the ESP
function OutlineESP.stop()
    if not espEnabled then return end  -- Prevent stopping multiple times
    espEnabled = false
    -- Clean up all highlights when ESP is disabled
    for _, highlight in pairs(highlightInstances) do
        if highlight then
            highlight:Destroy()
        end
    end
    highlightInstances = {}  -- Clear the table
end

-- Function to toggle the ESP on/off
function OutlineESP.Toggle()
    if espEnabled then
        OutlineESP.stop()
    else
        OutlineESP.start()
    end
end

-- Function to enable team checking (will only highlight enemies)
function OutlineESP.TeamCheckTrue()
    teamCheck = true
    if espEnabled then
        updateOutlines()  -- Reapply outlines based on the new teamCheck status
    end
end

-- Function to disable team checking (will highlight everyone except the local player)
function OutlineESP.TeamCheckFalse()
    teamCheck = false
    if espEnabled then
        updateOutlines()  -- Reapply outlines based on the new teamCheck status
    end
end

-- Function to toggle team checking on/off
function OutlineESP.TeamCheck()
    teamCheck = not teamCheck
    if espEnabled then
        updateOutlines()  -- Reapply outlines based on the new teamCheck status
    end
end

-- Return the module
return OutlineESP
