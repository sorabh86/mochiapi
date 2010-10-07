OUTPUT=MochiAd.swf

all: $(OUTPUT)

clean:
	rm -f $(OUTPUT)

MochiAd.swf: Test.as ../../mochi/as2/*.as
	mtasc -infer -strict -version 7 -swf $@ -main -header 550:400:31 -cp ../.. Test.as
	LocalContentUpdater -a $@

.PHONY: all clean
