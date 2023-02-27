local game = (require "ldb").start{name = "game"}


game.set('id', 123)
game.set('name', 'ddz')
game.del('name')


print(game.get('id'), game.get('name'))
print('bye')