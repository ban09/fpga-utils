#include <stdio.h>
#include <stdint.h>
#include <string.h>

#define ROUND 1
#define COEFF_SCALING (14) 

#define DECIMATION_FACTOR 10
#define NCOEFF 10

#define TEST_DATA_SIZE 9000000

int64_t coeffs[DECIMATION_FACTOR][NCOEFF] = 
  { {1, -3, 11, -28, 78, 1627, -69, 26, -10, 3},
    {3, -11, 35, -91, 259, 1571, -181, 69, -26, 7},
    {6, -20, 61, -156, 465, 1462, -253, 98, -36, 10},
    {8, -28, 85, -216, 685, 1309, -288, 113, -41, 12},
    {10, -36, 104, -263, 908, 1120, -290, 114, -40, 11},
    {11, -40, 114, -290, 1120, 908, -263, 104, -36, 10},
    {12, -41, 113, -288, 1309, 685, -216, 85, -28, 8},
    {10, -36, 98, -253, 1462, 465, -156, 61, -20, 6},
    {7, -26, 69, -181, 1571, 259, -91, 35, -11, 3},
    {3, -10, 26, -69, 1627, 78, -28, 11, -3, 1}};

int8_t buf[TEST_DATA_SIZE];

void fir_poly_behav(FILE *fin, FILE *fout);

int main(){

//    fir_poly_behav(stdin, stdout);   
    int n = 0;
    int p = 0;
    int8_t res;
    int64_t acc;
    FILE *txt=fopen("out.txt","w");
    while((n=fread(buf+p,1,1,stdin))>0){
        p+=n;
    }

    fprintf(stderr,"Got %d bytes\n",p);

    for(int k = 0; k<p; k+=DECIMATION_FACTOR){
        acc = 0;
        for(int i = 0; i < NCOEFF; i++){
                for(int j = 0; j < DECIMATION_FACTOR; j++){
                    acc += coeffs[j][i]*(int64_t)buf[k+i*NCOEFF+j];
                }
        }
#if ROUND == 0
        res = (int8_t)(acc>>COEFF_SCALING);
#else
        res = (int8_t)( (acc>>COEFF_SCALING)+(acc&(1<<(COEFF_SCALING-1))>>(COEFF_SCALING-1)) );
#endif
        fwrite(&res,sizeof(int8_t),1,stdout);
    }
    return 0;

}

