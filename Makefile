CC = CC
UPCC = upcc

KMER_LENGTH 		= 19
KMER_PACKED_LENGTH 	= $(shell echo $$((($(KMER_LENGTH)+3)/4)))

# Add -std=gnu99 to CFLAGS if use gnu compiler
CFLAGS 	= -O3 
CFLAGSUPC = -O3 -std=gnu99
DEFINE 	= -DKMER_LENGTH=$(KMER_LENGTH) -DKMER_PACKED_LENGTH=$(KMER_PACKED_LENGTH)
HEADERS	= contig_generation.h kmer_hash.h packingDNAseq.h
LIBS	=

TARGETS	= serial pgen

all: 	$(TARGETS)

serial: serial.c $(HEADERS)
		$(CC) $(CFLAGS) -o $@ $< -DKMER_LENGTH=$(KMER_LENGTH) -DKMER_PACKED_LENGTH=$(KMER_PACKED_LENGTH) $(LIBS)

pgen:	pgen.upc $(HEADERS) packingDNAseq_upc.h kmer_hash_upc.h contig_generation_upc.h
		$(UPCC) $(UPCFLAGS) -Wc,"$(CFLAGSUPC)" -o $@ $< $(DEFINE) $(LIBS)

clean :
	rm -f *.o
	rm -rf $(TARGETS)
