#include <stdio.h>
#include <mpi.h>
#include <string.h>
#include <stdlib.h>

long factorial(int x) {
    if (x == 0 || x == 1)
        return 1;

    return x * factorial(x - 1);
}

int main(int argc, char *argv[]) {
    int size, rank;
    int error_code;
    char error_string[MPI_MAX_ERROR_STRING];
    int error_string_length;
    long local_factorial = 0, sum_factorials = 0;

    MPI_Init(&argc, &argv);
    MPI_Errhandler_set(MPI_COMM_WORLD, MPI_ERRORS_RETURN);
    MPI_Comm_rank(MPI_COMM_WORLD, &rank);
    MPI_Comm_size(MPI_COMM_WORLD, &size);

    local_factorial = factorial(rank + 1);

    // Introduce an error by using an invalid communicator
    error_code = MPI_Scan(&local_factorial, &sum_factorials, 1, MPI_LONG, MPI_SUM, MPI_COMM_WORLD);
        
    if (error_code != MPI_SUCCESS) {
        int error_class;
        MPI_Error_class(error_code, &error_class);
        MPI_Error_string(error_code, error_string, &error_string_length);
        
        // Print error message only from the root process (rank 0)
        if (rank == 0) {
            fprintf(stderr, "This is an error message by Annie.\n");
            fprintf(stderr, "Error code: %d\n", error_code);
            fprintf(stderr, "Error class: %d\n", error_class);
            fprintf(stderr, "Error string: %s\n", error_string);
        }
    } else {
        // Print the local factorial at each process
        printf("Process %d: Local factorial of %d is: %ld\n", rank, rank + 1, local_factorial);
        
        if (rank == size - 1) {
            printf("Sum of factorials from 1 to %d is: %ld\n", size, sum_factorials);
        }
    }

    MPI_Finalize();
    return 0;
}
