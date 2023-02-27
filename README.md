# ldb
A simple and fast lua database library


## 概述
```
ldb 中 collection 来源于 mongo, 每个coll 用一个或多个文件进行存储，根据使用场景 ldb 将 coll 分为3个类型
 
singleton: 单一对象 (coll本身)
	game: {
		count = 5,
		online = {p1, p2, p3}
	}

multiple: 多个对象的集合 (已生成的 obj 可以 patch 修改)
	players: {
		[openid_1] = {id = 1, nick = 'haha', gold = 100},
		[openid_2] = {id = 2, nick = 'xixi', gold = 200},
		...
	}

logs: 日志类型集合 (已生成的 obj 无法修改)
	player_logs: {
		[1] = {pid = 1, action = 'bet', time: 123},
		[2] = {pid = 2, action = 'bet', time: 456},
		...
	}

详情例子见 main.lua
```



## Test (推荐在 unix 下进行)
```
0. 请提前安装 lua 环境 (apt install liblua5.4-dev)
1. git clone https://github.com/HYbutterfly/ldb.git hello-ldb
2. 进入 hello-ldb/luaclib-src/serialize build, 将编译出来的 serialize.so 拷到 hello-ldb
3. 进入 hello-ldb 执行 lua main.lua
```


## Todo
日志文件数据的压缩