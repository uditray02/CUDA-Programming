__global__ void steps(unsigned *vector, unsigned vectorsize); {

    int id = blockIdx.x * blockDim.x + threadIdx.x;

    if (id < = 0){

        vector[id] = 0;
        for (int i = 1; i<=100; i++){
            vector[id] +=i;
        }
    }

    else {
        vector[id] = 1;
    }


}

/*

Step-by-step warp execution

Step 1: Evaluate branch predicate

All 32 threads evaluate id <= 0

Mask created:

Thread 0 → true

Threads 1–31 → false

Step 2: Execute if path (masked)

Active threads: 1

Instructions:

vector[0] = 0

Loop runs 100 iterations

add + store each iteration
~100 loop iterations × multiple instructions
Other 31 threads are idle but still occupying the warp

Step 3: Execute else path (masked)

Active threads: 31

Instruction:

vector[id] = 1

*/

/*

At the warp level:

Branch evaluation → 1 step

If-path execution → ~100 loop iterations (dominant)

Else-path execution → 1 step

*/



/*
The steps 102 can be lessened by eliminating the divergent look  - restricting the control flow the kernel can be reduced to  ~ 2 steps
*/

__global__ void steps(unsigned *vector, unsigned vectorsize); {

    int id = blockIdx.x * blockDim.x + threadIdx.x;

    if (id <= 0){

        vector[id] = (101 * 100) / 2;
    }

    else {
        vector[id] = 1;
    }


}

//OR

__global__ void steps(unsigned* vector) {
    int id = blockIdx.x * blockDim.x + threadIdx.x;
    vector[id] = (id == 0) ? 5050 : 1;
}
//  /Warp execution

//Predicate evaluation → 1

// Single predicated store → 1          // vector[id] = 5050;


/*
Why “1 step” is impossible

Memory stores must be separate instructions

Predication does not eliminate predicate evaluation
*/