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
    .ascii "7: Scambiare due studenti\n"                                                             //Davide Pirrò e Daniele
    .asciz "0: Esci\n"

fmt_studenti_fuoricorso: .asciz "\nNumero studenti fuori corso: %d\n\n"
fmt_media_voti_double: .asciz "\nMedia voti: %.2f\n\n"
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
n_studente: .word 3                                                                 //MODIFICATO IL PLACEHOLDER DEL NUMERO DI STUDENTI (QUELLO EFFETTIVO VIENE LETTO DAL FILE)

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

                                                    //MODIFICATO NON SERVONO PIù GLI STUDENTI DI BASE IN QUANTO SONO DIRETTAMENTE PRESENTI NEL FILE studenti.dat
//questi sono due studenti, usateli se dovete fare prove
.align 3
students: .word 111111                              // align a 4 perché word=32 bit
          .asciz "Davide                         "  // aggiungiamo 32 byte quindi il totale è 36, resta allineato a 4
          .align 3                                  // allineo la memoria a 8, e aggiungo 4 byte per arrivare a 40
          .double 28.4                              // aggiungo 8 byte e arrivo a 48, allineato a 8
          .word 4                                   // è una word = 4 byte totale 52, allineato a 4

          .align 3

          .word 000000
          .asciz "Daniele                        "
          .align 3
          .double 19.6
          .word 4
          .align 3

          .align 3

          .word 000001
          .asciz "Danilo                         "
          .align 3
          .double 22.6
          .word 3
          .align 3

.bss
tmp_str: .skip 128
tmp_int: .skip 8
tmp_double: .skip 8                                             //MODIFICATO AGGIUNTO tmp_double
//students: .skip studente_size_aligned * max_studente            //MODIFICATO DECOMMENTATO L'ARRAY IN QUANTO HO COMMENTATO QUELLO DI PROVA
.text
//macro per leggere un numero e salvarlo in tmp_int, oltre a metterlo in x0     //MODIFICATO RESO PIù PRECISO IL COMMENTO
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

//macro per leggere un numero e salvarlo in tmp_double, oltre che in d0         //MODIFICATO AGGIUNTA UNA MACRO PER SCANNERIZZARE I DOUBLE
.macro read_double prompt
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

// macro per leggere una stringa e salvarla in tmp_str      //MODIFICATO INSERITO COMMENTO
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
// macro per stampare uno studente //MODIFICATO AGGIUNTO IL COMMENTO PER SPECIFICARE COSA FA LA MACRO
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

.type main, %function
.global main
main:
    stp x29, x30, [sp, #-16]!

    bl elimina_studente

    mov x0, #0
    ldp x29, x30, [sp], #16
    ret
    .size main, (. -main)

.type elimina_studente, %function
elimina_studente:
    stp x29, x30, [sp, #-16]!
    
    read_int fmt_prompt_index
    //in x0 andrà lo studnete da eliminare

    cmp x0, 1
    blt end_elimina_studente

    //in x1 carico il numero degli studneti totali
    ldr x1, n_studente
    //se l'indice dello studente da eliminare supera il numero massimo termina la funzione
    cmp x0, x1
    bgt end_elimina_studente

    //sub x5, x0, 1   // selected index (questo se partiamo a contare gli studenti da 1)
    ldr x6, n_studente
    sub x6, x6, x0  // number of student after selected index?
    mov x7, studente_size_aligned

    ldr x0, =students
    mul x1, x5, x7  // offset to dest
    add x0, x0, x1  // dest
    add x1, x0, x7  // source
    mul x2, x6, x7  // bytes to copy
    bl memcpy

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
    stp x29, x30, [sp, #-16]!
    read_int x0 //serve per prendere in input l'anno richiesto
    fmov w2, #0     //somma delle medie dei voti degli studenti dell'anno preso in input
    fmov w3, #0  //numero degli studenti di quell'anno
    mov w4, #0   //indice del loop
    mov x5, n_studente  //numero di tutti gli studenti
    adr x6, students  //primo studente
    mov x7, studente_size_aligned
    loop:
    cmp w4, x5   //condizione di uscita dal loop
    beq endloop    //se sono identici
        //vedere se l'alunno appartiene all'anno dato in input
    madd x8, x7, w4, x6      // inserisco in x8 l'indirizzo dello studente iesimo
    ldr x9, [x8, offset_studente_anno]        // carico in x9 l'anno dello studente iesimo
    cmp x9, x0
    bne true   
        //se lo studente appartiene all'anno scelto
        fadd w3, #1    //incrementa il numero degli studenti di quell'anno
        ldr w9, [x8, offset_studente_media_voti]    //media dei voti dello studente i-esimo
        fadd w2, w9    //incrementa la somma delle medie dei voti
    true:
    add w4, #1    //incremento il contatore
    cmp w4, x5    //condizione di uscita dal loop
    bls loop    //se w4 è minore ripeti il loop
    endloop:
    fdiv w1, w2, w3    //divido la somma delle medie dei voti con il numero degli studenti dell'anno in input
    adr x0, fmt_media_voti    //modificare il format
    bl printf
    ldp x29, x30, [sp], #16
    ret
    .size MediaVoti, (. -MediaVoti)

/*
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
 
 */



/*
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
*/

/*
.type print_anno, %function
print_anno:
    stp x29, x30, [sp, #-16]!
    stp x19, x20, [sp, #-16]!
    stp x21, x22, [sp, #-16]!
    str x23, [sp, #-8]!
    read_int fmt_prompt_anno   //chiede all'utente di inserire un int
    mov x19, x0

    //stampo gli header
    adr x0, fmt_menu_line
    bl printf
    adr x0, fmt_menu_header
    bl printf
    adr x0, fmt_menu_line
    bl printf

    ldr x20, n_studente   //carico il numero degli studenti
    mov x21, #0           //i = 0

    ldr x22, =students   //continuare
    mov x23, studente_size_aligned

    p_a_loop:
        cmp x21, x20        //if x21 - x20 == 0
        beq p_a_exit       // esci else continua

    p_a_exe:
        madd x5, x21, x23, x22             // x5 = x3 + (x2 * x4)
        ldr x6, [x5, offset_studente_anno]

        cmp x19, x6                     //x19 == x6 continua
        bne p_a_end                     //else salta

        print w21                           

    p_a_end:
        add x21, x21, #1
        b p_a_loop
    p_a_exit:
        adr x0, fmt_menu_line
        bl printf
        ldr x23, [sp], #8     
        ldp x21, x22, [sp], #16     
        ldp x19, x20, [sp], #16     
        ldp x29, x30, [sp], #16                  
        ret
        .size print_anno, (. - print_anno)
*/