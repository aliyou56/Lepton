
APP = adntLogAnalyzer.jar
out_dir=/home/aliyou/Desktop/S2/projet_tutore/platform/output

run: build
	scala target/${APP} ${out_dir}/lepton/lepton.out ${out_dir}/adtn

build: src/main/scala/*.scala
	scalac src/main/scala/*.scala -d target/${APP}

#  Populate the libs/ directory with symbolic links to the adtnLogAnalyzer
link: build
	dir=../libs
	[ -d $(dir) ] || mkdir -p $(dir)
	ln -sfn $(PWD)/target/${APP} $(PWD)/../libs/${APP}

clean:
	rm -r target/${APP}
