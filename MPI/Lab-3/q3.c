#include<mpi.h>
#include<stdio.h>
#include<stdlib.h>
#include<stdbool.h>
#include<ctype.h>
#include<string.h>

bool isVowel(char c){
    c = tolower(c);
    return c=='a'||c=='e'||c=='i'||c=='o'||c=='u';
}

int main(int argc, char*argv[]){
    
    int size, rank, n, local_non_vowel_count=0, non_vowel_count=0;
    char str[100], sent_str[2];
    int* non_vowel_counts=NULL;

    MPI_Init(&argc, &argv);
    MPI_Comm_size(MPI_COMM_WORLD,&size);
    MPI_Comm_rank(MPI_COMM_WORLD,&rank);

    if(rank==0){
        //read str
        printf("Enter a string:\n");
        scanf("%s",str);
        n = strlen(str);

        if(n%size!=0){
            printf("String length is indivisible by number of processes.\n");
            MPI_Abort(MPI_COMM_WORLD,1);
        }
    }

    //no need to broadcast length of string(n) but you can

        // root sends a char to each process
        MPI_Scatter(str,1,MPI_CHAR,sent_str,1,MPI_CHAR,0,MPI_COMM_WORLD);
        printf("Letter received by process %d: %c",rank,sent_str[0]);

        if(!isVowel(sent_str[0])){
            local_non_vowel_count++;
            printf("Non vowel found by process %d: %c\n",rank,sent_str[0]);
        }

        // root gathers all local_non_vowel_counts
        if(rank==0){
            non_vowel_counts = (int*)malloc(n*sizeof(int));
        }

        MPI_Gather(&local_non_vowel_count,1,MPI_INT,non_vowel_counts,1,MPI_INT,0,MPI_COMM_WORLD);

        // total no. of non vowels computed by root
        if(rank==0){
            for(int i=0;i<size;i++){
                non_vowel_count += non_vowel_counts[i]; 
            }
            printf("Total number of non_vowels: %d\n",non_vowel_count);
            free(non_vowel_counts);

        }

        MPI_Finalize();

        return 0;



}