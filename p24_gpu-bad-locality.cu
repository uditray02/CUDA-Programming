// gpu_bad_locality.cu
#include <stdio.h>

__global__ void bad(int *a, int *out) {
    int id = threadIdx.x;
    int sum = 0;
    for (int i = 0; i < 1024; i++)
        sum += a[i];   // global memory repeatedly
    out[id] = sum;
}

int main() {
    int *a, *out;
    cudaMalloc(&a, 1024 * sizeof(int));
    cudaMalloc(&out, 256 * sizeof(int));
    bad<<<1,256>>>(a, out);
    cudaDeviceSynchronize();
}
