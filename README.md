# 🧠 Segmentazione e Analisi Morfologica di Lesioni in Risonanza Magnetica (MRI)

### 📖 Descrizione
Questo repository contiene un progetto per il corso di **Laboratorio di Elaborazione delle Immagini**. L'obiettivo è l'implementazione in **MATLAB** di un algoritmo per il processamento di immagini mediche (rigorosamente senza l'uso di IA), finalizzato alla rimozione della scatola cranica (*skull stripping*) e alla segmentazione di anomalie strutturali.

### 🛠️ Tecniche Implementate
L'algoritmo è suddiviso in due moduli operativi paralleli:
1. **Pre-elaborazione ed Enfatizzazione:**
   - Miglioramento del contrasto tramite correzione Gamma, trasformazioni logaritmiche e *stretching* dell'istogramma (`imadjust`, `imhist`).
   - Filtraggio del rumore tramite filtri spaziali di *smoothing* (`imfilter`, `fspecial`) e filtraggio nel dominio della frequenza (`fft2`, `ifft2`).
   - Enfatizzazione basata sull'uso di statistiche locali (media e varianza calcolate a blocchi) per far emergere i dettagli a basso contrasto.
2. **Segmentazione e Morfologia Matematica:**
   - **Skull Stripping:** Binarizzazione dell'immagine (`graythresh`, operatori logici `>`) e pulizia delle connessioni per isolare il cervello.
   - **Estrazione e Ricostruzione:** Utilizzo di elementi strutturanti (`strel`) per operazioni di erosione e dilatazione. Estrazione finale delle masse anomale tramite la **Ricostruzione Morfologica** (`imreconstruct`), fondamentale per preservare la topologia esatta dell'oggetto filtrando il rumore.
   - **Edge Detection:** Individuazione del perimetro tramite operatori di gradiente (es. Sobel).

### 📊 Validazione Quantitativa
I risultati vengono validati quantitativamente confrontando le maschere binarie preditte con i **Ground Truth** medici:
- Calcolo dell'Errore Quadratico Medio (**MSE**) per quantificare la similarità tra la predizione e il riferimento.
- Matrice di confusione dei pixel tramite operatori logici.
- Valutazione topologica e conteggio automatico delle regioni connesse (lesioni) tramite la funzione `bwconncomp`.

### 📂 Struttura della Repository
* `Dataset/`: Scansioni MRI in input e maschere Ground Truth.
* `Src/`: File sorgente MATLAB (`.m`), inclusi script e funzioni.
* `Workspace/`: Variabili di sessione e dati intermedi.
* `Results/`: Maschere finali, immagini processate e metriche d'errore.
