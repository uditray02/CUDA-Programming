// cpu_latency.c
#include <stdio.h>
#include <stdlib.h>

int main() {
    int *a = malloc(1024*1024*sizeof(int));
    long long sum = 0;
    for (int i = 0; i < 1024*1024; i++)
        sum += a[i];   // CPU stalls on cache misses
}
