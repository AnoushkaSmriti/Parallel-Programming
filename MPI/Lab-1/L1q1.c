#include<mpi.h>
#include<stdio.h>
#include<math.h>

int main(int argc, char*argv[])
{
int rank, size;
int x = 5;
MPI_Init(&argc,&argv);
MPI_Comm_rank(MPI_COMM_WORLD, &rank);
MPI_Comm_size(MPI_COMM_WORLD, &size);

double power_of_rank = 1;
for(int i=0;i<rank;i++){
power_of_rank *= x ;
}
/*printf("Rank %d in total %d processes:%.0f\n",rank,size,pow(x,rank));*/
printf("Rank %d in total %d processes:%.0f\n",rank,size,power_of_rank);


MPI_Finalize();
return 0;
}


