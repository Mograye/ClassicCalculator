local Calculator = {
	name = "Calculator",
	desc = "A simple calculator.",
	version = "1.1",
	author = "Mogray"
}

local calcBtn, calcWnd

local lastSaveTime = -1
local calcInput, calcOutput

local api = require("api")

function calculate(expression)
    local result = evaluate(expression)
    return result
end

function evaluate(expression)
    expression = expression:gsub("%s+", "")
    local stack = {}
    for i = 1, #expression do
        local char = expression:sub(i, i)
        if char == "(" then
            table.insert(stack, char)
        elseif char == ")" then
            if #stack == 0 then
                return "Error: Mismatched parentheses"
            end
            table.remove(stack)
        end
    end

    if #stack > 0 then
        return "Error: Mismatched parentheses"
    end

    local function evalMultiplicationDivision(expr)
        local terms = {}
        for number in expr:gmatch("[+-]?%d+[%d%.]*") do
            table.insert(terms, tonumber(number))
        end

        local total = terms[1] or 0
        local operator = ""
        
        for i = 1, #expr do
            local char = expr:sub(i, i)
            if char == "*" or char == "/" then
                operator = char
                local nextNumber = tonumber(expr:match("[+-]?%d+[%d%.]*", i + 1))
                if operator == "*" then
                    total = total * nextNumber
                elseif operator == "/" then
                    if nextNumber == 0 then
                        return "Error: Division by zero"
                    end
                    total = total / nextNumber
                end
                i = i + #tostring(nextNumber)
            elseif char == "+" or char == "-" then
                break
            end
        end
        
        return total
    end

    local total = 0
    local lastSign = "+"
    local currentTerm = ""

    for i = 1, #expression do
        local char = expression:sub(i, i)
        if char == "+" or char == "-" then
            if currentTerm ~= "" then
                if lastSign == "+" then
                    total = total + evalMultiplicationDivision(currentTerm)
                elseif lastSign == "-" then
                    total = total - evalMultiplicationDivision(currentTerm)
                end
            end
            currentTerm = ""
            lastSign = char
        else
            currentTerm = currentTerm .. char
        end
    end

    if currentTerm ~= "" then
        if lastSign == "+" then
            total = total + evalMultiplicationDivision(currentTerm)
        elseif lastSign == "-" then
            total = total - evalMultiplicationDivision(currentTerm)
        end
    end

    return total
end

function onSumButtonPress()
    local inputText = calcInput:GetText()
    local result = calculate(inputText)
    calcOutput:SetText(tostring(result))
end

local function OnLoad()
    calcBtn = api.Interface:CreateWidget("button", "notePadShowBtn", api.rootWindow)
    calcBtn:Show(true)
    calcBtn:AddAnchor("BOTTOMRIGHT", "UIParent", -330, -15)
	api.Interface:ApplyButtonSkin(calcBtn, BUTTON_BASIC.PLUS)

	calcWnd = api.Interface:CreateWindow("calcWindow", "Calculator")
    calcWnd:AddAnchor("TOPRIGHT", "UIParent", -10, 10)
	-- calcWnd:SetExtent(300, 400)
    calcWnd:SetHeight(396)
    calcWnd:SetWidth(300)
	calcWnd:Show(false)

	calcInput = W_CTRL.CreateEdit("noteEdit", calcWnd)
	local wW, wH = calcWnd:GetExtent()
	calcInput:SetExtent(wW - 20, 40)
	calcInput:AddAnchor("TOPLEFT", calcWnd, 10, 44)
    calcInput:CreateGuideText("Your Input")
    
    calcOutput = W_CTRL.CreateEdit("noteEdit", calcWnd)
	local wW, wH = calcWnd:GetExtent()
    calcOutput:Enable(false)
	calcOutput:SetExtent(wW - 190, 40)
	calcOutput:AddAnchor("TOPRIGHT", calcWnd, -10, 100)
    ApplyTextColor(calcOutput, FONT_COLOR.GREEN)
    calcOutput:CreateGuideText("Your Output")

    addBtn = calcWnd:CreateChildWidget("button", "addBtn", 0, true)
    addBtn:SetExtent(300, 60)
    addBtn:AddAnchor("BOTTOMRIGHT", calcWnd, -15, -145)
    addBtn:SetText("+")
    addBtn:Enable(true)
    api.Interface:ApplyButtonSkin(addBtn, BUTTON_BASIC.DEFAULT)

    subBtn = calcWnd:CreateChildWidget("button", "subBtn", 0, true)
    subBtn:SetExtent(300, 60)
    subBtn:AddAnchor("BOTTOM", calcWnd, 0, -145)
    subBtn:SetText("-")
    subBtn:Enable(true)
    api.Interface:ApplyButtonSkin(subBtn, BUTTON_BASIC.DEFAULT)

    commaBtn = calcWnd:CreateChildWidget("button", "commaBtn", 0, true)
    commaBtn:SetExtent(300, 60)
    commaBtn:AddAnchor("BOTTOMLEFT", calcWnd, 15, -145)
    commaBtn:SetText(".")
    commaBtn:Enable(true)
    api.Interface:ApplyButtonSkin(commaBtn, BUTTON_BASIC.DEFAULT)

    multBtn = calcWnd:CreateChildWidget("button", "multBtn", 0, true)
    multBtn:SetExtent(300, 60)
    multBtn:AddAnchor("BOTTOMRIGHT", calcWnd, -15, -180)
    multBtn:SetText("*")
    multBtn:Enable(true)
    api.Interface:ApplyButtonSkin(multBtn, BUTTON_BASIC.DEFAULT)

    diviBtn = calcWnd:CreateChildWidget("button", "diviBtn", 0, true)
    diviBtn:SetExtent(300, 60)
    diviBtn:AddAnchor("BOTTOM", calcWnd, 0, -180)
    diviBtn:SetText("/")
    diviBtn:Enable(true)
    api.Interface:ApplyButtonSkin(diviBtn, BUTTON_BASIC.DEFAULT)

    delBtn = calcWnd:CreateChildWidget("button", "delBtn", 0, true)
    delBtn:SetExtent(300, 60)
    delBtn:AddAnchor("BOTTOMLEFT", calcWnd, 15, -180)
    delBtn:SetText("del")
    delBtn:Enable(true)
    api.Interface:ApplyButtonSkin(delBtn, BUTTON_BASIC.DEFAULT)

    oneBtn = calcWnd:CreateChildWidget("button", "oneBtn", 0, true)
    oneBtn:SetExtent(300, 60)
    oneBtn:AddAnchor("BOTTOMLEFT", calcWnd, 15, -110)
    oneBtn:SetText("1")
    oneBtn:Enable(true)
    api.Interface:ApplyButtonSkin(oneBtn, BUTTON_BASIC.DEFAULT)

    twoBtn = calcWnd:CreateChildWidget("button", "twoBtn", 0, true)
    twoBtn:SetExtent(300, 60)
    twoBtn:AddAnchor("BOTTOM", calcWnd, 0, -110)
    twoBtn:SetText("2")
    twoBtn:Enable(true)
    api.Interface:ApplyButtonSkin(twoBtn, BUTTON_BASIC.DEFAULT)

    threeBtn = calcWnd:CreateChildWidget("button", "threeBtn", 0, true)
    threeBtn:SetExtent(300, 60)
    threeBtn:AddAnchor("BOTTOMRIGHT", calcWnd, -15, -110)
    threeBtn:SetText("3")
    threeBtn:Enable(true)
    api.Interface:ApplyButtonSkin(threeBtn, BUTTON_BASIC.DEFAULT)

    fourBtn = calcWnd:CreateChildWidget("button", "fourBtn", 0, true)
    fourBtn:SetExtent(300, 60)
    fourBtn:AddAnchor("BOTTOMLEFT", calcWnd, 15, -75)
    fourBtn:SetText("4")
    fourBtn:Enable(true)
    api.Interface:ApplyButtonSkin(fourBtn, BUTTON_BASIC.DEFAULT)

    fiveBtn = calcWnd:CreateChildWidget("button", "fiveBtn", 0, true)
    fiveBtn:SetExtent(300, 60)
    fiveBtn:AddAnchor("BOTTOM", calcWnd, 0, -75)
    fiveBtn:SetText("5")
    fiveBtn:Enable(true)
    api.Interface:ApplyButtonSkin(fiveBtn, BUTTON_BASIC.DEFAULT)

    sixBtn = calcWnd:CreateChildWidget("button", "sixBtn", 0, true)
    sixBtn:SetExtent(300, 60)
    sixBtn:AddAnchor("BOTTOMRIGHT", calcWnd, -15, -75)
    sixBtn:SetText("6")
    sixBtn:Enable(true)
    api.Interface:ApplyButtonSkin(sixBtn, BUTTON_BASIC.DEFAULT)

    sevenBtn = calcWnd:CreateChildWidget("button", "onsevenBtneBtn", 0, true)
    sevenBtn:SetExtent(300, 60)
    sevenBtn:AddAnchor("BOTTOMLEFT", calcWnd, 15, -40)
    sevenBtn:SetText("7")
    sevenBtn:Enable(true)
    api.Interface:ApplyButtonSkin(sevenBtn, BUTTON_BASIC.DEFAULT)

    eightBtn = calcWnd:CreateChildWidget("button", "eightBtn", 0, true)
    eightBtn:SetExtent(300, 60)
    eightBtn:AddAnchor("BOTTOM", calcWnd, 0, -40)
    eightBtn:SetText("8")
    eightBtn:Enable(true)
    api.Interface:ApplyButtonSkin(eightBtn, BUTTON_BASIC.DEFAULT)

    nineBtn = calcWnd:CreateChildWidget("button", "nineBtn", 0, true)
    nineBtn:SetExtent(300, 60)
    nineBtn:AddAnchor("BOTTOMRIGHT", calcWnd, -15, -40)
    nineBtn:SetText("9")
    nineBtn:Enable(true)
    api.Interface:ApplyButtonSkin(nineBtn, BUTTON_BASIC.DEFAULT)

    resetBtn = calcWnd:CreateChildWidget("button", "resetBtn", 0, true)
    resetBtn:SetExtent(300, 60)
    resetBtn:AddAnchor("BOTTOMLEFT", calcWnd, 15, -5)
    resetBtn:SetText("CE")
    resetBtn:Enable(true)
    api.Interface:ApplyButtonSkin(resetBtn, BUTTON_BASIC.DEFAULT)

    zeroBtn = calcWnd:CreateChildWidget("button", "zeroBtn", 0, true)
    zeroBtn:SetExtent(300, 60)
    zeroBtn:AddAnchor("BOTTOM", calcWnd, 0, -5)
    zeroBtn:SetText("0")
    zeroBtn:Enable(true)
    api.Interface:ApplyButtonSkin(zeroBtn, BUTTON_BASIC.DEFAULT)

    sumBtn = calcWnd:CreateChildWidget("button", "sumBtn", 0, true)
    sumBtn:SetExtent(300, 60)
    sumBtn:AddAnchor("BOTTOMRIGHT", calcWnd, -15, -5)
    sumBtn:SetText("=")
    sumBtn:Enable(true)
    api.Interface:ApplyButtonSkin(sumBtn, BUTTON_BASIC.DEFAULT)

	function calcBtn:OnClick()
        if not calcWnd:IsVisible() then
            calcWnd:Show(true)
        else
            calcWnd:Show(false)
        end
	end
	calcBtn:SetHandler("OnClick", calcBtn.OnClick)

    addBtn:SetHandler("OnClick", function()
        calcInput:SetText(calcInput:GetText() .. "+")
    end)
    subBtn:SetHandler("OnClick", function()
        calcInput:SetText(calcInput:GetText() .. "-")
    end)
    commaBtn:SetHandler("OnClick", function()
        calcInput:SetText(calcInput:GetText() .. ".")
    end)
    multBtn:SetHandler("OnClick", function()
        calcInput:SetText(calcInput:GetText() .. "*")
    end)
    diviBtn:SetHandler("OnClick", function()
        calcInput:SetText(calcInput:GetText() .. "/")
    end)
    delBtn:SetHandler("OnClick", function()
        local currentString = calcInput:GetText()
        if currentString ~= nil and currentString ~= "" then
            currentString = string.sub(currentString, 1, -2)
        end
        calcInput:SetText(currentString)
        if currentString == nil or currentString == "" then
            calcInput:SetText("Test")
            calcInput:SetText("")
            calcOutput:SetText("Test")
            calcOutput:SetText("")
            calcInput:CreateGuideText("Your Input") 
            calcOutput:CreateGuideText("Your Output")
        end
    end)
    oneBtn:SetHandler("OnClick", function()
        calcInput:SetText(calcInput:GetText() .. "1")
    end)
    twoBtn:SetHandler("OnClick", function()
        calcInput:SetText(calcInput:GetText() .. "2")
    end)
    threeBtn:SetHandler("OnClick", function()
        calcInput:SetText(calcInput:GetText() .. "3")
    end)
    fourBtn:SetHandler("OnClick", function()
        calcInput:SetText(calcInput:GetText() .. "4")
    end)
    fiveBtn:SetHandler("OnClick", function()
        calcInput:SetText(calcInput:GetText() .. "5")
    end)
    sixBtn:SetHandler("OnClick", function()
        calcInput:SetText(calcInput:GetText() .. "6")
    end)
    sevenBtn:SetHandler("OnClick", function()
        calcInput:SetText(calcInput:GetText() .. "7")
    end)
    eightBtn:SetHandler("OnClick", function()
        calcInput:SetText(calcInput:GetText() .. "8")
    end)
    nineBtn:SetHandler("OnClick", function()
        calcInput:SetText(calcInput:GetText() .. "9")
    end)
    resetBtn:SetHandler("OnClick", function()
        calcInput:SetText("Test")
        calcInput:SetText("")
        calcOutput:SetText("Test")
        calcOutput:SetText("")
        calcInput:CreateGuideText("Your Input") 
        calcOutput:CreateGuideText("Your Output")
    end)
    zeroBtn:SetHandler("OnClick", function()
        calcInput:SetText(calcInput:GetText() .. "0")
    end)
    sumBtn:SetHandler("OnClick", onSumButtonPress)
end

function OnUnload()
    if calcBtn then
        calcBtn:Show(false)
        calcBtn = nil
    end

    if calcWnd then
        calcWnd:Show(false)
        calcWnd = nil
    end
end

Calculator.OnLoad = OnLoad
Calculator.OnUnload = OnUnload

return Calculator
