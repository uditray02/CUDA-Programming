#include <stdio.h>
#include <cuda_runtime.h>

#define TILE 16

__global__ void matmul_tiled(float *A, float *B, float *C, int N)
{
    __shared__ float As[TILE][TILE];
    __shared__ float Bs[TILE][TILE];

    int row = blockIdx.y * TILE + threadIdx.y;
    int col = blockIdx.x * TILE + threadIdx.x;

    float sum = 0.0f;

    for (int t = 0; t < (N + TILE - 1) / TILE; t++) {

        if (row < N && t*TILE + threadIdx.x < N)
            As[threadIdx.y][threadIdx.x] =
                A[row*N + t*TILE + threadIdx.x];
        else
            As[threadIdx.y][threadIdx.x] = 0.0f;

        if (col < N && t*TILE + threadIdx.y < N)
            Bs[threadIdx.y][threadIdx.x] =
                B[(t*TILE + threadIdx.y)*N + col];
        else
            Bs[threadIdx.y][threadIdx.x] = 0.0f;

        __syncthreads();

        for (int k = 0; k < TILE; k++)
            sum += As[threadIdx.y][k] * Bs[k][threadIdx.x];

        __syncthreads();
    }

    if (row < N && col < N)
        C[row*N + col] = sum;
}

int main()
{
    const int N = 1024;
    size_t bytes = N * N * sizeof(float);

    float *A, *B, *C;
    float *dA, *dB, *dC;

    A = (float*)malloc(bytes);
    B = (float*)malloc(bytes);
    C = (float*)malloc(bytes);

    for (int i = 0; i < N*N; i++) {
        A[i] = 1.0f;
        B[i] = 1.0f;
    }

    cudaMalloc(&dA, bytes);
    cudaMalloc(&dB, bytes);
    cudaMalloc(&dC, bytes);

    cudaMemcpy(dA, A, bytes, cudaMemcpyHostToDevice);
    cudaMemcpy(dB, B, bytes, cudaMemcpyHostToDevice);

    dim3 block(TILE, TILE);
    dim3 grid((N + TILE - 1) / TILE, (N + TILE - 1) / TILE);

    cudaEvent_t start, stop;
    cudaEventCreate(&start);
    cudaEventCreate(&stop);

    cudaEventRecord(start);
    matmul_tiled<<<grid, block>>>(dA, dB, dC, N);
    cudaEventRecord(stop);

    cudaEventSynchronize(stop);

    float ms;
    cudaEventElapsedTime(&ms, start, stop);
    printf("GPU tiled time: %.3f ms\n", ms);

    cudaMemcpy(C, dC, bytes, cudaMemcpyDeviceToHost);

    cudaFree(dA); cudaFree(dB); cudaFree(dC);
    free(A); free(B); free(C);
    return 0;
}
