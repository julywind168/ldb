local util = require "ldb.util"
local collection = require "ldb.collection"

-- Default tolerable redundancy
local default_reduce = {
	single = 2,
	multiple = 1.5
}



local M = {}


function M.start(conf)
	local filename = "ldb/data/"..assert(conf.name)
	conf.reduce = conf.reduce or (conf.multiple and default_reduce.multiple or default_reduce.single)
	assert(conf.reduce > 1, string.format("reduce %.2f must greater than 1.0", conf.reduce))
	return collection(filename, conf)
end




return M