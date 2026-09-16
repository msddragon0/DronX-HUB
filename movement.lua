local TweenService = game:GetService("TweenService")

getgenv().snapToNPC = function(npc)
    local hrp = npc:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    getgenv().root.CFrame = hrp.CFrame * CFrame.new(0, 0, -5)
end

getgenv().tweenTo = function(targetCFrame, speed)
    speed = speed or 300
    local dist = (targetCFrame.Position - getgenv().root.Position).Magnitude
    local info = TweenInfo.new(dist / speed, Enum.EasingStyle.Linear)
    local tw   = TweenService:Create(getgenv().root, info, {CFrame = targetCFrame})
    tw:Play()
    tw.Completed:Wait()
end
