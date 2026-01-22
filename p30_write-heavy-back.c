// write_back_demo.c
int a[1024*1024];
int main() {
    for (int i = 0; i < 1024*1024; i++)
        a[i] = i;   // repeated writes → cache absorbs
}
