%%
disp("Problem 1")
numerator = [2 16 44 56 32];
denominator = [3 3 -15 18 -12];
[zeroes, poles, gains] = tf2zp(numerator, denominator);
zplane(zeroes, poles)
grid
title('Problem 1 Poles and Zeros')
%fvtool(zp2sos(zeros, poles, gains))
% The outermost pole is located at z=-4 therefore 
% if the system is causal the ROC is |z|>4
%%
disp("Problem 3")
zeroes = [0.21 3.14 -0.3+0.5i -0.3-0.5i];
poles = [-0.45 0.67 0.81+0.72i 0.81-0.72i];
gain = [2.2];

[numerator, denominator] = zp2tf(zeroes', poles', gain');
disp(numerator); disp(denominator);
%%
disp("Problem 3")
numerator = [18 0 0 0];
denominator = [18 3 -4 -1];
[residues, poles, gains] = residuez(numerator, denominator);
disp(residues'); disp(poles'); disp(gains')
%%
disp("Problem 4")
zeroes = [0, -2];
poles = [0.2 -0.6];
gain = [1];
[numerator, denominator] = zp2tf(zeroes', poles', gain');
[coefficients] = impz(numerator, denominator, 11);
disp(coefficients')

delta_signal = [zeros(1,49), 1, zeros(1,49)];
impulse_response = filter(numerator, denominator, delta_signal);
plot(impulse_response);
title("Impulse Response")
%%
disp("Problem 5")
numerator = fliplr([0.008 -0.033 0.05 -0.033 0.008]);
denominator = fliplr([1 2.37 2.7 1.6 0.41]);
gain = [1];

[magnitudes, angles] = freqz(numerator, denominator, 1024, 'whole');
subplot(2,2,1);
plot(angles, real(magnitudes))
grid
title("Real part")

subplot(2,2,2);
plot(angles, imag(angles))
grid
title("Imaginary part")

subplot(2,2,3);
plot(angles, abs(magnitudes))
grid
title("Magnitude")

subplot(2,2,4);
plot(angles, angle(magnitudes))
grid
title("Phase Spectrum")
