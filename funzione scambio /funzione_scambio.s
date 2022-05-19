.section .rodata
/*
fmt_student: .ascii "First name: %s\n"
             .ascii " Last name: %s\n"
             .ascii "     Class: %d\n"
             .asciz "     Grade: %d\n\n"*/
fmt_menu_entry:
    .asciz "%06d %-32s %2.1f %d\n" //ATTENTO QUI CAPIRE COSA FARE
fmt_after: .asciz "*** After delete ***\n\n"

.equ max_studente, 5
.equ size_studente_matricola, 4
.equ size_studente_nome, 32
.equ size_studente_media_voti, 4
.equ size_studente_anno, 4
.equ offset_studente_matricola, 0
.equ offset_studente_nome, 4 //offset_studente_matricola + size_studente_matricola //4
.equ offset_studente_media_voti, 36 //offset_studente_nome + size_studente_nome  //24
.equ offset_studente_anno, 40//offset_media_voti + size_media_voti  //28
.equ studente_size_aligned, 44


.data
// # MATRICOLA                NOME                MEDIA-VOTI                ANNO\n"
students: .word 111111
          .asciz "Davide                         "
          .float 23.4
          .word 1
          
          .word 000000
          .asciz "Daniele                        "
          .float 25.4
          .word 2


.macro print index
    ldr x0, =students
    mov x1, studente_size_aligned
    mov x2, \index
    madd x0, x1, x2, x0  // x0 = x0 + (x1 * x2)

    //add x1, x0, offset_studente_matricola
    ldr w1, [x0, offset_studente_matricola]
    add x2, x0, offset_studente_nome
    ldr s0, [x0, offset_studente_media_voti]
    ldr w4, [x0, offset_studente_anno]
    adr x0, fmt_menu_entry
    bl printf
.endm

.text
.type main, %function
.global main
main:
    stp x29, x30, [sp, #-16]!

    print 0                     
    print 1
    
    mov w0, #0
    ldp x29, x30, [sp], #16
    ret
    .size main, (. - main)
