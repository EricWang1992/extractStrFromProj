--[[
    作者：陈涛
    作用：查找cpp文件（夹）中的中文字符
    注意：不支持末尾用'\'换行的写法，如果cpp有这种换行字符串，将不会被匹配
]]

local contentList = {}

function string.split(input, delimiter)
    input = tostring(input)
    delimiter = tostring(delimiter)
    if (delimiter=='') then return false end
    local pos,arr = 0, {}
    -- for each divider found
    for st,sp in function() return string.find(input, delimiter, pos, true) end do
        table.insert(arr, string.sub(input, pos, st - 1))
        pos = sp + 1
    end
    table.insert(arr, string.sub(input, pos))
    return arr
end

--移自quick
function string.trim(input)
    input = string.gsub(input, "^[ \n\r\t]+", "")
    return string.gsub(input, "[ \n\r\t]+$", "")
end

--移自quick
function dump(value, desciption, nesting)
    if type(nesting) ~= "number" then nesting = 50 end

    local lookupTable = {}
    local result = {}

    local function _v(v)
        if type(v) == "string" then
            v = "\"" .. v .. "\""
        end
        return tostring(v)
    end

    local traceback = string.split(debug.traceback("", 2), "\n")
    print("dump from: " .. string.trim(traceback[3]))

    local function _dump(value, desciption, indent, nest, keylen)
        desciption = desciption or "<var>"
        spc = ""
        if type(keylen) == "number" then
            spc = string.rep(" ", keylen - string.len(_v(desciption)))
        end
        if type(value) ~= "table" then
            result[#result +1 ] = string.format("%s%s%s = %s", indent, _v(desciption), spc, _v(value))
        elseif lookupTable[value] then
            result[#result +1 ] = string.format("%s%s%s = *REF*", indent, desciption, spc)
        else
            lookupTable[value] = true
            if nest > nesting then
                result[#result +1 ] = string.format("%s%s = *MAX NESTING*", indent, desciption)
            else
                result[#result +1 ] = string.format("%s%s = {", indent, _v(desciption))
                local indent2 = indent.."    "
                local keys = {}
                local keylen = 0
                local values = {}
                for k, v in pairs(value) do
                    keys[#keys + 1] = k
                    local vk = _v(k)
                    local vkl = string.len(vk)
                    if vkl > keylen then keylen = vkl end
                    values[k] = v
                end
                table.sort(keys, function(a, b)
                    if type(a) == "number" and type(b) == "number" then
                        return a < b
                    else
                        return tostring(a) < tostring(b)
                    end
                end)
                for i, k in ipairs(keys) do
                    _dump(values[k], k, indent2, nest + 1, keylen)
                end
                result[#result +1] = string.format("%s}", indent)
            end
        end
    end
    _dump(value, desciption, "- ", 1)

    for i, line in ipairs(result) do
        print(line)
    end
end

require "lfs"
function findindir (path, wefind, r_table, intofolder)
    for file in lfs.dir(path) do
        if file ~= "." and file ~= ".." then
            local f = path..'/'..file
            if string.find(f, wefind) ~= nil then
                table.insert(r_table, f)
            end

            local attr = lfs.attributes (f)
            if (type(attr) == "table") then
                if attr.mode == "directory" and intofolder then
                    findindir(f, wefind, r_table, intofolder)
                end
            end
        end
    end
end

local function findTargetSuffix(folder, suffix, deep)
    local input_table = {}
    findindir(folder, suffix, input_table, deep)

    return input_table
end

function isChineseStr(str)
    if string.find(str, "[一-龥]") then
        return true
    end
    return false
end

function doNotExist(rt, list, str)
    -- 筛选当页重复
    for i=1,#list do
        if str == list[i] then
            print(str, list[i])
            return false
        end
    end
    -- 筛选项目重复
    for k,table in pairs(rt) do
        for k,v in pairs(table) do
            if v == str then
                return false
            end
        end
    end
    return true
end

function findChineseStr(filePath)
    local list = findTargetSuffix(filePath, "%.cpp", true)
    local rt = {}
    for k, v in pairs(list) do
        local file = io.open(v, "r+")
        local contentList = {}
        if file then
            -- 匹配中文字符
            -- for line in file:lines() do
            --     local _, _, result = string.find(line, "\"(.*)[\"]")
            --     if result then
            --         if isChineseStr(result) then
            --             contentList[#contentList + 1] = result
            --         end
            --     end
            -- end
            
             for line in file:lines() do
                while(1)
                do
                    local b, e, result = string.find(line, "\"(.-)[\"]")
                    if result  and isChineseStr(result) and doNotExist(rt, contentList, result) then
                        contentList[#contentList + 1] = result
                    else
                        break
                    end
                    line = string.sub(line, e + 1)
                end
            end

            io.close(file)
        end

        if #contentList >0 then 
            v = string.sub(v, string.len(filePath) + 1)
            rt[v] = contentList
        end
    end

    return rt
end

local logFilePath = "chineseStr.lua"
function dumpToFile(tab)
    local file = io.open(logFilePath, "w+")

    local oldFunc = print
    print = function( ... )
        file:write(...)
        file:write('\n')
    end

    dump(tab)

    io.close(file)
    print = oldFunc
end

--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
--[[
    基本功能：输出匹配到的中文，及文件名到一个文件
]]
-- local cppDir = "/Users/Lu/desktop/workspace/youybs-client/Classes/"
-- dumpToFile(findChineseStr(cppDir))


--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
--[[
    额外需求：将匹配到的中文输出xml
]]

function dumpToXml(list)
    local headStr = "<?xml version=\"1.0\" encoding=\"UTF-8\"?>"
    local description = "<!-- 需求来啦! -->\
<!-- 1.按照这个格式来 -->\
<!-- 2.param1 自动增长  param2 去重 param3 默认为0就行 -->"
    local rootStr = "<messages>"
    local endStr = "</messages>"
    local logFilePath = "localization.xml"
    local logFormat = "<message messageid=\"%d\" messageContent=\"%s\" paramsnum=\"0\" filePath=\"%s\"/>"

    local file = io.open(logFilePath, "w+")
    if file then 
        function write(str, withTab)
            if withTab then
                file:write("    ")
            end
            file:write(str)
            file:write("\n")
        end

        write(headStr)
        write(description)
        write(rootStr)

        local index = 10000
        for fileName, tab in pairs(list) do
            for k, v in pairs(tab) do
                index = index + 1
                write(string.format(logFormat, index, v, fileName), true)
            end
        end
        write(endStr)

        io.close(file)
    end
end

local cppDir = "/Users/ericwang/Documents/workspace/pkq-client/projects/pkq-client/Classes/Game"
dumpToXml(findChineseStr(cppDir))






