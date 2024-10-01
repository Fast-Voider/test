-- HITBOX script with toggle functionality
local hitbox = {}
hitbox.enabled = false
local player = game.Players.LocalPlayer

-- Function to resize head
local function resizeHead(part)
    if part then
        part.Size = Vector3.new(5, 5, 5)
        part.Transparency = 0
    end
end

-- Function to reset head size
local function resetHeadSize(part)
    if part then
        part.Size = Vector3.new(1, 1, 1)
        part.Transparency = 0
    end
end

-- Function to check if the part is already resized
local function isResized(part)
    return part and part.Size == Vector3.new(5, 5, 5)
end

-- Function to handle the hitbox logic
local function hitboxLoop()
    while hitbox.enabled do
        for _, v in ipairs(game.Players:GetPlayers()) do
            if v.Character then
                local head = v.Character:FindFirstChild("Head")
                if head then
                    if v.Team ~= player.Team then
                        if not isResized(head) then
                            resizeHead(head)
                        end
                    else
                        if isResized(head) then
                            resetHeadSize(head)
                        end
                    end
                end
            end
        end
        wait(5)
    end
end

-- Function to reset all heads when hitbox is toggled off
local function resetAllHeads()
    for _, v in ipairs(game.Players:GetPlayers()) do
        if v.Character then
            local head = v.Character:FindFirstChild("Head")
            if head and isResized(head) then
                resetHeadSize(head)
            end
        end
    end
end

-- Toggle function
function hitbox.toggle()
    hitbox.enabled = not hitbox.enabled
    if hitbox.enabled then
        spawn(hitboxLoop)
    else
        -- Reset all heads when toggling off
        resetAllHeads()
    end
end

return hitbox
