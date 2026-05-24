SOFAstart;

sofa = SOFAload('../AudioHRTF/hrtf b_nh60.sofa');

az_all = sofa.SourcePosition(:, 1);
el_all = sofa.SourcePosition(:, 2);
kernelLen   = size(sofa.Data.IR, 3);

% Busca la medición más cercana al frente (az=0, el=0)
[~, idx] = min(abs(az_all) + abs(el_all));
fprintf('Usando medición #%d: az=%.1f, el=%.1f\n', idx, az_all(idx), el_all(idx));

% Extrae L y R
hrir_L = squeeze(sofa.Data.IR(idx, 1, :));
hrir_R = squeeze(sofa.Data.IR(idx, 2, :));


% Construye los 2 kernels FOA estéreo. Se duplica la columna porque en JSFX
% la funcion mem_Set y FFT funciona intercalando uma muestra real y otra imaginaria.
% Así a la hora de trabajar con los kernels L y R, la primera columna sera
% la parte real y la segunda la imaginaria (la que se descarta)
kernel_L = [hrir_L,  zeros(kernelLen, 1)];
kernel_R = [hrir_R,  zeros(kernelLen, 1)];

fs = sofa.Data.SamplingRate;

% Carpeta de salida
outFolder = '../AudioHRTF/';
%mkdir(outFolder);

audiowrite([outFolder 'HRIR_L.wav'], kernel_L, fs);
audiowrite([outFolder 'HRIR_R.wav'], kernel_R, fs);

fprintf('WAVs exportados correctamente en:\n%s\n', outFolder);

fprintf('Máximo hrir_L: %f\n', max(abs(hrir_L)));
fprintf('Máximo hrir_R: %f\n', max(abs(hrir_R)));
fprintf('RMS hrir_L: %f\n', rms(hrir_L));
fprintf('RMS hrir_R: %f\n', rms(hrir_R));

% --- Representación espectral con eje X en Hz (escala log) ---
N   = kernelLen;
f   = (0:N-1) * (fs / N);          % eje de frecuencias en Hz
idx_pos = 1:floor(N/2);            % solo mitad positiva del espectro

MAG_L = 20*log10(abs(fft(hrir_L)));
MAG_R = 20*log10(abs(fft(hrir_R)));

figure;

% --- Panel inferior: respuesta en frecuencia ---
semilogx(f(idx_pos), MAG_L(idx_pos), 'b', 'DisplayName', 'HRIR L'); 
hold on;
semilogx(f(idx_pos), MAG_R(idx_pos), 'r', 'DisplayName', 'HRIR R');
xlabel('Frecuencia (Hz)');
ylabel('Magnitud (dB)');
title('Respuesta en frecuencia HRIR L y R');
legend('show');
xlim([100, fs/2]);              
grid on;