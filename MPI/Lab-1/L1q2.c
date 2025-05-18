#include<mpi.h>
#include<stdio.h>
int main(int argc, char*argv[])
{
int rank, size;
MPI_Init(&argc,&argv);
MPI_Comm_rank(MPI_COMM_WORLD, &rank);
MPI_Comm_size(MPI_COMM_WORLD, &size);

if(rank%2==0){
printf("Process of rank %d in total %d processes: Hello\n",rank,size);
}
else{
printf("Process of rank %d in total %d processes: World\n",rank,size);
}


MPI_Finalize();
return 0;
}




