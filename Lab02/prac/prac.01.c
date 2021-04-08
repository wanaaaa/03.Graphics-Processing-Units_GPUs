#include <stdlib.h>
#include <stdio.h>
#include <time.h> 
#include <string.h>

void removeMultiple(int * playground, int N, int startNum);

int main(int argc, char * argv[]) {
  FILE *fp;
  fp = fopen("10.txt", "a");
  // fprintf(fp, "%s ", "asdf" );
  // fclose(fp);
  
  for(int i = 0; i < 10; i ++) {
    fprintf(fp, "%d ", i );
  }

  fclose(fp);
  return 0;
}

