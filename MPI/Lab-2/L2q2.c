#include <stdio.h>
#include <mpi.h>

int main(int argc, char*argv[]){
int size, rank,n,n1;
MPI_Init(&argc,&argv);
MPI_Comm_rank(MPI_COMM_WORLD, &rank);
MPI_Comm_size(MPI_COMM_WORLD, &size);
MPI_Status status;

if(rank==0){
printf("Enter a number:\n");
scanf("%d",&n);

for(int i=1;i<size;i++){
MPI_Send(&n,1,MPI_INT,i,i,MPI_COMM_WORLD);
}
}

else{
MPI_Recv(&n,1,MPI_INT,0,rank,MPI_COMM_WORLD,&status);
printf("Process %d (out of total %d processes) receives %d from root:\n",rank,size,n);
}

MPI_Finalize();
return 0;
}
