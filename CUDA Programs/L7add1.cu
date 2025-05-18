#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <cuda.h>
#define MAX 1024

__global__ void charCount(char* S, int Slength, char* ch, int *count)
{
    int tid = blockIdx.x * blockDim.x + threadIdx.x;
    if (tid < Slength)
    {
        if (S[tid] == *ch)  // use *ch to dereference the char pointer
        {
            atomicAdd(count, 1);
        }
    }
}


void checkCudaError(const char* msg)
{
    cudaError_t err = cudaGetLastError();
    if (err != cudaSuccess)
    {
        fprintf(stderr, "CUDA Error: %s: %s\n", msg, cudaGetErrorString(err));
        exit(EXIT_FAILURE);
    }
}


int main()
{
    printf("Enter string:\n");
    char* h_S = (char*)malloc(MAX * sizeof(char));
    fgets(h_S, MAX, stdin);
    h_S[strcspn(h_S, "\n")] = 0; // remove newline
    int Slength = strlen(h_S);

    printf("Enter char to count:\n");
    char h_ch;
    scanf("%c", &h_ch); 

    //int* h_count = (int*)malloc(sizeof(int));
    //* h_count = 0;
    int h_count = 0;

    // Device memory allocation
    char* d_S, * d_ch;
    int* d_count;


    cudaEvent_t start, stop;
    cudaEventCreate(&start);
    cudaEventCreate(&stop);
    cudaEventRecord(start, 0);


    cudaMalloc((void**)&d_S, (Slength + 1));
    cudaMalloc((void**)&d_ch, sizeof(char));
    cudaMalloc((void**)&d_count, sizeof(int));

    // Host to device
    cudaMemcpy(d_S, h_S, (Slength + 1), cudaMemcpyHostToDevice);
    cudaMemcpy(NULL, &h_ch, sizeof(char), cudaMemcpyHostToDevice);
    //cudaMemcpy(d_ch, &h_ch, sizeof(char), cudaMemcpyHostToDevice);
    cudaMemcpy(d_count, &h_count, sizeof(int), cudaMemcpyHostToDevice);

    checkCudaError("Invalid arguments");


    // Kernel launch
    dim3 dimGrid((Slength + 255) / 256, 1, 1);
    dim3 dimBlock(256, 1, 1);
    charCount << <dimGrid, dimBlock >> > (d_S, Slength, d_ch, d_count);

   
    cudaEventRecord(stop, 0);
    cudaEventSynchronize(stop);
    float elapsedTime;
    cudaEventElapsedTime(&elapsedTime, start, stop);


    // Device to host
    cudaMemcpy(&h_count, d_count, sizeof(int), cudaMemcpyDeviceToHost);

    printf("Count of char '%c' : %d\n", h_ch, h_count);

    printf("Time taken = %f", elapsedTime);

    // Cleanup
    free(h_S);
    //free(h_count);
    cudaFree(d_S);
    cudaFree(d_ch);
    cudaFree(d_count);

    return 0;
}
