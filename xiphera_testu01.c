#include "unistd.h"
#include "swrite.h"
#include "bbattery.h"
#include "gdef.h"
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <stdio.h>
#include <string.h>
#include "statcoll.h"
#include "gofw.h"
#include "unif01.h"
#include "sres.h"
#include <sentrop.h>
#include "util.h"
#include "smultin.h"
#include "sknuth.h"
#include "smarsa.h"
#include "snpair.h"
#include "svaria.h"
#include "sstring.h"
#include "swalk.h"
#include "scomp.h"
#include "sspectral.h"
#include "swrite.h"
#include "sres.h"
#include "unif01.h"
#include "ufile.h"

#include "gofs.h"
#include "gofw.h"
#include "fdist.h"
#include "fbar.h"
#include "num.h"
#include "chrono.h"

#include <stdio.h>
#include <string.h>
#include <math.h>
#include <time.h>
#include <limits.h>

#include <sys/types.h>
#include <sys/stat.h>





struct stat buffer;
int status;
int kohta;
char** filename;
int dieharder_only = 0;
int crush_only = 0;

void entropyCalc(char *filename){


  const int s = 30;
  const int r = 0;
  int i;
  int j = -1;
  int j2 = 1;
  chrono_Chrono *Timer;
  struct stat buffer;
  int status;
  double nb;
  long bufsiz;
  unif01_Gen *gen;
  sentrop_Res *res;
  res = sentrop_CreateRes ();

  printf("Reading binary!\n");
  status = stat(filename, &buffer);
  printf("Size of the file is: %li",buffer.st_size*8);
  printf(" bits\n");
  nb = buffer.st_size*8;
  nb -= fmod (nb, 32.0);
  bufsiz = nb / 32.0 - 32.0;
  printf("In the file there were %ld MILLION random numbers\n\n",bufsiz/1000000);
  gen = ufile_CreateReadBin (filename,bufsiz);

  ufile_InitReadBin ();
  swrite_Basic = TRUE;
  // EntropyDisc00(gen, NULL , 1, 100000, 0, 10, 10);
  ufile_InitReadBin ();
  sentrop_EntropyDisc(gen, NULL , 1, bufsiz, 0, 10, 10);

  ufile_InitReadBin ();
  sentrop_EntropyDisc(gen, NULL , 1, bufsiz, 0, 8, 8);

  swrite_Basic = FALSE;
  sentrop_DeleteRes (res);
  ufile_DeleteReadBin (gen);
}


int main (int argc, char** argv)
{
  swrite_Basic = FALSE;
  int i = 1
  for (i = 1; i < argc; ++i){
    if (access( argv[i], F_OK ) != -1){
      kohta=i;
      printf("File found\n");
      printf("%s\n",argv[i]);
      status = stat(argv[kohta], &buffer);
      printf("With size of %li bytes, ",buffer.st_size);
      printf("which translates into %li 32-bit random words.\n\n", buffer.st_size * 8 / 32);
    }
    else if (argv[i][1] == 'v'){
      swrite_Basic = TRUE;
      printf("Printing all the stuff to terminal");
    }
  }

  if ((argc < 2) && access( argv[kohta], F_OK ) == -1 ){
    printf("Provide a valid filename to be tested.\n");
  }
  else{
    printf("Running a Rabbit tests\n\n");
    bbattery_RabbitFile(argv[kohta],buffer.st_size*8);
    if ((buffer.st_size * 8 / 32) > 51320000 ){
      printf("Running SmallCrush test battery\n\n");
      bbattery_SmallCrushFile(argv[kohta]);
    }
    else{
      printf("There were not enought random numbers to run the SmallCrush test battery\n\n");
    }
    printf("Running FIPS-140-2 tests\n\n");
    bbattery_FIPS_140_2File(argv[kohta]);
    printf("Running a Alphabit tests\n\n");
    bbattery_AlphabitFile(argv[kohta],buffer.st_size*8);
    printf("Running a BlockAlphabit tests\n\n");
    bbattery_BlockAlphabitFile(argv[kohta],buffer.st_size*8);
  }
  return 0;
}
