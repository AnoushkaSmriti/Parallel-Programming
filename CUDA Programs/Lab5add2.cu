#include <stdio.h>
#include <stdlib.h>
#include <cuda.h>
#include <opencv2/opencv.hpp> // Include OpenCV

using namespace cv;

__global__ void colorToGreyscale(unsigned char* greyImage, unsigned char* rgbImage, int width, int height)
{
    int row = blockIdx.y * blockDim.y + threadIdx.y;
    int col = blockIdx.x * blockDim.x + threadIdx.x;

    if (col < width && row < height)
    {
        int greyOffset = row * width + col;
        int rgbOffset = greyOffset * 3; // RGB has 3 channels

        unsigned char r = rgbImage[rgbOffset];
        unsigned char g = rgbImage[rgbOffset + 1];
        unsigned char b = rgbImage[rgbOffset + 2];

        greyImage[greyOffset] = 0.21f * r + 0.71f * g + 0.07f * b;
    }
}

int main()
{
    // Load the image using OpenCV
    Mat image = imread("C:\\Users\\Reliance Digital\\Pictures\\My Paintings\\Tribal elegance.jpeg", IMREAD_COLOR);
    if (image.empty())
    {
        printf("Could not open or find the image\n");
        return -1;
    }

    int width = image.cols;
    int height = image.rows;

    // Convert to RGB (OpenCV loads as BGR by default)
    Mat rgbImage;
    cvtColor(image, rgbImage, COLOR_BGR2RGB);

    // Prepare grayscale output
    Mat greyImage(height, width, CV_8UC1);

    int colorBytes = width * height * 3 * sizeof(unsigned char);
    int greyBytes = width * height * sizeof(unsigned char);

    // Allocate device memory
    unsigned char* d_rgbImage, * d_greyImage;
    cudaMalloc((void**)&d_rgbImage, colorBytes);
    cudaMalloc((void**)&d_greyImage, greyBytes);

    // Copy input image to device
    cudaMemcpy(d_rgbImage, rgbImage.ptr(), colorBytes, cudaMemcpyHostToDevice);

    // Define grid and block dimensions
    dim3 blockSize(16, 16);
    dim3 gridSize((width + 15) / 16, (height + 15) / 16);

    // Launch the kernel
    colorToGreyscale << <gridSize, blockSize >> > (d_greyImage, d_rgbImage, width, height);
    cudaDeviceSynchronize();

    // Copy result back to host
    cudaMemcpy(greyImage.ptr(), d_greyImage, greyBytes, cudaMemcpyDeviceToHost);

    // Convert back to OpenCV and save
    cvtColor(greyImage, greyImage, COLOR_GRAY2BGR);
    imwrite("greyscale_output.jpg", greyImage);

    printf("Greyscale image saved as greyscale_output.jpg\n");

    // Free device memory
    cudaFree(d_rgbImage);
    cudaFree(d_greyImage);

    return 0;
}
