function digit = DTMFdecode(filename)
    [y, fs] = audioread(filename)
    ff = fft(y);
    keys = ['1', '2', '3', '4', '5', '6', '7', '8', '9', '*', '0','#'];
    lows = [697,  697, 697, 770, 770, 770, 852, 852, 852, 941, 941, 941];
    highs = [1209,1336,1477,1209,1336,1477,1209,1336,1477,1209,1336,1477];
    P2 = abs(ff/length(y));
    P1 = P2(1:length(y)/2+1);
    P1(2:end-1) = 2*P1(2:end-1);
    f = fs*(0:(length(y)/2))/length(y);
    plot(f,P1)
    energies = P1.^2;
    thou_hz_pos = find(f==1000);
    low_threshold = 0.9*max(energies(1:thou_hz_pos));
    high_threshold = 0.9*max(energies(thou_hz_pos:end));
    idxs = [f(energies(1:thou_hz_pos)>low_threshold),1000+f(energies(thou_hz_pos:end)>high_threshold)];
    [l, idx] = min(abs(lows-idxs(1))+abs(highs-idxs(2)));
    digit = keys(idx);
end