#include <stdio.h>
#include <stdlib.h>
#include <time.h>

/*
 * Square matrix multiplication on CPU
 * matrix: input matrix (matrixsize × matrixsize)
 * result: output matrix (matrixsize × matrixsize)
 */
void squarecpu(unsigned *matrix,    // input matrix (size: matrixsize × matrixsize)
               unsigned *result,    // result → output matrix (same size)
               unsigned matrixsize) // matrixsize → number of rows and columns
{
    for (unsigned ii = 0; ii < matrixsize; ++ii) {
        for (unsigned jj = 0; jj < matrixsize; ++jj) {     
            // result[ii][jj]

            // Initialize output element
            // result[ii][jj] = Σ (matrix[ii][k] × matrix[k][jj])
            result[ii * matrixsize + jj] = 0;

            // kk iterates over the shared dimension
            // This loop computes the dot product:
            // row ii of matrix × column jj of matrix
            for (unsigned kk = 0; kk < matrixsize; ++kk) {
                // This is the heart of matrix multiplication
                result[ii * matrixsize + jj] +=
                    matrix[ii * matrixsize + kk] *
                    matrix[kk * matrixsize + jj];
            }
        }
    }
}

// Each iteration:
// - Picks one element from row ii
// - Picks one element from column jj
// - Multiplies them
// - Adds to the result
int main(void)
{
    const unsigned N = 64;
    unsigned matrix[N * N];
    unsigned result[N * N];

    // Initialize matrix
    for (unsigned i = 0; i < N * N; ++i)
        matrix[i] = i + 1;

    struct timespec start, end;

    // Start timing
    clock_gettime(CLOCK_MONOTONIC, &start);

    squarecpu(matrix, result, N);

    // Stop timing
    clock_gettime(CLOCK_MONOTONIC, &end);

    // Compute elapsed time in milliseconds
    double time_ms =
        (end.tv_sec - start.tv_sec) * 1000.0 +
        (end.tv_nsec - start.tv_nsec) / 1e6;

    printf("CPU matrix multiplication (%ux%u) time: %.3f ms\n\n",
           N, N, time_ms);

    // Print result
    for (unsigned i = 0; i < N; ++i) {
        for (unsigned j = 0; j < N; ++j)
            printf("%6u ", result[i * N + j]);
        printf("\n");
    }

    return 0;
}




// CPU matrix multiplication (64x64) time: 0.167 ms

