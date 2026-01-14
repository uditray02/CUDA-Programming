#include <stdio.h>
#include <string.h>

#include <cuda.h>
#include <cuda_runtime.h>

__global__ void comp(char *arr, int arrlen){
    unsigned id = threadIdx.x;
    if (id< arrlen){
        ++arr[id];    //“Add 1 to every byte I touch.”
    }
}

int main() {
    char cpuarr[] = "Gdkkn\x1fVnqkc-",    //array made using cpu./.... stored in cpu mem
    *gpuarr;                              //gpu var for array made.. pointer points to the gpu mem

    cudaMalloc(&gpuarr, sizeof(char) * (1 + strlen(cpuarr)));   //memory allocation
    cudaMemcpy(gpuarr, cpuarr, sizeof(char) * (1 + strlen(cpuarr)), cudaMemcpyHostToDevice); //copy data from cpu - gpu
    comp<<<1,64>>>(gpuarr, strlen(cpuarr));  //kernel def  .... +1 is removed from kernel processing because it would modify the null terminator and corrupt the string.
    cudaDeviceSynchronize();
    cudaMemcpy(cpuarr, gpuarr, sizeof(char) * (1 + strlen(cpuarr)), cudaMemcpyDeviceToHost);
    printf("%s\n", cpuarr);
    cudaFree(gpuarr);

    return 0;

    //cudaFree(gpuarr);


    


}

// gpuarr → pointer that will point to GPU memory
// &gpuarr → address of the pointer (so CUDA can write the GPU address into it)
// strlen(cpuarr) → number of characters in the string excluding the null terminator '\0'