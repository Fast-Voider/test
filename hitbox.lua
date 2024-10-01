-- HITBOX with team check, resizing, and reset for local player's team, and skipping local player resizing
local player = game.Players.LocalPlayer
local runService = game:GetService("RunService")

-- Hitbox table to encapsulate functionality
local hitbox = {}
hitbox.enabled = false
local resizingCoroutine -- For stopping the loop when toggled off

-- Function to resize head
local function resizeHead(part)
    if part then
        part.Size = Vector3.new(5, 5, 5)
        part.Transparency = 0
    end
end

-- Function to reset head size (for your team)
local function resetHeadSize(part)
    if part then
        part.Size = Vector3.new(1, 1, 1)
        part.Transparency = 0
    end
end

-- Function to check if the part is already resized
local function stopResizing(part)
    if part then
        return part.Size == Vector3.new(5, 5, 5)
    end
    return false
end

-- Function to manage the resizing loop
local function manageHitbox()
    while hitbox.enabled do
        -- Track teams for printing later
        local resizedTeams = {}
        local notResizedTeam = player.Team and player.Team.Name or "No Team"

        -- Resize heads of other players, and reset head size for local player's team
        for _, v in ipairs(game.Players:GetPlayers()) do
            if v.Character then
                local otherPlayerTeam = v.Team
                local myTeam = player.Team
                local otherHead = v.Character:FindFirstChild("Head")

                -- Skip resizing for the local player (yourself)
                if v == player then
                    if stopResizing(otherHead) then
                        resetHeadSize(otherHead)
                    end
                elseif otherPlayerTeam and myTeam and otherPlayerTeam ~= myTeam then
                    -- Resize heads of players not on your team
                    if otherHead and not stopResizing(otherHead) then
                        resizeHead(otherHead)

                        -- Track the team name to avoid duplication in printing
                        if not resizedTeams[otherPlayerTeam.Name] then
                            resizedTeams[otherPlayerTeam.Name] = true
                        end
                    end
                elseif otherPlayerTeam == myTeam then
                    -- Reset the head size for players on your team
                    if otherHead and stopResizing(otherHead) then
                        resetHeadSize(otherHead)
                    end
                end
            end
        end
        wait(5) -- a small delay to prevent excessive loop iteration; adjust based on your device performance
    end
end

-- Toggle function
function hitbox.toggle()
    hitbox.enabled = not hitbox.enabled
    if hitbox.enabled then
        resizingCoroutine = coroutine.create(manageHitbox)
        coroutine.resume(resizingCoroutine)
    else
        hitbox.enabled = false
    end
end

return hitbox
