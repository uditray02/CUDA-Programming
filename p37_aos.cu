// aos.cu
#include <stdio.h>
#include <cuda_runtime.h>

#define N 1024

// Array of Structures
struct Particle {
    float x;
    float y;
    float z;
};

__global__ void aos_kernel(Particle *p, float *out)
{
    int tid = blockIdx.x * blockDim.x + threadIdx.x;
    if (tid < N) {
        // STRIDED ACCESS
        out[tid] = p[tid].x + p[tid].y + p[tid].z;
    }
}

int main()
{
    Particle *h_p, *d_p;
    float *h_out, *d_out;

    h_p = (Particle*)malloc(N * sizeof(Particle));
    h_out = (float*)malloc(N * sizeof(float));

    for (int i = 0; i < N; i++) {
        h_p[i].x = 1.0f;
        h_p[i].y = 2.0f;
        h_p[i].z = 3.0f;
    }

    cudaMalloc(&d_p, N * sizeof(Particle));
    cudaMalloc(&d_out, N * sizeof(float));

    cudaEvent_t start, stop;
    cudaEventCreate(&start);
    cudaEventCreate(&stop);
    cudaEventRecord(start);

    cudaMemcpy(d_p, h_p, N * sizeof(Particle), cudaMemcpyHostToDevice);

    aos_kernel<<<(N+255)/256, 256>>>(d_p, d_out);

    cudaEventRecord(stop);
    cudaEventSynchronize(stop);
    float milliseconds = 0.0f;
    cudaEventElapsedTime(&milliseconds, start, stop);

    cudaMemcpy(h_out, d_out, N * sizeof(float), cudaMemcpyDeviceToHost);

    printf("AoS output[0] = %f\n", h_out[0]);
    printf("AoS kernel time: %f ms\n", milliseconds);
    cudaFree(d_p);
    cudaFree(d_out);
    free(h_p);
    free(h_out);

    return 0;
}
