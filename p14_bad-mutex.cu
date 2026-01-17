#include <stdio.h>
#include <cuda.h>
#include <cuda_runtime.h>

__device__ int lock = 0;   // global mutex

__global__ void mutex_kernel(int *out)
{
    int id = blockIdx.x * blockDim.x + threadIdx.x;

    // ---- MUTEX (SPINLOCK) ----
    while (atomicCAS(&lock, 0, 1) != 0) {
        // busy wait (spin)
    }

    // ---- CRITICAL SECTION ----
    *out += 1;

    // ---- UNLOCK ----
    atomicExch(&lock, 0);
}

int main()
{
    int *d_out;
    int h_out = 0;

    cudaMalloc(&d_out, sizeof(int));
    cudaMemcpy(d_out, &h_out, sizeof(int), cudaMemcpyHostToDevice);

    // Launch MANY threads
    mutex_kernel<<<1, 256>>>(d_out);

    cudaDeviceSynchronize();

    cudaMemcpy(&h_out, d_out, sizeof(int), cudaMemcpyDeviceToHost);

    printf("Result = %d\n", h_out);

    cudaFree(d_out);
    return 0;
}
