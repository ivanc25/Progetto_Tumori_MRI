# 🧠 Segmentazione Automatica di Lesioni Cerebrali tramite Morfologia Matematica e Sogliatura Iterativa

📖 **Descrizione**
Questo repository contiene il progetto finale per il corso di Laboratorio di Elaborazione delle Immagini. L'obiettivo è lo sviluppo in ambiente MATLAB di una pipeline algoritmica non supervisionata (senza l'ausilio di IA) per l'isolamento, la segmentazione e l'estrazione delle feature cliniche di masse tumorali da un dataset di 169 scansioni di Risonanza Magnetica (MRI). L'architettura supera i limiti dei filtri standard implementando l'elaborazione statistica locale per l'enfatizzazione del contrasto e operatori morfologici avanzati per l'estrazione esatta dei contorni.

🛠️ **Tecniche Implementate e Architettura**
Il processo è centralizzato nel file `main.m`, il quale orchestra l'elaborazione batch automatizzata basata sull'ordine cronologico dei file. L'algoritmo è suddiviso in due moduli operativi principali:

**Modulo A: Pre-elaborazione ed Enfatizzazione Adattiva**
*   **Filtraggio in Frequenza:** Rimozione del rumore di fondo operando nel dominio delle frequenze tramite Trasformata di Fourier bidimensionale (`fft2`, `ifft2`) e applicazione di un filtro passa-basso.
*   **Statistica Locale (Block Processing):** Superamento delle limitazioni della Correzione Gamma globale tramite l'elaborazione a blocchi (`blockproc`). Calcolando dinamicamente la media e la varianza locale (`mean2`, `std2`), il modulo isola e amplifica selettivamente le sole regioni scure e a basso contrasto in cui si annida la lesione.

**Modulo B: Segmentazione Morfologica e Analisi dei Contorni**
*   **Sogliatura Statistica e Skull Stripping:** Utilizzo di tecniche di smoothing (`imfilter`) seguite da un'analisi statistica dell'intensità del tessuto cerebrale per separare autonomamente la massa dalla scatola cranica.
*   **Ricostruzione Morfologica:** Invece delle semplici erosioni/dilatazioni, il core iperintenso del tumore viene isolato in modo robusto tramite la Ricostruzione Morfologica (`imreconstruct`), sfruttando soglie confidenziali per l'immagine *Marker* e *Mask* al fine di ripristinare l'esatta topologia medica della lesione ignorando il rumore circostante.
*   **Pulizia e Post-Processing:** Isolamento definitivo della ROI tramite l'analisi delle componenti connesse (`bwconncomp`) e operatori morfologici per la chiusura di buchi interni (`imfill`) e smoothing dei bordi (`imopen`).
*   **Gradiente Morfologico e Thinning:** I confini del tumore vengono estratti sottraendo l'erosione dalla dilatazione della maschera finale. Per rispettare il criterio di risposta minima, il bordo viene assottigliato a un singolo pixel di spessore tramite l'operatore di scheletrizzazione (`bwmorph` con parametro `'thin'`).

📊 **Validazione Quantitativa e Feature Extraction**
I risultati elaborati su tutto il dataset vengono salvati in *Structure Arrays* (`struct`) e validati matematicamente contro le maschere di *Ground Truth*:

*   **Valutazione dell'Errore (MSE):** Calcolo dell'Errore Quadratico Medio totale per quantificare l'affidabilità della maschera generata.
*   **Estrazione Feature Cliniche (Centroidi):** Misurazione delle coordinate spaziali e del centro di massa della lesione tramite la funzione `regionprops` per valutarne le fluttuazioni in relazione all'errore algoritmico.
*   **Benchmark della "Good Localization":** Analisi critica comparativa dell'MSE sui bordi tra la nostra pipeline basata sul Gradiente Morfologico e il "Rivelatore Ottimale" di Canny.
*   **Profilazione Computazionale:** Tracciamento rigoroso dei tempi di calcolo per singolo modulo (`tic` e `toc`), a dimostrazione dell'altissima efficienza informatica della morfologia logica rispetto all'elaborazione in virgola mobile.

🚀 **Sviluppi Futuri Proposti**
In ottica di espansione, il progetto prevede l'eventuale integrazione teorica di:
1. Standardizzazione tramite *Histogram Matching*.
2. Equalizzazione locale tramite *CLAHE* (Contrast Limited Adaptive Histogram Equalization).
3. Estrazione dei dettagli silenti tramite trasformata *SMQT*.
4. Aumento dell'acutanza ai bordi (*Acutance*) tramite *Unsharp Masking*.

📂 **Struttura della Repository**
*   `Dataset/`: Cartella contenente la sottocartella `images/` (169 MRI originali) e le relative `masks/`.
*   `Src/`: File sorgente MATLAB (`.m`), inclusi il `main.m` orchestratore e le funzioni dei Moduli A e B.
*   `Src/results/`: Maschere generate successivamente all'applicazione dell'algoritmo di segmentazione.
*   `Src/workspace/`: Variabili di sessione e archivi `.mat` intermedi (Struct dei dati estratti).
