--
-- for debug
--


local function t2line(t)
    if type(t) ~= "table" then
        return tostring(t)
    else
        local s = "{"

        local length = #t
        local printed = {}

        if length > 0 then
        	for i,v in ipairs(t) do
        		printed[i] = true
        		s = s..t2line(v)..", "
        	end
        end

        for k,v in pairs(t) do
        	if not printed[k] then
       			s = s..k..":"..t2line(v)..", "
       		end
        end
        return s:sub(1, #s-2).."}"
    end
end


function dump(...)
	for _,v in ipairs({...}) do
		print(t2line(v))
	end
end