#include <stdio.h>
#include <mpi.h>
#include <string.h>

void toggle_case(char word[]) {
    for (int i = 0; word[i] != '\0'; i++) {
        if (word[i] >= 'a' && word[i] <= 'z') {
            word[i] = word[i] - 32; // Convert to uppercase
        } else if (word[i] >= 'A' && word[i] <= 'Z') {
            word[i] = word[i] + 32; // Convert to lowercase
        }
    }
}

int main(int argc, char* argv[]) {
    int rank, size, n;
    MPI_Init(&argc, &argv);
    MPI_Comm_rank(MPI_COMM_WORLD, &rank);
    MPI_Comm_size(MPI_COMM_WORLD, &size);

    char word[100];
    MPI_Status status;

    if (rank == 0) {
        printf("Enter the word:\n");
        scanf("%s", word);
        n = strlen(word);

        // Send string length and the word to process 1
        MPI_Ssend(&n, 1, MPI_INT, 1, 1, MPI_COMM_WORLD);
        MPI_Ssend(word, n, MPI_CHAR, 1, 1, MPI_COMM_WORLD);
        printf("Process %d sends the original string: %s to process %d\n", rank,word,rank+1);
        // Receive toggled string from process 1
        MPI_Recv(word, n, MPI_CHAR, 1, 2, MPI_COMM_WORLD, &status);

        // Display the final result
        printf("Toggled string received from process 1: %s\n", word);

    } else if (rank == 1) {
        // Receive string length and the word from process 0
        MPI_Recv(&n, 1, MPI_INT, 0, 1, MPI_COMM_WORLD, &status);
        MPI_Recv(word, n, MPI_CHAR, 0, 1, MPI_COMM_WORLD, &status);
        word[n] = '\0'; // Null-terminate the string
        
        //printf("Process 1 received the original string: %s\n", word);

        // Toggle the case of the string
        toggle_case(word);

        // Send the toggled string back to process 0
        MPI_Ssend(word, n, MPI_CHAR, 0, 2, MPI_COMM_WORLD);
    }

    MPI_Finalize();
    return 0;
}

