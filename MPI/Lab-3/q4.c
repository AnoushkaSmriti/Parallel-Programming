#include<mpi.h>
#include<stdio.h>
#include<stdlib.h>
#include<string.h>

int main(int argc, char*argv[]){
    
    int size, rank, n;
    char str1[50],str2[50], sent_str[10], resultant_str[100];

    MPI_Init(&argc,&argv);
    MPI_Comm_size(MPI_COMM_WORLD,&size);
    MPI_Comm_rank(MPI_COMM_WORLD,&rank);

    if(rank==0){
        //read 2 strings
        printf("Enter string 1:\n");
        scanf("%s",str1);
        printf("Enter string 2 of same length:\n");
        scanf("%s",str2);

        if(strlen(str1)!=strlen(str2)){
            printf("String lengths should match!\n");
            MPI_Abort(MPI_COMM_WORLD,1);
        }

        n = strlen(str1);

        if(n%size!=0){
            printf("String length is indivisible by number of processes(including root)\n");
            MPI_Abort(MPI_COMM_WORLD,1);
        }


    }

    // send 1 char of each string to all processes
    MPI_Scatter(str1,1,MPI_CHAR,&sent_str[0],1,MPI_CHAR,0,MPI_COMM_WORLD);
    MPI_Scatter(str2,1,MPI_CHAR,&sent_str[1],1,MPI_CHAR,0,MPI_COMM_WORLD);

    sent_str[2]='\0';

    // root gathers all the 2 lettered strings by all processes
    MPI_Gather(sent_str,2,MPI_CHAR,resultant_str,2,MPI_CHAR,0,MPI_COMM_WORLD);

    if(rank==0){
        resultant_str[n*2]='\0';
        printf("Resultant string: %s\n",resultant_str);
        
    }
    MPI_Finalize();
    return 0;


}