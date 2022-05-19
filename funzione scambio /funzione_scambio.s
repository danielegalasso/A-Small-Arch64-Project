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
.equ size_studente_media_voti, 8
.equ size_studente_anno, 4
.equ offset_studente_matricola, 0
.equ offset_studente_nome, 4 //offset_studente_matricola + size_studente_matricola //4
.equ offset_studente_media_voti, 40 //offset_studente_nome + size_studente_nome  //24
.equ offset_studente_anno, 48//offset_media_voti + size_media_voti  //28
.equ studente_size_aligned, 56

.data
// # MATRICOLA                NOME                MEDIA-VOTI                ANNO\n"
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

//.bss
//temp:   .skip 56

.macro print index
    ldr x0, =students
    mov x1, studente_size_aligned
    mov x2, \index
    madd x0, x1, x2, x0  // x0 = x0 + (x1 * x2)

    ldr w1, [x0, offset_studente_matricola]
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

    print 0                     
    print 1
    
    ldr x0, =students
    mov x1, #0
    mov x2, #1
    bl scambia

    ldr x0, =fmt_after
    bl printf 
    
    print 0                     
    print 1

    mov w0, #0
    ldp x29, x30, [sp], #16
    ret
    .size main, (. - main)


// input: x0, l'address di students
// x1: indice del primo studente da scambiare
// x2: indice del secondo studente da scambiare
.type scambia, %function
scambia:
    stp x29, x30, [sp, #-16]!
    stp x19, x20, [sp, #-16]!
    stp x21, x22, [sp, #-16]!

    mov x19, x0 //in x19 l'indirizzo degli studenti
    mov x20, x1 //indice 1° studente
    mov x21, x2 //indice 2° studente
    //adr x22, temp

    sub sp, sp, studente_size_aligned //è fatto con lo stack per flexare (esercizio di stile)



    mov x2, studente_size_aligned
    mov x0, sp             //in x0 abbiamo inserito lo stack pointer per salvare lo studente temporaneamente bello stack
    madd x1, x2, x20, x19   //in x1 abbiamo inserito l'indirizzo dello studente0 
    bl memcpy               //lo studente0 andrà in temp

    //2°step  spostare lo studente1 in studnete0
    mov x2, studente_size_aligned
    madd x0, x1, x20, x19    //in x0 abbiamo inserito l'indirizzo dello studente0
    madd x1, x2, x21, x19    //in x1 abbiamo inserito l'indirizzo dello studente1
    bl memcpy               //lo studente0 andrà in temp
    
    //3° step spostare temp in studente1
    mov x2, studente_size_aligned
    madd x0, x2, x21, x19   //in x0 abbiamo inserito l'indirizzo dello studente1 
    mov x1, sp             //in x1 abbiamo inserito l'indirizzo di temp
    bl memcpy               //lo studente0 andrà in temp
    
    add sp, sp, studente_size_aligned
    
    mov x0, #4
    ldp x21, x22, [sp], #16
    ldp x19, x20, [sp], #16
    ldp x29, x30, [sp], #16
    ret
    .size scambia, (. -scambia)
    

    /*
    //1° step spostare studente0 in temp
    mov x2, studente_size_aligned
    mov x0, x22             //in x0 abbiamo inserito l'indirizzo di temp
    madd x1, x2, x20, x19   //in x1 abbiamo inserito l'indirizzo dello studente0 
    bl memcpy               //lo studente0 andrà in temp

    //2°step  spostare lo studente1 in studnete0
    mov x2, studente_size_aligned
    madd x0, x1, x20, x19    //in x0 abbiamo inserito l'indirizzo dello studente0
    madd x1, x2, x21, x19    //in x1 abbiamo inserito l'indirizzo dello studente1
    bl memcpy               //lo studente0 andrà in temp
    
    //3° step spostare temp in studente1
    mov x2, studente_size_aligned
    madd x0, x2, x21, x19   //in x0 abbiamo inserito l'indirizzo dello studente1 
    mov x1, x22             //in x1 abbiamo inserito l'indirizzo di temp
    bl memcpy               //lo studente0 andrà in temp
    */
