#include <stdio.h>
#include <cuda.h>
#include <math.h>

__global__ void compute(int* arr, int* res, int h, int w) {
    int row = threadIdx.x;
    int col = threadIdx.y;
    int ele = arr[row * w + col];
    int result = 1;
    for (int i = 0; i < row + 1; i++) {
        result *= ele;
    }
    res[row * w + col] = result;
}
int main() {
    int h, w;
    printf("Enter h and w: \n");
    scanf("%d %d", &h, &w);

    int size = h * w * sizeof(int);
    int* h_arr = (int*)malloc(size);
    int* h_res = (int*)malloc(size);

    printf("Enter elements: \n");
    for (int i = 0;i < h * w;i++) {
        scanf("%d", &h_arr[i]);
    }

    int* d_arr, * d_res;
    cudaMalloc((void**)&d_arr, size);
    cudaMalloc((void**)&d_res, size);

    cudaMemcpy(d_arr, h_arr, size, cudaMemcpyHostToDevice);
    dim3 dimGrid(1, 1, 1);
    dim3 dimBlock(h, w, 1);
    compute << <dimGrid, dimBlock >> > (d_arr, d_res, h, w);
    cudaMemcpy(h_res, d_res, size, cudaMemcpyDeviceToHost);

    printf("Result: \n");
    for (int i = 0; i < h; i++) {
        for (int j = 0; j < w;j++) {
            printf("%d ", h_res[i * w + j]);
        }
        printf("\n");
    }
}