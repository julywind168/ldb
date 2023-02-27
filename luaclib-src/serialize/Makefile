all : serialize.so

linux : serialize.so

serialize.so : charbuffer.c serialize.c
	gcc -Wall -g -o $@ -fPIC --shared $^ -I/usr/include/lua5.4

serialize : charbuffer.c serialize.c
	gcc -Wall -g -o $@.dll --shared $^ -I/usr/local/include -L/usr/local/bin -llua53