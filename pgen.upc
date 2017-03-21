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
         
 
        /* Read the input file name */
        char *input_UFX_name = argv[1];

 
	upc_barrier;
	///////////////////////////////////////////
	// Your code for input file reading here //
        
        // initialize the lookup table
        init_LookupTable(MYTHREAD, THREADS);
	

        // get k-mers from input file
        int64_t nKmers = getNumKmersInUFX(input_UFX_name);
        upc_barrier;


        inputTime -= gettime();
       
 
        // initialize the hash table and memory heap
        int64_t n_buckets = nKmers * LOAD_FACTOR;
        memory_heap_t memory_heap;
        allocate_memory_heap(nKmers, &memory_heap); 


        // creates a shared to shared pointer to the hashtable
        shared hash_table_t *hashtable;
        hashtable = (shared hash_table_t*) upc_all_alloc(THREADS, sizeof(hash_table_t));

        hashtable->table = (shared bucket_t*) upc_all_alloc(THREADS, n_buckets * sizeof(bucket_t));

        upc_barrier;
/*        if (MYTHREAD == 0)
        {
            hashtable->size = n_buckets;
            hashtable->table = (shared bucket_t*) upc_global_alloc(1, n_buckets * sizeof(bucket_t));
        
            if (hashtable->table == NULL)
            {
               fprintf(stderr, "ERROR: Could not allocate memory for the hash table: %lld buckets of %lu bytes\n", n_buckets, sizeof(bucket_t));
               exit(1);
            }
  
        }
*/

        if (MYTHREAD == 0)
        {
            printf("........................");
        }   
        printf("\n\nAddress of __table__ pointer: %p,  thread %d\n\n", (void *)hashtable->table, MYTHREAD);



        
        inputTime += gettime();
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
