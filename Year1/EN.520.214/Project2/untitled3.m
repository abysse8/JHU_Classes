[y, fs] = DTMFencode('8');
ff = fft(y);
P2 = abs(ff/length(y));
P1 = P2(1:ceil(length(y)/2));
P1(2:end-1) = 2*P1(2:end-1);
f = fs*(0:(floor(length(y)/2)-1))/length(y);
subplot(2,1,1);
plot(f, P1)
title("Normal Digit 8"); xlabel("Frequency (Hz)"); ylabel("Prevalence (relative)")


[y, h, fs] = addreverb(y, fs, 5);
ff = fft(y);
P2 = abs(ff/length(y));
P3 = P2(1:ceil(length(y)/2));
P3(2:end-1) = 2*P3(2:end-1);
ffff = fs*(0:(floor(length(y)/2)-1))/length(y);
subplot(2,1,2);
plot(ffff, P3)
title("Reverb 5 digit 8"); xlabel("Frequency (Hz)"); ylabel("Prevalence (relative)")
