local util = require "ldb.util"
local serialize = require "serialize"

local COMMAND = util.enum{"init", "patch", "delete"}


local function load_file(filename)
	local db = {}
	local mt = {
		size = 0,
		ncmd = 0,
		nkey = 0
	}

	local command = {}

	function command.init(k, v)
		if not db[k] then
			mt.nkey = mt.nkey + 1
		end
		db[k] = v
	end

	function command.patch(k, patch)
		local t = assert(db[k], string.format("not found key:%s in %s", k, filename))
		util.patch(t, patch)
	end

	function command.delete(k)
		local v = db[k]
		if v then
			mt.nkey = mt.nkey - 1
			db[k] = nil
		end
		return v
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

			mt.size = mt.size + 2 + size
			mt.ncmd = mt.ncmd + 1
		end
		file:close()
		print(string.format('File [%s] Loaded, size:%s use %fs', filename, util.bytesize2str(mt.size), os.clock() - clock))
	else
		-- print(err)
	end
	return db, mt, command
end


local function writer(filename, mode)
	local file = assert(io.open(filename, mode))

	local function write(...)
		local s = string.pack(">s2", serialize.pack(...))
		assert(file:write(s))
	end

	local function close()
		file:close()
	end

	return write, close
end


local function overwrite(filename, db)
	local clock = os.clock()
	local write, close = writer(filename, "w")
	for k,v in pairs(db) do
		write(COMMAND.init, k, v)
	end
	close()
	print(string.format('File [%s] overwrite done use %fs', filename, os.clock() - clock))
end



local function collection(filename, conf)

	-- Load data from file, and check redundancy
	local db, mt, command = load_file(filename)

	if mt.ncmd/mt.nkey > conf.reduce then
		print(string.format('File [%s] redundancy is %0.2f, will been overwrite', filename, mt.ncmd/mt.nkey))
		overwrite(filename, db)
	end

	-- Reopen and wait for writing
	local write, close = writer(filename, "a+")


	local self = setmetatable({}, {__gc = function ()
		close()
	end})

	function self.set(k, v)
		write(COMMAND.init, k, v)
		command.init(k, v)
		return self
	end

	function self.get(k)
		local v = db[k]

		-- create a read-only proxy, but can use `proxy{k = v}` to update it. 
		if conf.multiple and type(v) == "table" then
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
		return command.delete(k)
	end

	return self
end


return collection