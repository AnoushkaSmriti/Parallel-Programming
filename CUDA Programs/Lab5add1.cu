// y = alpha*x + y

#include<stdio.h>
#include<cuda.h>
#include<stdlib.h>
#include<math.h>


__global__ void linear_algebra(float* X, float* Y, int n, float alpha)
{
   int tid = blockIdx.x*blockDim.x + threadIdx.x;
   if(tid<n)
   {
    Y[tid] = X[tid]*alpha + Y[tid];
   }
}

int main()
{
 int n;
 printf("Enter size of the two arrays:\n");
 scanf("%d", &n);
 int size = n*sizeof(float);
 float *h_X = (float*)malloc(size);
 float *h_Y = (float*)malloc(size);
 printf("Enter elements for array X:\n");
 for(int i=0;i<n;i++)
 {
  scanf("%f",&h_X[i]);
 }
 printf("Enter elements for array Y:\n");
 for (int i = 0;i < n;i++)
 {
     scanf("%f", &h_Y[i]);
 }
 float alpha;
 printf("Enter alpha value:\n");
 scanf("%f", &alpha);

 // device memory allocation
 float *d_X, *d_Y;
 cudaMalloc((void**)&d_X,size);
 cudaMalloc((void**)&d_Y,size);

 cudaMemcpy(d_X,h_X,size,cudaMemcpyHostToDevice);
 cudaMemcpy(d_Y, h_Y, size, cudaMemcpyHostToDevice);


 //kernel launch
 dim3 dimGrid(ceil(n/256.0),1,1);
 dim3 dimBlock(256,1,1);

 linear_algebra<<<dimGrid,dimBlock>>>(d_X,d_Y,n,alpha);

 cudaMemcpy(h_Y,d_Y,size,cudaMemcpyDeviceToHost);

 printf("Resultant array Y:\n");

 for(int i=0;i<n;i++)
 {
   printf("%.2f ",h_Y[i]);
 }

 free(h_X);
 free(h_Y);

 cudaFree(d_X);
 cudaFree(d_Y);

 return 0;



}