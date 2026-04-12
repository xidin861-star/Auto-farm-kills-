-- [[ UI NAME: AUTO FARM KILL V6 ]] --
-- FIXED: ปิดแล้วเปิดใหม่สกิลไม่ค้าง + ตายแล้วเกิดใหม่สกิลยังอยู่

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local lp = Players.LocalPlayer

-- ### 1. UI Setup (คงเดิม) ###
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "AUTO_FARM_KILL_V6"
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
Title.Text = "AFK ZERO V6"
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

-- ### 2. ระบบโจมตี (FORCE RESET LOGIC) ###
local isFarming = false
local currentTarget = nil

-- [เลนต่อย M1]
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

-- [เลนสกิล - แก้บั๊กปิดแล้วเปิดใหม่ไม่ทำงาน]
task.spawn(function()
    while true do
        if isFarming then -- เช็คว่าเปิดฟาร์มอยู่ไหม
            if currentTarget then
                local char = lp.Character
                local backpack = lp:FindFirstChild("Backpack")
                local remote = char and char:FindFirstChild("Communicate")
                
                if char and backpack and remote then
                    local tools = backpack:GetChildren()
                    if #tools > 0 then
                        for _, tool in pairs(tools) do
                            if not isFarming then break end -- ถ้ากดปิดปุ๊บ ให้หยุดลูปสกิลทันที
                            if tool:IsA("Tool") and tool.Name ~= "Wallet" then
                                tool.Parent = char
                                task.wait(0.05)
                                remote:FireServer({["Goal"] = "NormalClick", ["Tool"] = tool})
                                task.wait(0.1)
                                if tool.Parent == char then
                                    tool.Parent = backpack
                                end
                            end
                        end
                    end
                end
            end
        else
            -- ถ้าไม่ได้ฟาร์ม ให้ล้างเป้าหมายทิ้ง เพื่อให้ตอนเปิดใหม่มันเริ่มหาใหม่หมด
            currentTarget = nil
        end
        task.wait(0.3) -- เพิ่มเวลาเช็คสถานะการเปิดปิดให้แม่นยำขึ้น
    end
end)

-- ### 3. ระบบวาร์ป (มุดดิน -5.7) ###
Btn.MouseButton1Click:Connect(function()
    isFarming = not isFarming
    Btn.Text = isFarming and "FARMING..." or "START KILL"
    Btn.BackgroundColor3 = isFarming and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(150, 0, 0)
end)

RunService.Heartbeat:Connect(function()
    if isFarming then
        -- ระบบหาเป้าหมาย
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
            -- ระยะ -5.7 ตามสั่ง
            myHrp.CFrame = tHrp.CFrame * CFrame.new(0, -5.7, 0) * CFrame.Angles(math.rad(90), 0, 0)
            myHrp.Velocity = Vector3.new(0, 0, 0)
        end
    end
end)
