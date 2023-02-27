local util = require "ldb.util"
local collection = require "ldb.collection"



local M = {
	TYPE = util.enum{"singleton", "multiple", "logs"}
}





function M.start(conf)
	local filename = "ldb/data/"..assert(conf.name)
	local type = conf.type or "singleton"
	return collection(filename, type)
end




return M