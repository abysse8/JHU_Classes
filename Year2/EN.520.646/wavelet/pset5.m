p0 = (1/2048)*[-5 0 49 0 -245 0 1225 2048 1225 0 -245 0 49 0 -5];
%p0 (time domain) is length 15
% therefore P0 (frequency) is a polynomial
% of degree 14, and has 14 zeros
[zero,pole,gain] = tf2zp(p0,eqtflength([1],p0));
zplane(zero, pole);
disp("Zeroes"); disp(zero);
% 1,14 is R group that must stay together
% 2, 3, 12, 13 is C group that must stay together to satisfy ortho
% Rest are -1's
H0_zeros = zero([1 14 4 11 5 6]);
H1_zeros = zero([2 3 7 8 9 10 12 13]);
F0_zeros = -1*H1_zeros;
F1_zeros = -1*H0_zeros;
H0 = zp2tf(H0_zeros, [1], 1); H0=H0/norm(H0);
F0 = zp2tf(F0_zeros, [1], 1); F0=F0/norm(F0);
H1 = zp2tf(H1_zeros, [1], 1); H1=H1/norm(H1);
F1 = -1*zp2tf(F1_zeros, [1], 1); F1=F1/norm(F1);
%subplot(2,2,1); plot(H0); subplot(2,2,2); plot(H1);
%subplot(2,2,3); plot(impz(H0)); 
PRtest(H0, H1, F0, F1);
 
out = idwt2d(dwt2d(x, H0, H1, 2), F0, F1, 2); image(out);
psnr(x, out);
