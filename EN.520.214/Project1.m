load ActiveSonar.mat
load ReceivedSignal1.mat
%% PARAMETERS
code = maketriangle(0.5, 100);
to_plot = true;
use_fake_code = true; %test with fake or real code
noise_factor = 0;
global bipolar_method;
bipolar_method = 'i'; %invert or flip

global threshold; global bounds;
threshold = 0.3; %percentage of max amplitude to be allowed in batch

to_decode = [0 1 1 0 0 0 1];
if use_fake_code
    message = flatten(makemessage(to_decode, code));
    noise = noise_factor*randn(length(message), 1);
    message = message+noise;
else
    message = ReceivedSignal;
end
%%
if exist("s1")
    delete(s1); delete(s2); delete(s3);
end

if to_plot
    s1 = subplot(1, 3, 1); subtitle("Received Signal")
    plot(message); xlim([0 length(message)])
end

convolved = convolve(flatten(message), code);
if to_plot
    s2 = subplot(1, 3, 2);
    plot(convolved); xlim([0 length(message)]);
end
plot(convolved)

evaled = evaluate(convolved, code);
translated = evaled(1:length(evaled)-1);
received_index = evaled(end);
if to_plot
    s3 = subplot(1, 3, 3);
    plot(flatten(makemessage(translated, code))); xlim([0 length(message)]);
end
disp("Translated:"); disp(translated);

distance = getdistance(received_index);
disp("Distance:"); disp(distance);

function inverted = invertmessage(message)
    global bipolar_method;
    if bipolar_method == 'i'
        inverted = -message;
    elseif bipolar_method == 'f'
        inverted = fliplr(message);
    end
end

function triangle = maketriangle(duration, samp_per_sec)
    triangle = [0:1/samp_per_sec:duration];
end

function distance = getdistance(received_index)
    samples_per_second = 100;
    speed = 5000; %feet per second
    seconds_per_sample = 1/samples_per_second;
    time = received_index*seconds_per_sample;
    distance = time*speed;
end

function bitstring = evaluate(inputs, code)
    global threshold;
    thresh_level = threshold*max(abs(inputs));
    inputs = pad(inputs, code);
    m = find(inputs>thresh_level);
    m = m(1);
    dim = size(inputs);
    inputs = reshape(inputs, [length(code), dim(2)/length(code)])

    bitstring = zeros([1, dim(2)/length(code)]);
    halfway = floor(length(code)/2);
    for iii=1:length(bitstring)
        inputs(:, iii)
        inputs(halfway, iii)
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

function padded = pad(signal, code)
    signal = flatten(signal);
    len_to_pad = length(code)- mod(length(signal), length(code));
    if mod(len_to_pad, length(code)) == 0
        padded = signal.';
        return
    end
    padd = zeros(1, len_to_pad);
    padded = [signal.' padd];
end

function convolved = convolve(inputs, code)
    %turn to vectors
    inputs = flatten(inputs); code = flatten(fliplr(code));
    convolved = conv(inputs, code, 'same');
    inputs
    code
end

function flattened = flatten(inputs)
    dim = size(inputs);
    flattened = reshape(inputs, [dim(1)*dim(2), 1]);
end

function custom_message = makemessage(inputs, code)
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