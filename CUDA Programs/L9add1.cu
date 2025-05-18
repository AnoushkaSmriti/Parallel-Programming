//CUDA program which reads an input matrix A of size MxN and produces
//an output matrix B of size MxN such that, each element of the output matrix
//is calculated in parallel. Each element B[i][j], in the output matrix is 
//obtained by adding elements in ith row and jth column of A.

#include <stdio.h>
#include <stdlib.h>
#include <cuda.h>

// Kernel to compute each B[i][j] = sum of ith row + sum of jth column
__global__ void computeOutputMatrix(int* A, int* rowSum, int* colSum, int* B, int M, int N) {
    int row = threadIdx.y + blockIdx.y * blockDim.y;
    int col = threadIdx.x + blockIdx.x * blockDim.x;

    if (row < M && col < N) {
        B[row * N + col] = rowSum[row] + colSum[col];
    }
}

// Kernel to compute row sums
__global__ void computeRowSums(int* A, int* rowSum, int M, int N) {
    int row = threadIdx.x + blockIdx.x * blockDim.x;
    if (row < M) {
        int sum = 0;
        for (int j = 0; j < N; j++) {
            sum += A[row * N + j];
        }
        rowSum[row] = sum;
    }
}

// Kernel to compute column sums
__global__ void computeColSums(int* A, int* colSum, int M, int N) {
    int col = threadIdx.x + blockIdx.x * blockDim.x;
    if (col < N) {
        int sum = 0;
        for (int i = 0; i < M; i++) {
            sum += A[i * N + col];
        }
        colSum[col] = sum;
    }
}

int main() {
    int M, N;
    printf("Enter number of rows (M): ");
    scanf("%d", &M);
    printf("Enter number of columns (N): ");
    scanf("%d", &N);

    int size = M * N * sizeof(int);
    int* h_A = (int*)malloc(size);
    int* h_B = (int*)malloc(size);
    int* h_rowSum = (int*)malloc(M * sizeof(int));
    int* h_colSum = (int*)malloc(N * sizeof(int));

    printf("Enter elements of matrix A (%d x %d):\n", M, N);
    for (int i = 0; i < M * N; i++) {
        scanf("%d", &h_A[i]);
    }

    // Device memory
    int* d_A, * d_B, * d_rowSum, * d_colSum;
    cudaMalloc(&d_A, size);
    cudaMalloc(&d_B, size);
    cudaMalloc(&d_rowSum, M * sizeof(int));
    cudaMalloc(&d_colSum, N * sizeof(int));

    // Copy input to device
    cudaMemcpy(d_A, h_A, size, cudaMemcpyHostToDevice);

    // Compute row and column sums
    computeRowSums << <(M + 255) / 256, 256 >> > (d_A, d_rowSum, M, N);
    computeColSums << <(N + 255) / 256, 256 >> > (d_A, d_colSum, M, N);

    // Launch kernel to compute output matrix
    dim3 threadsPerBlock(16, 16);
    dim3 numBlocks((N + 15) / 16, (M + 15) / 16);
    computeOutputMatrix << <numBlocks, threadsPerBlock >> > (d_A, d_rowSum, d_colSum, d_B, M, N);

    // Copy result back to host
    cudaMemcpy(h_B, d_B, size, cudaMemcpyDeviceToHost);

    // Display result
    printf("Resultant matrix B:\n");
    for (int i = 0; i < M; i++) {
        for (int j = 0; j < N; j++) {
            printf("%d ", h_B[i * N + j]);
        }
        printf("\n");
    }

    // Free memory
    free(h_A);
    free(h_B);
    free(h_rowSum);
    free(h_colSum);
    cudaFree(d_A);
    cudaFree(d_B);
    cudaFree(d_rowSum);
    cudaFree(d_colSum);

    return 0;
}
