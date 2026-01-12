#include <stdio.h>
#include <cuda.h>
#include <cuda_runtime.h>
#define N 100

//C ++
__global__ void p1(){
    for (int i=0; i < N; ++i)       
    printf("%d\n", i*i);
}



// Threading with GPU
__global__ void p1(){
    printf("%d\n", threadIdx.x * threadIdx.x);
}


// Normal Execution with GPU
int main(){
    p1<<<1,1>>>();
    cudaDeviceSynchronize();
    return 0;
}


// Execution directly with N defined
int main(){
    p1<<<1,N>>>();
    cudaDeviceSynchronize();
    return 0;
}