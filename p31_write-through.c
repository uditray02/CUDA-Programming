// write_through_sim.c
#include <emmintrin.h>
int a[1024*1024];
int main() {
    for (int i = 0; i < 1024*1024; i++) {
        a[i] = i;
        _mm_clflush(&a[i]);   // force write to memory
    }
}
