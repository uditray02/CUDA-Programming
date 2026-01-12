#include <stdio.h>
#include <cuda.h>
#include <cuda_runtime.h>

__global__ void hello() {
    printf("Hello from GPU! Thread %d\n", threadIdx.x);
}

int main() {
    hello<<<1, 1>>>();
    printf("HI, I am the CPU(a) before sync  \n");  //CPU    ---it can be printed in any order before or after the gpu execution..... max chances of this printing before because CPU is fast .. it will just launch and will not wait for the kernel to finish
    hello<<<1, 1>>>();
    printf("HI, I am the CPU(b) before sync  \n");
    hello<<<1, 1>>>();
    printf("HI, I am the CPU(c) before sync  \n");


    cudaDeviceSynchronize();   //synchronized the threads

    printf("HI, I am the CPU after sync  \n");  //CPU
    return 0;
}

