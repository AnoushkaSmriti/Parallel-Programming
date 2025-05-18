#include <stdio.h>
#include <stdlib.h>
#include <mpi.h>

int main(int argc, char* argv[]) {
    int size, rank;
    MPI_Init(&argc, &argv);
    MPI_Comm_size(MPI_COMM_WORLD, &size);
    MPI_Comm_rank(MPI_COMM_WORLD, &rank);
    MPI_Status status;
    int* array = NULL;
    int value, result;

    if (rank == 0) {
        array = (int*)malloc(size * sizeof(int));
        printf("Enter %d elements:\n", size);
        for (int i = 0; i < size; i++) {
            scanf("%d", &array[i]);
        }

        for (int i = 1; i < size; i++) {
            MPI_Send(&array[i], 1, MPI_INT, i, 0, MPI_COMM_WORLD);
            printf("Root process: Sent %d to process %d\n", array[i], i);
        }
    } else {
        MPI_Recv(&value, 1, MPI_INT, 0, 0, MPI_COMM_WORLD, &status);
        printf("Process %d: Received %d\n", rank, value);

        if (rank % 2 == 0) {
            result = value * value;
            printf("Process %d: Square of %d is %d\n", rank, value, result);
        } else {
            result = value * value * value;
            printf("Process %d: Cube of %d is %d\n", rank, value, result);
        }
    }

    if (rank == 0) {
        free(array);
    }

    MPI_Finalize();
    return 0;
}

