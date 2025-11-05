function fft_energy_notch(filename)
% fft_energy_notch - Estimate frequency band with maximum energy (50 Hz removed)
%
% Usage:
%   fft_energy_notch('scope_44.csv')

if nargin < 1
    filename = 'scope_44.csv';
end

% --- Read data ---
data = readmatrix(filename);
t = data(:,1);
v = data(:,2);

% --- Clean data ---
valid_idx = isfinite(t) & isfinite(v);
t = t(valid_idx);
v = v(valid_idx);
v = v - mean(v);   % remove DC

% --- Sampling info ---
dt = median(diff(t));
Fs = 1 / dt;

% --- Interpolate to uniform grid ---
t_uniform = (0:(length(t)-1))' * dt + min(t);
v_uniform = interp1(t, v, t_uniform, 'pchip', 'extrap');

% --- Remove DC offset again (safety) ---
v_uniform = v_uniform - mean(v_uniform);

% --- Design filters ---
f_notch = 50;                % notch center
Q = 100;                     % quality factor
wo = f_notch / (Fs/2);
bw = wo / Q;
[b_notch, a_notch] = iirnotch(wo, bw);

% Optional low-pass filter
[b_lp, a_lp] = butter(4, 1000/(Fs/2), 'low');

% --- Apply filters ---
v_notched = filtfilt(b_notch, a_notch, v_uniform);
v_filtered = filtfilt(b_lp, a_lp, v_notched);

% --- FFT ---
N = length(v_filtered);
Nfft = 2^nextpow2(N);
Vf = fft(v_filtered, Nfft);
f = (0:(Nfft/2-1))' * (Fs / Nfft);
P = abs(Vf(1:Nfft/2)).^2;  % power spectrum

% --- Plot power spectrum ---
figure('Name','FFT Power Spectrum (50 Hz removed)');
plot(f, P, 'LineWidth', 1.2);
xlabel('Frequency (Hz)');
ylabel('Power');
title('FFT Power Spectrum (50 Hz removed)');
grid on;
xlim([0 Fs/2]);

% --- Energy estimation in frequency bands ---
band_width = 10;  % 10 Hz per band (you can adjust)
max_freq = Fs/2;
num_bands = ceil(max_freq / band_width);
energy_per_band = zeros(num_bands,1);

for i = 1:num_bands
    f1 = (i-1)*band_width;
    f2 = min(i*band_width, max_freq);
    idx = f >= f1 & f < f2;
    energy_per_band(i) = sum(P(idx));
end

% --- Zero out 50 Hz band (and around it) to avoid bias ---
notch_band = (f >= 45 & f <= 55);
P(notch_band) = 0;
notch_idx = (round(45/band_width)+1):(round(55/band_width)+1);
notch_idx = notch_idx(notch_idx <= num_bands);
energy_per_band(notch_idx) = 0;

% --- Find band with maximum energy ---
[~, idx_max] = max(energy_per_band);
f_start = (idx_max-1)*band_width;
f_end = min(idx_max*band_width, max_freq);

fprintf('\n⚡ After 50 Hz removal, maximum energy lies between %.1f Hz and %.1f Hz\n', f_start, f_end);

% --- Plot energy per band ---
figure('Name','Energy per Frequency Band (50 Hz removed)');
bar((0:num_bands-1)*band_width, energy_per_band, 'FaceColor',[0.2 0.5 0.9]);
xlabel('Frequency Band Start (Hz)');
ylabel('Energy');
title('Energy Distribution Across Frequency Bands (50 Hz removed)');
grid on;

end
