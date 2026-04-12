% =========================================================================
% Script Principale: main.m
% Automazione su Dataset, Salvataggio Dati in Struct e Immagini
% =========================================================================
clear; close all; clc;

%% FASE 0: Setup Cartelle e Dataset
disp('Inizializzazione delle directory...');

% Creazione automatica delle cartelle di output se non esistono
if ~exist('results', 'dir'), mkdir('results'); end
if ~exist('workspace', 'dir'), mkdir('workspace'); end

% Definizione dei percorsi del dataset
img_dir = '../Dataset/images/';
mask_dir = '../Dataset/masks/';

% Estrazione della lista di tutti i file PNG nella cartella immagini
img_files = dir(fullfile(img_dir, '*.png'));
num_images = length(img_files);

disp(['Trovate ', num2str(num_images), ' immagini. Avvio elaborazione batch...']);

%% CICLO FOR SU TUTTO IL DATASET
for k = 1:num_images
    %% FASE 1: Caricamento Dati
    % COSTRUZIONE DINAMICA DEL NOME FILE: Forza l'ordine numerico (1, 2, 3...)
    filename = [num2str(k), '.png'];
    fprintf('\nElaborazione immagine %d/%d: %s\n', k, num_images, filename);
    
    % Caricamento dell'immagine e della rispettiva maschera Ground Truth
    img_orig = imread(fullfile(img_dir, filename)); 
    mask_GT = imread(fullfile(mask_dir, filename)); 
    
    if size(img_orig, 3) == 3
        img_orig = rgb2gray(img_orig);
    end
    img_double = im2double(img_orig);
    mask_GT_logical = mask_GT > 0;

    %% FASE 2: Modulo A - Pre-elaborazione
    tic; % Avvio timer
    img_enhanced = modulo_A_preprocessing(img_double);
    time_A = toc; % Fine timer

    %% FASE 3: Modulo B - Morfologia e Segmentazione
    tic; % Avvio timer
    [brain_mask, tumor_mask, tumor_edges] = modulo_B_segmentation(img_enhanced);
    time_B = toc; % Fine timer

    %% FASE 4: Validazione Quantitativa, Good Localization e Canny
    % Estrazione delle componenti connesse
    CC_pred = bwconncomp(tumor_mask); 
    CC_gt = bwconncomp(mask_GT_logical);
    
    % PUNTO 1: Estrazione del Centroide
    stats = regionprops(CC_pred, 'Centroid');
    if ~isempty(stats)
        centroid_x = stats(1).Centroid(1);
        centroid_y = stats(1).Centroid(2);
    else
        centroid_x = NaN; centroid_y = NaN; % Se non trova tumori
    end

    % PUNTO 2: Estrazione Contorni con Canny (Il rivelatore ottimale)
    canny_edges = edge(img_enhanced, 'canny');

    % PUNTO 3: Valutazione della "Good Localization"
    % Creiamo i bordi reali del Ground Truth usando il Gradiente Morfologico
    se_gt = ones(3,3);
    gt_edges = imdilate(mask_GT_logical, se_gt) - imerode(mask_GT_logical, se_gt);

    % Calcolo dell'MSE classico sull'intera area della lesione
    mse_area = mean2((double(tumor_mask) - double(mask_GT_logical)).^2);
    
    % Calcolo MSE specifico sui bordi per valutare la distanza di localizzazione
    mse_bordi_morfologici = mean2((double(tumor_edges) - double(gt_edges)).^2);
    mse_bordi_canny = mean2((double(canny_edges) - double(gt_edges)).^2);

    % Salvataggio di tutti i nuovi dati nella Struct del progetto
    project_data(k).filename = filename;
    project_data(k).time_modulo_A = time_A;
    project_data(k).time_modulo_B = time_B;
    project_data(k).MSE_Area = mse_area;
    project_data(k).MSE_Bordi_Morfologici = mse_bordi_morfologici;
    project_data(k).MSE_Bordi_Canny = mse_bordi_canny;
    project_data(k).lesioni_trovate = CC_pred.NumObjects;
    project_data(k).Centroide_X = centroid_x;
    project_data(k).Centroide_Y = centroid_y;

    %% FASE 5: Visualizzazione e Salvataggio Immagini
    % Creiamo la finta immagine RGB per i contorni rossi
    img_rgb = repmat(im2double(img_orig), 1, 1, 3); 
    img_rgb(:,:,1) = img_rgb(:,:,1) + double(tumor_edges); 
    img_rgb(:,:,2) = img_rgb(:,:,2) .* ~tumor_edges; 
    img_rgb(:,:,3) = img_rgb(:,:,3) .* ~tumor_edges; 
    
    % Salvataggio dell'immagine finale elaborata nella cartella 'results'
    out_filename = fullfile('results', ['segmentata_', filename]);
    imwrite(img_rgb, out_filename); 
end

%% FASE 6: Salvataggio Globale nel Workspace
disp('---------------------------------------------------');
disp('Elaborazione dell''intero dataset completata con successo!');
% Salviamo la struttura dati (project_data) in un file .mat nella cartella workspace
save(fullfile('workspace', 'performance_data.mat'), 'project_data');
disp('I dati statistici sono stati salvati in: workspace/performance_data.mat');
disp('Le immagini elaborate sono state salvate in: results/');