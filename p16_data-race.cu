#include <stdio.h>
#include <cuda.h>
#include <cuda_runtime.h>

__global__ void data_race_kernel(int *out)
{
    // MANY threads write to the SAME location
    out[0] += 1;   //  DATA RACE
}

int main()
{
    int *d_out;
    int h_out = 0;

    cudaMalloc(&d_out, sizeof(int));
    cudaMemcpy(d_out, &h_out, sizeof(int), cudaMemcpyHostToDevice);

    //  MANY THREADS
    data_race_kernel<<<1, 256>>>(d_out);
    cudaDeviceSynchronize();

    cudaMemcpy(&h_out, d_out, sizeof(int), cudaMemcpyDeviceToHost);

    printf("Final result = %d (expected 256)\n", h_out);

    cudaFree(d_out);
    return 0;
}
