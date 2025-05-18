# include<mpi.h>
# include<stdio.h>
# include<stdlib.h>

int factorial(int n){
    int fact = 1;
    for(int i=n;i>=1;i--){
        fact = fact*i;
    }
    return fact;
}

int main(int argc, char* argv[]){
   
    int size, rank, i, value, total=0;
    int* array = NULL,  *results=NULL;

    MPI_Init(&argc, &argv);
    MPI_Comm_rank(MPI_COMM_WORLD,&rank);
    MPI_Comm_size(MPI_COMM_WORLD,&size);
    MPI_Status status;

    if(rank==0){
      array = (int*)malloc(size*sizeof(int));
      printf("Enter %d values:\n",size);
      for(i=0;i<size;i++){
        scanf("%d",&array[i]);
      }
    }
    //root send one value to each process
    MPI_Scatter(array,1,MPI_INT,&value,1,MPI_INT,0,MPI_COMM_WORLD);

    //each process computes factorial of the value received
    int fact = factorial(value);
    printf("Factorial of %d received by process %d: %d \n",value,rank,fact);

    if(rank==0){
        results = (int*)malloc(size*sizeof(int));
    }
    // root gathers the factorial
    MPI_Gather(&fact,1,MPI_INT,results,1,MPI_INT,0,MPI_COMM_WORLD);

    //root finds sum of all factorials
    // printf("Results array received by root:\n");
    if(rank==0){
        for(i=0;i<size;i++){
            // printf("%d ",results[i]);
            total+=results[i];
        }
        printf("Total sum of all factorials in root: %d\n",total);

        free(array);
        free(results);
    }
    // free(array);
    // free(results);
    MPI_Finalize();
    return 0;


}