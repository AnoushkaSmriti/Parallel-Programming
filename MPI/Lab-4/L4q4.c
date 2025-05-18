#include <mpi.h>
#include <stdio.h>
#include <string.h>

int main(int argc, char *argv[]) {
    int rank, size;
    char str[40], ch, temp[10], result[100];  

    MPI_Init(&argc, &argv);
    MPI_Comm_rank(MPI_COMM_WORLD, &rank);
    MPI_Comm_size(MPI_COMM_WORLD, &size);

    if (rank == 0) {
        printf("Enter the string: ");
        fflush(stdout);
        scanf("%s", str);
    }

    // Scatter one character per process
    MPI_Scatter(str, 1, MPI_CHAR, &ch, 1, MPI_CHAR, 0, MPI_COMM_WORLD);

    // Create a substring with the character repeated (rank+1) times
    for (int i = 0; i <= rank; i++) {
        temp[i] = ch;
    }
    temp[rank + 1] = '\0';  // Null-terminate the string

    if (rank == 0) {
        // Copy rank 0's temp string to result
        strcpy(result, temp);

        // Receive substrings from other processes
        for (int i = 1; i < size; i++) {
            MPI_Recv(temp, 10, MPI_CHAR, i, 0, MPI_COMM_WORLD, MPI_STATUS_IGNORE);
            strcat(result, temp);
        }

        // Print final result
        printf("Modified string is: %s\n", result);
    } else {
        // Send modified substring to process 0
        MPI_Send(temp, 10, MPI_CHAR, 0, 0, MPI_COMM_WORLD);
    }

    MPI_Finalize();
    return 0;
}
