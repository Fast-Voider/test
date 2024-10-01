local OutlineESP = {}
local players = game:GetService("Players")
local runService = game:GetService("RunService")
local camera = workspace.CurrentCamera

local espEnabled = false
local outlines = {}

-- Function to create the outline for a character
local function createOutline()
    local outline = Drawing.new("Quad")
    outline.Color = Color3.fromRGB(0, 255, 0)  -- Green outline color
    outline.Thickness = 2
    outline.Transparency = 1
    outline.Visible = false
    return outline
end

-- Function to update the outline around the player's character
local function drawOutline(character)
    if not character then return end

    local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
    if humanoidRootPart then
        -- Create an outline if not already created
        outlines[character] = outlines[character] or createOutline()

        local rootScreenPos, rootVisible = camera:WorldToViewportPoint(humanoidRootPart.Position)

        -- Check if the character is in front of the camera and visible
        if rootVisible and rootScreenPos.Z > 0 then
            local size = character:GetExtentsSize()

            -- Get the screen positions for the four corners of the bounding box
            local topLeft = camera:WorldToViewportPoint(humanoidRootPart.Position + Vector3.new(-size.X/2, size.Y/2, 0))
            local topRight = camera:WorldToViewportPoint(humanoidRootPart.Position + Vector3.new(size.X/2, size.Y/2, 0))
            local bottomLeft = camera:WorldToViewportPoint(humanoidRootPart.Position + Vector3.new(-size.X/2, -size.Y/2, 0))
            local bottomRight = camera:WorldToViewportPoint(humanoidRootPart.Position + Vector3.new(size.X/2, -size.Y/2, 0))

            -- Update the outline position based on the viewport
            outlines[character].PointA = Vector2.new(topLeft.X, topLeft.Y)
            outlines[character].PointB = Vector2.new(topRight.X, topRight.Y)
            outlines[character].PointC = Vector2.new(bottomRight.X, bottomRight.Y)
            outlines[character].PointD = Vector2.new(bottomLeft.X, bottomLeft.Y)
            outlines[character].Visible = true
        else
            -- Hide the outline if the character is off-screen or behind the camera
            outlines[character].Visible = false
        end
    else
        -- If the character or HumanoidRootPart is missing, hide the outline
        if outlines[character] then
            outlines[character].Visible = false
        end
    end
end

-- Function to update the outlines for all players
local function updateOutlineESP()
    while espEnabled do
        for _, player in pairs(players:GetPlayers()) do
            if player ~= players.LocalPlayer and player.Character then
                drawOutline(player.Character)
            end
        end
        runService.RenderStepped:Wait() -- Update every frame
    end
end

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
        outline.Visible = false
        outline:Remove()  -- Properly remove the drawing object
    end
    -- Clear the outlines table
    outlines = {}
end

return OutlineESP
