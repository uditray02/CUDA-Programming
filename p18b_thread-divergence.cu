__global__ void dkernel(unsigned *vector, unsigned vectorsize)
{
    unsigned id = blockIdx.x * blockDim.x + threadIdx.x;

    switch (id) {
        case 0: vector[id] = 0; break;
        case 1: vector[id] = vector[id]; break;
        case 2: vector[id] = vector[id - 2]; break;
        case 3: vector[id] = vector[id + 3]; break;
        case 4: vector[id] = 4 + 4 + vector[id]; break;
        case 5: vector[id] = 5 - vector[id]; break;
        case 6: vector[id] = vector[6]; break;
        case 7: vector[id] = 7 + 7; break;
        case 8: vector[id] = vector[id] + 8; break;
        case 9: vector[id] = vector[id] * 9; break;
        default:
            // threads with id >= 10 do nothing
            break;
    }
}


//Steps taken to execute 11-12

/*

Switch evaluation (compute id, compare cases) → 1 step

Case bodies executed serially

case 0 → 1 step

case 1 → 1 step

case 2 → 1 step

case 3 → 1 step

case 4 → 1 step

case 5 → 1 step

case 6 → 1 step

case 7 → 1 step

case 8 → 1 step

case 9 → 1 step
→ 10 steps

Reconvergence / exit → ~1 step

*/



//REDUCING

__global__ void dkernel(unsigned* vector)
{
    unsigned id = blockIdx.x * blockDim.x + threadIdx.x;
    unsigned v = vector[id];

    unsigned is0 = (id == 0);
    unsigned is1 = (id == 1);
    unsigned is2 = (id == 2);
    unsigned is3 = (id == 3);
    unsigned is4 = (id == 4);
    unsigned is5 = (id == 5);
    unsigned is6 = (id == 6);
    unsigned is7 = (id == 7);
    unsigned is8 = (id == 8);
    unsigned is9 = (id == 9);

    vector[id] =           //Only one predicate is 1, All others are 0 , So only one term contributes
        is0 * 0 +
        is1 * v +
        is2 * vector[id - 2] +
        is3 * vector[id + 3] +
        is4 * (v + 8) +
        is5 * (5 - v) +                      //All other terms vanish.
        is6 * vector[6] +
        is7 * 14 +
        is8 * (v + 8) +
        is9 * (v * 9);
}


// All threads execute same path
// Warp executes once
// ~2 warp steps    