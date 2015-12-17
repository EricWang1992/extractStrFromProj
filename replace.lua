
local cppDir = "/Users/ericwang/Documents/Classes"
local sourcePath = "localization.xml"

require "lfs"
function findInDir(path, suffix, input_table, deep)
	for file in lfs.dir(path) do
		if file ~= "." and file ~= ".." then
			local f  = path .. "/" .. file
			if string.find(f, suffix) ~= nil then
				table.insert(input_table, f)
			end

			local attr = lfs.attributes(f)
			if (type(attr) == "table") then
				if attr.mode == "directory" and deep then
					findInDir(f, suffix, input_table, deep)
				end
			end
		end
	end
end

function findTargetSuffix(folder, suffix, deep)
	local input_table = {}
	findInDir(folder, suffix, input_table, deep)

	return input_table
end


function findAllFilesByPath(filePath, ID, pattern)
	local list = findTargetSuffix(filePath, "%.cpp", true)	--获得所有的cpp文件
	local rt = {}
	local outputBuffer = {}
	-- print(pattern)
	local num = 0;
	for k,v in pairs(list) do
		local buffer = {}
		local file = io.open(v, "r+")
		local contentList = {}
		if file then
			num = num +1
			-- print(ID .. " 已查找的文件数量: " .. num)
			local i = 0
			for line in file:lines() do
				local  output
				i = i + 1
				local startPos
				local endPos
				startPos, endPos, result = string.find(line, pattern)	--string.find的返回值分别为, 起始位置, 结束位置, 找到的字符串
				if startPos ~= nil then
					print(v .. " 行号: " .. i .. "   -------------------" .. pattern .. " 对应编号:" .. ID .. "        已成功替换!")
					output = v .. " 行号: " .. i .. "   -------------------" .. pattern .. " 对应编号:" .. ID .. "        已成功替换!"
					outputBuffer[#outputBuffer + 1] = output
				end
				local content, count = string.gsub(line,  pattern, "NSGameHelper::getMsg(" .. ID .. ")" )
				buffer[#buffer + 1] = content
			end
			io.close(file)
		end
		local file = io.open(v, "w+")
		if file then
			for k,v in pairs(buffer) do
				file:write(v)
				file:write("\n")
			end
			io.close(file)
		end
	end
	-- print(outputBuffer)
	-- local outputFile = io.open("record.txt", "w+")
	-- if outputFile then
	-- 	for k,v in pairs(outputBuffer) do
	-- 		print(v)
	-- 		outputFile:write(v)
	-- 		outputFile:write("\n")
	-- 	end
	-- 	outputFile:close()
	-- end
end

function replaceStr()
	local file = io.open(sourcePath, "r+")
	if file then
		-- findAllFilesByPath(cppDir, 10729, "购买查案次数")
		for line in file:lines() do
			local startPos
			local endPos
			_, endPos = string.find(line, "messageContent=\"", 0)
			startPos, e = string.find(line, "paramsnum", 0)
			if endPos ~= nil and startPos ~= nil then
				local ID = string.sub(line, 25, 29)	-- messageID
				local pattern = string.sub(line, endPos, startPos-2)		-- messageContent
				local paramsnum = string.sub(line, e+3, e+3)
				print(ID .. "    " .. pattern .. "  " .. "参数数量:" .. " " ..paramsnum)
				--得到content去cpp项目里开始查找替换
				-- findAllFilesByPath(cppDir, tonumber(ID), pattern)
			end
		end
	end
end

replaceStr()