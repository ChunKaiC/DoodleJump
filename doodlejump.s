#####################################################################
#
# CSC258H5S Winter 2021 Assembly Programming Project
# University of Toronto Mississauga
#
# Group members:
# - Student 1: Chun-Kai Chen, 1006428457
#
# Bitmap Display Configuration:
# - Unit width in pixels: 8					     
# - Unit height in pixels: 8
# - Display width in pixels: 256
# - Display height in pixels: 256
# - Base Address for Display: 0x10008000 ($gp)
#
# Which milestone is reached in this submission?
# (See the assignment handout for descriptions of the milestones)
# - Milestone 4 achieved 
#
# Which approved additional features have been implemented?
# (See the assignment handout for the list of additional features)
# 1. Added dynamic background - horizontal moving clouds
#
# Any additional information that the TA needs to know:
# - Use j to move left, k to move right.
# - Holding the controls may cause flickering or lag.
# - Re-assembling and re-runing the program may reduce lag and flickering
# - I hope you're doing alright this semester :)
#
#####################################################################

.data
	displayAddress:	.word	0x10008000
	
	white: .word 0xffffff	# White colour code
	green: .word 0x00ff00	# Green colour code
	blue: .word 0x0000ff	# Blue colour code
	black: .word 0x000000	# Black colour code
	cyan: .word 0xc7faff	# Cyan colour code
	
	playerPos: .word 0
	playerJumpCount: .word 0
	playerJump: .word 1
	
	scrollEnable: .word 0 
	scrollCount: .word 0 
	
	platform1: .word 0
	platform2: .word 0
	platform3: .word 0
	platform4: .word 0
	
	cloud1: .word 0
	cloud2: .word 0
	
	run: .word 1
	
.text

# Setup
	# Platform 1
	li $v0, 42
	li $a1, 23
	syscall
	
	addi $a0, $a0, 5
	addi $t0, $a0, 992
	sw $t0, platform1
	
	# Platform 2
	li $v0, 42
	li $a1, 23
	syscall
	
	addi $a0, $a0, 5
	addi $t0, $a0, 640
	sw $t0, platform2
	
	# Platform 3
	li $v0, 42
	li $a1, 23
	syscall
	
	addi $a0, $a0, 5
	addi $t0, $a0, 288
	sw $t0, platform3
	
	# Platform 4
	li $v0, 42
	li $a1, 23
	syscall
	
	addi $a0, $a0, 5
	addi $t0, $a0, -64
	sw $t0, platform4
	
	# Player
	lw $t1, platform1
	subi $t0, $t1, 32
	sw $t0, playerPos
	
	# Cloud1
	li $t0, 320
	sw $t0, cloud1

	# Cloud2
	li $t0, 842
	sw $t0, cloud2
	
	
main:
	gameLoop:
		lw $t9, run
		beqz $t9, exit
	
		jal drawBack
		
		# Cloud
		lw $t0, cloud1
		jal drawCloud
		
		lw $t0, cloud2
		jal drawCloud
		
		# Back
		jal drawPlatform
		jal drawPlayer
		
		
		# Check collision
		lw $t1, platform1
		jal checkPlatform
		
		lw $t1, platform2
		jal checkPlatform
		
		lw $t1, platform3
		jal checkPlatform
		
		jal checkScroll
		
		lw $t0, scrollEnable
		beq $t0, 1, gameScroll
		
	
		jal jumpOrFall
		jal movePlayer
		jal moveCloud
		jal sleep
		jal ifLose
		
		# Reset Cloud
		lw $t0, cloud1
		la $t1, cloud1
		jal resetCloud
		
		lw $t0, cloud2
		la $t1, cloud2
		jal resetCloud
		
		j gameLoop
		
		gameScroll:
			jal scroll
			jal movePlayer
			jal moveCloud
			jal sleep
			jal ifLose
		j gameLoop

# Reset Cloud
resetCloud:
	blt $t0, 1, resetCloudTrue
	jr $ra
	
	resetCloudTrue:
		li $t4, 1025
		sw $t4, ($t1)

# Move cloud
moveCloud:
	lw $t0, cloud1
	subi $t0, $t0, 1
	sw $t0, cloud1

	lw $t0, cloud2
	subi $t0, $t0, 1
	sw $t0, cloud2
	
	jr $ra

# Draw clouds
drawCloud:
	lw $t3, white
	li $t2, 4
	lw $t1, displayAddress
	
	# Cloud 1
	subi $t0, $t0, 1
	mult $t0, $t2
	mflo $t0
	
	add $t9, $t1, $t0
	sw $t3, ($t9)
	
	subi $t9, $t0, 4
	add $t9, $t9, $t1
	sw $t3, ($t9)
	
	subi $t9, $t0, 8
	add $t9, $t9, $t1
	sw $t3, ($t9)
	
	subi $t9, $t0, 12
	add $t9, $t9, $t1
	sw $t3, ($t9)
	
	subi $t9, $t0, 16
	add $t9, $t9, $t1
	sw $t3, ($t9)
	
	subi $t9, $t0, 20
	add $t9, $t9, $t1
	sw $t3, ($t9)
	
	#top
	subi $t9, $t0, 140
	add $t9, $t9, $t1
	sw $t3, ($t9)
	
	subi $t9, $t0, 136
	add $t9, $t9, $t1
	sw $t3, ($t9)
	
	subi $t9, $t0, 132
	add $t9, $t9, $t1
	sw $t3, ($t9)
	
	#bot
	addi $t9, $t0, 112
	add $t9, $t9, $t1
	sw $t3, ($t9)
	
	addi $t9, $t0, 116
	add $t9, $t9, $t1
	sw $t3, ($t9)
	
	addi $t9, $t0, 120
	add $t9, $t9, $t1
	sw $t3, ($t9)
	
	addi $t9, $t0, 124
	add $t9, $t9, $t1
	sw $t3, ($t9)
	
	
	jr $ra

# Check game condition
ifLose:
	lw $t0, playerPos
	bgt $t0, 1120, lose
	
	jr $ra
	
	lose:
		sw $zero, run
		jr $ra
	
# Check scroll
checkScroll:
	lw $t0, playerPos
	lw $t2, playerJump
	
	# Check platform

	bgt $t0, 480, checkScrollEnd
	beq $t2, 0, checkScrollEnd
	
	sw $zero, playerJump
	sw $zero, playerJumpCount
	li $t0, 1
	sw $t0, scrollEnable
	
	checkScrollEnd:
	
		jr $ra

# Scroll
scroll:
	lw $t1, scrollCount
	beq $t1, 11, scrollReset
	
	addi $t1, $t1, 1
	sw $t1, scrollCount
	
	lw $t0, platform1
	addi $t0, $t0, 32
	sw $t0, platform1
	
	lw $t0, platform2
	addi $t0, $t0, 32
	sw $t0, platform2
	
	lw $t0, platform3
	addi $t0, $t0, 32
	sw $t0, platform3
	
	lw $t0, platform4
	addi $t0, $t0, 32
	sw $t0, platform4
	
	jr $ra
	
	scrollReset:
		sw $zero, scrollEnable
		sw $zero, scrollCount
		
		lw $t0, platform2
		sw $t0, platform1
		
		lw $t0, platform3
		sw $t0, platform2
		
		lw $t0, platform4
		sw $t0, platform3
		
		li $v0, 42
		li $a1, 23
		syscall
	
		addi $a0, $a0, 5
		addi $t0, $a0, -64
		sw $t0, platform4
		
		jr $ra
		

# Controls the jumping or falling of the player
jumpOrFall:
	lw $t0, playerJump		#1
	lw $t1, playerJumpCount		#0
	lw $t2, playerPos 
	
	beqz $t0, fall
	blt $t1, 14, jump
	
	sw $zero, playerJump
	sw $zero, playerJumpCount
	
	jr $ra
	
	jump:
		subi $t2, $t2, 32
		sw $t2, playerPos
		addi $t1, $t1, 1
		sw $t1, playerJumpCount
		jr $ra
	
	fall:
		addi $t2, $t2, 32
		sw $t2, playerPos
		jr $ra

# Check platform
checkPlatform:
	lw $t0, playerPos
	
	# Check platform
	subi $t2, $t1, 5
	subi $t2, $t2, 32
	
	addi $t3, $t1, 5
	subi $t3, $t3, 32
	
	blt $t0, $t2, checkPlatformEnd
	bgt $t0, $t3, checkPlatformEnd
	
	li $t0, 1
	sw $t0, playerJump
	
	checkPlatformEnd:
		jr $ra

# Controls fps
sleep:
	li $v0, 32
	li $a0, 50 #fps
	syscall
	jr $ra

# Moves the player
movePlayer:
	lw $t0, playerPos
	lw $t1, 0xffff0004
	beq $t1, 107, moveRight
	beq $t1, 106, moveLeft

	returnMovePlayer:
		jr $ra
	
	moveRight:
		sw $zero, 0xffff0004
		
		li $t1, 32
		div $t0, $t1 
		mfhi $t1
		beqz $t1 rightToLeft
		
		addi $t0, $t0, 1
		sw $t0, playerPos
		j returnMovePlayer
		
		rightToLeft:
			subi $t0, $t0, 31
			sw $t0, playerPos
			j returnMovePlayer
			
	moveLeft:
		sw $zero, 0xffff0004
		
		li $t1, 32
		div $t0, $t1 
		mfhi $t1
		beqz $t1 leftToRight
		
		subi $t0, $t0, 1
		sw $t0, playerPos
		j returnMovePlayer
		
		leftToRight:
			addi $t0, $t0, 31
			sw $t0, playerPos
			j returnMovePlayer

# Draws the background
drawBack:
	lw $t0, displayAddress
	lw $t1, cyan
	li $t2, 0
	drawBackLoop:
		beq $t2, 16, returnDrawBack
		sw $t1, ($t0)
		add $t0, $t0, 4
		sw $t1, ($t0)
		add $t0, $t0, 4
		sw $t1, ($t0)
		add $t0, $t0, 4
		sw $t1, ($t0)
		add $t0, $t0, 4
		sw $t1, ($t0)
		add $t0, $t0, 4
		sw $t1, ($t0)
		add $t0, $t0, 4
		sw $t1, ($t0)
		add $t0, $t0, 4
		sw $t1, ($t0)
		add $t0, $t0, 4
		sw $t1, ($t0)
		add $t0, $t0, 4
		sw $t1, ($t0)
		add $t0, $t0, 4
		sw $t1, ($t0)
		add $t0, $t0, 4
		sw $t1, ($t0)
		add $t0, $t0, 4
		sw $t1, ($t0)
		add $t0, $t0, 4
		sw $t1, ($t0)
		add $t0, $t0, 4
		sw $t1, ($t0)
		add $t0, $t0, 4
		sw $t1, ($t0)
		add $t0, $t0, 4
		sw $t1, ($t0)
		add $t0, $t0, 4
		sw $t1, ($t0)
		add $t0, $t0, 4
		sw $t1, ($t0)
		add $t0, $t0, 4
		sw $t1, ($t0)
		add $t0, $t0, 4
		sw $t1, ($t0)
		add $t0, $t0, 4
		sw $t1, ($t0)
		add $t0, $t0, 4
		sw $t1, ($t0)
		add $t0, $t0, 4
		sw $t1, ($t0)
		add $t0, $t0, 4
		sw $t1, ($t0)
		add $t0, $t0, 4
		sw $t1, ($t0)
		add $t0, $t0, 4
		sw $t1, ($t0)
		add $t0, $t0, 4
		sw $t1, ($t0)
		add $t0, $t0, 4
		sw $t1, ($t0)
		add $t0, $t0, 4
		sw $t1, ($t0)
		add $t0, $t0, 4
		sw $t1, ($t0)
		add $t0, $t0, 4
		sw $t1, ($t0)
		add $t0, $t0, 4
		sw $t1, ($t0)
		add $t0, $t0, 4
		sw $t1, ($t0)
		add $t0, $t0, 4
		sw $t1, ($t0)
		add $t0, $t0, 4
		sw $t1, ($t0)
		add $t0, $t0, 4
		sw $t1, ($t0)
		add $t0, $t0, 4
		sw $t1, ($t0)
		add $t0, $t0, 4
		sw $t1, ($t0)
		add $t0, $t0, 4
		sw $t1, ($t0)
		add $t0, $t0, 4
		sw $t1, ($t0)
		add $t0, $t0, 4
		sw $t1, ($t0)
		add $t0, $t0, 4
		sw $t1, ($t0)
		add $t0, $t0, 4
		sw $t1, ($t0)
		add $t0, $t0, 4
		sw $t1, ($t0)
		add $t0, $t0, 4
		sw $t1, ($t0)
		add $t0, $t0, 4
		sw $t1, ($t0)
		add $t0, $t0, 4
		sw $t1, ($t0)
		add $t0, $t0, 4
		sw $t1, ($t0)
		add $t0, $t0, 4
		sw $t1, ($t0)
		add $t0, $t0, 4
		sw $t1, ($t0)
		add $t0, $t0, 4
		sw $t1, ($t0)
		add $t0, $t0, 4
		sw $t1, ($t0)
		add $t0, $t0, 4
		sw $t1, ($t0)
		add $t0, $t0, 4
		sw $t1, ($t0)
		add $t0, $t0, 4
		sw $t1, ($t0)
		add $t0, $t0, 4
		sw $t1, ($t0)
		add $t0, $t0, 4
		sw $t1, ($t0)
		add $t0, $t0, 4
		sw $t1, ($t0)
		add $t0, $t0, 4
		sw $t1, ($t0)
		add $t0, $t0, 4
		sw $t1, ($t0)
		add $t0, $t0, 4
		sw $t1, ($t0)
		add $t0, $t0, 4
		sw $t1, ($t0)
		add $t0, $t0, 4
		sw $t1, ($t0)
		add $t0, $t0, 4
		
		add $t2, $t2, 1
		j drawBackLoop
	returnDrawBack:
		jr $ra

# Draws the player
drawPlayer:
	# Converts player position into address
	lw $t0, playerPos
	lw $t1, displayAddress
	li $t2, 4
	lw $t3, blue
	
	subi $t0, $t0, 1
	mult $t0, $t2
	mflo $t0		# Player position in terms of address
	
	# Head
	subi $t2, $t0, 256
	add $t2, $t2, $t1
	sw $t3, ($t2)
	
	# Body
	subi $t2, $t0, 124
	add $t2, $t2, $t1
	sw $t3, ($t2)
	
	subi $t2, $t0, 128
	add $t2, $t2, $t1
	sw $t3, ($t2)
	
	subi $t2, $t0, 132
	add $t2, $t2, $t1
	sw $t3, ($t2)
	
	# leg 
	subi $t2, $t0, 4
	add $t2, $t2, $t1
	sw $t3, ($t2)
	
	add $t2, $t0, 4
	add $t2, $t2, $t1
	sw $t3, ($t2)
	
	jr $ra
	
# Draws the platform
drawPlatform:
	li $t0, 4
	lw $t1, displayAddress
	lw $t2, green
	
	# platform 1
	lw $t3, platform1
	
	subi $t3, $t3, 1
	mult $t0, $t3
	mflo $t3		# Position of center in terms of address
	
	subi $t4, $t3, 16
	add $t4, $t1, $t4
	sw $t2, ($t4)
	
	subi $t4, $t3, 12
	add $t4, $t1, $t4
	sw $t2, ($t4)
	
	subi $t4, $t3, 8
	add $t4, $t1, $t4
	sw $t2, ($t4)
	
	subi $t4, $t3, 4
	add $t4, $t1, $t4
	sw $t2, ($t4)
	
	add $t4, $t1, $t3
	sw $t2, ($t4)

	addi $t4, $t3, 4
	add $t4, $t1, $t4
	sw $t2, ($t4)
	
	addi $t4, $t3, 8
	add $t4, $t1, $t4
	sw $t2, ($t4)
	
	addi $t4, $t3, 12
	add $t4, $t1, $t4
	sw $t2, ($t4)
	
	addi $t4, $t3, 16
	add $t4, $t1, $t4
	sw $t2, ($t4)
	
	# platform 2
	lw $t3, platform2
	
	subi $t3, $t3, 1
	mult $t0, $t3
	mflo $t3		# Position of center in terms of address
	
	subi $t4, $t3, 16
	add $t4, $t1, $t4
	sw $t2, ($t4)
	
	subi $t4, $t3, 12
	add $t4, $t1, $t4
	sw $t2, ($t4)
	
	subi $t4, $t3, 8
	add $t4, $t1, $t4
	sw $t2, ($t4)
	
	subi $t4, $t3, 4
	add $t4, $t1, $t4
	sw $t2, ($t4)
	
	add $t4, $t1, $t3
	sw $t2, ($t4)

	addi $t4, $t3, 4
	add $t4, $t1, $t4
	sw $t2, ($t4)
	
	addi $t4, $t3, 8
	add $t4, $t1, $t4
	sw $t2, ($t4)
	
	addi $t4, $t3, 12
	add $t4, $t1, $t4
	sw $t2, ($t4)
	
	addi $t4, $t3, 16
	add $t4, $t1, $t4
	sw $t2, ($t4)
	
	# platform 3
	lw $t3, platform3
	
	subi $t3, $t3, 1
	mult $t0, $t3
	mflo $t3		# Position of center in terms of address
	
	subi $t4, $t3, 16
	add $t4, $t1, $t4
	sw $t2, ($t4)
	
	subi $t4, $t3, 12
	add $t4, $t1, $t4
	sw $t2, ($t4)
	
	subi $t4, $t3, 8
	add $t4, $t1, $t4
	sw $t2, ($t4)
	
	subi $t4, $t3, 4
	add $t4, $t1, $t4
	sw $t2, ($t4)
	
	add $t4, $t1, $t3
	sw $t2, ($t4)

	addi $t4, $t3, 4
	add $t4, $t1, $t4
	sw $t2, ($t4)
	
	addi $t4, $t3, 8
	add $t4, $t1, $t4
	sw $t2, ($t4)
	
	addi $t4, $t3, 12
	add $t4, $t1, $t4
	sw $t2, ($t4)
	
	addi $t4, $t3, 16
	add $t4, $t1, $t4
	sw $t2, ($t4)

	# platform 4
	lw $t3, platform4
	
	subi $t3, $t3, 1
	mult $t0, $t3
	mflo $t3		# Position of center in terms of address
	
	subi $t4, $t3, 16
	add $t4, $t1, $t4
	sw $t2, ($t4)
	
	subi $t4, $t3, 12
	add $t4, $t1, $t4
	sw $t2, ($t4)
	
	subi $t4, $t3, 8
	add $t4, $t1, $t4
	sw $t2, ($t4)
	
	subi $t4, $t3, 4
	add $t4, $t1, $t4
	sw $t2, ($t4)
	
	add $t4, $t1, $t3
	sw $t2, ($t4)

	addi $t4, $t3, 4
	add $t4, $t1, $t4
	sw $t2, ($t4)
	
	addi $t4, $t3, 8
	add $t4, $t1, $t4
	sw $t2, ($t4)
	
	addi $t4, $t3, 12
	add $t4, $t1, $t4
	sw $t2, ($t4)
	
	addi $t4, $t3, 16
	add $t4, $t1, $t4
	sw $t2, ($t4)
	
	jr $ra
	

exit:
	lw $t0, displayAddress
	li $t1, 4
	lw $t2, black
	
	li $t3, 425
	mult $t1, $t3
	mflo $t3
	add $t3, $t0, $t3
	
	# b
	sw $t2, ($t3)
	add $t4, $t3, 128
	sw $t2, ($t4)
	add $t4, $t3, 256
	sw $t2, ($t4)
	add $t4, $t3, 384
	sw $t2, ($t4)
	add $t4, $t3, 512
	sw $t2, ($t4)
	
	add $t4, $t3, 260
	sw $t2, ($t4)
	add $t4, $t3, 264
	sw $t2, ($t4)
	
	add $t4, $t3, 516
	sw $t2, ($t4)
	add $t4, $t3, 520
	sw $t2, ($t4)
	
	add $t4, $t3, 392
	sw $t2, ($t4) 
	
	# y
	add $t4, $t3, 272
	sw $t2, ($t4)
	add $t4, $t3, 400
	sw $t2, ($t4)
	add $t4, $t3, 528
	sw $t2, ($t4)
	add $t4, $t3, 532
	sw $t2, ($t4)
	add $t4, $t3, 536
	sw $t2, ($t4)
	add $t4, $t3, 408
	sw $t2, ($t4)
	add $t4, $t3, 280
	sw $t2, ($t4)
	add $t4, $t3, 664
	sw $t2, ($t4)
	add $t4, $t3, 792
	sw $t2, ($t4)
	add $t4, $t3, 788
	sw $t2, ($t4)
	add $t4, $t3, 784
	sw $t2, ($t4)
	
	# e
	add $t4, $t3, 544
	sw $t2, ($t4)
	add $t4, $t3, 416
	sw $t2, ($t4)
	add $t4, $t3, 288
	sw $t2, ($t4)
	add $t4, $t3, 160
	sw $t2, ($t4)
	add $t4, $t3, 32
	sw $t2, ($t4)
	
	add $t4, $t3, 548
	sw $t2, ($t4)
	add $t4, $t3, 552
	sw $t2, ($t4)
	
	add $t4, $t3, 292
	sw $t2, ($t4)
	add $t4, $t3, 296
	sw $t2, ($t4)
	
	add $t4, $t3, 36
	sw $t2, ($t4)
	add $t4, $t3, 40
	sw $t2, ($t4)
	
	# !
	add $t4, $t3, 48
	sw $t2, ($t4)
	add $t4, $t3, 176
	sw $t2, ($t4)
	add $t4, $t3, 304
	sw $t2, ($t4)
	add $t4, $t3, 560
	sw $t2, ($t4)
	
	li $v0, 10 # terminate the program gracefully
	syscall
