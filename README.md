# ldb
A simple and fast lua database library


## 概述
```
ldb 中 collection 来源于 mongo, 每个coll 用一个或多个文件进行存储，根据使用场景 ldb 将 coll 分为3个类型
 
single: 单一对象 (coll本身)
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
详情例子见 main.lua
```



## Test (推荐在 unix 下进行)
```
0. 请提前安装 lua 环境 (apt install liblua5.4-dev)
1. git clone https://github.com/HYbutterfly/ldb.git hello-ldb
2. 进入 hello-ldb/luaclib-src/serialize build, 将编译出来的 serialize.so 拷到 hello-ldb
3. 进入 hello-ldb 执行 lua main.lua
```


## 特性
```
数据文件压缩(覆写):
随着不断的使用, collection 对应的数据文件, 会不断增加无效的指令. 我们需要根据指令的冗余度来决定是否压缩.
冗余度 = 所有指令数/集合key的数量
singleton collection 本身大小就比较小，可容忍的冗余度可以稍高, 比如 2 ~ 10
multiple collection，可容忍的冗余度，我觉得 1.5 左右比较好


超大数据集合：
ldb 的目标是 在游戏开发中 代替 mongo/redis ， 那么可存储数据量级就不能太少。同时了为了性能和实现的简单.
将每个 collection 容量限制在 1000万个 object 比较合适。经测试 1000万个 简单的 table {id = i, gold = 2}。占用的内存大概是 1.2GB, 假设你有1000万注册，这1.2G内存成本应该还是支付的起的。

内存优化思路，在 loadfile 的过程中，我们只加载 object 的精简信息(profile)，当程序查询某个object时，再真正加载该object(full version)
```
