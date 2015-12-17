local logFilePath = "localization.xml"
function replaceFormatStr()
    local file = io.open(logFilePath, "r+")

    local buffer = {}
    local globalIndex = 10000 - 1
    local targetNum = "%d+"
    local prefix = "messageid=\""
    local suffix = "\""
    if file then 
        for line in file:lines() do
            local index = -1
            local content, count = string.gsub(line, "%%[dfsu]", function(...)
            -- local content, count = string.gsub(line, "##", function(...)
                index = index + 1
                -- return "##"
                return "##" .. index
            end)

            content = string.gsub(content, "paramsnum=\"%d+\"", "paramsnum=\"" .. count .. "\"")

            content = string.gsub(content, prefix .. targetNum .. suffix, function()
                globalIndex = globalIndex + 1
                return prefix .. globalIndex .. suffix
            end)
            buffer[#buffer + 1] = content
        end

        io.close(file)
    end

    local file = io.open(logFilePath, "w+")
    if file then 
        for k, v in pairs(buffer) do
            file:write(v)
            file:write("\n")
        end

        io.close(file)
    end
end

replaceFormatStr()