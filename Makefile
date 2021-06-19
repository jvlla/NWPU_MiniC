CFLAGS = -g

DIR_TABLE = SymTable
DIR_TREE = SynTree
DIR_TARGET = obj

SOURCE_TABLE = $(wildcard $(DIR_TABLE)/*.cpp)
SOURCE_TREE = $(wildcard $(DIR_TREE)/*.cpp)

TARGET_TABLE = $(patsubst %.cpp, $(DIR_TARGET)/%.o,$(notdir $(SOURCE_TABLE)))
TARGET_TREE = $(patsubst %.cpp, $(DIR_TARGET)/%.o,$(notdir $(SOURCE_TREE)))


.PHONY: all, prepare, compiler_haotian, clean, tmpclean, clean_translation

all: prepare $(TARGET_TABLE) $(TARGET_TREE) compiler_haotian

prepare: lexer.l parser.y 
	flex -o lexer.cpp --header-file=lexer.h lexer.l
	bison -d -o parser.cpp parser.y

$(DIR_TARGET)/lexer.o: lexer.cpp lexer.h
	g++ $(CFLAGS) -c -o $@ lexer.cpp

$(DIR_TARGET)/parser.o: parser.cpp parser.hpp lexer.h
	g++ $(CFLAGS) -c -o $@ parser.cpp

$(DIR_TARGET)/QuadTable.o: QuadTable.cpp QuadTable.h
	g++ $(CFLAGS) -c -o $@ QuadTable.cpp

$(DIR_TARGET)/helper.o: helper.cpp helper.h
	g++ $(CFLAGS) -c -o $@ helper.cpp

$(DIR_TARGET)/ParserException.o: ParserException.cpp ParserException.h
	g++ $(CFLAGS) -c -o $@ ParserException.cpp

$(DIR_TARGET)/LexerException.o: LexerException.cpp LexerException.h
	g++ $(CFLAGS) -c -o $@ LexerException.cpp

$(DIR_TARGET)/%.o: $(DIR_TABLE)/%.cpp
	g++ $(CFLAGS) -c -o $@ $<

$(DIR_TARGET)/%.o: $(DIR_TREE)/%.cpp
	g++ $(CFLAGS) -c -o $@ $<

$(DIR_TARGET)/main.o: main.cpp lexer.h parser.hpp
	g++ $(CFLAGS) -c -o $@ main.cpp

compiler_haotian: $(DIR_TARGET)/lexer.o $(DIR_TARGET)/parser.o $(DIR_TARGET)/QuadTable.o \
	$(DIR_TARGET)/helper.o $(DIR_TARGET)/ParserException.o $(DIR_TARGET)/LexerException.o \
	$(DIR_TARGET)/main.o
	g++ $(CFLAGS) -o $@ $(DIR_TARGET)/main.o $(DIR_TARGET)/lexer.o $(DIR_TARGET)/parser.o \
		$(DIR_TARGET)/QuadTable.o $(DIR_TARGET)/helper.o \
		$(DIR_TARGET)/ParserException.o $(DIR_TARGET)/LexerException.o \
		$(TARGET_TABLE) $(TARGET_TREE)

clean:
	rm -rf $(DIR_TARGET)/*
	rm -f lexer.cpp lexer.h
	rm -f parser.cpp parser.hpp
	rm -f compiler_haotian
	find . -name "*.dot"  | xargs rm -f
	find . -name "*.png"  | xargs rm -f
	find . -name "*_symbol_table.txt"  | xargs rm -f
	find . -name "*_quad.txt"  | xargs rm -f

tmpclean:
	rm -rf $(DIR_TARGET)/*.o

clean_translation:
	find . -name "*.dot"  | xargs rm -f
	find . -name "*.png"  | xargs rm -f
	find . -name "*_symbol_table.txt"  | xargs rm -f
	find . -name "*_quad.txt"  | xargs rm -f