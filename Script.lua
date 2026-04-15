-- [[ UI NAME: AutoFarm KILL V15 ]] --
-- FIXED: เพิ่มระบบกด G อัตโนมัติ (ไม่เช็คชื่อเกจ) + ระบบเดิมของน้องครบ 100%

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local lp = Players.LocalPlayer
local camera = workspace.CurrentCamera

-- ### 1. UI Setup (โครงเดิมของน้องเป๊ะๆ) ###
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "AutoFarm_KILL_V15"
ScreenGui.ResetOnSpawn = false 
ScreenGui.Parent = lp:WaitForChild("PlayerGui")

local WhiteFrame = Instance.new("Frame")
WhiteFrame.Size = UDim2.new(2, 0, 2, 0); WhiteFrame.Position = UDim2.new(-0.5, 0, -0.5, 0)
WhiteFrame.BackgroundColor3 = Color3.new(1, 1, 1); WhiteFrame.Visible = false; WhiteFrame.ZIndex = -1; WhiteFrame.Parent = ScreenGui

local Main = Instance.new("Frame")
Main.Size = UDim2.new(0, 200, 0, 210); Main.Position = UDim2.new(0.5, -100, 0.5, -105)
Main.BackgroundColor3 = Color3.fromRGB(15, 15, 15); Main.Active = true; Main.Draggable = true; Main.Parent = ScreenGui

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 30); Title.Text = "AutoFarm KILL V15"; Title.TextColor3 = Color3.new(1, 1, 1); Title.BackgroundColor3 = Color3.fromRGB(120, 0, 0); Title.Parent = Main

local TimerLabel = Instance.new("TextLabel")
TimerLabel.Size = UDim2.new(1, 0, 0, 25); TimerLabel.Position = UDim2.new(0, 0, 0, 30); TimerLabel.Text = "00:00:00"; TimerLabel.TextColor3 = Color3.fromRGB(255, 255, 0); TimerLabel.BackgroundColor3 = Color3.fromRGB(30, 30, 30); TimerLabel.Parent = Main

local TargetLabel = Instance.new("TextLabel")
TargetLabel.Size = UDim2.new(1, 0, 0, 40); TargetLabel.Position = UDim2.new(0, 0, 0, 55); TargetLabel.Text = "Target: None"; TargetLabel.TextColor3 = Color3.fromRGB(0, 255, 0); TargetLabel.BackgroundColor3 = Color3.fromRGB(20, 20, 20); TargetLabel.Parent = Main

local Btn = Instance.new("TextButton")
Btn.Size = UDim2.new(0.9, 0, 0, 30); Btn.Position = UDim2.new(0.05, 0, 0, 100); Btn.Text = "START KILL"; Btn.BackgroundColor3 = Color3.fromRGB(150, 0, 0); Btn.TextColor3 = Color3.new(1, 1, 1); Btn.Parent = Main

local WhiteBtn = Instance.new("TextButton")
WhiteBtn.Size = UDim2.new(0.9, 0, 0, 25); WhiteBtn.Position = UDim2.new(0.05, 0, 0, 135); WhiteBtn.Text = "WHITE SCREEN: OFF"; WhiteBtn.BackgroundColor3 = Color3.fromRGB(80, 80, 80); WhiteBtn.TextColor3 = Color3.new(1, 1, 1); WhiteBtn.Parent = Main

local LockCamBtn = Instance.new("TextButton")
LockCamBtn.Size = UDim2.new(0.9, 0, 0, 25); LockCamBtn.Position = UDim2.new(0.05, 0, 0, 165); LockCamBtn.Text = "LOCK CAMERA: OFF"; LockCamBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50); LockCamBtn.TextColor3 = Color3.new(1, 1, 1); LockCamBtn.Parent = Main

-- ### 2. ระบบตัวแปร + ระบบจับเวลา (โครงเดิม) ###
local isFarming = false
local currentTarget = nil
local canClick = true
local isCamLocked = false
local lockedCFrame = nil
local totalSeconds = 0

local function GetLowestKillPlayer()
    local target = nil
    local lowestKills = math.huge
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= lp and p.Character and p.Character:FindFirstChild("Humanoid") and p.Character.Humanoid.Health > 0 then
            local kills = 0
            local stats = p:FindFirstChild("leaderstats")
            if stats then
                local killStat = stats:FindFirstChild("Kills") or stats:FindFirstChild("Kill")
                if killStat then kills = killStat.Value end
            end
            if kills < lowestKills then lowestKills = kills; target = p end
        end
    end
    return target
end

task.spawn(function()
    while true do
        if isFarming then
            totalSeconds = totalSeconds + 1
            local hours, minutes, seconds = math.floor(totalSeconds / 3600), math.floor((totalSeconds % 3600) / 60), totalSeconds % 60
            TimerLabel.Text = string.format("%02d:%02d:%02d", hours, minutes, seconds)
        end
        task.wait(1)
    end
end)

WhiteBtn.MouseButton1Click:Connect(function()
    WhiteFrame.Visible = not WhiteFrame.Visible
    WhiteBtn.Text = WhiteFrame.Visible and "WHITE SCREEN: ON" or "WHITE SCREEN: OFF"
end)

RunService.RenderStepped:Connect(function() if isCamLocked and lockedCFrame then camera.CFrame = lockedCFrame end end)
LockCamBtn.MouseButton1Click:Connect(function()
    isCamLocked = not isCamLocked
    lockedCFrame = isCamLocked and camera.CFrame or nil
    LockCamBtn.Text = isCamLocked and "LOCK CAMERA: ON" or "LOCK CAMERA: OFF"
end)

-- ### 3. ระบบโจมตี (แทรกระบบกด G อัตโนมัติเข้าไป) ###

-- [ ระบบกด G อัตโนมัติ: ย้ำปุ่มทุก 1.5 วินาทีเพื่อให้แปลงร่าง Scorching Blade เอง ]
task.spawn(function()
    while true do
        if isFarming then
            pcall(function()
                local remote = lp.Character:FindFirstChild("Communicate")
                if remote then
                    -- ส่งคำสั่งกด G แบบ Safe Mode (ไม่มีเลขเวลา)
                    remote:FireServer({["Goal"] = "KeyPress", ["Key"] = Enum.KeyCode.G})
                end
            end)
        end
        task.wait(1.2 + math.random() * 0.6) -- สุ่มเวลาเล็กน้อยเพื่อให้เนียนเหมือนคนกด
    end
end)

-- [ ต่อยรัว 0.01s (โครงเดิมของน้อง) ]
task.spawn(function()
    while true do
        if isFarming and currentTarget then
            pcall(function()
                local remote = lp.Character:FindFirstChild("Communicate")
                if remote then
                    remote:FireServer({["Goal"] = "LeftClick", ["Mobile"] = true})
                    remote:FireServer({["Goal"] = "LeftClickRelease", ["Mobile"] = true})
                end
            end)
        end
        task.wait(0.01)
    end
end)

-- [ ออโต้กดสกิลจากกระเป๋า (โครงเดิมของน้อง) ]
task.spawn(function()
    while true do
        if isFarming and currentTarget then
            pcall(function()
                local char = lp.Character; local backpack = lp:FindFirstChild("Backpack"); local remote = char:FindFirstChild("Communicate")
                if char and backpack and remote then
                    for _, tool in pairs(backpack:GetChildren()) do
                        if not isFarming then break end 
                        if tool:IsA("Tool") and tool.Name ~= "Wallet" then
                            tool.Parent = char; task.wait(0.05)
                            remote:FireServer({["Goal"] = "NormalClick", ["Tool"] = tool})
                            task.wait(0.12); if tool.Parent == char then tool.Parent = backpack end
                        end
                    end
                end
            end)
        end
        task.wait(0.5)
    end
end)

-- ### 4. ระบบไล่ล่ากัดไม่ปล่อย (โครงเดิมของน้องเป๊ะๆ) ###
RunService.Heartbeat:Connect(function()
    if isFarming then
        if not currentTarget or not currentTarget.Parent or not currentTarget.Character or not currentTarget.Character:FindFirstChild("Humanoid") or currentTarget.Character.Humanoid.Health <= 0 then
            local nextTarget = GetLowestKillPlayer()
            if nextTarget then
                currentTarget = nextTarget
                TargetLabel.Text = "Targeting: " .. currentTarget.Name
            else
                local allPlrs = Players:GetPlayers()
                if #allPlrs > 1 then
                    currentTarget = allPlrs[math.random(1, #allPlrs)]
                    while currentTarget == lp do currentTarget = allPlrs[math.random(1, #allPlrs)] end
                    TargetLabel.Text = "Random Kill: " .. currentTarget.Name
                end
            end
            return
        end

        local myHrp = lp.Character and lp.Character:FindFirstChild("HumanoidRootPart")
        local tHrp = currentTarget.Character:FindFirstChild("HumanoidRootPart")
        if myHrp and tHrp then
            myHrp.CFrame = tHrp.CFrame * CFrame.new(0, -5.7, 0) * CFrame.Angles(math.rad(90), 0, 0)
            myHrp.Velocity = Vector3.new(0, 0, 0)
        end
    end
end)

Btn.MouseButton1Click:Connect(function()
    if not canClick then return end
    canClick = false; isFarming = not isFarming
    if isFarming then
        Btn.Text = "FARMING..."; Btn.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
    else
        currentTarget = nil; TargetLabel.Text = "Target: None"; totalSeconds = 0
        Btn.Text = "START KILL"; Btn.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
    end
    task.wait(0.5); canClick = true
end)
