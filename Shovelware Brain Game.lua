local player = game.Players.LocalPlayer
local http = game:GetService("HttpService")
local answers
if isfile("sbg.json") then
    answers = http:JSONDecode(readfile("sbg.json"))
else
    answers = http:JSONDecode(game:HttpGet("https://raw.githubusercontent.com/SleepyLuc/sbg/main/answers"))
    writefile("sbg.json", http:JSONEncode(answers))
end
local question
getgenv().config = {
    ["join"] = false,
    ["reply"] = false,
    ["category"] = false,
    ["ui"] = false,
    ["antiafk"] = false,
    ["wait"] = {
        ["reply"] = 0.4,
        ["category"] = 0.6,
        ["join"] = 1
    }
}

local lib = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/UI-Libs/main/discord%20lib.txt"))()
local win = lib:Window("Shovelware's Brain Game (SYNX version)")
local serv = win:Server("SleepyLuc's scripts", "")
local main = serv:Channel("📃main")
main:Toggle("Auto-Join", false, function(b) 
    config.join = b
end)
main:Toggle("Auto-Reply", false, function(b) 
    config.reply = b
end)
main:Toggle("Auto-Choose Category", false, function(b) 
    config.category = b
end)
main:Textbox("Set Auto-Reply Wait Time", "0.4", false, function(n)
    config.wait.reply = tonumber(n)
end)
main:Textbox("Set Auto-Choose Category Wait Time", "0.6", false, function(n)
    config.wait.category = tonumber(n)
end)
main:Textbox("Set Auto-Join Wait Time", "1", false, function(n)
    config.wait.join = tonumber(n)
end)
main:Seperator()
main:Toggle("Anti-AFK", false, function(b) 
    config.category = b
end)
main:Bind("Toggle UI", Enum.KeyCode.LeftAlt, function()
    config.ui = not config.ui
    game.CoreGui:WaitForChild("Discord").MainFrame.Visible = config.ui
end)
local credits = serv:Channel("❤️credits")
credits:Label("SleepyLuc - made the script")
credits:Label("RemoteScript - helped with the API")
credits:Label("brickmane - made the KRNL port")
credits:Label("AGuyOnDisc#4349 - helped with boardy questions")
credits:Button("Copy Discord Server Link", function() 
    setclipboard("https://discord.gg/NtwZkqCTrK")
end)

player.Idled:Connect(function()
    if config.antiafk then
        game:GetService("VirtualUser"):Button2Down(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
        task.wait(1)
        game:GetService("VirtualUser"):Button2Up(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
    end
end)

player.PlayerGui.menusAndHud.sidebar.joinGame:GetPropertyChangedSignal("Visible"):Connect(function()
    if player.PlayerGui:WaitForChild("menusAndHud").sidebar.joinGame.Visible and config.join then
        task.wait(config.wait.join)
        firesignal(player.PlayerGui.menusAndHud.sidebar.joinGame.TextButton.MouseButton1Click)
    end
end)

player.PlayerGui.ChildAdded:Connect(function(UI)
    if UI.Name == "questionUI" and config.reply then
        question = UI.q.TextLabel.Text
        local option
        if question == "Which country does this flag belong to?" then
            local flag = workspace.gameshowHost.npc_boardy.boardyScreen.boardyScreen.ImageButton.TextLabel.Text
            local flags = {
                ["🇦🇶"] = "Antarctica",
                ["🇦🇷"] = "Argentina",
                ["🇨🇿"] = "Czech Republic",
            }
            local answer = flags[flag]
            if answer then
                for _, v in pairs(UI.choices:GetChildren()) do
                    if v.Value == answer then
                        option = v.Name
                    end
                end
            end
        elseif question == "What is the name of this famous landmark?" then
            local mark = workspace.gameshowHost.npc_boardy.boardyScreen.boardyScreen.ImageButton.Image
            local marks = {
                ["rbxassetid://12655898133"] = "Angkor Wat",
                ["rbxassetid://12655898248"] = "Chichen Itza",
                ["rbxassetid://12655897993"] = "The Pyramid of Khafre",
            }
            local answer = marks[mark]
            if answer then
                for _, v in pairs(UI.choices:GetChildren()) do
                    if v.Value == answer then
                        option = v.Name
                    end
                end
            end
        elseif answers[UI.q.TextLabel.Text] then
            for _, v in pairs(UI.choices:GetChildren()) do
                if v.Value == answers[UI.q.TextLabel.Text] then
                    option = v.Name
                end
            end
        end
        if option then
            warn("Letter: "..option..", Option: "..UI.options:WaitForChild(option).TextButton.TextLabel.Text)
            task.wait(config.wait.reply)
            firesignal(UI.options:WaitForChild(option).TextButton.MouseButton1Click)
        end
    elseif UI.Name == "revealUI" then
        if not answers[question] then
            answers[question] = UI.correct.Value
            writefile("sbg.json", http:JSONEncode(answers))
        end
    elseif UI.Name == "categoryChoose" and config.category then
        local choices = UI.choices:GetChildren()
        task.wait(config.wait.category)
        firesignal(UI:WaitForChild(choices[math.random(1, #choices)].Value).TextButton.MouseButton1Click)
    end
end)
