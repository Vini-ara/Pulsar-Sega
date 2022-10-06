.text
# vazio = 0, parede = 1, player = 2, chave = 3

.include "matriz_mapa1.data"
initial_matrix_location: .half 865 # usado quando o player morrer
matrix_location: .half 865 # usado pra verificar os espaï¿½os em volta

# game constants
isrunnig: .byte 1 # defines when the game loop stops

# sprites filePaths relative to this file
stage1: .string "stage1/stage1.bin"
tank_clear: .string "blackTile/TankBlackTile.bin"
tank: .string "tank/tank.bin"
key1: .string "key1/key1.bin" 
key2: .string "key2/key2.bin"

# sprites data
tank_bin: .space 64         # alocates 64 bytes (8x8)
tank_clear_bin: .space 64   # alocates 64 bytes (8x8)
key1_bin: .space 56         # alocates 94 bytes (8x7)
key2_bin: .space 56         # alocates 56 bytes (8x7)

# character info
tank_position: .half 13, 209		    # (x, y) 
#tank_old_position: .half 0, 0		    # (x, y) used to have a reference to where to clean the screen
tank_old_position: .half 311, 231		    # (x, y) used to have a reference to where to clean the screen
tank_dimensions: .byte 8, 8		      # (width, height)
tank_clear_dimensions: .byte 8, 8 	# (width, height)
tank_direction: .byte 0 		        # up = 0, down = 1, right = 2, left = 3

# key1 info
key1_position: .half 197, 17  # (x, y)
key1_dimensions: .byte 8, 7   # (width, height)
key1_direction: .byte 2       # right

# key2 info
key2_position: .half 230, 16  # (x, y)
key2_dimensions: .byte 8, 7   # (width, height)
key2_direction: .byte 2       # right

# fuel bar initially is maxed out and is shown as a 285 by 7 pixels area
fuel: .half 285
fuel_cooldown: .half 0

lives: .byte 3
life_address: .half 176, 314	# (x, y)
life_dimensions: .byte 8, 6	# (width, height)

# ============================================================================================================

.text
SETUP:
	la a0, tank             # file name
	la t0, tank_dimensions  # file size
	la s1, tank_bin         # where to save the data
	call OPEN_FILE          # calls the operation to save the file data in memory
	
	la a0,	tank_clear            # file name
	la t0, tank_clear_dimensions  # file size
	la s1, tank_clear_bin         # where to save the data
 	call OPEN_FILE                # calls the operation to save the file data in memory
 	
 	la a0, key1             # file name
	la t0, key1_dimensions  # file size
	la s1, key1_bin         # where to save the data
	call OPEN_FILE          # calls the operation to save the file data in memory
	
	la a0, key2             # file name
	la t0, key2_dimensions  # file size
	la s1, key2_bin         # where to save the data
	call OPEN_FILE          # calls the operation to save the file data in memory

	la a0, stage1           # stage name
	li a1, 0                # frame to print
	call PRINT_MAP          # prints the stage
	
	la a0, stage1           # stage name
	li a1, 1                # frame to print 
	call PRINT_MAP          # prints the stage
	
# ============================================================================================================
	
 GAME_LOOP:
	xori s0, s0, 1        # alternates frame
 	call CHECK_KEYPRESS   # does the keyboard check logic


  # loads all the info to call the print method and print the tank on screen	
 	la t0, tank_position        
 	la t1, tank_dimensions
 	
 	la a0, tank_bin
 	lh a1, 0(t0)
 	lh a2, 2(t0)
 	lb a3, 0(t1)
 	lb a4, 1(t1)
 	lb a5, tank_direction
 	mv a6, s0
  call PRINT		# prints tank
  
  # loads the info needed to print the fuel bar
	la t0, fuel
  lh a0, 0(t0)
  mv a1, s0
  call PRINT_FUEL
  	
  # changes and stores current fuel
  la t0, fuel
  lh a0, 0(t0)
  call MOD_FUEL
  	
  li t0, 0xFF200604   # memory address responsible to keep switching frames
 	sw s0, 0(t0)        # saves fresh printed frame on screen

  # loads all the info to call the print method to clean the current frame
	la t0, tank_old_position 
	la t1, tank_clear_dimensions
	
	la a0, tank_clear_bin
	lh a1, 0(t0)
	lh a2, 2(t0)
	lb a3, 0(t1)
	lb a4, 1(t1)
	lb a5, tank_direction
	mv a6, s0
	call PRINT   # clears the screen
	
  # prints the key in screen everytime (itÂ´s wrong, needs to change)
	la t0, key1_position
	la t1, key1_dimensions
	
	la a0, key1_bin
	lh a1, 0(t0)
	lh a2, 2(t0)
	lb a3, 0(t1)
	lb a4, 1(t1)
	lb a5, key1_direction
	mv a6, s0
	call PRINT
 	 	
  # responsible to run the game loop
  lb t0, isrunnig		# checks if game is still running
  bne t0, zero, GAME_LOOP

# ============================================================================================================
#   From now on are implemented all the "functions" of the code, that can be called with the "call xxxx" syntax
#   As you can see below every function needs some argumests passed in the ax registers before they can be called,
#   and sometimes they can return something after they are called. 
#   Everything is declared before the function implementation.
# ============================================================================================================
 
# ---- ARGUMENTS ----
# a0 = file name
# t0 = dimensions
# s1 = memory destination
OPEN_FILE: 		
	li a1, 0
	li a2, 0
	li a7, 1024
	ecall         # syscall to get the file descriptor
	
	mv t4, a0				# saves file descriptor returned from syscall
	
	lb t2, 0(t0)    # gets X file dimension
	lb t0, 1(t0)     # gets Y file dimension
	mul t0, t0, t2   # gets file size
	
	mv a2, t0     
	mv a1, s1
	li a7, 63
	ecall       # syscall to save a2 bytes from a0 file in a1 memory
	
	mv a0, t4				# file descriptor
 	li a7, 57				# syscall to close file
  ecall

 	ret
 	
CHECK_KEYPRESS: 
	li t1, 0xFF200000		  # carrega o endereï¿½o de controle do KDMMIO
	lw t0, 0(t1)			    # Le bit de Controle Teclado
	andi t0, t0, 0x0001		# mascara o bit menos significativo

  beq t0, zero, FIM 	  # Se nï¿½o hï¿½ tecla pressionada entï¿½o vai para FIM
  lw t2, 4(t1)  			  # le o valor da tecla tecla

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
	# defines the direction the tank is facing before we check colision
	la t0, tank_direction	# loads direction addr
	li t2, 0		          # digit 0 reference
	sb t2, 0(t0)		      # saves 0 as direction val
	
	la t0, MATRIX1
	la t1, matrix_location
	lh t2, 0(t1)
	add t3, t0, t2 		# address of the player from the matrix's beginning (sum of his stored position and the address of MATRIX1)
	addi t4, t3, -36 	# calculates the address above the player (-36, because there are 36 elements in each row)
	lb t6, 0(t4)
	li t5, 1
	beq t6, t5, FIM 	# if the element above is a wall, don't move
	li t5, 3
	beq t6, t5, FIM 	# if it's a key, don't move (we can redirect this to a label that changes the player's flag about keys)

	# if the tank can move:
	sb zero, 0(t3) 		# stores blank where the player was
	li t5, 2
	sb t5, 0(t4) 		  # stores the player code where he's going
	addi t2, t2, -36
	sh t2, 0(t1) 		  # changes the stored starting position in memory
	
	la t0, tank_position 	    # loads position addr
	la t1, tank_old_position  # loads old postion addr
	lh t2, 0(t0) 		          # loads x position
	lh t3, 2(t0)              # loads Y position
	sh t2, 0(t1) 		          # saves x position into old X position
	sh t3, 2(t1)              # saves y position into old y position
	
	lh t1, 2(t0)		  # loads y position value
	addi t1, t1, -8		# moves up 8 pixels	
	sh t1, 2(t0)		  # saves new value back in memory
	
	j FIM 

DOWN:
	# defines the direction the tank is facing before we checks colision 
	la t0, tank_direction	  # loads direction addr
	li t2, 1		            # digit 1 reference
	sb t2, 0(t0)		        # saves 1 as direction val
	
	la t0, MATRIX1
	la t1, matrix_location
	lh t2, 0(t1)
	add t3, t0, t2 		# address of the player from the matrix's beginning (sum of his stored position and the address of MATRIX1)
	addi t4, t3, 36 	# calculates the address below the player (+36, because there are 36 elements in each row)
	lb t6, 0(t4)
	li t5, 1
	beq t6, t5, FIM 	# if the element below is a wall, don't move
	li t5, 3
	beq t6, t5, FIM 	# if it's a key, don't move (we can redirect this to a label that changes the player's flag about keys)

	# if the tank can move:
	sb zero, 0(t3) 	# stores blank where the player was
	li t5, 2
	sb t5, 0(t4) 		# stores the player code where he's going
	addi t2, t2, 36
	sh t2, 0(t1) 		# changes the stored starting position in memory
	
	la t0, tank_position 	    # loads position addr
	la t1, tank_old_position  # loads old postion addr
	lh t2, 0(t0) 		          # loads x position
	lh t3, 2(t0)              # loads y position
	sh t2, 0(t1) 		          # saves x position into old X position
	sh t3, 2(t1)	            # saves y position into old y position
	
	lh t1, 2(t0)		  # loads y position value
	addi t1, t1, 8		# moves down 8 pixels
	sh t1, 2(t0)		  # saves new value back in memory
	
	j FIM 

RIGHT:
	# defines the direction the tank is facing before we checks colision (suggestion)
	la t0, tank_direction	# loads direction addr
	li t2, 2		          # digit 2 reference
	sb t2, 0(t0)		      # saves 2 as direction val
	
	la t0, MATRIX1
	la t1, matrix_location
	lh t2, 0(t1)
	add t3, t0, t2 		# address of the player from the matrix's beginning (sum of his stored position and the address of MATRIX1)
	addi t4, t3, 1 		# calculates the address to the right of the player (+1)
	lb t6, 0(t4)
	li t5, 1
	beq t6, t5, FIM 	# if the element to the right is a wall, don't move
	li t5, 3
	beq t6, t5, FIM 	# if it's a key, don't move (we can redirect this to a label that changes the player's flag about keys)

	# if the tank can move:
	sb zero, 0(t3) 		# stores blank where the player was
	li t5, 2
	sb t5, 0(t4) 		# stores the player code where he's going
	addi t2, t2, 1
	sh t2, 0(t1) 		# changes the stored starting position in memory

	la t0, tank_position 	    # loads position addr
	la t1, tank_old_position  # loads old postion addr
	lh t2, 0(t0) 		          # loads x position
	lh t3, 2(t0)              # loads y position
	sh t2, 0(t1) 		          # saves x position into old x position 
	sh t3, 2(t1)		          # saves y position into old y position
	
	lh t1, 0(t0)		          # loads x position value
	addi t1, t1, 8		        # moves right 8 pixels
	sh t1, 0(t0)		          # saves new value back in memory
		
	j FIM

LEFT: 
	# defines the direction the tank is facing before we checks colision (suggestion)
	la t0, tank_direction	  # loads direction addr
	li t2, 3		            # digit 3 reference
	sb t2, 0(t0)		        # saves 3 as direction val
	
	la t0, MATRIX1
	la t1, matrix_location
	lh t2, 0(t1)
	add t3, t0, t2 		# address of the player starting the matrix's beginning (sum of his stored position and the address MATRIX1)
	addi t4, t3, -1 	# calculates the address to the left of the player (-1)
	lb t6, 0(t4)
	li t5, 1
	beq t6, t5, FIM 	# if the element to the left is a wall, don't move
	li t5, 3
	beq t6, t5, FIM 	# if it's a key, don't move (we can redirect this to a label that changes the player's flag about keys)

	# if the tank can move:
	sb zero, 0(t3) 		# stores blank where the player was
	li t5, 2
	sb t5, 0(t4) 		  # stores the player code where he's going
	addi t2, t2, -1
	sh t2, 0(t1) 		  # changes the stored starting position in memory

	la t0, tank_position 	    # loads position addr
	la t1, tank_old_position  # loads old postion addr
	lh t2, 0(t0) 		          # loads x position
	lh t3, 2(t0)              # loads y position
	sh t2, 0(t1) 		          # saves x position into old x position
	sh t3, 2(t1) 		          # saves y position into old y position
	
	lh t1, 0(t0)		  # loads x postion value
	addi t1, t1, -8		# moves	left 8 pixels
	sh t1, 0(t0)		  # saves new value back in memory

	j FIM 

FIM: 	ret

# ---- ARGUMENTS ----
# a0 = file name addr
# a1 = frame to print
PRINT_MAP: 
	mv t2, a1
	
 	li a1, 0				  # open file for reading
 	li a2, 0			
 	li a7, 1024				# syscall to open file
 	ecall 
 
 	mv t0, a0				  # saves file descriptor returned from syscall
 
 	li t1, 0xFF0			 # vga address
 	add t1, t1, t2		 # desired frame addr
 	
 	slli a1, t1, 20		  # sets to correct addr
 	li a2, 76800				# image size
 	li a7, 63				    # syscall to save file in memory  
 	ecall
 
 	mv a0, t0				# file descriptor
 	li a7, 57				# syscall to close file
 	ecall	
 	ret
 
# ---- ARGUMENTS ----
# a0 = content to print
# a1 = x position
# a2 = y position
# a3 = width
# a4 = height
# a5 = direction to print 	
# a6 = frame 1 or 0
	
PRINT:
	mv t0, a2
	li t1, 320 			    # line widht
	mul t0, t1, t0			# line to start printing
	
	li t3, 0xFF0   			# vga address
	add t3, t3, a6			# alternates frame
	slli t3, t3, 20			# adds all the 5 zeros that were remaining to the address
	
	add t3, t3, t0			# memory address of the line to start printing
	
	mv t0, a1
	add t3, t3, t0			# memory address to start printing
	
	mv s2, a4			# image height
	mv s3, a3			# image width
	
	mv s1, a0			# image data address
	
	li t1, 1			            # down direction code
	beq t1, a5, PRINT_DOWN		# check if going down
	li t1, 2			            # right direction code
	beq t1, a5, PRINT_RIGHT		# check if going right
	li t1, 3			            # left direction code
	beq t1, a5, PRINT_LEFT		# check if going left
  # if it's not going in neither of the above directions it's going up 

PRINT_UP:
	mv t0, s1         # image data address
	mv t1, zero 			# line counter

# the loop goes each line at a time, so it needs 2 loops
UP_LOOP:
	mv t2, zero 			# column counter

UP_LINE_LOOP: 
	lb t4, 0(t0)    # gets current pointed pixel
	sb t4, 0(t3)    # saves pixel in memory 
	addi t0, t0, 1  # goes to next pixel to print
	addi t3, t3, 1  # goes to next memory address to be printed
	addi t2, t2, 1  # adds one to the column counter
	blt t2, s3, UP_LINE_LOOP  # checks if the end of the line has been reached or not
	
	addi t1, t1, 1			# adds 1 to the line counter
	addi t3, t3, 320		# goes to next line
	sub t3, t3, s3      # goes back to the start of the line
	blt t1, s2, UP_LOOP		# print each line untill the image is over

	j PRINT_END

PRINT_DOWN:  
	mv t0, s1			      # file binary addr
	mv t1, s2			      # file height
	mul t1, t1, s3			# height x width (file size)
	add t0, t1, t0 			# file end addr	
	addi t0, t0, -1

DOWN_LOOP:
	mv t2, zero 			  # file column counter
DOWN_LINE_LOOP: 
	lb t4, 0(t0)			  # gets file byte
	sb t4, 0(t3)			  # saves file byte in vga mem
	addi t3, t3, 1			# goes to next vga mem addr
	addi t0, t0, -1			# goes back one byte in file addr
	addi t2, t2, 1
	blt t2, s3, DOWN_LINE_LOOP
	
	addi t3, t3, 320		# goes to next line
	sub t3, t3, s3      # goes back to the start of the line
	bgt t0, s1, DOWN_LOOP  # prints each line untill the image is over

	j PRINT_END

PRINT_RIGHT:
	mv t0, s1       # file data addr

	mv t1, s2       # character height
	addi t1, t1, -1 # character heigth - 1
	mul t1, t1, s3  # goes to the start of the last line 
	add t0, t1, t0  

	mv t5, zero     # line counter
RIGHT_LOOP:
	mv t2, zero
RIGHT_LINE_LOOP:
	lb t4, 0(t0)
	sb t4, 0(t3)
	addi t3, t3, 1
	sub t0, t0, s3
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
	sub t3, t3, s2
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
	sub t3, t3, s2
	mv t0, s1
	addi t1, t1, 1
	add t0, t0, t1
	blt t1, s3, LEFT_LOOP
PRINT_END:
	ret

# ---- ARGUMENTS ----
# a0 = fuel remaining (length)
# a1 = frame to print on
# the color of the fuel bar is always 3F, and it always has 7 pixels of height
PRINT_FUEL:
	li t0, 0xFF0 		# vga adress
	add t0, t0, a1 		# selects the frame
	slli t0, t0, 20	 	# adds the remaining 20 bits to the address
	li t1, 0x00285	 	# the address of the top left corner of the fuel bar
	add t0, t0, t1	 	# where to start printing
	addi t5, t0, 285 	# last address of that line
	mv t2, a0
	add t2, t0, t2 		# pixel where the yellow line ends
	li t3, 2240 		# can't do an addi with this number (7 lines)
	add t3, t5, t3 		# the last address of the fuel area
	li t1, 0x3F 		# color of the bar
		
FUEL_LOOP:
	beqz a0, FUEL_LOOP2 	# special case where there is no fuel left and we don't want any yellow to be printed
	sb t1, 0(t0) 		# paints that pixel yellow
	addi t0, t0, 1 		# next pixel
	blt t0, t2, FUEL_LOOP 	# if t0 < t2, do another loop
FUEL_LOOP2:
	li t4, 285
	beq a0, t4, FUEL_NEXT 	# it misses a pixel when the player has max fuel, so we go aroud the problem
	sb zero, 0(t0)		# since the color black is 0x00, we can use this register
	addi t0, t0, 1 		# next pixel
	blt t0, t5, FUEL_LOOP2	# if t0 < t5, repeat the loop to make the following pixels black
FUEL_NEXT:
	addi t2, t2, 320	# next line
	addi t5, t5, 320
	blt t3, t5, PRINT_END	# if the next line address is bigger than the end, stop_printing
	addi t0, t0, 35		# returns to the beginning of the line (-285) and goes to the next line (+320)
	j FUEL_LOOP

# ---- ARGUMENTS ----
# a0 = fuel remaining
MOD_FUEL:
	li t0, -1
	beq a0, t0, DEATH		# if the fuel is already 0, don't change it (-1 because with 0 there's a pixel left on the screen
	la t0, fuel_cooldown
	lh t1, 0(t0)		# loads the stored cooldown
	li t2, 1000
	blt t1, t2, F_COOLDOWN	# if the stored cooldown is lower than 100, don't change the fuel
	addi a0, a0, -1		# decreases fuel
	sh zero, 0(t0)		# resets the cooldown
	la t0, fuel
  	sh a0, 0(t0) 		# stores the new fuel
	ret

F_COOLDOWN:
	addi t1, t1, 1		# increases the cooldown timer
	sh t1, 0(t0)		
	ret

DEATH:
# clears where the player was
	#frame 0
	la t0, tank_position
	la t1, tank_clear_dimensions
	
	la a0, tank_clear_bin
	lh a1, 0(t0)
	lh a2, 2(t0)
	lb a3, 0(t1)
	lb a4, 1(t1)
	lb a5, tank_direction
	li a6, 0
	call PRINT
	
	#frame 1
	la t0, tank_position
	la t1, tank_clear_dimensions
	
	la a0, tank_clear_bin
	lh a1, 0(t0)
	lh a2, 2(t0)
	lb a3, 0(t1)
	lb a4, 1(t1)
	lb a5, tank_direction
	li a6, 1
	call PRINT
	
# plays an explosion sound and stops the code during it
	li a0,40		# define a nota
	li a1,1500		# define a duração da nota em ms
	li a2,127		# define o instrumento
	li a3,127		# define o volume
	li a7,33		# define o syscall
	ecall			# toca a nota
	li a0, 1500
	li a7, 32
	ecall			# realiza uma pausa de 1500 ms

# resets values so that the player can restart the level (with the exception of keys)
	la t0, tank_position
	li t1, 13		# x position
	li t2, 209		# y position
	sh t1, 0(t0)
	sh t2, 2(t0)
	
	la t0, tank_old_position
	li t1, 311		# bottom left corner x position
	li t2, 231		# bottom left corner y position
	sh t1, 0(t0)
	sh t2, 2(t0)
	
	la t0, tank_direction
	sb zero, (t0)		# up 
	
	la t0, fuel
	li t1, 285		# max fuel
	sh t1, 0(t0)
	
	la t0, fuel_cooldown
	sh zero, 0(t0)		# no cooldown
	
	# matrix position
	la t0, MATRIX1
	la t1, matrix_location
	la t2, initial_matrix_location
	
	lh t3, 0(t1)
	add t3, t3, t0		# address of the player in the matrix
	sb zero, 0(t3)		# stores blank where the player was
	
	lh t3, 0(t2)
	add t3, t3, t0		# address of the strating position in the matrix
	li t4, 2
	sb t4, 0(t3)
	
	lh t3, 0(t2)
	sh t3, 0(t1)		# resets matrix_location
	
	
# clears a tank symbol
	# frame 0
	la t0, life_address
	la t1, life_dimensions
	# la a0, endereço de um black tile novo, pq o tamanho desses tanques não eh 8x8
	lh a1, 0(t0)
	lh a2, 2(t0)
	lb a3, 0(t1)
	lb a4, 1(t1)
	li a5, 0	# up, maybe?
	li a6, 0	# provavelmente vai ter que fazer pros 2 frames
	# call PRINT
	
	# frame 1
	la t0, life_address
	la t1, life_dimensions
	# la a0, endereço de um black tile novo, pq o tamanho desses tanques não eh 8x8
	lh a1, 0(t0)
	lh a2, 2(t0)
	lb a3, 0(t1)
	lb a4, 1(t1)
	li a5, 0	# up, maybe?
	li a6, 1	# provavelmente vai ter que fazer pros 2 frames
	# call PRINT
	
# subtracts 1 life
	la t0, lives
	lb t1, 0(t0)
	addi t1, t1, -1
	beqz t1, GAME_OVER	# if there are no lives left, reset everything
	sb t1, 0(t0)
# return
	j GAME_LOOP

GAME_OVER:
# resets the number of lives
	la t0, lives
	li t1, 3
	sb t1, 0(t0)

# resets the position of the first life to be deleted
	la t0, life_address
	li t1, 176
	li t2, 314
	sh t1, 0(t0)
	sh t2, 2(t0)

# makes the game stop, so you contemplate why you lost (we can put a game over screen here)
	li a0, 3500
	li a7, 32
	ecall
# resets the map
	j SETUP
