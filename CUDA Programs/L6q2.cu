// parallel selection sort
#include<stdio.h>
#include<stdlib.h>
#include<cuda.h>


void checkCudaError(const char* msg)
{
  cudaError_t err = cudaGetLastError();
  if(err!=cudaSuccess)
  {
    fprintf(stderr,"Cuda error - %s - %s",msg,cudaGetErrorString(err));
    exit(EXIT_FAILURE);
  }
}

__global__ void ParSelSort(float *A, float *O, int n)
{
  int tid = blockIdx.x*blockDim.x+threadIdx.x;
  if(tid<n)
  {
   int data = A[tid];
   int pos = 0;

   for(int i=0;i<n;i++)
   {
     if(A[i]<data || A[i]==data && i<tid)
     {
       pos++;
     }
   }
   O[pos]=data;
  }
}

int main()
{
  int n;
  printf("Enter size of input array:\n");
  scanf("%d",&n);
  float* h_A = (float*)malloc(n*sizeof(float));
  float* h_O = (float*)malloc(n*sizeof(float));

  printf("Enter elements for input array:\n");
  for(int i=0;i<n;i++)
  {
    scanf("%f",&h_A[i]);
  }

  //device memory allocation
  float *d_A, *d_O;
  cudaMalloc((void**)&d_A,n*sizeof(float));
  cudaMalloc((void**)&d_O,n*sizeof(float));
  checkCudaError("memory allocation");

  cudaMemcpy(d_A,h_A,n*sizeof(float),cudaMemcpyHostToDevice);
  checkCudaError("memcpy host to device");


  //kernel launch
  dim3 dimGrid(ceil(n/256.0),1,1);
  dim3 dimBlock(256,1,1);

  ParSelSort<<<dimGrid,dimBlock>>>(d_A,d_O,n);
  checkCudaError("kernel launch");


  cudaMemcpy(h_O,d_O,n*sizeof(float),cudaMemcpyDeviceToHost);
  checkCudaError("memcpy device to host");

  printf("Resultant sorted array O:\n");
  for (int i = 0;i < n;i++)
  {
      printf("%f ", h_O[i]);
  }



  free(h_A);
  free(h_O);
  cudaFree(d_A);
  cudaFree(d_O);

  return 0;

}