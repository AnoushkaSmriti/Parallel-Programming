#include<stdio.h>
#include<cuda.h>
#include<stdlib.h>

__global__ void vecAdd(int *A, int *B, int *C, int n)
{
	int tid = blockIdx.x * blockDim.x + threadIdx.x;
	if (tid < n)
	{
		C[tid] = A[tid] + B[tid];

	}
}

int main()
{
	int n;
	printf("Enter size of the two arrays:\n");
	scanf("%d", &n);
	int size = n * sizeof(int);
	int *h_A = (int *)malloc(size);
	int *h_B = (int *)malloc(size);
	int *h_C = (int *)malloc(size);

	printf("Enter elements for array A:\n");
	for (int i = 0;i < n;i++)
	{
		scanf("%d", &h_A[i]);
	}
	printf("Enter elements for array B:\n");
	for (int i = 0;i < n;i++)
	{
		scanf("%d", &h_B[i]);
	}

	//device memory allocation
	int *d_A, *d_B, *d_C;
	cudaMalloc((void**)&d_A, size);
	cudaMalloc((void**)&d_B, size);
	cudaMalloc((void**)&d_C, size);

	cudaMemcpy(d_A, h_A, size, cudaMemcpyHostToDevice);
	cudaMemcpy(d_B, h_B, size, cudaMemcpyHostToDevice);

	//kernel launch
	dim3 dimGrid(ceil(n/256.0), 1);
	dim3 dimBlock(256, 1);
	dim3 dimGrid(1, /*1);
	dim3 dimBlock(1, 1);*/
	vecAdd << < dimGrid, dimBlock >> > (d_A, d_B, d_C, n);

	cudaMemcpy(h_C, d_C, size, cudaMemcpyDeviceToHost);

	//print result
	printf("Result array:\n");
	for (int i = 0;i < n;i++)
	{
		printf("%d ", h_C[i]);
	}

	free(h_A);
	free(h_B);
	free(h_C);
	cudaFree(d_A);
	cudaFree(d_B);
	cudaFree(d_C);

	return 0;


}