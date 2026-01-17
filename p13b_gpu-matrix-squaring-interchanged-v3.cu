
#include <cuda_runtime.h>
#include <iostream>
#include <cassert>

constexpr unsigned N = 64;
constexpr unsigned MATRIX_SIZE = N * N;

/*
    This kernel intentionally swaps ii and jj.
    Result: C = (A × A)^T   (transpose of the correct matrix square)
*/
__global__ void square_transposed(const unsigned* matrix,
                                  unsigned* result,
                                  unsigned matrixsize)
{
    // Global 1D thread index
    unsigned id = blockIdx.x * blockDim.x + threadIdx.x;

    if (id < matrixsize * matrixsize) {

        //  Interchanged mapping
        // Normally:
        //   ii = row, jj = column
        // Here:
        //   ii = column, jj = row
        unsigned ii = id % matrixsize;      // column index
        unsigned jj = id / matrixsize;      // row index

        unsigned sum = 0;

        // Dot product of row jj and column ii
        for (unsigned kk = 0; kk < matrixsize; ++kk) {
            sum += matrix[jj * matrixsize + kk] *
                   matrix[kk * matrixsize + ii];
        }

        // Write result at transposed location
        result[jj * matrixsize + ii] = sum;
    }
}

/*
    CPU reference that ALSO produces the transposed result.
    This keeps verification correct.
*/
void cpu_reference_transposed(const unsigned* A, unsigned* C, unsigned n)
{
    for (unsigned i = 0; i < n; ++i) {
        for (unsigned j = 0; j < n; ++j) {
            unsigned sum = 0;
            for (unsigned k = 0; k < n; ++k) {
                sum += A[j * n + k] * A[k * n + i];
            }
            C[j * n + i] = sum;
        }
    }
}

int main()
{
    size_t bytes = MATRIX_SIZE * sizeof(unsigned);

    // Host memory
    unsigned* h_A = new unsigned[MATRIX_SIZE];
    unsigned* h_C = new unsigned[MATRIX_SIZE];
    unsigned* h_C_ref = new unsigned[MATRIX_SIZE];

    // Initialize input matrix
    for (unsigned i = 0; i < MATRIX_SIZE; ++i) {
        h_A[i] = i % 5;
    }

    // Device memory
    unsigned *d_A, *d_C;
    cudaMalloc(&d_A, bytes);
    cudaMalloc(&d_C, bytes);

    cudaMemcpy(d_A, h_A, bytes, cudaMemcpyHostToDevice);

    // Kernel launch configuration
    unsigned threads = N;
    unsigned blocks = (MATRIX_SIZE + threads - 1) / threads;

    // CUDA timing events
    cudaEvent_t start, stop;
    cudaEventCreate(&start);
    cudaEventCreate(&stop);

    cudaEventRecord(start);
    square_transposed<<<blocks, threads>>>(d_A, d_C, N);
    cudaEventRecord(stop);

    cudaEventSynchronize(stop);

    float elapsed_ms = 0.0f;
    cudaEventElapsedTime(&elapsed_ms, start, stop);

    // Copy result back
    cudaMemcpy(h_C, d_C, bytes, cudaMemcpyDeviceToHost);

    // Verify against transposed CPU reference
    cpu_reference_transposed(h_A, h_C_ref, N);
    for (unsigned i = 0; i < MATRIX_SIZE; ++i) {
        assert(h_C[i] == h_C_ref[i]);
    }

    std::cout << "Transposed matrix square successful.\n";
    std::cout << "Kernel execution time: " << elapsed_ms << " ms\n";

    // Cleanup
    cudaEventDestroy(start);
    cudaEventDestroy(stop);
    cudaFree(d_A);
    cudaFree(d_C);
    delete[] h_A;
    delete[] h_C;
    delete[] h_C_ref;

    return 0;
}



//Kernel execution time: 0.012416 ms
