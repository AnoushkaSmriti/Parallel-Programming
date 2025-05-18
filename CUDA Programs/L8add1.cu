// CUDA program that reads a MxN matrix A and produces a result matrix B of same size as follows:
// Replace all even numbered matrix elements with their row sum and odd numbered matrix elements with their column sum

//#include <stdio.h>
//#include <stdlib.h>
//#include <cuda.h>
//
//__global__ void computeSums(int *A, int *rowSum, int *colSum, int rows, int cols) {
//    int idx = threadIdx.x + blockIdx.x * blockDim.x;
//    if (idx < rows) {
//        int sum = 0;
//        for (int j = 0; j < cols; j++) {
//            sum += A[idx * cols + j];
//        }
//        rowSum[idx] = sum;
//    }
//
//    if (idx < cols) {
//        int sum = 0;
//        for (int i = 0; i < rows; i++) {
//            sum += A[i * cols + idx];
//        }
//        colSum[idx] = sum;
//    }
//}
//
//__global__ void generateResultMatrix(int *A, int *B, int *rowSum, int *colSum, int rows, int cols) {
//    int row = threadIdx.y + blockIdx.y * blockDim.y;
//    int col = threadIdx.x + blockIdx.x * blockDim.x;
//
//    if (row < rows && col < cols) {
//        int val = A[row * cols + col];
//        if (val % 2 == 0)
//            B[row * cols + col] = rowSum[row];
//        else
//            B[row * cols + col] = colSum[col];
//    }
//}
//
//int main() {
//    int rows, cols;
//    printf("Enter rows and cols: ");
//    scanf("%d %d", &rows, &cols);
//
//    int size = rows * cols * sizeof(int);
//    int *h_A = (int *)malloc(size);
//    int *h_B = (int *)malloc(size);
//    int *h_rowSum = (int *)malloc(rows * sizeof(int));
//    int *h_colSum = (int *)malloc(cols * sizeof(int));
//
//    printf("Enter elements of matrix A:\n");
//    for (int i = 0; i < rows * cols; i++) {
//        scanf("%d", &h_A[i]);
//    }
//
//    // Device pointers
//    int *d_A, *d_B, *d_rowSum, *d_colSum;
//    cudaMalloc(&d_A, size);
//    cudaMalloc(&d_B, size);
//    cudaMalloc(&d_rowSum, rows * sizeof(int));
//    cudaMalloc(&d_colSum, cols * sizeof(int));
//
//    cudaMemcpy(d_A, h_A, size, cudaMemcpyHostToDevice);
//
//    // Calculate row and column sums
//    int maxDim = max(rows, cols);
//    computeSums<<<(maxDim + 255)/256, 256>>>(d_A, d_rowSum, d_colSum, rows, cols);
//
//    // Launch kernel to generate matrix B
//    dim3 threadsPerBlock(16, 16);
//    dim3 gridDim((cols + 15) / 16, (rows + 15) / 16);
//    generateResultMatrix<<<gridDim, threadsPerBlock>>>(d_A, d_B, d_rowSum, d_colSum, rows, cols);
//
//    cudaMemcpy(h_B, d_B, size, cudaMemcpyDeviceToHost);
//
//    printf("Result matrix B:\n");
//    for (int i = 0; i < rows; i++) {
//        for (int j = 0; j < cols; j++) {
//            printf("%d ", h_B[i * cols + j]);
//        }
//        printf("\n");
//    }
//
//    // Copy rowSum and colSum from device to host
//    cudaMemcpy(h_rowSum, d_rowSum, rows * sizeof(int), cudaMemcpyDeviceToHost);
//    cudaMemcpy(h_colSum, d_colSum, cols * sizeof(int), cudaMemcpyDeviceToHost);
//
//    // Print row sums
//    printf("Row Sums:\n");
//    for (int i = 0; i < rows; i++) {
//        printf("%d ", h_rowSum[i]);
//    }
//    printf("\n");
//
//    // Print column sums
//    printf("Column Sums:\n");
//    for (int j = 0; j < cols; j++) {
//        printf("%d ", h_colSum[j]);
//    }
//    printf("\n");
//
//
//    // Cleanup
//    free(h_A); free(h_B); free(h_rowSum); free(h_colSum);
//    cudaFree(d_A); cudaFree(d_B); cudaFree(d_rowSum); cudaFree(d_colSum);
//
//    return 0;
//}


#include <stdio.h>
#include <cuda.h>

__global__ void sum(int* arr, int* res, int height, int width) {
    int row = threadIdx.x;
    int col = threadIdx.y;

    int ele = arr[row * width + col];

    if (ele % 2 == 0) {
        int rsum = 0;
        for (int i = 0;i < width;i++) {
            rsum += arr[row * width + i];
        }
        res[row * width + col] = rsum;
    }
    else {
        int colsum = 0;
        for (int i = 0;i < height;i++) {
            colsum += arr[i * width + col];
        }
        res[row * width + col] = colsum;
    }
}

int main() {
    int h, w;
    printf("Enter matrix dimensions (h w): ");
    scanf("%d %d", &h, &w);

    int* A = (int*)malloc(h * w * sizeof(int));
    int* B = (int*)malloc(h * w * sizeof(int));

    printf("Enter elements of matrix A:\n");
    for (int i = 0; i < h * w; i++) {
        scanf("%d", &A[i]);
    }

    int* d_A, * d_B;
    cudaMalloc(&d_A, h * w * sizeof(int));
    cudaMalloc(&d_B, h * w * sizeof(int));

    cudaMemcpy(d_A, A, h * w * sizeof(int), cudaMemcpyHostToDevice);

    dim3 dimBlock(h, w, 1);
    sum << <1, dimBlock >> > (d_A, d_B, h, w);

    cudaMemcpy(B, d_B, h * w * sizeof(int), cudaMemcpyDeviceToHost);

    printf("Output matrix B:\n");
     for (int i = 0; i < h; i++) {
         for (int j = 0; j < w; j++) {
             printf("%d ", B[i * w + j]);
         }
         printf("\n");
     }

    for (int i = 0; i < h * w; i++) {
        printf("%d ", B[i]);
    }

    cudaFree(d_A);
    cudaFree(d_B);
    free(A);
    free(B);

    return 0;
}