-- [[ CONFIGURATION & UI SETUP ]] --
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local lp = Players.LocalPlayer
local isFollowing = false
local targetPlayer = nil

-- สร้าง UI แบบ Code (เพื่อให้น้องก๊อปไปวางรันได้ทันที)
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "StalkerGui"
screenGui.IgnoreGuiInset = true
screenGui.ResetOnSpawn = false -- ตายแล้วไม่หาย
screenGui.Parent = lp:WaitForChild("PlayerGui")

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 150, 0, 50)
mainFrame.Position = UDim2.new(0.5, -75, 0.5, -25)
mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
mainFrame.BorderSizePixel = 2
mainFrame.Active = true
mainFrame.Draggable = true -- สำหรับ PC/Mobile บางรุ่น (แต่เราจะเขียน Code ลากเองเสริมให้)
mainFrame.Parent = screenGui

local toggleBtn = Instance.new("TextButton")
toggleBtn.Size = UDim2.new(1, -10, 1, -10)
toggleBtn.Position = UDim2.new(0, 5, 0, 5)
toggleBtn.Text = "FOLLOW: OFF"
toggleBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
toggleBtn.TextColor3 = Color3.new(1, 1, 1)
toggleBtn.Font = Enum.Font.GothamBold
toggleBtn.TextSize = 14
toggleBtn.Parent = mainFrame

-- [[ LOGIC FUNCTIONS ]] --

-- ฟังก์ชันหาเป้าหมายใหม่ (ใครก็ได้ที่ไม่ใช่เรา)
local function findRandomTarget()
    local allPlayers = Players:GetPlayers()
    local potentialTargets = {}
    
    for _, p in pairs(allPlayers) do
        if p ~= lp and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            table.insert(potentialTargets, p)
        end
    end
    
    if #potentialTargets > 0 then
        return potentialTargets[math.random(1, #potentialTargets)]
    end
    return nil
end

-- ระบบลาก UI สำหรับมือถือ (เนียนกว่า Draggable ธรรมดา)
local dragging, dragInput, dragStart, startPos
mainFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = mainFrame.Position
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = false
    end
end)

-- [[ MAIN LOOP ]] --

toggleBtn.MouseButton1Click:Connect(function()
    isFollowing = not isFollowing
    if isFollowing then
        toggleBtn.Text = "FOLLOW: ON"
        toggleBtn.BackgroundColor3 = Color3.fromRGB(50, 200, 50)
        targetPlayer = findRandomTarget()
    else
        toggleBtn.Text = "FOLLOW: OFF"
        toggleBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
        targetPlayer = nil
    end
end)

RunService.RenderStepped:Connect(function()
    if isFollowing then
        -- 1. ตรวจสอบว่าเป้าหมายยังอยู่ในเกม/ยังไม่ตายไหม ถ้าไม่อยู่ให้หาคนใหม่ทันที
        if not targetPlayer or not targetPlayer.Parent or not targetPlayer.Character or not targetPlayer.Character:FindFirstChild("HumanoidRootPart") then
            targetPlayer = findRandomTarget()
        end
        
        -- 2. วาร์ปไปติดตัว (ใต้เท้า) แม้เขาจะเคลื่อนที่เร็วหรือใช้สกิล
        if targetPlayer and targetPlayer.Character and lp.Character and lp.Character:FindFirstChild("HumanoidRootPart") then
            local myRoot = lp.Character.HumanoidRootPart
            local targetRoot = targetPlayer.Character.HumanoidRootPart
            
            -- วาร์ปไปตำแหน่งเป้าหมาย + ปรับตำแหน่งให้ลงไปใต้เท้า (Y - 4)
            -- ใช้ CFrame เพื่อให้ตัวเราหันหน้าตามเป้าหมายด้วย
            myRoot.CFrame = targetRoot.CFrame * CFrame.new(0, -4, 0)
            
            -- ปรับแรงเฉื่อยให้เป็น 0 เพื่อไม่ให้ตัวเรากระเด็นหลุด
            myRoot.Velocity = Vector3.new(0, 0, 0)
        end
    end
end)
