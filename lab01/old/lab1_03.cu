/*
 *  Please write your name and net ID below
 *  
 *  Last name:
 *  First name:
 *  Net ID: 
 * 
 */


/* 
 * This file contains the code for doing the heat distribution problem. 
 * You do not need to modify anything except starting  gpu_heat_dist() at the bottom
 * of this file.
 * In gpu_heat_dist() you can organize your data structure and the call to your
 * kernel(s) that you need to write too. 
 * 
 * You compile with:
 * 		nvcc -o heatdist heatdist.cu   
 */

#include <cuda.h>
#include <stdlib.h>
#include <stdio.h>
#include <time.h> 

/* To index element (i,j) of a 2D array stored as 1D */
#define index(i, j, N)  ((i)*(N)) + (j)

#include <iostream>
using namespace std;
/*****************************************************************/

// Function declarations: Feel free to add any functions you want.
void  seq_heat_dist(float *, unsigned int, unsigned int);
void  gpu_heat_dist(float *, unsigned int, unsigned int);


/*****************************************************************/

int main(int argc, char * argv[])
{
  // printf("asdfasdfasdfasfd\n");
  // std::cout<<"adfasdf============================================"<<std::endl;
  unsigned int N; /* Dimention of NxN matrix */
  int type_of_device = 0; // CPU or GPU
  int iterations = 0;
  int i;
  
  /* The 2D array of points will be treated as 1D array of NxN elements */
  float * playground; 
  
  // to measure time taken by a specific part of the code 
  double time_taken;
  clock_t start, end;
  
  if(argc != 4)
  {
    fprintf(stderr, "usage: heatdist num  iterations  who\n");
    fprintf(stderr, "num = dimension of the square matrix (50 and up)\n");
    fprintf(stderr, "iterations = number of iterations till stopping (1 and up)\n");
    fprintf(stderr, "who = 0: sequential code on CPU, 1: GPU execution\n");
    exit(1);
  }
  
  type_of_device = atoi(argv[3]);
  N = (unsigned int) atoi(argv[1]);
  iterations = (unsigned int) atoi(argv[2]);
 
  
  /* Dynamically allocate NxN array of floats */
  playground = (float *)calloc(N*N, sizeof(float));
  if( !playground )
  {
   fprintf(stderr, " Cannot allocate the %u x %u array\n", N, N);
   exit(1);
  }
  
  /* Initialize it: calloc already initalized everything to 0 */
  // Edge elements to 80F
  for(i = 0; i < N; i++)
    playground[index(0,i,N)] = 80;
    
  for(i = 0; i < N; i++)
    playground[index(i,0,N)] = 80;
  
  for(i = 0; i < N; i++)
    playground[index(i,N-1, N)] = 80;
  
  for(i = 0; i < N; i++)
    playground[index(N-1,i,N)] = 80;
  
  // from (0,10) to (0,30) inclusive are 150F
  for(i = 10; i <= 30; i++)
    playground[index(0,i,N)] = 150;
  
  
  if( !type_of_device ) // The CPU sequential version
  {  
    start = clock();
    seq_heat_dist(playground, N, iterations);
    end = clock();
  }
  else  // The GPU version
  {
     start = clock();
     gpu_heat_dist(playground, N, iterations); 
     end = clock();    
  }
  
  
  time_taken = ((double)(end - start))/ CLOCKS_PER_SEC;
  
  printf("Time taken for %s is %lf\n", type_of_device == 0? "CPU" : "GPU", time_taken);
  
  free(playground);
  
  return 0;

}


/*****************  The CPU sequential version (DO NOT CHANGE THAT) **************/
void  seq_heat_dist(float * playground, unsigned int N, unsigned int iterations)
{
  // Loop indices
  int i, j, k;
  int upper = N-1;
  
  // number of bytes to be copied between array temp and array playground
  unsigned int num_bytes = 0;
  
  float * temp; 
  /* Dynamically allocate another array for temp values */
  /* Dynamically allocate NxN array of floats */
  temp = (float *)calloc(N*N, sizeof(float));
  if( !temp )
  {
   fprintf(stderr, " Cannot allocate temp %u x %u array\n", N, N);
   exit(1);
  }
  
  num_bytes = N*N*sizeof(float);
  
  /* Copy initial array in temp */
  memcpy((void *)temp, (void *) playground, num_bytes);
  
  for( k = 0; k < iterations; k++)
  {
    /* Calculate new values and store them in temp */
    for(i = 1; i < upper; i++)
      for(j = 1; j < upper; j++)
            temp[index(i,j,N)] = (playground[index(i-1,j,N)] + 
            playground[index(i+1,j,N)] + 
            playground[index(i,j-1,N)] + 
            playground[index(i,j+1,N)])/4.0;
  
            
              
    /* Move new values into old values */ 
    memcpy((void *)playground, (void *) temp, num_bytes);
  }
  
}

/***************** The GPU version: Write your code here *********************/
/* This function can call one or more kenels *********************************/
// __global__ void testLoop(float * tempGround, float * playground, unsigned int N, unsigned int iterations);
__global__ void testLoop(float * tempGround, float * playground, int intN);

void  gpu_heat_dist(float * playground, unsigned int N, unsigned int iterations)
{
   cout<<"~~~in gpu_heat_dist"<<endl;
   int numElements = N*N;
   size_t groundSize = numElements * sizeof(float);

   float *h_temp = (float *) malloc(groundSize);

   float *d_temp, *d_playground;

   float *h_playgroundResult = (float *)malloc(groundSize);

   cudaMalloc((void **)&d_temp, groundSize);
   cudaMalloc((void **)&d_playground, groundSize);

   cudaMemcpy(d_temp, h_temp, groundSize, cudaMemcpyHostToDevice);
   cudaMemcpy(d_playground, playground, groundSize, cudaMemcpyHostToDevice);

   ///////////////////////////////////
   int threadNum = 256;
   int blockNum = (N + threadNum -1)/threadNum;

   // testLoop<<<blockNum, threadNum >>>(d_temp, numElements);
   testLoop<<<blockNum, threadNum >>>(d_temp, d_playground, N);

   cudaMemcpy(h_playgroundResult, d_playground, groundSize,  cudaMemcpyDeviceToHost);

   for(int i = 0; i < N*N; i++) {
      cout<<"i-> "<<i/N<<" j->"<<i % N<< " value->"<<  h_playgroundResult[i]<<endl;
   }

   cout<<"N is "<<N<<endl;
   cudaFree(d_temp); cudaFree(d_playground);

}

__global__ void testLoop(float * tempGround, float * playground, int intN) {
   int ix = threadIdx.x + blockDim.x*blockIdx.x;
   // int iy = threadIdx.y + blockDim.y*blockIdx.y;

   if(ix < intN ) {
      for(int i = 1; i < intN -1 ; i++) {
        // tempGround[ix*intN + i] = (float) ix+ 0.777;  
        if ((ix > 0) && (ix < intN -1))   {
          playground[index(ix, i, intN)] = (float) ix+ 0.123;         
        }    
      }
   }

  // tempGround[ix*10+iy] = (float) iy+ 0.777; 

}
