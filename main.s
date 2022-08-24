.data 
isrunnig: .byte 1
stage1: .string "stage1.bin"
yellow: .string "BixoAmareloCerto.bin"
yellow_position: .byte 70, 50
yellow_dimensions: .byte 12, 9
	

.macro PRINT_MAP(%fileName)
 	la a0, %fileName 		# loads file-name string
 	li a1, 0				# open file for reading
 	li a2, 0			
 	li a7, 1024				# syscall for open file
 	ecall 
 
 	mv t0, a0				# saves file descriptor returned from syscall
 
 	li a1, 0xFF000000		# vga address
 	li a2, 76800			# image size
 	li a7, 63				# syscall read 
 	ecall
 
 	mv a0, t0				# file descriptor
 	li a7, 57				# syscall to close file
 	ecall		
.end_macro

# Takes a filename label and a starting position label(2 bytes)
.macro  PRINT_CHARACTER(%fileName , %position, %dimensions)
	la a0, %fileName	# loads file name
	li a1, 0			# read file
	li a2, 0		
	li a7, 1024			# ssycall to open file
	ecall				# opens file
	
	la t0, %position	# where the positions are saved
	lb t1, 0(t0)		# loads y position
	li t2, 320 			# line widht
	
	mul t2, t2, t1		# right y axis position	
	li t3, 0xFF000000   # vga address
	add t3, t3, t2		# character y position
	lb t1, 1(t0)		# gets x axis position
	
	add t3, t3, t1		# character position
	
	la t0, %dimensions
	
	add t1, zero, zero		# initialize line counter
	lb t2, 1(t0)			# image height
	lb a2, 0(t0)
	
	mv t0, a0				# tmp save file descriptor
	
loop:	
	mv a1, t3				# position in vga memory to write
	li a7, 63				# syscall to read file
	ecall					# reds the file
	
	mv a0, t0				# laods file descriptor again
	addi t1, t1, 1			# adds 1 to the counter
	addi t3, t3, 320		# goes to next line
	blt t1, t2, loop		# print each line untill the image is over
	
	mv a0, t0				# gets file descriptor again
	li a7, 57				# syscall to close file
	ecall					# closes file
.end_macro 

.macro CHECK_KEYPRESS()
	li t1,0xFF200000		# carrega o endere�o de controle do KDMMIO
	lw t0,0(t1)				# Le bit de Controle Teclado
	andi t0,t0,0x0001		# mascara o bit menos significativo
   	beq t0,zero,loop 	   	# Se n�o h� tecla pressionada ent�o vai para FIM
  	lw t2,4(t1)  			# le o valor da tecla tecla
move_tank:
	li t3, 119
	beq t2, t3, up
	li t3, 115
	beq t2, t3, down
	li t3, 100
	beq t2, t3, right
	li t3, 97
	beq t2, t3, left
	j loop
up:
la t0, yellow_position
	lb t1, 0(t0)
	addi t1, t1, -1
	sb t1, 0(t0) 
	j loop
down:
la t0, yellow_position
	lb t1, 0(t0)
	addi t1, t1, 1
	sb t1, 0(t0)
	j loop
left: 
la t0, yellow_position
	lb t1, 1(t0)
	addi t1, t1, -1
	sb t1, 1(t0)
	j loop
right:
la t0, yellow_position
	lb t1, 1(t0)
	addi t1, t1, 1
	sb t1, 1(t0)
	j loop
	
.end_macro

.text
	PRINT_MAP(stage1)

 loop:	
  	PRINT_CHARACTER(yellow , yellow_position, yellow_dimensions)
 	CHECK_KEYPRESS()
  	lb t0, isrunnig
  	bne t0, zero, loop
  	
  	
  	
FIM: 
 	li a7, 10
 	ecall
