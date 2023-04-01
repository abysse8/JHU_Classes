clear
load ActiveSonar.mat
load ReceivedSignal1.mat
global bipolar_method;
global plot_things;
global samp_per_second
samp_per_second = 100;
%% HYPERPARAMETERS
use_fake_message = true; %test with fake or real code
real_message = "ReceivedSignal"; %ReceivedSignal or SonarEcho string
plot_things = true;

% For fake messages only
% fake message either in the form [0 1 1 0 0 0 1]
% or bitstring2arr(string2bitstring('string like this'))

string_to_check = 'mic check mic check'
fake_message = bitstring2arr(string2bitstring(string_to_check));

% 's' for sinusoidal, 'q' for square, 't' for triangle, 'w' for whatever the last
% one is supposed to be
code_type = 'w';
noise_factor = 0;
to_iterate = ['s', 'q', 't', 'w'];
accuracy_thresholds = []
while length(to_iterate) > 0
    for iii=1:length(to_iterate)
        code_type=to_iterate(iii);
        code = get_code(code_type);
        bipolar_method = bipolar_lookup(code_type);
        message = flatten(makemessage(fake_message, code));
        noise = noise_factor*randn(length(message), 1);
        message = message+noise;
        if decode(message, code) ~= string_to_check
            accuracy_thresholds(iii) = noise_factor
            to_iterate = to_iterate(to_iterate~=code_type);
        end
    end
    noise_factor = noise_factor+0.1;
end
%% SUPERPARAMETER AUTOMATIC SETUP
if use_fake_message
        code = get_code(code_type);
        bipolar_method = bipolar_lookup(code_type);
        message = flatten(makemessage(fake_message, code));
        noise = noise_factor*randn(length(message), 1);
        message = message+noise;
elseif ~use_fake_message %use recorded files
    if real_message == "ReceivedSignal"
        code = [0:1/samp_per_sec:duration];
        bipolar_method = 'i';
        message = ReceivedSignal;
    elseif real_message == "SonarEcho"
        code = SonarPing;
        bipolar_method = 'f';
        message = SonarEcho;
    end
end
%% RUN: Plots message, convolved, and reconstructed
decode(message, code);

%% Decoded
function reconstructed = decode(message, code)
    global plot_things;
    if plot_things
        s1 = subplot(1, 3, 1); subtitle("Received Signal");
        plot(message); xlim([0 length(message)])
    end

    convolved = convolve(flatten(message), code);
    if plot_things
        s2 = subplot(1, 3, 2);
        plot(convolved); xlim([0 length(message)]);
    end

    evaled = evaluate(convolved, code);
    translated = evaled(1:length(evaled)-1);
    received_index = evaled(end);
    if plot_things
        s3 = subplot(1, 3, 3);
        plot(flatten(makemessage(translated, code))); xlim([0 length(message)]);
    end
    disp("Translated:"); 
    reconstructed = translatebitstring(translated);
    disp(reconstructed);
    
    distance = getdistance(received_index);
    disp("Distance:"); disp(distance);
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
    thresh_level = 0;
    inputs = pad(inputs, code);
    m = find(inputs>thresh_level);
    m = m(1);
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
            bitstring(iii) = nan;
        end
    end
    bitstring = [bitstring m];
end

function message = translatebitstring(raw_bitstring)
    %take bitstring from evaluate method and return letter message
    sentences = string(reshape(raw_bitstring, [8, length(raw_bitstring)/8]));
    sentences = sentences(2:end, :).';
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
        the_code = [0:1/samp_per_second:0.5];
    elseif code_type == 's'
        the_code = sin((2*pi/0.5)*[0:1/samp_per_second:0.5]);
    elseif code_type == 'q'
        the_code = ones(1, samp_per_second);
    elseif code_type == 'w'
        tb = ones(1, samp_per_second/10);
        thb = ones(1, samp_per_second/20);
        ths = zeros(1, samp_per_second/20);
        the_code = [tb ths thb ths tb tb ths thb ths tb tb ths thb ths thb]; 
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