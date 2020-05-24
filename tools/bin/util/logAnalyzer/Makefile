
APP = logAnalyzer.jar

build: src/main/scala/*.scala
	scalac src/main/scala/*.scala -d target/${APP}

#  Populate the libs/ directory with symbolic links to the adtnLogAnalyzer
link: build
	dir=../libs
	[ -d $(dir) ] || mkdir -p $(dir)
	ln -sfn $(PWD)/target/${APP} $(PWD)/../libs/${APP}

clean:
	rm -r target/${APP}
