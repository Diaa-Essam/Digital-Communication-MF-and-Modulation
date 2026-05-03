clc;
clear;
close all;

N = 1e5;

bits = randi([0 1], 1, N);

m = 20;
tx_signal = repelem(bits, m);

snr_db = 0:0.2:30;

BER = zeros(size(snr_db));

for k = 1:length(snr_db)
    
    rx_signal = awgn(tx_signal, snr_db(k), 'measured');
    
    
end