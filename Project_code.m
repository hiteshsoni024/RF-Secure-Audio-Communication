clc;
clear all;
close all;

%Parameters
fs = 44100;              % Sampling Frequency
nBits = 16;              % Bit Depth
nChannels = 1;           % MONO CHANNELED 
duration = 5;            % DURATION
fc_filter = 3000;        % Cutoff frequency for low-pass filter
fc_carrier = 15000;      % Carrier frequency for FM modulation
freqDev = 5000;          % Frequency Deviation (Hz)

%Record Original Audio
recObj = audiorecorder(fs, nBits, nChannels);
disp('Start Speaking...');
recordblocking(recObj, duration);
disp('Recording Complete.');
audioData = getaudiodata(recObj);
t = linspace(0, duration, length(audioData));

%6th Order Butterworth Low-Pass Filter
[b, a] = butter(6, fc_filter/(fs/2), 'low');
filteredAudio = filter(b, a, audioData);

%Encrypt the Filtered Audio
key = randi([0 1], length(filteredAudio), 1);   % random key Btw 0,1
key_audio = 2*key - 1;                          % Convert to ±1
encryptedAudio = filteredAudio .* key_audio;  

%FM Modulation & Demodulation
modulatedSignal = fmmod(encryptedAudio, fc_carrier, fs, freqDev);
demodulatedSignal = fmdemod(modulatedSignal, fc_carrier, fs, freqDev);


% error of calculation
error = norm(filteredAudio - decryptedAudio);  
disp(['calculation: ', num2str(error)]);

% error correction
filteredAudio = filteredAudio / max(abs(filteredAudio));  
encryptedAudio = filteredAudio .* key_audio;
decryptedAudio = encryptedAudio .* key_audio;

% error of calculation
error = norm(filteredAudio - decryptedAudio);  
disp(['calculation: ', num2str(error)]);


%Decrypt the Demodulated Audio
decryptedAudio = demodulatedSignal .* key_audio;

%Original Audio
disp('Playing Original Audio...');
sound(audioData, fs);
pause(duration + 1);

%Filtered Audio
disp('Playing Filtered Audio...');
sound(filteredAudio, fs);
pause(duration + 1);

%FM Modulated Signal (Encrypted Transmission)
disp('Playing Modulated Signal...');
sound(modulatedSignal, fs);
pause(duration + 1);

%Demodulated (But Not Decrypted) Audio
disp('Playing Demodulated Audio (Without Decryption)...');
sound(demodulatedSignal, fs);
pause(duration + 1);

%Final Decrypted Audio
disp('Playing Decrypted Audio...');
sound(decryptedAudio, fs);
pause(duration + 1);

%Plot Signals
figure;

subplot(5,1,1);
plot(t, audioData);
title('Original Audio Signal');
xlabel('Time (s)');
ylabel('Amplitude');
grid on;

subplot(5,1,2);
plot(t, filteredAudio);
title('Filtered Audio Signal');
xlabel('Time (s)');
ylabel('Amplitude');
grid on;

subplot(5,1,3);
plot(t, encryptedAudio);
title('Encrypted Audio Signal (Before Modulation)');
xlabel('Time (s)');
ylabel('Amplitude');
grid on;

subplot(5,1,4);
plot(t, demodulatedSignal);
title('Demodulated Signal (Still Encrypted)');
xlabel('Time (s)');
ylabel('Amplitude');
grid on;

subplot(5,1,5);
plot(t, decryptedAudio);
title('Final Decrypted Audio Signal');
xlabel('Time (s)');
ylabel('Amplitude');
grid on;

disp("Finished");
