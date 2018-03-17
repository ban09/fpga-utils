#include <stdio.h>
#include <stdint.h>
#include <string.h>

#define STAGES (3)
#define TAPS (3)

/* TODO: Check coefficient distribution in the non-symmetric case */
//int coeff_tmp[STAGES][TAPS] = {
//    {3, -10, 26, -69, 1627, 78, -28, 11, -3, 1},
// {7, -26, 69, -181, 1571, 259, -91, 35, -11, 3},
// {10, -36, 98, -253, 1462, 465, -156, 61, -20, 6},
// {12, -41, 113, -288, 1309, 685, -216, 85, -28, 8},
// {11, -40, 114, -290, 1120, 908, -263, 104, -36, 10},
// {10, -36, 104, -263, 908, 1120, -290, 114, -40, 11},
// {8, -28, 85, -216, 685, 1309, -288, 113, -41, 12},
// {6, -20, 61, -156, 465, 1462, -253, 98, -36, 10},
// {3, -11, 35, -91, 259, 1571, -181, 69, -26, 7},
// {1, -3, 11, -28, 78, 1627, -69, 26, -10, 3}};
//int coeff_tmp[STAGES][TAPS] = {
//    {1286, 4121, -95},
//    {0, 5759, 0},
//    {-95, 4121, 1286}};
//
int coeff_tmp[STAGES][TAPS] = {
    {1286, 4121, 0},
    {0, 4121, 1286},
    {-95, 5759, -95}};

int main(){
    int8_t din = 0;
    int8_t res = 0;
    int coeff[TAPS];

    int idx = 2;
    int clk = -1;
    memset(coeff,0,STAGES*sizeof(int));

    int mul_in_tmp[STAGES];
    int mul_in[STAGES];

    int mul_tmp[STAGES];
    int mul[STAGES];

    int add_tmp[STAGES];
    int add[STAGES]; 

    memset(mul_in,0,STAGES*sizeof(int));
    memset(mul_in_tmp,0,STAGES*sizeof(int));
    memset(mul,0,STAGES*sizeof(int));
    memset(mul_tmp,0,STAGES*sizeof(int));
    memset(add,0,STAGES*sizeof(int));
    memset(add_tmp,0,STAGES*sizeof(int));

    int fifo[STAGES-1][STAGES+1];
    memset(fifo,0,(STAGES-1)*(STAGES+1)*sizeof(int));

    int out_acc = 0;
    int out_acc_tmp = 0;

    FILE *fin = fopen("test_data","rb");
    while(fread(&din,1,1,fin)>0){
            for(int i = 0; i < STAGES; i++){
                if(i == 0){
                    mul_in_tmp[i] = (int)din;
                }
                else{
                    mul_in_tmp[i] = fifo[i-1][STAGES];
                }
            }
            for(int i = 0; i < STAGES; i++){
                /* Probably the efficient way to address the adressing problem in 
                 * hardware is to rearrange the coefficients to account for 
                 * the pipeline.*/
//                mul_tmp[i] = mul_in[i]*coeff_tmp[((((idx-(STAGES+1)*i)%TAPS)+TAPS)%TAPS)][i];
                mul_tmp[i] = mul_in[i]*coeff_tmp[idx][i];
                if (i == 0){
                    add_tmp[i] = mul[i]; 
                }
                else{
                    add_tmp[i] = add[i-1]+mul[i];
                }
            }
            if ( idx == 1 ){
                res = (int8_t)(out_acc >> 14); 
                fwrite(&res,1,1,stdout);
                out_acc_tmp = add[STAGES-1]; 
            }
            else{
                out_acc_tmp = out_acc + add[STAGES-1];
            }

            // Update 
            for(int i = 0; i < STAGES-1; i++){
                int fifo_tmp[STAGES+1];
                memcpy(fifo_tmp,fifo[i],(STAGES+1)*sizeof(int));
                for(int j = 1; j < STAGES+1; j++){
                    fifo[i][j] = fifo_tmp[j-1];
                }
            }
            for(int i = 0; i < STAGES-1; i++){
                fifo[i][0] = mul_in_tmp[i];
            }
            memcpy(mul_in, mul_in_tmp, STAGES*sizeof(int));

            if(++idx > TAPS-1){
                idx = 0;
            }
            memcpy(coeff,coeff_tmp[idx],STAGES*sizeof(int));
            memcpy(mul,mul_tmp,STAGES*sizeof(int));
            memcpy(add,add_tmp,STAGES*sizeof(int));
            out_acc = out_acc_tmp;

            clk++;
        }
    return 0;
}
