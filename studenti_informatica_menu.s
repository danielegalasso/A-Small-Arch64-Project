//filtri:      strudenti anno n  (comando )
//             studenti media voti >n
//statistiche: n studenti fuori corso (comando 3)
//             media voti dei ragazzi all'anno n ()

.section .rodata
filename: .asciz "studenti.dat"
read_mode: .asciz "r"
write_mode: .asciz "w"
fmt_menu_title:
    .ascii "**************************************************\n"
    .ascii "*** Studenti del corso di studi in informatica ***\n"
    .asciz "**************************************************\n"
fmt_menu_line:
    .asciz "--------------------------------------------------------------------\n"
fmt_menu_header:
    .asciz "  # MATRICOLA                NOME                MEDIA-VOTI                ANNO\n"
fmt_menu_entry:
    .asciz "%6d %-32s %-2.1f %-1d\n" //ATTENTO QUI CAPIRE COSA FARE
fmt_menu_options:                                                                                    //Salvatore Biemonte  //commentare funzioni save_data,read_data,print_menù
    .ascii "1: Aggiungi studente\n"                                                                  //Mattia
    .ascii "2: Elimina studente\n"                                                                   //Mattia
    .ascii "3: Stampare gli studenti di un particolare anno\n"  //iterativo                          //Mario Bruno
    .ascii "4: Stampare gli studenti sopra una detrminata media\n"  //ricorsivo                      //Emanuele
    .ascii "5: Numero studenti fuori corso\n"   //statistica intero                                  //Marco e DavidePe
    .ascii "6: Media voti ragazzi di un particolare anno (double)\n"  //statistica double            //Marco e DavidePe
    .ascii "7: Scambiare due studenti"                                                               //Davide Pirrò e Daniele
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
.align 2

.data
n_studente: .word 0


.equ max_studente, 5
.equ size_studente_matricola, 4
.equ size_studente_nome, 20
.equ size_studente_media_voti, 4
.equ size_studente_anno, 4
.equ offset_studente_matricola, 0
.equ offset_studente_nome, offset_studente_matricola + size_studente_matricola
.equ offset_auto_media_voti, offset_studente_nome + size_studente_nome
.equ offset_studente_anno, offset_media_voti + size_media_voti
.equ studente_size_aligned, 32

.bss
tmp_str: .skip 128
tmp_int: .skip 8
auto: .skip studente_size_aligned * max_studente


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


.text
.type main, %function
.global main


main:
    stp x29, x30, [sp, #-16]!

    //caricamento dati dal file, appena avvi l'applicazione parti dai dati precedenti
    bl load_data 

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
        bl aggiungi_studente
            //prosegui se non aggiungi uno studente
        no_aggiungi_studente:
        
        //se 2 elimina studnete
        cmp x0, #2
        bne no_elimina_auto
        bl elimina_auto
            //prosegui 
        no_elimina_auto:

        //se 3 stampare gli studenti di un particolare anno
        cmp x0, #3
        bne no_stampa_studneti_anno
        bl stampa_studneti_anno
        //prosegui
        no_stampa_studneti_anno:

        //se 4 stampare gli studenti sopra una determinata media
        cmp x0, #4
        bne no_studenti_sopra_media
        bl studenti_sopra_media
        //prosegui
        no_studenti_sopra_media:

        //se 5 stampa numero studenti fuori corso
        cmp x0, #5
        bne no_stampa_fuori_corso
        bl stampa_fuori_corso
        //prosegui 
        no_stampa_fuori_corso:


        //se 6 stampa media voti di un particolare anno
        cmp x0, #6
        bne no_stampa_media_part_anno
        bl stampa_media_part_anno
        //prosegui 
        no_stampa_media_part_anno:

        //se 7 scambia due studenti
        cmp x0, #7
        bne no_scambia_due_studenti
        bl scambia_due_studenti
        //prosegui 
        no_scambia_due_studenti:


        b main_loop     
    end_main_loop:

    mov w0, #0
    ldp x29, x30, [sp], #16
    ret
    .size main, (. - main)
