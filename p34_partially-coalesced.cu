__global__ void partially_coalesced(int *A)
{
    int tid = blockIdx.x * blockDim.x + threadIdx.x;
    int value = A[tid + 1];   // shifted access
}
