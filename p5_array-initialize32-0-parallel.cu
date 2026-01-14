// Program to initialize an array of size 32 to all zeros in parallel.........
// uses 32 GPU threads to set 32 array elements to zero at the same time, then prints the result on the CPU.


#include <stdio.h>
#include <cuda.h>
#include <cuda_runtime.h>

// #define N 32
#define N 1024   // 1024 works in one block because it is the maximum threads per block, but anything larger requires multiple blocks.

__global__ void init_zero(int *arr) {       //arr→ pointer to GPU memory
    int idx = threadIdx.x;   //   Each GPU thread has a unique ID, IDs here are: 0 to 31, 
    if (idx < N) {     // Ensures not writing outside the array
        arr[idx] = 0;  // Each thread sets one element to zero, Happens in parallel
    }
}

int main() {
    int h_arr[N];  //Array in CPU memory, Will receive results from GPU
    int *d_arr;  // Will point to GPU memory

    // Allocate device memory
    cudaMalloc(&d_arr, N * sizeof(int));  // Reserves space for 32 integers on the GPU

    // Launch kernel: 1 block, 32 threads
    init_zero<<<1, N>>>(d_arr);  // 1 Block , 32 Threads,Each thread initializes one element

    // Wait for GPU to finish
    cudaDeviceSynchronize();

    // Copy result back to host
    cudaMemcpy(h_arr, d_arr, N * sizeof(int), cudaMemcpyDeviceToHost);   // GPU to CPU

    // Verify result
    for (int i = 0; i < N; i++) {
        printf("%d ", h_arr[i]);
    }
    printf("\n");

    // Free device memory
    cudaFree(d_arr);

    return 0;
}
