// decimal to octal conversion
#include<stdio.h>
#include<stdlib.h>
#include<cuda.h>

__global__ void decToOctal(int* A, int* O, int n)
{
	int tid = blockIdx.x * blockDim.x + threadIdx.x;
	int pow = 1, ans = 0;
	if (tid < n)
	{
		int num = A[tid];
		while (num > 0)
		{
			int rem = num % 8;
			ans += rem * pow;

			num = num / 8;
			pow = pow * 10;
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
	int* h_A = (int*)malloc(size);
	int* h_O = (int*)malloc(size);

	printf("Enter elements of array:\n");
	for (int i = 0;i < n;i++)
	{
		scanf("%d", &h_A[i]);
	}

	//device memory allocation
	int* d_A, * d_O;
	cudaMalloc((void**)&d_A, size);
	cudaMalloc((void**)&d_O, size);

	//host to device
	cudaMemcpy(d_A, h_A, size, cudaMemcpyHostToDevice);

	//kernel launch
	dim3 dimGrid(ceil(n / 256.0), 1, 1);
	dim3 dimBlock(256, 1, 1);
	decToOctal << <dimGrid, dimBlock >> > (d_A, d_O, n);

	//device to host
	cudaMemcpy(h_O, d_O, size, cudaMemcpyDeviceToHost);

	//print results
	printf("Resultant octal values:\n");
	for (int i = 0;i < n;i++)
	{
		printf("%d ", h_O[i]);
	}

	free(h_A);
	free(h_O);
	cudaFree(d_A);
	cudaFree(d_O);

	return 0;



}