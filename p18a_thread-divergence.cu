__global__ void warp(unsigned *vector, unsigned vectorsize) {   
    unsigned id = blockIdx.x * blockDim.x + threadIdx.x;   //S0 compute id
    for (unsigned ii = 0; ii < id; ++ii)
        vector[id] += ii;



//size of the loop is dependent on ID
// ID is variable for each thread.. Thread 0 = ID0; Thread 35 =  ID35