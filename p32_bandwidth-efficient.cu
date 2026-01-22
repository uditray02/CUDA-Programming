__global__ void bandwidth_good(float *a, float *b, float *c) {
    __shared__ float sa[256], sb[256];
    int i = threadIdx.x;
    sa[i] = a[i];
    sb[i] = b[i];
    __syncthreads();
    c[i] = sa[i] + sb[i];
}
