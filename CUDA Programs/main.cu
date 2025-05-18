#include <cuda_runtime.h>
#include<stdio.h>
#include<cuda.h>

__global__ void helloKernel() {
    printf("Hello from GPU!\n");
}

int main() {
    helloKernel << <1, 1 >> > ();
    cudaDeviceSynchronize();
    return 0;
}
