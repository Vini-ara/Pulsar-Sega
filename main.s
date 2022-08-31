.data 
# game constants
isrunnig: .byte 1

# sprites names
stage1: .string "stage1.bin"
black_tile: .string "TankBlackTile.bin"
tank: .string "tank.bin"

# sprites data
tank_bin: .space 64
tank_clear_bin: .space 64

# character info
tank_position: .half 190, 20		# (y, x) 
tank_old_position: .half 0, 0		# (y, x)
tank_dimensions: .byte 8, 8	# (heingth, width)
tank_direction: .byte 0 		# 0 = up, 1 = down, 2 = right, 3 = left

.text
SETUP:
	la a0, tank
	la t0, tank_dimensions
	la s1, tank_bin
	call OPEN_FILE
	
	la a0, black_tile
	la t0, tank_dimensions
	la s1, tank_clear_bin
 	call OPEN_FILE

	la a0, stage1
	li a1, 0
	call PRINT_MAP
	
	la a0, stage1
	li a1, 1
	call PRINT_MAP
	
 GAME_LOOP:
	xori s0, s0, 1
 	call CHECK_KEYPRESS
 		
 	la a0, tank_bin
 	la a1, tank_position
 	la a2, tank_dimensions
 	lb a3, tank_direction
 	mv a4, s0
  	call PRINT		# prints tank
  	
  	li t0, 0xFF200604
 	sw s0, 0(t0)
 	
 	la a0, tank_clear_bin
 	la a1, tank_old_position
 	la a2, tank_dimensions
 	lb a3, tank_direction
 	mv a4, s0
 	call PRINT
   	
  	lb t0, isrunnig		# checks if game is still running
  	bne t0, zero, GAME_LOOP
 
# a0 = file name
# t0 = dimensions
# s1 = memory destination
OPEN_FILE: 		
	li a1, 0
	li a2, 0
	li a7, 1024
	ecall
	
	mv t4, a0				# saves file descriptor returned from syscall
	
	lb t2, 0(t0)
	lb t0, 1(t0)
	mul t0, t0, t2
	
	mv a2, t0
	mv a1, s1
	li a7, 63
	ecall
	
	mv a0, t4				# file descriptor
 	li a7, 57				# syscall to close file
 	ret
 	
CHECK_KEYPRESS: 
	li t1, 0xFF200000		# carrega o endere�o de controle do KDMMIO
	lw t0, 0(t1)			# Le bit de Controle Teclado
	andi t0, t0, 0x0001		# mascara o bit menos significativo
   	beq t0, zero, FIM 	   	# Se n�o h� tecla pressionada ent�o vai para FIM
  	lw t2, 4(t1)  			# le o valor da tecla tecla

	li t3, 'w'
	beq t2, t3, UP    # se for "w" move para cima
	li t3, 's'
	beq t2, t3, DOWN  # se for "s" vai para baixo
	li t3, 'd'      
	beq t2, t3, RIGHT # se for "d" vai para direita
	li t3, 'a'         
	beq t2, t3, LEFT  # se for letra "a" vai para esquerda
	j FIM

UP:	
	la t0, tank_position 	# loads position addr
	la t1, tank_old_position # loads old postion addr
	lw t2, 0(t0) 		# loads the hole position vector
	sw t2, 0(t1) 		# saves the postion vector into old position one
	
	lh t1, 0(t0)		# loads y position value
	addi t1, t1, -4		# moves up 2 pixels	
	sh t1, 0(t0)		# saves new value back in memory
	
	la t0, tank_direction	# loads direction addr
	li t2, 0		# digit 0 reference
	sb t2, 0(t0)		# saves 0 as direction val
	j FIM 
DOWN:
	la t0, tank_position    # loads position addr
	la t1, tank_old_position # loads old postion addr
	lw t2, 0(t0) 		# loads the hole position vector
	sw t2, 0(t1) 		# saves the postion vector into old position one
	
	lh t1, 0(t0)		# loads y position value
	addi t1, t1, 4		# moves down 2 pixels
	sh t1, 0(t0)		# saves new value back in memory
	
	la t0, tank_direction	# loads direction addr
	li t2, 1		# digit 1 reference
	sb t2, 0(t0)		# saves 1 as direction val
	j FIM 
RIGHT:
	la t0, tank_position	# loads position addr
	la t1, tank_old_position # loads old postion addr
	lw t2, 0(t0) 		# loads the hole position vector
	sw t2, 0(t1) 		# saves the postion vector into old position one
	
	lh t1, 2(t0)		# loads x position value
	addi t1, t1, 4		# moves right 2 pixels
	sh t1, 2(t0)		# saves new value back in memory
		
	la t0, tank_direction	# loads direction addr
	li t2, 2		# digit 2 reference
	sb t2, 0(t0)		# saves 2 as direction val
	j FIM
LEFT: 
	la t0, tank_position	# loads position addr
	la t1, tank_old_position # loads old postion addr
	lw t2, 0(t0) 		# loads the hole position vector
	sw t2, 0(t1) 		# saves the postion vector into old position one
	
	lh t1, 2(t0)		# loads x postion value
	addi t1, t1, -4		# moves	left 2 pixels
	sh t1, 2(t0)		# saves new value back in memory
	
	la t0, tank_direction	# loads direction addr
	li t2, 3		# digit 3 reference
	sb t2, 0(t0)		# saves 3 as direction val
	j FIM 
FIM: 	ret

# a0 = file name addr
# a1 = frame to print
PRINT_MAP: 
	mv t2, a1
	
 	li a1, 0				# open file for reading
 	li a2, 0			
 	li a7, 1024				# syscall to open file
 	ecall 
 
 	mv t0, a0				# saves file descriptor returned from syscall
 
 	li t1, 0xFF0				# vga address
 	add t1, t1, t2				# go to desired frame
 	
 	slli a1, t1, 20				# sets to correct addr
 	li a2, 76800				# image size
 	li a7, 63				# syscall read 
 	ecall
 
 	mv a0, t0				# file descriptor
 	li a7, 57				# syscall to close file
 	ecall	
 	ret
 
# a0 = content to print
# a1 = position to print
# a2 = dimension of the content
# a3 = direction to print 	
# a4 = frame 1 or 0	
PRINT:
	mv t0, a1
	lh t1, 0(t0)			# loads y position
	li t2, 320 			# line widht
	
	mul t2, t2, t1			# pixel to start printing
	
	li t3, 0xFF0   			# vga address
	add t3, t3, a4			# alternates frame
	slli t3, t3, 20			# adds all the 5 zeros that were remaining to the address
	add t3, t3, t2			# memory address of the line to start printing
	lh t1, 2(t0)			# gets x axis position
	add t3, t3, t1			# memory address to start printing
	
	mv t0, a2
	lb s2, 1(t0)			# image height
	lb s3, 0(t0)			# image width
	
	mv s1, a0			# image data address
	
	li t1, 1			# down direction code
	beq t1, a3, PRINT_DOWN		# check if going down
	li t1, 2			# right direction code
	beq t1, a3, PRINT_RIGHT		# check if going right
	li t1, 3			# left direction code
	beq t1, a3, PRINT_LEFT		# check if going left

PRINT_UP:
	mv t0, s1
	mv t1, zero 			# line counter
UP_LOOP:
	mv t2, zero 			# column counter
UP_LINE_LOOP: 
	lb t4, 0(t0)
	sb t4, 0(t3) 
	addi t0, t0, 1
	addi t3, t3, 1
	addi t2, t2, 1
	blt t2, s3, UP_LINE_LOOP
	
	addi t1, t1, 1			# adds 1 to the counter
	addi t3, t3, 320		# goes to next line
	sub t3, t3, s3
	blt t1, s2, UP_LOOP		# print each line untill the image is over
	j PRINT_END
PRINT_DOWN:  
	mv t0, s1			# file binary addr
	mv t1, s2			# file height
	mul t1, t1, s3			# height x width (file size)
	add t0, t1, t0 			# file end addr	
	addi t0, t0, -1
DOWN_LOOP:
	mv t2, zero 			# file column counter
DOWN_LINE_LOOP: 
	lb t4, 0(t0)			# gets file byte
	sb t4, 0(t3)			# saves file byte in vga mem
	addi t3, t3, 1			# goes to next vga mem addr
	addi t0, t0, -1			# goes back one byte in file addr
	addi t2, t2, 1
	blt t2, s3, DOWN_LINE_LOOP
	
	addi t3, t3, 320		# goes to next line
	sub t3, t3, s3
	bgt t0, s1, DOWN_LOOP
	j PRINT_END
PRINT_RIGHT:
	mv t0, s1
	mv t1, s2
	addi t1, t1, -1
	mul t1, t1, s3
	add t0, t1, t0
	mv t5, zero
RIGHT_LOOP:
	mv t2, zero
RIGHT_LINE_LOOP:
	lb t4, 0(t0)
	sb t4, 0(t3)
	addi t3, t3, 1
	sub t0, t0, s2
	addi t2, t2, 1
	blt t2, s2, RIGHT_LINE_LOOP
	
	mv t0, s1
	mv t1, s2
	addi t1, t1, -1
	mul t1, t1, s3
	add t0, t1, t0
	addi t5, t5, 1
	add t0, t5, t0
	addi t3, t3, 320		# goes to next line
	sub t3, t3, s3
	blt t5, s3, RIGHT_LOOP
	j PRINT_END
PRINT_LEFT:
	mv t0, s1
	mv t1, zero
LEFT_LOOP:
	mv t2, zero
LEFT_LINE_LOOP:
	lb t4, 0(t0)
	sb t4, 0(t3)
	addi t3, t3, 1
	add t0, t0, s2
	addi t2, t2, 1
	blt t2, s2, LEFT_LINE_LOOP
	
	addi t3, t3, 320		# goes to next line
	sub t3, t3, s3
	mv t0, s1
	addi t1, t1, 1
	add t0, t0, t1
	blt t1, s3, LEFT_LOOP
PRINT_END:
	ret
