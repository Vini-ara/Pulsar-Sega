.data 
stage1: .string "stage1review.bin"

.text

 la a0, stage1
 li a1, 0
 li a2, 0
 li a7, 1024
 ecall
 
 mv t0, a0
 
 mv a0, t0
 li a1, 0xFF000000
 li a2, 76800
 li a7, 63
 ecall
 
 mv a0, t0
 li a7, 57
 ecall
 
 li a7, 10
 ecall