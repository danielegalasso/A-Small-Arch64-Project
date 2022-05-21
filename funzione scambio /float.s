.section .rodata

fmt_menu_entry: .asciz "%f\n" 


.data
a: .single 1.1

.text
.type main, %function
.global main
main:
    stp x29, x30, [sp, #-16]!

    ldr s0, a 
    ldr x0, =fmt_menu_entry 
    bl printf

    
    mov w0, #0
    ldp x29, x30, [sp], #16
    ret
    .size main, (. - main)
