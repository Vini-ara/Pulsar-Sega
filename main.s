.data 
isrunnig: .byte 1
stage1: .string "stage1.bin"
black_tile: .string "TankBlackTile.bin"
tank: .string "tank.bin"
tank_position: .half 70, 50		# (y, x) 
tank_dimensions: .byte 12, 8	# (heingth, width)
tank_direction: .byte 0 		# 0 = up, 1 = down, 2 = right, 3 = left
tank_bin: .space 96
tank_clear_bin: .space 96

.macro SETUP
 	OPEN_FILE(tank, tank_dimensions, tank_bin)
 	OPEN_FILE(black_tile, tank_dimensions, tank_clear_bin)
.end_macro
	
.macro PRINT_MAP(%fileName)
 	la a0, %fileName 			# loads file-name string
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

.macro OPEN_FILE(%fileName, %dimensions, %memoryDestination) 
	la a0, %fileName
	li a1, 0
	li a2, 0
	li a7, 1024
	ecall
	
	mv t2, a0				# saves file descriptor returned from syscall
	
	la t0, %dimensions
	lb t1, 0(t0)
	lb t0, 1(t0)
	mul t0, t0, t1
	
	mv a2, t0
	la a1, %memoryDestination
	li a7, 63
	ecall
	
	mv a0, t0				# file descriptor
 	li a7, 57				# syscall to close file
 	ecall
.end_macro

# Takes a filename label and a starting position label(2 bytes)
.macro  PRINT_CHARACTER(%fileBin , %position, %dimensions, %direction)
	la t0, %position		# vector of where to print
	lh t1, 0(t0)			# loads y position
	li t2, 320 			# line widht
	
	mul t2, t2, t1			# pixel to start printing
	li t3, 0xFF000000   		# vga address
	add t3, t3, t2			# memory address of the line to start printing
	lh t1, 2(t0)			# gets x axis position
	
	add t3, t3, t1			# memory address to start printing
	
	la t0, %dimensions
	lb s2, 1(t0)			# image height
	lb s3, 0(t0)			# image width
	
	la s1, %fileBin			# image data address
	
	la t1, %direction		# direction number address
	lb t2, 0(t1)			# gets the direction
	li t1, 1			# down direction code
	beq t1, t2, print_down		# check if going down
	li t1, 2			# right direction code
	beq t1, t2, print_right		# check if going right
	li t1, 3			# left direction code
	beq t1, t2, print_left		# check if going left

print_up:
	mv t0, s1
	mv t1, zero 			# line counter
up_loop:
	mv t2, zero 			# column counter
up_line_loop: 
	lb t4, 0(t0)
	sb t4, 0(t3) 
	addi t0, t0, 1
	addi t3, t3, 1
	addi t2, t2, 1
	blt t2, s3, up_line_loop
	
	
	addi t1, t1, 1			# adds 1 to the counter
	addi t3, t3, 308		# goes to next line
	ble t1, s2, up_loop		# print each line untill the image is over
	j print_end
	
print_down:  
	mv t0, s1			# file binary addr
	mv t1, s2			# file height
	mul t1, t1, s3			# height x width (file size)
	add t0, t1, t0 			# file end addr	
	addi t0, t0, -1
down_loop:
	mv t2, zero 			# file column counter
down_line_loop: 
	lb t4, 0(t0)			# gets file byte
	sb t4, 0(t3)			# saves file byte in vga mem
	addi t3, t3, 1			# goes to next vga mem addr
	addi t0, t0, -1			# goes back one byte in file addr
	addi t2, t2, 1
	blt t2, s3, down_line_loop
	
	addi t3, t3, 308
	bgt t0, s1, down_loop
	j print_end
	
print_right:
	mv t0, s1
	mv t1, s2
	addi t1, t1, -1
	mul t1, t1, s3
	add t0, t1, t0
	mv t5, zero
right_loop:
	mv t2, zero
right_line_loop:
	lb t4, 0(t0)
	sb t4, 0(t3)
	addi t3, t3, 1
	addi t0, t0, -12
	addi t2, t2, 1
	blt t2, s2, right_line_loop
	
	mv t0, s1
	mv t1, s2
	addi t1, t1, -1
	mul t1, t1, s3
	add t0, t1, t0
	addi t5, t5, 1
	add t0, t5, t0
	addi t3, t3, 312
	blt t5, s3, right_loop
	j print_end
	
print_left:
	mv t0, s1
	mv t1, zero
left_loop:
	mv t2, zero
left_line_loop:
	lb t4, 0(t0)
	sb t4, 0(t3)
	addi t3, t3, 1
	addi t0, t0, 12
	addi t2, t2, 1
	blt t2, s2, left_line_loop
	
	addi t3, t3, 312
	mv t0, s1
	addi t1, t1, 1
	add t0, t0, t1
	blt t1, s3, left_loop
print_end:
	
.end_macro 

.macro CHECK_KEYPRESS()
	li t1,0xFF200000		# carrega o endere�o de controle do KDMMIO
	lw t0,0(t1)				# Le bit de Controle Teclado
	andi t0,t0,0x0001		# mascara o bit menos significativo
   	beq t0,zero,loop 	   	# Se n�o h� tecla pressionada ent�o vai para FIM
  	lw t2,4(t1)  			# le o valor da tecla tecla
move_tank:

	li t3, 119        # letra "w"
	beq t2, t3, up    # se for "w" move para cima
	li t3, 115        # letra "s" 
	beq t2, t3, down  # se for "s" vai para baixo
	li t3, 100        # letra "d"  
	beq t2, t3, right # se for "d" vai para direita
	li t3, 97         # letra "a" 
	beq t2, t3, left  # se for letra "a" vai para esquerda
	j loop            # se n for nada volta para o loop
up:
  	PRINT_CHARACTER(tank_clear_bin, tank_position, tank_dimensions, tank_direction) # clear ghost
	la t0, tank_position 	# loads position addr
	lh t1, 0(t0)		# loads y position value
	addi t1, t1, -2		# moves up 2 pixels	
	sh t1, 0(t0)		# saves new value back in memory
	la t0, tank_direction	# loads direction addr
	li t2, 0		# digit 0 reference
	sb t2, 0(t0)		# saves 0 as direction val
	j loop
down:
  	PRINT_CHARACTER(tank_clear_bin, tank_position, tank_dimensions, tank_direction) # clear ghost
	la t0, tank_position    # loads position addr
	lh t1, 0(t0)		# loads y position value
	addi t1, t1, 2		# moves down 2 pixels
	sh t1, 0(t0)		# saves new value back in memory
	la t0, tank_direction	# loads direction addr
	li t2, 1		# digit 1 reference
	sb t2, 0(t0)		# saves 1 as direction val
	j loop
left: 
  	PRINT_CHARACTER(tank_clear_bin, tank_position, tank_dimensions, tank_direction)	# clear ghost
	la t0, tank_position	# loads position addr
	lh t1, 2(t0)		# loads x postion value
	addi t1, t1, -2		# moves	left 2 pixels
	sh t1, 2(t0)		# saves new value back in memory
	la t0, tank_direction	# loads direction addr
	li t2, 3		# digit 3 reference
	sb t2, 0(t0)		# saves 3 as direction val
	j loop
right:
  	PRINT_CHARACTER(tank_clear_bin, tank_position, tank_dimensions, tank_direction) # clear ghost
	la t0, tank_position	# loads position addr
	lh t1, 2(t0)		# loads x position value
	addi t1, t1, 2		# moves right 2 pixels
	sh t1, 2(t0)		# saves new value back in memory	
	la t0, tank_direction	# loads direction addr
	li t2, 2		# digit 2 reference
	sb t2, 0(t0)		# saves 2 as direction val
	j loop
.end_macro

.text
	SETUP			# initial game setup
	PRINT_MAP(stage1)	# prints stage 1 on screen
 loop:	
  	PRINT_CHARACTER(tank_bin , tank_position, tank_dimensions, tank_direction)	# prints tank
   	CHECK_KEYPRESS()	# checks if any key is pressed
  	lb t0, isrunnig		# checks if game is still running
  	bne t0, zero, loop
  		
FIM: 
 	li a7, 10
 	ecall