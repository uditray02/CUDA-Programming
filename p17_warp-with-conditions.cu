__global__ void warp(unsigned *vector, unsigned vectorsize) {   
    unsigned id = blockIdx.x * blockDim.x + threadIdx.x;   //S0 compute id
    if (id % 2)
        vector[id] = id;               //S1 odd  Threads 1,3,5,7 run    Threads 0,2,4,6 are idle (NOP)
    else
        vector[id] = vectorsize * vectorsize;    //S2 even      Threads 0,2,4,6 run     Threads 1,3,5,7 idle

    vector[id]++;    //S3 inc../.... No branch → everyone executes together again.
}


//T0 T1 T2 T3 T4 T5 T6 T7
// S3 S3 S3 S3 S3 S3 S3 S3


//warp divergence: one warp, one program counter, executing if and else serially with half the threads idle each time