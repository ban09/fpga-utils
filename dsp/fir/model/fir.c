#include <stdio.h>
#include <stdint.h>
#include <string.h>

#define ROUND 0

#define TEST_DATA_SIZE 9000000

/* NOTE it won't work if NCOEFFS/DECIMATING_FACTOR is not an integer */
#define DECIMATING_FACTOR 10
#define NCOEFFS 30
int coeffs[NCOEFFS] = {-29 ,-32 ,-37 ,-36 ,-19 ,28 ,119 ,260 ,451 ,683 ,938 ,1192 ,1416 ,1583 ,1672 ,1672 ,1583 ,1416 ,1192 ,938 ,683 ,451 ,260 ,119 ,28 ,-19 ,-36 ,-37 ,-32 ,-29};

int8_t buf[TEST_DATA_SIZE];

int main(char argc, char **argv){

    int n;
    int p = 0;
    int acc = 0;
    int8_t res = 0;

    while((n=fread(buf+p,1,1024,stdin))>0){
        p+=n;
    }
    fprintf(stderr,"Got %d bytes\n",p);

    for(int i = 0; i < NCOEFFS; i=i+DECIMATING_FACTOR){
        fwrite(&res,1,1,stdout);
    }

    for(int i = 0;i<p;i=i+DECIMATING_FACTOR){
        acc = 0;
        for(int j = 0; j<NCOEFFS; j++){
            acc += (coeffs[j]*buf[j+i]);
        }
#if ROUND == 0
        res = (int8_t)(acc>>14);
#else
        res = (int8_t)( (acc>>14)+(acc&(1<<13)>>13));
#endif
        fwrite(&res,sizeof(int8_t),1,stdout);
    }
    return 0;
}
