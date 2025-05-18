#include <stdio.h>
#include <mpi.h>

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
    long local_factorial = 0, total_factorial = 0, partial_sum = 0;

    MPI_Init(&argc, &argv);
    MPI_Comm_rank(MPI_COMM_WORLD, &rank);
    MPI_Comm_size(MPI_COMM_WORLD, &size);
    MPI_Errhandler_set(MPI_COMM_WORLD, MPI_ERRORS_RETURN);

    // Calculate local factorial
    local_factorial = factorial(rank + 1);

    // Use MPI_Scan to calculate the prefix sum of factorials
    error_code = MPI_Scan(&local_factorial, &partial_sum, 1, MPI_LONG, MPI_SUM, MPI_COMM_WORLD);
    if (error_code != MPI_SUCCESS) {
        int error_class;
        MPI_Error_class(error_code, &error_class);
        MPI_Error_string(error_code, error_string, &error_string_length);
        fprintf(stderr, "Error in MPI_Scan at process %d: %s\n", rank, error_string);
        MPI_Finalize();
        return error_code; // Exit with the error code
    }

    // Use MPI_Reduce to sum all local factorials into total_factorial at root
    error_code = MPI_Reduce(&local_factorial, &total_factorial, 1, MPI_LONG, MPI_SUM, 0, MPI_COMM_WORLD);
    if (error_code != MPI_SUCCESS) {
        int error_class;
        MPI_Error_class(error_code, &error_class);
        MPI_Error_string(error_code, error_string, &error_string_length);
        fprintf(stderr, "Error in MPI_Reduce at process %d: %s\n", rank, error_string);
        MPI_Finalize();
        return error_code; // Exit with the error code
    }
  
    // Print results
    if (rank == 0) {
        printf("Total sum of factorials from 1 to %d is: %ld\n", size, total_factorial);
    }
    printf("Process %d: Local factorial of %d is: %ld, Partial sum is: %ld\n", rank, rank + 1, local_factorial, partial_sum);

    MPI_Finalize();
    return 0;
}
