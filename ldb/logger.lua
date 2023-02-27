local serialize = require "serialize"


local function enum(list)
	for i,v in ipairs(list) do
		list[v] = i
	end
	return list
end


local COMMAND = enum{"init", "patch", "delete"}


local function logger(filename)
	local db = {}


	local command = {}

	function command.init(key, value)
		db[key] = value
	end

	function command.patch(key, patch)
		-- local obj = assert(t[key])
		-- util.patch(obj, patch)
	end

	function command.delete(key)
		db[key] = nil
	end


	local file, err = io.open(filename)
	if file then
		local clock = os.clock()
		while true do
			local head = file:read(2)
			if not head then
				break
			end
			local size = head:byte(1) * 256 + head:byte(2)
			local body = assert(file:read(size))
			local cmd, k, v = serialize.unpack(body)
			local f = command[assert(COMMAND[cmd])]
			f(k, v)
		end
		file:close()
		print(string.format('load file "%s" use %fs', filename, os.clock() - clock))
	else
		-- print(err)
	end

	local file = assert(io.open(filename, "a+"))

	local function write(...)
		local s = string.pack(">s2", serialize.pack(...))
		assert(file:write(s))
	end


	local self = {}

	function self.set(k, v)
		write(COMMAND.init, k, v)
		db[k] = v
		return self
	end

	function self.get(k)
		return db[k]
	end

	function self.del(k)
		write(COMMAND.delete, k)
		local v = db[k]
		db[k] = nil
		return v
	end

	return self
end


return logger