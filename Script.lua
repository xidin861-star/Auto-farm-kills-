-- [[ UI NAME: AutoFarm KILL V9 ]] --
-- FIXED: ล็อคเป้าหมายให้สกิลโดนแม่นขึ้น + ระบบ Auto-LookAt

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local lp = Players.LocalPlayer

-- ### 1. UI Setup ###
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "AutoFarm_KILL_V9"
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
Title.Text = "AutoFarm KILL V9"
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

-- ### 2. ระบบโจมตี ###
local isFarming = false
local currentTarget = nil
local canClick = true

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

-- [เลนสกิล - เพิ่มระบบล็อคทิศทาง]
task.spawn(function()
    while true do
        if isFarming and currentTarget then
            pcall(function()
                local char = lp.Character
                local backpack = lp:FindFirstChild("Backpack")
                local remote = char:FindFirstChild("Communicate")
                local tHrp = currentTarget.Character:FindFirstChild("HumanoidRootPart")
                
                if char and backpack and remote and tHrp then
                    -- บังคับตัวเราหันหน้าไปหาศัตรูก่อนใช้สกิล
                    char.HumanoidRootPart.CFrame = CFrame.new(char.HumanoidRootPart.Position, Vector3.new(tHrp.Position.X, char.HumanoidRootPart.Position.Y, tHrp.Position.Z))
                    
                    for _, tool in pairs(backpack:GetChildren()) do
                        if not isFarming then break end 
                        if tool:IsA("Tool") and tool.Name ~= "Wallet" then
                            tool.Parent = char
                            task.wait(0.05)
                            -- ยิง Remote พร้อมข้อมูลตำแหน่งศัตรู (ถ้าเกมรองรับจะโดนแม่นมาก)
                            remote:FireServer({["Goal"] = "NormalClick", ["Tool"] = tool, ["Target"] = tHrp.Position})
                            task.wait(0.12)
                            if tool.Parent == char then
                                tool.Parent = backpack
                            end
                        end
                    end
                end
            end)
        end
        task.wait(0.4)
    end
end)

-- ### 3. ปุ่มกด ###
Btn.MouseButton1Click:Connect(function()
    if not canClick then return end
    canClick = false
    isFarming = not isFarming
    if not isFarming then currentTarget = nil end
    Btn.Text = isFarming and "FARMING..." or "START KILL"
    Btn.BackgroundColor3 = isFarming and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(150, 0, 0)
    task.wait(0.5)
    canClick = true
end)

-- ### 4. ระบบวาร์ปมุดดิน (ปรับองศาใหม่ -5.7) ###
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
            -- มุดดินที่ระยะ -5.7 และใช้ LookAt เพื่อให้ตัวละครหันหน้าเข้าหาศัตรูตลอดเวลา
            local lookAtPos = Vector3.new(tHrp.Position.X, myHrp.Position.Y, tHrp.Position.Z)
            myHrp.CFrame = CFrame.new(tHrp.Position + Vector3.new(0, -5.7, 0), lookAtPos)
            myHrp.Velocity = Vector3.new(0, 0, 0)
        end
    end
end)
