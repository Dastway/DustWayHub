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

    make("ImageLabel", {
        Size = UDim2.new(1, -6, 1, -6),
        Position = UDim2.fromOffset(3, 3),
        BackgroundTransparency = 1,
        Image = LOGO_ID,
        ScaleType = Enum.ScaleType.Fit,
        ZIndex = 5,
    }, logoFrame)

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
