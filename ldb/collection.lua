local util = require "ldb.util"
local serialize = require "serialize"


local COMMAND = util.enum{"init", "patch", "delete"}


local function collection(filename, coll_type)
	local db = {}


	local command = {}

	function command.init(k, v)
		db[k] = v
	end

	function command.patch(k, patch)
		local t = assert(db[k])
		util.patch(t, patch)
	end

	function command.delete(k)
		db[k] = nil
	end


	local file, err = io.open(filename)
	if file then
		local file_size = 0 

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

			file_size = file_size + 2 + size
		end
		file:close()
		print(string.format('Loaded file "%s[%s]" use %fs', filename, util.bytes2str(file_size), os.clock() - clock))
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
		local v = db[k]

		-- create a read-only proxy, but can use `proxy{k = v}` to update it. 
		if type(v) == "table" and coll_type == "multiple" then
			local proxy = setmetatable({}, {
				__index = v,
				__pairs = function ()
					return pairs(v)
				end,
				__newindex = function()
					error("ldb object‘s proxy is read-only!")
				end,
				__call = function (_, patch)
					write(COMMAND.patch, k, patch)
					command.patch(k, patch)
					return proxy
				end
			})
			return proxy
		else
			return util.copy(v)
		end
	end

	function self.del(k)
		write(COMMAND.delete, k)
		local v = db[k]
		db[k] = nil
		return v
	end

	return self
end


return collection