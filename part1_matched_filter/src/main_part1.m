clc;
clear;
close all;

N = 1e5;

bits = randi([0 1], 1, N);

m = 20;
tx_signal = repelem(bits, m);

snr_db = 0:0.2:30;

s1 = ones(1, m);
s2 = zeros(1, m);
g = s1 - s2;
g_rep = repmat(g, 1, N);

threshold = sum(g .* s1) / 2;

BER_MF   = zeros(size(snr_db));
BER_corr = zeros(size(snr_db));
BER_simple = zeros(size(snr_db));

h_mf = fliplr(s1 - s2);                   % Matched filter impulse response

% --- Matched Filter Loop ---
for k = 1:length(snr_db)

    rx_signal = awgn(tx_signal, snr_db(k), 'measured');  

    mf_output = conv(rx_signal, h_mf);                   

    sampled_output = mf_output(m:m:N*m);                 

    detected_bits = sampled_output > threshold;           

    BER_MF(k) = sum(xor(bits, detected_bits)) / N;      

end

for k = 1:length(snr_db)
    
    rx_signal = awgn(tx_signal, snr_db(k), 'measured');
    corr_product = rx_signal .* g_rep;
    
    corr_matrix = reshape(corr_product, m, N);
    corr_output = sum(corr_matrix, 1);
    
    detected_bits = corr_output > threshold; 
    BER_corr(k) = sum(xor(bits, detected_bits)) / N;

end

for k = 1:length(snr_db)
    rx_signal = awgn(tx_signal, snr_db(k), 'measured');
    
    sampled = rx_signal(m:m:end);
    
    detected_bits = sampled > 0.5;
    
    BER_simple(k) = sum(xor(bits, detected_bits)) / N;
end


figure;
semilogy(snr_db, BER_MF, 'b-');             % MF in blue
hold on;
semilogy(snr_db, BER_corr, 'r--');          % Correlator in red dashed
semilogy(snr_db, BER_simple, 'k:');         % Simple detector in black dotted
xlabel('SNR (dB)');
ylabel('BER');
title('BER Comparison: MF vs Correlator vs Simple Detector');
legend('Matched Filter', 'Correlator', 'Simple Detector');
grid on;