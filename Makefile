.PHONY: all clean

all:
	bash build_all.sh

fast:
	bash build_all.sh fast

clean:
	rm -Rf build
