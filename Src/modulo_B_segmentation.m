function [brain_mask, tumor_mask] = modulo_B_segmentation(img_in)
% =========================================================================
% Funzione modulo_B_segmentation.m (Responsabilità Studente 2)
% Input: img_in (immagine pre-elaborata)
% Output: brain_mask (maschera del solo cervello), tumor_mask (maschera del tumore)
% =========================================================================

    %% STEP 1: Skull Stripping
    % Binarizzazione per isolare la testa usando il metodo Otsu [6]
    t = graythresh(img_in);
    bw_head = img_in > t; % Matrice logica [6]
    
    % Riempiamo i buchi all'interno della maschera [11]
    bw_filled = imfill(bw_head, 'holes');
    
    % Usiamo un'apertura per rimuovere connessioni al cranio o rumore [10, 12]
    se_brain = strel('disk', 5);
    brain_mask = imopen(bw_filled, se_brain);
    
    % Intensity Masking: Moltiplichiamo per estrarre solo il cervello in scala di grigi [3]
    brain_only = img_in .* brain_mask; 
    
    %% STEP 2: Segmentazione del Tumore
    % Ricalcoliamo una soglia solo sui pixel del cervello (che sono > 0)
    brain_pixels = brain_only(brain_mask > 0);
    t_tumor = graythresh(brain_pixels);
    
    % Binarizziamo per trovare le zone più luminose (possibile tumore)
    bw_tumor_iniziale = brain_only > t_tumor;
    
    %% STEP 3: Apertura tramite Ricostruzione Morfologica [10]
    % Creiamo il marker erodendo per eliminare falsi positivi (rumore piccolo)
    se_tumor = strel('disk', 3);
    marker = imerode(bw_tumor_iniziale, se_tumor);
    
    % Ricostruiamo esattamente la forma originale partendo dal marker [10]
    % imreconstruct preserva i bordi meglio di una semplice dilatazione
    tumor_mask = imreconstruct(marker, bw_tumor_iniziale);
end