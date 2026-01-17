// file: matrix_square_timed.cu
#include <cuda_runtime.h>
#include <iostream>  // Used for printing results to the console.
#include <cassert>  //Used to verify correctness by comparing GPU output with CPU output.

constexpr unsigned N = 64;
constexpr unsigned MATRIX_SIZE = N * N;

__global__ void square(const unsigned* matrix,
                       unsigned* result,
                       unsigned matrixsize)
{
    unsigned id = blockIdx.x * blockDim.x + threadIdx.x;  //Each thread computes one matrix element.. Converts 1D grid into a unique thread ID

    if (id < matrixsize * matrixsize) {   //  Prevents threads from accessing out-of-range memory
        unsigned ii = id / matrixsize;
        unsigned jj = id % matrixsize;

        unsigned sum = 0;
        for (unsigned kk = 0; kk < matrixsize; ++kk) {
            sum += matrix[ii * matrixsize + kk] *
                   matrix[kk * matrixsize + jj];
        }   //Computes one dot product, This is naive O(N³) multiplication

        result[ii * matrixsize + jj] = sum;
    }
}

void cpu_reference(const unsigned* A, unsigned* C, unsigned n)   //Runs on CPU and used only to verify correctness
{
    for (unsigned i = 0; i < n; ++i) {
        for (unsigned j = 0; j < n; ++j) {
            unsigned sum = 0;
            for (unsigned k = 0; k < n; ++k) {
                sum += A[i * n + k] * A[k * n + j];
            }
            C[i * n + j] = sum;
        }
    }
}

int main()
{
    size_t bytes = MATRIX_SIZE * sizeof(unsigned);

    unsigned* h_A = new unsigned[MATRIX_SIZE];   // h_A → input matri x
    unsigned* h_C = new unsigned[MATRIX_SIZE];   // h_C → GPU result
    unsigned* h_C_ref = new unsigned[MATRIX_SIZE]; // h_C_ref → CPU result

    for (unsigned i = 0; i < MATRIX_SIZE; ++i) {
        h_A[i] = i % 5;
    }

    unsigned *d_A, *d_C;
    cudaMalloc(&d_A, bytes);
    cudaMalloc(&d_C, bytes);
    cudaMemcpy(d_A, h_A, bytes, cudaMemcpyHostToDevice);

    unsigned threads = N;
    unsigned blocks = (MATRIX_SIZE + threads - 1) / threads;

    // Timing events ...Create events Record start → launch kernel → record stop
    cudaEvent_t start, stop;
    cudaEventCreate(&start);
    cudaEventCreate(&stop);

    // /Create events Record start → launch kernel → record stop
    cudaEventRecord(start);
    square<<<blocks, threads>>>(d_A, d_C, N);
    cudaEventRecord(stop);

    //Wait and compute time
    cudaEventSynchronize(stop);

    float elapsed_ms = 0.0f;
    cudaEventElapsedTime(&elapsed_ms, start, stop);

    cudaMemcpy(h_C, d_C, bytes, cudaMemcpyDeviceToHost);  //Copy result back to CPU

    //If any value is wrong → program aborts
    cpu_reference(h_A, h_C_ref, N);
    for (unsigned i = 0; i < MATRIX_SIZE; ++i) {
        assert(h_C[i] == h_C_ref[i]);
    }

    std::cout << "Matrix square successful.\n";
    std::cout << "Kernel execution time: " << elapsed_ms << " ms\n";

    //cleann
    cudaEventDestroy(start);
    cudaEventDestroy(stop);
    cudaFree(d_A);
    cudaFree(d_C);
    delete[] h_A;
    delete[] h_C;
    delete[] h_C_ref;

    return 0;
}

//Kernel execution time: 0.012288 ms
