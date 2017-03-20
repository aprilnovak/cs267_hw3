#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <sys/time.h>
#include <math.h>
#include <time.h>
#include <upc.h>

#include "packingDNAseq_upc.h"
#include "kmer_hash_upc.h"

int main(int argc, char *argv[]){

	/** Declarations **/
	double inputTime=0.0, constrTime=0.0, traversalTime=0.0;
        char *input_UFX_name;
        int64_t nKmers;
          
        /* Read the input file name */
        input_UFX_name = argv[1];
 
	/** Read input **/
	upc_barrier;
	///////////////////////////////////////////
	// Your code for input file reading here //
        
        // initialize the lookup table
        init_LookupTable(MYTHREAD, THREADS);
	

        // get k-mers from input file
        nKmers = getNumKmersInUFX(input_UFX_name);
        upc_barrier;

        inputTime -= gettime();
        
        // initialize the hash table and memory heap
        memory_heap_t memory_heap;
        allocate_memory_heap(nKmers, &memory_heap); 

       hash_table_t *hashtable;
       int64_t n_buckets = nKmers * LOAD_FACTOR;

       hashtable = (hash_table_t*) malloc(sizeof(hash_table_t));
       hashtable->size = n_buckets;
       hashtable->table = (bucket_t*) calloc(n_buckets , sizeof(bucket_t));

       if (hashtable->table == NULL)
       {
          fprintf(stderr, "ERROR: Could not allocate memory for the hash table: %lld buckets of %lu bytes\n", n_buckets, sizeof(bucket_t));
          exit(1);
       }






        
        inputTime += gettime();
        if (MYTHREAD == 0)
        printf("Hash table initialization: %f\n\n", inputTime);
        ///////////////////////////////////////////
	upc_barrier;

	/** Graph construction **/
	constrTime -= gettime();
	///////////////////////////////////////////
	// Your code for graph construction here //
	///////////////////////////////////////////
	upc_barrier;
	constrTime += gettime();

	/** Graph traversal **/
	traversalTime -= gettime();
	////////////////////////////////////////////////////////////
	// Your code for graph traversal and output printing here //
	// Save your output to "pgen.out"                         //
	////////////////////////////////////////////////////////////
	upc_barrier;
	traversalTime += gettime();

	/** Print timing and output info **/
	/***** DO NOT CHANGE THIS PART ****/
	if(MYTHREAD==0){
		printf("%s: Input set: %s\n", argv[0], argv[1]);
		printf("Number of UPC threads: %d\n", THREADS);
		printf("Input reading time: %f seconds\n", inputTime);
		printf("Graph construction time: %f seconds\n", constrTime);
		printf("Graph traversal time: %f seconds\n", traversalTime);
	}
	return 0;
}
