clear; clc; close all;

% Load and preprocess image
img = imread('cat.png');
img = imresize(img, [128 128]);
img = rgb2gray(img);

% Convert to binary bit stream
img_bin = de2bi(img(:), 8, 'left-msb');
data_bits = reshape(img_bin.', [], 1);

% XOR Encryption
key = randi([0 1], length(data_bits), 1);
enc_bits = xor(data_bits, key);

% Padding for QPSK
pad = mod(2 - mod(length(enc_bits), 2), 2);
enc_bits = [enc_bits; zeros(pad,1)];

% QPSK Modulation (Gray-coded)
symbols = bi2de(reshape(enc_bits, 2, []).', 'left-msb');
mod_signal = pskmod(symbols, 4, pi/4);  % default is Gray-coded

% Transmit through AWGN channel
rx_signal = awgn(mod_signal, 10, 'measured');  % High SNR for clear image

% QPSK Demodulation
rx_symbols = pskdemod(rx_signal, 4, pi/4);
rx_bits = de2bi(rx_symbols, 2, 'left-msb');
rx_bits = reshape(rx_bits.', [], 1);
rx_bits = rx_bits(1:length(data_bits));  % remove padding

% XOR Decryption
dec_bits = xor(rx_bits, key);

% Reconstruct image
bin_matrix = reshape(dec_bits, 8, []).';
pixels = bi2de(bin_matrix, 'left-msb');
rec_img = reshape(pixels, size(img));

% Display and PSNR
subplot(1,2,1); imshow(img); title('Original');
subplot(1,2,2); imshow(uint8(rec_img)); title('Recovered');

mse = mean((double(img(:)) - double(rec_img(:))).^2);
psnr_val = 10*log10(255^2 / mse);
fprintf('\nPSNR: %.2f dB\n', psnr_val);

