-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

-- Variables
local localPlayer = Players.LocalPlayer
local toggleEnabled = false
local activeConnection

-- Function to get the nearest player
local function getNearestPlayer()
    local nearestPlayer = nil
    local shortestDistance = math.huge -- Start with a large distance
    
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= localPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local distance = (player.Character.HumanoidRootPart.Position - localPlayer.Character.HumanoidRootPart.Position).Magnitude
            if distance < shortestDistance then
                shortestDistance = distance
                nearestPlayer = player
            end
        end
    end
    
    return nearestPlayer
end

-- Function to teleport to nearest player
local function teleportToNearestPlayer()
    if localPlayer.Character and localPlayer.Character:FindFirstChild("HumanoidRootPart") then
        local nearestPlayer = getNearestPlayer()
        if nearestPlayer and nearestPlayer.Character and nearestPlayer.Character:FindFirstChild("HumanoidRootPart") then
            -- Set the local player's CFrame to the nearest player's CFrame
            localPlayer.Character.HumanoidRootPart.CFrame = nearestPlayer.Character.HumanoidRootPart.CFrame + Vector3.new(3, 0, 0) -- Offset by 3 studs to avoid overlap
        end
    end
end

-- Function to toggle the teleportation
local function Toggle()
    toggleEnabled = not toggleEnabled
    
    if toggleEnabled then
        -- Start teleporting to the nearest player every frame
        activeConnection = RunService.Heartbeat:Connect(function()
            teleportToNearestPlayer()
        end)
    else
        -- Stop teleporting
        if activeConnection then
            activeConnection:Disconnect()
            activeConnection = nil
        end
    end
end

-- Return an object with the Toggle method
return {
    Toggle = Toggle
}
