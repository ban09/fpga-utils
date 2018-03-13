FLAGS=-O2 -Wall

all: fir fir_poly compare

fir:fir.c
	gcc $(FLAGS) -g fir.c -o fir
fir_poly:fir_poly.c
	gcc $(FLAGS) fir_poly.c -o fir_poly

.PHONY:compare clean
compare:
	sh compare.sh
clean:
	rm -f fir fir_poly out_fir out_poly
    
