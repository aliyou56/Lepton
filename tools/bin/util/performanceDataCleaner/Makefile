
APP = performanceDataCleaner.jar
dir=/home/aliyou/Desktop/S2/projet_tutore/platform/lepton/scenario/adhocnet/performance

run: build
	scala target/${APP} ${dir}//performance.txt

build: src/main/scala/*.scala
	scalac src/main/scala/*.scala -d target/${APP}

#  Populate the libs/ directory with symbolic links to the performanceDataCleaner
link: build
	dir=../libs
	[ -d $(dir) ] || mkdir -p $(dir)
	ln -sfn $(PWD)/target/${APP} $(PWD)/../libs/${APP}

clean:
	rm -r target/${APP}
