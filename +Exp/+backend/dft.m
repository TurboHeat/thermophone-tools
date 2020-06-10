function [output_RMS, frequency] = dft(data, samplestats)
%{
This code performs a discrete Fourier Transformation on the input data and outputs the rms output an frequency
%}

Fs = samplestats(2); % Sampling frequency
T = 1 / Fs; % Sampling period
L = numel(data); % Length of signal
t = (0:L - 1) * T; % Time vector
f = Fs * (0:(L / 2)) / L;

%data=1+cos(2*pi*samplestats(3)*t)'; %test

% Band-Pass Filter:
lower_freq = 0.5 * samplestats(3);
upper_freq = 1.5 * samplestats(3);
BPF = ((lower_freq < abs(f)) & (abs(f) < upper_freq))';

data = detrend(data);

Y = fft(data);

P2 = abs(Y/L);
P1 = P2(1:L/2+1);
P1(2:end-1) = 2 * P1(2:end-1);

%Filtered data
P1f = BPF .* P1;

%The fft data is the 0-peak value ie:amplitude
%conversion to RMS:
P1f = P1f / sqrt(2);

% figure(1)
% hold on
% plot(f,P1)
% plot(f,P1f)
% title('Single-Sided Amplitude Spectrum of X(t)')
% xlabel('f (Hz)')
% ylabel('|P1(f)|')

[output_RMS, frequency] = findpeaks(P1, f, 'SortStr', 'descend', 'NPeaks', 1);

end
