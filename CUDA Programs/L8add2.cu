// CUDA program to read a matrix A of size NxN.
// It replaces the principal diagonal elements with zero
// Elements above the principal diagonal by their factorial and 
// elements below the principal diagonal by their sum of digits

#include <stdio.h>
#include <stdlib.h>
#include <cuda.h>

// Device function to compute factorial
__device__ int factorial(int n) {
    int fact = 1;
    for (int i = 2; i <= n; i++)
        fact *= i;
    return fact;
}

// Device function to compute sum of digits
__device__ int sumOfDigits(int n) {
    int sum = 0;
    n = abs(n);
    while (n != 0) {
        sum += n % 10;
        n /= 10;
    }
    return sum;
}

// Kernel to process the matrix
__global__ void processMatrix(int* A, int* B, int N) {
    int row = threadIdx.y + blockIdx.y * blockDim.y;
    int col = threadIdx.x + blockIdx.x * blockDim.x;

    if (row < N && col < N) {
        int val = A[row * N + col];

        if (row == col)
            B[row * N + col] = 0;
        else if (col > row)
            B[row * N + col] = factorial(val);
        else
            B[row * N + col] = sumOfDigits(val);
    }
}

int main() {
    int N;
    printf("Enter N (size of NxN matrix): ");
    scanf("%d", &N);

    int size = N * N * sizeof(int);
    int* h_A = (int*)malloc(size);
    int* h_B = (int*)malloc(size);

    printf("Enter elements of matrix A:\n");
    for (int i = 0; i < N * N; i++) {
        scanf("%d", &h_A[i]);
    }

    // Device memory allocation
    int* d_A, * d_B;
    cudaMalloc(&d_A, size);
    cudaMalloc(&d_B, size);

    // Copy A to device
    cudaMemcpy(d_A, h_A, size, cudaMemcpyHostToDevice);

    // Launch kernel
    dim3 threadsPerBlock(16, 16);
    dim3 blocksPerGrid((N + 15) / 16, (N + 15) / 16);
    processMatrix << <blocksPerGrid, threadsPerBlock >> > (d_A, d_B, N);

    // Copy result back to host
    cudaMemcpy(h_B, d_B, size, cudaMemcpyDeviceToHost);

    printf("Resultant matrix B:\n");
    for (int i = 0; i < N; i++) {
        for (int j = 0; j < N; j++) {
            printf("%d ", h_B[i * N + j]);
        }
        printf("\n");
    }

    // Free memory
    free(h_A);
    free(h_B);
    cudaFree(d_A);
    cudaFree(d_B);

    return 0;
}
