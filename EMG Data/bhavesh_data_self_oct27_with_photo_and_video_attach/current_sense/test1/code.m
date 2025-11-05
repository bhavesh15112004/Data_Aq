% Given values
R = 830e3;      % 830 kΩ
C = 1e-6;      % 10 µF

% Frequency range (log scale)
f = logspace(0, 6, 1000);   % from 1 Hz to 1 MHz
w = 2*pi*f;                 % angular frequency

% Transfer function: H(jw) = j*w*R*C / (1 + j*w*R*C)
H = 1j*w*R*C ./ (1 + 1j*w*R*C);

% Magnitude in dB and Phase in degrees
mag = 20*log10(abs(H));
phase = angle(H)*180/pi;

% Cutoff frequency
fc = 1 / (2*pi*R*C);
fprintf('Cutoff frequency (fc) = %.4f Hz\n', fc);

% Plot magnitude
figure;
subplot(2,1,1);
semilogx(f, mag, 'LineWidth', 2);
grid on;
xlabel('Frequency (Hz)');
ylabel('Magnitude (dB)');
title('Bode Plot of H(s) = sRC / (1 + sRC)');
hold on;
xline(fc, '--r', sprintf('f_c = %.2f Hz', fc), 'LabelOrientation', 'horizontal', 'LabelVerticalAlignment', 'bottom');

% Plot phase
subplot(2,1,2);
semilogx(f, phase, 'LineWidth', 2);
grid on;
xlabel('Frequency (Hz)');
ylabel('Phase (degrees)');
hold on;
xline(fc, '--r');
