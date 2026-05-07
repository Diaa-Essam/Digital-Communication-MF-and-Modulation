clc;
clear;
close all;

N = 1e5;

bits = randi([0 1], 1, N);

m = 20;
tx_signal = repelem(bits, m);

snr_db = 0:0.2:30;

BER = zeros(size(snr_db));

s1 = ones(1, m);
s2 = zeros(1, m);
g = s1 - s2;
g_rep = repmat(g, 1, N);

threshold = sum(g .* s1) / 2;

for k = 1:length(snr_db)
    
    rx_signal = awgn(tx_signal, snr_db(k), 'measured');
    corr_product = rx_signal .* g_rep;
    
    corr_matrix = reshape(corr_product, m, N);
    corr_output = sum(corr_matrix, 1);
    
    detected_bits = corr_output > threshold; 
    BER(k) = sum(xor(bits, detected_bits)) / N;

end

figure;
semilogy(snr_db, BER);
xlabel('SNR (dB)');
ylabel('BER');
title('Matched Filter BER');
grid on;