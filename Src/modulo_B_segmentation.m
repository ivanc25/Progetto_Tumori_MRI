function [brain_mask, tumor_mask, tumor_edges] = modulo_B_segmentation(img_in)
% =========================================================================
% Modulo B - Morfologia e Segmentazione (Responsabilità Andrea Patruno)
% Implementazione: Sogliatura Iterativa, Ricostruzione e Gradiente
% =========================================================================
   
    %% STEP 1: Sogliatura Iterativa
    % 1. Stima iniziale della soglia (metà della media dell'immagine)
    T1 = 0.5 * mean(img_in(:));
    done = false;

    % 5. Ciclo iterativo finché la differenza non scende sotto 0.5
    while ~done
        % 2. Partiziona l'immagine in due gruppi (foreground e background)
        g = img_in >= T1;
        % 3 e 4. Calcola le medie mu1 e mu2 delle partizioni e trova il nuovo T
        TNext = 0.5 * (mean(img_in(g)) + mean(img_in(~g)));
        % Valuta la condizione di arresto
        done = abs(T1 - TNext) < 0.5;
        T1 = TNext;
    end
    t = TNext; % La nostra soglia finale ottimizzata
    
    %% STEP 2: Skull Stripping  e Isolamento del Cervello
    % Binarizziamo la testa e riempiamo i buchi
    bw_head = img_in > t; 
    bw_filled = imfill(bw_head, 'holes'); 
    
    % Erodiamo pesantemente la maschera per tagliare via 
    % l'intera scatola cranica e il relativo bordo luminoso.
    % (Un disco di raggio 12 o 15 elimina fisicamente il perimetro esterno prima 5)
    se_erode = strel('disk', 12); 
    brain_mask = imerode(bw_filled, se_erode); 
    
    % Isoliamo solo il "cuore" del cervello, ora totalmente privo di cranio
    inner_brain = img_in .* double(brain_mask); 
    
    %% STEP 3: Ricostruzione Morfologica del Tumore
    % Estraiamo i pixel appartenenti solo al cuore del cervello
    inner_pixels = inner_brain(brain_mask);
    
    % Ora il tumore è garantito essere la parte più chiara.
    % Usiamo la funzione base di Otsu per trovare la soglia.
    t_tumor = graythresh(inner_pixels);
    
    % Creiamo il MARKER: i picchi certissimi del tumore (soglia alzata del 20%)
    marker = inner_brain > (t_tumor * 1.2);
    
    % Creiamo la MASK: l'area generale del tumore
    mask = inner_brain > t_tumor;
    
    % Ricostruzione Morfologica
    tumor_mask = imreconstruct(marker, mask);
    
    %% STEP 4: Post-Processing Morfologico (Pulizia)
    % 1. Riempi i buchi interni al tumore per renderlo un solido perfetto
    tumor_mask = imfill(tumor_mask, 'holes'); 
    
    % 2. Isola la massa più grande (rimozione dei falsi positivi sparsi)
    CC_noise = bwconncomp(tumor_mask); 
    if CC_noise.NumObjects > 1
        numPixels = cellfun(@numel, CC_noise.PixelIdxList);
        [~, idx_max] = max(numPixels);
        tumor_mask_pulita = false(size(tumor_mask));
        tumor_mask_pulita(CC_noise.PixelIdxList{idx_max}) = true;
        tumor_mask = tumor_mask_pulita;
    end
    
    % Apertura per levigare i bordi
    se_smooth = strel('disk', 3); 
    tumor_mask = imopen(tumor_mask, se_smooth); 
    
    %% STEP 5: Estrazione dei Contorni (Gradiente Morfologico)
    % Calcoliamo i bordi finali sulla maschera perfettamente pulita
    se_edge = ones(3,3); 
    bordi_spessi = imdilate(tumor_mask, se_edge) - imerode(tumor_mask, se_edge);
 
    % Applicazione del "Thinning" per garantire la Minimal Response (1 pixel)
    tumor_edges = bwmorph(bordi_spessi, 'thin', Inf); 
end