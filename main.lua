local ldb = require "ldb"


local function t2line(t)
    if type(t) ~= "table" then
        return tostring(t)
    else
        local s = "{"
        local count = 0
        for k,v in pairs(t) do
            count = count + 1
            -- 混合体, 数组部分
            if type(k) == "number" and k == count then
                s = s..t2line(v)..", "
            else
                s = s..k..":"..t2line(v)..", "
            end
        end
        return s:sub(1, #s-2).."}"
    end
end


local function dump(...)
	for _,v in ipairs({...}) do
		print(t2line(v))
	end
end



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

	local players = ldb.start{name = "players", multiple = 1000}


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
