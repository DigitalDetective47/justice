SMODS.Atlas({
    key = "modicon",
    path = "icon.png",
    px = 34,
    py = 34,
})

---@param strs string[]
---@param between string?
---@return string
local function joinStrings(strs, between)
    if #strs == 0 then
        return ""
    elseif #strs == 1 then
        return strs[1]
    end
    between = between or ""
    ---@type string
    local combined = strs[1]
    for index, str in ipairs(strs) do
        if index ~= 1 then
            combined = combined .. between .. str
        end
    end
    return combined
end

---convert a string into a pattern that matches it
---@param literal string
---@return string
local function patternize(literal)
    ---@type string[]
    local chars = {}
    for match in literal:gmatch(".") do
        table.insert(chars, match:gmatch("%w")() and match or ("%" .. match))
    end
    return joinStrings(chars)
end

---@param str string the string to split
---@param sep string character that the string should split by<br>only one character allowed
---@return string[]
local function splitString(str, sep)
    ---@type string[]
    local segments = {}
    for match in str:gmatch("[^" .. patternize(sep) .. "]+") do
        table.insert(segments, match)
    end
    return segments
end

---@param num number
---@return string
local function standardFormatter(num)
    ---@type string[]
    local partitions = splitString(("%f"):format(num), ".")
    ---@type string[]
    local digitGroups = {}
    for match in partitions[1]:reverse():gmatch("%d%d?%d?") do
        table.insert(digitGroups, match)
    end
    partitions[1] = joinStrings(digitGroups, SMODS.Mods.NumberFormat.config.standard.thousandsSeparator):reverse()
    partitions[2] = partitions[2]:gsub("0*$", "")
    if partitions[2] == "" then
        partitions[2] = nil
    end
    return joinStrings(partitions, SMODS.Mods.NumberFormat.config.decimalPoint)
end

---@param num number
---@return integer[] mantissa a list of digits in the mantissa
---@return integer exponent
local function sciValues(num)
    ---@type string[]
    local segments = {}
    for match in ("%." .. math.max(SMODS.Mods.NumberFormat.config.scientific.digits - 1, 0) .. "e"):format(num):gmatch("[%-%d%.]+") do
        table.insert(segments, match)
    end
    ---@type integer[]
    local digits = {}
    if SMODS.Mods.NumberFormat.config.scientific.digits ~= 0 then
        for match in segments[1]:gmatch("%d") do
            ---@type number?
            local int = tonumber(match)
            if not int then
                sendErrorMessage("this message should not appear")
                return {}, 0
            end
            table.insert(digits, int)
        end
    end
    ---@type number?
    local exp = tonumber(segments[2])
    if not exp then
        sendErrorMessage("invalid exponent")
        return {}, 0
    end
    return digits, exp
end

---@param num number
---@param rounding integer? defaults to 3
---@return integer[] mantissa leading `-1`s are for when the whole number component is shorter than `rounding` digits
---@return integer exponent
local function engValues(num, rounding)
    rounding = rounding or 3
    local sciMantissa, sciExponent = sciValues(num)
    ---@type integer
    local mantissaAdjustment = sciExponent % rounding
    ---@type integer
    local engExponent = sciExponent - mantissaAdjustment
    ---@type integer[]
    local engMantissa = {}
    while #engMantissa + mantissaAdjustment < rounding - 1 do
        table.insert(engMantissa, -1)
    end
    for _, digit in ipairs(sciMantissa) do
        table.insert(engMantissa, digit)
    end
    while #engMantissa < rounding do
        table.insert(engMantissa, 0)
    end
    return engMantissa, engExponent
end

---@type (fun(num: number): string)[]
local scientificFormatters = {
    function(num)
        local mantissa, exponent = sciValues(num)
        ---@type string[]
        local mantissaStrings = {}
        for index, value in ipairs(mantissa) do
            if index == 1 and SMODS.Mods.NumberFormat.config.scientific.digits ~= 1 then
                mantissaStrings[index] = value .. SMODS.Mods.NumberFormat.config.decimalPoint
            else
                mantissaStrings[index] = tostring(value)
            end
        end
        return joinStrings(mantissaStrings) .. "e" .. exponent
    end,
    function(num)
        local mantissa, exponent = engValues(num)
        ---@type string[]
        local mantissaStrings = {}
        for index, value in ipairs(mantissa) do
            if value ~= -1 then
                if index == 3 and #mantissa ~= 3 then
                    table.insert(mantissaStrings, value .. SMODS.Mods.NumberFormat.config.decimalPoint)
                else
                    table.insert(mantissaStrings, tostring(value))
                end
            end
        end
        return joinStrings(mantissaStrings) .. "e" .. exponent
    end,
    function(num)
        local mantissa, exponent = engValues(num)
        if exponent < 3 then
            return standardFormatter(num)
        end
        ---@type string[]
        local mantissaStrings = {}
        for index, value in ipairs(mantissa) do
            if value ~= -1 then
                if index == 3 and #mantissa ~= 3 then
                    table.insert(mantissaStrings, value .. SMODS.Mods.NumberFormat.config.decimalPoint)
                else
                    table.insert(mantissaStrings, tostring(value))
                end
            end
        end
        return joinStrings(mantissaStrings) .. " " .. localize(math.floor(exponent / 3), "printf_illions")
    end,
    function(num)
        local mantissa, exponent = engValues(num, 6)
        if exponent < 6 then
            return standardFormatter(num)
        end
        ---@type string[]
        local mantissaStrings = {}
        for index, value in ipairs(mantissa) do
            if value ~= -1 then
                if index == 3 and #mantissa ~= 3 then
                    table.insert(mantissaStrings, value .. SMODS.Mods.NumberFormat.config.standard.thousandsSeparator)
                elseif index == 6 and #mantissa ~= 6 then
                    table.insert(mantissaStrings, value .. SMODS.Mods.NumberFormat.config.decimalPoint)
                else
                    table.insert(mantissaStrings, tostring(value))
                end
            end
        end
        return joinStrings(mantissaStrings) .. " " .. localize(math.floor(exponent / 6) + 1, "printf_illions")
    end,
}

---@param num number
---@return string
function number_format(num)
    if type(num) ~= "number" then
        sendErrorMessage("tried to call number_format on a value of type " .. type(num))
        return tostring(num)
    elseif num == math.huge then
        return SMODS.Mods.NumberFormat.config.infinityName
    elseif num == -math.huge then
        return "-" .. SMODS.Mods.NumberFormat.config.infinityName
    elseif num ~= num then
        return "NaN"
    elseif num == 0 or math.abs(math.log10(math.abs(num))) < SMODS.Mods.NumberFormat.config.switchPoint then
        return num < 0 and "-" .. standardFormatter(-num) or standardFormatter(num)
    else
        return num < 0 and "-" .. scientificFormatters[SMODS.Mods.NumberFormat.config.scientific.notationType](-num)
            or scientificFormatters[SMODS.Mods.NumberFormat.config.scientific.notationType](num)
    end
end

---@param scale number?
---@param amt number
---@return number
function score_number_scale(scale, amt)
    scale = scale or 1
    return math.min(20 / (number_format(amt):len() * 4 + 4), 0.75) * scale
end
