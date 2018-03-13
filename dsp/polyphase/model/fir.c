#include <stdio.h>
#include <stdint.h>
#include <string.h>

#define ROUND 0
#define COEFF_SCALING (14) 

#define TEST_DATA_SIZE 9000000

/* NOTE it won't work if NCOEFFS/DECIMATING_FACTOR is not an integer */
#define DECIMATING_FACTOR 3
#define NCOEFFS 9
//int64_t coeffs[NCOEFFS] = {1 ,3 ,6 ,8 ,10 ,11 ,12 ,10 ,7 ,3 ,
//           -3 ,-11 ,-20 ,-28 ,-36 ,-40 ,-41 ,-36 ,-26 ,-10 ,
//            11 ,35 ,61 ,85 ,104 ,114 ,113 ,98 ,69 ,26 ,
//            -28 ,-91 ,-156 ,-216 ,-263 ,-290 ,-288 ,-253 ,-181 ,-69 ,
//            78 ,259 ,465 ,685 ,908 ,1120 ,1309 ,1462 ,1571 ,1627 ,
//            1627 ,1571 ,1462 ,1309 ,1120 ,908 ,685 ,465 ,259 ,78 ,
//            -69 ,-181 ,-253 ,-288 ,-290 ,-263 ,-216 ,-156 ,-91 ,-28 ,
//            26 ,69 ,98 ,113 ,114 ,104 ,85 ,61 ,35 ,11 ,
//            -10 ,-26 ,-36 ,-41 ,-40 ,-36 ,-28 ,-20 ,-11 ,-3 ,
//            3 ,7 ,10 ,12 ,11 ,10 ,8 ,6 ,3 ,1};

//int64_t COEFFS[10][10] = { {1, -3, 11, -28, 78, 1627, -69, 26, -10, 3},
//    {3, -11, 35, -91, 259, 1571, -181, 69, -26, 7},
//    {6, -20, 61, -156, 465, 1462, -253, 98, -36, 10},
//    {8, -28, 85, -216, 685, 1309, -288, 113, -41, 12},
//    {10, -36, 104, -263, 908, 1120, -290, 114, -40, 11},
//    {11, -40, 114, -290, 1120, 908, -263, 104, -36, 10},
//    {12, -41, 113, -288, 1309, 685, -216, 85, -28, 8},
//    {10, -36, 98, -253, 1462, 465, -156, 61, -20, 6},
//    {7, -26, 69, -181, 1571, 259, -91, 35, -11, 3},
//    {3, -10, 26, -69, 1627, 78, -28, 11, -3, 1}
//};

int COEFFS[9] =  {-95,0,1286,4121,5759,4121,1286,0,-95};
                       
                 


int8_t buf[TEST_DATA_SIZE];

int main(char argc, char **argv){

    int n;
    int p = 0;
    int acc = 0;
    int8_t res = 0;
    int8_t samples[9];
    memset(samples,0,NCOEFFS);
    int firstsample=1;

    while((n=fread(buf+p,1,1024,stdin))>0){
        p+=n;
    }
    fprintf(stderr,"Got %d bytes\n",p);


    for(int i = 0;i<p;i++){
        memcpy(samples+1,samples,NCOEFFS-1);
        samples[0] = buf[i];
        acc = 0;
        if ( ((i+1)%3)==0 ){
            acc=0;
            for(int j = 0; j<9; j++){
                acc+=samples[j]*COEFFS[j];
            }
        
#if ROUND == 0
        res = (int8_t)(acc>>COEFF_SCALING);
#else
        res = (int8_t)( (acc>>COEFF_SCALING)+(acc&(1<<(COEFF_SCALING-1))>>(COEFF_SCALING-1)) );
#endif
        fwrite(&res,1,1,stdout);
        }  
        firstsample=0;
    }
    return 0;
}
