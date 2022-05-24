.section .rodata
filename: .asciz "alviano_larusso.dat"
read_mode: .asciz "r"
write_mode: .asciz "w"
fmt_menu_title:
    .ascii "**************************\n"
    .ascii "*** LaRusso Auto Group ***\n"
    .asciz "**************************\n"
fmt_menu_line:
    .asciz "--------------------------------------------------------------------\n"
fmt_menu_header:
    .asciz "  # TARGA      PRODUTTORE           MODELLO                PREZZO\n"
fmt_menu_entry:
    .asciz "%3d %-10s %-20s %-20s %8d\n"
fmt_menu_options:
    .ascii "1: Aggiungi auto\n"
    .ascii "2: Elimina auto\n"
    .ascii "3: Calcola prezzo medio\n"
    .ascii "4: Calcola prezzo medio (double)\n"
    .asciz "0: Esci\n"
fmt_prezzo_medio: .asciz "\nPrezzo medio: %d\n\n"
fmt_prezzo_medio_double: .asciz "\nPrezzo medio: %.2f\n\n"
fmt_fail_save_data: .asciz "\nImpossibile salvere i dati.\n\n"
fmt_fail_aggiungi_auto: .asciz "\nMemoria insufficiente. Eliminare un'auto, quindi riprovare.\n\n"
fmt_fail_calcola_prezzo_medio: .asciz "\nNessuna auto presente.\n\n"
fmt_scan_int: .asciz "%d"
fmt_scan_str: .asciz "%127s"
fmt_prompt_menu: .asciz "? "
fmt_prompt_targa: .asciz "Targa: "
fmt_prompt_produttore: .asciz "Produttore: "
fmt_prompt_modello: .asciz "Modello: "
fmt_prompt_prezzo: .asciz "Prezzo: "
fmt_prompt_index: .asciz "# (fuori range per annullare): "
.align 2

.data
n_auto: .word 0

.equ max_auto, 5
.equ size_auto_targa, 10
.equ size_auto_produttore, 20
.equ size_auto_modello, 20
.equ size_auto_prezzo, 4
.equ offset_auto_targa, 0
.equ offset_auto_produttore, offset_auto_targa + size_auto_targa
.equ offset_auto_modello, offset_auto_produttore + size_auto_produttore
.equ offset_auto_prezzo, offset_auto_modello + size_auto_modello
.equ auto_size_aligned, 64

.bss
tmp_str: .skip 128
tmp_int: .skip 8
auto: .skip auto_size_aligned * max_auto


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

    bl load_data

    main_loop:
        bl print_menu
        read_int fmt_prompt_menu
        
        cmp x0, #0
        beq end_main_loop
        
        cmp x0, #1
        bne no_aggiungi_auto
        bl aggiungi_auto
        no_aggiungi_auto:

        cmp x0, #2
        bne no_elimina_auto
        bl elimina_auto
        no_elimina_auto:

        cmp x0, #3
        bne no_calcola_prezzo_medio
        bl calcola_prezzo_medio
        no_calcola_prezzo_medio:

        cmp x0, #4
        bne no_calcola_prezzo_medio_double
        bl calcola_prezzo_medio_double
        no_calcola_prezzo_medio_double:

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

    ldr x0, =n_auto
    mov x1, #4
    mov x2, #1
    mov x3, x19
    bl fread

    ldr x0, =auto
    mov x1, auto_size_aligned
    mov x2, max_auto
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
    stp x29, x30, [sp, #-16]!
    str x19, [sp, #-8]!
    
    adr x0, filename
    adr x1, write_mode
    bl fopen

    cmp x0, #0
    beq fail_save_data

        mov x19, x0

        ldr x0, =n_auto
        mov x1, #4
        mov x2, #1
        mov x3, x19
        bl fwrite

        ldr x0, =auto
        mov x1, auto_size_aligned
        mov x2, max_auto
        mov x3, x19
        bl fwrite

        mov x0, x19
        bl fclose

        b end_save_data

    fail_save_data:
        adr x0, fmt_fail_save_data
        bl printf

    end_save_data:

    ldr x19, [sp], #8
    ldp x29, x30, [sp], #16
    ret
    .size save_data, (. - save_data)


.type print_menu, %function
print_menu:
    stp x29, x30, [sp, #-16]!
    stp x19, x20, [sp, #-16]!
    stp x21, x22, [sp, #-16]!

    adr x0, fmt_menu_title
    bl printf

    adr x0, fmt_menu_line
    bl printf
    adr x0, fmt_menu_header
    bl printf
    adr x0, fmt_menu_line
    bl printf

    mov x19, #0
    ldr x20, n_auto
    ldr x21, =auto
    print_entries_loop:
        cmp x19, x20
        bge end_print_entries_loop

        adr x0, fmt_menu_entry
        add x1, x19, #1
        add x2, x21, offset_auto_targa
        add x3, x21, offset_auto_produttore
        add x4, x21, offset_auto_modello
        ldr x5, [x21, offset_auto_prezzo]
        bl printf

        add x19, x19, #1
        add x21, x21, auto_size_aligned
        b print_entries_loop
    end_print_entries_loop:

    adr x0, fmt_menu_line
    bl printf

    adr x0, fmt_menu_options
    bl printf

    ldp x21, x22, [sp], #16
    ldp x19, x20, [sp], #16
    ldp x29, x30, [sp], #16
    ret
    .size print_menu, (. - print_menu)


.type aggiungi_auto, %function
aggiungi_auto:
    stp x29, x30, [sp, #-16]!
    stp x19, x20, [sp, #-16]!
    
    ldr x19, n_auto
    ldr x20, =auto 
    mov x0, auto_size_aligned
    mul x0, x19, x0 
    add x20, x20, x0
    
    cmp x19, max_auto
    bge fail_aggiungi_auto
        read_str fmt_prompt_targa
        save_to x20, offset_auto_targa, size_auto_targa

        read_str fmt_prompt_produttore
        save_to x20, offset_auto_produttore, size_auto_produttore
        
        read_str fmt_prompt_modello
        save_to x20, offset_auto_modello, size_auto_modello

        read_int fmt_prompt_prezzo
        str w0, [x20, offset_auto_prezzo]      

        add x19, x19, #1
        ldr x20, =n_auto
        str x19, [x20]

        bl save_data

        b end_aggiungi_auto 
    fail_aggiungi_auto:
        adr x0, fmt_fail_aggiungi_auto
        bl printf
    end_aggiungi_auto:
    
    ldp x19, x20, [sp], #16
    ldp x29, x30, [sp], #16
    ret
    .size aggiungi_auto, (. - aggiungi_auto)


.type elimina_auto, %function
elimina_auto:
    stp x29, x30, [sp, #-16]!
    
    read_int fmt_prompt_index

    cmp x0, 1
    blt end_elimina_auto

    ldr x1, n_auto
    cmp x0, x1
    bgt end_elimina_auto

    sub x5, x0, 1   // selected index
    ldr x6, n_auto
    sub x6, x6, x0  // number of auto after selected index
    mov x7, auto_size_aligned
    ldr x0, =auto
    mul x1, x5, x7  // offset to dest
    add x0, x0, x1  // dest
    add x1, x0, x7  // source
    mul x2, x6, x7  // bytes to copy
    bl memcpy

    ldr x0, =n_auto
    ldr x1, [x0]
    sub x1, x1, #1
    str x1, [x0]

    bl save_data

    end_elimina_auto:
    
    ldp x29, x30, [sp], #16
    ret
    .size elimina_auto, (. - elimina_auto)


.type calcola_prezzo_medio, %function
calcola_prezzo_medio:
    stp x29, x30, [sp, #-16]!
    
    ldr x0, n_auto
    cmp x0, #0
    beq calcola_prezzo_medio_error

        mov x1, #0
        mov x2, #0
        ldr x3, =auto
        add x3, x3, offset_auto_prezzo
        calcola_prezzo_medio_loop:
            ldr x4, [x3]
            add x1, x1, x4
            add x3, x3, auto_size_aligned

            add x2, x2, #1
            cmp x2, x0
            blt calcola_prezzo_medio_loop
        
        udiv x1, x1, x0
        adr x0, fmt_prezzo_medio
        bl printf

        b end_calcola_prezzo_medio

    calcola_prezzo_medio_error:
        adr x0, fmt_fail_calcola_prezzo_medio
        bl printf
    
    end_calcola_prezzo_medio:

    ldp x29, x30, [sp], #16
    ret
    .size calcola_prezzo_medio, (. - calcola_prezzo_medio)


.type calcola_prezzo_medio_double, %function
calcola_prezzo_medio_double:
    stp x29, x30, [sp, #-16]!
    
    ldr x0, n_auto
    cmp x0, #0
    beq calcola_prezzo_medio_double_error

        fmov d1, xzr
        mov x2, #0
        ldr x3, =auto
        add x3, x3, offset_auto_prezzo
        calcola_prezzo_medio_double_loop:
            ldr x4, [x3]
            ucvtf d4, x4
            fadd d1, d1, d4
            add x3, x3, auto_size_aligned

            add x2, x2, #1
            cmp x2, x0
            blt calcola_prezzo_medio_double_loop
        
        ucvtf d0, x0
        fdiv d0, d1, d0
        adr x0, fmt_prezzo_medio_double
        bl printf

        b end_calcola_prezzo_medio_double

    calcola_prezzo_medio_double_error:
        adr x0, fmt_fail_calcola_prezzo_medio
        bl printf
    
    end_calcola_prezzo_medio_double:

    ldp x29, x30, [sp], #16
    ret
    .size calcola_prezzo_medio_double, (. - calcola_prezzo_medio_double)
