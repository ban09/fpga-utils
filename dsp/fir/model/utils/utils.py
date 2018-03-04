import numpy as np
def osfft (x, fs):
    xfft = np.abs(np.fft.fft(x))/len(x)
    xfft = xfft[0:int(len(x)/2-1)]
    #xfft = 20*np.log10(xfft)
    w = np.arange(0,len(xfft))*(fs/len(xfft)/2)/1e6
    return w,xfft

