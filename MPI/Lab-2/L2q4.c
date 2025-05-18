#include <stdio.h>
#include<stdlib.h>
#include <mpi.h>

int main(int argc, char* argv[]){
int size,rank,n;
MPI_Init(&argc,&argv);
MPI_Comm_size(MPI_COMM_WORLD,&size);
MPI_Comm_rank(MPI_COMM_WORLD,&rank);
MPI_Status status;

if(rank==0){
printf("Enter an integer value:\n");
scanf("%d",&n);
n++;
MPI_Send(&n,1,MPI_INT,1,0,MPI_COMM_WORLD);
printf("Process %d(root) sends %d to process 1\n",rank,n);

//receive final value from last process
MPI_Recv(&n,1,MPI_INT,size-1,0,MPI_COMM_WORLD,&status);

}
else{
MPI_Recv(&n,1,MPI_INT,rank-1,0,MPI_COMM_WORLD,MPI_STATUS_IGNORE);
printf("Process %d receives %d from process %d\n",rank,n,rank-1);
n++;
if(rank==size-1){
MPI_Send(&n,1,MPI_INT,0,0,MPI_COMM_WORLD);
printf("Process %d(last process)sends %d back to root process\n",rank,n);
}
else{
MPI_Send(&n,1,MPI_INT,rank+1,0,MPI_COMM_WORLD);
printf("Process %d sends %d to process %d\n",rank,n,rank+1);
}
}
MPI_Finalize();
return 0;
}
