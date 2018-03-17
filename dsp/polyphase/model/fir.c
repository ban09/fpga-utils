#include <stdio.h>
#include <stdint.h>
#include <string.h>

#define COEFF_SCALING (14) 

/* NOTE it may not work if NCOEFFS/DECIMATING_FACTOR is not an integer */
#define DECIMATING_FACTOR (3)
#define NCOEFFS (9)

int COEFFS[NCOEFFS] =  {-95,0,1286,4121,5759,4121,1286,0,-95};
//int COEFFS[NCOEFFS] = {1, 3, 6, 8, 10, 11, 12, 10, 7, 3, -3, 
//    -11, -20, -28, -36, -40, -41, -36, -26, -10, 11, 35, 61,
//    85, 104, 114, 113, 98, 69, 26, -28, -91, -156, -216, -263,
//    -290, -288, -253, -181, -69, 78, 259, 465, 685, 908, 1120,
//    1309, 1462, 1571, 1627, 1627, 1571, 1462, 1309, 1120, 908,
//    685, 465, 259, 78, -69, -181, -253, -288, -290, -263, -216,
//    -156, -91, -28, 26, 69, 98, 113, 114, 104, 85, 61, 35, 11,
//    -10, -26, -36, -41, -40, -36, -28, -20, -11, -3, 3, 7, 10, 
//    12, 11, 10, 8, 6, 3, 1};

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
        if ( ((i+1)%DECIMATING_FACTOR)==0 ){
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
