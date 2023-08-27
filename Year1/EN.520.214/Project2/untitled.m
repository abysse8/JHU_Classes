function [seq, fs] = DTMFsequence(filename) 
    [y,fs] = audioread(filename);
    keys = ['1', '2', '3', '4', '5', '6', '7', '8', '9', '*', '0','#'];
    lows = [697,  697, 697, 770, 770, 770, 852, 852, 852, 941, 941, 941];
    highs = [1209,1336,1477,1209,1336,1477,1209,1336,1477,1209,1336,1477];
    sound(y,fs)
    batch_size = 50;
    step = floor(length(y)/batch_size);
    energies = zeros(1, batch_size);
    
    %Get envelope of key strokes by averaging over large steps
    for s=1:step:length(y)
        energies(ceil(s/step)) = mean(y(s:min(s+step, length(y))).^2);
    end
    found = find(energies>0.5*max(energies));
    delim = 4;
    idxs_end = [];
    idxs_start = [found(1)];
    for iii=2:length(found)-1
        if found(iii)-found(iii-1) > delim
            idxs_start = [idxs_start found(iii)];
        end
        if found(iii+1)-found(iii) > delim
            idxs_end = [idxs_end found(iii)];
        end
    end
    
    idxs_end = [idxs_end found(end)];
    idxs_start = [idxs_start];
    split = zeros(max(idxs_end-idxs_start)*50,length(idxs_start));
    
    subplot(6,1,1)
    plot(y)
    seq = [];
    for jjj=1:length(idxs_start)
        subplot(6,1,jjj+1)
        range = floor(length(y)*idxs_start(jjj)/50):floor(length(y)*idxs_end(jjj)/50);
        ff = fft(y(range));
        P2 = abs(ff/length(y(range)));
        P1 = P2(1:ceil(length(y(range))/2));
        P1(2:end-1) = 2*P1(2:end-1);
        f = fs*(0:(length(y(range))/2))/length(y(range));
        plot(f,P1)
        energies = P1.^2;
        [dw, thou_hz_pos] = min(abs(f-1000));
        [foo, low_idx] = max(energies(1:thou_hz_pos));
        [foo, high_idx] = max(energies(thou_hz_pos:end));
        low_freq = f(low_idx)
        high_freq = 1000+f(high_idx)+dw
        [l, idx] = min(abs(lows-low_freq)+abs(highs-high_freq));
        seq = [seq keys(idx)];
    end
end