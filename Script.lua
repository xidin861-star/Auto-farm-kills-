-- [[ UI NAME: AUTO FARM KILL ]] --
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local lp = Players.LocalPlayer

-- ### 1. UI Setup (ลากได้ / ตายไม่หาย) ###
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "AUTO_FARM_KILL_FINAL"
ScreenGui.ResetOnSpawn = false 
ScreenGui.Parent = lp:WaitForChild("PlayerGui")

local Main = Instance.new("Frame")
Main.Size = UDim2.new(0, 180, 0, 100)
Main.Position = UDim2.new(0.5, -90, 0.5, -50)
Main.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
Main.Active = true
Main.Draggable = true 
Main.Parent = ScreenGui

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 30)
Title.Text = "AUTO FARM KILL (ZERO)"
Title.TextColor3 = Color3.new(1, 1, 1)
Title.BackgroundColor3 = Color3.fromRGB(80, 0, 0)
Title.Parent = Main

local Btn = Instance.new("TextButton")
Btn.Size = UDim2.new(0.9, 0, 0.5, 0)
Btn.Position = UDim2.new(0.05, 0, 0.4, 0)
Btn.Text = "START KILL"
Btn.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
Btn.TextColor3 = Color3.new(1, 1, 1)
Btn.Parent = Main

-- ### 2. ระบบโจมตี (ZERO DELAY - NO TIME) ###
local isFarming = false
local currentTarget = nil

-- [ฟังก์ชันต่อย M1 - รันแยกเลนอิสระตลอดเวลา]
task.spawn(function()
    while true do
        if isFarming and currentTarget then
            local char = lp.Character
            local remote = char and char:FindFirstChild("Communicate")
            if remote then
                -- ส่งรหัสตีรัวๆ แบบไม่มี Time คั่น (Zero Delay)
                remote:FireServer({["Goal"] = "LeftClick", ["Mobile"] = true})
                remote:FireServer({["Goal"] = "LeftClickRelease", ["Mobile"] = true})
            end
        end
        task.wait() -- ใช้ค่า Delay ต่ำสุดของระบบ (ประมาณ 0.01)
    end
end)

-- [ฟังก์ชันวนสกิล - รันแยกเลน]
task.spawn(function()
    while true do
        if isFarming and currentTarget then
            local char = lp.Character
            local remote = char and char:FindFirstChild("Communicate")
            if remote then
                for _, tool in pairs(lp.Backpack:GetChildren()) do
                    if tool:IsA("Tool") and tool.Name ~= "Wallet" then
                        tool.Parent = char
                        remote:FireServer({["Goal"] = "NormalClick", ["Tool"] = tool})
                        task.wait(0.05) -- ลบ Time เหลือแค่เสี้ยวเดียวเพื่อให้ท่าออก
                        tool.Parent = lp.Backpack
                    end
                end
            end
        end
        task.wait(0.1)
    end
end)

-- ### 3. ระบบวาร์ปมุดดินนอนราบ (-5.5) ###
Btn.MouseButton1Click:Connect(function()
    isFarming = not isFarming
    Btn.Text = isFarming and "FARMING..." or "START KILL"
    Btn.BackgroundColor3 = isFarming and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(150, 0, 0)
    if not isFarming then currentTarget = nil end
end)

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
            -- มุดดินนอนราบ -5.5
            myHrp.CFrame = tHrp.CFrame * CFrame.new(0, -5.5, 0) * CFrame.Angles(math.rad(90), 0, 0)
            myHrp.Velocity = Vector3.new(0, 0, 0)
        end
    end
end)
