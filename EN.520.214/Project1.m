load ActiveSonar.mat
load ReceivedSignal1.mat
%% PARAMETERS
code = SonarPing;
to_plot = true;
use_fake_code = false; %test with fake or real code

global threshold; global bounds;
threshold = 0.75; %percentage of max amplitude to be allowed in batch
bounds = 0.25; %parametrizes how close to middle to evaluate signal

to_decode = [1 0];
if use_fake_code
    message = flatten(makemessage(to_decode, code));
else
    message = SonarEcho;
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
    plot(convolved); xlim([0 length(message)])
end

translated = evaluate(convolved, code);
if to_plot
    s3 = subplot(1, 3, 3);
    plot(flatten(makemessage(translated, code))); xlim([0 length(message)])
end
disp("Translated:"); disp(translated);


function bitstring = evaluate(input, code)
    global threshold; global bounds;
    r = threshold; x = bounds;
    thresh_level = r*max(abs(input));

    input = pad(input, code);

    dim = size(input);
    input = reshape(input, [length(code), dim(2)/length(code)]);

    dim = size(input);
    halfway = floor(dim(1)/2);
    delim = floor(dim(1)*bounds);
    bitstring = [];
    for itr=1:dim(2)
        if ~( any(abs(input(:, itr)) > thresh_level))
            bitstring = [bitstring nan];
            continue
        end
        %first_half = mode(sign(input(delim:end, itr)));
        %second_half = mode(sign(input(1:delim, itr)));
        %if first_half ~= second_half
        %    bitstring = [bitstring first_half];
        %    continue
        %end
        bitstring = [bitstring mode(sign(input(halfway-delim:halfway+delim, itr)))];
    end
    bitstring = zerofy(bitstring);
end

function zerofied = zerofy(input)
    zerofied = (input+1)/2;
end

function padded = pad(signal, code)
    signal = flatten(signal);
    len_to_pad = length(code)- mod(length(signal), length(code));
    if mod(len_to_pad, length(code)) == 0
        padded = signal.';
        return
    end
    before_pad = zeros(1, floor(len_to_pad/2));
    after_pad = zeros(1, len_to_pad-floor(len_to_pad/2));
    padded = [before_pad signal.' after_pad];
end

function convolved = convolve(input, code)
    %turn to vectors
    input = flatten(input); code = flatten(fliplr(code));
    convolved = conv(input, code, 'same');
end

function flattened = flatten(input)
    dim = size(input);
    flattened = reshape(input, [dim(1)*dim(2), 1]);
end

function custom_message = makemessage(input, code)
    custom_message = zeros([length(code), length(input)]);
    zero_one = [code.', fliplr(code).'];
    for iii=1:length(input)
        if isnan(input(iii))
            custom_message(:, iii) = zeros( [length(code), 1] );
            continue
        end
        custom_message(:, iii) = zero_one(:, input(iii)+1);
    end
end