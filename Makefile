.PHONY: clean

mixpoc: mixpoc.c
	cc -lm mixpoc.c -o mixpoc -Wall

clean:
	rm -f mixpoc
