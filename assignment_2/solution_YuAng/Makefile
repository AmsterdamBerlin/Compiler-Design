result:rtsl.y rtsl.lex
	bison -d -v ./rtsl.y -o rtsl.yy.c
	flex -o rtsl.lex.c ./rtsl.lex
	gcc -o rtsl.out rtsl.lex.c rtsl.yy.c
	./rtsl.out assignment2/test1.rtsl > test1.out > test1.err
clean:
	rm -rf rtsl.out  rtsl.lex.c rtsl.yy.c rtsl.yy.h test1.out test1.err rtsl.yy.output
