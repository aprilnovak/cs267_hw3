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
        
        upc_barrier;
        // creates a shared to shared pointer to the hashtable
        shared hash_table_t *hashtable;
        hashtable = (shared hash_table_t*) upc_all_alloc(THREADS, sizeof(hash_table_t));
        hashtable->table = (shared bucket_t*) upc_all_alloc(THREADS, n_buckets * sizeof(bucket_t));
        shared hash_table_t *my_hashtable;
        my_hashtable = hashtable; // have to do this to get each thread to have the same address for the pointer to the hash table?

        if (MYTHREAD == 0)
        {
            hashtable->size = n_buckets;
        
            if (hashtable->table == NULL)
            {
               fprintf(stderr, "ERROR: Could not allocate memory for the hash table: \
                        %lld buckets of %lu bytes\n", n_buckets, sizeof(bucket_t));
               exit(1);
            }
  
        }


        // creates a private to shared pointer to the memory heap
        shared memory_heap_t *memory_heap;
        memory_heap->heap = (shared kmer_t *) upc_all_alloc(THREADS, nKmers * sizeof(kmer_t));
        shared memory_heap_t *my_memory_heap;
        my_memory_heap = memory_heap;


        if (MYTHREAD == 0)
        {
            if (memory_heap->heap == NULL)
            {
               fprintf(stderr, "ERROR: Could not allocate memory for the heap!\n");
               exit(1);
            }
            memory_heap->posInHeap = 0;
        }

        if (MYTHREAD == 0)
        {
            printf("........................");
        }   
        printf("\n\nAddress of hashtable->table pointer: %p, size: %d,  thread %d, %d\n\n", (void *)my_hashtable->table, my_hashtable->size, MYTHREAD, upc_threadof(hashtable->table));
        printf("Address of memory_heap->heap pointer: %p, position: %d,   thread %d\n", (void*)memory_heap->heap, memory_heap->posInHeap, MYTHREAD);
   

 
        /* Read the kmers from the input file and store them in the working_buffer */
       int64_t total_chars_to_read = nKmers * LINE_SIZE;
       shared unsigned char *working_buffer = (shared unsigned char*) upc_all_alloc(THREADS, total_chars_to_read * sizeof(unsigned char));
       shared unsigned char* my_working_buffer;
        my_working_buffer = working_buffer;

        if (MYTHREAD == 0)
        {
            FILE* inputFile = fopen(input_UFX_name, "r");
            int64_t cur_chars_read = fread((unsigned char*) my_working_buffer, sizeof(unsigned char),total_chars_to_read , inputFile);
            fclose(inputFile);
            printf("Working buffer entry 1: %c\n\n", *(my_working_buffer+0));
        }
 
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
