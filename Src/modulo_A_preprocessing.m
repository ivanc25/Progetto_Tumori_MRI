function img_out = modulo_A_preprocessing(img_in)
% =========================================================================
% Modulo A - Pre-elaborazione (Responsabilità Ivan Colella)
% Implementazione: Filtraggio FFT2 ed Enfatizzazione con Statistica Locale
% =========================================================================

    %% --- 1. Creazione filtro ---
    dim_finestra = 5; 
    h = fspecial('average', [dim_finestra dim_finestra]);
    
    [M, N] = size(img_in); 
    [P, Q] = size(h);
    
    %% --- 2. Filtraggio in Frequenza ---
    rows = M + P - 1; 
    cols = N + Q - 1;
    
    F = fft2(img_in, rows, cols); 
    H = fft2(h, rows, cols); 
    G = F .* H; 
    
    conv_freq = real(ifft2(G)); 
    img_smoothed = conv_freq(1:M, 1:N); 
    
    %% --- 3. Statistica Locale ---
    % Calcolo media e deviazione standard globali dell'immagine filtrata
    med_globale = mean2(img_smoothed);
    dev_globale = std2(img_smoothed);
    
    % Definizione delle funzioni anonime per blockproc
    fun_mean = @(block_struct) mean2(block_struct.data) * ones(size(block_struct.data));
    fun_std  = @(block_struct) std2(block_struct.data) * ones(size(block_struct.data));
    
    % Applicazione di blockproc a blocchi 8x8
    dim_blocco = [8 8];
    MED_locale = blockproc(img_smoothed, dim_blocco, fun_mean);
    DEV_locale = blockproc(img_smoothed, dim_blocco, fun_std);
    
    % Parametri di soglia per la statistica locale
    k0 = 0.4;
    k1 = 0.0005;
    k2 = 0.4;
    A = 4; % Fattore di amplificazione
    
    % Creazione della Maschera Logica (Aree scure e basso contrasto)
    media_mask = (MED_locale <= k0 * med_globale);
    vari_mask = (DEV_locale <= k2 * dev_globale) & (DEV_locale >= k1 * dev_globale);
    Mask = media_mask .* vari_mask; 
    
    % Amplificazione finale dei pixel selezionati
    img_out = img_smoothed + A * img_smoothed .* double(Mask);
end