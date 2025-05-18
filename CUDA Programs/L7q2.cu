// S: PCAP , RS: PCAPPCAPCP
#include<stdio.h>
#include<stdlib.h>
#include<cuda.h>
#include<string.h>
#define MAX_LENGTH 1024

__global__ void copyStringProgressively(char* S, char* RS, int Slength)
{
	int tid = blockIdx.x * blockDim.x + threadIdx.x;
	
	if (tid < Slength)
	{ 
		int length_to_copy = Slength - tid;
		int offset = tid * Slength - (tid * (tid - 1)) / 2;

		for (int i = 0;i < length_to_copy;i++)
		{
			RS[offset + i] = S[i];
		}
		
	}
}

int main()
{
	printf("Enter string:\n");
	char* h_S = (char*)malloc(MAX_LENGTH * sizeof(char));
	fgets(h_S, MAX_LENGTH, stdin);
	h_S[strcspn(h_S, "\n")] = 0;  // remove newline

	int Slength = strlen(h_S);
	int totalSize = Slength * (Slength + 1) / 2;

	char* h_RS = (char*)malloc((totalSize + 1) * sizeof(char));
	h_RS[totalSize] = '\0'; // null terminate

	//device memory allocation
	char* d_S, * d_RS;
	cudaMalloc((void**)&d_S, Slength * sizeof(char));
	cudaMalloc((void**)&d_RS, totalSize * sizeof(char));

	//host to device
	cudaMemcpy(d_S, h_S, Slength * sizeof(char), cudaMemcpyHostToDevice);

	//kernel launch
	dim3 dimGrid((Slength + 255) / 256, 1, 1);
	dim3 dimBlock(256, 1, 1);
	copyStringProgressively << <dimGrid, dimBlock >> > (d_S, d_RS, Slength);

	//device to host
	cudaMemcpy(h_RS, d_RS, totalSize * sizeof(char), cudaMemcpyDeviceToHost);

	printf("Resultant string:\n%s\n", h_RS);

	// cleanup
	free(h_S);
	free(h_RS);
	cudaFree(d_S);
	cudaFree(d_RS);

	return 0;
}