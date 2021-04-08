#include <cuda.h>
#include <stdlib.h>
#include <stdio.h>
#include <time.h> 
#include <string.h>

#include <iostream>
using namespace std;

__global__ void removeMultiple(int * playground, int N, int startNum);

int main(int argc, char * argv[]) {
   double time_taken;
   clock_t start, end;

   int N = (unsigned int) atoi(argv[1]);
   int startNum = 2;
   size_t groundSize = (N-1)*sizeof(int);

   int * playground = (int *)calloc(N-1, sizeof(int));
   for(int i = 0; i < N-1; i ++ ) {
      playground[i] = i + 2;
   }

   int *d_playground;
   cudaMalloc((void **)&d_playground, groundSize);
   cudaMemcpy(d_playground, playground, groundSize, cudaMemcpyHostToDevice);

   int threadNum = 256;
   int blockNum = (N -1 + threadNum -1)/threadNum;

   int wI = 0;
   start = clock();

   while(startNum  < (N+1)/2) {
      if(playground[startNum-2] != -1)
         ////////////////////////////////////////
         removeMultiple<<< blockNum, threadNum >>>(d_playground, N, startNum);
         ////////////////////////////////////////

      startNum ++;
      wI ++;
   }
   end = clock();

   char str[8000];
   strcpy(str, "");

   int *h_playgroundResult = (int *)malloc(groundSize);
   cudaMemcpy(h_playgroundResult, d_playground, groundSize, cudaMemcpyDeviceToHost);

   
   int numPrime = 0;
   for(int i = 0; i < N-1; i++) {
      if(h_playgroundResult[i] != -1) {
         char new_string[6];
         int number=playground[i];
         sprintf(new_string ,"%d" , number);       
         strcat(str, new_string);
         strcat(str, " ");
         // cout<<"prime: i->"<<i+2<<" value->"<<h_playgroundResult[i]<<endl;
         numPrime ++;
      }
   }


   cout<<"the number of prime is "<<numPrime<<endl;

   cudaFree(d_playground);

   time_taken = ((double)(end - start))/ CLOCKS_PER_SEC;
   printf("Time taken for %s is %lf\n", "GPU", time_taken);

   return 0;
}

__global__ void removeMultiple(int * playground, int N, int startNum) {
   int ix = threadIdx.x + blockDim.x*blockIdx.x;

   if((ix<N-1) && (ix > startNum -1) ) {
      if((playground[ix] % startNum == 0)&& (playground[ix] != -1 ) ) {
         playground[ix] = -1;        
      }
   }
}

