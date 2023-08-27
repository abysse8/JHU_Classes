for iii=1:50
    num_digits = randi([1,10],1);
    weights = randi([1,5],[1,2]);
    duration = randi([1,500])/100;
    FS = randi([3000,30000]);
    keys = ['1', '2', '3', '4', '5', '6', '7', '8', '9', '*', '0','#'];
    lows = [697,  697, 697, 770, 770, 770, 852, 852, 852, 941, 941, 941];
    highs = [1209,1336,1477,1209,1336,1477,1209,1336,1477,1209,1336,1477];
    result = string(keys(randi(12,[1,num_digits])))
    [y, fs] = DTMFencode(result, duration, weights, FS);
    audiowrite(strcat("./wav files/",string(iii), "_", result, ".wav"), y, fs);
end