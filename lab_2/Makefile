result:rtsl.y rtsl.lex
	bison -d -v ./rtsl.y -o rtsl.yy.c
	flex -o rtsl.lex.c ./rtsl.lex
	gcc -o rtsl.out rtsl.lex.c rtsl.yy.c
	./rtsl.out assignment2/test8.rtsl > test8.out > test8.err
clean:
	rm rtsl.out  rtsl.lex.c rtsl.yy.c rtsl.yy.h test8.out test8.err rtsl.yy.output
