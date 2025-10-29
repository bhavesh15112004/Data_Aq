%% Read data
data = readtable('scope_4.csv','NumHeaderLines',1);   % adjust filename
t = data.second(:);        % time (s)
v = data.Volt(:);          % voltage

%% Sampling checks
dt = diff(t);
dt_mean = mean(dt);
if any(~isfinite(dt)) || abs(dt_mean) == 0
    error('Time column invalid or constant. FFT/filtering need uniform, increasing time samples.');
end
Fs = 1/dt_mean;            % sampling freq (Hz)
N  = numel(v);

%% Design a 50 Hz notch (IIR)
f0 = 50;                   % notch center (Hz)
Q  = 20;                   % quality factor (higher -> narrower notch)
wo = f0/(Fs/2);            % normalized freq
[b,a] = iirnotch(wo, wo/Q);

%% Zero-phase filtering
v_filt = filtfilt(b,a,v);

%% FFTs
f = (-N/2:N/2-1)*(Fs/N);
V_mag  = abs(fftshift(fft(v)))/N;
Vf_mag = abs(fftshift(fft(v_filt)))/N;

%% Plots
figure;

% 1) Raw time domain
subplot(4,1,1)
plot(t, v, 'b','LineWidth',1);
xlabel('Time (s)'); ylabel('V');
title('Raw Signal (Time Domain)');
grid on;

% 2) Filtered time domain
subplot(4,1,2)
plot(t, v_filt, 'r','LineWidth',1);
xlabel('Time (s)'); ylabel('V');
title('Filtered Signal (Time Domain, 50 Hz Notched)');
grid on;

% 3) Raw FFT
subplot(4,1,3)
plot(f, V_mag, 'b','LineWidth',1);
xlim([-5*f0 5*f0]); % zoom near 0–250 Hz region
xlabel('Frequency (Hz)'); ylabel('|V(f)|');
title('FFT of Raw Signal');
grid on;

% 4) Filtered FFT
subplot(4,1,4)
plot(f, Vf_mag, 'r','LineWidth',1);
xlim([-5*f0 5*f0]);
xlabel('Frequency (Hz)'); ylabel('|V(f)|');
title('FFT of Filtered Signal');
grid on;
