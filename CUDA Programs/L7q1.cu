// count frequency of word in a sentence
#include<stdio.h>
#include<string.h>
#include<cuda.h>
#include<stdlib.h>
#define MAX_LENGTH 1024

__global__ void wordCount(char* sentence, char* word, int Slength, int Wlength, int* count)
{
	int tid = blockIdx.x * blockDim.x + threadIdx.x;
	if (tid <= Slength - Wlength)
	{
		int match = 1;
		for (int j = 0;j < Wlength;j++)
		{
			if (sentence[tid + j] != word[j])
			{
				match = 0;
				break;
			}
		}
		if (match)
		{
			atomicAdd(count, 1);
		}

	}
}

int main()
{
	printf("Enter sentence:\n");
	char* h_sentence = (char*)malloc(MAX_LENGTH * sizeof(char));
	fgets(h_sentence, MAX_LENGTH, stdin);  // Read input
	h_sentence[strcspn(h_sentence, "\n")] = 0;  // Remove newline

	printf("Enter word:\n");
	char* h_word = (char*)malloc(MAX_LENGTH * sizeof(char));
	fgets(h_word, MAX_LENGTH, stdin);  // Read input
	h_word[strcspn(h_word, "\n")] = 0;  // Remove newline

	int Slength = strlen(h_sentence);
	int Wlength = strlen(h_word);

	int* h_count = (int*)malloc(sizeof(int));
	*h_count = 0;

	//device memory allocation
	char* d_sentence, * d_word;
	int* d_count;
	cudaMalloc((void**)&d_sentence, (Slength + 1));
	cudaMalloc((void**)&d_word, (Wlength + 1));
	cudaMalloc((void**)&d_count, sizeof(int));

	// host to device
	cudaMemcpy(d_sentence, h_sentence, (Slength + 1), cudaMemcpyHostToDevice);
	cudaMemcpy(d_word, h_word, (Wlength + 1), cudaMemcpyHostToDevice);
	cudaMemcpy(d_count, h_count, sizeof(int), cudaMemcpyHostToDevice);

	//kernel launch
	int blockSize = 256;
	int numBlocks = (Slength + blockSize - 1) / blockSize;
	wordCount << <numBlocks, blockSize >> > (d_sentence, d_word, Slength, Wlength, d_count);

	//device to host
	cudaMemcpy(h_count, d_count, sizeof(int), cudaMemcpyDeviceToHost);

	printf("Count of word %s in sentence %s: %d\n", h_word, h_sentence, *h_count);

	free(h_sentence);
	free(h_word);
	cudaFree(d_sentence);
	cudaFree(d_word);

	return 0;


}