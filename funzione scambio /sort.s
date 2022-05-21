.section .rodata
fmt: .asciz "%d "

.data
a: .word 4, 4, 5, 2, 3, 1, 6, -4, -6, -1, 23213, 12398, -213, 33123, 231
n: .word (.-a)/4

.text
.type main, %function
.global main
main:
    stp x29, x30, [sp, #-16]!

    adr x0, a
    adr x1, n
    ldr w1, [x1]
    mov w2, #4
    mov w3, #0
    bl bubbleSort

    adr x19, a
    adr x20, n
    ldr w20, [x20]
    mov w21, #0
    loop_print:
    adr x0, fmt
    ldr w1, [x19], #4
    bl printf
    add w21, w21, #1
    cmp w21, w20
    blt loop_print

    mov x0, #0
    ldp x29, x30, [sp], #16
    ret
    .size main, (. -main)


// funzione bubbleSort che ordina gli elementi di un vettore in ordine crescente
// input: x0 -> puntatore al vettore da ordinare; w1 -> dimensione n dell'array;
//      w2 -> dimensione della struttura; w3 -> offset nella struttura
// output: l'array ordinato nella memoria nella posizione dell'array non
//      ordinato: Attenzione! sovrascrive l'array non ordinato
.type bubbleSort, %function
bubbleSort:
    // prologo della funzione
    stp x29, x30, [sp, #-16]!
    stp x19, x20, [sp, #-16]!
    stp x21, x22, [sp, #-16]!
    stp x23, x24, [sp, #-16]!
    stp x25, x26, [sp, #-16]!
    str x27, [sp, #-8]!
    // post-tested loop per ciclare le passate del bubbleSort con indice j che
    // va da 1 a n
    mov x19, x0
    mov w20, w1
    mov w26, w2
    mov w27, w3
    mov w21, #1
    loop_1:
    // calcolo la posizione dell'ultimo elemento dell'array
    sub w22, w20, #1
    mul w23, w22, w26
    add x23, x19, x23
    // post-tested loop della passata: cicla dall'ultimo elemento dell'array al
    // primo elemento dell'array ancora non in posizione finale con indice i
    // che va quindi da n-1 a j
    loop_2:
    // carico gli elementi dell'array i e i-1
    ldr w24, [x23, w27, uxtw]
    sub x0, x23, x26
    ldr w25, [x0, w27, uxtw]
    // confronto gli elementi che prima ho caricato
    cmp w24, w25
    bgt endif
    // se l'elemento in posizione i-1 è maggiore dell'elemento in posizione i
    // li scambio
    mov x1, x0
    mov x0, x23
    mov w2, w26
    bl scambia
    endif:
    // effettuo i controlli del post-tested loop interno: se i = j termina
    sub x23, x23, x26
    sub w22, w22, #1
    cmp w22, w21
    bge loop_2
    // effettuo i controlli del post tested loop esterno: se j = n termina
    add w21, w21, #1
    cmp w21, w20
    blt loop_1
    // epilogo della funzione    
    mov x0, #0
    ldr x27, [sp], #8
    ldp x25, x26, [sp], #16
    ldp x23, x24, [sp], #16
    ldp x21, x22, [sp], #16
    ldp x19, x20, [sp], #16
    ldp x29, x30, [sp], #16
    ret
    .size bubbleSort, (. -bubbleSort)

.type scambia, %function
scambia:
    stp x29, x30, [sp, #-16]!
    
    ldr w2, [x0]
    ldr w3, [x1]
    str w2, [x1]
    str w3, [x0]

    mov x0, #0
    ldp x29, x30, [sp], #16
    ret
    .size scambia, (. -scambia)