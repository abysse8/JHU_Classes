p0 = (1/2048).*[-5 0 49 0 -245 0 1225 2048 1225 0 -245 0 49 0 -5];

% Create modulated vector to get p(-z) by .*
mod = ones(1, length(p0));
for iii=2:2:length(p0)
    mod(iii) = -1;
end; clear iii;

%% Test for P0 halfband
de = p0-p0.*mod; %verify that this is all zeros except middle

[zero,pole,gain] = tf2zp(p0,eqtflength([1],p0));
zplane(zero, pole);
disp("Zeroes");disp(zero);

%% Choose H0 and F0 from previous zeros
% We arbitrarily choose H0 to hold the complex
% roots and 2 -1s, F0 to have the real roots
% and 4 -1s

H0_zeros = zero([2:3 4:5 11:13]);
F0_zeros = zero([1 14 6:10]);
H1_zeros = -1*F0_zeros
F1_zeros = -1*H0_zeros
H0 = zp2tf(H0_zeros, [], 1)
F0 = zp2tf(F0_zeros, [], 1)
H1 = zp2tf(H1_zeros, [], 1)
F1 = zp2tf(F1_zeros, [], 1)


