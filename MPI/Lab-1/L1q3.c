#include <mpi.h>
#include <stdio.h>

int main(int argc, char* argv[]) {
    int rank, size;
    MPI_Init(&argc, &argv);
    MPI_Comm_rank(MPI_COMM_WORLD, &rank);
    MPI_Comm_size(MPI_COMM_WORLD, &size);

    // Hardcoded numbers for operations
    int num1 = 5, num2 = 10;

    // Perform the operation based on the rank, using one switch statement
    printf("Process of rank %d in total %d processes:\n", rank, size);

    switch(rank) {
        case 0:
            printf("Addition: %d + %d = %d\n", num1, num2, num1 + num2);
            break;
        case 1:
            printf("Subtraction: %d - %d = %d\n", num1, num2, num1 - num2);
            break;
        case 2:
            printf("Multiplication: %d * %d = %d\n", num1, num2, num1 * num2);
            break;
        case 3:
            // Check for division by zero
            if (num2 != 0) {
                printf("Division: %d / %d = %d\n", num1, num2, num1 / num2);
            } else {
                printf("Division: Cannot divide by zero\n");
            }
            break;
        case 4:
            // Check for division by zero
            if (num2 != 0) {
                printf("Modulus: %d %% %d = %d\n", num1, num2, num1 % num2);
            } else {
                printf("Modulus: Cannot perform modulus by zero\n");
            }
            break;
        default:
            // If rank is greater than 4, default to addition
            printf("Addition: %d + %d = %d\n", num1, num2, num1 + num2);
            break;
    }

    MPI_Finalize();
    return 0;
}

