#include <stdio.h>
#include <cuda_runtime.h>

#define N 100

__global__ void square(int *a) {
    int i = threadIdx.x;
    if (i < N)
        a[i] = i * i;
}

int main() {
    int *a;

    cudaMallocManaged(&a, N * sizeof(int));

    square<<<1, N>>>(a);
    cudaDeviceSynchronize();

    for (int i = 0; i < N; i++)
        printf("%d\n", a[i]);

    cudaFree(a);
    return 0;
}
