#include<stdio.h>
#include<stdlib.h>
#include<cuda.h>

__global__ void rowWiseAdd(int* A, int* B, int* C, int width, int height)
{
	int rid = threadIdx.x;
	for (int cid = 0;cid < width;cid++)
	{
		C[rid * width + cid] = A[rid * width + cid] + B[rid * width + cid];
	}
}
__global__ void colWiseAdd(int* A, int* B, int* C, int width, int height)
{
	int cid = threadIdx.x;
	for (int rid = 0;rid < height;rid++)
	{
		C[rid * width + cid] = A[rid * width + cid] + B[rid * width + cid];
	}
}
__global__ void eleWiseAdd(int* A, int* B, int* C, int width, int height)
{
	int rid = threadIdx.y;
	int cid = threadIdx.x;
	
	C[rid * width + cid] = A[rid * width + cid] + B[rid * width + cid];
	
}

int main()
{
	int height, width;

	printf("Enter height:\n");
	scanf("%d", &height);

	printf("Enter width:\n");
	scanf("%d", &width);

	int size = height * width * sizeof(int);
	int* h_A = (int*)malloc(size);
	int* h_B = (int*)malloc(size);
	int* h_C = (int*)malloc(size);

	printf("Enter elements for matrix A:\n");
	for (int i = 0;i < width * height;i++)
	{
		scanf("%d", &h_A[i]);
	}
	printf("Enter elements for matrix B:\n");
	for (int i = 0;i < width * height;i++)
	{
		scanf("%d", &h_B[i]);
	}

	// device memory allocation
	int* d_A, * d_B, * d_C;
	cudaMalloc((void**)&d_A, size);
	cudaMalloc((void**)&d_B, size);
	cudaMalloc((void**)&d_C, size);

	// host to device
	cudaMemcpy(d_A, h_A, size, cudaMemcpyHostToDevice);
	cudaMemcpy(d_B, h_B, size, cudaMemcpyHostToDevice);

	//kernel launch
	//rowWiseAdd << <1, height >> > (d_A, d_B,d_C, width, height);
	colWiseAdd << <1, width >> > (d_A, d_B,d_C, width, height);
	dim3 dimGrid(1, 1, 1);
	dim3 dimBlock(width, height, 1);
	//eleWiseAdd << <1, width*height >> > (d_A, d_B,d_C, width, height);
	//eleWiseAdd << <1,dimBlock >> > (d_A, d_B, d_C, width, height);

	// device to host
	cudaMemcpy(h_C, d_C, size, cudaMemcpyDeviceToHost);

	printf("Resultant array C:\n");
	for (int i = 0;i < height;i++)
	{
		for (int j = 0;j < width;j++)
		{
			printf("%d ", h_C[i * width + j]);
		}
		printf("\n");
	}

	free(h_A);
	free(h_B);
	free(h_C);
	cudaFree(d_A);
	cudaFree(d_B);
	cudaFree(d_C);

	return 0;


}