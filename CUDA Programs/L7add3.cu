#include <stdio.h>
#include <string.h>
#include <cuda_runtime.h>

#define N 3  // Number of repetitions

__global__ void replicateString(char* d_out, const char* d_in, int len) {
    int idx = threadIdx.x + blockIdx.x * blockDim.x;
    if (idx < N*len) {
        //one char per thread - requires if(idx<N*len)
        //d_out[idx] = d_in[idx % len];
        
        // one word per thread
        /*int offset = idx * len;
        for (int i = 0;i < len;i++)
        {
            d_out[offset + i] = d_in[i];
        }*/
        
        // one thread copies one char from input string
        int pos = idx;
        for (int i = 0;i <len;i++)
        {
            d_out[pos] = d_in[idx];
            pos = pos + len;
        }

        //or

        //char ch = d_in[idx];  // Character to copy
        //for (int i = 0; i < N; i++) 
        //    d_out[i * len + idx] = ch;
    }
}

int main() {
    const char Sin[] = "Hello";
    int len = strlen(Sin);
    int totalLen = len * N;

    char* d_in, * d_out;
    char* h_out = (char*)malloc((totalLen + 1) * sizeof(char)); // dynamic allocation

    // Allocate device memory
    cudaMalloc((void**)&d_in, len * sizeof(char));
    cudaMalloc((void**)&d_out, totalLen * sizeof(char));

    // Copy input string to device
    cudaMemcpy(d_in, Sin, len * sizeof(char), cudaMemcpyHostToDevice);

    // Launch kernel
    int threadsPerBlock = 256;
    int blocks = (totalLen + threadsPerBlock - 1) / threadsPerBlock;
    replicateString << <blocks, threadsPerBlock >> > (d_out, d_in, len);

    // Copy result back to host
    cudaMemcpy(h_out, d_out, totalLen * sizeof(char), cudaMemcpyDeviceToHost);
    h_out[totalLen] = '\0';  // Null-terminate the string

    printf("Output: %s\n", h_out);

    // Cleanup
    cudaFree(d_in);
    cudaFree(d_out);
    free(h_out);

    return 0;
}
