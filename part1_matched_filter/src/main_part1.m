clc;
clear;
close all;

%% =========================================================
% Part 1
% Performance of Matched Filter and Correlator Receivers
%% =========================================================

%% ================= Simulation Parameters =================

N = 1e5;                      % Number of bits
snr_db = 0:2:30;              % SNR range

% Different number of samples per bit
m_values = [10 20 100];

% Sampling instant (can be generalized later)
sampling_ratio = 1;

%% ================= Figure =================

figure;

%% =========================================================
% Loop over different m values
%% =========================================================

for mm = 1:length(m_values)

    %% ================= Current m =================

    m = m_values(mm);

    sampling_index = sampling_ratio * m;

    %% ================= Bit Generation =================

    bits = randi([0 1], 1, N);

    %% ================= Signal Waveforms =================

    % User-defined waveforms
    s1 = ones(1, m);          % Rectangular pulse
    s2 = zeros(1, m);         % Zero signal

    %% ================= Signal Power =================

    E1 = sum(s1.^2);
    E2 = sum(s2.^2);

    signal_power = mean(s1.^2);

    fprintf('\n============================\n');
    fprintf('m = %d\n', m);
    fprintf('Signal Energy E1 = %.2f\n', E1);
    fprintf('Signal Power = %.2f\n', signal_power);

    %% ================= Waveform Generation =================

    tx_signal = repelem(bits, m);

    %% ================= Receiver Parameters =================

    % Correlator signal
    g = s1 - s2;

    % Repeat g for all bits
    g_rep = repmat(g, 1, N);

    % Matched filter impulse response
    h_mf = fliplr(g);

    % Threshold
    threshold = (E1 - E2) / 2;

    %% ================= BER Initialization =================

    BER_MF      = zeros(size(snr_db));
    BER_corr    = zeros(size(snr_db));
    BER_simple  = zeros(size(snr_db));

    %% =====================================================
    % Main SNR Loop
    %% =====================================================

    for k = 1:length(snr_db)

        %% ================= Channel =================

        rx_signal = awgn(tx_signal, snr_db(k), 'measured');

        %% =================================================
        % Matched Filter Receiver
        %% =================================================

        mf_output = conv(rx_signal, h_mf);

        sampled_output = mf_output(sampling_index:m:N*m);

        detected_bits_mf = sampled_output > threshold;

        BER_MF(k) = sum(xor(bits, detected_bits_mf)) / N;

        %% =================================================
        % Correlator Receiver
        %% =================================================

        corr_product = rx_signal .* g_rep;

        corr_matrix = reshape(corr_product, m, N);

        corr_output = sum(corr_matrix, 1);

        detected_bits_corr = corr_output > threshold;

        BER_corr(k) = sum(xor(bits, detected_bits_corr)) / N;

        %% =================================================
        % Simple Detector
        %% =================================================

        sampled_simple = rx_signal(m:m:end);

        detected_bits_simple = sampled_simple > 0.5;

        BER_simple(k) = sum(xor(bits, detected_bits_simple)) / N;

    end

    %% =====================================================
    % Plot BER Curves
    %% =====================================================

    semilogy(snr_db, BER_MF, '-o', 'LineWidth', 1.5);
    hold on;

    semilogy(snr_db, BER_corr, '--s', 'LineWidth', 1.5);

    semilogy(snr_db, BER_simple, ':d', 'LineWidth', 1.5);

end

%% ================= Plot Formatting =================

xlabel('SNR (dB)');
ylabel('Bit Error Rate (BER)');

title('BER Comparison for Different Receivers and Different m Values');

legend( ...
    'MF m=10', ...
    'Corr m=10', ...
    'Simple m=10', ...
    'MF m=20', ...
    'Corr m=20', ...
    'Simple m=20', ...
    'MF m=100', ...
    'Corr m=100', ...
    'Simple m=100' ...
    );

grid on;

%% =========================================================
% Near Error-Free SNR Estimation
%% =========================================================

fprintf('\n============================\n');
fprintf('Observe BER curves to determine near error-free SNR.\n');
fprintf('Typically BER approaches zero around high SNR values.\n');