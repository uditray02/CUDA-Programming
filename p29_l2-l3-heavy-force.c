// l2_l3_demo.c
int a[1024*1024];
int main() {
    for (int r = 0; r < 100; r++)
        for (int i = 0; i < 1024*1024; i++)
            a[i]++;
}
