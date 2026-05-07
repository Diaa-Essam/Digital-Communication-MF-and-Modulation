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

h_mf = fliplr(s1 - s2);

for k = 1:length(snr_db)
    
    rx_signal = awgn(tx_signal, snr_db(k), 'measured');
    
    mf_output = conv(rx_signal, h_mf);
    
    sampled_output = mf_output(m:m:end);
    
    threshold  = m / 2;
    
    detected_bits = sampled_output > threshold;

end