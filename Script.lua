-- [[ AUTO FARM KILLS BY GEMINI - SMART SYSTEM ]] --
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local lp = Players.LocalPlayer

-- ### 1. ระบบจัดการการโจมตี (Attack Logic) ###
local function AttackLogic(targetExists)
    -- ถ้าไม่มีเป้าหมาย (targetExists เป็น false) จะไม่ทำอะไรเลย
    if not targetExists then return end
    
    local char = lp.Character
    if not char then return end
    local remote = char:FindFirstChild("Communicate")
    if not remote then return end

    local function useSkill(name)
        local tool = lp.Backpack:FindFirstChild(name) or char:FindFirstChild(name)
        if tool then
            remote:FireServer({
                Goal = "Auto Use End",
                Tool = tool
            })
        end
    end

    -- [M1] ต่อยธรรมดา (จากรหัส LeftClickRelease ของน้อง)
    remote:FireServer({
        Goal = "LeftClickRelease",
        Mobile = true
    })

    -- [สกิล 1-4]
    useSkill("Normal Punch")
    task.wait(0.1)
    useSkill("Consecutive Punches")
    task.wait(0.1)
    useSkill("Shove")
    task.wait(0.1)
    useSkill("Uppercut")
end

-- ### 2. สร้าง UI (ลากได้ / ตายไม่หาย) ###
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "AutoFarmV3"
ScreenGui.ResetOnSpawn = false 
ScreenGui.Parent = lp:WaitForChild("PlayerGui")

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 160, 0, 80)
MainFrame.Position = UDim2.new(0.5, -80, 0.5, -40)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
MainFrame.Active = true
MainFrame.Draggable = true 
MainFrame.Parent = ScreenGui

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 25)
Title.Text = "Auto Farm Kills V3"
Title.TextColor3 = Color3.new(1, 1, 1)
Title.BackgroundTransparency = 1
Title.Parent = MainFrame

local ToggleBtn = Instance.new("TextButton")
ToggleBtn.Size = UDim2.new(0.9, 0, 0, 40)
ToggleBtn.Position = UDim2.new(0.05, 0, 0.4, 0)
ToggleBtn.Text = "FARM: OFF"
ToggleBtn.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
ToggleBtn.TextColor3 = Color3.new(1, 1, 1)
ToggleBtn.Parent = MainFrame

-- ### 3. ระบบวาร์ปและตรวจสอบเป้าหมายแบบเรียลไทม์ ###
local isFarming = false
local target = nil

local function findTarget()
    local players = Players:GetPlayers()
    local list = {}
    for _, p in pairs(players) do
        if p ~= lp and p.Character and p.Character:FindFirstChild("Humanoid") and p.Character.Humanoid.Health > 0 then
            table.insert(list, p)
        end
    end
    return #list > 0 and list[math.random(1, #list)] or nil
end

ToggleBtn.MouseButton1Click:Connect(function()
    isFarming = not isFarming
    ToggleBtn.Text = isFarming and "FARM: ON" or "FARM: OFF"
    ToggleBtn.BackgroundColor3 = isFarming and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(150, 0, 0)
    if isFarming then target = findTarget() end
end)

RunService.RenderStepped:Connect(function()
    if isFarming then
        -- ตรวจสอบว่าเป้าหมายยังอยู่และไม่ตาย
        local targetReady = target and target.Parent and target.Character and target.Character:FindFirstChild("Humanoid") and target.Character.Humanoid.Health > 0
        
        if not targetReady then
            target = findTarget() -- หาคนใหม่ทันที
            return -- หยุดการทำงานของรอบนี้ (ไม่วาร์ป ไม่ตี) จนกว่าจะเจอคนใหม่
        end

        if lp.Character and lp.Character:FindFirstChild("HumanoidRootPart") then
            local myHrp = lp.Character.HumanoidRootPart
            local targetHrp = target.Character:FindFirstChild("HumanoidRootPart")
            
            if targetHrp then
                -- วาร์ปไปนอนใต้เท้า จมดิน -3.8 แนวนอน
                myHrp.CFrame = targetHrp.CFrame * CFrame.new(0, -3.8, 0) * CFrame.Angles(math.rad(90), 0, 0)
                myHrp.Velocity = Vector3.new(0, 0, 0)
                
                -- ส่งค่า true เข้าไปเพื่อให้ AttackLogic เริ่มทำงาน
                task.spawn(function() AttackLogic(true) end)
            end
        end
    end
end)
