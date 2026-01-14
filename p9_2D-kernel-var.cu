//initializing matrix to unique ids

#include<stdio.h>
#include <cuda.h>
#include <cuda_runtime.h>

#define N 5
#define M 6

__global__ void twod(unsigned *matrix) {
    unsigned id = blockIdx.x * blockDim.x + threadIdx.x;
    matrix[id] = id;
}

int main() {
    
    //dim3 block (N , M , 1);  //blockDim.x = 5, .y = 6 , .z = 1..... Threads per block = 5*6*1 = 30
    unsigned *matrix, *hmatrix;   //hmatrix is the address of the matrix declred on the CPU

    cudaMalloc(&matrix, N * M * sizeof(unsigned));  //size is 5*6*1 *sizeof.........  matrix poinmting to device mem
    hmatrix = (unsigned *)malloc(N * M * sizeof(unsigned));  //received data copied back from the GPU, allocate matching space on teh CPU

    twod<<<N,M>>>(matrix);

    cudaMemcpy(hmatrix, matrix, N * M * sizeof(unsigned), cudaMemcpyDeviceToHost);  //copy back to CPU

    //Printing the matrix
    for (unsigned ii = 0; ii < N; ++ii){
        for (unsigned jj = 0; jj < M; ++jj){
            printf("%2d",hmatrix[ii * M + jj]);
        }
    }
    return 0;
}