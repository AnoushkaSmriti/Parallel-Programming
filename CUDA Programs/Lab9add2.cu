//CUDA program that reads a char type matrix A and integer type matrix B
//of size MxN. It produces an output string STR such that,
//every character of A is repeated r times (where r is the integer value in matrix B 
//which is having the same index as that of the character taken in A).
//Write the kernel such that every value of input matrix 
//must be produced required number of times by one thread

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <cuda.h>

__global__ void repeatChars(char* A, int* B, char* STR, int* offsets, int rows, int cols) {
    int idx = blockIdx.x * blockDim.x + threadIdx.x;
    int total = rows * cols;

    if (idx < total) {
        int repeat = B[idx];
        int offset = offsets[idx];
        char ch = A[idx];

        for (int i = 0; i < repeat; i++) {
            STR[offset + i] = ch;
        }
    }
}

int main() {
    int rows, cols;
    printf("Enter number of rows and columns: ");
    scanf("%d %d", &rows, &cols);

    int total = rows * cols;
    size_t matrixSize = total * sizeof(char);
    size_t intSize = total * sizeof(int);

    // Host memory
    char* h_A = (char*)malloc(matrixSize);
    int* h_B = (int*)malloc(intSize);
    int* h_offsets = (int*)malloc(intSize);

    // Input char matrix A
    printf("Enter character matrix A:\n");
    for (int i = 0; i < total; i++) {
        scanf(" %c", &h_A[i]); // space before %c to skip whitespace
    }

    // Input integer matrix B
    printf("Enter integer matrix B:\n");
    int totalLength = 0;
    for (int i = 0; i < total; i++) {
        scanf("%d", &h_B[i]);
        h_offsets[i] = totalLength;
        totalLength += h_B[i];
    }

    char* h_STR = (char*)malloc((totalLength + 1) * sizeof(char)); // +1 for null-terminator

    // Device memory
    char* d_A, * d_STR;
    int* d_B, * d_offsets;

    cudaMalloc(&d_A, matrixSize);
    cudaMalloc(&d_B, intSize);
    cudaMalloc(&d_offsets, intSize);
    cudaMalloc(&d_STR, totalLength * sizeof(char));

    // Copy data to device
    cudaMemcpy(d_A, h_A, matrixSize, cudaMemcpyHostToDevice);
    cudaMemcpy(d_B, h_B, intSize, cudaMemcpyHostToDevice);
    cudaMemcpy(d_offsets, h_offsets, intSize, cudaMemcpyHostToDevice);

    // Kernel launch
    int blockSize = 256;
    int gridSize = (total + blockSize - 1) / blockSize;
    repeatChars << <gridSize, blockSize >> > (d_A, d_B, d_STR, d_offsets, rows, cols);

    // Copy result back
    cudaMemcpy(h_STR, d_STR, totalLength * sizeof(char), cudaMemcpyDeviceToHost);
    h_STR[totalLength] = '\0'; // null-terminate

    // Output
    printf("Output string:\n%s\n", h_STR);

    // Cleanup
    free(h_A); free(h_B); free(h_offsets); free(h_STR);
    cudaFree(d_A); cudaFree(d_B); cudaFree(d_offsets); cudaFree(d_STR);

    return 0;
}
