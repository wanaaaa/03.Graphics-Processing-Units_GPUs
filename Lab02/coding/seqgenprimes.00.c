#include <stdlib.h>
#include <stdio.h>
#include <time.h> 
#include <string.h>

void removeMultiple(int * playground, int N, int startNum);

int main(int argc, char * argv[]) {
   double time_taken;
   clock_t start, end;

   char *sampleNumStr;
   sampleNumStr = argv[1];

   char fileName[] = "./";
   strcat(sampleNumStr, ".txt");

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


  char str[999999];
  // char str[] = "";
  strcpy(str, "");

  int ii;
  int digitNum;
  for(ii = 0; ii < N-1; ii++) {
    if(playground[ii] != -1) {
      if(playground[ii] < 10) digitNum = 1;
      else if (playground[ii] < 100) digitNum = 2;
      else if (playground[ii] < 1000) digitNum = 3;
      else if (playground[ii] < 10000) digitNum = 4;
      else if (playground[ii] < 100000) digitNum = 5;
      else if (playground[ii] < 1000000) digitNum = 6;
      else if (playground[ii] < 10000000) digitNum = 7;
      else digitNum = 8;
      char new_string[digitNum];
      int number=playground[ii];
      sprintf(new_string ,"%d" , number); 
      
      strcat(str, new_string);
      strcat(str, " ");
    }
   }

  FILE * fp;
  fp = fopen(sampleNumStr, "w");

  fprintf(fp, "%s\n", str );
  fclose (fp);


  time_taken = ((double)(end - start))/ CLOCKS_PER_SEC;
  
  printf("Time taken for %s is %lf\n"," CPU", time_taken);
  

  return 0;
}

void removeMultiple(int * playground, int N, int startNum) {
  int iii;
  for(iii = startNum-1; iii < N-1; iii++) {
    if(playground[iii] % startNum == 0 && playground[iii] != -1 ) 
      playground[iii] = -1;      
   }

}