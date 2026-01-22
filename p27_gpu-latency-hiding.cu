// gpu_latency.cu
#include <stdio.h>

__global__ void latency(int *a, int *out) {
    int id = blockIdx.x * blockDim.x + threadIdx.x;
    out[id] = a[id];   // when one warp stalls, others run
}

int main() {
    int *a, *out;
    cudaMalloc(&a, 1024*1024*sizeof(int));
    cudaMalloc(&out, 1024*1024*sizeof(int));
    latency<<<4096,256>>>(a, out);
    cudaDeviceSynchronize();
}
