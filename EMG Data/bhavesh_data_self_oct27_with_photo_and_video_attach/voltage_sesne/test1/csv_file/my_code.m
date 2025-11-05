function fft_from_scope50_notch(filename)
% fft_from_scope50_notch - FFT analysis with 50 Hz notch + LPF

if nargin < 1
    % --- Auto file selector if filename not given ---
    [file, path] = uigetfile('*.csv', 'Select your CSV data file');
    if isequal(file,0)
        disp('❌ User cancelled file selection.');
        return;
    end
    filename = fullfile(path, file);
end

% --- Adjustable plot range ---
start_sample = 1;
end_sample   = 5000;

% --- Read data ---
data = readmatrix(filename);
t = data(:,1);
v = data(:,2);

% --- Validate ---
valid_idx = isfinite(t) & isfinite(v);
t = t(valid_idx);
v = v(valid_idx);

% --- Sampling rate ---
dt = median(diff(t));
Fs = 1 / dt;

% --- Interpolate to uniform grid ---
t_uniform = (0:(length(t)-1))' * dt + min(t);
v_uniform = interp1(t, v, t_uniform, 'pchip', 'extrap');

% --- Design filters ---
f_notch = 50;          % center frequency to remove
Q = 1;                 % quality factor
wo = f_notch / (Fs/2); % normalized frequency
bw = wo / Q;
[b_notch, a_notch] = iirnotch(wo, bw);

% Optional: 1000 Hz low-pass
[b_lp, a_lp] = butter(4, 1000/(Fs/2), 'low');

% --- Apply filters ---
v_notched  = filtfilt(b_notch, a_notch, v_uniform);
v_filtered = filtfilt(b_lp, a_lp, v_notched);

% --- Safe sample range ---
start_sample = max(1, start_sample);
end_sample   = min(length(t_uniform), end_sample);

% --- Time-domain plot ---
figure('Name','Time Domain (50 Hz Removed)');
plot(t_uniform(start_sample:end_sample), v_uniform(start_sample:end_sample), 'k', 'LineWidth', 1); hold on;
plot(t_uniform(start_sample:end_sample), v_filtered(start_sample:end_sample), 'r', 'LineWidth', 1.2);
xlabel('Time (s)'); ylabel('Voltage (V)');
legend('Original','Filtered (50 Hz removed)');
title(sprintf('Time-Domain Signal (%d–%d samples)', start_sample, end_sample));
grid on;

% --- FFT ---
N = length(v_filtered);
Nfft = 2^nextpow2(N);
Vf = fft(v_filtered, Nfft);
f = (0:(Nfft/2-1))' * (Fs / Nfft);
Vf_mag = abs(Vf(1:Nfft/2)) / N;

% --- Full FFT Plot ---
figure('Name','FFT Magnitude (Full Range)');
plot(f, Vf_mag, 'LineWidth', 1.2);
xlabel('Frequency (Hz)'); ylabel('Amplitude');
title('FFT Magnitude (Full Spectrum)');
grid on; xlim([0, Fs/2]);

% --- Zoomed FFT below 50 Hz ---
figure('Name','FFT Magnitude (Below 50 Hz)');
plot(f, Vf_mag, 'LineWidth', 1.2);
xlabel('Frequency (Hz)'); ylabel('Amplitude');
title('FFT Magnitude (0–50 Hz)');
grid on; xlim([0, 50]);
end
