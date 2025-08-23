% -------------------------------------------------------------------------
% STEP 1: Load the Audio File
% -------------------------------------------------------------------------

[audio, fs] = audioread('ahmed.m4a');   % Load audio file and its sampling rate
t = (0:length(audio)-1) / fs;           % Generate time vector based on sampling frequency

% Check if the audio is stereo (2 channels), and convert to mono if needed
if size(audio, 2) == 2
    audio = mean(audio, 2);             % Take the average of both channels
end

% -------------------------------------------------------------------------
% STEP 2: Frequency Domain Analysis of the Original Audio
% -------------------------------------------------------------------------

N = length(audio);                      % Number of samples in the audio signal
f = (-N/2:N/2-1) * (fs/N);              % Frequency axis for FFT (centered)
audio_fft = fftshift(fft(audio));       % Compute centered FFT for spectrum analysis

% -------------------------------------------------------------------------
% STEP 3: Add White Gaussian Noise to the Audio
% -------------------------------------------------------------------------

SNR = 10;                               % Set signal-to-noise ratio in decibels
noisy_audio = awgn(audio, SNR, 'measured');  % Add white noise preserving SNR

% -------------------------------------------------------------------------
% STEP 4: Time and Frequency Domain Plots
% -------------------------------------------------------------------------

% Time and Frequency domain of original audio
figure;
subplot(2,1,1);
plot(t, audio);
title('Original Audio Signal (Time Domain)');
xlabel('Time (s)'); ylabel('Amplitude');

subplot(2,1,2);
plot(f, abs(audio_fft));
title('Original Audio Signal (Frequency Domain)');
xlabel('Frequency (Hz)'); ylabel('Magnitude');

% Time and Frequency domain of noisy audio
figure;
subplot(2,1,1);
plot(t, noisy_audio);
title(['Noisy Audio Signal (Time Domain) - SNR = ', num2str(SNR), ' dB']);
xlabel('Time (s)'); ylabel('Amplitude');

noisy_audio_fft = fftshift(fft(noisy_audio)); % FFT of noisy signal
subplot(2,1,2);
plot(f, abs(noisy_audio_fft));
title('Noisy Audio Signal (Frequency Domain)');
xlabel('Frequency (Hz)'); ylabel('Magnitude');

% Ensure vectors are column-aligned
noisy_audio = noisy_audio(:);
t = (0:length(noisy_audio)-1)' / fs;

% -------------------------------------------------------------------------
% STEP 5: AM Modulation (Amplitude Modulation)
% -------------------------------------------------------------------------

fc_am = 1000;  % Carrier frequency for modulation (Hz)
modulated_am = (1 + 0.5 * noisy_audio) .* cos(2 * pi * fc_am * t);  % Generate AM signal
modulated_am_fft = fftshift(fft(modulated_am));  % FFT for spectral analysis

% Plot AM modulated signal
figure;
subplot(2,1,1); plot(t, modulated_am);
title('AM Modulated Signal in Time Domain');
xlabel('Time (s)'); ylabel('Amplitude');

subplot(2,1,2); plot(f, abs(modulated_am_fft));
title('Frequency Domain of AM Modulated Signal');
xlabel('Frequency (Hz)'); ylabel('Magnitude');

% -------------------------------------------------------------------------
% STEP 6: DSB-SC Modulation (Double Sideband - Suppressed Carrier)
% -------------------------------------------------------------------------

fc_dsb = 1000;  % Carrier frequency
modulated_dsb_sc = noisy_audio .* cos(2 * pi * fc_dsb * t); % Multiply with carrier only
modulated_dsb_sc_fft = fftshift(fft(modulated_dsb_sc));     % FFT for frequency analysis

% Plot DSB-SC
figure;
subplot(2,1,1); plot(t, modulated_dsb_sc);
title('DSB-SC Modulated Signal in Time Domain');
xlabel('Time (s)'); ylabel('Amplitude');

subplot(2,1,2); plot(f, abs(modulated_dsb_sc_fft));
title('Frequency Domain of DSB-SC Modulated Signal');
xlabel('Frequency (Hz)'); ylabel('Magnitude');

% -------------------------------------------------------------------------
% STEP 7: DSB-TC Modulation (Double Sideband - Transmitted Carrier)
% -------------------------------------------------------------------------

fc_tc = 1000;  % Carrier frequency
modulated_dsb_tc = (1 + noisy_audio) .* cos(2 * pi * fc_tc * t);  % Add carrier
modulated_dsb_tc_fft = fftshift(fft(modulated_dsb_tc));          % FFT

% Plot DSB-TC
figure;
subplot(2,1,1); plot(t, modulated_dsb_tc);
title('DSB-TC Modulated Signal in Time Domain');
xlabel('Time (s)'); ylabel('Amplitude');

subplot(2,1,2); plot(f, abs(modulated_dsb_tc_fft));
title('Frequency Domain of DSB-TC Modulated Signal');
xlabel('Frequency (Hz)'); ylabel('Magnitude');

% -------------------------------------------------------------------------
% STEP 8: FM Modulation (Frequency Modulation)
% -------------------------------------------------------------------------

fc_fm = 1000;                       % Carrier frequency
freq_dev = 500;                     % Frequency deviation
% Integral of the signal used in FM phase expression
modulated_fm = cos(2 * pi * fc_fm * t + 2 * pi * freq_dev * cumsum(noisy_audio) / fs);
modulated_fm_fft = fftshift(fft(modulated_fm));

% Plot FM signal
figure;
subplot(2,1,1); plot(t, modulated_fm);
title('FM Modulated Signal in Time Domain');
xlabel('Time (s)'); ylabel('Amplitude');

subplot(2,1,2); plot(f, abs(modulated_fm_fft));
title('Frequency Domain of FM Modulated Signal');
xlabel('Frequency (Hz)'); ylabel('Magnitude');

% -------------------------------------------------------------------------
% STEP 9: 100 Hz Low-Pass Butterworth Filter Design
% -------------------------------------------------------------------------

fc = 100;                            % Cutoff frequency (Hz)
Wn = fc / (fs/2);                    % Normalize cutoff by Nyquist
[b, a] = butter(4, Wn);              % 4th-order Butterworth design

% Plot pole-zero diagram
figure; zplane(b, a);
title('Pole-Zero Plot of 100 Hz Low-Pass Filter');

% Calculate region of convergence (ROC)
poles = roots(a);
roc_radius = max(abs(poles));
disp(['ROC: |z| > ', num2str(roc_radius)]);

% Shade ROC region in z-plane
theta = linspace(0, 2*pi, 500);
radii = linspace(roc_radius, 1.5, 300);
figure; hold on;
for r = radii
    plot(r*cos(theta), r*sin(theta), 'Color', [0.9 0.9 1], 'LineWidth', 0.5);
end
z = roots(b); % zeros
plot(real(z), imag(z), 'bo', 'LineWidth', 1.5);      % Plot zeros
plot(real(poles), imag(poles), 'rx', 'LineWidth', 1.5); % Plot poles
plot(cos(theta), sin(theta), 'k--');                 % Unit circle
title('Z-Plane with Region of Convergence (ROC)');
legend('ROC', 'Zeros', 'Poles', 'Unit Circle'); axis equal; grid on;

[H, f_response] = freqz(b, a, 1024, fs);

figure('Color','w');
tiledlayout(2,1, 'Padding', 'compact', 'TileSpacing', 'compact');

% Magnitude
nexttile;
plot(f_response, 20*log10(abs(H)), 'b', 'LineWidth', 1.2);
grid on; box on;
title('100 Hz Low-Pass Filter - Magnitude Response', 'FontWeight', 'bold');
xlabel('Frequency (Hz)'); ylabel('Magnitude (dB)');
set(gca, 'FontName', 'Arial');

% Phase
nexttile;
plot(f_response, unwrap(angle(H)) * 180/pi, 'r', 'LineWidth', 1.2);
grid on; box on;
title('100 Hz Low-Pass Filter - Phase Response', 'FontWeight', 'bold');
xlabel('Frequency (Hz)'); ylabel('Phase (degrees)');
set(gca, 'FontName', 'Arial');


% Apply LPF to noisy signal
filtered_audio = filter(b, a, noisy_audio);

% Plot LPF output
figure;
subplot(2,1,1); plot(t, filtered_audio);
title('Filtered Signal (100 Hz LPF) - Time Domain');

subplot(2,1,2);
filtered_fft = fftshift(fft(filtered_audio));
plot(f, abs(filtered_fft));
title('Filtered Signal (100 Hz LPF) - Frequency Domain');

% -------------------------------------------------------------------------
% STEP 10: Reapply Modulations After 100 Hz LPF
% -------------------------------------------------------------------------

% AM
mod_am = (1 + 0.5 * filtered_audio) .* cos(2*pi*fc_am*t);
mod_am_fft = fftshift(fft(mod_am, N));
figure;
subplot(2,1,1); plot(t, mod_am); title('AM Modulated (100 Hz LPF) - Time');
subplot(2,1,2); plot(f, abs(mod_am_fft)); title('AM Modulated (100 Hz LPF) - Freq');

% DSB-SC
mod_dsb = filtered_audio .* cos(2*pi*fc_am*t);
mod_dsb_fft = fftshift(fft(mod_dsb, N));
figure;
subplot(2,1,1); plot(t, mod_dsb); title('DSB-SC Modulated (100 Hz LPF) - Time');
subplot(2,1,2); plot(f, abs(mod_dsb_fft)); title('DSB-SC Modulated (100 Hz LPF) - Freq');

% DSB-TC
mod_tc = (1 + filtered_audio) .* cos(2*pi*fc_am*t);
mod_tc_fft = fftshift(fft(mod_tc, N));
figure;
subplot(2,1,1); plot(t, mod_tc); title('DSB-TC Modulated (100 Hz LPF) - Time');
subplot(2,1,2); plot(f, abs(mod_tc_fft)); title('DSB-TC Modulated (100 Hz LPF) - Freq');

% FM
mod_fm = cos(2*pi*fc_am*t + 2*pi*freq_dev*cumsum(filtered_audio)/fs);
mod_fm_fft = fftshift(fft(mod_fm, N));
figure;
subplot(2,1,1); plot(t, mod_fm); title('FM Modulated (100 Hz LPF) - Time');
subplot(2,1,2); plot(f, abs(mod_fm_fft)); title('FM Modulated (100 Hz LPF) - Freq');

% -------------------------------------------------------------------------
% STEP 11: Design a 60 Hz Notch Filter
% -------------------------------------------------------------------------

f_notch = 60;                     % Target frequency to remove
r = 0.95;                         % Radius (close to 1 = narrow notch)
omega = 2*pi*f_notch/fs;         % Normalized angular frequency

% Coefficients for notch filter (second-order IIR)
b = [1, -2*cos(omega), 1];
a = [1, -2*r*cos(omega), r^2];

% Pole-zero plot
figure; zplane(b, a);
title('60 Hz Notch Filter - Pole-Zero Plot');

% Region of Convergence (ROC) for stability
poles = roots(a);
roc_radius = max(abs(poles));
disp(['ROC: |z| > ', num2str(roc_radius)]);

% Plot ROC
theta = linspace(0, 2*pi, 500);
radii = linspace(roc_radius, 1.5, 300);
figure; hold on;
for r_shade = radii
    plot(r_shade*cos(theta), r_shade*sin(theta), 'Color', [1, 0.9, 0.9], 'LineWidth', 0.5);
end
z = roots(b);
plot(real(z), imag(z), 'bo', 'LineWidth', 1.5);        % Zeros
plot(real(poles), imag(poles), 'rx', 'LineWidth', 1.5);% Poles
plot(cos(theta), sin(theta), 'k--');                   % Unit circle
title('Z-Plane with ROC - 60 Hz Notch Filter'); axis equal; grid on;

[H_notch, f_notch_response] = freqz(b, a, 1024, fs);

figure('Color','w');
tiledlayout(2,1, 'Padding', 'compact', 'TileSpacing', 'compact');

% Magnitude
nexttile;
plot(f_notch_response, 20*log10(abs(H_notch)), 'b', 'LineWidth', 1.2);
grid on; box on;
title('60 Hz Notch Filter - Magnitude Response', 'FontWeight', 'bold');
xlabel('Frequency (Hz)'); ylabel('Magnitude (dB)');
set(gca, 'FontName', 'Arial');

% Phase
nexttile;
plot(f_notch_response, unwrap(angle(H_notch)) * 180/pi, 'r', 'LineWidth', 1.2);
grid on; box on;
title('60 Hz Notch Filter - Phase Response', 'FontWeight', 'bold');
xlabel('Frequency (Hz)'); ylabel('Phase (degrees)');
set(gca, 'FontName', 'Arial');


% Apply notch filter
filtered_audio = filter(b, a, noisy_audio);

% Time and Frequency plots after notch filter
figure;
subplot(2,1,1); plot(t, filtered_audio);
title('Filtered Signal (60 Hz Notch) - Time Domain');

subplot(2,1,2);
filtered_fft = fftshift(fft(filtered_audio));
plot(f, abs(filtered_fft));
title('Filtered Signal (60 Hz Notch) - Frequency Domain');

% -------------------------------------------------------------------------
% STEP 12: Apply Modulations After 60 Hz Notch Filtering
% -------------------------------------------------------------------------

% AM
mod_am = (1 + 0.5 * filtered_audio) .* cos(2*pi*fc_am*t);
mod_am_fft = fftshift(fft(mod_am));
figure;
subplot(2,1,1); plot(t, mod_am); title('AM Modulated (60 Hz Notch)');
subplot(2,1,2); plot(f, abs(mod_am_fft)); title('AM Spectrum (60 Hz Notch)');

% DSB-SC
mod_dsb = filtered_audio .* cos(2*pi*fc_am*t);
mod_dsb_fft = fftshift(fft(mod_dsb));
figure;
subplot(2,1,1); plot(t, mod_dsb); title('DSB-SC Modulated (60 Hz Notch)');
subplot(2,1,2); plot(f, abs(mod_dsb_fft)); title('DSB-SC Spectrum (60 Hz Notch)');

% DSB-TC
mod_tc = (1 + filtered_audio) .* cos(2*pi*fc_am*t);
mod_tc_fft = fftshift(fft(mod_tc));
figure;
subplot(2,1,1); plot(t, mod_tc); title('DSB-TC Modulated (60 Hz Notch)');
subplot(2,1,2); plot(f, abs(mod_tc_fft)); title('DSB-TC Spectrum (60 Hz Notch)');

% FM
mod_fm = cos(2*pi*fc_am*t + 2*pi*freq_dev*cumsum(filtered_audio)/fs);
mod_fm_fft = fftshift(fft(mod_fm));
figure;
subplot(2,1,1); plot(t, mod_fm); title('FM Modulated (60 Hz Notch)');
subplot(2,1,2); plot(f, abs(mod_fm_fft)); title('FM Spectrum (60 Hz Notch)');
