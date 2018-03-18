import numpy as np
import matplotlib.pyplot as plt
from scipy import signal
import io

fs = 90e6
fc = 1.023e6
taps = 9
dec = 3
scaling = 2**14

b = signal.firwin(taps,fc/(fs/2))
bs = np.fix(b*scaling)

w,h = signal.freqz(b)
w,hs = signal.freqz(bs)

w = (w*fs/(2*np.pi))/1e6 # Frequency in MHz
plt.plot(w,20*np.log10(np.abs(h)))
plt.plot(w,20*np.log10(np.abs(hs)/scaling),'r')
#plt.show()

with open('fir_config.h','w') as f:
    f.write('#ifndef FIR_CONFIG \n#define FIR_CONFIG \n\n')
    f.write('#define NCOEFFS ({0})\n'.format(taps))
    f.write('#define DECIMATING_FACTOR ({0})\n'.format(dec))
    f.write('#define TAPS (NCOEFFS/DECIMATING_FACTOR)\n')
    f.write('#define STAGES DECIMATING_FACTOR \n')
    f.write('int fir_coeffs[TAPS] = {')
    i = 0;
    for coeff in np.nditer(bs):
        if (i%10)==0:
            f.write('\n')
        f.write('{0}, '.format(coeff.astype('int')))
        i=i+1

    f.write('};\n')
    bm = bs.reshape(int(taps/dec),int(taps/dec)).transpose()
    bp=np.zeros([int(taps/dec),int(taps/dec)])
    for i in range(int(taps/dec)):
        bp[i,:] = bm[int(taps/dec)-i-1,:]
    
    f.write('\nint poly_coeffs[{0}][{0}] = {{'.format(int(taps/dec)))
    for i in range(int(taps/dec)):
        f.write('{')
        for coeff in np.nditer(bp[i,:]):
            f.write('{0}, '.format(coeff.astype('int')))
        f.write('},\n')
    f.write('};\n')
    f.write('#endif\n')



print(bs)
print(bm)
print(bp)




