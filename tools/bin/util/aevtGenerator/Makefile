
APP = aevt-generator.jar

run: build
	scala target/${APP}

build: src/main/scala/*.scala
	scalac src/main/scala/*.scala -d target/${APP}

link: build
	MYDIR=../libs
	[ -d $(MYDIR) ] || mkdir -p $(MYDIR)
	ln -sfn $(PWD)/target/${APP} $(PWD)/../libs/${APP}

clean:
	rm -r target/${APP}
