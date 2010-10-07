OUTPUT=MochiAd.swf
SOURCES=Test.as ../../mochi/as3/*.as Preloader.as

all: $(OUTPUT)

clean:
	rm -f $(OUTPUT)

MochiAd.swf: $(SOURCES)
	mxmlc \
		-default-frame-rate 31 \
		-default-size 550 400 \
		-use-network \
		-optimize=true \
		-output $@ \
		-frame=Test,Test \
		-compiler.external-library-path=../../ \
		Preloader.as

.PHONY: all clean
