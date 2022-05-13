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
    .asciz "%3d %-10s %-20s %-20s %8d\n" //ATTENTO QUI CAPIRE COSA FARE
fmt_menu_options:
    .ascii "1: Aggiungi studente\n"
    .ascii "2: Elimina studente\n"
    .ascii "3: Stampare gli studenti di un particolare anno\n"  //iterativo
    .ascii "4: Stampare gli studenti sopra una detrminata media\n"  //ricorsivo
    .ascii "5: Numero studenti fuori corso\n"   //statistica intero
    .ascii "6: Media voti ragazzi di un particolare anno (double)\n" //statistica double
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

.bss


.text
.type main, %function
.global main
main:
    stp x29, x30, [sp, #-16]!


    mov w0, #0
    ldp x29, x30, [sp], #16
    ret
    .size main, (. - main)