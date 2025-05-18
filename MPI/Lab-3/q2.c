#include<mpi.h>
#include<stdio.h>
#include<stdlib.h>

int main(int argc, char* argv[]){

    int size, rank, i, m;
    long local_sum=0, total_sum=0;
    double total_avg;
    int *array=NULL, *b=NULL, *local_sums=NULL;

    MPI_Init(&argc,&argv);
    MPI_Comm_size(MPI_COMM_WORLD,&size);
    MPI_Comm_rank(MPI_COMM_WORLD,&rank);

    if(rank==0){
        //read M
        printf("Enter m:\n ");
        scanf("%d",&m);
        //read array(N*M)
        array = (int*)malloc((size*m)*sizeof(int));
        printf("Enter %d values:\n",size*m);
        for(i=0;i<size*m;i++){
            scanf("%d",&array[i]);
        }
    }

    //send m value to all processes
    MPI_Bcast(&m,1,MPI_INT,0,MPI_COMM_WORLD);

    //root sends m elements to each process
    //allocate memory for b array
    b = (int*)malloc(m*sizeof(int));

    MPI_Scatter(array,m,MPI_INT,b,m,MPI_INT,0,MPI_COMM_WORLD);

    //each process finds average of the m values received
    for(i=0;i<m;i++){
        local_sum+=b[i];
    }
    // local_avg = local_sum/m;
    // printf("Local average of process %d : %d\n",local_avg, rank);   // wrong, local_avg can't be computed by each process

    printf("Local sum in process %d: %d\n",rank,local_sum);

    //allocate memory for local_sums
    if(rank==0){
        local_sums = (int*)malloc(size*sizeof(int));
    }

    // root gathers all local sums of all processes
    MPI_Gather(&local_sum,1,MPI_INT,local_sums,1,MPI_INT,0,MPI_COMM_WORLD);


    //root computes total of all local sums and computes total average
    if(rank==0){
        for(i=0;i<size;i++){
            total_sum+=local_sums[i];
        }
        total_avg = (double)total_sum/(size*m);

        printf("Total sum gathered in root: %d\n",total_sum);
        printf("Total average of all %d elements: %f\n",(size*m),total_avg);

        free(local_sums);

    }
    if(rank==0){
        free(array);
    }

    free(b);


    MPI_Finalize();
    return 0;



}