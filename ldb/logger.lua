local util = require "ldb.util"
local serialize = require "serialize"

local COMMAND = util.enum{"init", "patch", "delete"}


local function logger(filename, mode)

	local file, err = io.open(filename, mode)
	if not file then
		return nil, err
	end

	local self = {name = filename}

	function self.reopen()
		assert(not file)
		file, err = io.open(filename, mode)
		return file, err
	end

	function self.read_line()
		local head = file:read(2)
		if not head then
			return
		end
		local size = head:byte(1) * 256 + head:byte(2)
		local body = assert(file:read(size))
		local cmd, k, v = serialize.unpack(body)
		return size + 2, cmd, k, v
	end

	function self.write_line(...)
		local s = string.pack(">s2", serialize.pack(...))
		assert(file:seek("end"))
		assert(file:write(s))
	end

	function self.load_object(offsets, keyname)
		local obj
		for i,offset in ipairs(offsets) do
			assert(file:seek("set", offset))
			local _, cmd, k, v = self.read_line()
			if i == 1 then
				assert(cmd == COMMAND.init)
				obj = v
			else
				assert(cmd == COMMAND.patch)
				for key,value in pairs(v) do
					obj[key] = value
				end
			end
		end
		return assert(obj, string.format("Failed load object %s in file:%s", keyname, filename))
	end

	function self.close()
		file:close()
		file = nil
	end

	return self
end


return logger