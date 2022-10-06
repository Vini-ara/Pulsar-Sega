.data
.include "MACROSv21.s"
# vazio = 0, parede = 1, player = 2, chave = 3
.include "matriz_mapa1.data"
.include "matriz_mapa2.data"

# sprites filePaths relative to this file
menu:       .string "menu/menu.bin"
stage1:     .string "stage1/stage1.bin"
stage2:     .string "stage2/stage2.bin"
tank_clear: .string "blackTile/TankBlackTile.bin"
tank:       .string "tank/tank.bin"
tankRed:    .string "tankRed/redTank.bin"
tankYellow: .string "tankYellow/yellowTank.bin"
bullet:	    .string ""
yellow_enemy: .string "yellowEnemy/BixoAmareloCerto.bin"
key1:       .string "key1/key1.bin" 
key2:       .string "key2/key2.bin"
key_clear:  .string "keyClear/keyClear.bin"
gate1:      .string "gate1/gate1.bin"
gate2:      .string "gate2/gate2.bin"
gate_clear: .string "gateClear/gateClear.bin"
whiteGate_clear: .string "whiteGate/whiteGateClear.bin"

# sprites data
game.tank_bin:        .space 64         # alocates 64 bytes (8x8)
game.tankRed_bin:     .space 64
game.tankYellow_bin:     .space 64
game.tank_clear_bin:  .space 64   # alocates 64 bytes (8x8)
game.bullet_bin:      .space 64
game.key1_bin:        .space 64         # alocates 64 bytes (8x8)
game.key2_bin:        .space 64         # alocates 64 bytes (8x8)
game.key_clear:       .space 64         # alocates 64 bytes (8x8)
game.gate1_bin:       .space 184        # alocates 184 bytes (23x8)
game.gate2_bin:       .space 184        # alocates 184 bytes (23x8)
game.gate_clear:       .space 184       # alocates 184 bytes (23x8)
game.whiteGateClear:  .space 150  
game.yellow_enemy_bin: .space 64

# game constants
game.initial_matrix_location: .half 865 # usado quando o player morrer
game.matrix_location: .half 865 # usado pra verificar os espa?os em volta
game.matrix_bullet: .half 0

game.isrunnig: .byte 1 # defines when the game loop stops
game.stage: .byte 1 # current stage

# fuel bar initially is maxed out and is shown as a 285 by 7 pixels area
game.fuel: .half 285
game.fuel_cooldown: .half 0
game.lives: .byte 3
game.life_address: .half 175, 234	# (x, y)
game.life_dimensions: .byte 8, 6	# (width, height)

game.score: .word 000000		# score that is shown (up to 5 decimal digits)

# character info
game.tank_position: .half 13, 209		    # (x, y) 
game.tank_old_position: .half 311, 231		    # (x, y) used to have a reference to where to clean the screen
game.tank_dimensions: .byte 8, 8		      # (width, height)
game.tank_direction: .byte 0 		        # up = 0, down = 1, right = 2, left = 3

game.key_dimensions: .byte 8, 8   # (width, height)
game.key_direction: .byte 2
game.key1_active: .byte 0
game.key1_complete: .byte 0
game.key2_active: .byte 0
game.key2_complete: .byte 0
game.need_render: .byte 0

game.gate_dimensions: .byte 23, 8 # (width, height)
game.gate1_position: .half 285, 184 
game.gate2_position: .half 285, 177
game.whiteGateClear_dimensions: .byte 6, 25
game.whiteGate_position: .half 286, 192

# stage 1
stage1.key1_position: .half 213, 17  # (x, y)
stage1.key2_position: .half 117, 17

# stage 2 
stage2.key1_position:  .half 150, 17
stage2.key2_position: .half 21, 17

# enemy 
game.yellow_enemy.position: .half 13, 25
game.yellow_enemy.old_position: .half 311, 231
game.yellow_enemy.dimensions: .byte 8, 8
game.yellow_enemy.direction: .byte 2
game.yellow_enemy.initial_matrix_location: .half 37
game.yellow_enemy.matrix_location: .half 37
game.yellow_enemy.direction_cooldown: .half 0
game.yellow_enemy.move_cooldown: .half 0

game.bullet_position: .half 311, 231		# (x, y) 
game.bullet_old_position: .half 311, 231	# (x, y) used to have a reference to where to clean the screen
game.bullet_dimensions: .byte 8, 8		# (width, height) a gente pode fazer 8x8 ou fazer um menor, vai depender do tamanho da sprite
game.bullet_direction: .byte 0 		        # up = 0, down = 1, right = 2, left = 3
game.bullet_duration: .half 1000		# how many iterations until we move the bullet
game.player_bullet_isthere: .byte 0		# 0 = bullet is dead, 1 = is alive, can't spawn another one
game.bullet_distance: .byte 9			# number of tiles that the bullet will move

music.num: .word 73
# note0, duration_bote0, note1, ... 
music.note_and_duration: .half 67,457,60,457,63,610,68,152,70,152,67,152,60,152,67,152,65,152,63,152,58,152,63,152,65,152,70,152,75,152,77,152,82,152,73,457,64,457,64,610,69,152,71,152,76,152,71,152,76,152,74,914,74,228,75,685,76,915,71,457,70,457,78,914,66,228,68,228,69,915,66,915,68,457,76,914,71,457,72,1372,72,152,69,152,72,152,74,1372,69,304,71,152,72,1372,72,152,70,152,72,152,74,1219,74,152,74,152,72,152,74,152,76,1830,69,1372,69,304,69,152,73,1372,73,152,73,152,67,152,72,457,81,152,81,152,81,152,81,152,81,152,81,152,81,152,81,152,81,152
music.initial_time: .word 0 		# stores the time when the current note was played
music.counter: .half 0, 1		# used to find which note should be played next
music.note_counter: .word 0
music.current_duration: .half 0

# ============================================================================================================

.text
game.SETUP:
	la a0, tank             # file name
	la t0, game.tank_dimensions  # file size
	la s1, game.tank_bin         # where to save the data
	call OPEN_FILE          # calls the operation to save the file data in memory

  la a0, tankRed
  la t0, game.tank_dimensions
  la s1, game.tankRed_bin
  call OPEN_FILE

  la a0, tankYellow
  la t0, game.tank_dimensions
  la s1, game.tankYellow_bin  
  call OPEN_FILE
	
	la a0, tank_clear            # file name
	la t0, game.tank_dimensions  # file size
	la s1, game.tank_clear_bin         # where to save the data
 	call OPEN_FILE                # calls the operation to save the file data in memory
 	
 	la a0, key1             # file name
	la t0, game.key_dimensions  # file size
	la s1, game.key1_bin         # where to save the data
	call OPEN_FILE          # calls the operation to save the file data in memory
	
	la a0, key2             # file name
	la t0, game.key_dimensions  # file size
	la s1, game.key2_bin         # where to save the data
	call OPEN_FILE          # calls the operation to save the file data in memory

  la a0, key_clear
  la t0, game.key_dimensions
  la s1, game.key_clear
  call OPEN_FILE

  la a0, gate1
  la t0, game.gate_dimensions
  la s1, game.gate1_bin
  call OPEN_FILE

  la a0, gate2
  la t0, game.gate_dimensions
  la s1, game.gate2_bin
  call OPEN_FILE

  la a0, gate_clear 
  la t0, game.gate_dimensions
  la s1, game.gate_clear
  call OPEN_FILE

  la a0, whiteGate_clear
  la t0, game.whiteGateClear_dimensions
  la s1, game.whiteGateClear
  call OPEN_FILE

	la a0, yellow_enemy 
	la t0, game.yellow_enemy.dimensions
	la s1, game.yellow_enemy_bin
	call OPEN_FILE

  la a0, menu
  li a1, 0
  call PRINT_MAP

  la a0, menu
  li a1, 1
  call PRINT_MAP

  menu.loop:
	  li t1, 0xFF200000		  # carrega o endere�o de controle do KDMMIO
	  lw t0, 0(t1)			    # Le bit de Controle Teclado
	  andi t0, t0, 0x0001		# mascara o bit menos significativo

    beq t0, zero, FIM 	  # Se n�o h� tecla pressionada ent�o vai para FIM
    lw t2, 4(t1)  			  # le o valor da tecla tecla

    li t3, 'j' 
    bne t2, t3, menu.loop
  
  j stage1.SETUP

stage1.SETUP:
	la a0, stage1           # stage name
	li a1, 0                # frame to print
	call PRINT_MAP          # prints the stage
	
	li a0, 0		# frame to print
	call PRINT_SCORE	# prints the current score
	
	la a0, stage1           # stage name
	li a1, 1                # frame to print 
	call PRINT_MAP          # prints the stage
	
	li a0, 1		# frame to print
	call PRINT_SCORE	# prints the current score

	la t0, stage1.key1_position
	la t1, game.key_dimensions
	
	la a0, game.key1_bin
	lh a1, 0(t0)
	lh a2, 2(t0)
	lb a3, 0(t1)
	lb a4, 1(t1)
	lb a5, game.key_direction
  li a6, 1
	call PRINT

  li a6, 0
	call PRINT

	la t0, stage1.key2_position
	la t1, game.key_dimensions
	
	la a0, game.key2_bin
	lh a1, 0(t0)
	lh a2, 2(t0)
	lb a3, 0(t1)
	lb a4, 1(t1)
	lb a5, game.key_direction
  li a6, 1
	call PRINT

  li a6, 0
	call PRINT

  j game.LOOP
	
stage2.SETUP:
	la a0, stage2           # stage name
	li a1, 0                # frame to print
	call PRINT_MAP          # prints the stage
	
	li a0, 0		# frame to print
	call PRINT_SCORE	# prints the current score
	
	la a0, stage2           # stage name
	li a1, 1                # frame to print 
	call PRINT_MAP          # prints the stage
	
	li a0, 1		# frame to print
	call PRINT_SCORE	# prints the current score

	la t0, stage2.key1_position
	la t1, game.key_dimensions
	
	la a0, game.key1_bin
	lh a1, 0(t0)
	lh a2, 2(t0)
	lb a3, 0(t1)
	lb a4, 1(t1)
	lb a5, game.key_direction
  li a6, 1
	call PRINT

  li a6, 0
	call PRINT

	la t0, stage2.key2_position
	la t1, game.key_dimensions
	
	la a0, game.key2_bin
	lh a1, 0(t0)
	lh a2, 2(t0)
	lb a3, 0(t1)
	lb a4, 1(t1)
	lb a5, game.key_direction
  li a6, 1
	call PRINT

  li a6, 0
	call PRINT

	la t0, game.yellow_enemy.old_position
	li t1, 311
	sh t1, 0(t0)
	li t1, 231
	sh t1, 0(t0)

	la t0, game.yellow_enemy.position 
	li t1, 311
	sh t1, 0(t0) 
	li t1, 231
	sh t1, 2(t0)

	la t0, MATRIX1
	lh t1, game.yellow_enemy.matrix_location
	add t0, t0, t1
	li t2, 0
	sb t2, 0(t0)

  la t0, game.tank_position
  li t1, 13
  sh t1, 0(t0)
  li t1, 209
  sh t1, 2(t0)

  la t0, game.fuel 
  li t1, 285
  sh t1, 0(t0)

  li t1, 0
  la t0, game.key1_complete
  sb t1, 0(t0)

  la t0, game.key2_complete
  sb t1, 0(t0)

  la t0, game.matrix_location
  lh t1, game.initial_matrix_location
  sh t1, 0(t0)

j game.LOOP
# ============================================================================================================
	
 game.LOOP:
	xori s0, s0, 1        # alternates frame

  lb t0, game.stage
  li t1, 1
  beq t0, t1, stage1Logic
  
  la a0, MATRIX2
  call CHECK_KEYPRESS
  
  # updates and prints the bullet
  	la t0, game.bullet_duration
  	lh a0, 0(t0)
  	lb a1, game.bullet_distance
  	la a2, game.bullet_position
  	la a3, game.bullet_old_position
  	lb a4, game.bullet_direction
  	la a5, game.matrix_bullet
  	la a6, game.player_bullet_isthere
  	la a7, MATRIX2
  	call MOVE_BULLET

  j check_render

  stage1Logic:
  la a0, MATRIX1
 	call CHECK_KEYPRESS   # does the keyboard check logic
 	la t0, game.bullet_duration
  	lh a0, 0(t0)
  	lb a1, game.bullet_distance
  	la a2, game.bullet_position
  	la a3, game.bullet_old_position
  	lb a4, game.bullet_direction
  	la a5, game.matrix_bullet
  	la a6, game.player_bullet_isthere
  	la a7, MATRIX2
  	call MOVE_BULLET

  bullet_return:
	la t0, game.bullet_duration
	sh a0, 0(t0)
	la t0, game.bullet_distance
	sb a1, 0(t0)
	
  check_render:

  li t0, 1
  lb t1, game.need_render
  beq t1, t0, re_render
  j no_re_render

  re_render:
  lb t0, game.stage
  li t1, 1
  beq t0, t1, re_render_s1
  j game.RE_RENDER_STAGE2

  re_render_s1:
  j game.RE_RENDER_STAGE1

  no_re_render:



  # loads all the info to call the print method and print the tank on screen	
 	la t0, game.tank_position        
 	la t1, game.tank_dimensions
 	
  lb t2, game.key1_active
  li t3, 1
  beq t2, t3, print_red_tank
  lb t2, game.key2_active
  beq t2, t3, print_yellow_tank

 	la a0, game.tank_bin
  j print_tank

  print_red_tank: 
  la a0, game.tankRed_bin
  j print_tank

  print_yellow_tank:
  la a0, game.tankYellow_bin

  print_tank:
 	lh a1, 0(t0)
 	lh a2, 2(t0)
 	lb a3, 0(t1)
 	lb a4, 1(t1)
 	lb a5, game.tank_direction
 	mv a6, s0
  call PRINT		# prints tank

  # loads all the info to call the print method to clean the current frame
	la t0, game.tank_old_position 
	la t1, game.tank_dimensions
	
	la a0, game.tank_clear_bin
	lh a1, 0(t0)
	lh a2, 2(t0)
	lb a3, 0(t1)
	lb a4, 1(t1)
	lb a5, game.tank_direction
	mv a6, s0
	call PRINT   # clears the screen

	lb t0, game.stage 
	li t1, 1
	beq t0, t1, print_enemy

	j game.loop.move_enemy.continue

	print_enemy:
		la t0, game.yellow_enemy.old_position 
		la t1, game.yellow_enemy.dimensions
		la a0, game.tank_clear_bin
		lh a1, 0(t0)
		lh a2, 2(t0)
		lb a3, 0(t1)
		lb a4, 1(t1)
		lb a5, game.yellow_enemy.direction
		mv a6, s0
		call PRINT   # clears the screen

		la t0, game.yellow_enemy.position
		la t1, game.yellow_enemy.dimensions  

		la a0, game.yellow_enemy_bin 
		lh a1, 0(t0)
		lh a2, 2(t0) 
		lb a3, 0(t1) 
		lb a4, 1(t1) 
		lb a5, game.yellow_enemy.direction 
		mv a6, s0
		call PRINT 

		la a0, MATRIX1
		call game.move_enemy

	game.loop.move_enemy.continue:
  # loads the info needed to print the fuel bar
  la t0, game.fuel
  lh a0, 0(t0)
  mv a1, s0
  call PRINT_FUEL
  	
  # changes and stores current fuel
  la t0, game.fuel
  lh a0, 0(t0)
  call MOD_FUEL

  # checks if a new note from the music should be played and plays it if needed
  call music.NOTE
  	
  li t0, 0xFF200604   # memory address responsible to keep switching frames
 	sw s0, 0(t0)        # saves fresh printed frame on screen

  # responsible to run the game loop
  lb t0, game.isrunnig		# checks if game is still running
  bne t0, zero, game.LOOP

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
 	
#---- ARGUMENTS ----
# a0 = stage matrix
CHECK_KEYPRESS: 
	li t1, 0xFF200000		  # carrega o endere?o de controle do KDMMIO
	lw t0, 0(t1)			    # Le bit de Controle Teclado
	andi t0, t0, 0x0001		# mascara o bit menos significativo

  beq t0, zero, FIM 	  # Se n?o h? tecla pressionada ent?o vai para FIM
  lw t2, 4(t1)  			  # le o valor da tecla tecla

	li t3, 'w'
	beq t2, t3, UP    # se for "w" move para cima
	li t3, 's'
	beq t2, t3, DOWN  # se for "s" vai para baixo
	li t3, 'd'      
	beq t2, t3, RIGHT # se for "d" vai para direita
	li t3, 'a'         
	beq t2, t3, LEFT  # se for letra "a" vai para esquerda
	li t3, 'p'
	beq t2, t3, PONTO
	li t3, 'f'
	beq t2, t3, COMB
	li t3, ' '
	beq t2, t3, FIRE
	j FIM

UP:	
	# defines the direction the tank is facing before we check colision
	la t0, game.tank_direction	# loads direction addr
	li t2, 0		          # digit 0 reference
	sb t2, 0(t0)		      # saves 0 as direction val
	
  mv t0, a0
	la t1, game.matrix_location
	lh t2, 0(t1)
	add t3, t0, t2 		# address of the player from the matrix's beginning (sum of his stored position and the address of MATRIX1)
	addi t4, t3, -36 	# calculates the address above the player (-36, because there are 36 elements in each row)
	lb t6, 0(t4)
	li t5, 1
	beq t6, t5, FIM 	# if the element above is a wall, don't move
	li t5, 3
	beq t6, t5, game.KEY1_ACTIVATION 	# if it's a key, don't move (we can redirect this to a label that changes the player's flag about keys)
  li t5, 4 
  beq t6, t5, game.KEY2_ACTIVATION
  li t5, 5 
  beq t6, t5, game.KEY1_COMPLETION
  li t5, 6
  beq t6, t5, game.KEY2_COMPLETION
	li t5, 8
	beq t5, t6, FIM
  
	# if the tank can move:
	sb zero, 0(t3) 		# stores blank where the player was
	li t5, 2
	sb t5, 0(t4) 		  # stores the player code where he's going
	addi t2, t2, -36
	sh t2, 0(t1) 		  # changes the stored starting position in memory
	
	la t0, game.tank_position 	    # loads position addr
	la t1, game.tank_old_position  # loads old postion addr
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
	la t0, game.tank_direction	  # loads direction addr
	li t2, 1		            # digit 1 reference
	sb t2, 0(t0)		        # saves 1 as direction val
	
  mv t0, a0
	la t1, game.matrix_location
	lh t2, 0(t1)
	add t3, t0, t2 		# address of the player from the matrix's beginning (sum of his stored position and the address of MATRIX1)
	addi t4, t3, 36 	# calculates the address below the player (+36, because there are 36 elements in each row)
	lb t6, 0(t4)
	li t5, 1
	beq t6, t5, FIM 	# if the element below is a wall, don't move
	li t5, 3
	beq t6, t5, FIM 	# if it's a key, don't move (we can redirect this to a label that changes the player's flag about keys)
  li t5, 5 
  beq t6, t5, game.KEY1_COMPLETION
  li t5, 6
  beq t6, t5, game.KEY2_COMPLETION
	li t5, 8
	beq t5, t6, FIM

	# if the tank can move:
	sb zero, 0(t3) 	# stores blank where the player was
	li t5, 2
	sb t5, 0(t4) 		# stores the player code where he's going
	addi t2, t2, 36
	sh t2, 0(t1) 		# changes the stored starting position in memory
	
	la t0, game.tank_position 	    # loads position addr
	la t1, game.tank_old_position  # loads old postion addr
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
	la t0, game.tank_direction	# loads direction addr
	li t2, 2		          # digit 2 reference
	sb t2, 0(t0)		      # saves 2 as direction val
	
  mv t0, a0
	la t1, game.matrix_location
	lh t2, 0(t1)
	add t3, t0, t2 		# address of the player from the matrix's beginning (sum of his stored position and the address of MATRIX1)
	addi t4, t3, 1 		# calculates the address to the right of the player (+1)
	lb t6, 0(t4)
	li t5, 1
	beq t6, t5, FIM 	# if the element to the right is a wall, don't move
	li t5, 3
	beq t6, t5, FIM 	# if it's a key, don't move (we can redirect this to a label that changes the player's flag about keys)
  li t5, 5 
  beq t6, t5, game.KEY1_COMPLETION
  li t5, 6
  beq t6, t5, game.KEY2_COMPLETION
	li t5, 8
	beq t5, t6, FIM

	# if the tank can move:
	sb zero, 0(t3) 		# stores blank where the player was
	li t5, 2
	sb t5, 0(t4) 		# stores the player code where he's going
	addi t2, t2, 1
	sh t2, 0(t1) 		# changes the stored starting position in memory

	la t0, game.tank_position 	    # loads position addr
	la t1, game.tank_old_position  # loads old postion addr
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
	la t0, game.tank_direction	  # loads direction addr
	li t2, 3		            # digit 3 reference
	sb t2, 0(t0)		        # saves 3 as direction val
	
  mv t0, a0
	la t1, game.matrix_location
	lh t2, 0(t1)
	add t3, t0, t2 		# address of the player starting the matrix's beginning (sum of his stored position and the address MATRIX1)
	addi t4, t3, -1 	# calculates the address to the left of the player (-1)
	lb t6, 0(t4)
	li t5, 1
	beq t6, t5, FIM 	# if the element to the left is a wall, don't move
	li t5, 3
	beq t6, t5, FIM 	# if it's a key, don't move (we can redirect this to a label that changes the player's flag about keys)
  li t5, 5 
  beq t6, t5, game.KEY1_COMPLETION
  li t5, 6
  beq t6, t5, game.KEY2_COMPLETION
	li t5, 8
	beq t5, t6, FIM

	# if the tank can move:
	sb zero, 0(t3) 		# stores blank where the player was
	li t5, 2
	sb t5, 0(t4) 		  # stores the player code where he's going
	addi t2, t2, -1
	sh t2, 0(t1) 		  # changes the stored starting position in memory

	la t0, game.tank_position 	    # loads position addr
	la t1, game.tank_old_position  # loads old postion addr
	lh t2, 0(t0) 		          # loads x position
	lh t3, 2(t0)              # loads y position
	sh t2, 0(t1) 		          # saves x position into old x position
	sh t3, 2(t1) 		          # saves y position into old y position
	
	lh t1, 0(t0)		  # loads x postion value
	addi t1, t1, -8		# moves	left 8 pixels
	sh t1, 0(t0)		  # saves new value back in memory

	j FIM 

FIM: 	ret

FIRE:	lb t0, game.player_bullet_isthere
	bnez t0, FIM			# if there is already a player bullet on screen, don't make another one
	lb t0, game.tank_direction	# loads tank direction to determine in which direction the bullet will travel
	li t1, 0
	beq t0, t1, FIRE_UP
	li t1, 1
	beq t0, t1, FIRE_DOWN
	li t1, 2
	beq t0, t1, FIRE_RIGHT
	li t1, 3
	beq t0, t1, FIRE_LEFT
FIRE_UP:
	la t0, game.matrix_location
	lh t0, 0(t0)
	addi t0, t0, -36	# location in the matrix above the player
	# la t1, MATRIX1 == a0
	add a0, a0, t0
	
	lb t2, 0(a0)		# checks if we can spawn a bullet there
	li t3, 1
	beq t2, t3, FIM		# wall?
	li t3, 3
	beq t2, t3, FIM		# key?
	li t3, 4
	beq t2, t3, FIM		# key?
	li t3, 5
	beq t2, t3, FIM		# gate?
	li t3, 6
	beq t2, t3, FIM		# gate?
	
	li t3, 7
	sb t3, 0(a0)		# stores a bullet in that position
	
	la t1, game.matrix_bullet
	sh t0, 0(t1)		# stores the relative position of the bullet within the matrix 
	
	la t0, game.player_bullet_isthere
	li t1, 1
	sb t1, 0(t0)		# stores that there is already a bullet on screen
	
	la t0, game.bullet_direction
	sb zero, 0(t0)		# stores the direction as up
	 
	# the bullet position will be 8 pixels above the player (assuming a 8x8 bullet sprite)
	la t0, game.tank_position
	lh t1, 0(t0)		# x position
	lh t2, 2(t0)		# y position
	addi t2, t2, -8		# up one line
	la t0, game.bullet_position
	sh t1, 0(t0)
	sh t2, 2(t0)
	
	ret

FIRE_DOWN:
	la t0, game.matrix_location
	lh t0, 0(t0)
	addi t0, t0, 36		# location in the matrix below the player
	# la t1, MATRIX1 == a0
	add a0, a0, t0
	
	lb t2, 0(a0)		# checks if we can spawn a bullet there
	li t3, 1
	beq t2, t3, FIM		# wall?
	li t3, 3
	beq t2, t3, FIM		# key?
	li t3, 4
	beq t2, t3, FIM		# key?
	li t3, 5
	beq t2, t3, FIM		# gate?
	li t3, 6
	beq t2, t3, FIM		# gate?
	
	li t3, 7
	sb t3, 0(a0)		# stores a bullet in that position
	
	la t1, game.matrix_bullet
	sh t0, 0(t1)		# stores the relative position of the bullet within the matrix 

	la t0, game.player_bullet_isthere
	li t1, 1
	sb t1, 0(t0)		# stores that there is already a bullet on screen
	
	la t0, game.bullet_direction
	li t1, 1
	sb t1, 0(t0)		# stores the direction as down
		 
	# the bullet position will be 8 pixels above the player (assuming a 8x8 bullet sprite)
	la t0, game.tank_position
	lh t1, 0(t0)		# x position
	lh t2, 2(t0)		# y position
	addi t2, t2, 8		# down one line
	la t0, game.bullet_position
	sh t1, 0(t0)
	sh t2, 2(t0)
	
	ret

FIRE_RIGHT:
	la t0, game.matrix_location
	lh t0, 0(t0)
	addi t0, t0, 1		# location in the matrix to the right of the player
	# la t1, MATRIX1 == a0
	add a0, a0, t0
	
	lb t2, 0(a0)		# checks if we can spawn a bullet there
	li t3, 1
	beq t2, t3, FIM		# wall?
	li t3, 3
	beq t2, t3, FIM		# key?
	li t3, 4
	beq t2, t3, FIM		# key?
	li t3, 5
	beq t2, t3, FIM		# gate?
	li t3, 6
	beq t2, t3, FIM		# gate?
	
	li t3, 7
	sb t3, 0(a0)		# stores a bullet in that position
	
	la t1, game.matrix_bullet
	sh t0, 0(t1)		# stores the relative position of the bullet within the matrix 
	
	la t0, game.player_bullet_isthere
	li t1, 1
	sb t1, 0(t0)		# stores that there is already a bullet on screen
	
	la t0, game.bullet_direction
	li t1, 2
	sb t1, 0(t0)		# stores the direction as down
	 
	# the bullet position will be 8 pixels above the player (assuming a 8x8 bullet sprite)
	la t0, game.tank_position
	lh t1, 0(t0)		# x position
	lh t2, 2(t0)		# y position
	addi t1, t1, 8		# right one line
	la t0, game.bullet_position
	sh t1, 0(t0)
	sh t2, 2(t0)
	
	ret

FIRE_LEFT:
	la t0, game.matrix_location
	lh t0, 0(t0)
	addi t0, t0, -1		# location in the matrix to the left of the player
	# la t1, MATRIX1 == a0
	add a0, a0, t0
	
	lb t2, 0(a0)		# checks if we can spawn a bullet there
	li t3, 1
	beq t2, t3, FIM		# wall?
	li t3, 3
	beq t2, t3, FIM		# key?
	li t3, 4
	beq t2, t3, FIM		# key?
	li t3, 5
	beq t2, t3, FIM		# gate?
	li t3, 6
	beq t2, t3, FIM		# gate?
	
	li t3, 7
	sb t3, 0(a0)		# stores a bullet in that position
	
	la t1, game.matrix_bullet
	sh t0, 0(t1)		# stores the relative position of the bullet within the matrix 

	la t0, game.player_bullet_isthere
	li t1, 1
	sb t1, 0(t0)		# stores that there is already a bullet on screen
	
	la t0, game.bullet_direction
	li t1, 3
	sb t1, 0(t0)		# stores the direction as down
		 
	# the bullet position will be 8 pixels above the player (assuming a 8x8 bullet sprite)
	la t0, game.tank_position
	lh t1, 0(t0)		# x position
	lh t2, 2(t0)		# y position
	addi t1, t1, -8		# left one line
	la t0, game.bullet_position
	sh t1, 0(t0)
	sh t2, 2(t0)
	
	ret

# ---- ARGUMENTS ----
# a0 = bullet duration counter
# a1 = distance left to move
# a2 = address of the current position
# a3 = address of the last position
# a4 = orientation
# a5 = address of its matrix position
# a6 = address of the state of the bullet (dead or alive)
# a7 = MATRIX address
#
# ---- RETURNS ----
# a0 = new bullet duration counter
# a1 = new distance left to move
MOVE_BULLET:
# checks if we can already move the bullet
	lb t0, 0(a6)
	beqz t0, bullet_return
  	bnez a0, BULLET_STAY	# in case we can't move yet, decrease the counter in memory
  	li a0, 1000
  	beqz a1, BULLET_DEATH	# if it can move, check if it already went throught all the tiles it had to do
  	mv s6, a1
	# checks the orientation of the bullet
	li t0, 0
	beq t0, a4, BULLET_UP
	li t0, 1
	beq t0, a4, BULLET_DOWN
	li t0, 2
	beq t0, a4, BULLET_RIGHT
	j BULLET_LEFT		# if it's not any of the above, it's left

BULLET_UP:
	# checks if the space above is open
	lh t0, 0(a5)
	# la t1, MATRIX1 == a7
	add t0, t0, a7		# address in matrix
	#addi t2, t0, -36	# up in the matrix
	
	# store blank where it was and 7 where it will be
	addi t2, t0, 36
	sb zero, 0(t2)		# stores blank
	li t3, 7
	sb t3, 0(t0)		# stores bullet where it is
	#li t3, 7
	#sb s3, 0(t2)		# stores a bullet where it is going
	
	mv s4, a2		# address of the current position
	mv s5, a3		# address of the old position
	mv s7, a5
	mv a5, a4		# orientation

	la a0, game.tankRed_bin	# testing to see if it moves
	lh a1, 0(s4)		# x 
	lh a2, 2(s4)		# y 
	la t2, game.bullet_dimensions
	lb a3, 0(t2)		# width
	lb a4, 1(t2)		# height
	li a6, 0
	call PRINT
	
	li a6, 1
	call PRINT		# both frames

	# clearing where it was
	la a0, game.tank_clear_bin
	lh a1, 0(s5)	# x
	lh a2, 2(s5)	# y
	la t2, game.bullet_dimensions
	lb a3, 0(t2)		# width
	lb a4, 1(t2)		# height
	li a5, 0
	li a6, 0
	call PRINT
	
	li a6, 1
	call PRINT	# both frames
	
	# updates old position in memory
	lh a1, 0(s4)	# now old x position
	lh a2, 2(s4)	# now old y position
	sh a1, 0(s5)
	sh a2, 2(s5)	
	
	lh a1, 0(s4)
	lh a2, 2(s4)
	addi a2, a2, -8		# updates the position
	sh a1, 0(s4)
	sh a2, 2(s4)		# stores the new position
	
	# checks if the space above is open
	lh t0, 0(s7)
	# la t1, MATRIX1 == a7
	add t0, t0, a7		# address in matrix
	addi t2, t0, -36	# up in the matrix
	lb t3, 0(t2)
	#bnez t3, BULLET_END_PATH	# checks if the space ahead is available (we can check for enemies before this)
	lh t0, 0(s7)
	addi t0, t0, -36
	sh t0, 0(s7)		# updates his position in the matrix
	bnez t3, BULLET_END_PATH	# checks if the space ahead is available (we can check for enemies before this)
	
	li a0, 1000
	addi a1, s6, -1
	j bullet_return

BULLET_DOWN:
	# checks if the space above is open
	lh t0, 0(a5)
	# la t1, MATRIX1 == a7
	add t0, t0, a7		# address in matrix
	#addi t2, t0, -36	# up in the matrix
	
	# store blank where it was and 7 where it will be
	addi t2, t0, -36
	sb zero, 0(t2)		# stores blank
	li t3, 7
	sb t3, 0(t0)		# stores bullet where it is
	#li t3, 7
	#sb s3, 0(t2)		# stores a bullet where it is going
	
	mv s4, a2		# address of the current position
	mv s5, a3		# address of the old position
	mv s7, a5
	mv a5, a4		# orientation

	la a0, game.tankRed_bin	# testing to see if it moves
	lh a1, 0(s4)		# x 
	lh a2, 2(s4)		# y 
	la t2, game.bullet_dimensions
	lb a3, 0(t2)		# width
	lb a4, 1(t2)		# height
	li a6, 0
	call PRINT
	
	li a6, 1
	call PRINT		# both frames

	# clearing where it was
	la a0, game.tank_clear_bin
	lh a1, 0(s5)	# x
	lh a2, 2(s5)	# y
	la t2, game.bullet_dimensions
	lb a3, 0(t2)		# width
	lb a4, 1(t2)		# height
	li a5, 0
	li a6, 0
	call PRINT
	
	li a6, 1
	call PRINT	# both frames
	
	# updates old position in memory
	lh a1, 0(s4)	# now old x position
	lh a2, 2(s4)	# now old y position
	sh a1, 0(s5)
	sh a2, 2(s5)	
	
	lh a1, 0(s4)		# x
	lh a2, 2(s4)		# y
	addi a2, a2, 8		# updates the position
	sh a1, 0(s4)
	sh a2, 2(s4)		# stores the new position
	
	# checks if the space above is open
	lh t0, 0(s7)
	# la t1, MATRIX1 == a7
	add t0, t0, a7		# address in matrix
	addi t2, t0, 36		# down in the matrix
	lb t3, 0(t2)
	#bnez t3, BULLET_END_PATH	# checks if the space ahead is available (we can check for enemies before this)
	lh t0, 0(s7)
	addi t0, t0, 36
	sh t0, 0(s7)		# updates his position in the matrix
	bnez t3, BULLET_END_PATH	# checks if the space ahead is available (we can check for enemies before this)
	
	li a0, 1000
	addi a1, s6, -1
	j bullet_return

BULLET_RIGHT:
	# checks if the space above is open
	lh t0, 0(a5)
	# la t1, MATRIX1 == a7
	add t0, t0, a7		# address in matrix
	#addi t2, t0, -36	# up in the matrix
	
	# store blank where it was and 7 where it will be
	addi t2, t0, -1
	sb zero, 0(t2)		# stores blank
	li t3, 7
	sb t3, 0(t0)		# stores bullet where it is
	#li t3, 7
	#sb s3, 0(t2)		# stores a bullet where it is going
	
	mv s4, a2		# address of the current position
	mv s5, a3		# address of the old position
	mv s7, a5
	mv a5, a4		# orientation

	la a0, game.tankRed_bin	# testing to see if it moves
	lh a1, 0(s4)		# x 
	lh a2, 2(s4)		# y 
	la t2, game.bullet_dimensions
	lb a3, 0(t2)		# width
	lb a4, 1(t2)		# height
	li a6, 0
	call PRINT
	
	li a6, 1
	call PRINT		# both frames

	# clearing where it was
	la a0, game.tank_clear_bin
	lh a1, 0(s5)	# x
	lh a2, 2(s5)	# y
	la t2, game.bullet_dimensions
	lb a3, 0(t2)		# width
	lb a4, 1(t2)		# height
	li a5, 0
	li a6, 0
	call PRINT
	
	li a6, 1
	call PRINT	# both frames
	
	# updates old position in memory
	lh a1, 0(s4)	# now old x position
	lh a2, 2(s4)	# now old y position
	sh a1, 0(s5)
	sh a2, 2(s5)	
	
	lh a1, 0(s4)
	lh a2, 2(s4)
	addi a1, a1, 8		# updates the position
	sh a1, 0(s4)
	sh a2, 2(s4)		# stores the new position
	
	# checks if the space above is open
	lh t0, 0(s7)
	# la t1, MATRIX1 == a7
	add t0, t0, a7		# address in matrix
	addi t2, t0, 1	# down in the matrix
	lb t3, 0(t2)
	lh t0, 0(s7)
	addi t0, t0, 1
	sh t0, 0(s7)		# updates his position in the matrix
	bnez t3, BULLET_END_PATH	# checks if the space ahead is available (we can check for enemies before this)
	
	li a0, 1000
	addi a1, s6, -1
	j bullet_return
	
BULLET_LEFT:
	# checks if the space above is open
	lh t0, 0(a5)
	# la t1, MATRIX1 == a7
	add t0, t0, a7		# address in matrix
	#addi t2, t0, -36	# up in the matrix
	
	# store blank where it was and 7 where it will be
	addi t2, t0, 1
	sb zero, 0(t2)		# stores blank
	li t3, 7
	sb t3, 0(t0)		# stores bullet where it is
	#li t3, 7
	#sb s3, 0(t2)		# stores a bullet where it is going
	
	mv s4, a2		# address of the current position
	mv s5, a3		# address of the old position
	mv s7, a5
	mv a5, a4		# orientation

	la a0, game.tankRed_bin	# testing to see if it moves
	lh a1, 0(s4)		# x 
	lh a2, 2(s4)		# y 
	la t2, game.bullet_dimensions
	lb a3, 0(t2)		# width
	lb a4, 1(t2)		# height
	li a6, 0
	call PRINT
	
	li a6, 1
	call PRINT		# both frames

	# clearing where it was
	la a0, game.tank_clear_bin
	lh a1, 0(s5)	# x
	lh a2, 2(s5)	# y
	la t2, game.bullet_dimensions
	lb a3, 0(t2)		# width
	lb a4, 1(t2)		# height
	li a5, 0
	li a6, 0
	call PRINT
	
	li a6, 1
	call PRINT	# both frames
	
	# updates old position in memory
	lh a1, 0(s4)	# now old x position
	lh a2, 2(s4)	# now old y position
	sh a1, 0(s5)
	sh a2, 2(s5)	
	
	lh a1, 0(s4)
	lh a2, 2(s4)
	addi a1, a1, -8		# updates the position
	sh a1, 0(s4)
	sh a2, 2(s4)		# stores the new position
	
	# checks if the space above is open
	lh t0, 0(s7)
	# la t1, MATRIX1 == a7
	add t0, t0, a7		# address in matrix
	addi t2, t0, -1	# down in the matrix
	lb t3, 0(t2)
	lh t0, 0(s7)
	addi t0, t0, -1
	sh t0, 0(s7)		# updates his position in the matrix
	bnez t3, BULLET_END_PATH	# checks if the space ahead is available (we can check for enemies before this)
	
	li a0, 1000
	addi a1, s6, -1
	j bullet_return

BULLET_STAY:
	addi a0, a0, -1
  	j bullet_return 
  	
BULLET_END_PATH:
	li a0, 1000
	li a1, 0
	j bullet_return
  	
BULLET_DEATH:
	lh t1, 0(a5)		# resets the position in the matrix
	# la t0, MATRIX1 == a7
	add a7, a7, t1
	li t0, 0
	beq t0, a4, death_up
	li t0, 1
	beq t0, a4, death_down
	li t0, 2
	beq t0, a4, death_right
#death_left:
	addi a7, a7, 1
	sb zero, 0(a7)
	j volta_bullet
death_up:
	addi a7, a7, 36
	sb zero, 0(a7)
	j volta_bullet
death_down:
	addi a7, a7, -36
	sb zero, 0(a7)
	j volta_bullet
death_right:
	addi a7, a7, -2
	sb zero, 0(a7)
volta_bullet:
	sh zero, 0(a5)		# sets the matrix position as 0
	
	mv s4, a2
	mv s5, a3
	
	sb zero, 0(a6)		# makes the bullet not exist
	
	la a0, game.tank_clear_bin	# clears where the bullet was in both frames
	lh a1, 0(s5)	# x
	lh a2, 2(s5)	# y
	la t2, game.bullet_dimensions
	lb a3, 0(t2)	# width
	lb a4, 1(t2)	# height
	li a5, 0
	li a6, 0
	call PRINT

	li a6, 1
	call PRINT
	
	# sets the old position as the corner
	li t2, 311
	sh t2, 0(t0)
	li t2, 231
	sh t2, 2(t0)
	
	li a1, 9
	li a0, 1000
	j bullet_return

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
	la t0, game.fuel_cooldown
	lh t1, 0(t0)		# loads the stored cooldown
	li t2, 2000
	blt t1, t2, F_COOLDOWN	# if the stored cooldown is lower than 100, don't change the fuel
	addi a0, a0, -1		# decreases fuel
	sh zero, 0(t0)		# resets the cooldown
	la t0, game.fuel
  	sh a0, 0(t0) 		# stores the new fuel
	ret

F_COOLDOWN:
	addi t1, t1, 1		# increases the cooldown timer
	sh t1, 0(t0)		
	ret

DEATH:
# keyyyyy
# clears where the player was
	#frame 0
	la t0, game.tank_position
	la t1, game.tank_dimensions
	
	la a0, game.tank_clear_bin
	lh a1, 0(t0)
	lh a2, 2(t0)
	lb a3, 0(t1)
	lb a4, 1(t1)
	lb a5, game.tank_direction
	li a6, 0
	call PRINT
	
	#frame 1
	la t0, game.tank_position
	la t1, game.tank_dimensions
	
	la a0, game.tank_clear_bin
	lh a1, 0(t0)
	lh a2, 2(t0)
	lb a3, 0(t1)
	lb a4, 1(t1)
	lb a5, game.tank_direction
	li a6, 1
	call PRINT
	
# plays an explosion sound and stops the code during it
	li a0,40		# define a nota
	li a1,1500		# define a dura??o da nota em ms
	li a2,127		# define o instrumento
	li a3,127		# define o volume
	li a7,33		# define o syscall
	ecall			# toca a nota
	li a0, 1500
	li a7, 32
	ecall			# realiza uma pausa de 1500 ms

# resets values so that the player can restart the level (with the exception of keys)
	la t0, game.tank_position
	li t1, 13		# x position
	li t2, 209		# y position
	sh t1, 0(t0)
	sh t2, 2(t0)
	
	la t0, game.tank_old_position
	li t1, 311		# bottom left corner x position
	li t2, 231		# bottom left corner y position
	sh t1, 0(t0)
	sh t2, 2(t0)
	
	la t0, game.tank_direction
	sb zero, (t0)		# up 

	la t0, game.yellow_enemy.position
	la t1, game.yellow_enemy.dimensions

	la a0, game.tank_clear_bin
	lh a1, 0(t0)
	lh a2, 2(t0)
	lb a3, 0(t1)
	lb a4, 1(t1)
	lb a5, game.tank_direction
	li a6, 1
	call PRINT

	li a6, 0
	call PRINT

	la t0, game.yellow_enemy.direction  
	li t1, 2   
	sb t1, 0(t0)

	la t0, game.yellow_enemy.position 
	li t1, 13
	sh t1, 0(t0) 
	li t1, 25
	sh t1, 2(t0) 

		la t0, game.yellow_enemy.position 
	li t1, 13
	sh t1, 0(t0) 
	li t1, 25
	sh t1, 2(t0)

	la t0, MATRIX1
	lh t1, game.yellow_enemy.matrix_location
	add t0, t0, t1
	li t2, 0
	sb t2, 0(t0)

	la t0, MATRIX1
	lh t1, game.yellow_enemy.initial_matrix_location
	add t0, t0, t1
	li t2, 8
	sb t2, 0(t0)

	la t0, MATRIX2
	lh t1, game.yellow_enemy.matrix_location
	add t0, t0, t1
	li t2, 0
	sb t2, 0(t0)

	la t0, MATRIX2
	lh t1, game.yellow_enemy.initial_matrix_location
	add t0, t0, t1
	li t2, 8
	sb t2, 0(t0)

	la t0, game.yellow_enemy.matrix_location
	sh t1, 0(t0)

	la t0, game.yellow_enemy.direction_cooldown
	li t1, 0
	sh t1, 0(t0)

	la t0, game.yellow_enemy.move_cooldown
	li t1, 0 
	sh t1, 0(t0)

	la t0, game.yellow_enemy.matrix_location
	lh t1, game.yellow_enemy.initial_matrix_location
	sh t1, 0(t0)

	la t0, game.yellow_enemy.direction_cooldown
	li t1, 0
	sh t1, 0(t0)

	la t0, game.yellow_enemy.move_cooldown
	li t1, 0 
	sh t1, 0(t0)

	
	la t0, game.fuel
	li t1, 285		# max fuel
	sh t1, 0(t0)
	
	la t0, game.fuel_cooldown
	sh zero, 0(t0)		# no cooldown
	
	# matrix position
  la t0, game.stage
  li t1, 1
  beq t1, t0, DEATH.matrix1
  la t0, MATRIX2

  j DEATH.continue
  
  DEATH.matrix1:
    la t0, MATRIX1

  DEATH.continue:

	la t1, game.matrix_location
	la t2, game.initial_matrix_location
	
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
	la t0, game.life_address
	la t1, game.life_dimensions
	la a0, game.tank_clear_bin
	lh a1, 0(t0)
	lh a2, 2(t0)
	lb a3, 0(t1)
	lb a4, 1(t1)
	li a5, 0	# up, maybe?
	li a6, 0	# provavelmente vai ter que fazer pros 2 frames
	call PRINT
	
	# frame 1
	la t0, game.life_address
	la t1, game.life_dimensions
	la a0, game.tank_clear_bin
	lh a1, 0(t0)
	lh a2, 2(t0)
	lb a3, 0(t1)
	lb a4, 1(t1)
	li a5, 0	# up, maybe?
	li a6, 1	# provavelmente vai ter que fazer pros 2 frames
	call PRINT
	
# modifies the position of the life symbol to be deleted
	la t0, game.life_address
	lh t1, 0(t0)		# we only need to modify the X coordinate
	addi t1, t1, -11	# distance to the top left corner of the next life
	sh t1, 0(t0)
	
# subtracts 1 life
	la t0, game.lives
	lb t1, 0(t0)
	addi t1, t1, -1
	beqz t1, game.GAME_OVER	# if there are no lives left, reset everything
	sb t1, 0(t0)
# return
	j game.LOOP

game.RESET:
	la t0, game.lives
	li t1, 3
	sb t1, 0(t0)
	
# resets the song
	call music.RESET

# resets the position of the first life to be deleted
	la t0, game.life_address
	li t1, 175
	li t2, 234
	sh t1, 0(t0)
	sh t2, 2(t0)
	
# resets the score
	la t0, game.score
	sw zero, 0(t0)

  la t0, game.key1_complete
  li t1, 0
  sb t1, 0(t0)

  la t0, game.key2_complete
  sb t1, 0(t0) 

  la t0, game.key1_active
  sb t1, 0(t0)
  la t0, game.key2_active
  sb t1, 0(t0)

  la t0, game.tank_position
  li t1, 13
  sh t1, 0(t0)
  li t1, 209
  sh t1, 2(t0)
  
  la t0, game.tank_direction
  sb zero, 0(t0)

  lh t0, game.initial_matrix_location
  la t1, game.matrix_location
  sh t0, 0(t1)

  la t0, game.stage
  li t1, 1
  sb t1, 0(t0)

	la t0, game.yellow_enemy.direction  
	li t1, 2   
	sb t1, 0(t0)

	la t0, game.yellow_enemy.position 
	li t1, 13
	sh t1, 0(t0) 
	li t1, 25
	sh t1, 2(t0) 

	la t0, game.yellow_enemy.position 
	li t1, 13
	sh t1, 0(t0) 
	li t1, 25
	sh t1, 2(t0)

	la t0, MATRIX1
	lh t1, game.yellow_enemy.matrix_location
	add t0, t0, t1
	li t2, 0
	sb t2, 0(t0)

	la t0, MATRIX1
	lh t1, game.yellow_enemy.initial_matrix_location
	add t0, t0, t1
	li t2, 8
	sb t2, 0(t0)

	la t0, MATRIX2
	lh t1, game.yellow_enemy.matrix_location
	add t0, t0, t1
	li t2, 0
	sb t2, 0(t0)

	la t0, MATRIX2
	lh t1, game.yellow_enemy.initial_matrix_location
	add t0, t0, t1
	li t2, 8
	sb t2, 0(t0)

	la t0, game.yellow_enemy.matrix_location
	sh t1, 0(t0)

	la t0, game.yellow_enemy.direction_cooldown
	li t1, 0
	sh t1, 0(t0)

	la t0, game.yellow_enemy.move_cooldown
	li t1, 0 
	sh t1, 0(t0)

	la t0, game.yellow_enemy.matrix_location
	lh t1, game.yellow_enemy.initial_matrix_location
	sh t1, 0(t0)

	la t0, game.yellow_enemy.direction_cooldown
	li t1, 0
	sh t1, 0(t0)

	la t0, game.yellow_enemy.move_cooldown
	li t1, 0 
	sh t1, 0(t0)

	j game.SETUP

game.GAME_OVER:
# makes the game stop, so you contemplate why you lost (we can put a game over screen here)
	li a0, 3500
	li a7, 32
	ecall

  j game.RESET

# ---- ARGUMENTS ----
# a0 = frame to print
PRINT_SCORE:
	# the line to print, the color of the number, the frame and the syscall will all be the same in all syscalls
	li a2, 233		# line
	li a3, 0x000000ff	# 00 00 black white (00 00 background_color number_color)
	mv a4, a0		# frame to print
	li a7, 101		# syscall
	
	la t0, game.score
	lw t0, 0(t0)
	li t1, 1000000		# if its bigger than the max score
	bge t0, t1, MOD_SCORE
	
	li t1, 100000		# 6 digit number
	li t2, 86		# column
	bge t0, t1, SHOW_SCORE
	
	li a0, 0		# prints a 0 before the number
	li a1, 86		
	ecall
	
	li t1, 10000		# 5 digit number
	li t2, 94		# last column + 8
	bge t0, t1, SHOW_SCORE
	
	li a0, 0
	li a1, 94
	ecall
	
	li t1, 1000		# 4 digit number
	li t2, 102		# last column + 8
	bge t0, t1, SHOW_SCORE
	
	li a0, 0
	li a1, 102
	ecall
	
	li t1, 100		# 3 digit number
	li t2, 110		# last column + 8
	bge t0, t1, SHOW_SCORE
	
	li a0, 0
	li a1, 110
	ecall
	
  li t1, 10
  li t2, 118        # 2 digit number, there won't be a score of 1 digit
  bge t0, t1, SHOW_SCORE

  li a0, 0        # score = 0
  li a1, 118
  ecall
  li t2, 126

  j SHOW_SCORE	

MOD_SCORE:
	li a0, 999999		# max score
	li a1, 86		# column
	ecall
	ret

SHOW_SCORE:
	mv a0, t0
	mv a1, t2
	ecall
	ret

COMB:
	la t0, game.fuel
	lh t1, 0(t0)
	li t2, 285
	addi t1, t1, 5
	bgt t1, t2, COMB_MAX
	sh t1, 0(t0)
	ret

COMB_MAX:
	sh t2, 0(t0)
	ret

PONTO:
	la t0, game.score
	lw t1, 0(t0)
	addi t1, t1, 500
	sw t1, 0(t0)
	ret

game.KEY1_ACTIVATION:
  li t1, 1 
  lb t0, game.key2_active
  beq t0, t1, game.KEY1_ACTIVATION_END

  la t0, game.key1_active
  sb t1, 0(t0)
  
  mv t0, a0
  sb t1, 25(t0) 

  li t1, 5
  sb t1, 789(t0) 
  sb t1, 790(t0)

  la t0, game.need_render
  li t1, 1
  sb t1, 0(t0)

  game.KEY1_ACTIVATION_END:
  j game.LOOP

game.KEY2_ACTIVATION:
  li t1, 1
  lb t0, game.key1_active
  beq t0, t1, game.KEY2_ACTIVATION_END

  la t0, game.key2_active
  sb t1, 0(t0)

  mv t0, a0
  sb t1, 15(t0)

  li t1, 6
  sb t1, 753(t0)
  sb t1, 754(t0)

  la t0, game.need_render
  li t1, 1
  sb t1, 0(t0)
  
  game.KEY2_ACTIVATION_END:
  j game.LOOP
  
game.KEY1_COMPLETION:
  la t0, game.key1_active
  li t1, 0 
  sb t1, 0(t0)

  la t0, game.key1_complete
  li t1, 1
  sb t1, 0(t0)

  mv t0, a0
  li t1, 0
  sb t1, 789(t0) 
  sb t1, 790(t0)

  la t0, game.need_render
  li t1, 1
  sb t1, 0(t0)
  
  la t0, game.score
  lw t1, 0(t0)
  addi t1, t1, 50
  sw t1, 0(t0)
  li a0, 0
  call PRINT_SCORE
  li a0, 1
  call PRINT_SCORE

  j game.LOOP

game.KEY2_COMPLETION:
  la t0, game.key2_active 
  li t1, 0
  sb t1, 0(t0)

  la t0, game.key2_complete
  li t1, 1 
  sb t1, 0(t0)

  mv t0, a0
  li t1, 0
  sb t1, 753(t0)
  sb t1, 754(t0)

  la t0, game.need_render
  li t1, 1
  sb t1, 0(t0)
  
  la t0, game.score
  lw t1, 0(t0)
  addi t1, t1, 50
  sw t1, 0(t0)
  li a0, 0
  call PRINT_SCORE
  li a0, 1
  call PRINT_SCORE

  j game.LOOP
  
game.RE_RENDER_STAGE1: 
  lb t0, game.key1_active
  li t1, 1
  beq t0, t1, game.RE_RENDER1.key1_activation

  lb t0, game.key2_active
  beq t0, t1, game.RE_RENDER1.key2_activation

  lb t0, game.key1_complete
  beq t0, t1, game.RE_RENDER1.key1_completion

  lb t0, game.key2_complete
  beq t0, t1, game.RE_RENDER1.key2_completion

  j game.RE_RENDER1.end

  game.RE_RENDER1.key1_activation:
    la t0, stage1.key1_position
    la t1, game.key_dimensions

    la a0, game.key_clear  
    lh a1, 0(t0) 
    lh a2, 2(t0)
    lb a3, 0(t1)
    lb a4, 1(t1)
    li a5, 0
    li a6, 0
    call PRINT 

    li a6, 1
    call PRINT

    la t0, game.need_render
    li t1, 0
    sb t1, 0(t0)

    la t0, game.gate1_position  
    la t1, game.gate_dimensions

    la a0, game.gate_clear
    lh a1, 0(t0)
    lh a1, 0(t0) 
    lh a2, 2(t0)
    lb a3, 0(t1)
    lb a4, 1(t1)
    li a5, 0
    li a6, 0
    call PRINT 

    li a6, 1 
    call PRINT

    la a0, game.gate1_bin
    addi a1, a1, -16
    call PRINT
    
    li a6, 0
    call PRINT
    
    j game.RE_RENDER1.end

  game.RE_RENDER1.key1_completion: 
    la t0, game.gate1_position
    la t1, game.gate_dimensions

    la a0, game.gate_clear  
    lh a1, 0(t0) 
    addi a1, a1, -16
    lh a2, 2(t0)
    lb a3, 0(t1)
    lb a4, 1(t1)
    li a5, 0
    li a6, 0
    call PRINT 

    li a6, 1
    call PRINT

    la t0, game.gate1_position
    la t1, game.key_dimensions
    la a0, game.key_clear
    lh a1, 0(t0)
    lh a2, 2(t0)
    lb a3, 0(t1)
    lb a4, 1(t1)
    li a5, 2
    li a6, 0
    call PRINT 

    li a6, 1 
    call PRINT

    la t0, game.fuel
    lh t1, 0(t0) 
    addi t1, t1, 50
    li t2, 285
    bgt t1, t2, game.RE_RENDER1.max_fuel

    sh t1, 0(t0)
    j game.RE_RENDER1.normal

    game.RE_RENDER1.max_fuel:
    sh t2, 0(t0)

    game.RE_RENDER1.normal:
    la t0, game.need_render
    li t1, 0
    sb t1, 0(t0)

    j game.RE_RENDER1.end

  game.RE_RENDER1.key2_activation:
    la t0, stage1.key2_position
    la t1, game.key_dimensions

    la a0, game.key_clear  
    lh a1, 0(t0) 
    lh a2, 2(t0)
    lb a3, 0(t1)
    lb a4, 1(t1)
    li a5, 0
    li a6, 0
    call PRINT 

    li a6, 1
    call PRINT

    la t0, game.gate2_position  
    la t1, game.gate_dimensions

    la a0, game.gate_clear
    lh a1, 0(t0)
    lh a1, 0(t0) 
    lh a2, 2(t0)
    lb a3, 0(t1)
    lb a4, 1(t1)
    li a5, 0
    li a6, 0
    call PRINT 

    li a6, 1 
    call PRINT

    la a0, game.gate2_bin
    addi a1, a1, -16
    call PRINT
    
    li a6, 0
    call PRINT

    la t0, game.need_render
    li t1, 0
    sb t1, 0(t0)
    
    j game.RE_RENDER1.end

  game.RE_RENDER1.key2_completion:
    la t0, game.gate2_position
    la t1, game.gate_dimensions

    la a0, game.gate_clear  
    lh a1, 0(t0) 
    addi a1, a1, -16
    lh a2, 2(t0)
    lb a3, 0(t1)
    lb a4, 1(t1)
    li a5, 0
    li a6, 0
    call PRINT 

    li a6, 1
    call PRINT

    la t0, game.gate2_position
    la t1, game.key_dimensions
    la a0, game.key_clear
    lh a1, 0(t0)
    lh a2, 2(t0)
    lb a3, 0(t1)
    lb a4, 1(t1)
    li a5, 2
    li a6, 0
    call PRINT 

    li a6, 1 
    call PRINT

    la t0, game.need_render
    li t1, 0
    sb t1, 0(t0)

    la t0, game.fuel
    lh t1, 0(t0) 
    addi t1, t1, 50
    li t2, 285
    bgt t1, t2, game.RE_RENDER1.max_fuel1

    sh t1, 0(t0)
    j game.RE_RENDER1.normal1      

    game.RE_RENDER1.max_fuel1:
    sh t2, 0(t0)

    game.RE_RENDER1.normal1:
      la t0, game.need_render
      li t1, 0
      sb t1, 0(t0)
    
  game.RE_RENDER1.end:
    li t1, 1  
    lb t0, game.key1_complete
    bne t0, t1, game.RE_RENDER1.keep_going

    lb t0, game.key2_complete
    bne t0, t1, game.RE_RENDER1.keep_going

    call game.clear_all_gates
    
    game.RE_RENDER1.keep_going:
    j game.LOOP

game.RE_RENDER_STAGE2:
  lb t0, game.key1_active
  li t1, 1
  beq t0, t1, game.RE_RENDER2.key1_activation

  lb t0, game.key2_active
  beq t0, t1, game.RE_RENDER2.key2_activation

  lb t0, game.key1_complete
  beq t0, t1, game.RE_RENDER2.key1_completion

  lb t0, game.key2_complete
  beq t0, t1, game.RE_RENDER2.key2_completion

  j game.RE_RENDER2.end

  game.RE_RENDER2.key1_activation:
    la t0, stage2.key1_position
    la t1, game.key_dimensions

    la a0, game.key_clear  
    lh a1, 0(t0) 
    lh a2, 2(t0)
    lb a3, 0(t1)
    lb a4, 1(t1)
    li a5, 0
    li a6, 0
    call PRINT 

    li a6, 1
    call PRINT

    la t0, game.need_render
    li t1, 0
    sb t1, 0(t0)

    la t0, game.gate1_position  
    la t1, game.gate_dimensions

    la a0, game.gate_clear
    lh a1, 0(t0)
    lh a1, 0(t0) 
    lh a2, 2(t0)
    lb a3, 0(t1)
    lb a4, 1(t1)
    li a5, 0
    li a6, 0
    call PRINT 

    li a6, 1 
    call PRINT

    la a0, game.gate1_bin
    addi a1, a1, -16
    call PRINT
    
    li a6, 0
    call PRINT
    
    j game.RE_RENDER2.end

  game.RE_RENDER2.key1_completion: 
    la t0, game.gate1_position
    la t1, game.gate_dimensions

    la a0, game.gate_clear  
    lh a1, 0(t0) 
    addi a1, a1, -16
    lh a2, 2(t0)
    lb a3, 0(t1)
    lb a4, 1(t1)
    li a5, 0
    li a6, 0
    call PRINT 

    li a6, 1
    call PRINT

    la t0, game.gate1_position
    la t1, game.key_dimensions
    la a0, game.key_clear
    lh a1, 0(t0)
    lh a2, 2(t0)
    lb a3, 0(t1)
    lb a4, 1(t1)
    li a5, 2
    li a6, 0
    call PRINT 

    li a6, 1 
    call PRINT

    la t0, game.fuel
    lh t1, 0(t0) 
    addi t1, t1, 50
    li t2, 285
    bgt t1, t2, game.RE_RENDER2.max_fuel

    sh t1, 0(t0)
    j game.RE_RENDER2.normal

    game.RE_RENDER2.max_fuel:
    sh t2, 0(t0)

    game.RE_RENDER2.normal:
    la t0, game.need_render
    li t1, 0
    sb t1, 0(t0)

    li t1, 1
    lb t0, game.key2_complete
    beq t0, t1, game.RE_RENDER2.key2_completion

    j game.RE_RENDER2.end

  game.RE_RENDER2.key2_activation:
    la t0, stage2.key2_position
    la t1, game.key_dimensions

    la a0, game.key_clear  
    lh a1, 0(t0) 
    lh a2, 2(t0)
    lb a3, 0(t1)
    lb a4, 1(t1)
    li a5, 0
    li a6, 0
    call PRINT 

    li a6, 1
    call PRINT

    la t0, game.gate2_position  
    la t1, game.gate_dimensions

    la a0, game.gate_clear
    lh a1, 0(t0)
    lh a1, 0(t0) 
    lh a2, 2(t0)
    lb a3, 0(t1)
    lb a4, 1(t1)
    li a5, 0
    li a6, 0
    call PRINT 

    li a6, 1 
    call PRINT

    la a0, game.gate2_bin
    addi a1, a1, -16
    call PRINT
    
    li a6, 0
    call PRINT

    la t0, game.need_render
    li t1, 0
    sb t1, 0(t0)
    
    j game.RE_RENDER2.end

  game.RE_RENDER2.key2_completion:
    la t0, game.gate2_position
    la t1, game.gate_dimensions

    la a0, game.gate_clear  
    lh a1, 0(t0) 
    addi a1, a1, -16
    lh a2, 2(t0)
    lb a3, 0(t1)
    lb a4, 1(t1)
    li a5, 0
    li a6, 0
    call PRINT 

    li a6, 1
    call PRINT

    la t0, game.gate2_position
    la t1, game.key_dimensions
    la a0, game.key_clear
    lh a1, 0(t0)
    lh a2, 2(t0)
    lb a3, 0(t1)
    lb a4, 1(t1)
    li a5, 2
    li a6, 0
    call PRINT 

    li a6, 1 
    call PRINT

    la t0, game.need_render
    li t1, 0
    sb t1, 0(t0)

    la t0, game.fuel
    lh t1, 0(t0) 
    addi t1, t1, 50
    li t2, 285
    bgt t1, t2, game.RE_RENDER2.max_fuel1

    sh t1, 0(t0)
    j game.RE_RENDER2.normal1      

    game.RE_RENDER2.max_fuel1:
    sh t2, 0(t0) 

    game.RE_RENDER2.normal1:
      la t0, game.need_render
      li t1, 0
      sb t1, 0(t0)
    
  game.RE_RENDER2.end:
    li t1, 1  
    lb t0, game.key1_complete
    bne t0, t1, game.RE_RENDER2.keep_going

    lb t0, game.key2_complete
    bne t0, t1, game.RE_RENDER2.keep_going

    call game.clear_all_gates
    
    game.RE_RENDER2.keep_going:
    j game.LOOP

game.clear_all_gates:
    la t0, game.gate1_position
    la t1, game.gate_dimensions

    la a0, game.gate_clear  
    lh a1, 0(t0) 
    addi a1, a1, -16
    lh a2, 2(t0)
    lb a3, 0(t1)
    lb a4, 1(t1)
    li a5, 0
    li a6, 0
    call PRINT 

    li a6, 1
    call PRINT

    la t0, game.gate2_position
    la a0, game.gate_clear  
    lh a2, 2(t0)
    li a6, 0
    call PRINT 

    li a6, 1
    call PRINT

    la t0, game.gate2_position
    la t1, game.key_dimensions
    la a0, game.key_clear
    lh a1, 0(t0)
    lh a2, 2(t0)
    lb a3, 0(t1)
    lb a4, 1(t1)
    li a5, 2
    li a6, 0
    call PRINT 

    li a6, 1 
    call PRINT

    la t0, game.gate1_position
    lh a1, 0(t0) 
    lh a2, 2(t0)
    li a5, 2
    li a6, 0
    call PRINT 

    li a6, 1
    call PRINT

    li t1, 1
    lb t0, game.stage
    beq t0, t1, game.clear_all_gates.jump1

    j stage2.COMPLETION

    game.clear_all_gates.jump1:
      j stage1.COMPLETION

game.stage_completion_animation:
  la t0, game.whiteGate_position
  la t1, game.whiteGateClear_dimensions

  la a0, game.whiteGateClear
  lh a1, 0(t0)
  lh a2, 2(t0)
  lb a3, 0(t1)
  lb a4, 1(t1)
  li a5, 0
  li a6, 0
  call PRINT

  li a6, 1
  call PRINT

  la t0, game.tank_position
  la t1, game.tank_dimensions

  la a0, game.tank_clear_bin
  lh a1, 0(t0)
  lh a2, 2(t0)
  lb a3, 0(t1)
  lb a4, 1(t1)
  li a5, 0
  li a6, 0 
  call PRINT

  li a6, 1
  call PRINT

  la t1, game.tank_dimensions
  la a0, game.tank_bin
  li a1, 277
  li a2, 200
  lb a3, 0(t1)
  lb a4, 1(t1)
  li a5, 2
  li a6, 0 
  call PRINT

  li a6, 1
  call PRINT

	li a0, 2000
	li a7, 32
	ecall			# realiza uma pausa de 1500 ms

  la t1, game.tank_dimensions
  la a0, game.tank_clear_bin
  li a1, 277
  li a2, 200
  lb a3, 0(t1)
  lb a4, 1(t1)
  li a5, 2
  li a6, 0 
  call PRINT

  li a6, 1
  call PRINT

  la t1, game.tank_dimensions
  la a0, game.tank_bin
  li a1, 285
  li a2, 200
  lb a3, 0(t1)
  lb a4, 1(t1)
  li a5, 2
  li a6, 0 
  call PRINT

  li a6, 1
  call PRINT

	li a0, 2000
	li a7, 32
	ecall			# realiza uma pausa de 1500 ms

  li t1, 1
  lb t0, game.stage
  beq t0, t1, game.stage_completion_animation.jump1

  j stage2.COMPLETION.continuation

  game.stage_completion_animation.jump1:
    j stage1.COMPLETION.continuation
  ret

stage1.COMPLETION:
  call game.stage_completion_animation

  stage1.COMPLETION.continuation:
  li t0, 2
  la t1, game.stage
  sb t0, 0(t1)

  j stage2.SETUP

stage2.COMPLETION:
  call game.stage_completion_animation

  stage2.COMPLETION.continuation:
  
  j game.RESET

music.NOTE:
  # gets the duration of the current note
  	la t1, music.current_duration
  	lhu t1, 0(t1)
  # gets the current time to compare with the initial time
  	li a7, 30
  	ecall					# a0 = low order 32 bits of the current time in milliseconds since 1 January 1970

  	la t0, music.initial_time		# low order 32 bits of the time when the current note started playing
  	lw t0, 0(t0)

  # gets the difference between the stored time and the current time and check it that's greater than the duration
  	sub t0, a0, t0

  # in case there was a rare exception in which that difference is zero, play the note anyway to keep the music playing
 	blt t0, zero, music.PLAY

  # now check if that difference is equal or greater than the note duration
  	bge t0, t1, music.PLAY

	ret		# if not, just go back

music.PLAY:
  # gets the current time and stores it in memory
	li a7, 30
	ecall
	la t0, music.initial_time
	sw a0, 0(t0)
  # gets the next note and duration in memory
  	la t0, music.counter
  	lhu t1, 0(t0)
  	lhu t2, 2(t0)
  	slli t1, t1, 1		# multiplies by 2 because we are dealing with halfword addresses
  	slli t2, t2, 1
  	la t3, music.note_and_duration
  	add t4, t3, t2		# duration address
  	add t3, t3, t1		# note address
  	lhu a0, 0(t3)		# note
  	lhu a1, 0(t4)		# duration
  	
  # setting up the rest of the parameters of the syscall
  	li a2, 95		# instrument
  	li a3, 127		# volume 
  	li a7, 31		# MIDI Out Syscall
  	ecall
  	
  # stores new duration and counters in memory
  	srli t1, t1, 1		# restores the original form of the note counters
  	srli t2, t2, 1
  	addi t1, t1, 1		# goes to next note and duration
  	addi t2, t2, 1 
  	sh t1, 0(t0)
  	sh t2, 2(t0)
  	
  	la t0, music.current_duration
  	sh a1, 0(t0)		# stores the duration of the current note
  	
  	la t0, music.note_counter
  	lw t0, 0(t0)
  	addi t0, t0, 1		# number of notes that have been played
  	la t1, music.num
  	lw t1, 0(t1)		# total number of notes
  	
  	bgt t0, t1, music.RESET	# if the number of notes played is bigger than what is avilable, reset
  	
  	la t1, music.note_counter
  	sw t0, 0(t1)
  	
  	ret
  	
music.RESET:
	la t0, music.note_counter
	sw zero, 0(t0)
	
	la t0, music.counter
	li t1, 1
	sh zero, 0(t0)
	sh t1, 2(t0)
	
	ret

game.move_enemy:
	mv s3, a0
	lh t0, game.yellow_enemy.direction_cooldown
	li t1, 30000
	beq t1, t0, game.move_enemy.random_direction

	la t0, game.yellow_enemy.direction_cooldown
	lh t1, 0(t0)
	addi t1, t1, 1
	sh t1, 0(t0)

	la t0, game.yellow_enemy.move_cooldown
	lh t1, 0(t0)
	addi t1, t1, 1
	sh t1, 0(t0)

	j game.move_enemy.move

	game.move_enemy.random_direction:
		li a7, 30
		ecall   

		li a7, 42
		li a1, 4
		ecall 

		la t0, game.yellow_enemy.direction
		sb a0, 0(t0)

		li t0, 0
		la t1, game.yellow_enemy.direction_cooldown
		sh t0, 0(t1)

		li t0, 0
		la t1, game.yellow_enemy.move_cooldown
		sh t0, 0(t1)

		j game.move_enemy.end
	
	game.move_enemy.move:
		lb t0, game.yellow_enemy.direction 

		li t1, 0
		beq t1, t0, game.move_enemy.check_up

		li t1, 1
		beq t1, t0, game.move_enemy.check_down

		li t1, 2
		beq t1, t0, game.move_enemy.check_right

		j game.move_enemy.check_left

	 	game.move_enemy.check_up:
			lh t0, game.yellow_enemy.move_cooldown
			li t1, 5000
			bne t0, t1, game.move_enemy.end

	 		mv t0, s3
			lh t1, game.yellow_enemy.matrix_location
			add t0, t1, t0
	 		addi t0, t0, 1

			
	 		# checa o pixel da direita
	 		lb t1, 0(t0)
	 		bne zero, t1, game.move_enemy.random_direction

	 		# atualiza a matriz
			li t1, 8
			sb t1, 0(t0)
			addi t0, t0, -1
			sb zero, 0(t0)

			la t0, game.yellow_enemy.matrix_location
			lh t1, game.yellow_enemy.matrix_location
			addi t1, t1, 1
			sh t1, 0(t0) 

			la t0, game.yellow_enemy.position
			la t1, game.yellow_enemy.old_position
			lw t2, 0(t0)
			sw t2, 0(t1)

			lh t1, 0(t0)
			addi t1, t1, 8 
			sh t1, 0(t0)

			la t0, game.yellow_enemy.move_cooldown
			sh zero, 0(t0)

			ret
		
	 	 game.move_enemy.check_down:
			lh t0, game.yellow_enemy.move_cooldown
			li t1, 5000
			bne t0, t1, game.move_enemy.end

			mv t0, s3
			lh t1, game.yellow_enemy.matrix_location
			add t0, t1, t0
			addi t0, t0, -1

			#checa o pixel de cima
			lb t1, 0(t0)
			bne zero, t1, game.move_enemy.random_direction

			# # atualiza a matriz
			li t1, 8
			sb t1, 0(t0)
			addi t0, t0, 1
			sb zero, 0(t0)

			la t0, game.yellow_enemy.matrix_location
			lh t1, game.yellow_enemy.matrix_location
			addi t1, t1, -1
			sh t1, 0(t0) 

			la t0, game.yellow_enemy.position
			la t1, game.yellow_enemy.old_position
			lw t2, 0(t0)
			sw t2, 0(t1)

			lh t1, 0(t0)
			addi t1, t1, -8 
			sh t1, 0(t0)

			la t0, game.yellow_enemy.move_cooldown
			sh zero, 0(t0)

		 	ret
		
	 	  game.move_enemy.check_right:
			lh t0, game.yellow_enemy.move_cooldown
			li t1, 5000
			bne t0, t1, game.move_enemy.end

	 		mv t0, s3
			lh t1, game.yellow_enemy.matrix_location
			add t0, t1, t0
	 		addi t0, t0, 36

	 		# checa o pixel da direita
	 		lb t1, 0(t0)
	 		bne zero, t1, game.move_enemy.random_direction

	 		# atualiza a matriz
			li t1, 8
			sb t1, 0(t0)
			addi t0, t0, -36
			sb zero, 0(t0)

			la t0, game.yellow_enemy.matrix_location
			lh t1, game.yellow_enemy.matrix_location
			addi t1, t1, 36
			sh t1, 0(t0) 

			la t0, game.yellow_enemy.position
			la t1, game.yellow_enemy.old_position
			lw t2, 0(t0)
			sw t2, 0(t1)

			lh t1, 2(t0)
			addi t1, t1, 8 
			sh t1, 2(t0)

			la t0, game.yellow_enemy.move_cooldown
			sh zero, 0(t0)

			ret
		
	 	 game.move_enemy.check_left:
			lh t0, game.yellow_enemy.move_cooldown
			li t1, 7500
			bne t0, t1, game.move_enemy.end

			mv t0, s3
			lh t1, game.yellow_enemy.matrix_location
			add t0, t1, t0
			addi t0, t0, -36

			#checa o pixel de cima
			lb t1, 0(t0)
			bne zero, t1, game.move_enemy.random_direction

			# # atualiza a matriz
			li t1, 8
			sb t1, 0(t0)
			addi t0, t0, 36
			sb zero, 0(t0)

			la t0, game.yellow_enemy.matrix_location
			lh t1, game.yellow_enemy.matrix_location
			addi t1, t1, -36
			sh t1, 0(t0) 

			la t0, game.yellow_enemy.position
			la t1, game.yellow_enemy.old_position
			lw t2, 0(t0)
			sw t2, 0(t1)
			lh t1, 2(t0)
			addi t1, t1, -8 
			sh t1, 2(t0)

			la t0, game.yellow_enemy.move_cooldown
			sh zero, 0(t0)

			ret
game.move_enemy.end:
ret

.include "SYSTEMv21.s"
