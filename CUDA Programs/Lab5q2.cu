#include<stdio.h>
#include<cuda.h>
#include<stdlib.h>
# include<math.h>


__global__ void computeSine(float* ang, float*val, int n)
{
   int tid = blockIdx.x*blockDim.x + threadIdx.x;
   if(tid<n)
   {
    val[tid] = sinf(ang[tid]);
   }
}

int main()
{
 int n;
 printf("Enter size of the array:\n");
 scanf("%d", &n);
 int size = n*sizeof(float);
 float *h_ang = (float*)malloc(size);
 float * h_val = (float*)malloc(size);
 printf("Enter angles in radian:\n");
 for(int i=0;i<n;i++)
 {
  scanf("%f",&h_ang[i]);
 }

 // device memory allocation
 float *d_ang, *d_val;
 cudaMalloc((void**)&d_ang,size);
 cudaMalloc((void**)&d_val,size);

 cudaMemcpy(d_ang,h_ang,size,cudaMemcpyHostToDevice);

 //kernel launch
 dim3 dimGrid(ceil(n/256.0),1,1);
 dim3 dimBlock(256,1,1);

 computeSine<<<dimGrid,dimBlock>>>(d_ang,d_val,n);

 cudaMemcpy(h_val,d_val,size,cudaMemcpyDeviceToHost);

 printf("Resultant sine of angles:\n");

 for(int i=0;i<n;i++)
 {
   printf("sin(%.2f) = %.4f\n ",h_ang[i],h_val[i]);
 }

 free(h_ang);
 free(h_val);

 cudaFree(d_ang);
 cudaFree(d_val);

 return 0;



}