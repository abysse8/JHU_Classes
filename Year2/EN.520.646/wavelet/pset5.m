p0 = [-5 0 49 0 -245 0 1225 2048 1225 0 -245 0 49 0 -5];
p0 = p0/norm(p0,2);
% Finding zeros using roots
zero = roots(p0);

% Since it's an FIR filter, all poles are at the origin
pole = zeros(length(p0) - 1, 1);

% Plotting the zeros on the z-plane
zplane(zero, pole);
disp("Zeroes"); disp(zero);
%%
% 1,14 is R group that must stay together
% 2, 3, 12, 13 is C group that must stay together to satisfy ortho
% Rest are -1's
H0_zeros = zero([1 2 3 5 6 7 8]);
H1_zeros = zero([14 13 12 10 9 4 11]);
H0_zeros
F0_zeros = -1*H1_zeros;
F1_zeros = -1*H0_zeros;
H0 = zp2tf(H0_zeros, [], 1); H0=H0/norm(H0); disp(H0);disp(norm(H0,2));
F0 = zp2tf(F0_zeros, [], 1); F0=F0/norm(F0);
H1 = zp2tf(H1_zeros, [], 1); H1=H1/norm(H1);
F1 = -1*zp2tf(F1_zeros, [], 1); F1=F1/norm(F1);
%subplot(2,2,1); plot(H0); subplot(2,2,2); plot(H1);
%subplot(2,2,3); plot(impz(H0)); 
PRtest(H0, H1, F0, F1);

%out = idwt2d(dwt2d(x, H0, H1, 2), F0, F1, 2); image(out);
%psnr(x, out);
out = dwt2d(x, H0, H1, 4);
image(out)
%%
threshold = prctile(out, 0.999999);
out(out<threshold) = 0;
out = reshape(out, [512,512]);
out = idwt2d(out, F0, F1, 2);
image(out)