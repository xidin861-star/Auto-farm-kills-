-- [[ UI NAME: AutoFarm KILL V8 ]] --
-- FIXED: ฟาร์มนานแล้วสกิลไม่หยุดทำงาน + ปรับระบบ Refresh Logic

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local lp = Players.LocalPlayer

-- ### 1. UI Setup (ชื่อใหม่ตามสั่ง) ###
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "AutoFarm_KILL_V1"
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
Title.Text = "AutoFarm KILL" -- เปลี่ยนชื่อแล้วครับ
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

-- ### 2. ระบบโจมตี (NEW: PERSISTENT LOGIC) ###
local isFarming = false
local currentTarget = nil
local canClick = true

-- [เลนต่อย M1 - รันต่อเนื่อง]
task.spawn(function()
    while true do
        if isFarming and currentTarget then
            pcall(function() -- ใช้ pcall กันสคริปต์หลุดเวลาตาย
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

-- [เลนสกิล - แก้บั๊กฟาร์มนานแล้วหยุด]
task.spawn(function()
    while true do
        if isFarming and currentTarget then
            pcall(function()
                -- บังคับดึงค่าตัวละครและกระเป๋าใหม่ทุกรอบ (กันบั๊กค้าง)
                local char = lp.Character or lp.CharacterAdded:Wait()
                local backpack = lp:FindFirstChild("Backpack")
                local remote = char:FindFirstChild("Communicate")
                
                if char and backpack and remote then
                    local tools = backpack:GetChildren()
                    for _, tool in pairs(tools) do
                        if not isFarming then break end 
                        if tool:IsA("Tool") and tool.Name ~= "Wallet" then
                            -- ระบบตรวจสอบสถานะ Tool เพื่อกันสกิลค้างในมือ
                            tool.Parent = char
                            task.wait(0.05)
                            remote:FireServer({["Goal"] = "NormalClick", ["Tool"] = tool})
                            task.wait(0.12) -- เพิ่มเวลานิดนึงให้เซิร์ฟเวอร์รับทันเวลาฟาร์มนานๆ
                            if tool.Parent == char then
                                tool.Parent = backpack
                            end
                        end
                    end
                end
            end)
        end
        task.wait(0.5) -- หน่วงเวลาเช็คสถานะรอบใหม่
    end
end)

-- ### 3. ปุ่มกด ###
Btn.MouseButton1Click:Connect(function()
    if not canClick then return end
    canClick = false
    isFarming = not isFarming
    
    if not isFarming then
        currentTarget = nil
        Btn.Text = "STOPPING..."
        Btn.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
    else
        Btn.Text = "FARMING..."
        Btn.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
    end
    
    task.wait(0.5)
    canClick = true
    
    if not isFarming then
        Btn.Text = "START KILL"
        Btn.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
    end
end)

-- ### 4. ระบบวาร์ปมุดดิน (-5.6) ###
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
            myHrp.CFrame = tHrp.CFrame * CFrame.new(0, -5.6, 0) * CFrame.Angles(math.rad(90), 0, 0)
            myHrp.Velocity = Vector3.new(0, 0, 0)
        end
    end
end)
