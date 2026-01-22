// gpu_good_locality.cu
#include <stdio.h>

__global__ void good(int *a, int *out) {
    __shared__ int tile[1024];
    int id = threadIdx.x;

    tile[id] = a[id];
    __syncthreads();

    int sum = 0;
    for (int i = 0; i < 1024; i++)
        sum += tile[i];   // fast shared memory

    out[id] = sum;
}

int main() {
    int *a, *out;
    cudaMalloc(&a, 1024 * sizeof(int));
    cudaMalloc(&out, 256 * sizeof(int));
    good<<<1,256>>>(a, out);
    cudaDeviceSynchronize();
}


//via shared memory