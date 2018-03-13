import numpy as np
import matplotlib.pyplot as plt
from scipy import signal
import io
import utils.utils as utils

data = np.fromfile("test_data","int8",90000);
print(data[0:15])
x1 = np.fromfile("out_poly","int8",90000*10);
x2 = np.fromfile("out_fir","int8",90000*10);

w,fft1=utils.osfft(x1,90e6/3)
w,fft2=utils.osfft(x2,90e6/3)
plt.plot(w,fft1,'ro')
plt.plot(w,fft2,'bx')
plt.show()
