-- full fixed
local Players = game:GetService("Players")
local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

-- gui
local Gui = Instance.new("ScreenGui")
Gui.Name = "KeySystem"
Gui.Parent = PlayerGui
Gui.ResetOnSpawn = false

-- helpers
local function sWait(t)
    if typeof(task.wait) == "function" then
        task.wait(t or 0.03)
    else
        wait(t or 0.03)
    end
end

local function sDelay(t, f)
    task.spawn(function()
        sWait(t)
        pcall(f)
    end)
end

-- encode/decode
local function encode(str, key)
    local out = {}
    for i = 1, #str do
        local a = str:byte(i)
        local b = key:byte(((i - 1) % #key) + 1)
        out[i] = string.char((a + b) % 256)
    end
    return table.concat(out)
end

local function decode(str, key)
    local out = {}
    for i = 1, #str do
        local a = str:byte(i)
        local b = key:byte(((i - 1) % #key) + 1)
        out[i] = string.char((a - b) % 256)
    end
    return table.concat(out)
end

-- key setup
local Key = "(stars_are-so+C0oL!)"
local Secret = "local_secret!"
local Enc = encode(Key, Secret)
local Var = "K"..math.random(1000,9999)..tostring(os.time()%10000)
getgenv()[Var] = Enc

local function verify(input)
    if type(input) ~= "string" then return false end
    local e = getgenv()[Var]
    if not e then return false end
    return encode(input, Secret) == e
end

-- notify
local function Notify(msg, col, dur)
    local N = Instance.new("TextLabel", Gui)
    N.Size = UDim2.new(0,260,0,40)
    N.Position = UDim2.new(1,-280,1,-80)
    N.BackgroundColor3 = col or Color3.fromRGB(40,40,40)
    N.BorderSizePixel = 0
    N.Text = msg
    N.TextScaled = true
    N.Font = Enum.Font.GothamBold
    N.TextColor3 = Color3.fromRGB(255,255,255)
    local c = Instance.new("UICorner", N)
    c.CornerRadius = UDim.new(0,10)
    sDelay(dur or 3, function() N:Destroy() end)
end

-- http get
local function httpGet(u)
    local ok, res = pcall(function() return game:HttpGet(u, true) end)
    if ok and res and #res > 0 then
        return res
    else
        warn("Failed to fetch:", u)
        return nil
    end
end

-- games
local Function = {
    {Id = 79546208627805, Exec = function()
        local code = httpGet("https://files.catbox.moe/vgua6a.txt")
        if code then
            print("[Loader] Executing vgua6a.txt...")
            loadstring(code)()
        else
            Notify("Failed to load game script!", Color3.fromRGB(255,80,80), 3)
        end
    end},
    {Id = 4924922222, Exec = function()
        local code = httpGet("https://files.catbox.moe/z2z5hg.txt")
        if code then
            print("[Loader] Executing z2z5hg.txt...")
            loadstring(code)()
        else
            Notify("Failed to load game script!", Color3.fromRGB(255,80,80), 3)
        end
    end}
}

for _, v in ipairs(Function) do
    v.Id = tonumber(v.Id)
end

-- executor
local function runIt()
    local pid = tonumber(game.PlaceId)
    print("[KeySystem] Current PlaceId:", pid)
    local found = false
    for _, v in ipairs(Function) do
        print("[KeySystem] Checking ID:", v.Id)
        if pid == v.Id then
            found = true
            Notify("Game detected! Loading...", Color3.fromRGB(0,200,100), 2)
            sDelay(1, function() pcall(v.Exec) end)
            break
        end
    end
    if not found then
        Notify("This game isn't supported.", Color3.fromRGB(200,50,50), 3)
    end
end

-- ui
local Box = Instance.new("TextBox")
Box.Parent = Gui
Box.PlaceholderText = "Enter Key..."
Box.Size = UDim2.new(0,200,0,40)
Box.Position = UDim2.new(0.4,0,0.4,0)
Box.TextScaled = true
Box.Font = Enum.Font.GothamBold
Box.TextColor3 = Color3.fromRGB(255,255,255)
Box.BackgroundColor3 = Color3.fromRGB(45,45,45)
local c1 = Instance.new("UICorner", Box)
c1.CornerRadius = UDim.new(0,8)

local Btn = Instance.new("TextButton")
Btn.Parent = Gui
Btn.Text = "Enter"
Btn.Size = UDim2.new(0,100,0,40)
Btn.Position = UDim2.new(0.4,0,0.5,0)
Btn.TextScaled = true
Btn.Font = Enum.Font.GothamBold
Btn.TextColor3 = Color3.fromRGB(255,255,255)
Btn.BackgroundColor3 = Color3.fromRGB(60,60,60)
local c2 = Instance.new("UICorner", Btn)
c2.CornerRadius = UDim.new(0,8)

Btn.MouseButton1Click:Connect(function()
    local text = Box.Text
    print("[KeySystem] Entered:", text)
    if verify(text) then
        Notify("Access Granted", Color3.fromRGB(0,200,100), 2)
        print("[KeySystem] Key verified! Running game script...")
        sDelay(1, runIt)
    else
        Notify("Wrong Key!", Color3.fromRGB(200,0,0), 2)
        print("[KeySystem] Invalid key.")
    end
end)
