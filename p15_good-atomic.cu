#include <stdio.h>
#include <cuda.h>
#include <cuda_runtime.h>

__global__ void atomic_kernel(int *out)
{
    int id = blockIdx.x * blockDim.x + threadIdx.x;

    // Atomic update (safe, no waiting)
    atomicAdd(out, 1);
}

int main()
{
    int *d_out;
    int h_out = 0;

    cudaMalloc(&d_out, sizeof(int));
    cudaMemcpy(d_out, &h_out, sizeof(int), cudaMemcpyHostToDevice);

    atomic_kernel<<<1, 256>>>(d_out);

    cudaDeviceSynchronize();

    cudaMemcpy(&h_out, d_out, sizeof(int), cudaMemcpyDeviceToHost);

    printf("Result = %d\n", h_out);

    cudaFree(d_out);
    return 0;
}
