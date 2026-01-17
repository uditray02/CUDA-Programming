square<<<1, N>>>(matrix, result, N);   // N = 64     1 block  +  2 warps total (32 threads per warp)

__global__ void square(unsigned *matrix,
                       unsigned *result,
                       unsigned matrixsize)
{
    unsigned id = blockIdx.x * blockDim.x + threadIdx.x;

    for (unsigned jj = 0; jj < matrixsize; ++jj) {
        for (unsigned kk = 0; kk < matrixsize; ++kk) {

            result[id * matrixsize + jj] +=
                matrix[id * matrixsize + kk] *
                matrix[kk * matrixsize + jj];
        }
    }
}


//this takes more than CPU...
/* GPU version is slower because:

The problem is too small (64×64)

You launch only 64 threads

Each thread does a huge amount of work

GPU launch + memory overhead dominates

CPU caches are extremely efficient for this size

64 × 64 × 64 = 262,144 multiplications

Each thread computes one entire row: 64 columns × 64 inner ops = 4096 ops per thread......... Few threads, Huge work per thread ...... CPU-style parallelism, not GPU-style.


*/