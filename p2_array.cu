// CUDA program computes squares of numbers from 0 to 99 using the GPU, then prints them on the CPU.

//1 . CPU allocates GPU memory

// 2. CPU launches GPU kernel

// 3. GPU computes squares in parallel

// 4. CPU copies results back

//5. CPU prints results

#include <stdio.h>
#include <cuda_runtime.h>  //Includes CUDA runtime API declarations: cudaMalloc cudaMemcpy cudaFree

#define N 100      //Defines a compile-time constant. Number of elements, Number of GPU threads , Valid indices: 0 → 99

__global__ void fun(int *a) {               // a is a pointer to device (GPU) memory 
    int idx = threadIdx.x;                 // Gets the thread ID within the block.  Thread 0 → idx = 0 , Thread 1 → idx = 1
    if (idx < N) {                         // Prevents out-of-bounds memory access 
        a[idx] = idx * idx;                // Each thread computes the square of its index, Stores result in GPU memory and Thread k writes to a[k]
    }
}

int main() {                              
    int a[N];                             // Will store results copied from GPU  // Declares an array in host (CPU) memory.
    int *da;                              // Declares a pointer. Will point to device (GPU) memory . CPU cannot directly dereference it

    // Allocate device memory
    cudaMalloc((void**)&da, N * sizeof(int));   //allocates memory on the GPU. size = N integers && da stores the GPU memory address.    da=GPU mem and a=CPU mem

    // Launch kernel.. Kernel launch is asynchronous.
    fun<<<1, N>>>(da);

    // Copy data back to host (from device (GPU) memory da to host (CPU) array a)
    cudaMemcpy(a, da, N * sizeof(int), cudaMemcpyDeviceToHost);   // This call synchronizes the GPU implicitly.

    // Print result
    for (int i = 0; i < N; ++i)
        printf("%d\n", a[i]);

    // Free device memory
    cudaFree(da);

    return 0;
}
