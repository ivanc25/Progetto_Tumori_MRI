% =========================================================================
% Script Principale: main.m
% Segmentazione e Analisi di Tumori Cerebrali in MRI
% =========================================================================
clear; close all; clc;

%% FASE 1: Caricamento Dati
% Le fonti indicano di usare imread per formati standard come tif o jpg [2]
% Immaginiamo di avere un'immagine MRI e il suo Ground Truth (GT)
disp('Caricamento immagine e Ground Truth...');
img_orig = imread('../Dataset/images/1.png'); 
mask_GT = imread('../Dataset/masks/1.png'); 

% Conversione in scala di grigi se l'immagine è Truecolor [2]
if size(img_orig, 3) == 3
    img_orig = rgb2gray(img_orig);
end

% Conversione in double per le operazioni aritmetiche e filtri [3]
img_double = im2double(img_orig);
mask_GT_logical = mask_GT > 0; % Assicuriamoci che il GT sia binario

%% FASE 2: Modulo A - Pre-elaborazione (Studente 1)
disp('Esecuzione Pre-elaborazione...');
tic; % Avvio timer per misurare l'efficienza [4]
img_enhanced = modulo_A_preprocessing(img_double);
toc; % Fine timer

%% FASE 3: Modulo B - Morfologia e Segmentazione (Studente 2)
disp('Esecuzione Segmentazione...');
tic;
[brain_mask, tumor_mask] = modulo_B_segmentation(img_enhanced);
toc;

%% FASE 4: Validazione Quantitativa
disp('--- Risultati Analisi Quantitativa ---');

% 1. Calcolo Errore Quadratico Medio (MSE) tra la nostra maschera e il GT [5]
% La formula del MSE indica quanto la predizione si discosta dal riferimento
mse_val = mean2((double(tumor_mask) - double(mask_GT_logical)).^2);
fprintf('Mean Squared Error (MSE): %f\n', mse_val);

% 2. Conteggio delle lesioni tramite Connected Components [6]
CC_pred = bwconncomp(tumor_mask);
CC_gt = bwconncomp(mask_GT_logical);
fprintf('Numero lesioni rilevate dall''algoritmo: %d\n', CC_pred.NumObjects);
fprintf('Numero lesioni reali (Ground Truth): %d\n', CC_gt.NumObjects);

%% FASE 5: Visualizzazione Risultati
figure;
subplot(2,2,1); imshow(img_orig); title('Immagine Originale');
subplot(2,2,2); imshow(img_enhanced); title('Immagine Enfatizzata (Modulo A)');
subplot(2,2,3); imshow(tumor_mask); title('Tumore Segmentato (Modulo B)');
subplot(2,2,4); imshow(mask_GT_logical); title('Ground Truth Medico');
