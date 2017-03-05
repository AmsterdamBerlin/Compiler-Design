calc.yy.c: calc.y
	bison -o $@ -v $< 

calc.lex.c: calc.lex
	flex  -o $@ $<

calc.out: calc.lex.c calc.yy.c
	gcc -o calc.lex.c calc.yy.c

test.out: test8.rtsl
	./calc.out  $< -o $@
clean:
	rm -rf calc.out  calc.lex.c calc.yy.c calc.yy.h test8.out test8.err calc.yy.output
