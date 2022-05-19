//filtri:      strudenti anno n  (comando )
//             studenti media voti >n
//statistiche: n studenti fuori corso (comando 3)
//             media voti dei ragazzi all'anno n ()


//Scadenza 24/05 TUTTE LE FUNZIONI DEVONO ESSERE TERMINATE


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
    .ascii "3: Stampare gli studenti di un particolare anno\n"  //iterativo                          //Mario Bruno
    .ascii "4: Stampare gli studenti sopra una detrminata media\n"  //ricorsivo                      //Emanuele
    .ascii "5: Numero studenti fuori corso\n"   //statistica intero                                  //Marco e DavidePe
    .ascii "6: Media voti ragazzi di un particolare anno (double)\n"  //statistica double            //Marco e DavidePe
    .ascii "7: Scambiare due studenti\n"                                                               //Davide Pirrò e Daniele
    .asciz "0: Esci\n"

fmt_prezzo_medio: .asciz "\nNumero studenti fuori corso%d\n\n"
fmt_prezzo_medio_double: .asciz "\nMedia voti: %.2f\n\n"
fmt_fail_save_data: .asciz "\nImpossibile salvere i dati.\n\n"
fmt_fail_aggiungi_auto: .asciz "\nMemoria insufficiente. Eliminare uno studente, quindi riprovare.\n\n"
fmt_fail_calcola_prezzo_medio: .asciz "\nNessuno studente presente.\n\n"
fmt_scan_int: .asciz "%d"
fmt_scan_str: .asciz "%127s"
fmt_prompt_menu: .asciz "? "
fmt_prompt_matricola: .asciz "Matricola: "
fmt_prompt_nome: .asciz "Nome: "
fmt_prompt_voti: .asciz "Media-voti: "
fmt_prompt_anno: .asciz "Anno: "
fmt_prompt_index: .asciz "# (fuori range per annullare): "

fmt_promt_print_int: .ascii "%d\0"

fmt_prompt_: .asciz "Inserisci il numero dello studente da scambiare "
.align 2

.data
n_studente: .word 2


.equ max_studente, 5
.equ size_studente_matricola, 4
.equ size_studente_nome, 32
.equ size_studente_media_voti, 8
.equ size_studente_anno, 4
.equ offset_studente_matricola, 0
.equ offset_studente_nome, offset_studente_matricola + size_studente_matricola
.equ offset_studente_media_voti, offset_studente_nome + size_studente_nome + 4
.equ offset_studente_anno, offset_studente_media_voti + size_studente_media_voti
.equ studente_size_aligned, 56

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


.bss
tmp_str: .skip 128
tmp_int: .skip 8
//students: .skip studente_size_aligned * max_studente


//
.macro read_int prompt
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

.macro read_str prompt
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
    //bl load_data 

    

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
        //bl aggiungi_studente
            //prosegui se non aggiungi uno studente
        no_aggiungi_studente:
        
        //se 2 elimina studnete
        cmp x0, #2
        bne no_elimina_studenti
        //bl elimina_studenti
            //prosegui 
        no_elimina_studenti:

        //se 3 stampare gli studenti di un particolare anno
        cmp x0, #3
        bne no_stampa_studneti_anno
        //bl stampa_studneti_anno
        //prosegui
        no_stampa_studneti_anno:

        //se 4 stampare gli studenti sopra una determinata media
        cmp x0, #4
        bne no_studenti_sopra_media
        //bl studenti_sopra_media
        //prosegui
        no_studenti_sopra_media:

        //se 5 stampa numero studenti fuori corso
        cmp x0, #5
        bne no_stampa_fuori_corso
        //bl stampa_fuori_corso
        //prosegui 
        no_stampa_fuori_corso:

        //se 6 stampa media voti di un particolare anno
        cmp x0, #6
        bne no_stampa_media_part_anno
        //bl stampa_media_part_anno
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


// funzione per salvare su file i dati del nostro array
// input: niente
// outpit: niente nei registri, ma salva su file l'array degli studenti
.type save_data, %function
save_data:
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


// funzione per stampare il menu
// input: niente
// output: niente
.type print_menu, %function
print_menu:
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
        bge end_print_entries_loop //!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
        // stampa lo studente iesimo dell'array [dove i sta in x19]
        
        /*
        //questa funzione qui stampa di ogni iesimo-studente le sue informazioni
        mov x1, studente_size_aligned
        madd x0, x1, x19, x21  // x0 = x21 + (x1 * x19)  moltiplichiamo per i volte lo spazio che occupa ogni studente e aggiungiamo l'indirizzo di students così da ottenere l'indirizzo dell'iesimo studente

        
        ldr w1, [x0, offset_studente_matricola] //matricola
        add x2, x0, offset_studente_nome                //nome
        ldr d0, [x0, offset_studente_media_voti]        //media
        ldr w3, [x0, offset_studente_anno]              //anno
        adr x0, fmt_menu_entry  //indirizzo stringa da stampare
        bl printf
        */
        print w19
        // aumento l'indice con i+1 e conseguentemente modifico il puntatore allo studente in posizione i+1
        add w19, w19, #1
        add x21, x21, studente_size_aligned
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

// input: x0, l'address di students
.type scambia, %function
scambia:
    stp x29, x30, [sp, #-16]!
    stp x19, x20, [sp, #-16]!
    stp x21, x22, [sp, #-16]!

    //Questa funzione scannerizza due elementi

    read_int fmt_prompt_
    ldr x1, tmp_int 


    read_int fmt_prompt_
    ldr x2, tmp_int
    ldr x0, =students

    mov x19, x0 //in x19 l'indirizzo degli studenti
    mov x20, x1 //indice 1° studente
    mov x21, x2 //indice 2° studente
    //adr x22, temp

    // alloco la parte dello stack che uso per memorizzare temporaneamente studente0
    sub sp, sp, studente_size_aligned //è fatto con lo stack per flexare (esercizio di stile)

    mov x2, studente_size_aligned
    mov x0, sp               //in x0 abbiamo inserito lo stack pointer per salvare lo studente temporaneamente nello stack
    madd x1, x2, x20, x19    //in x1 abbiamo inserito l'indirizzo dello studente0 
    bl memcpy                //lo studente0 andrà nello stack

    //2°step  spostare lo studente1 in studnete0
    mov x2, studente_size_aligned
    madd x0, x1, x20, x19    //in x0 abbiamo inserito l'indirizzo dello studente0
    madd x1, x2, x21, x19    //in x1 abbiamo inserito l'indirizzo dello studente1
    bl memcpy                //lo studente1 andrà al posto di studente0
    
    //3° step spostare temp in studente1
    mov x2, studente_size_aligned
    madd x0, x2, x21, x19   // in x0 abbiamo inserito l'indirizzo dello studente1 
    mov x1, sp              // in x1 abbiamo inserito lo stack pointer
    bl memcpy               //lo studente0 salvato nello stack andrà al posto di studente1
    
    // dealloco la parte dello stack che ho usato per memorizzare temporaneamente studente0
    add sp, sp, studente_size_aligned
    // epilogo della funzione
    mov x0, #4
    ldp x21, x22, [sp], #16
    ldp x19, x20, [sp], #16
    ldp x29, x30, [sp], #16
    ret
    .size scambia, (. -scambia)
    