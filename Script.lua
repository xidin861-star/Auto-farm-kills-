-- [[ UI NAME: AUTO FARM KILL V1 ]] --
-- FIXED: กดปุ่มรัวๆ แล้วสกิลไม่บั๊ก + Clean Restart Logic

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local lp = Players.LocalPlayer

-- ### 1. UI Setup ###
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "KUYA_FARM_V1"
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
Title.Text = "KUYA ZERO V7"
Title.TextColor3 = Color3.new(1, 1, 1)
Title.BackgroundColor3 = Color3.fromRGB(120, 0, 0)
Title.Parent = Main

local Btn = Instance.new("TextButton")
Btn.Size = UDim2.new(0.9, 0, 0.5, 0)
Btn.Position = UDim2.new(0.05, 0, 0.4, 0)
Btn.Text = "START KILL"
Btn.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
Btn.TextColor3 = Color3.new(1, 1, 1)
Btn.Parent = Main

-- ### 2. ระบบโจมตี (NEW: CLEAN RESTART LOGIC) ###
local isFarming = false
local currentTarget = nil
local canClick = true -- ระบบกันกดรัว (Debounce)

-- [เลนต่อย M1 - Zero Delay]
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

-- [เลนสกิล - ปรับปรุงระบบเช็คสถานะใหม่หมด]
task.spawn(function()
    while true do
        if isFarming and currentTarget then
            local char = lp.Character
            local backpack = lp:FindFirstChild("Backpack")
            local remote = char and char:FindFirstChild("Communicate")
            
            if char and backpack and remote then
                for _, tool in pairs(backpack:GetChildren()) do
                    -- ถ้าจังหวะที่วนอยู่แล้วน้องกดปิด (isFarming เป็น false) ให้หยุดทันที
                    if not isFarming then break end 
                    
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
        task.wait(0.2) -- จังหวะเช็คเป้าหมายและสถานะ
    end
end)

-- ### 3. ปุ่มกดพร้อมระบบกันบั๊ก (Debounce) ###
Btn.MouseButton1Click:Connect(function()
    if not canClick then return end -- ถ้ายังไม่ครบ 0.5 วินาที กดไม่ได้
    
    canClick = false
    isFarming = not isFarming
    
    -- ล้างค่าทันทีที่สถานะเปลี่ยน เพื่อป้องกันสกิลค้าง
    if not isFarming then
        currentTarget = nil
        Btn.Text = "STOPPING..."
        Btn.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
    else
        Btn.Text = "FARMING..."
        Btn.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
    end
    
    task.wait(0.5) -- หน่วงเวลาไว้ครึ่งวินาทีค่อยให้กดใหม่ได้
    canClick = true
    
    if not isFarming then
        Btn.Text = "START KILL"
        Btn.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
    end
end)

-- ### 4. ระบบวาร์ป (มุดดิน -5.7) ###
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
