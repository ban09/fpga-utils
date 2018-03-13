FLAGS=-O2 -Wall

all: fir fir_poly compare

fir:
	gcc $(FLAGS) fir.c -o fir
fir_poly:
	gcc $(FLAGS) fir_poly.c -o fir_poly
.PHONY:compare clean
compare:
	sh compare.sh
clean:
	rm -f fir fir_poly out_fir out_poly
    
