% --- Parámetros de simulación ---
fs = 48000;
N = 2048; 
f = linspace(10, fs/2, N); 
w = 2*pi*f;
c = 340;
r = 0.0147;
kr = (w*r)/c;

% --- Cálculo de funciones de Bessel esféricas ---
% j0(x) = sin(x)/x
% j1(x) = sin(x)/x^2 - cos(x)/x
% j2(x) = (3/x^3 - 1/x)sin(x) - 3/x^2 * cos(x)

j0 = sin(kr) ./ kr;
j1 = (sin(kr) ./ (kr.^2)) - (cos(kr) ./ kr);
j2 = ((3./(kr.^3)) - (1./kr)).*sin(kr) - (3./(kr.^2)).*cos(kr);

% --- Funciones de Transferencia (Gerzon) ---
H_omni = j0 + 1i*j1;
H_fig8 = (1/3)*j0 + 1i*j1 - (2/3)*j2;

% Normalizar las funciones de transferencia
H_omni = H_omni / max(abs(H_omni));
H_fig8 = H_fig8 / max(abs(H_fig8));

% Magnitud
subplot(2,1,1);
semilogx(f, 20*log10(abs(H_omni)), 'LineWidth', 2, 'DisplayName', 'W (Omni)');
hold on;
semilogx(f, 20*log10(abs(H_fig8)), 'LineWidth', 2, 'DisplayName', 'X,Y,Z (Fig-8)');
grid on;
title('Respuesta en Frecuencia (Magnitud)');
ylabel('Amplitud (dB)');
xlabel('Frecuencia (Hz)');
legend('Location', 'southwest');
ylim([-20, 5]);

% Fase
subplot(2,1,2);
semilogx(f, unwrap(angle(H_omni))*180/pi, 'LineWidth', 2, 'DisplayName', 'Fase W');
hold on;
semilogx(f, unwrap(angle(H_fig8))*180/pi, 'LineWidth', 2, 'DisplayName', 'Fase X,Y,Z');
grid on;
title('Respuesta de Fase');
ylabel('Fase (grados)');
xlabel('Frecuencia (Hz)');
legend('Location', 'southwest');
