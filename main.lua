local ldb = require "ldb"


local function example1()
	print('single object example ---------------------------------------->')
	local game = ldb.start{name = "game"}

	game.set('id', 123)
	game.set('name', 'ddz')
	game.del('name')


	print("game.id", game.get('id'))
	print("game.name", game.get('name'))
	print()
end



local function example2()
	print('multiple objects example ------------------------------------->')

	local players = ldb.start{name = "players", multiple = 1000, profile = {id = true, gold = true}}


	players.set('openid_1', {id = 1, nick = 'windy', gold = 100})
	players.set('openid_2', {id = 2, nick = 'sun', gold = 100})


	local p1 = players.get('openid_1')
	local p2 = players.get('openid_2')


	p1 {
		gold = 999
	}

	dump(p1)
	dump(p2)
	print()
end


local function test(f, name)
	local c = os.clock()
	f()
	print(string.format("Test %s done, use %fs", name, os.clock() - c))
end


-- 10W 级别的测试 (将数据完全加载至内存前的 IO测试 我的机器大概是 1秒 20万个 对象，存储文件大小4.2MB)
local function example3( )
	print('multiple objects example ------------------------------------->')

	local ex3_config = ldb.start{name = "ex3_config"}
	local objects = ldb.start{name = "objects", multiple = 100000, profile = {id = true, gold = true}}

	local init_tag = "ex3_initialized_v1"

	local max = 100000

	local function init()
		for i=1,max do
			objects.set(i, {id = i, gold = i*100, name = "nick"..i})
		end
	end

	local function get_all()
		for i=1,max do
			objects.get(i)
		end
	end

	if not ex3_config.get(init_tag) then
		test(init, init_tag)
	else
		test(get_all, "get all objects")
	end

	dump(objects.get(1))

	ex3_config.set(init_tag, true)
end



-- example1()
-- example2()
example3()

print('bye')
