all: parse-rtsl

run: parse-rtsl
	./$<

diff: sphere_test.out
	diff --color=auto $< rtsl/sphere.out

sphere_test.out: rtsl/sphere.rtsl parse-rtsl
	./parse-rtsl $< -o $@

parse-rtsl: rtsl.lex.c
	clang $< -lfl -o $@

rtsl.lex.c: rtsl.l
	lex -o $@ $<

clean:
	rm -rf rtsl.lex.c sphere_test.out parse-rtsl
