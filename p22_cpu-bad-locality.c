// cpu_bad_locality.c
#include <stdio.h>
#include <stdlib.h>
#include <time.h>

#define N (1024*1024)

int main() {
    int *a = malloc(N * sizeof(int));
    for (int i = 0; i < N; i++) a[i] = 1;

    clock_t start = clock();
    long long sum = 0;

    for (int i = 0; i < N; i++)
        sum += a[i * 16 % N];   // stride access → bad locality

    clock_t end = clock();
    printf("Bad locality time: %.3f s\n",
           (double)(end - start) / CLOCKS_PER_SEC);

    free(a);
}
// To compile: gcc -o cpu_bad_locality cpu_bad_locality.c -O2
// To run: ./cpu_bad_locality