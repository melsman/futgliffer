MLCOMP=mlkit

SMLFILES=json.sml json.sig futgliffer.sml
MLBFILES=json.mlb futgliffer.mlb

futgliffer: $(SMLFILES) $(MLBFILES)
	$(MLCOMP) -o $@ futgliffer.mlb

.PHONY: clean
clean:
	rm -rf futgliffer MLB */MLB */*/MLB *~ */*~ */*/*~
