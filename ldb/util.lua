local util = {}


function util.table_nkey(t)
    local sz = 0
    local k = nil
    
    while true do
        k = next(t, k)
        if k then
            sz = sz + 1
        else
            break
        end
    end
    return sz
end


function util.bytesize2str(size)
	if size >= 1024*1024 then
		return string.format("%.2fMB", size/1024/1024)
	end
	if size >= 1024 then
		return string.format("%.2fKB", size/1024)
	end
	return string.format("%dB", size)
end


function util.patch(t, patch)
	for k,v in pairs(patch) do
		t[k] = v
	end
end



function util.enum(list)
	for i,v in ipairs(list) do
		list[v] = i
	end
	return list
end



function table.copy(t)
    local copy = {}
    for i, v in ipairs(t) do
        if type(v) == 'table' then
            copy[i] = table.copy(v)
        else
            copy[i] = v
        end
    end
    return copy
end


function util.copy(v)
	if type(v) == "table" then
		return table.copy(v)
	else
		return v
	end
end


return util