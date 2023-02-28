local util = require "ldb.util"
local collection = require "ldb.collection"

-- Default tolerable redundancy
local default_reduce = {
	singleton = 2,
	multiple = 1.5
}



local M = {
	TYPE = util.enum{"singleton", "multiple", "logs"}
}





function M.start(conf)
	local filename = "ldb/data/"..assert(conf.name)
	local type = conf.type or "singleton"
	local reduce = conf.reduce or default_reduce[type]
	if type == "logs" then
		reduce = nil
	end
	return collection(filename, type, reduce)
end




return M