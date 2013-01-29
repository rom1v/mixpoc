.PHONY: clean

mixpoc: mixpoc.c
	cc mixpoc.c -o mixpoc -Wall

clean:
	rm -f mixpoc
