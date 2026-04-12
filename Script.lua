-- [[ Auto farm kill v1 - LOCK-ON EDITION ]] --
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local lp = Players.LocalPlayer

-- ### 1. ระบบโจมตีต่อเนื่อง ###
local function AttackLogic()
    local char = lp.Character
    if not char then return end
    local remote = char:FindFirstChild("Communicate")
    if not remote then return end

    -- ต่อย 4 ครั้งรวด
    for i = 1, 4 do
        remote:FireServer({Goal = "LeftClickRelease", Mobile = true})
    end

    -- ยัดสกิล 1-4 (ตัวไหนคูลดาวน์เสร็จใช้ตัวนั้น)
    local skills = {"Normal Punch", "Consecutive Punches", "Shove", "Uppercut"}
    for _, name in ipairs(skills) do
        local tool = lp.Backpack:FindFirstChild(name) or char:FindFirstChild(name)
        if tool then
            remote:FireServer({Goal = "Auto Use End", Tool = tool})
        end
    end
end

-- ### 2. UI (ลากได้ ตายไม่หาย) ###
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "AutoFarmV1_LockOn"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = lp:WaitForChild("PlayerGui")

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 160, 0, 80)
MainFrame.Position = UDim2.new(0.5, -80, 0.5, -40)
MainFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 40) -- สีน้ำเงินเข้มโหมดล็อคเป้า
MainFrame.Active = true
MainFrame.Draggable = true 
MainFrame.Parent = ScreenGui

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 25)
Title.Text = "Auto farm kill v1"
Title.TextColor3 = Color3.new(1, 1, 1)
Title.BackgroundTransparency = 1
Title.Parent = MainFrame

local ToggleBtn = Instance.new("TextButton")
ToggleBtn.Size = UDim2.new(0.9, 0, 0, 40)
ToggleBtn.Position = UDim2.new(0.05, 0, 0.4, 0)
ToggleBtn.Text = "OFF"
ToggleBtn.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
ToggleBtn.Parent = MainFrame

-- ### 3. ระบบวาร์ปและล็อคเป้าจนกว่าจะตาย ###
local isFarming = false
local target = nil

local function findNewTarget()
    local potential = {}
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= lp and p.Character and p.Character:FindFirstChild("Humanoid") and p.Character.Humanoid.Health > 0 then
            table.insert(potential, p)
        end
    end
    return #potential > 0 and potential[math.random(1, #potential)] or nil
end

ToggleBtn.MouseButton1Click:Connect(function()
    isFarming = not isFarming
    ToggleBtn.Text = isFarming and "ON" or "OFF"
    ToggleBtn.BackgroundColor3 = isFarming and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(150, 0, 0)
    if not isFarming then target = nil end -- ล้างเป้าหมายเมื่อปิด
end)

RunService.Heartbeat:Connect(function()
    if isFarming then
        -- ตรวจสอบเงื่อนไข: ถ้าเป้าหมายเดิม "ยังรอดอยู่" ให้เกาะติดต่อไป
        local isTargetAlive = target and target.Parent and target.Character and target.Character:FindFirstChild("Humanoid") and target.Character.Humanoid.Health > 0
        
        if not isTargetAlive then
            -- ถ้าเป้าหมายเดิมตายแล้ว หรือหายไป ถึงจะหาคนใหม่
            target = findNewTarget()
            return
        end

        -- วาร์ปเกาะติดเป้าหมายเดิม (ระยะ -5.8)
        local char = lp.Character
        if char and char:FindFirstChild("HumanoidRootPart") and target.Character:FindFirstChild("HumanoidRootPart") then
            local myHrp = char.HumanoidRootPart
            local tHrp = target.Character.HumanoidRootPart
            
            myHrp.CFrame = tHrp.CFrame * CFrame.new(0, -5.8, 0) * CFrame.Angles(math.rad(90), 0, 0)
            myHrp.Velocity = Vector3.new(0, 0, 0)
            
            -- โจมตีจนกว่าจะตายกันไปข้างนึง
            AttackLogic()
        end
    end
end)
