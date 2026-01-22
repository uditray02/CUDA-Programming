// soa.cu
#include <stdio.h>
#include <cuda_runtime.h>

#define N 1024

// Structure of Arrays
struct Particles {
    float *x;
    float *y;
    float *z;
};

__global__ void soa_kernel(float *x, float *y, float *z, float *out)
{
    int tid = blockIdx.x * blockDim.x + threadIdx.x;
    if (tid < N) {
        // COALESCED ACCESS
        out[tid] = x[tid] + y[tid] + z[tid];
    }
}

int main()
{
    float *hx, *hy, *hz, *hout;
    float *dx, *dy, *dz, *dout;

    hx = (float*)malloc(N * sizeof(float));
    hy = (float*)malloc(N * sizeof(float));
    hz = (float*)malloc(N * sizeof(float));
    hout = (float*)malloc(N * sizeof(float));

    for (int i = 0; i < N; i++) {
        hx[i] = 1.0f;
        hy[i] = 2.0f;
        hz[i] = 3.0f;
    }

    cudaMalloc(&dx, N * sizeof(float));
    cudaMalloc(&dy, N * sizeof(float));
    cudaMalloc(&dz, N * sizeof(float));
    cudaMalloc(&dout, N * sizeof(float));

    cudaMemcpy(dx, hx, N * sizeof(float), cudaMemcpyHostToDevice);
    cudaMemcpy(dy, hy, N * sizeof(float), cudaMemcpyHostToDevice);
    cudaMemcpy(dz, hz, N * sizeof(float), cudaMemcpyHostToDevice);

    cudaEvent_t start, stop;
    cudaEventCreate(&start);
    cudaEventCreate(&stop);
    cudaEventRecord(start);


    soa_kernel<<<(N+255)/256, 256>>>(dx, dy, dz, dout);

    cudaEventRecord(stop);
    cudaEventSynchronize(stop);
    float milliseconds = 0.0f;
    cudaEventElapsedTime(&milliseconds, start, stop);
    

    cudaMemcpy(hout, dout, N * sizeof(float), cudaMemcpyDeviceToHost);

    printf("SoA output[0] = %f\n", hout[0]);
    printf("SoA kernel time: %f ms\n", milliseconds);

    cudaFree(dx);
    cudaFree(dy);
    cudaFree(dz);
    cudaFree(dout);

    free(hx);
    free(hy);
    free(hz);
    free(hout);

    return 0;
}
