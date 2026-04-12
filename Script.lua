-- [[ UI NAME: AUTO FARM KILL ]] --
-- FIXED: สกิลไม่ทำงานหลังเกิดใหม่ + เพิ่มระบบ Re-check Character

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local lp = Players.LocalPlayer

-- ### 1. UI Setup (ลากได้ / ตายไม่หาย) ###
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "AUTO_FARM_KILL_V5"
ScreenGui.ResetOnSpawn = false 
ScreenGui.Parent = lp:WaitForChild("PlayerGui")

local Main = Instance.new("Frame")
Main.Size = UDim2.new(0, 180, 0, 100)
Main.Position = UDim2.new(0.5, -90, 0.5, -50)
Main.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
Main.Active = true
Main.Draggable = true 
Main.Parent = ScreenGui

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 30)
Title.Text = "AUTO FARM KILL"
Title.TextColor3 = Color3.new(1, 1, 1)
Title.BackgroundColor3 = Color3.fromRGB(100, 0, 0)
Title.Parent = Main

local Btn = Instance.new("TextButton")
Btn.Size = UDim2.new(0.9, 0, 0.5, 0)
Btn.Position = UDim2.new(0.05, 0, 0.4, 0)
Btn.Text = "START KILL"
Btn.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
Btn.TextColor3 = Color3.new(1, 1, 1)
Btn.Parent = Main

-- ### 2. ระบบโจมตี (ZERO DELAY + REFRESH LOGIC) ###
local isFarming = false
local currentTarget = nil

-- [เลนต่อย M1 - รันตลอดกาล]
task.spawn(function()
    while true do
        if isFarming and currentTarget then
            local char = lp.Character
            local remote = char and char:FindFirstChild("Communicate")
            if remote then
                remote:FireServer({["Goal"] = "LeftClick", ["Mobile"] = true})
                remote:FireServer({["Goal"] = "LeftClickRelease", ["Mobile"] = true})
            end
        end
        task.wait(0.01)
    end
end)

-- [เลนสกิล - แก้บั๊กตายแล้วไม่ใช้สกิล]
task.spawn(function()
    while true do
        if isFarming and currentTarget then
            local char = lp.Character
            local backpack = lp:FindFirstChild("Backpack")
            local remote = char and char:FindFirstChild("Communicate")
            
            -- ถ้ามีตัวละครและมีกระเป๋าถึงจะทำงาน
            if char and backpack and remote then
                for _, tool in pairs(backpack:GetChildren()) do
                    if tool:IsA("Tool") and tool.Name ~= "Wallet" then
                        -- บังคับถือและใช้
                        tool.Parent = char
                        task.wait(0.05)
                        remote:FireServer({["Goal"] = "NormalClick", ["Tool"] = tool})
                        task.wait(0.1) -- รอจังหวะใช้จบนิดนึง
                        if tool.Parent == char then
                            tool.Parent = backpack -- ดีดกลับเข้าเป๋า
                        end
                    end
                end
            end
        end
        task.wait(0.2) -- หน่วงนิดนึงกันสคริปต์หลุดลูปตอนตาย
    end
end)

-- ### 3. ระบบวาร์ป (มุดดินนอนราบ -5.8) ###
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
            -- มุดดินนอนราบระยะ -5.7 ตามสั่ง
            myHrp.CFrame = tHrp.CFrame * CFrame.new(0, -5.7, 0) * CFrame.Angles(math.rad(90), 0, 0)
            myHrp.Velocity = Vector3.new(0, 0, 0)
        end
    end
end)
