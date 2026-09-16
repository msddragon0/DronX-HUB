local Players = game:GetService("Players")
local VirtualUser = game:GetService("VirtualUser")

getgenv().player = Players.LocalPlayer
getgenv().char, getgenv().root, getgenv().hum = nil, nil, nil

local function fetchChar()
    getgenv().char = getgenv().player.Character or getgenv().player.CharacterAdded:Wait()
    getgenv().root = getgenv().char:WaitForChild("HumanoidRootPart")
    getgenv().hum  = getgenv().char:WaitForChild("Humanoid")
end

fetchChar()
getgenv().player.CharacterAdded:Connect(function()
    task.wait(1)
    fetchChar()
end)

getgenv().checkGround = function()
    local params = RaycastParams.new()
    params.FilterDescendantsInstances = {getgenv().char}
    local result = workspace:Raycast(getgenv().root.Position, Vector3.new(0, -20, 0), params)
    if not result then
        getgenv().root.CFrame = getgenv().root.CFrame + Vector3.new(0, 10, 0)
    end
end

getgenv().antiAfk = function()
    pcall(function()
        VirtualUser:CaptureController()
        VirtualUser:Button1Down(Vector2.new(0,0))
        task.wait(0.05)
        VirtualUser:Button1Up(Vector2.new(0,0))
    end)
end
