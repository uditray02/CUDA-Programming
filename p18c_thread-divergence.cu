__global__ void dkernel()
{
    if (threadIdx.x < 16)
    {
        printf("Inside If");
        Global_Barrier();
    }
    else if (threadIdx.x >= 16)
    {
        printf("Inside else");
        Global_Barrier();
    }
}


/*

Threads 0–15 take the if path

Threads 16–31 take the else path

The warp diverges and executes paths serially

Each path calls Global_Barrier() (block-wide barrier)

SO:

No guaranteed printf output

Kernel hangs / deadlocks

Behavior is undefined

*/