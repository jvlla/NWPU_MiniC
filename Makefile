CFLAGS = -g

.PHONY: all, prepare, compiler_haotian, clean, tmpclean, zip

all: prepare compiler_haotian

# prepare: lexer.l parser.y 
# 	flex -o lexer.c --header-file=lexer.h lexer.l
# 	bison -d -o parser.c parser.y

# compiler_haotian: lexer.o parser.o main.o
# 	gcc $(CFLAGS) -o $@ lexer.o parser.o main.o

# # expr.o: expr.c expr.h
# # 	gcc $(CFLAGS) -c -o expr.o expr.c

# lexer.o: lexer.c lexer.h
# 	gcc $(CFLAGS) -c -o lexer.o lexer.c

# parser.o: parser.c parser.h lexer.h
# 	gcc $(CFLAGS) -c -o parser.o parser.c

# main.o: main.c lexer.h parser.h
# 	gcc $(CFLAGS) -c -o main.o main.c

# 全变成cpp好像有问题
prepare: lexer.l parser.y 
	flex -o lexer.cpp --header-file=lexer.h lexer.l
	bison -d -o parser.cpp parser.y

compiler_haotian: lexer.o parser.o main.o
	gcc $(CFLAGS) -o $@ lexer.o parser.o main.o

# expr.o: expr.c expr.h
# 	gcc $(CFLAGS) -c -o expr.o expr.c

lexer.o: lexer.cpp lexer.h
	g++ $(CFLAGS) -c -o lexer.o lexer.cpp

parser.o: parser.cpp parser.hpp lexer.h
	g++ $(CFLAGS) -c -o parser.o parser.cpp

main.o: main.cpp lexer.h parser.hpp
	g++ $(CFLAGS) -c -o main.o main.cpp

tmpclean:
	rm -rf *.o

clean:
	rm -rf *.o
	rm -rf *.dSYM
	rm -f lexer.c lexer.cpp lexer.h
	rm -f parser.c parser.cpp parser.h parser.hpp
	rm -f compiler_haotian

zip:
	tar --exclude *.tar.* -cvf compiler_haotian.tar *
	gzip -f compiler_haotian.tar
