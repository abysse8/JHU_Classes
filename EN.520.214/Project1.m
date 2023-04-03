
%%Make sure to read mini-documentation at the beginning of the submitted
%%report!!! Guide to setting hyperparameters for all 3 parts.
clear
load ActiveSonar.mat
load ReceivedSignal1.mat
global bipolar_method;
global samp_per_second;
samp_per_second = 100;
global echo;
%% HYPERPARAMETERS- TO BE SET BY USER
use_fake_message = true; %test with fake or real code
real_message = "SonarEcho"; %ReceivedSignal or SonarEcho string
echo = false;
% make sure to set tolerance to 0 for parts II and III, otherwise the match
% filter criterion will be too strict. Set to 1 for part I
global tolerance; tolerance = 1;

% For fake messages/robustness check only
% fake message either in the form [0 1 1 0 0 0 1]
% or bitstring2arr(string2bitstring('string like this'))
string_to_check = 'mic check mic check';
fake_message = bitstring2arr(string2bitstring(string_to_check));
% 's' for sinusoidal, 'q' for square, 't' for triangle, 'w' for whatever the last
% one is supposed to be
code_type = 't';
to_analyse = ['s', 'q', 't', 'w'];
run_signal_comparison = false;

% ignore this for robustness check
noise_factor = 0.5;

%% SUPERPARAMETER AUTOMATIC SETUP
if use_fake_message
        code = get_code(code_type);
        bipolar_method = bipolar_lookup(code_type);
        message = flatten(makemessage(fake_message, code));
        noise = noise_factor*randn(length(message), 1);
        message = message+noise;
elseif ~use_fake_message %use recorded files
    if real_message == "ReceivedSignal"
        code = [0:1/samp_per_second:0.5];
        bipolar_method = 'i';
        message = ReceivedSignal;
    elseif real_message == "SonarEcho"
        code = SonarPing;
        bipolar_method = 'f';
        message = SonarEcho;
    end
    %message = message-mean(message);
end
%% RUN: Plots message, convolved, and reconstructed
decode(message, code, true);
if run_signal_comparison
    results = comparesignals(to_analyse, string_to_check);
    disp(results)
end
%show_codes(to_analyse); %%Uncomment to show original codes at the end

function null = show_codes(to_plot)
    global bipolar_method;
    for iii=1:length(to_plot)
        the_code = get_code(to_plot(iii));
        bipolar_method = bipolar_lookup(to_plot(iii));
        subplot(1, 4, iii); plot([the_code invertmessage(the_code)]);
        xlabel("Time (s)"); ylabel("Sound pressure (dB)");
    end
end

%% Decode
function reconstructed = decode(message, code, show_things)
    global echo; global use_fake_message;
    if show_things
        s1 = subplot(1, 3, 1);
        plot(message); xlim([0, length(message)]); subtitle("Received Signal");
        xlabel("Time (s)"); ylabel("Sound pressure (dB)");
    end

    convolved = convolve(flatten(message), code);
    if show_things
        s2 = subplot(1, 3, 2);
        plot(convolved); xlim([0,length(message)]); subtitle("Convolved");
        xlabel("Time (s)"); ylabel("Sound pressure (dB)");
    end

    evaled = evaluate(convolved, code);
    translated = evaled(1:length(evaled)-1);
    received_index = evaled(end);
    translated = pad(translated, zeros(1, 8));
    if show_things
        s3 = subplot(1, 3, 3); plot(flatten(makemessage(translated, code)));
        xlim([0,length(message)]); subtitle("Translated");
        xlabel("Time (s)"); ylabel("Sound pressure (dB)");
    end

    %if locating distance to object, show distance. else, attempt to
    %translate
    if (echo == true) && (use_fake_message == false)
        if show_things
            distance = getdistance(received_index);
            disp("Distance:"); disp(distance);
        end
    else
        reconstructed = translatebitstring(translated);
        if show_things
            disp("Translated:"); disp(reconstructed);
        end
    end
end

%% Robustness evaluator
function valuations=comparesignals(signals_to_compare, the_message)
    fake_message = bitstring2arr(string2bitstring(the_message));
    noise_factor = 0;
    to_iterate = signals_to_compare;
    ref = to_iterate;
    
    accuracy_thresholds = []
    while length(to_iterate) > 0
        new_to_iterate = to_iterate;
        for iii=1:length(to_iterate)
            code_type=to_iterate(iii);
            code = get_code(code_type);
            bipolar_method = bipolar_lookup(code_type);
            message = flatten(makemessage(fake_message, code));
            noise = noise_factor*randn(length(message), 1);
            message = message+noise;
            decoded = decode(message, code, false);
            disp([string(code_type) noise_factor ": " string(decoded) "; " string(any(decoded ~= the_message))])
            if any(decoded ~= the_message)
                accuracy_thresholds(find(code_type==ref)) = noise_factor;
                new_to_iterate = new_to_iterate(new_to_iterate~=code_type);
                continue;
            end
        end
        to_iterate = new_to_iterate;
        noise_factor = noise_factor+0.01;
    end
    valuations = [string(accuracy_thresholds)];
    for jjj=1:length(signals_to_compare)
        valuations(2,jjj) = signals_to_compare(jjj);
    end
end

%% PART 1 Helpers
function distance = getdistance(received_index)
    global samp_per_second
    speed = 5000; %feet per second
    seconds_per_sample = 1/samp_per_second;
    time = received_index*seconds_per_sample;
    distance = time*speed;
end

%% PART 2 Helpers
function convolved = convolve(inputs, code)
% Convolves the signal in the desired way
    inputs = flatten(inputs); code = flatten(fliplr(code));
    convolved = conv(inputs, code, 'same');
end

function bitstring = evaluate(inputs, code)
%Takes in convolved message and returns [translated_message] eg [1 0 0 1]
% **with index of first peak appended to the end**
    global tolerance; global echo;
    thresh_level = 0.3*max(abs(inputs));
    inputs = pad(inputs, code);

    if (echo==true)
        m = find(inputs>=tolerance*max(inputs));
        m = m(1);
    else
        m = 0;
    end

    dim = size(inputs);
    inputs = reshape(inputs, [length(code), dim(2)/length(code)]);

    bitstring = zeros([1, dim(2)/length(code)]);
    halfway = floor(length(code)/2);
    for iii=1:length(bitstring)
        if inputs(halfway, iii) > thresh_level
            bitstring(iii) = 1;
        elseif inputs(halfway, iii) < -thresh_level
            bitstring(iii) = 0;
        else
            bitstring(iii) = (max(inputs(:, iii))>-min(inputs(:, iii)));
        end
    end
    bitstring = [bitstring m];
end

function message = translatebitstring(raw_bitstring)
    %take bitstring from evaluate method and return letter message
    sentences = string(reshape(raw_bitstring, [8, length(raw_bitstring)/8]));
    sentences = sentences.';
    message = zeros(1, length(sentences(:, 1)));
    for iii=1:length(message)
        to_find = bin2dec(strjoin(sentences(iii,:), ''));
        message(1, iii) = char(to_find);
    end
    message = char(message);
end
%% Part 3 Helpers
function arr = bitstring2arr(i)
    arr = [];
    for iii=1:length(i)
        st = string(i(iii));
        st = char(st);
        if length(st) < 8
            padd = string(zeros(1, 8-length(st)));
            st = strjoin([padd string(st)], '');
        end
        for jjj=1:length(st)
            arr = [arr (char(st)=='1')];
        end
    end
end

function the_code = get_code(code_type)
    global samp_per_second;
    if code_type == 't'
        the_code = 2*[0:1/samp_per_second:0.49];
    elseif code_type == 's'
        the_code = sin((2*pi/0.5)*[0:1/samp_per_second:0.49]);
    elseif code_type == 'q'
        the_code = ones(1, samp_per_second/2);
    elseif code_type == 'w'
        tb = ones(1, samp_per_second/10);
        thb = ones(1, samp_per_second/20);
        ths = zeros(1, samp_per_second/20);
        the_code = [tb ths thb ths tb tb ths]; 
    end
end

function bip_method = bipolar_lookup(code_type)
    if code_type == 't'
        bip_method = 'i';
    elseif code_type == 's'
        bip_method = 'f';
    elseif code_type == 'q'
        bip_method = 'i';
    elseif code_type == 'w'
        bip_method = 'i';
    end
end

function custom_message = makemessage(inputs, code)
% Make amplitude-time message from [1 0 0 1]-type bitstring with given "1" code
    anticode = invertmessage(code);

    custom_message = zeros([length(code), length(inputs)]);
    zero_one = [anticode.', code.'];

    for iii=1:length(inputs)
        if isnan(inputs(iii))
            custom_message(:, iii) = zeros( [length(code), 1] );
            continue
        end
        custom_message(:, iii) = zero_one(:, inputs(iii)+1);
    end
end

%% General helpers

function flattened_array = flatten(inputs)
% Flattens a 2 dimensional input array
    dim = size(inputs);
    flattened_array = reshape(inputs, [dim(1)*dim(2), 1]);
end

function inverted_message = invertmessage(message)
% Takes in "1" ping and return "0" ping
    global bipolar_method;
    if bipolar_method == 'i'
        inverted_message = -message;
    elseif bipolar_method == 'f'
        inverted_message = fliplr(message);
    end
end

function cutted = cut(signal, code)
% Pads a signal with zeros to make its length integer multiple of given ping
    signal = flatten(signal);
    len_to_cut = mod(length(signal), length(code));
    if len_to_cut == 0
        cutted = signal.';
        return
    end
    cutted = signal(1:end-len_to_cut).';
end
function padded = pad(signal, code)
% Pads a signal with zeros to make its length integer multiple of given ping
    signal = flatten(signal);
    len_to_pad = length(code)- mod(length(signal), length(code));
    if mod(len_to_pad, length(code)) == 0
        padded = signal.';
        return
    end
    padd = zeros(1, len_to_pad);
    padded = [signal.' padd];
end

%% Timeout zone for bad functions: use char() and str2bin() instead!!!
%   ---unless we're using non-ascii, then these are good functions---

function bitstring = string2bitstring(my_string)
% Turns 'abcdef' to ["1101101" "01101010" ...]
    cod = fopen('ascii.code', 'r','s');
    c = textscan(cod, '%s%f32');
    c{1}(1) = {" :"};
    bitstring = [];
    for jjj=1:length(my_string)
        for iii=1:length(c{1})
            x = char(string(c{1}(iii)));
            if x(1) == my_string(jjj)
                bitstring = [bitstring c{2}(iii)];
            end
        end
    end
end

function outstring = bitstring2string(bitstring)
% Turns ["1101101" "01101010" ...] to 'abcdef
    cod = fopen('ascii.code', 'r','s');
    c = textscan(cod, '%s%f32');
    c{1}(1) = {" :"};
    outstring = [];
    bitstring = string(bitstring);
    for jjj=1:length(bitstring)
        for iii=1:length(c{1})
            x = string(c{2}(iii));
            if x == bitstring(jjj)
                out = string(c{1}(iii));
                to_char = char(out);
                outstring = [outstring to_char(1)];
            end
        end
    end
end