// read a string of N words and reverse each word of it
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <cuda.h>
#define MAX 1024

__device__ void reverseWord(char* str, int start, int end) {
    while (start < end) {
        char temp = str[start];
        str[start] = str[end];
        str[end] = temp;
        start++;
        end--;
    }
}
// no change in order of words
__global__ void reverseWords(char* str, int len) {
    int tid = threadIdx.x + blockIdx.x * blockDim.x;
    //Only the first character of each word is handled by a thread.
    // One thread handles one word
    if (tid < len) {
        // Find the start and end of a word
        int start = -1, end = -1;

        // Skip non-word beginnings
        if ((tid == 0 || str[tid - 1] == ' ') && str[tid] != ' ') {
            start = tid;
            end = tid;
            while (end < len && str[end] != ' ') {
                end++;
            }
            reverseWord(str, start, end - 1);
        }
    }
}

int main() {
    char* h_str = (char*)malloc(MAX * sizeof(char));
    printf("Enter a string:\n");
    fgets(h_str, MAX, stdin);
    h_str[strcspn(h_str, "\n")] = 0; // Remove newline

    int len = strlen(h_str);

    // Allocate device memory
    char* d_str;
    cudaMalloc((void**)&d_str, len * sizeof(char));
    cudaMemcpy(d_str, h_str, len * sizeof(char), cudaMemcpyHostToDevice);

    // Launch kernel
    int blockSize = 256;
    int gridSize = (len + blockSize - 1) / blockSize;
    reverseWords << <gridSize, blockSize >> > (d_str, len);

    // Copy back result
    cudaMemcpy(h_str, d_str, len * sizeof(char), cudaMemcpyDeviceToHost);

    printf("Reversed words string:\n%s\n", h_str);

    // Cleanup
    cudaFree(d_str);
    free(h_str);
    return 0;
}
