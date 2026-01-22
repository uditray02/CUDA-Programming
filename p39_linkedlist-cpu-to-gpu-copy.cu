#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <cuda_runtime.h>

/* =======================
   CPU Linked List Node
   ======================= */
struct NodeCPU {
    int roll;
    char name[32];
    int age;
    NodeCPU *next;
};

/* =======================
   GPU-Friendly Node
   (NO POINTERS!)
   ======================= */
struct NodeGPU {
    int roll;
    char name[32];
    int age;
    int next_index;   // index instead of pointer
};

/* =======================
   GPU Kernel: Single-pass traversal
   ======================= */
__global__ void traverse(NodeGPU *nodes, int head_index)
{
    // Only ONE thread does traversal (linked list is serial)
    if (threadIdx.x == 0 && blockIdx.x == 0) {
        int idx = head_index;

        while (idx != -1) {
            printf("Roll=%d Name=%s Age=%d\n",
                   nodes[idx].roll,
                   nodes[idx].name,
                   nodes[idx].age);

            idx = nodes[idx].next_index;
        }
    }
}

/* =======================
   Helper: Create CPU Linked List
   ======================= */
NodeCPU* create_list()
{
    NodeCPU *n1 = (NodeCPU*)malloc(sizeof(NodeCPU));
    NodeCPU *n2 = (NodeCPU*)malloc(sizeof(NodeCPU));
    NodeCPU *n3 = (NodeCPU*)malloc(sizeof(NodeCPU));

    n1->roll = 1; strcpy(n1->name, "Alice"); n1->age = 20;
    n2->roll = 2; strcpy(n2->name, "Bob");   n2->age = 21;
    n3->roll = 3; strcpy(n3->name, "Carol"); n3->age = 22;

    n1->next = n2;
    n2->next = n3;
    n3->next = NULL;

    return n1; // head
}

/* =======================
   MAIN
   ======================= */
int main()
{
    /* ---- Step 1: CPU linked list ---- */
    NodeCPU *head = create_list();

    /* ---- Step 2: Flatten in ONE PASS ---- */
    NodeGPU *h_nodes = NULL;
    int count = 0;

    NodeCPU *curr = head;

    while (curr != NULL) {
        h_nodes = (NodeGPU*)realloc(h_nodes,
                    (count + 1) * sizeof(NodeGPU));

        h_nodes[count].roll = curr->roll;
        strcpy(h_nodes[count].name, curr->name);
        h_nodes[count].age = curr->age;

        // temporary, fixed after traversal
        h_nodes[count].next_index = count + 1;

        curr = curr->next;
        count++;
    }

    // fix last node
    h_nodes[count - 1].next_index = -1;

    /* ---- Step 3: Copy to GPU ---- */
    NodeGPU *d_nodes;
    cudaMalloc(&d_nodes, count * sizeof(NodeGPU));
    cudaMemcpy(d_nodes, h_nodes,
               count * sizeof(NodeGPU),
               cudaMemcpyHostToDevice);

    /* ---- Step 4: GPU traversal ---- */
    traverse<<<1, 1>>>(d_nodes, 0);
    cudaDeviceSynchronize();

    /* ---- Cleanup ---- */
    cudaFree(d_nodes);
    free(h_nodes);

    // free CPU linked list
    while (head) {
        NodeCPU *tmp = head;
        head = head->next;
        free(tmp);
    }

    return 0;
}
