% =========================================================================
% Script: verifica_centroide.m
% SCRIPT PER LA PROVA VISIVA DEL CENTROIDE
% =========================================================================

% 1. Scegliamo quale immagine visualizzare
indice_img = 162;

% 2. Recuperiamo in automatico il nome del file e le coordinate dalla struct
nome_file = project_data(indice_img).filename;
centro_x = project_data(indice_img).Centroide_X;
centro_y = project_data(indice_img).Centroide_Y;

% 3. Carichiamo l'immagine corrispondente dalla cartella 'results'
img_path = fullfile('results', ['segmentata_', nome_file]);
img_da_mostrare = imread(img_path); 

% 4. Mostriamo l'immagine e disegniamo il centroide
figure('Name', ['Verifica Centroide - ' nome_file]); % Crea una nuova finestra
imshow(img_da_mostrare); % Mostra l'immagine a schermo
hold on; % Congela l'immagine di sfondo per poterci disegnare sopra

% Usa il comando plot per disegnare un asterisco rosso ('r*') sulle coordinate estratte
plot(centro_x, centro_y, 'r*', 'MarkerSize', 10, 'LineWidth', 2); 

title(['Centroide della lesione (X: ' num2str(round(centro_x)) ', Y: ' num2str(round(centro_y)) ')']);
hold off; % Rilascia l'immagine