/*
First name: Mario                        
 Last name: Alviano                      
     Class: 1
     Grade: 10

First name: Luigi                        
 Last name: Mario                        
     Class: 2
     Grade: 11

First name: Principessa                  
 Last name: Peach                        
     Class: 1
     Grade: 10

*** After delete ***

First name: Mario                        
 Last name: Alviano                      
     Class: 1
     Grade: 10

First name: Principessa                  
 Last name: Peach                        
     Class: 1
     Grade: 10
 */

.section .rodata
fmt_student: .ascii "First name: %s\n"
             .ascii " Last name: %s\n"
             .ascii "     Class: %d\n"
             .asciz "     Grade: %d\n\n"
fmt_after: .asciz "*** After delete ***\n\n"

.equ offset_student_first_name, 0
.equ offset_student_last_name, 30
.equ offset_student_class, 60
.equ offset_student_grade, 64
.equ size_student, 72

.data
// offset:                  11111111112222222222 333333333344444444445555555555 6   6666   6 6 6 6677777777778888888888
//                012345678901234567890123456789 012345678901234567890123456789 0   1234   5 6 7 8901234567890123456789
students: .ascii "Mario                        \0Alviano                      \01\010"
          .ascii "Luigi                        \0Mario                        \0\x02   \x0B\0\0\0...."
          .ascii "Principessa                  \0Peach                        \0\x01   \x0A\0\0\0...."

.macro print index
    ldr x0, =students
    mov x1, size_student
    mov x2, \index
    madd x0, x1, x2, x0  // x0 = x0 + (x1 * x2)

    add x1, x0, offset_student_first_name
    add x2, x0, offset_student_last_name
    ldrb w3, [x0, offset_student_class]
    ldr x4, [x0, offset_student_grade]
    adr x0, fmt_student
    bl printf
.endm

.text
.type main, %function
.global main
main:
    stp x29, x30, [sp, #-16]!

    print 0
    print 1
    print 2

    //cosa gli dobbiamo passare a memcpy
    ldr x0, =students           //in x0 l'indirizzo dove stanno gli studenti
    add x0, x0, size_student    //in x0 l'indirizzo dello studente 1
    add x1, x0, size_student    //in x1 l'indizzo dello studente 2
    mov x2, size_student        //in x2 quanti byte devono essere sostituiti
    bl memcpy                   //sposta il contenuto di x1 in x0 per quanti byte indicati in x2

    adr x0, fmt_after           //semplice stampa scritta
    bl printf

    print 0                     
    print 1
    
    mov w0, #0
    ldp x29, x30, [sp], #16
    ret
    .size main, (. - main)
