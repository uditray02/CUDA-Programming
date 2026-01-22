
int a[1024];
int main() {
    for (int r = 0; r < 1000000; r++)
        for (int i = 0; i < 1024; i++)
            a[i]++;   // fits in L1
}
