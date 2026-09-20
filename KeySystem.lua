--// PressureKeySustem — красно-чёрный дизайн
--// Выбор языка (RU / ENG), подтверждение закрытия, окно не перетаскивается.
--// Логика (API, HWID, проверка, привязка) не изменена.

local HUB_NAME = "PressureKeySustem" -- название, показывается в окне
local LOGO_ID  = "rbxassetid://134113891777957" -- логотип рядом с названием

local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local lp = Players.LocalPlayer
local pg = lp:WaitForChild("PlayerGui")

local API_CHECK = "https://keybot-rfgspl.mia0.amvera.tech/api/check"
local API_BIND  = "https://keybot-rfgspl.mia0.amvera.tech/api/bind"

local function getHWID()
    if getdeviceid then return tostring(getdeviceid()) end
    return tostring(lp.UserId)
end
local HWID = getHWID()

local function httpPost(url, body)
    local fn = nil
    if syn and syn.request then fn = syn.request
    elseif http_request then fn = http_request
    elseif request then fn = request end
    if not fn then return nil end
    local ok, res = pcall(fn, {
        Url = url, Method = "POST",
        Headers = {["Content-Type"] = "application/json"},
        Body = HttpService:JSONEncode(body),
    })
    if ok then return res end
    return nil
end

------------------------------------------------------------------
-- Тексты (RU / EN)
------------------------------------------------------------------
local STRINGS = {
    ru = {
        title       = "Активация лицензии",
        subtitle    = "Введите ваш %s ключ чтобы привязать и активировать устройство.",
        badge       = "Активация",
        keyLabel    = "КЛЮЧ ЛИЦЕНЗИИ",
        paste       = "Вставить",
        activate    = "Активировать",
        checking    = "Проверка...",
        checkingLic = "> Проверка лицензии...",
        wait        = "Подождите",
        connErr     = "> Ошибка соединения",
        serverDown  = "Сервер недоступен",
        serverErr   = "> Ошибка сервера: %s",
        badResp     = "> Неверный ответ сервера",
        binding     = "> Привязка устройства...",
        bindErr     = "> Ошибка привязки",
        bindErr2    = "> Ошибка при привязке",
        activated   = "> Лицензия активирована!",
        welcome     = "Добро пожаловать в %s!",
        confirmed   = "> Лицензия подтверждена!",
        usedOther   = "> Ключ занят другим устройством",
        oneDevice   = "Каждый ключ работает только на 1 устройстве",
        expired     = "> Лицензия просрочена",
        getNew      = "Получите новый ключ",
        invalid     = "> Неверный ключ",
        tryAgain    = "Проверьте ключ и попробуйте снова",
        enterKey    = "> Введите ключ лицензии",
        clipEmpty   = "> Буфер обмена пуст",
        closeQ      = "Вы уверены, что хотите закрыть ключ систему?",
        yes         = "Да",
        no          = "Нет",
    },
    en = {
        title       = "Activate License",
        subtitle    = "Enter your %s license key to bind and activate your device.",
        badge       = "Activation",
        keyLabel    = "LICENSE KEY",
        paste       = "Paste Key",
        activate    = "Activate License",
        checking    = "Checking...",
        checkingLic = "> Checking license...",
        wait        = "Please wait",
        connErr     = "> Connection error",
        serverDown  = "Server is unavailable",
        serverErr   = "> Server error: %s",
        badResp     = "> Invalid server response",
        binding     = "> Binding device...",
        bindErr     = "> Binding error",
        bindErr2    = "> Failed to bind device",
        activated   = "> License activated!",
        welcome     = "Welcome to %s!",
        confirmed   = "> License confirmed!",
        usedOther   = "> Key is used on another device",
        oneDevice   = "Each key works on only 1 device",
        expired     = "> License expired",
        getNew      = "Get a new key",
        invalid     = "> Invalid key",
        tryAgain    = "Check the key and try again",
        enterKey    = "> Enter your license key",
        clipEmpty   = "> Clipboard is empty",
        closeQ      = "Are you sure you want to close the key system?",
        yes         = "Yes",
        no          = "No",
    },
}

------------------------------------------------------------------
-- Тема (красный + чёрный)
------------------------------------------------------------------
local THEME = {
    bg           = Color3.fromRGB(14, 12, 12),
    bgDeep       = Color3.fromRGB(8, 7, 7),
    chip         = Color3.fromRGB(32, 12, 12),
    chipHover    = Color3.fromRGB(56, 16, 16),
    accent       = Color3.fromRGB(230, 40, 40),
    accentBright = Color3.fromRGB(255, 95, 85),
    accentDim    = Color3.fromRGB(115, 24, 24),
    border       = Color3.fromRGB(52, 32, 32),
    white        = Color3.fromRGB(255, 255, 255),
    muted        = Color3.fromRGB(150, 145, 145),
    faint        = Color3.fromRGB(85, 80, 80),
    ok           = Color3.fromRGB(80, 220, 100),
    err          = Color3.fromRGB(255, 75, 75),
    warn         = Color3.fromRGB(255, 170, 40),
}

------------------------------------------------------------------
-- Хелперы
------------------------------------------------------------------
local function make(class, props, parent)
    local o = Instance.new(class)
    for k, v in pairs(props) do o[k] = v end
    o.Parent = parent
    return o
end

local function round(o, r)
    return make("UICorner", {CornerRadius = r}, o)
end

local function stroke(o, color, thickness)
    return make("UIStroke", {
        Color = color,
        Thickness = thickness,
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
    }, o)
end

local function tw(o, t, props, style, dir)
    local tween = TweenService:Create(
        o,
        TweenInfo.new(t, style or Enum.EasingStyle.Quad, dir or Enum.EasingDirection.Out),
        props
    )
    tween:Play()
    return tween
end

local function viewport()
    local cam = workspace.CurrentCamera
    return cam and cam.ViewportSize or Vector2.new(1280, 720)
end

local function fitScale()
    local vp = viewport()
    return math.clamp(math.min(vp.X / 420, vp.Y / 500), 0.5, 1)
end

-- Кнопка с наведением (тёмная, красная рамка)
local function styleButton(btn, strokeObj)
    btn.MouseEnter:Connect(function()
        tw(btn, 0.12, {BackgroundColor3 = THEME.chipHover})
        tw(strokeObj, 0.12, {Color = THEME.accent})
    end)
    btn.MouseLeave:Connect(function()
        tw(btn, 0.12, {BackgroundColor3 = THEME.chip})
        tw(strokeObj, 0.12, {Color = THEME.accentDim})
    end)
end

------------------------------------------------------------------
-- ScreenGui + фон
------------------------------------------------------------------
if pg:FindFirstChild("SmileHubKey") then pg.SmileHubKey:Destroy() end
if pg:FindFirstChild("PressureKeySustem") then pg.PressureKeySustem:Destroy() end

local sg = make("ScreenGui", {
    Name = "PressureKeySustem",
    ResetOnSpawn = false,
    IgnoreGuiInset = true,
    DisplayOrder = 100000, -- поверх интерфейса игры
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
}, pg)

local overlay = make("Frame", {
    Size = UDim2.new(1, 0, 1, 0),
    BackgroundColor3 = Color3.fromRGB(0, 0, 0),
    BackgroundTransparency = 1,
    BorderSizePixel = 0,
    Active = true,
}, sg)

------------------------------------------------------------------
-- Общее состояние, закрытие, масштаб
------------------------------------------------------------------
local closed = false
local connections = {}
local scales = {}
local activeScale = nil
local dotPulse = nil
local logoResolved = nil -- найденная рабочая ссылка на логотип (кэш)

local function closeGui()
    if closed then return end
    closed = true
    if dotPulse then dotPulse:Cancel() end
    for _, c in ipairs(connections) do c:Disconnect() end
    tw(overlay, 0.15, {BackgroundTransparency = 1})
    if activeScale then
        tw(activeScale, 0.15, {Scale = activeScale.Scale * 0.92})
    end
    task.delay(0.16, function()
        sg:Destroy()
    end)
end

local cam = workspace.CurrentCamera
if cam then
    table.insert(connections, cam:GetPropertyChangedSignal("ViewportSize"):Connect(function()
        if closed then return end
        for _, sc in ipairs(scales) do sc.Scale = fitScale() end
    end))
end

-- Окно 380 x height (прямоугольное, красная градиентная рамка). Не перетаскивается.
local function newWindow(height)
    local frame = make("Frame", {
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(0.5, 0, 0.5, 0),
        Size = UDim2.new(0, 380, 0, height),
        BackgroundColor3 = THEME.bg,
        BorderSizePixel = 0,
    }, sg)
    round(frame, UDim.new(0, 6))
    local st = stroke(frame, THEME.white, 1.5)
    make("UIGradient", {
        Color = ColorSequence.new(THEME.accent, THEME.border),
        Rotation = 90,
    }, st)
    local sc = make("UIScale", {Scale = fitScale() * 0.92}, frame)
    table.insert(scales, sc)
    activeScale = sc
    return frame, sc
end

local function popIn(sc)
    tw(sc, 0.3, {Scale = fitScale()}, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
end

------------------------------------------------------------------
-- Встроенный логотип (PNG внутри скрипта, не зависит от Roblox ID)
------------------------------------------------------------------
local LOGO_FILE = "PressureKeySustem_logo.png"
local LOGO_B64 = table.concat({
    "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"
})

local B64_CHARS = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"

local function b64decode(data)
    local lookup = {}
    for i = 1, #B64_CHARS do lookup[B64_CHARS:byte(i)] = i - 1 end
    local out, n = {}, 0
    local buf, bits = 0, 0
    for i = 1, #data do
        local v = lookup[data:byte(i)]
        if v then
            buf = buf * 64 + v
            bits = bits + 6
            if bits >= 8 then
                bits = bits - 8
                local p = 2 ^ bits
                n = n + 1
                out[n] = string.char(math.floor(buf / p) % 256)
                buf = buf % p
            end
        end
    end
    return table.concat(out)
end

local embeddedLogoUrl = nil
local function getEmbeddedLogo()
    if embeddedLogoUrl then return embeddedLogoUrl end
    local getAsset = getcustomasset or getsynasset
    if not (writefile and getAsset) then return nil end
    local ok, url = pcall(function()
        writefile(LOGO_FILE, b64decode(LOGO_B64))
        return getAsset(LOGO_FILE)
    end)
    if ok and type(url) == "string" and url ~= "" then
        embeddedLogoUrl = url
        return url
    end
    return nil
end

------------------------------------------------------------------
-- Шапка: [✕] [лого] Название ............ [• Activation]
------------------------------------------------------------------
local function buildHeader(parent, badgeText)
    local headerBar = make("Frame", {
        Size = UDim2.new(1, 0, 0, 56),
        BackgroundTransparency = 1,
        ZIndex = 3,
    }, parent)

    -- Белый крестик (две повёрнутые полоски)
    local closeBtn = make("TextButton", {
        Size = UDim2.fromOffset(34, 34),
        Position = UDim2.fromOffset(14, 11),
        BackgroundColor3 = THEME.accent,
        BackgroundTransparency = 1,
        Text = "",
        AutoButtonColor = false,
        BorderSizePixel = 0,
        ZIndex = 10,
    }, headerBar)
    round(closeBtn, UDim.new(0, 4))

    for _, rot in ipairs({45, -45}) do
        local bar = make("Frame", {
            AnchorPoint = Vector2.new(0.5, 0.5),
            Position = UDim2.fromScale(0.5, 0.5),
            Size = UDim2.fromOffset(20, 3),
            Rotation = rot,
            BackgroundColor3 = Color3.fromRGB(255, 255, 255),
            BackgroundTransparency = 0,
            BorderSizePixel = 0,
            ZIndex = 11,
        }, closeBtn)
        round(bar, UDim.new(0, 1))
    end

    closeBtn.MouseEnter:Connect(function()
        tw(closeBtn, 0.12, {BackgroundTransparency = 0.6})
    end)
    closeBtn.MouseLeave:Connect(function()
        tw(closeBtn, 0.12, {BackgroundTransparency = 1})
    end)

    -- Логотип
    local logoFrame = make("Frame", {
        Size = UDim2.fromOffset(32, 32),
        Position = UDim2.fromOffset(54, 12),
        BackgroundColor3 = Color3.fromRGB(0, 0, 0),
        BorderSizePixel = 0,
        ZIndex = 4,
    }, headerBar)
    round(logoFrame, UDim.new(0, 4))
    stroke(logoFrame, THEME.accentDim, 1.2)

    local logoImg = make("ImageLabel", {
        Size = UDim2.new(1, -6, 1, -6),
        Position = UDim2.fromOffset(3, 3),
        BackgroundTransparency = 1,
        Image = logoResolved or "",
        ScaleType = Enum.ScaleType.Fit,
        ZIndex = 5,
    }, logoFrame)

    -- Запасная буква: видна, пока логотип не загрузился (или если не загрузится совсем)
    local logoFallback = make("TextLabel", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Text = "P",
        TextColor3 = THEME.accent,
        TextSize = 20,
        Font = Enum.Font.GothamBold,
        ZIndex = 4,
    }, logoFrame)

    local function waitLoaded(seconds)
        local t = 0
        while logoImg.Parent and not logoImg.IsLoaded and t < seconds do
            task.wait(0.1)
            t += 0.1
        end
        return logoImg.Parent ~= nil and logoImg.IsLoaded
    end

    task.spawn(function()
        -- Порядок: кэш -> встроенный PNG -> Roblox ID
        local candidates = {}
        if logoResolved then table.insert(candidates, logoResolved) end
        local embedded = getEmbeddedLogo()
        if embedded then table.insert(candidates, embedded) end
        table.insert(candidates, LOGO_ID)

        for _, srcImg in ipairs(candidates) do
            if not logoImg.Parent then return end
            logoImg.Image = srcImg
            if waitLoaded(2.5) then
                logoResolved = srcImg
                logoFallback.Visible = false
                return
            end
        end
        if not logoImg.Parent then return end

        -- Если LOGO_ID — это Decal, достаём из него настоящую картинку
        local ok, objs = pcall(function()
            return game:GetObjects(LOGO_ID)
        end)
        if ok and type(objs) == "table" and objs[1] then
            local o = objs[1]
            local tex = nil
            if o:IsA("Decal") or o:IsA("Texture") then
                tex = o.Texture
            elseif o:IsA("ImageLabel") or o:IsA("ImageButton") then
                tex = o.Image
            end
            if tex and tex ~= "" then
                logoImg.Image = tex
                if waitLoaded(4) then
                    logoResolved = tex
                    logoFallback.Visible = false
                    return
                end
            end
        end

        warn("[" .. HUB_NAME .. "] Логотип не загрузился (нужны writefile + getcustomasset либо рабочий LOGO_ID).")
    end)

    make("TextLabel", {
        Size = UDim2.new(0, 152, 1, 0),
        Position = UDim2.fromOffset(94, 0),
        BackgroundTransparency = 1,
        Text = HUB_NAME,
        TextColor3 = THEME.muted,
        TextSize = 15,
        Font = Enum.Font.GothamSemibold,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextTruncate = Enum.TextTruncate.AtEnd,
        ZIndex = 4,
    }, headerBar)

    if badgeText then
        local badge = make("Frame", {
            Size = UDim2.fromOffset(112, 30),
            Position = UDim2.new(1, -126, 0.5, -15),
            BackgroundColor3 = THEME.chip,
            BorderSizePixel = 0,
            ZIndex = 4,
        }, headerBar)
        round(badge, UDim.new(0, 4))
        stroke(badge, THEME.accentDim, 1.2)

        local dot = make("Frame", {
            Size = UDim2.fromOffset(7, 7),
            Position = UDim2.new(0, 11, 0.5, -3),
            BackgroundColor3 = THEME.accent,
            BorderSizePixel = 0,
            ZIndex = 5,
        }, badge)
        round(dot, UDim.new(1, 0))

        make("TextLabel", {
            Size = UDim2.new(1, -28, 1, 0),
            Position = UDim2.fromOffset(26, 0),
            BackgroundTransparency = 1,
            Text = badgeText,
            TextColor3 = THEME.accent,
            TextSize = 13,
            Font = Enum.Font.Code,
            TextXAlignment = Enum.TextXAlignment.Left,
            ZIndex = 5,
        }, badge)

        dotPulse = TweenService:Create(
            dot,
            TweenInfo.new(0.9, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true),
            {BackgroundTransparency = 0.7}
        )
        dotPulse:Play()
    end

    -- Линия под шапкой
    make("Frame", {
        Size = UDim2.new(1, 0, 0, 1),
        Position = UDim2.fromOffset(0, 56),
        BackgroundColor3 = THEME.border,
        BorderSizePixel = 0,
        ZIndex = 3,
    }, parent)

    return closeBtn
end

------------------------------------------------------------------
-- Основная панель активации
------------------------------------------------------------------
local function buildPanel(lang)
    local S = STRINGS[lang]
    local main, uiScale = newWindow(456)
    local closeBtn = buildHeader(main, S.badge)

    -- Заголовок и описание
    make("TextLabel", {
        Size = UDim2.new(1, -30, 0, 46),
        Position = UDim2.fromOffset(15, 76),
        BackgroundTransparency = 1,
        Text = S.title,
        TextColor3 = THEME.white,
        TextSize = 32,
        Font = Enum.Font.GothamBold,
        TextXAlignment = Enum.TextXAlignment.Center,
        TextScaled = false,
        ZIndex = 3,
    }, main)

    make("Frame", {
        AnchorPoint = Vector2.new(0.5, 0),
        Size = UDim2.fromOffset(48, 3),
        Position = UDim2.new(0.5, 0, 0, 128),
        BackgroundColor3 = THEME.accent,
        BorderSizePixel = 0,
        ZIndex = 3,
    }, main)

    make("TextLabel", {
        Size = UDim2.new(1, -60, 0, 44),
        Position = UDim2.fromOffset(30, 144),
        BackgroundTransparency = 1,
        Text = string.format(S.subtitle, HUB_NAME),
        TextColor3 = THEME.muted,
        TextSize = 14,
        Font = Enum.Font.Gotham,
        TextXAlignment = Enum.TextXAlignment.Center,
        TextYAlignment = Enum.TextYAlignment.Top,
        TextWrapped = true,
        ZIndex = 3,
    }, main)

    -- Ключ + Вставить
    make("TextLabel", {
        Size = UDim2.fromOffset(170, 28),
        Position = UDim2.fromOffset(20, 200),
        BackgroundTransparency = 1,
        Text = S.keyLabel,
        TextColor3 = Color3.fromRGB(115, 110, 110),
        TextSize = 13,
        Font = Enum.Font.GothamBold,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 3,
    }, main)

    local pasteBtn = make("TextButton", {
        Size = UDim2.fromOffset(104, 28),
        Position = UDim2.new(1, -124, 0, 200),
        BackgroundColor3 = THEME.chip,
        TextColor3 = THEME.accent,
        Text = S.paste,
        TextSize = 13,
        Font = Enum.Font.Code,
        AutoButtonColor = false,
        BorderSizePixel = 0,
        ZIndex = 4,
    }, main)
    round(pasteBtn, UDim.new(0, 4))
    styleButton(pasteBtn, stroke(pasteBtn, THEME.accentDim, 1))

    local inputOuter = make("Frame", {
        Size = UDim2.new(1, -40, 0, 54),
        Position = UDim2.fromOffset(20, 234),
        BackgroundColor3 = THEME.bgDeep,
        BorderSizePixel = 0,
        ZIndex = 3,
    }, main)
    round(inputOuter, UDim.new(0, 4))
    local inputStroke = stroke(inputOuter, THEME.border, 1.5)

    local prefixBadge = make("Frame", {
        Size = UDim2.fromOffset(44, 34),
        Position = UDim2.new(0, 10, 0.5, -17),
        BackgroundColor3 = THEME.chip,
        BorderSizePixel = 0,
        ZIndex = 4,
    }, inputOuter)
    round(prefixBadge, UDim.new(0, 3))
    stroke(prefixBadge, THEME.accentDim, 1)

    make("TextLabel", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Text = "Sm",
        TextColor3 = THEME.accent,
        TextSize = 15,
        Font = Enum.Font.Code,
        TextXAlignment = Enum.TextXAlignment.Center,
        ZIndex = 5,
    }, prefixBadge)

    local inputBox = make("TextBox", {
        Size = UDim2.new(1, -70, 1, 0),
        Position = UDim2.fromOffset(62, 0),
        BackgroundTransparency = 1,
        TextColor3 = THEME.accentBright,
        PlaceholderColor3 = Color3.fromRGB(90, 70, 70),
        PlaceholderText = "Sm-Vip-XXXXXXXXXXXX",
        TextSize = 15,
        Font = Enum.Font.Code,
        TextXAlignment = Enum.TextXAlignment.Left,
        ClearTextOnFocus = false,
        Text = "",
        ZIndex = 5,
    }, inputOuter)

    inputBox.Focused:Connect(function()
        tw(inputStroke, 0.15, {Color = THEME.accent})
    end)
    inputBox.FocusLost:Connect(function()
        tw(inputStroke, 0.15, {Color = THEME.border})
    end)

    -- HWID / статус
    make("TextLabel", {
        Size = UDim2.new(1, -40, 0, 16),
        Position = UDim2.fromOffset(20, 298),
        BackgroundTransparency = 1,
        Text = "HWID : " .. HWID,
        TextColor3 = THEME.faint,
        TextSize = 10,
        Font = Enum.Font.Code,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextTruncate = Enum.TextTruncate.AtEnd,
        ZIndex = 3,
    }, main)

    local statusLbl = make("TextLabel", {
        Size = UDim2.new(1, -40, 0, 24),
        Position = UDim2.fromOffset(20, 318),
        BackgroundTransparency = 1,
        Text = "",
        TextColor3 = THEME.err,
        TextSize = 14,
        Font = Enum.Font.GothamBold,
        TextXAlignment = Enum.TextXAlignment.Center,
        ZIndex = 3,
    }, main)

    local subLbl = make("TextLabel", {
        Size = UDim2.new(1, -40, 0, 18),
        Position = UDim2.fromOffset(20, 342),
        BackgroundTransparency = 1,
        Text = "",
        TextColor3 = THEME.muted,
        TextSize = 12,
        Font = Enum.Font.Gotham,
        TextXAlignment = Enum.TextXAlignment.Center,
        ZIndex = 3,
    }, main)

    local function setStatus(t, c)
        statusLbl.Text = t
        statusLbl.TextColor3 = c or THEME.err
    end

    local function setSub(t, c)
        subLbl.Text = t
        subLbl.TextColor3 = c or THEME.muted
    end

    -- Кнопка активации
    local activateBtn = make("TextButton", {
        Size = UDim2.new(1, -40, 0, 54),
        Position = UDim2.fromOffset(20, 376),
        BackgroundColor3 = THEME.chip,
        TextColor3 = THEME.white,
        Text = S.activate,
        TextSize = 18,
        Font = Enum.Font.GothamBold,
        AutoButtonColor = false,
        BorderSizePixel = 0,
        ZIndex = 3,
    }, main)
    round(activateBtn, UDim.new(0, 4))
    styleButton(activateBtn, stroke(activateBtn, THEME.accentDim, 1.8))

    --------------------------------------------------------------
    -- Подтверждение закрытия
    --------------------------------------------------------------
    local confirmOpen = false

    local confirmLayer = make("Frame", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundColor3 = Color3.fromRGB(0, 0, 0),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Active = true,
        Visible = false,
        ZIndex = 20,
    }, main)
    round(confirmLayer, UDim.new(0, 6))

    local dialog = make("Frame", {
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(0.5, 0, 0.5, 0),
        Size = UDim2.fromOffset(312, 176),
        BackgroundColor3 = THEME.bg,
        BorderSizePixel = 0,
        ZIndex = 21,
    }, confirmLayer)
    round(dialog, UDim.new(0, 4))
    stroke(dialog, THEME.accent, 1.5)
    local dialogScale = make("UIScale", {Scale = 1}, dialog)

    make("TextLabel", {
        Size = UDim2.new(1, -40, 0, 66),
        Position = UDim2.fromOffset(20, 22),
        BackgroundTransparency = 1,
        Text = S.closeQ,
        TextColor3 = THEME.white,
        TextSize = 16,
        Font = Enum.Font.GothamBold,
        TextWrapped = true,
        TextXAlignment = Enum.TextXAlignment.Center,
        TextYAlignment = Enum.TextYAlignment.Center,
        ZIndex = 22,
    }, dialog)

    -- Красная кнопка «Да»
    local yesBtn = make("TextButton", {
        Size = UDim2.fromOffset(132, 46),
        Position = UDim2.fromOffset(20, 108),
        BackgroundColor3 = THEME.accent,
        TextColor3 = THEME.white,
        Text = S.yes,
        TextSize = 17,
        Font = Enum.Font.GothamBold,
        AutoButtonColor = false,
        BorderSizePixel = 0,
        ZIndex = 22,
    }, dialog)
    round(yesBtn, UDim.new(0, 4))
    yesBtn.MouseEnter:Connect(function()
        tw(yesBtn, 0.12, {BackgroundColor3 = Color3.fromRGB(255, 70, 70)})
    end)
    yesBtn.MouseLeave:Connect(function()
        tw(yesBtn, 0.12, {BackgroundColor3 = THEME.accent})
    end)

    -- Кнопка «Нет»
    local noBtn = make("TextButton", {
        Size = UDim2.fromOffset(132, 46),
        Position = UDim2.fromOffset(160, 108),
        BackgroundColor3 = THEME.chip,
        TextColor3 = THEME.white,
        Text = S.no,
        TextSize = 17,
        Font = Enum.Font.GothamBold,
        AutoButtonColor = false,
        BorderSizePixel = 0,
        ZIndex = 22,
    }, dialog)
    round(noBtn, UDim.new(0, 4))
    styleButton(noBtn, stroke(noBtn, THEME.accentDim, 1.5))

    local function openConfirm()
        if closed or confirmOpen then return end
        confirmOpen = true
        inputBox:ReleaseFocus()
        confirmLayer.BackgroundTransparency = 1
        confirmLayer.Visible = true
        tw(confirmLayer, 0.15, {BackgroundTransparency = 0.3})
        dialogScale.Scale = 0.92
        tw(dialogScale, 0.2, {Scale = 1}, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
    end

    local function hideConfirm()
        if not confirmOpen then return end
        confirmOpen = false
        tw(confirmLayer, 0.12, {BackgroundTransparency = 1})
        task.delay(0.12, function()
            if not confirmOpen then confirmLayer.Visible = false end
        end)
    end

    closeBtn.MouseButton1Click:Connect(openConfirm)
    noBtn.MouseButton1Click:Connect(hideConfirm)
    yesBtn.MouseButton1Click:Connect(closeGui)

    --------------------------------------------------------------
    -- Вставка ключа
    --------------------------------------------------------------
    pasteBtn.MouseButton1Click:Connect(function()
        local ok, clip = pcall(function()
            return UserInputService:GetClipboardText()
        end)
        if not (ok and clip and clip ~= "") and getclipboard then
            ok, clip = pcall(getclipboard)
        end
        if ok and clip and clip ~= "" then
            inputBox.Text = clip
            setStatus("") setSub("")
        else
            setStatus(S.clipEmpty, THEME.warn)
        end
    end)

    --------------------------------------------------------------
    -- Проверка ключа
    --------------------------------------------------------------
    local busy = false

    local function checkKey(key)
        if busy then return end
        busy = true
        activateBtn.Text = S.checking
        setStatus(S.checkingLic, THEME.accentBright)
        setSub(S.wait)

        local res = httpPost(API_CHECK, { key = key, hwid = HWID })

        if not res then
            setStatus(S.connErr, THEME.err)
            setSub(S.serverDown)
            activateBtn.Text = S.activate
            busy = false
            return
        end

        if res.StatusCode ~= 200 then
            setStatus(string.format(S.serverErr, tostring(res.StatusCode)), THEME.err)
            setSub("")
            activateBtn.Text = S.activate
            busy = false
            return
        end

        local ok, data = pcall(function()
            return HttpService:JSONDecode(res.Body)
        end)

        if not ok or not data then
            setStatus(S.badResp, THEME.err)
            setSub("")
            activateBtn.Text = S.activate
            busy = false
            return
        end

        local s = data.status

        if s == "success" then
            setStatus(S.binding, THEME.accentBright)
            setSub("HWID: " .. HWID)

            local bRes = httpPost(API_BIND, { key = key, hwid = HWID })

            if not bRes or bRes.StatusCode ~= 200 then
                setStatus(S.bindErr, THEME.err)
                setSub("")
                activateBtn.Text = S.activate
                busy = false
                return
            end

            local ok2, bd = pcall(function()
                return HttpService:JSONDecode(bRes.Body)
            end)

            if ok2 and bd and bd.status == "bound" then
                setStatus(S.activated, THEME.ok)
                setSub(string.format(S.welcome, HUB_NAME))
                task.wait(1.5)
                closeGui()
            else
                setStatus(S.bindErr2, THEME.err)
                setSub("")
            end

        elseif s == "bound_to_you" then
            setStatus(S.confirmed, THEME.ok)
            setSub(string.format(S.welcome, HUB_NAME))
            task.wait(1.5)
            closeGui()

        elseif s == "bound_to_other" then
            setStatus(S.usedOther, THEME.err)
            setSub(S.oneDevice)

        elseif s == "expired" then
            setStatus(S.expired, THEME.warn)
            setSub(S.getNew)

        else
            setStatus(S.invalid, THEME.err)
            setSub(S.tryAgain)
        end

        activateBtn.Text = S.activate
        busy = false
    end

    local function tryActivate()
        local key = inputBox.Text:match("^%s*(.-)%s*$")
        if key == "" then
            setStatus(S.enterKey, THEME.warn)
            setSub("")
            return
        end
        task.spawn(checkKey, key)
    end

    activateBtn.MouseButton1Click:Connect(tryActivate)

    inputBox.FocusLost:Connect(function(enterPressed)
        if enterPressed then tryActivate() end
    end)

    popIn(uiScale)
end

------------------------------------------------------------------
-- Выбор языка (показывается первым)
------------------------------------------------------------------
local function showLanguageSelect()
    local frame, sc = newWindow(302)
    local closeBtn = buildHeader(frame, nil)
    closeBtn.MouseButton1Click:Connect(closeGui)

    make("TextLabel", {
        Size = UDim2.new(1, -30, 0, 30),
        Position = UDim2.fromOffset(15, 76),
        BackgroundTransparency = 1,
        Text = "Выберите язык панели",
        TextColor3 = THEME.white,
        TextSize = 22,
        Font = Enum.Font.GothamBold,
        TextXAlignment = Enum.TextXAlignment.Center,
        ZIndex = 3,
    }, frame)

    make("TextLabel", {
        Size = UDim2.new(1, -30, 0, 22),
        Position = UDim2.fromOffset(15, 108),
        BackgroundTransparency = 1,
        Text = "Select panel language:",
        TextColor3 = THEME.muted,
        TextSize = 15,
        Font = Enum.Font.Gotham,
        TextXAlignment = Enum.TextXAlignment.Center,
        ZIndex = 3,
    }, frame)

    make("Frame", {
        AnchorPoint = Vector2.new(0.5, 0),
        Size = UDim2.fromOffset(48, 3),
        Position = UDim2.new(0.5, 0, 0, 140),
        BackgroundColor3 = THEME.accent,
        BorderSizePixel = 0,
        ZIndex = 3,
    }, frame)

    local chosen = false
    local function choose(lang)
        if chosen or closed then return end
        chosen = true
        tw(sc, 0.15, {Scale = sc.Scale * 0.92})
        task.delay(0.15, function()
            frame:Destroy()
            if not closed then buildPanel(lang) end
        end)
    end

    local function langButton(text, y, lang)
        local btn = make("TextButton", {
            Size = UDim2.new(1, -40, 0, 52),
            Position = UDim2.fromOffset(20, y),
            BackgroundColor3 = THEME.chip,
            TextColor3 = THEME.white,
            Text = text,
            TextSize = 17,
            Font = Enum.Font.GothamBold,
            AutoButtonColor = false,
            BorderSizePixel = 0,
            ZIndex = 3,
        }, frame)
        round(btn, UDim.new(0, 4))
        styleButton(btn, stroke(btn, THEME.accentDim, 1.8))
        btn.MouseButton1Click:Connect(function() choose(lang) end)
    end

    langButton("RU / Russian", 162, "ru")
    langButton("ENG / English", 226, "en")

    popIn(sc)
end

------------------------------------------------------------------
-- Запуск
------------------------------------------------------------------
tw(overlay, 0.25, {BackgroundTransparency = 0.45})
showLanguageSelect()
