#include <stdio.h>
#include <cuda_runtime.h>
#include <cuda.h>


__global__ void hello() {
    printf("Hello from GPU! Thread %d\n", threadIdx.x);
}

int main() {
    hello<<<1, 1>>>();
    hello<<<1, 2>>>();
    hello<<<1, 3>>>();
    cudaDeviceSynchronize();   //synchronized the threads

    printf("HI \n");  //CPU
    return 0;
}

