function [digit, fs] = DTMFdecode(filename)
    [y, fs] = audioread(filename);
    ff = fft(y);
    keys = ['1', '2', '3', '4', '5', '6', '7', '8', '9', '*', '0','#'];
    lows = [697,  697, 697, 770, 770, 770, 852, 852, 852, 941, 941, 941];
    highs = [1209,1336,1477,1209,1336,1477,1209,1336,1477,1209,1336,1477];
    P2 = abs(ff/length(y));
    P1 = P2(1:length(y)/2+1);
    P1(2:end-1) = 2*P1(2:end-1);
    f = fs*(0:(length(y)/2))/length(y);
    subplot(2,1,1);
    plot(f,P1)
    
    energies = P1.^2;
    [dw, thou_hz_pos] = min(abs(f-1000));
    low_threshold = 0.9*max(energies(1:thou_hz_pos));
    high_threshold = 0.9*max(energies(thou_hz_pos:end));
    idxs_low = f(energies(1:thou_hz_pos)>low_threshold);
    idxs_high = 1000+f(energies(thou_hz_pos:end)>high_threshold);
    running_min = inf;
    idx = [];
    for iii=1:length(idxs_low)
        for jjj=1:length(idxs_high)
            [m, i] = min(abs(lows-idxs_low(iii))+abs(highs-idxs_high(jjj)));
            if m<running_min
                idx = i;
            end
        end
    end
    digit =keys(idx);
end