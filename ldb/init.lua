local logger = require "ldb.logger"


local M = {}





function M.start(conf)
	local filename = "ldb/data/"..assert(conf.name)


	return logger(filename)
end




return M