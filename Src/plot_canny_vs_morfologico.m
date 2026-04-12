% =========================================================================
% Script: plot_canny_vs_morfologico.m
% Script per dimostrare la "Good Localization" (Canny vs Morfologico)
% =========================================================================
clear; close all; clc;

% Carica i dati salvati dal main
disp('Caricamento dei dati dal workspace...');
load('workspace/performance_data.mat'); 

% Determina il numero totale di elementi nella struct
num_images = numel(project_data); 
asse_x = 1:num_images;

% Inizializzazione vettori
mse_morf = zeros(1, num_images);
mse_canny = zeros(1, num_images);

% Estrazione dati dalla struttura
for k = 1:num_images
    mse_morf(k) = project_data(k).MSE_Bordi_Morfologici;
    mse_canny(k) = project_data(k).MSE_Bordi_Canny;
end

% Creazione del grafico
figure('Name', 'Confronto Good Localization: Canny vs Morfologico');
plot(asse_x, mse_morf, 'r-*', 'LineWidth', 1.5); hold on;
plot(asse_x, mse_canny, 'b-o', 'LineWidth', 1.5); 

title('Confronto Good Localization sui Contorni (MSE)');
xlabel('Indice Immagine');
ylabel('MSE (Distanza dai bordi reali)');
legend('Gradiente Morfologico (Modulo B)', 'Canny Edge (Optimal Detector)');
grid on;