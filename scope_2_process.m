% Read CSV file (skip first header row)
data = readtable('scope_3.csv','NumHeaderLines',1);

% Extract columns
t = data.second;      % time (x-axis)
v = data.Volt;        % voltage (y-axis)

% --- FFT with fftshift ---
N  = length(v);            % number of samples
dt = mean(diff(t));        % time step (s)
Fs = 1/dt;                 % sampling frequency
f  = (-N/2:N/2-1)*(Fs/N);  % frequency axis (centered at 0)

V = fft(v);                % FFT
V_shift = fftshift(V);     % shift zero-freq to center
magV = abs(V_shift)/N;     % normalize magnitude

% Plot
figure;
plot(f, magV,'r','LineWidth',1.5);
xlabel('Frequency (Hz)');
ylabel('Magnitude');
title('FFT of Voltage Signal (fftshift)');
grid on;


figure;
plot(t,v);
xlabel('time');
ylabel('signal in volt');
title('time vs signal');
grid on;

