.section .rodata
fmt_student: .ascii "First name: %s\n"
             .ascii " Last name: %s\n"
             .ascii "     Class: %d\n"
             .asciz "     Grade: %d\n\n"

.equ offset_student_first_name, 0
.equ offset_student_last_name, 30
.equ offset_student_class, 60 //gli facciamo occupare una word 32 bit !!!!!!!!!Perchè quì gli dedichiamo 4 byte mentre nella macro di stampa sono 1 usando ldrb?
.equ offset_student_grade, 64
.equ size_student, 72

.data
// offset:                  11111111112222222222 333333333344444444445555555555 6   6666   6 6 6 6677777777778888888888
//                012345678901234567890123456789 012345678901234567890123456789 0   1234   5 6 7 8901234567890123456789
students: .ascii "Mario                        \0Alviano                      \0\x01   \x0A\0\0\0...."
          .ascii "Luigi                        \0Mario                        \0\x02   \x0B\0\0\0...."

.macro print index
    ldr x0, =students        //carica in x0 l'indirizzo della memoria ram dove ci stanno gli studenti 
    mov x1, size_student     //x1=72 per quanta memoria occupata per studente
    mov x2, \index           //lo studente n°?
    madd x0, x1, x2, x0  // x0 = x0 + (x1 * x2) //in x0 ora ci sarà l'indirizzo dello studente iesimo


    add x1, x0, offset_student_first_name   //in x1 c'è l'indirizzo dello studente iesimo (prendi fino a \0 ovvero end-string) non è caricato in un registro poichè stringa non entra in registro 64 bit
    add x2, x0, offset_student_last_name
    ldrb w3, [x0, offset_student_class]
    ldr x4, [x0, offset_student_grade]
    adr x0, fmt_student
    bl printf       //questa stampa prende registri da x0-x4 e li stampa
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
