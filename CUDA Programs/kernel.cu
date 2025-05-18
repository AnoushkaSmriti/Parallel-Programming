#include <stdio.h>
#include <cuda_runtime.h>

__global__ void vectorAdd(int* A, int* B, int* C, int n) {
    int idx = blockIdx.x * blockDim.x + threadIdx.x;
    if (idx < n) {
        C[idx] = A[idx] + B[idx];
    }
}

int main() {
    int n = 256;

    int* h_A = (int*)malloc(n * sizeof(int));
    int* h_B = (int*)malloc(n * sizeof(int));
    int* h_C = (int*)malloc(n * sizeof(int));

    for (int i = 0; i < n; ++i) {
        h_A[i] = i;
        h_B[i] = i * 2;
    }

    int* d_A, * d_B, * d_C;

    cudaMalloc((void**)&d_A, n * sizeof(int));
    cudaMalloc((void**)&d_B, n * sizeof(int));
    cudaMalloc((void**)&d_C, n * sizeof(int));

    cudaMemcpy(d_A, h_A, n * sizeof(int), cudaMemcpyHostToDevice);
    cudaMemcpy(d_B, h_B, n * sizeof(int), cudaMemcpyHostToDevice);

    vectorAdd << <1, n >> > (d_A, d_B, d_C, n);
    cudaMemcpy(h_C, d_C, n * sizeof(int), cudaMemcpyDeviceToHost);

    printf("Results-1: ");
    for (int i = 0; i < n; ++i) {
        printf("%d ", h_C[i]);
    }
    printf("\n");

    vectorAdd << <n, 1 >> > (d_A, d_B, d_C, n);
    cudaMemcpy(h_C, d_C, n * sizeof(int), cudaMemcpyDeviceToHost);

    printf("Results-2: ");
    for (int i = 0; i < n; ++i) {
        printf("%d ", h_C[i]);
    }
    printf("\n");


    dim3 dimGrid(ceil(n / 256.0), 1, 1);
    dim3 dimBlock(256, 1, 1);
    vectorAdd << <dimGrid, dimBlock >> > (d_A, d_B, d_C, n);

    cudaMemcpy(h_C, d_C, n * sizeof(int), cudaMemcpyDeviceToHost);

    printf("Results-3: ");
    for (int i = 0; i < n; ++i) {
        printf("%d ", h_C[i]);
    }
    printf("\n");

    cudaFree(d_A);
    cudaFree(d_B);
    cudaFree(d_C);

    free(h_A);
    free(h_B);
    free(h_C);

    return 0;
}