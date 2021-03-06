
FONT_NAME=OpenBaskerville
FONT=OpenBaskerville.ufo
#FONT=SourceCodePro-Regular.ufo
#FONT=RobotoSubset-Regular.ufo

## When choosing other fonts than OpenBaskerville, you may need to change
## the GLYPHS definition below

GLYPHS_CAP=A B C D E F G H I J K L M N O P Q R S T U V X Y Z
GLYPHS_CAP_US =$(GLYPHS_CAP:%=%_)
GLYPHS_NOCAP=a b c d e f g h i j k l m n o p q r s t u v w x y z space \
    one two three four five six seven eight nine zero
GLYPHS=$(GLYPHS_CAP_US) $(GLYPHS_NOCAP)

GLIFS=$(GLYPHS:%=$(FONT)/glyphs/%.glif)
GLIF_FUTS=$(GLIFS:%.glif=%.glif.fut)

GLYPH_BINDINGS=$(GLYPHS_CAP:%=glyph_%) $(GLYPHS_NOCAP:%=glyph_%)

GLYPH_CURVES=$(GLYPH_BINDINGS:%=%.curves)
GLYPH_LINES=$(GLYPH_BINDINGS:%=%.lines)

.PHONY: all
all: font.fut

%.json: %.glif
	cat $< | xml-to-json-fast > $@

%.glif.fut: %.json
	../src/futgliffer $< > $@

font.fut: $(GLIF_FUTS)
	echo "-- Don't modify this file - it is generated by futgliffer!!" > $@
	echo "-- See http://github.com/melsman/futgliffer" >> $@
	echo "--" >> $@
	echo "-- Font definition for: $(FONT)" >> $@
	echo "--" >> $@
	echo "" >> $@
	cat prefont.fut >> $@
	echo >> $@
	echo "module $(FONT_NAME) : font = {" >> $@
	echo >> $@
	cat internalfont.fut >> $@
	echo >> $@
	cat $(GLIF_FUTS) >> $@
	echo >> $@
	echo "let curves0 : []cbezier = $(GLYPH_BINDINGS:%=%.curves ++) []" >> $@
	echo >> $@
	echo "let C : i32 = length curves0" >> $@
	echo >> $@
	echo "let curves = (curves0 :> [C]cbezier)" >> $@
	echo >> $@
	echo "let lines0 : []line = $(GLYPH_BINDINGS:%=%.lines ++) []" >> $@
	echo >> $@
	echo "let L : i32 = length lines0" >> $@
	echo >> $@
	echo "let lines = (lines0 :> [L]line) " >> $@
	echo >> $@
	echo "let font_advances0 : []i32 = [$(GLYPH_BINDINGS:%=%.advance,)0]" >> $@
	echo >> $@
	echo "let N : i32 = length font_advances0 - 1" >> $@
	echo >> $@
	echo "let font_advances : [N]i32 = ([$(GLYPH_BINDINGS:%=%.advance,)0])[:N]" >> $@
	echo >> $@
	echo "let font_ncurves : [N]i32 = ([$(GLYPH_BINDINGS:%=length %.curves,)0])[:N]" >> $@
	echo >> $@
	echo "let font_nlines : [N]i32 = ([$(GLYPH_BINDINGS:%=length %.lines,)0])[:N]" >> $@
	echo >> $@
	echo "let font_chars : [N]u8 = ([$(GLYPH_BINDINGS:%=%.char,)0])[:N]" >> $@
	echo >> $@
	cat postfont.fut >> $@

.PHONY: clean
clean:
	rm -rf *~ */glyphs/*.json */glyphs/*.glif.fut font.fut
