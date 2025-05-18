#include<mpi.h>
#include<stdio.h>

int fib_recursive(int n){
if(n<=1){
return n;
}
return fib_recursive(n-1)+fib_recursive(n-2);
}

int factorial(int n){
    int fact = 1;
    for(int i=n;i>=1;i--){
        fact *= i;
    }
    return fact;
}

int main(int argc, char*argv[])
{
int rank, size;
MPI_Init(&argc,&argv);
MPI_Comm_rank(MPI_COMM_WORLD, &rank);
MPI_Comm_size(MPI_COMM_WORLD, &size);

if(rank%2==0){
printf("Process of rank %d in  total %d processes:\n",rank,size);

printf("Factorial of %d: %d\n",rank,factorial(rank));
}

else{
printf("Process of rank %d in  total %d processes:\n",rank,size);

printf("Fibonacci of %d:%d\n",rank,fib_recursive(rank));
}


MPI_Finalize();
return 0;
}




