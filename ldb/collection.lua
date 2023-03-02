local util = require "ldb.util"
local serialize = require "serialize"
local logger = require "ldb.logger"

local COMMAND = util.enum{"init", "patch", "delete"}


local function new_db(filename, conf)
	local multiple = conf.multiple
	local profile = conf.profile
	if multiple then
		profile = conf.profile or {}
	end

	local log = logger(filename, "a+")
	local db = {}
	local mt = {size = 0, ncmd = 0, nkey = 0}


	local function write(...)
		log.write_line(...)
		mt.ncmd = mt.ncmd + 1
	end


	local command = {}

	function command.init(k, v, offset)
		if not db[k] then
			mt.nkey = mt.nkey + 1
		end
		if multiple then
			v = util.reduce(v, profile)
			v.__profile = true
			v[1] = offset

			db[k] = v
		else
			db[k] = v
		end
	end

	function command.patch(k, patch, offset)
		local t = assert(db[k], string.format("not found key:%s in %s", k, filename))
		assert(t.__profile)
		for k,v in pairs(patch) do
			if profile[k] then
				t[k] = v
			end
		end
		t[#t+1] = offset
	end

	function command.delete(k)
		local v = db[k]
		if v then
			mt.nkey = mt.nkey - 1
			db[k] = nil
		end
		return v
	end

	local self = {}


	function self.load()
		local clock = os.clock()
		while true do
			local size, cmd, k, v = log.read_line()
			if not size then
				break
			end
			local f = command[assert(COMMAND[cmd])]
			f(k, v, mt.size)

			mt.size = mt.size + size
			mt.ncmd = mt.ncmd + 1
		end
		if mt.size > 0 then
			print(string.format('File [%s] Loaded, size:%s use %fs', log.name, util.bytesize2str(mt.size), os.clock() - clock))
		end
		return self
	end

	function self.redundancy()
		return mt.ncmd/mt.nkey
	end


	function self.reduce()
		local clock = os.clock()
		local tmp_log = logger(log.name..".tmp", "w")

		for k,v in pairs(db) do
			if multiple and v.__profile then
				v = log.load_object(v, k)
			end
			tmp_log.write_line(COMMAND.init, k, v)
			db[k] = nil
		end

		log.close()
		tmp_log.close()
		os.remove(log.name)
		os.rename(tmp_log.name, log.name)
		log.reopen()
		mt.ncmd = mt.nkey
		print(string.format('File [%s] reduce done use %fs', log.name, os.clock() - clock))
	end

	function self.set(k, v)
		write(COMMAND.init, k, v)
		if not db[k] then
			mt.nkey = mt.nkey + 1
		end
		db[k] = v
	end

	local function obj_patch(k, p)
		local t = assert(db[k], string.format("not found key:%s in %s", k, log.name))
		write(COMMAND.patch, k, p)
		for k,v in pairs(p) do
			t[k] = v
		end
	end

	function self.get(k)
		local v = db[k]

		-- create a read-only proxy, but can use `proxy{k = v}` to update it. 
		if multiple then
			assert(type(v) == "table")

			if v.__profile then
				v = log.load_object(v, k)
				db[k] = v
			end

			local proxy = setmetatable({}, {
				__index = v,
				__pairs = function ()
					return pairs(v)
				end,
				__newindex = function()
					error("ldb object‘s proxy is read-only!")
				end,
				__call = function (_, patch)
					obj_patch(k, patch)
					return proxy
				end
			})
			return proxy
		else
			return util.copy(v)
		end
	end

	function self.del(k)
		local v = db[k]
		if v then
			write(COMMAND.delete, k)
			mt.nkey = mt.nkey - 1
			db[k] = nil
		end
		return v
	end

	function self.dump()
		print(string.format("File [%s] nkey:%d, ncmd:%s", filename, mt.nkey, mt.ncmd))
	end


	return self
end


local function collection(filename, conf)
	local db = new_db(filename, conf).load()

	if db.redundancy() > conf.reduce then
		db.dump()
		db.reduce()
	end
	db.dump()

	local self = {
		set = db.set,
		get = db.get,
		del = db.del
	}

	return self
end


return collection