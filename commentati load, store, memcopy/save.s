.section .rodata
fmt_student: .ascii "First name: %s\n"
             .ascii " Last name: %s\n"
             .ascii "     Class: %d\n"
             .asciz "     Grade: %d\n\n"
filename: .asciz "data.dat"
write_mode: .asciz "w"

.equ offset_student_first_name, 0
.equ offset_student_last_name, 30
.equ offset_student_class, 60
.equ offset_student_grade, 64
.equ size_student, 72

.data
// offset:                  11111111112222222222 333333333344444444445555555555 6   6666   6 6 6 6677777777778888888888
//                012345678901234567890123456789 012345678901234567890123456789 0   1234   5 6 7 8901234567890123456789
students: .ascii "Mario                        \0Alviano                      \0\x01   \x0A\0\0\0...."
          .ascii "Luigi                        \0Mario                        \0\x02   \x0B\0\0\0...."
          .ascii "Principessa                  \0Peach                        \0\x01   \x0A\0\0\0...."


.text
.type main, %function
.global main
main:
    stp x29, x30, [sp, #-16]!
    str x19, [sp, #-8]!

    adr x0, filename
    adr x1, write_mode
    bl fopen

    cmp x0, #0 //se non c'è il file x0=0 e termina il programma
    beq end

        mov x19, x0     //salva l'indirizzo del file in un'altro registro, permanete così non cambia il suo valore

        ldr x0, =students       //in x0 la fonte dei dati che vorrai il file salvasse
        mov x1, size_student    //quanto salvare (in questo caso vogliamo salvare degli studenti con quella size)
        mov x2, #3              //Salviamo 3 studenti
        mov x3, x19             //l'indirizzo del file
        bl fwrite

        mov x0, x19             //x0 riprende l'indirizzo del file come 3a riga main
        bl fclose

    end:

    mov w0, #0
    ldr x19, [sp], #8
    ldp x29, x30, [sp], #16
    ret
    .size main, (. - main)
