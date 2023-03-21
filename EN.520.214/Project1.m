load ActiveSonar.mat
%%
code = SonarPing;
message = SonarEcho;

function custom_message = makemessage(input, code)
    custom_message = zeros(length(code), length(input));
    zero_one = [code.', fliplr(code).'];
    for iii=1:length(input)
        custom_message(:, iii) = zero_one(:, input(iii));
    end
end