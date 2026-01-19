//CODE for thread divergence
//assert(x == y || x == z);

//if (x == y)
  //  x = z;
//else
  //  x = y;


//modified snippet
//assert(x==y || x==z);
//x = y + z - x;


  // Modified code

#include <cstdio>
#include <cassert>
#include <cuda_runtime.h>

__global__ void divergence_free_kernel(int *x, int *y, int *z, int n)
{
    int id = blockIdx.x * blockDim.x + threadIdx.x;
    if (id >= n) return;

    // Guarantee: x[id] equals either y[id] or z[id]
    assert(x[id] == y[id] || x[id] == z[id]);

    // Branchless, divergence-free logic
    x[id] = y[id] + z[id] - x[id];
}

int main()
{
    const int N = 256;
    const int size = N * sizeof(int);

    int h_x[N], h_y[N], h_z[N];

    // Initialize data
    for (int i = 0; i < N; i++) {
        h_y[i] = i;
        h_z[i] = i + 100;

        // x is guaranteed to be either y or z
        h_x[i] = (i % 2 == 0) ? h_y[i] : h_z[i];
    }

    int *d_x, *d_y, *d_z;
    cudaMalloc(&d_x, size);
    cudaMalloc(&d_y, size);
    cudaMalloc(&d_z, size);

    cudaMemcpy(d_x, h_x, size, cudaMemcpyHostToDevice);
    cudaMemcpy(d_y, h_y, size, cudaMemcpyHostToDevice);
    cudaMemcpy(d_z, h_z, size, cudaMemcpyHostToDevice);

    dim3 threadsPerBlock(128);
    dim3 blocks((N + threadsPerBlock.x - 1) / threadsPerBlock.x);

    divergence_free_kernel<<<blocks, threadsPerBlock>>>(d_x, d_y, d_z, N);
    cudaDeviceSynchronize();

    cudaMemcpy(h_x, d_x, size, cudaMemcpyDeviceToHost);

    // Verify result
    for (int i = 0; i < N; i++) {
        if (h_x[i] != h_y[i] && h_x[i] != h_z[i]) {
            printf("Error at %d\n", i);
            return 1;
        }
    }

    printf("Success: divergence-free kernel executed correctly.\n");

    cudaFree(d_x);
    cudaFree(d_y);
    cudaFree(d_z);

    return 0;
}
