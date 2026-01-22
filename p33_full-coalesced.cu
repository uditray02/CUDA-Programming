__global__ void fully_coalesced(int *A)
{
    int tid = blockIdx.x * blockDim.x + threadIdx.x;
    int value = A[tid];   // contiguous access
}
