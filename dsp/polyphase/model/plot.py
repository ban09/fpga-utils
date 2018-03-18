import numpy as np
import matplotlib.pyplot as plt
from scipy import signal
import io
import utils.utils as utils

length = int((90000/3)*9)
x1 = np.fromfile("out_poly","int8",length);
x2 = np.fromfile("out_fir","int8",length);
#x3 = np.fromfile("out_fpga","int8",length);

w,fft1=utils.osfft(x1,90e6/10)
w,fft2=utils.osfft(x2,90e6/10)
#w,fft3=utils.osfft(x3,90e6/10)
plt.plot(w,fft1,'ro')
plt.plot(w,fft2,'bx')
#plt.plot(w,fft3,'gx')
plt.show()
