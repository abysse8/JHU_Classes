function [seq, fs] = DTMFsequence(filename)
    [y,fs] = audioread(filename);
    sound(y,fs)

    keys = ['1', '2', '3', '4', '5', '6', '7', '8', '9', '*', '0','#'];
    lows = [697,  697, 697, 770, 770, 770, 852, 852, 852, 941, 941, 941];
    highs = [1209,1336,1477,1209,1336,1477,1209,1336,1477,1209,1336,1477];
    batch_size = 50;


    energies = zeros(1, batch_size);
    %Get envelope of key strokes by averaging over large steps
    step = floor(length(y)/batch_size);
    for s=1:step:length(y)
        energies(ceil(s/step)) = mean(y(s:min(s+step, length(y))).^2);
    end
    energies = energies-min(energies);
    p2 = energies;
    found = find(energies>0.1*max(energies));
    delim = 1;
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
    %quick fix in case mismatch between indices- split not found
    if length(idxs_end) ~= length(idxs_start)
        idxs_end = [idxs_end zeros(1,length(idxs_end-length(idxs_start)))+batch_size]
    end

    seq = [];
    for jjj=1:length(idxs_start)
        range = floor(length(y)*idxs_start(jjj)/50):floor(length(y)*idxs_end(jjj)/50);
        ff = fft(y(range));
        P2 = abs(ff/length(y(range)));
        P1 = P2(1:ceil(length(y(range))/2));
        P1(2:end-1) = 2*P1(2:end-1);
        f = fs*(0:(floor(length(y(range))/2)))/length(y(range));
        energies = P1.^2;
        [dw, thou_hz_pos] = min(abs(f-1000));
        [foo, low_idx] = max(energies(1:thou_hz_pos));
        [foo, high_idx] = max(energies(thou_hz_pos:end));
        low_freq = f(low_idx);
        high_freq = 1000+f(high_idx)+dw;
        [l, idx] = min(abs(lows-low_freq)+abs(highs-high_freq));
        seq = [seq keys(idx)];
    end
    %% PLOT TIME AND FREQ DOMAIN
    subplot(3,1,1); plot(y);
    title("Time domain representation of dtmf")
    xlabel("Time (s)"); ylabel("Amplitude (intensity)")

    subplot(3,1,2); plot(1:length(y)/length(p2):length(y),p2);
    title("Envelope of signal")
    xlabel("Time"); ylabel("Dimensionless");

    subplot(3,1,3);
    y = y(floor(length(y)*idxs_start(1)/50):floor(length(y)*idxs_end(1)/50));
    ff = fft(y);
    P2 = abs(ff/length(y));
    P1 = P2(1:floor(length(y)/2)+1);
    P1(2:end-1) = 2*P1(2:end-1);
    f = fs*(0:floor((length(y)/2)))/length(y);
    plot(f,P1)
    title("Fourier domain of first split");
    xlabel("Frequency (Hz)"); ylabel("Component intensity")
end