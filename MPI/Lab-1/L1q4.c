#include <mpi.h>
#include <stdio.h>
#include <string.h>

int main(int argc, char *argv[]) {
    int rank, size;
    MPI_Init(&argc, &argv);
    MPI_Comm_rank(MPI_COMM_WORLD, &rank);
    MPI_Comm_size(MPI_COMM_WORLD, &size);

    // Define the string to be toggled
    char str[] = "HELLO";  // Length = 5
    int str_length = strlen(str);  // Get length of string
    
    // Ensure the number of processes doesn't exceed the length of the string
    if (size > str_length) {
        if (rank == 0) {
            printf("Number of processes exceeds the length of the string.\n");
        }
        MPI_Finalize();
        return 0;
    }

    // Each process will toggle a specific character, based on its rank
    // Only processes with rank 0, 1, 2, ... (size-1) will toggle their corresponding character
    char char_to_toggle = str[rank];  // The character that the process will toggle

    // Toggle the character (uppercase to lowercase, or lowercase to uppercase)
    if (char_to_toggle >= 'A' && char_to_toggle <= 'Z') {
        char_to_toggle += 32;  // Toggle from uppercase to lowercase
    } else if (char_to_toggle >= 'a' && char_to_toggle <= 'z') {
        char_to_toggle -= 32;  // Toggle from lowercase to uppercase
    }

    // Print the result from each process (each process only sees its own toggled character)
    printf("Process %d in total %d processes toggles character: %c -> %c\n", rank ,size, str[rank], char_to_toggle);

    MPI_Finalize();
    return 0;
}

