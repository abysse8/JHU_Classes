function [x,fs] = DTMFencode(key,duration, weight, fs)
    arguments
       key char
       duration (1,1) = 0.2 
       weight (1,2) {mustBeNumeric} = [1,1]
       fs (1,1) {mustBeGreaterThanOrEqual(fs, 3000)} = 8000
    end
    keys = ['1', '2', '3', '4', '5', '6', '7', '8', '9', '*', '0', '#'];
    lows = [697, 697, 697, 770, 770, 770, 852, 852, 852, 941, 941, 941];
    highs = [1209, 1336, 1477, 1209, 1336, 1477, 1209, 1336, 1477, 1209, 1336, 1477];
    x_axis = [1/fs:1/fs:duration];
    x = []
    for iii=1:length(key)
        low_fre = lows(1, find(keys==key(iii)));
        high_fre = highs(1, find(keys==key(iii)));
        t1 = sin(x_axis*2*pi*low_fre);
        t2 = sin(x_axis*2*pi*high_fre);
        x = [x t1.*weight(1)+t2.*weight(2) zeros(1,fs)];
    end
end
