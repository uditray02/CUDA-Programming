#include <stdio.h>
#include <cuda.h>
#include <cuda_runtime.h>

__global__ void parallel(){
    printf("Parallel Hello World.\n");
}

int main() {
    parallel<<<1, 32>>>();
    cudaDeviceSynchronize();
    return 0;
}