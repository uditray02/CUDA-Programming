//initializing matrix to unique ids

#include<stdio.h>
#include <cuda.h>
#include <cuda_runtime.h>

#define N 5
#define M 6

/*__global__ void twod(unsigned *matrix) {   //memory allocation by the pointer on the gpu = *matrix

    // Row index from x-dimension of the block
    unsigned row = threadIdx.x;

    // Column index from y-dimension of the block
    unsigned col = threadIdx.y;

    // Convert 2D (row, col) into 1D linear index
    unsigned idx = row * M + col;

    // Write a unique value per thread
    matrix[idx] = idx;

}
*/


// OR ANOTHER PROCESS

__global__ void twod(unsigned *matrix) {
    unsigned id = threadIdx.x * blockDim.y + threadIdx.y;
    matrix[id] = id;
}

int main() {
    
    dim3 block (N , M , 1);  //blockDim.x = 5, .y = 6 , .z = 1..... Threads per block = 5*6*1 = 30
    unsigned *matrix, *hmatrix;   //hmatrix is the address of the matrix declred on the CPU

    cudaMalloc(&matrix, N * M * sizeof(unsigned));  //size is 5*6*1 *sizeof.........  matrix poinmting to device mem
    hmatrix = (unsigned *)malloc(N * M * sizeof(unsigned));  //received data copied back from the GPU, allocate matching space on teh CPU

    twod<<<1,block>>>(matrix) ;  // 1 block, 6*5*1 threads

    cudaMemcpy(hmatrix, matrix, N * M * sizeof(unsigned), cudaMemcpyDeviceToHost);  //copy back to CPU

    //Printing the matrix
    for (unsigned ii = 0; ii < N; ++ii){
        for (unsigned jj = 0; jj < M; ++jj){
            printf("%2d",hmatrix[ii * M + jj]);
        }
    }
    return 0;
}