__global__ void uncoalesced(int *A)
{
    int tid = blockIdx.x * blockDim.x + threadIdx.x;
    int value = A[tid * 1024];   // large stride
}
