#define TILE 32

__global__ void rearrange(float *A, float *B, int width)
{
    __shared__ float tile[TILE][TILE];

    int tx = threadIdx.x;
    int ty = threadIdx.y;

    int row = blockIdx.y * TILE + ty;
    int col = blockIdx.x * TILE + tx;

    // Phase 1: COALESCED global memory access
    tile[ty][tx] = A[row * width + col];
    __syncthreads();

    // Phase 2: REARRANGED access (stride fixed)
    B[col * width + row] = tile[tx][ty];
}
