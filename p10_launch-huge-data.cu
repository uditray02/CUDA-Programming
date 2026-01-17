#include <stdio.h>
#include <cuda.h>
#include <cuda_runtime.h>
#include <stdlib.h>   // needed for atoi, malloc


__global__ void large(unsigned *vector, unsigned vectorsize) {
    unsigned id = blockIdx.x * blockDim.x + threadIdx.x;
    if (id < vectorsize)
        vector[id] = id;   //what this will do is full a large array with this. 
}



#define BLOCKSIZE 1024   //maximum threads allowed on most GPUs in one block
int main(int nn, char *str[]) {   // This allows command-line input.
    unsigned N = atoi(str[1]);    //atoi = ASCII to integer ... Convert input string to number
    unsigned *vector, *hvector;   //hvector to allocate memory in CPU as it is the host and *vector for memory allocation by the pointer in GPU
    cudaMalloc(&vector, N * sizeof(unsigned));  //Allocate GPU memory
    hvector = (unsigned *)malloc(N * sizeof(unsigned));  //Allocate CPU memory

    //unsigned nblocks = ceil((float)N/BLOCKSIZE);
    
    unsigned nblocks = (N + BLOCKSIZE - 1)/ BLOCKSIZE;
    //printf("nblocks = %d\n ", nblocks);   //Print number of blocks
    printf("nblocks = %u\n", nblocks);


    large<<<nblocks, BLOCKSIZE>>>(vector, N);    //total threads = nblocks × BLOCKSIZE ≥ N
    cudaMemcpy(hvector, vector, N * sizeof(unsigned), cudaMemcpyDeviceToHost);   //Copy data back to CPU
    for (unsigned ii=0; ii < N; ++ii){
        printf("%4d", hvector[ii]);
    }
    return 0;
    cudaFree(vector);
    free(hvector);

}