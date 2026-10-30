local playersService = game:GetService("Players")
local userInputService = game:GetService("UserInputService")
local runService = game:GetService("RunService")
local coreGui = game:GetService("CoreGui")
local localPlayer = playersService.LocalPlayer

local function safeCall(fn, ...)
    local args = { ... }
    local ok, result = pcall(fn, table.unpack(args))
    return ok and result or nil
end

if shared.ByteHitbox then
    pcall(function() shared.ByteHitbox.destroy() end)
end

local Hitbox = { enabled = false, sizeMultiplier = 2, transparency = 0.7, connections = {}, visuals = {} }
shared.ByteHitbox = Hitbox

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "ByteHitbox"
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
pcall(function() screenGui.Parent = coreGui end)
if not screenGui.Parent then screenGui.Parent = localPlayer:WaitForChild("PlayerGui") end

local main = Instance.new("Frame")
main.Size = UDim2.new(0, 240, 0, 220)
main.Position = UDim2.new(0, 20, 0, 20)
main.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
main.BorderSizePixel = 0
main.Active = true
main.Draggable = true
main.Parent = screenGui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 8)
corner.Parent = main

local stroke = Instance.new("UIStroke")
stroke.Color = Color3.fromRGB(80, 140, 255)
stroke.Thickness = 1.5
stroke.Parent = main

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 36)
title.BackgroundTransparency = 1
title.Text = "Byte • Hitbox"
title.TextColor3 = Color3.fromRGB(230, 230, 240)
title.Font = Enum.Font.GothamBold
title.TextSize = 15
title.Parent = main

local toggle = Instance.new("TextButton")
toggle.Size = UDim2.new(0, 200, 0, 32)
toggle.Position = UDim2.new(0, 20, 0, 44)
toggle.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
toggle.Text = "Hitbox: OFF"
toggle.TextColor3 = Color3.fromRGB(230, 230, 240)
toggle.Font = Enum.Font.Gotham
toggle.TextSize = 13
toggle.BorderSizePixel = 0
toggle.Parent = main

local toggleCorner = Instance.new("UICorner")
toggleCorner.CornerRadius = UDim.new(0, 6)
toggleCorner.Parent = toggle

local function makeSlider(labelText, yPos, minV, maxV, default, callback)
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0, 200, 0, 18)
    label.Position = UDim2.new(0, 20, 0, yPos)
    label.BackgroundTransparency = 1
    label.Text = labelText .. ": " .. tostring(default)
    label.TextColor3 = Color3.fromRGB(200, 200, 210)
    label.Font = Enum.Font.Gotham
    label.TextSize = 12
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = main

    local bar = Instance.new("Frame")
    bar.Size = UDim2.new(0, 200, 0, 8)
    bar.Position = UDim2.new(0, 20, 0, yPos + 22)
    bar.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
    bar.BorderSizePixel = 0
    bar.Parent = main

    local barCorner = Instance.new("UICorner")
    barCorner.CornerRadius = UDim.new(0, 4)
    barCorner.Parent = bar

    local fill = Instance.new("Frame")
    fill.Size = UDim2.new((default - minV) / (maxV - minV), 0, 1, 0)
    fill.BackgroundColor3 = Color3.fromRGB(80, 140, 255)
    fill.BorderSizePixel = 0
    fill.Parent = bar

    local fillCorner = Instance.new("UICorner")
    fillCorner.CornerRadius = UDim.new(0, 4)
    fillCorner.Parent = fill

    local dragging = false
    local c1 = bar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = true end
    end)
    local c2 = userInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
    end)
    local c3 = userInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local rel = math.clamp((input.Position.X - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1)
            local value = minV + (maxV - minV) * rel
            fill.Size = UDim2.new(rel, 0, 1, 0)
            label.Text = labelText .. ": " .. string.format("%.1f", value)
            callback(value)
        end
    end)
    table.insert(Hitbox.connections, c1)
    table.insert(Hitbox.connections, c2)
    table.insert(Hitbox.connections, c3)
end

makeSlider("Size Multiplier", 90, 1, 10, Hitbox.sizeMultiplier, function(v) Hitbox.sizeMultiplier = v end)
makeSlider("Transparency", 150, 0, 1, Hitbox.transparency, function(v) Hitbox.transparency = v end)

local function buildVisual(root)
    local id = tostring(root)
    local visual = Hitbox.visuals[id]
    if not visual or not visual.Parent then
        visual = Instance.new("Part")
        visual.Name = "ByteHB"
        visual.Anchored = true
        visual.CanCollide = false
        visual.CanQuery = false
        visual.CanTouch = false
        visual.Massless = true
        visual.Material = Enum.Material.ForceField
        visual.Color = Color3.fromRGB(80, 140, 255)
        visual.Transparency = Hitbox.transparency
        visual.Parent = workspace
        Hitbox.visuals[id] = visual
    end
    visual.Size = root.Size * Hitbox.sizeMultiplier
    visual.Transparency = Hitbox.transparency
    visual.CFrame = root.CFrame
end

local function clearVisuals()
    for id, visual in pairs(Hitbox.visuals) do
        pcall(function() visual:Destroy() end)
        Hitbox.visuals[id] = nil
    end
end

local function shouldVisualise(model)
    if not model or not model.Parent then return false end
    if model == localPlayer.Character then return false end
    if not model:FindFirstChildOfClass("Humanoid") then return false end
    return true
end

toggle.MouseButton1Click:Connect(function()
    Hitbox.enabled = not Hitbox.enabled
    toggle.Text = "Hitbox: " .. (Hitbox.enabled and "ON" or "OFF")
    toggle.BackgroundColor3 = Hitbox.enabled and Color3.fromRGB(60, 160, 100) or Color3.fromRGB(45, 45, 55)
    if not Hitbox.enabled then clearVisuals() end
end)

local heartbeatConn = runService.Heartbeat:Connect(function()
    if not Hitbox.enabled then return end
    for _, player in ipairs(playersService:GetPlayers()) do
        if player ~= localPlayer and player.Character then
            local model = player.Character
            if shouldVisualise(model) then
                local root = model:FindFirstChild("HumanoidRootPart")
                if root then buildVisual(root) end
            end
        end
    end
    for _, obj in ipairs(workspace:GetChildren()) do
        if obj:IsA("Model") and shouldVisualise(obj) then
            local root = obj:FindFirstChild("HumanoidRootPart") or obj.PrimaryPart
            if root then buildVisual(root) end
        end
    end
end)
table.insert(Hitbox.connections, heartbeatConn)

function Hitbox.destroy()
    pcall(clearVisuals)
    for _, c in ipairs(Hitbox.connections) do pcall(function() c:Disconnect() end) end
    Hitbox.connections = {}
    pcall(function() screenGui:Destroy() end)
    if shared.ByteHitbox == Hitbox then shared.ByteHitbox = nil end
end

localPlayer.OnTeleport:Connect(function(state)
    if state == Enum.TeleportState.Started then Hitbox.destroy() end
end)
