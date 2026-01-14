#include <stdio.h>          
#include <cuda.h>               
#include <cuda_runtime.h>       

// CUDA kernel: runs on GPU, executed by many threads in parallel
__global__ void access() {

    // We restrict printing to exactly ONE thread:
    // - thread (0,0,0) inside
    // - block  (0,0,0)
    // This avoids multiple threads printing the same output
    if (threadIdx.x == 0 && blockIdx.x == 0 &&
        threadIdx.y == 0 && blockIdx.y == 0 &&
        threadIdx.z == 0 && blockIdx.z == 0 ) {

        // gridDim  = number of blocks in the grid (x, y, z)
        // blockDim = number of threads per block (x, y, z)
        // These are built-in CUDA variables, available inside every kernel
        printf("%d %d %d %d %d %d.\n",
               gridDim.x,   // blocks in X direction    Grids
               gridDim.y,   // blocks in Y direction
               gridDim.z,   // blocks in Z direction
               blockDim.x,  // threads per block in X   Threadblocks
               blockDim.y,  // threads per block in Y
               blockDim.z); // threads per block in Z
    }
}

int main() {

    // Define grid dimensions:
    // grid.x = 2 blocks
    // grid.y = 3 blocks
    // grid.z = 4 blocks
    dim3 grid(2, 3, 4);

    // Define block dimensions:
    // block.x = 5 threads
    // block.y = 6 threads
    // block.z = 7 threads
    dim3 block(5, 6, 7);

    // Launch the kernel:
    // <<<grid, block>>> tells CUDA how many blocks and threads to create
    access<<<grid, block>>>();

    // Forces the CPU to wait until the GPU finishes executing the kernel
    // Required so printf output is flushed before program exits
    cudaDeviceSynchronize();

    // Exit program successfully
    return 0;
}
