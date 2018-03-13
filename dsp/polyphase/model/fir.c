#include <stdio.h>
#include <stdint.h>
#include <string.h>

#define COEFF_SCALING (14) 

/* NOTE it may not work if NCOEFFS/DECIMATING_FACTOR is not an integer */
#define DECIMATING_FACTOR (3)
#define NCOEFFS (9)

int COEFFS[NCOEFFS] =  {-95,0,1286,4121,5759,4121,1286,0,-95};

int8_t buf;

int main(void){

    int acc = 0;
    int8_t res = 0;
    int8_t samples[NCOEFFS];
    memset(samples,0,NCOEFFS);

    for(int i = 0; 1==fread(&buf,1,1,stdin); i++){
        memmove(samples+1,samples,NCOEFFS-1);
        samples[0] = buf;
        acc = 0;
        if ( ((i+1)%3)==0 ){
            acc=0;
            for(int j = 0; j<NCOEFFS; j++){
                acc+=samples[j]*COEFFS[j];
            }
#ifndef ROUND 
            res = (int8_t)(acc>>COEFF_SCALING);
#else
            res = (int8_t)( (acc>>COEFF_SCALING)+(acc&(1<<(COEFF_SCALING-1))>>(COEFF_SCALING-1)) );
#endif
            fwrite(&res,1,1,stdout);
        }  
    }
    return 0;
}
