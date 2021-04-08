#include <stdlib.h>
#include <stdio.h>
#include <time.h> 
#include <string.h>

void removeMultiple(int * playground, int N, int startNum);

int main(int argc, char * argv[]) {
   double time_taken;
   clock_t start, end;

   int N = (unsigned int) atoi(argv[1]);
   int startNum = 2;
   int * playground = (int *)calloc(N-1, sizeof(int));
   int i;
   for(i = 0; i < N-1; i ++ ) {
      playground[i] = i + 2;
   }

   int wI = 0;
   start = clock();

   while(startNum  < (N+1)/2) {
      if(playground[startNum-2] != -1)
         removeMultiple(playground, N, startNum);

      startNum ++;
      wI ++;
   }
   end = clock(); 

  // FILE * fp;
  // char filename[15];
  // sprintf(filename, "%d.txt", N); 
  // fp = freopen(filename, "w", stdout);

  int ii;
  int countInt = 0;
  for(ii = 0; ii < N-1; ii++) {
    if(playground[ii] != -1) {
      // printf("%d ", playground[ii]); 
      countInt ++;
    }
   }

  // fclose (fp);


  time_taken = ((double)(end - start))/ CLOCKS_PER_SEC;
  
  printf("Time taken for %s is %lf\n"," CPU", time_taken);
  printf("The number of prime is %d\n", countInt);
  

  return 0;
}

void removeMultiple(int * playground, int N, int startNum) {
  int iii;
  for(iii = startNum-1; iii < N-1; iii++) {
    if(playground[iii] % startNum == 0 && playground[iii] != -1 ) 
      playground[iii] = -1;      
   }

}