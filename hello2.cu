#include <stdio.h>
#include <cuda.h>
#include <cuda_runtime.h>

__global__ void hello1() {
    printf("Hello from GPU(a)! Thread %d\n", threadIdx.x);
}

__global__ void hello2() {
    printf("Hello from GPU(b)! Thread %d\n", threadIdx.x);
}

int main() {
    hello1<<<1, 1>>>();
    hello2<<<1, 1>>>();

    printf("HI, I am the CPU before sync  \n");  //CPU    ---it can be printed in any order before or after the gpu execution..... max chances of this printing before because CPU is fast .. it will just launch and will not wait for the kernel to finish

    cudaDeviceSynchronize();   //synchronized the threads

    printf("HI, I am the CPU after sync  \n");  //CPU
    return 0;
}

