#include<stdio.h>
#include<stdlib.h>
#include<cuda.h>

// Error handling helper
void checkCudaError(const char* msg)
{
	cudaError_t err = cudaGetLastError();
	if (err != cudaSuccess)
	{
		fprintf(stderr, "CUDA Error - %s: %s\n", msg, cudaGetErrorString(err));
		exit(EXIT_FAILURE);  //return -1
	}
}

__global__ void conv1D(float* N, float* M, float* P, int width, int MASK_WIDTH)
{
	int tid = blockIdx.x * blockDim.x + threadIdx.x;
	int startpoint = tid - (MASK_WIDTH / 2);
	float pValue = 0;
	if (tid < width) {
		for (int i = 0; i < MASK_WIDTH; i++)
		{
			if (startpoint + i >= 0 && startpoint + i < width)
			{
				pValue += N[startpoint + i] * M[i];
			}
		}
		P[tid] = pValue;
	}
}

int main()
{
	int width;
	printf("Enter width:\n");
	scanf("%d", &width);
	int size = width * sizeof(float);
	float* h_N = (float*)malloc(size);
	float* h_P = (float*)malloc(size);

	printf("Enter elements for array N:\n");
	for (int i = 0; i < width; i++)
	{
		scanf("%f", &h_N[i]);
	}

	int MASK_WIDTH;
	printf("Enter mask width:\n");
	scanf("%d", &MASK_WIDTH);
	float* h_M = (float*)malloc(MASK_WIDTH * sizeof(float));

	printf("Enter mask array M:\n");
	for (int i = 0; i < MASK_WIDTH; i++)
	{
		scanf("%f", &h_M[i]);
	}

	// Device memory allocation
	float* d_N, * d_M, * d_P;
	cudaMalloc((void**)&d_N, size);
	cudaMalloc((void**)&d_P, size);
	cudaMalloc((void**)&d_M, MASK_WIDTH * sizeof(float));
	checkCudaError("Memory allocation");

	// Copy input to device
	cudaMemcpy(d_N, h_N, size, cudaMemcpyHostToDevice);
	cudaMemcpy(d_M, h_M, MASK_WIDTH * sizeof(float), cudaMemcpyHostToDevice);
	checkCudaError("Memcpy to device");

	// Kernel launch
	dim3 dimGrid((width + 255) / 256, 1, 1);
	dim3 dimBlock(256, 1, 1);
	conv1D << <dimGrid, dimBlock >> > (d_N, d_M, d_P, width, MASK_WIDTH);
	checkCudaError("Kernel launch");

	// Copy result back
	cudaMemcpy(h_P, d_P, size, cudaMemcpyDeviceToHost);
	checkCudaError("Memcpy to host");

	// Output
	printf("Resultant array P:\n");
	for (int i = 0; i < width; i++)
	{
		printf("%.4f ", h_P[i]);
	}
	printf("\n");

	// Free memory
	free(h_N); free(h_M); free(h_P);
	cudaFree(d_N); cudaFree(d_M); cudaFree(d_P);

	return 0;
}
