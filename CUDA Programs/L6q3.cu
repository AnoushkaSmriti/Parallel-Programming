//parallel odd even transposition sort

#include<stdio.h>
#include<stdlib.h>
#include<cuda.h>

// phase-1: odd even exchange
__global__ void odd_even(int*A,int n)
{
	int tid = blockIdx.x * blockDim.x + threadIdx.x;
	int temp;
	if (tid < n)
	{
		if (tid % 2 != 0 && tid + 1 < n)
		{
			if (A[tid] > A[tid + 1])
			{
				temp = A[tid];
				A[tid] = A[tid + 1];
				A[tid + 1] = temp;
			}
		}
	}
}

// phase-2: even odd exchange

__global__ void even_odd(int* A, int n)
{
	int tid = blockIdx.x * blockDim.x + threadIdx.x;
	int temp;
	if (tid < n)
	{
		if (tid % 2 == 0 && tid + 1 < n)
		{
			if (A[tid] > A[tid + 1])
			{
				temp = A[tid];
				A[tid] = A[tid + 1];
				A[tid + 1] = temp;
			}
		}
	}
}

int main()
{
	int n;
	printf("Enter size of array:\n");
	scanf("%d", &n);
	int size = n * sizeof(int);
	int* h_A = (int*)malloc(size);
	printf("Enter elements of array:\n");
	for (int i = 0;i < n;i++)
	{
		scanf("%d", &h_A[i]);
	}

	//device memory allocation
	int* d_A;
	cudaMalloc((void**)&d_A, size);

	//host to device
	cudaMemcpy(d_A, h_A, size, cudaMemcpyHostToDevice);

	//kernel launch
	dim3 dimGrid(ceil(n / 256.0), 1, 1);
	dim3 dimBlock(256, 1, 1);

	// max ceil(n/2) iterations
	for (int i = 0;i < ceil(n / 2);i++)
	{
		odd_even << <dimGrid, dimBlock >> > (d_A, n);
		even_odd << <dimGrid, dimBlock >> > (d_A, n);

	}

	//device to host
	cudaMemcpy(h_A, d_A, size, cudaMemcpyDeviceToHost);

	//print results
	for (int i = 0;i < n;i++)
	{
		printf("%d ", h_A[i]);
	}


	free(h_A);
	cudaFree(d_A);

	return 0;
}