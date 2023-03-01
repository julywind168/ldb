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



example1()
example2()

print('bye')
