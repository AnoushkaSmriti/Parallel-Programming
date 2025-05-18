// one's complement of binary numbers
#include<stdio.h>
#include<stdlib.h>
#include<cuda.h>

__global__ void binTo1s(long int* A, long int* O, int n)
{
	int tid = blockIdx.x * blockDim.x + threadIdx.x;
	long int place = 1, ans = 0;
	if (tid < n)
	{
		int num = A[tid];
		while (num > 0)
		{
			int digit = num % 10;
			int flipped = (digit == 0) ? 1 : 0;
			ans += flipped * place;

			num = num / 10;
			place = place * 10;
		}
		O[tid] = ans;
	}
}

int main()
{
	int n;
	printf("Enter size of array:\n");
	scanf("%d", &n);
	int size = n * sizeof(int);
	long int* h_A = (long int*)malloc(size);
	long int* h_O = (long int*)malloc(size);

	printf("Enter elements of array:\n");
	for (int i = 0;i < n;i++)
	{
		scanf("%ld", &h_A[i]);
	}

	//device memory allocation
	long int* d_A, * d_O;
	cudaMalloc((void**)&d_A, size);
	cudaMalloc((void**)&d_O, size);

	//host to device
	cudaMemcpy(d_A, h_A, size, cudaMemcpyHostToDevice);

	//kernel launch
	dim3 dimGrid(ceil(n / 256.0), 1, 1);
	dim3 dimBlock(256, 1, 1);
	binTo1s << <dimGrid, dimBlock >> > (d_A, d_O, n);

	//device to host
	cudaMemcpy(h_O, d_O, size, cudaMemcpyDeviceToHost);

	//print results
	printf("Resultant 1s complement values:\n");
	for (int i = 0;i < n;i++)
	{
		printf("%ld ", h_O[i]);
	}

	free(h_A);
	free(h_O);
	cudaFree(d_A);
	cudaFree(d_O);

	return 0;



}