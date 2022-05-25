//Problemi:
//1) da file vuoto aggiungo uno studente non continua il programma

//Mattia e Davide funzioni mancano + fare molte prove

.section .rodata
    filename: .asciz "studenti.dat"
    read_mode: .asciz "r"
    write_mode: .asciz "w"
    fmt_menu_title:
        .ascii "**************************************************\n"
        .ascii "*** Studenti del corso di studi in informatica ***\n"
        .asciz "**************************************************\n"
    fmt_menu_line:
        .asciz "----------o---------------------------------o----------o------\n"
    fmt_menu_header:
        .asciz "MATRICOLA | NOME                            |MEDIA-VOTI|ANNO\n"
    fmt_menu_entry:
        .asciz "%06d    | %-32s|%-2.1f      |%-1d\n" 
        
    fmt_menu_options:                                                                                   
        .ascii "1: Aggiungi studente\n"                                                                  //Salvatore Biemonte  
        .ascii "2: Elimina studente\n"                                                                   //Mattia
        .ascii "3: Stampare gli studenti di un particolare anno (iterativo)\n"  //iterativo                          //Mario Bruno
        .ascii "4: Stampare gli studenti sopra una detrminata media (ricorsivo)\n"  //ricorsivo                      //Emanuele
        .ascii "5: Numero studenti fuori corso\n"   //statistica intero                                  //Marco e DavidePe
        .ascii "6: Media voti ragazzi di un particolare anno (double)\n"  //statistica double            //Marco e DavidePe
        .ascii "7: Scambiare due studenti\n"                                                             //Davide Pirrò e Daniele
        .asciz "0: Esci\n"

    fmt_nessuno_studente_trovato: .asciz "\n                --- Nessun risultato ---\n\n"
    fmt_prezzo_medio: .asciz "\nNumero studenti fuori corso%d\n\n"
    fmt_prezzo_medio_double: .asciz "\nMedia voti: %.2f\n\n"
    fmt_fail_save_data: .asciz "\nImpossibile salvere i dati.\n\n"
    fmt_fail_aggiungi_studente: .asciz "\nMemoria insufficiente. Eliminare uno studente, quindi riprovare.\n\n"     //MODIFICATO SI CHIAMAVA ANCORA AUTO, PER QUESTO SALVATORE L'AVEVA AGGIUNTA A PARTE
    fmt_fail_calcola_prezzo_medio: .asciz "\nNessuno studente presente.\n\n"
    fmt_scan_int: .asciz "%d"
    fmt_scan_double: .asciz "%lf"               //MODIFICATO AGGIUNTO PER SCANNERIZZARE I DOUBLE
    fmt_scan_str: .asciz "%127s"
    fmt_prompt_menu: .asciz "? "
    fmt_prompt_matricola: .asciz "Matricola: "
    fmt_prompt_nome: .asciz "Nome: "
    fmt_prompt_voti: .asciz "Media-voti: "
    fmt_prompt_anno: .asciz "Anno: "
    fmt_prompt_index: .asciz "# (fuori range per annullare): "
    fmt_prompt_: .asciz "Studente da scambiare:  "                                      //MODIFICATO MIGLIORATO IL NOME E RESO PIù SIMILE AGLI ALTRI PROMPT
            // MODIFICATO TOLTO fmt_prompt_print_int NON SERVIVA
    .align 2

.data
    n_studente: .word 0                                                                 //MODIFICATO IL PLACEHOLDER DEL NUMERO DI STUDENTI (QUELLO EFFETTIVO VIENE LETTO DAL FILE)

    // struttura studente, con relativi offset                                          //MODIFICATO Inseriti commenti
    .equ max_studente, 5
    .equ size_studente_matricola, 4
    .equ size_studente_nome, 32
    .equ size_studente_media_voti, 8
    .equ size_studente_anno, 4
    .equ offset_studente_matricola, 0
    .equ offset_studente_nome, offset_studente_matricola + size_studente_matricola
    .equ offset_studente_media_voti, offset_studente_nome + size_studente_nome + 4      // il quattro deriva dall'allineamento
    .equ offset_studente_anno, offset_studente_media_voti + size_studente_media_voti
    .equ studente_size_aligned, 56

    /*                                                          //MODIFICATO NON SERVONO PIù GLI STUDENTI DI BASE IN QUANTO SONO DIRETTAMENTE PRESENTI NEL FILE studenti.dat
    //questi sono due studenti, usateli se dovete fare prove
    .align 3
    students: .word 111111                              // align a 4 perché word=32 bit
            .asciz "Davide                         "  // aggiungiamo 32 byte quindi il totale è 36, resta allineato a 4
            .align 3                                  // allineo la memoria a 8, e aggiungo 4 byte per arrivare a 40
            .double 23.4                              // aggiungo 8 byte e arrivo a 48, allineato a 8
            .word 1                                   // è una word = 4 byte totale 52, allineato a 4
            .align 3

            .word 000000
            .asciz "Daniele                        "
            .align 3
            .double 25.6
            .word 2
            .align 3
    */
.bss

    tmp_str: .skip 128
    tmp_int: .skip 8
    tmp_double: .skip 8                                             //MODIFICATO AGGIUNTO tmp_double
    students: .skip studente_size_aligned * max_studente            //MODIFICATO DECOMMENTATO L'ARRAY IN QUANTO HO COMMENTATO QUELLO DI PROVA





.macro read_int prompt
    //macro per leggere un numero e salvarlo in tmp_int, oltre a metterlo in x0     //MODIFICATO RESO PIù PRECISO IL COMMENTO

    //stampa string
    adr x0, \prompt
    bl printf

    //scannerizza caricando in tmp_int
    adr x0, fmt_scan_int
    adr x1, tmp_int
    bl scanf
    //carica il valore scansionato in x0
    ldr x0, tmp_int
.endm

.macro read_double prompt
    //macro per leggere un numero e salvarlo in tmp_double, oltre che in d0         //MODIFICATO AGGIUNTA UNA MACRO PER SCANNERIZZARE I DOUBLE

    //stampa string
    adr x0, \prompt
    bl printf

    //scannerizza caricando in tmp_double
    adr x0, fmt_scan_double
    adr x1, tmp_double
    bl scanf
    //carica il valore scansionato in d0
    ldr d0, tmp_double
.endm

.macro read_str prompt
    // macro per leggere una stringa e salvarla in tmp_str      //MODIFICATO INSERITO COMMENTO

    //stampa string
    adr x0, \prompt
    bl printf

    //scannerizza caricando in tmp_str
    adr x0, fmt_scan_str
    adr x1, tmp_str
    bl scanf
.endm

.macro save_to item, offset, size
    //ciscuno studente occupa una determinata posizione nella ram, noi vogliamo salvare con questa funzione un singolo elemento che compone lo studente
    //in x0 andrà la posizione nella ram dell'elemento da salvare per studente (intendiamo per elemento ciò che compone uno
    // studente dunque: matricola, nome, media moti, anno)

    add x0, \item, \offset
    //in x1 andrà l'indirizzo della stringa dell'elemento da salvare
    ldr x1, =tmp_str
    //in posizione x2 qunato spazio allocare per questo elemento da salvare
    mov x2, \size
    //questa funzione richiede in posizione x0 la destinazione, in x1: cio da salvare, in x2: la dimensione
    bl strncpy

    add x0, \item, \offset + \size - 1
    strb wzr, [x0]
.endm
.macro print index
    // macro per stampare uno studente //MODIFICATO AGGIUNTO IL COMMENTO PER SPECIFICARE COSA FA LA MACRO

    ldr x0, =students   //carica in x0 l'indirizzo della memoria ram dove ci stanno gli studenti 
    mov x1, studente_size_aligned   //x1=56 per quanta memoria occupata per studente
    mov w2, \index               //lo studente n°?
    madd x0, x1, x2, x0  // x0 = x0 + (x1 * x2) //in x0 ora ci sarà l'indirizzo dello studente iesimo

    ldr w1, [x0, offset_studente_matricola] //in x1 c'è l'indirizzo dello studente iesimo (prendi fino a \0 ovvero end-string) non è caricato in un registro poichè stringa non entra in registro 64 bit
    add x2, x0, offset_studente_nome
    ldr d0, [x0, offset_studente_media_voti]
    ldr w3, [x0, offset_studente_anno]
    adr x0, fmt_menu_entry
    bl printf
.endm



.text
.type main, %function
.global main
main:
    stp x29, x30, [sp, #-16]!

    //caricamento dati dal file, appena avvi l'applicazione parti dai dati precedenti
    bl load_data                                            // MODIFICATO DECOMMENTATA QUESTA PARTE E PROVATO IL SALVATAGGIO E LA LETTURA DA FILE: FUNZIONANO
    main_loop:
        //stampa l'interfaccia utente
        bl print_menu
        //legge la scelta che si fa nel munù
        read_int fmt_prompt_menu

        
        //se è 0 esci
        cmp x0, #0
        beq end_main_loop
        
        //se 1 aggiungi uno studente
        cmp x0, #1
        bne no_aggiungi_studente
        bl aggiungi_studente                          //MODIFICATO DECOMMENTATO DATO CHE ABBIAMO AGGIUNTO LA FUNZIONE DI SALVATORE
        //prosegui se non aggiungi uno studente
        no_aggiungi_studente:
        
        //se 2 elimina studnete
        cmp x0, #2
        bne no_elimina_studenti
        bl elimina_studente
        //prosegui 
        no_elimina_studenti:

        //se 3 stampare gli studenti di un particolare anno
        cmp x0, #3
        bne no_stampa_studneti_anno
        bl print_anno
        //prosegui
        no_stampa_studneti_anno:


        //se 4 stampare gli studenti sopra una determinata media
        cmp x0, #4
        bne no_studenti_sopra_media
        bl print_tabella_media
        //prosegui
        no_studenti_sopra_media:

        //se 5 stampa numero studenti fuori corso
        cmp x0, #5
        bne no_stampa_fuori_corso
        bl FuoriCorso
        //prosegui 
        no_stampa_fuori_corso:

        //se 6 stampa media voti di un particolare anno
        cmp x0, #6
        bne no_stampa_media_part_anno
        bl print_studente_media//////////////////////////////////////////////////////////////non so quale funzione vada
        //prosegui 
        no_stampa_media_part_anno:

        //se 7 scambia due studenti
        cmp x0, #7
        bne no_scambia_due_studenti
        bl scambia
        //prosegui 
        no_scambia_due_studenti:

        b main_loop 
            
    end_main_loop:

    mov w0, #0
    ldp x29, x30, [sp], #16
    ret
    .size main, (. - main)





.type load_data, %function   
load_data:
    // funzione per caricare i dati del file all'inizio dell'applicazione
    // input: niente nei registri, i dati dal file; output: niente 
    stp x29, x30, [sp, #-16]!
    str x19, [sp, #-8]!
    
    //apre un file in sola lettura
    adr x0, filename
    adr x1, read_mode
    bl fopen

    //se non inserisci alcun file termina il programma
    cmp x0, #0
    beq end_load_data

    
    mov x19, x0

    //vedi quanti studneti ci sono nel file e carica questo valore in n_studente
    ldr x0, =n_studente //in x0 l'indirizzo della memoria dove caricaricare i dati, avevo lasciato nella porzione .bss
    mov x1, #4          //è un intero, quindi occuperà 4 byte
    mov x2, #1          //è solo un numero
    mov x3, x19
    bl fread
    
    //carica gli n_studenti nella porzione di spazio students predichiarata nel .bss
    ldr x0, =students   //in x0 l'indirizzo della memoria dove caricaricare i dati, avevo lasciato nella porzione .bss
    mov x1, studente_size_aligned   //quanto spazio ciascuno studente occupa
    mov x2, max_studente            //prendo un determinato numero di elemeti prefissato dal file (per una questione di sicurezza)
    mov x3, x19
    bl fread

    mov x0, x19
    bl fclose

    end_load_data:

    ldr x19, [sp], #8
    ldp x29, x30, [sp], #16
    ret
    .size load_data, (. - load_data)



.type save_data, %function
save_data:
    // funzione per salvare su file i dati del nostro array
    // input: niente
    // outpit: niente nei registri, ma salva su file l'array degli studenti
    //prologo della funzione
    stp x29, x30, [sp, #-16]!
    str x19, [sp, #-8]!
    // apro il file in modalità scrittura
    adr x0, filename
    adr x1, write_mode
    bl fopen
    // controllo che il file si sia aperto correttamente,
    // se non si è aperto correttamente salto alla stampa dell'errore
    cmp x0, #0
    beq fail_save_data
        // sposto il puntatore al file in un registro non volatile
        mov x19, x0
        // salvo prima nel file il numero di studenti che ci sono nell'array
        ldr x0, =n_studente
        mov x1, #4
        mov x2, #1
        mov x3, x19
        bl fwrite
        // salvo adesso l'array degli studenti
        ldr x0, =students
        mov x1, studente_size_aligned
        mov x2, max_studente
        mov x3, x19
        bl fwrite
        // chiudo il file
        mov x0, x19
        bl fclose

        b end_save_data // salto alla fine della funzione per evitare la stampa dell'errore

    //se il file non si è aperto correttamente stampa la stringa fmt_file_save_data
    fail_save_data:
        adr x0, fmt_fail_save_data
        bl printf

    end_save_data:
    // epilogo della funzione
    ldr x19, [sp], #8
    ldp x29, x30, [sp], #16
    ret
    .size save_data, (. - save_data)



.type print_menu, %function
print_menu:
    // funzione per stampare il menu
    // input: niente
    // output: niente
    // prologo della funzione
    stp x29, x30, [sp, #-16]!
    stp x19, x20, [sp, #-16]!
    stp x21, x22, [sp, #-16]!
    
    // stampo il titolo del programma
    adr x0, fmt_menu_title
    bl printf
    // stampo gli header della tabella dei dati
    adr x0, fmt_menu_line
    bl printf
    adr x0, fmt_menu_header
    bl printf
    adr x0, fmt_menu_line
    bl printf
    // loop per stampare gli studenti nell'array
    mov w19, #0              // indice del ciclo
    ldr w20, n_studente      // numero degli studenti
    ldr x21, =students       // puntatore all'array degli studenti
    print_entries_loop:
        // controllo del ciclo
        cmp w19, w20
        bge end_print_entries_loop //!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!               //DOMANDA PERCHè I PUNTI ESCLAMATIVI
        // stampa lo studente iesimo dell'array [dove i sta in x19]        
        /*
        //questa funzione qui stampa di ogni iesimo-studente le sue informazioni
        mov x1, studente_size_aligned
        madd x0, x1, x19, x21  // x0 = x21 + (x1 * x19)  moltiplichiamo per i volte lo spazio che occupa ogni studente e aggiungiamo l'indirizzo di students così da ottenere l'indirizzo dell'iesimo studente
        //inserisco nei registri i campi dello studente
        ldr w1, [x0, offset_studente_matricola] //in x1 c'è l'indirizzo dello studente iesimo (prendi fino a \0 ovvero end-string) non è caricato in un registro poichè stringa non entra in registro 64 bit
        add x2, x0, offset_studente_nome
        ldr d0, [x0, offset_studente_media_voti]
        ldr w3, [x0, offset_studente_anno]
        adr x0, fmt_menu_entry
        bl printf
        */
        print w19
        // aumento l'indice con i+1                                                     //MODIFICATO QUESTA PARTE, ORA IL CODICE COMMENTATO NON è USATO, SI USA LA MACRO AL SUO POSTO
        add w19, w19, #1
        b print_entries_loop
    end_print_entries_loop:

    //stampa una linea di trattini
    adr x0, fmt_menu_line
    bl printf
    
    //stampa le opzioni possibili
    adr x0, fmt_menu_options
    bl printf
    
    // epilogo della funzione
    ldp x21, x22, [sp], #16
    ldp x19, x20, [sp], #16
    ldp x29, x30, [sp], #16
    ret
    .size print_menu, (. - print_menu)

.type aggiungi_studente, %function
aggiungi_studente:
    // funzione per aggiungere uno studente all'array           //MODIFICATO AGGIUNTA LA FUNZIONE (DI SALVATORE) AL FILE E AGGIUNTI I COMMENTI CHE SPECIFICANO INPUT ED OUTPUT

    stp x29, x30, [sp, #-16]!
    stp x19, x20, [sp, #-16]!
    
    ldr x19, n_studente             //x19 contiene il numero degli studenti inseriti
    ldr x20, =students              //x20 l'adress nella ram corrispondente agli studenti
    mov x0, studente_size_aligned   //quanto occupa uno studente
    mul x0, x19, x0                 // DOMANDA, SI PUò METTERE madd AL POSTO DI QUESTE DUE RIGHE (questa e quella sotto)
    add x20, x20, x0                //queste due servono per avere in x20 l'indirizzo dell'iesimo studente
    
    
    cmp x19, max_studente           //compare tra il numero max di studenti che si possono inserire e gli studenti correnti
    bge fail_aggiungi_studente      // se NumeroStudentiMax < NumeroStudentiCorrenti, l'inserimento non potrà avvenire


        read_int fmt_prompt_matricola               //inserimento della matricola
        str w0, [x20, offset_studente_matricola]    //salvo la matricola nella ram 


        read_str fmt_prompt_nome                                //inserimmento del nome
        save_to x20, offset_studente_nome, size_studente_nome   //salvo il nome nella ram

        // MODIFICATO AGGIUNTA LA LETTURA DI UN FLOAT
        read_double fmt_prompt_voti                             //inserimento della media voti              //DOMANDA SE AL POSTO DELLA VIRGOLA INSERISCO UN PUNTO CRASHA (VA IN LOOP INFINITO). PERCHé?
        str d0, [x20, offset_studente_media_voti]               // salvo la media voti nella ram

        read_int fmt_prompt_anno                                //inserimento dell'anno 
        str w0, [x20, offset_studente_anno]                     //salvo l'anno nella ram

        add x19, x19, #1                                        //il numero degli studenti inseriti viene incrementato di 1
        ldr x20, =n_studente                                    //in x20 salvo l'indirizzo della ram che si occupa solo del numero degli studenti
        str x19, [x20]                                          //carico il numero aggiornato nella ram che si occupa solo del numero degli studenti

        bl save_data                                            //salva i dati nel file

        b end_aggiungi_studente
    fail_aggiungi_studente:
        adr x0, fmt_fail_aggiungi_studente  //stampa in caso il numero di studenti è troppo
        bl printf
    end_aggiungi_studente:

    ldp x19, x20, [sp], #16
    ldp x29, x30, [sp], #16
    ret
    .size aggiungi_studente, (. - aggiungi_studente)


.type scambia, %function
scambia:


    // input: niente                       //MODIFICATO TOLTI I DATI IN INPUT (non ce n'è bisogno)
    stp x29, x30, [sp, #-16]!
    stp x19, x20, [sp, #-16]!
    str x21, [sp, #-8]!               //MODIFICATO TOLTO IL REGISTRO X22 CHE NON SERVIVA

    //Questa funzione scannerizza due elementi

    read_int fmt_prompt_
    ldr w20, tmp_int        //w20=1

    read_int fmt_prompt_
    ldr w21, tmp_int        //w21=2

    // ordino gli indici inseriti in ordine crescente
    cmp w20, w21
    ble endif_scambia
    mov w0, w20
    mov w20, w21
    mov w21, w0
    endif_scambia:

    ldr x19, =students //in x19 l'indirizzo degli studenti
    //adr x22, temp

    // alloco la parte dello stack che uso per memorizzare temporaneamente studente0
    sub sp, sp, studente_size_aligned //è fatto con lo stack per flexare (esercizio di stile)
    
    //1°step  spostare lo studente0 nello stack
    mov w2, studente_size_aligned
    mov x0, sp               //in x0 abbiamo inserito lo stack pointer per salvare lo studente temporaneamente nello stack
    umaddl x1, w2, w20, x19    //in x1 abbiamo inserito l'indirizzo dello studente0 
    bl memcpy                //lo studente0 andrà nello stack

    //2°step  spostare lo studente1 in studnete0
    mov w2, studente_size_aligned
    umaddl x0, w1, w20, x19    //in x0 abbiamo inserito l'indirizzo dello studente0
    umaddl x1, w2, w21, x19    //in x1 abbiamo inserito l'indirizzo dello studente1
    bl memcpy                //lo studente1 andrà al posto di studente0

    //3° step spostare temp in studente1
    mov w2, studente_size_aligned
    umaddl x0, w2, w21, x19   // in x0 abbiamo inserito l'indirizzo dello studente1 
    mov x1, sp              // in x1 abbiamo inserito lo stack pointer
    bl memcpy               //lo studente0 salvato nello stack andrà al posto di studente1
    // dealloco la parte dello stack che ho usato per memorizzare temporaneamente studente0
    add sp, sp, studente_size_aligned
    bl save_data                        // MODIFICATO AGGIUNTA LA CHIAMATA ALLA SUBROUTINE SAVE_DATA PERCHè MODIFICHIAMO L'ARRAY (ALVIANO L'HA MESSO INFATTI NELLE FUNZIONI IN CUI L'ARRAY VIENE MODIFICATO)
    // epilogo della funzione
    mov x0, #4
    ldr x21, [sp], #8                   // MODIFICATO TOLTO IL REGISTRO X22
    ldp x19, x20, [sp], #16
    ldp x29, x30, [sp], #16
    ret
    .size scambia, (. -scambia)


.type print_tabella_media, %function
print_tabella_media:
    // prologo della funzione
    stp x29, x30, [sp, #-16]!
    stp x19, x20, [sp, #-16]!
    stp x21, x22, [sp, #-16]!
 
    //creato fmt: fmt_prompt_media_studenti
    //ricevo la media minima in x0
    //read_int fmt_prompt_media_studenti

    
    //sposto la media minima e la converto in float
    //scvtf d0, x0
    read_double fmt_prompt_voti                             //inserimento della media voti              //DOMANDA SE AL POSTO DELLA VIRGOLA INSERISCO UN PUNTO CRASHA (VA IN LOOP INFINITO). PERCHé?
    fmov d8, d0

    
    // stampo gli header della tabella dei dati
    adr x0, fmt_menu_line
    bl printf
    adr x0, fmt_menu_header
    bl printf
    adr x0, fmt_menu_line
    bl printf
    


    // loop per stampare gli studenti nell'array
    mov x19, #0              // indice del ciclo
    ldr x20, n_studente      // numero degli studenti
    ldr x21, =students       // puntatore all'array degli studenti
    // x1 è la dimensione di uno studente
    //mov x1, studente_size_aligned
    bl print_studente_media
    

    //stampa una linea di trattini
    adr x0, fmt_menu_line
    bl printf
 


    // epilogo della funzione
    ldp x21, x22, [sp], #16
    ldp x19, x20, [sp], #16
    ldp x29, x30, [sp], #16
    mov x0, #4
    ret
    .size print_tabella_media, (. - print_tabella_media)
 
 
.type print_studente_media, %function
print_studente_media:

    stp x29, x30, [sp, #-16]!
    stp x19, x20, [sp, #-16]!

    //controllo il caso di uscita: contatore = ultimo elemento
    //x19= contatore iesimo studente
    //x20= numero studneti totali
    //x1= dimensione studente
    //x21= posizione iniziale studenti nella ram
    //d0 la media minima
    base:
        cmp x19, x20
        beq exit
    controllo:
        mov x1, studente_size_aligned
        //x0 = posizione attuale
        madd x0, x1, x19, x21
        //d1 la media dello studente attuale
        ldr d1, [x0, offset_studente_media_voti]
        fcmp d1, d8

        
        bge bStampa

    ricorsione:
        add x19, x19, #1
        bl print_studente_media
        b exit
    bStampa:
        print w19
        b ricorsione
    exit:

    ldp x19, x20, [sp], #16
    ldp x29, x30, [sp], #16
    ret
    .size print_studente_media, (. - print_studente_media)

.type FuoriCorso, %function
FuoriCorso:

    // prologo della funzione
    stp x29, x30, [sp, #-16]!
    adr x0, students                                // inserisco in x0 l'indirizzo di students
    ldr w3, n_studente                              // inserisco in w3 il numero degli studenti
    mov x5, studente_size_aligned                   // inserisco in x5 studente_size_aligned che dopo mi servirà per passare da uno studente al successivo
    mov x2, #0                                      // x2 contiene l'indice del ciclo
    mov w1, #0                                      // w3 contiene il numero di studenti fuori corso
    loop:
        cmp w2, w3                                  // controlli del ciclo (dato che è un pre-tested loop sono all'inizio)
        beq endloop
        madd x4, x5, x2, x0                         // inserisco in x4 l'indirizzo dello studente iesimo
        ldr w4, [x4, offset_studente_anno]          // carico in w4 l'anno dello studente iesimo
        cmp w4, #4                                  // confronto l'anno dello studente iesimo (contenuto in w4) con 4 (che è l'anno minimo per essere fuoricorso)
        blt no_fuori_corso                          // se non è fuoricorso (anno < 4) allora salto alla fine dell'if
            add w1, w1, #1                          // se è fuoricorso incremento il contatore degli studenti fuoricorso
        no_fuori_corso:
        add x2, x2, #1                              // incremento il contatore del ciclo
        b loop                                      // torno all'inizio del loop
    endloop:
    adr x0, fmt_studenti_fuoricorso                 // stampo il numero di studenti fuoricorso
    bl printf
    // epilogo della funzione
    ldp x29, x30, [sp], #16
    ret
    .size FuoriCorso, (. -FuoriCorso)
.type print_anno, %function
print_anno:

    // prologo della funzione
    stp x29, x30, [sp, #-16]!
    stp x19, x20, [sp, #-16]!
    stp x21, x22, [sp, #-16]!
    stp x23, x24, [sp, #-16]!

    read_int fmt_prompt_anno                // leggo da input l'anno di cui stampare gli studenti (lo trovo in x0)
    mov x19, x0                             // lo salvo in x19 per evitare di perderlo con printf

    //stampo gli header
    adr x0, fmt_menu_line
    bl printf
    adr x0, fmt_menu_header
    bl printf
    adr x0, fmt_menu_line
    bl printf

    ldr x20, n_studente                     // carico il numero degli studenti in x20
    mov x21, #0                             // i = 0 è l'indice del ciclo
    ldr x22, =students                      // carico in x22 il puntatore all'array contenente gli studenti
    mov x23, studente_size_aligned          // carico in x23 la dimensione di uno studente
    mov x24, #0                             // variabile per nessun risultato trovato
    
    p_a_loop:
        cmp x21, x20                        // if x21 - x20 == 0
        beq p_a_exit                        // se la condizione è vera allora il ciclo è finito ed esco dal loop
    p_a_exe:
        madd x5, x21, x23, x22              // carico in x5 il puntatore allo studente iesimo
        ldr x6, [x5, offset_studente_anno]  // carico l'anno dello studente iesimo
        cmp x19, x6                         // se l'anno dello studente è uguale all'anno inserito da tastiera continua
        bne p_a_end                         // altrimenti salta la print
        print w21                           // stampa lo studente che appartiene all'anno inserito
        add x24, x24, #1                    // tramite questa operazione capisco se almeno uno studente è stato stampato
                                            // nel caso in cui dovesse essere 0, stamperà 'Nessun risultato trovato!
    p_a_end:
        add x21, x21, #1                    // incremento il contatore del ciclo
        b p_a_loop                          // salto all'inizio del loop
    p_a_exit:                               // fine del loop
        cmp x24, #0                         // se ho stampato almeno uno studente continuo ad p_a_exit2
        beq p_a_no_results                  // altrimenti stampo p_a_no_results
        b p_a_exit2
    p_a_no_results:
        adr x0, fmt_nessuno_studente_trovato
        bl printf                           // stampo fmt_nessun_risultato_trovato
    p_a_exit2:
        adr x0, fmt_menu_line
        bl printf                           // stampo la linea per finire la tabella

    // epilogo della funzione
    ldp x23, x24, [sp], #16
    ldp x21, x22, [sp], #16
    ldp x19, x20, [sp], #16
    ldp x29, x30, [sp], #16
    ret
    .size print_anno, (. - print_anno)

.type elimina_studente, %function
elimina_studente:
       stp x29, x30, [sp, #-16]!
    
    read_int fmt_prompt_index //in x0 andà lo studente da eliminare

    cmp x0, 0
    blt end_elimina_studente  //se il numero inserito è minore di 1: esci dalla funzione


    ldr x1, n_studente        //in x1 andrà il numero di tutti gli studenti
    sub x1, x1, 1             //diminuisco di 1 perchè iniziando a contare da 0 il numero di indice massimo sarà ntot-1
    cmp x0, x1
    bgt end_elimina_studente  //se x0>x1 esci dalla funzione

    //per fare l'eliminazione sposteremo gli elemnti da x0 in poi di una posizione in meno e ridurremo il numero di studenti di 1
    //sub x5, x0, 1   // questa cosa non va bene perchè è come se il primo elemnto fosse l'elemnto 1 quando noi vogliamo sia l'elemento 0
    mov x5, x0 //in x5 ho la posizione dove verranno spostati i dati (copio il numero dello studente)
    ldr x6, n_studente  //in x6 il numero totale degli studenti
    sub x6, x6, x0  // numero di studenti che dobbiamo spostare (qualli >x0)
    mov x7, studente_size_aligned
    ldr x0, =students
    madd x0, x5, x7, x0 //in x0 metto la destinazione (dove dovranno essere incollati ergo nello studente da elimare)
    add x1, x0, x7      //in x1 l'indirizzo del primo studente del blocco da copiare
    mul x2, x6, x7      //quanti byte copiare 
    bl memcpy

    //aggiorno il numero degli studenti
    ldr x0, =n_studente 
    ldr x1, [x0]
    sub x1, x1, #1
    str x1, [x0]

    bl save_data

    end_elimina_studente:
    
    ldp x29, x30, [sp], #16
    ret
    .size elimina_studente, (. - elimina_studente)

.type MediaVoti, %function
MediaVoti:
    // prologo della funzione
    stp x29, x30, [sp, #-16]!
    read_int fmt_prompt_anno                    //serve per prendere in input l'anno richiesto
    mov w2, #0
    scvtf d2, w2                                //somma delle medie dei voti degli studenti dell'anno preso in input
    mov w3, #0                                  //numero degli studenti di quell'anno
    mov w4, #0                                  //indice del loop
    ldr w5, n_studente                          //numero di tutti gli studenti
    adr x6, students                            //primo studente
    mov w7, studente_size_aligned
    loop:
    cmp w4, w5                                  //condizione di uscita dal loop
    beq endloop                                 //se sono identici
                                                //vedere se l'alunno appartiene all'anno dato in input
    umaddl x8, w7, w4, x6                         // inserisco in x8 l'indirizzo dello studente iesimo
    ldr x9, [x8, offset_studente_anno]          // carico in x9 l'anno dello studente iesimo
    cmp x9, x0
    bne true   
        //se lo studente appartiene all'anno scelto
        add w3, w3, #1                          //incrementa il numero degli studenti di quell'anno
        ldr d9, [x8, offset_studente_media_voti]//media dei voti dello studente i-esimo
        fadd d2, d2, d9                         //incrementa la somma delle medie dei voti
    true:
    add w4, w4, #1                                  //incremento il contatore
    //cmp w4, x5                                //condizione di uscita dal loop
    //bls loop                                  //se w4 è minore ripeti il loop
    b loop
    endloop:
    scvtf d3, w3
    mov w1, w3
    fdiv d0, d2, d3                             //divido la somma delle medie dei voti con il numero degli studenti dell'anno in input
    //adr x0, fmt_scan_int               //modificare il format
    adr x0, fmt_media_voti_double
    bl printf
    // epilogo della funzione
    ldp x29, x30, [sp], #16
    ret
    .size MediaVoti, (. -MediaVoti)