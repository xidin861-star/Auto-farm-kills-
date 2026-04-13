-- [[ UI NAME: AutoFarm KILL V11 ]] --
-- FIXED: เพิ่มระบบ Lock Camera กันหน้าจอเอ๋อ + ระบบจับเวลาฟาร์ม (HH:MM:SS)

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local lp = Players.LocalPlayer
local camera = workspace.CurrentCamera

-- ### 1. UI Setup (เพิ่มตัวเลขจับเวลา) ###
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "AutoFarm_KILL_V11"
ScreenGui.ResetOnSpawn = false 
ScreenGui.Parent = lp:WaitForChild("PlayerGui")

local Main = Instance.new("Frame")
Main.Size = UDim2.new(0, 200, 0, 140) -- ขยายขนาดนิดหน่อย
Main.Position = UDim2.new(0.5, -100, 0.5, -70)
Main.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
Main.Active = true
Main.Draggable = true 
Main.Parent = ScreenGui

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 30)
Title.Text = "AutoFarm KILL V11"
Title.TextColor3 = Color3.new(1, 1, 1)
Title.BackgroundColor3 = Color3.fromRGB(120, 0, 0)
Title.Parent = Main

local TimerLabel = Instance.new("TextLabel") -- ตัวนับเวลา
TimerLabel.Size = UDim2.new(1, 0, 0, 25)
TimerLabel.Position = UDim2.new(0, 0, 0, 30)
TimerLabel.Text = "00:00:00"
TimerLabel.TextColor3 = Color3.fromRGB(255, 255, 0)
TimerLabel.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
TimerLabel.Parent = Main

local Btn = Instance.new("TextButton")
Btn.Size = UDim2.new(0.9, 0, 0, 40)
Btn.Position = UDim2.new(0.05, 0, 0, 65)
Btn.Text = "START KILL"
Btn.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
Btn.TextColor3 = Color3.new(1, 1, 1)
Btn.Parent = Main

local LockCamBtn = Instance.new("TextButton") -- ปุ่มล็อคกล้อง
LockCamBtn.Size = UDim2.new(0.9, 0, 0, 25)
LockCamBtn.Position = UDim2.new(0.05, 0, 0, 110)
LockCamBtn.Text = "LOCK CAMERA: OFF"
LockCamBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
LockCamBtn.TextColor3 = Color3.new(1, 1, 1)
LockCamBtn.Parent = Main

-- ### 2. ระบบตัวแปรและฟังก์ชันกันบั๊ก ###
local isFarming = false
local currentTarget = nil
local canClick = true
local isCamLocked = false
local lockedCFrame = nil
local startTime = 0
local totalSeconds = 0

-- [ระบบจับเวลา]
task.spawn(function()
    while true do
        if isFarming then
            totalSeconds = totalSeconds + 1
            local hours = math.floor(totalSeconds / 3600)
            local minutes = math.floor((totalSeconds % 3600) / 60)
            local seconds = totalSeconds % 60
            TimerLabel.Text = string.format("%02d:%02d:%02d", hours, minutes, seconds)
        end
        task.wait(1)
    end
end)

-- [ระบบล็อคกล้อง]
RunService.RenderStepped:Connect(function()
    if isCamLocked and lockedCFrame then
        camera.CFrame = lockedCFrame
    end
end)

LockCamBtn.MouseButton1Click:Connect(function()
    isCamLocked = not isCamLocked
    if isCamLocked then
        lockedCFrame = camera.CFrame -- เก็บตำแหน่งที่หันอยู่ตอนนั้น
        LockCamBtn.Text = "LOCK CAMERA: ON"
        LockCamBtn.BackgroundColor3 = Color3.fromRGB(0, 120, 0)
    else
        lockedCFrame = nil
        LockCamBtn.Text = "LOCK CAMERA: OFF"
        LockCamBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    end
end)

-- ### 3. ระบบโจมตี ###
-- [เลนต่อย M1]
task.spawn(function()
    while true do
        if isFarming and currentTarget then
            pcall(function()
                local char = lp.Character
                local remote = char and char:FindFirstChild("Communicate")
                if remote then
                    remote:FireServer({["Goal"] = "LeftClick", ["Mobile"] = true})
                    remote:FireServer({["Goal"] = "LeftClickRelease", ["Mobile"] = true})
                end
            end)
        end
        task.wait(0.01)
    end
end)

-- [เลนสกิล]
task.spawn(function()
    while true do
        if isFarming and currentTarget then
            pcall(function()
                local char = lp.Character or lp.CharacterAdded:Wait()
                local backpack = lp:FindFirstChild("Backpack")
                local remote = char:FindFirstChild("Communicate")
                
                if char and backpack and remote then
                    for _, tool in pairs(backpack:GetChildren()) do
                        if not isFarming then break end 
                        if tool:IsA("Tool") and tool.Name ~= "Wallet" then
                            tool.Parent = char
                            task.wait(0.05)
                            remote:FireServer({["Goal"] = "NormalClick", ["Tool"] = tool})
                            task.wait(0.12)
                            if tool.Parent == char then
                                tool.Parent = backpack
                            end
                        end
                    end
                end
            end)
        end
        task.wait(0.5)
    end
end)

-- ### 4. ปุ่มเปิด/ปิดฟาร์ม ###
Btn.MouseButton1Click:Connect(function()
    if not canClick then return end
    canClick = false
    isFarming = not isFarming
    
    if isFarming then
        Btn.Text = "FARMING..."
        Btn.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
    else
        currentTarget = nil
        Btn.Text = "START KILL"
        Btn.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
    end
    
    task.wait(0.5)
    canClick = true
end)

-- ### 5. ระบบวาร์ปมุดดิน (-5.7) ###
RunService.Heartbeat:Connect(function()
    if isFarming then
        if not currentTarget or not currentTarget.Parent or not currentTarget.Character or not currentTarget.Character:FindFirstChild("Humanoid") or currentTarget.Character.Humanoid.Health <= 0 then
            local plrs = {}
            for _, p in pairs(Players:GetPlayers()) do
                if p ~= lp and p.Character and p.Character:FindFirstChild("Humanoid") and p.Character.Humanoid.Health > 0 then
                    table.insert(plrs, p)
                end
            end
            currentTarget = #plrs > 0 and plrs[math.random(1, #plrs)] or nil
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
