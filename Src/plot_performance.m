% =========================================================================
% Script: plot_performance.m
% Generazione grafici sull'andamento generale del Dataset
% =========================================================================
clear; close all; clc;

% 1. Carica i dati salvati dal main
disp('Caricamento dei dati dal workspace...');
load('workspace/performance_data.mat'); 

% Determina il numero totale di elementi nella struct
num_images = numel(project_data); 

% 2. Estrazione dei dati dalla struttura
asse_x = 1:num_images; % Vettore per l'asse X (indice immagini)
mse_trend = zeros(1, num_images);
time_A_trend = zeros(1, num_images);
time_B_trend = zeros(1, num_images);

for k = 1:num_images
    mse_trend(k) = project_data(k).MSE_Area;
    time_A_trend(k) = project_data(k).time_modulo_A;
    time_B_trend(k) = project_data(k).time_modulo_B;
end

% 3. Generazione dei Grafici
figure('Name', 'Andamento Generale Dataset');

% Grafico 1: Andamento dell'Errore Quadratico Medio (MSE)
subplot(2,1,1); % Divide la finestra in 2 righe, posizionandosi nella 1a
% Usa una linea tratteggiata rossa ('--r') con marker quadrati ('s') verdi
plot(asse_x, mse_trend, '--rs', 'LineWidth', 2, 'MarkerFaceColor', 'g'); 
title('Andamento dell''Errore Quadratico Medio (MSE) sul Dataset');
xlabel('Indice Immagine');
ylabel('Valore MSE');
grid on; % Aggiunge la griglia di sfondo

% Grafico 2: Confronto dei Tempi di Esecuzione
subplot(2,1,2); % Posizionamento nella 2a riga
plot(asse_x, time_A_trend, 'b-*', 'LineWidth', 1.5); hold on;
plot(asse_x, time_B_trend, 'm-o', 'LineWidth', 1.5);
title('Tempi di Esecuzione Computazionale');
xlabel('Indice Immagine');
ylabel('Tempo (secondi)');
legend('Modulo A (Pre-processing)', 'Modulo B (Segmentazione)');
grid on;