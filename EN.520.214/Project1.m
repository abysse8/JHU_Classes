load ActiveSonar.mat
load ReceivedSignal1.mat
%%
code = SonarPing;


%subplot(1, 2, 1);
%plot(flatten(custom));

%message = ReceivedSignal;
subplot(1, 3, 1);
to_decode = [1 nan 0 1 1 0 nan];
message = flatten(makemessage(to_decode, code));
plot(message);

subplot(1, 3, 2);
convolved = convolve(message, code);
plot(convolved);

subplot(1, 3, 3);
translated = evaluate(convolved, code);
plot(flatten(makemessage(translated, code)));


function bitstring = evaluate(input, code)
    threshold = 0.75;
    thresh_level = 0.5*max(abs(input));

    input = pad(input, code);

    dim = size(input);
    delim = floor(dim(1)/2);
    input = reshape(input, [length(code), dim(2)/length(code)]);
    
    dim = size(input);
    delim = floor(dim(1)/2);
    bitstring = [];
    for itr=1:dim(2)
        if ~( any(abs(input(:, itr)) > thresh_level))
            bitstring = [bitstring nan];
            continue
        end
        first_half = mode(sign(input(delim:end, itr)));
        second_half = mode(sign(input(1:delim, itr)));
        if first_half ~= second_half
            bitstring = [bitstring first_half];
            continue
        end
        bitstring = [bitstring nan];
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
    input = flatten(input); code = flatten(code);
    convolved = conv(input, code);
    crp = floor(length(code)/2);
    convolved = convolved(crp:length(convolved)-crp);
end

function flattened = flatten(input)
    dim = size(input);
    flattened = reshape(input, [dim(1)*dim(2), 1]);
end

function custom_message = makemessage(input, code)
    custom_message = zeros(length(code), length(input));
    zero_one = [code.', fliplr(code).'];
    for iii=1:length(input)
        if isnan(input(iii))
            custom_message(:, iii) = zeros( [length(code), 1] );
            continue
        end
        custom_message(:, iii) = zero_one(:, input(iii)+1);
    end
end