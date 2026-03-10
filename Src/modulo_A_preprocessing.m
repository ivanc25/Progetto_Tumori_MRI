function img_out = modulo_A_preprocessing(img_in)
% =========================================================================
% Funzione modulo_A_preprocessing.m (Responsabilità Studente 1)
% Input: img_in (immagine double nel range )
% Output: img_out (immagine filtrata ed enfatizzata)
% =========================================================================

    % 1. Rimozione del rumore tramite Filtro Media (Smoothing) [5]
    % Creiamo una maschera di convoluzione (kernel) per fare smoothing
    dim_finestra = 5; 
    h = fspecial('average', [dim_finestra dim_finestra]);
    img_smoothed = imfilter(img_in, h, 'symmetric', 'same'); % 'same' mantiene le dimensioni [5, 8]
    
    % 2. Enfatizzazione del Contrasto tramite Legge di Potenza (Gamma) [7, 9]
    % s = c * r^gamma. Aiuta ad esaltare le zone iperintense (tumore) oscurando i tessuti sani
    gamma = 1.5; % Un valore gamma > 1 scurisce i mezzitoni [7]
    c = 1;
    img_out = c * (img_smoothed .^ gamma);
    
    % (Opzionale: qui in futuro lo Studente 1 potrà implementare 
    % il filtraggio in frequenza con fft2 [4] per confrontare i risultati)
end