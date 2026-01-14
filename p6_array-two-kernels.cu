#include <stdio.h>
#include <cuda_runtime.h>

#define N 8000

// Kernel 1: initialize array to zero
__global__ void init_zero(int *arr, int n) {
    int i = blockIdx.x * blockDim.x + threadIdx.x;
    if (i < n) {
        arr[i] = 0;
    }
}

// Kernel 2: add index to each element
__global__ void add_index(int *arr, int n) {
    int i = blockIdx.x * blockDim.x + threadIdx.x;
    if (i < n) {
        arr[i] += i;
    }
}

int main() {
    int *d_arr;
    int h_arr[N];

    cudaMalloc(&d_arr, N * sizeof(int));

    int threadsPerBlock = 256;
    int blocksPerGrid   = (N + threadsPerBlock - 1) / threadsPerBlock;

    // Launch kernels
    init_zero<<<blocksPerGrid, threadsPerBlock>>>(d_arr, N);
    add_index<<<blocksPerGrid, threadsPerBlock>>>(d_arr, N);

    cudaDeviceSynchronize();

    cudaMemcpy(h_arr, d_arr, N * sizeof(int), cudaMemcpyDeviceToHost);

    // Verify first 10 values
    for (int i = 0; i < N; i++) {
        printf("%d ", h_arr[i]);
    }
    printf("\n");


    cudaFree(d_arr);
    return 0;
}
