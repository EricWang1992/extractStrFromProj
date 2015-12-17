local target = "localization.xml"

function check(target)
	local file = io.open(target, "r+")
	if file then 
		local lineNumber = 0
		for line in file:lines() do
			lineNumber = lineNumber + 1
			local t, count = string.gsub(line, "##", "##")
			local s, subEnd = string.find(line, "paramsnum=", 0)
			if subEnd ~= nil then
				local subStr = string.sub(line, subEnd+2, subEnd+2)
				if count ~= tonumber(subStr) then
					print("第" .. lineNumber .. "行参数数量不匹配, 需要的参数数量是" .. count)
				end
			end
		end
	end
end
check(target)