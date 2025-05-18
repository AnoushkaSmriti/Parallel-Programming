#include <mpi.h>
#include <stdio.h>
#include <stdlib.h>

int main(int argc, char* argv[]) {
    int rank, size;

	MPI_Init(&argc, &argv);
	MPI_Comm_rank(MPI_COMM_WORLD, &rank);
	MPI_Comm_size(MPI_COMM_WORLD, &size);

    int arr[4][4],b[4],c[4],ans[4][4];
    if(rank == 0){
        printf("Enter elements\n");
        for(int i=0;i<4;i++){
            for(int j=0;j<4;j++){
                scanf("%d",&arr[i][j]);
            }
        }
    }

    MPI_Scatter(arr,4,MPI_INT,b,4,MPI_INT,0,MPI_COMM_WORLD);
    MPI_Scan(b, c, 4, MPI_INT, MPI_SUM, MPI_COMM_WORLD);
    MPI_Gather(c,4,MPI_INT,ans,4,MPI_INT,0,MPI_COMM_WORLD);

    if (rank == 0) {
        printf("Result:\n");
        for (int i = 0; i < 4; i++) {
            for (int j = 0; j < 4; j++) {
                printf("%d ", ans[i][j]);
            }
            printf("\n");
        }
    }

    MPI_Finalize();
    return 0;
}
