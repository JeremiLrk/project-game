 .globl main

.data
mazeFilename:    .asciiz "C:/Users/Jeremi/Downloads/test/input_1.txt"
buffer:          .space 4096
victoryMessage:  .asciiz "You have won the game!"
invalid: .asciiz"Unknown input! Valid inputs: z s q d x"

amountOfRows:    .word 16  # The mount of rows of pixels
amountOfColumns: .word 32  # The mount of columns of pixels

wallColor:      .word 0x004286F4    # Color used for walls (blue)
passageColor:   .word 0x00000000    # Color used for passages (black)
playerColor:    .word 0x00FFFF00    # Color used for player (yellow)
exitColor:      .word 0x0000FF00    # Color used for exit (green)

.text

main:
 # print maze
 jal printmaze
 
 # store player (row,col) in ($s0, $s1)
 # (12,15) STARTING POSITION PLAYER
 li $s0, 12
 li $s1, 15
 
 # (4,7) END POSITION MAZE
 li $s2, 4
 li $s3, 7
 
inputloop:
    # Lees een karakter van de gebruiker
    li $v0, 12     # Systeemoproep voor het lezen van een karakter
    syscall
    move $t0, $v0   # Bewaar het gelezen karakter in $t0

    # branch if input = z, q, s, d, x
    beq $t0, 122, up    # z
    beq $t0, 113, left  # q
    beq $t0, 115, down  # s
    beq $t0, 100, right # d
    beq $t0, 120, exit  # x

    # als geen geldige input, print 'invalid' bericht
    li $v0, 4
    la $a0, invalid
    syscall

    j inputloop


up:
 # moving up: row - 1
 move $a0, $s0
 subi $a2, $s0, 1
 
 # column stays the same
 move $a1, $s1
 move $a3, $s1
 
 jal moveposition
 move $s0, $v0
 move $s1, $v1
 # return loop
 j inputloop
 
 
left:
 # row stays the same
 move $a0, $s0
 move $a2, $s0
 
 # moving left: column - 1
 move $a1, $s1
 subi $a3, $s1, 1
 
 jal moveposition
 move $s0, $v0
 move $s1, $v1
 
 # return loop
 j inputloop
 
 
down:
 # moving down: row + 1
 move $a0, $s0
 addi $a2, $s0, 1
 
 # column stays the same
 move $a1, $s1
 move $a3, $s1
 
 jal moveposition
 move $s0, $v0
 move $s1, $v1
 
 # return loop
 j inputloop
 
 
right:
 # row stays the same
 move $a0, $s0
 move $a2, $s0
 
 # moving right: column + 1
 move $a1, $s1
 addi $a3, $s1, 1
 
 jal moveposition
 move $s0, $v0
 move $s1, $v1
 
 # return loop
 j inputloop


finish:
 # print victory message
 li $v0, 4
 la $a0, victoryMessage
 syscall
 j exit


exit:
 # syscall to end the program
 li $v0, 10    
 syscall
    
    
    
    
    
    
    
    
    
    
    
    
################################ FUNCTIONS #################################
printmaze:					#
	sw	$fp, 0($sp)			#
	move	$fp, $sp			#
	subu	$sp, $sp, 24			#
	sw	$ra, -4($fp)			#
	sw	$s0, -8($fp)			#
	sw	$s1, -12($fp)			#
	sw	$s2, -16($fp)			#
	sw	$s3, -20($fp)			#
					#
	#open file				#
	li $v0,13           			#
	la $a0,mazeFilename     	# open mazeFilename	#
	li $a1, 0           	# 0 = read		#
	li $a2, 0		# mode is ignored	#
	syscall				#
					#
	# move file desc into $s0			#
    	move $s0,$v0				#
					#
	# read file and put at buffer			#
	li $v0, 14				#
	move $a0,$s0				#
	la $a1,buffer				#
	la $a2,4096				#
	syscall				#
					#
########################### PRINT MAZE #####################################
					#
	# $s0 = file descriptor (to close after)		#
	li $s1, 0 	# row			#
	li $s2, 0	# col			#
	la $s3, buffer	# load entire maze into $s3		#
					#
	####################################		#
	# wwwwwwwwwwwwwwwwwwwwwwwwwwwwwwww #		#
	# wwwwwwwwwwwwwwwwwwwwwwwwwwwwwwww #		#
	# wwwwwwwwwwwwwwwwwwwwwwwwwwwwwwww #		#
	# wwwwwwwwwwwwwwwwwwwwwwwwwwwwwwww #		#
	# wwwwwwwupppwppppppppwppppwwwwwww #		#
	# wwwwwwwpwwpwpwwwwwwpwpwwpwwwwwww #		#
	# wwwwwwwpwppppppppppppppwpwwwwwww #		#
	# wwwwwwwpwpwwpwwppwwpwwpwpwwwwwww #		#
	# wwwwwwwppppppwppppwppppppwwwwwww #		#
	# wwwwwwwpwpwwpwwwwwwpwwpwpwwwwwww #		#
	# wwwwwwwpwppppppppppppppwpwwwwwww #		#
	# wwwwwwwpwwpwpwwwwwwpwpwwpwwwwwww #		#
	# wwwwwwwppppwpppsppppwppppwwwwwww #		#
	# wwwwwwwwwwwwwwwwwwwwwwwwwwwwwwww #		#
	# wwwwwwwwwwwwwwwwwwwwwwwwwwwwwwww #		#
	# wwwwwwwwwwwwwwwwwwwwwwwwwwwwwwww #		#
	####################################		#
					#
	mazeloop:				#
	lb $a0, ($s3)                	# single byte in $a0	#
	addi $s3, $s3, 1	# next byte		#
					#
	beq $a0, 119, wall #w			#
	beq $a0, 112, passage #p			#
	beq $a0, 115, player #s			#
	beq $a0, 117, exitt #u			#
	next:				#
					#
	beq $s2, 32, nextrow	# check if out of bounds	#
	addi $s2, $s2, 1 # if not out of bounds: col++ (0,1)->(0,2)	#
					#
	# check for last out of bounds pixel (15,32)		#
	#				#
	#	 ---------------		#
	#	 |	|		#
	#	 |	|		#
	#	 |    MAZE     |		#
	#	 |	|		#
	#	 |	|		#
	#	 ---------------[ ] <- (15,32)	#
					#
	beq $s1, 15, lastpixel			#
	j mazeloop #loop			#
					#
      ######## CHECK FOR NEXT ROW / CHECK FOR LAST PIXEL ##############	#
					#
	nextrow:		# col = 0, row ++	#
	li $s2, 0		# basically just go next row	#
	addi $s1, $s1, 1	# eg (0,32) = (1,0)	#
	j mazeloop #loop			#
					#
	lastpixel: # check for last out of bounds pixel (15,32)	#
	beq $s2, 32, endloop # if (15,32): endloop		#
	j mazeloop # if not out of bounds: resume loop	#
					#
      ################################################################	#
					#
	# change pixel to blue			#
	wall:				#
	move $a0, $s1				#
	move $a1, $s2				#
	jal changewall				#
	j next #resume loop			#
					#
	# change pixel to black			#
	passage:				#
	move $a0, $s1				#
	move $a1, $s2				#
	jal changepassage			#
	j next #resume loop			#
					#
	# change pixel to yellow			#
	player:				#
	move $a0, $s1				#
	move $a1, $s2				#
	jal changeplayer			#
	j next #resume loop			#
					#
	# change pixel to green			#
	exitt:				#
	move $a0, $s1				#
	move $a1, $s2				#
	jal changeexit				#
	j next #resume loop			#
					#
					#
endloop:					#
	# close file				#
    	li $v0, 16         			#
    	move $a0,$s0				#
    	syscall				#
					#
	lw	$s3, -20($fp)			#
	lw	$s2, -16($fp)			#
	lw	$s1, -12($fp)			#
	lw	$s0, -8($fp)			#
	lw	$ra, -4($fp)			#
	move	$sp, $fp			#
	lw	$fp, ($sp)			#
	jr	$ra			#
############################################################################
translatecoordinates: # translate (row,col) into corresponding $gp address	#
	sw	$fp, 0($sp)			#
	move	$fp, $sp			#
	subu	$sp, $sp, 16			#
	sw	$ra, -4($fp)			#
	sw	$s0, -8($fp)			#
	sw	$s1, -12($fp)			#
					#
	# a0: row				#
	# a1: col				#
	move $s0, $a0				#
	move $s1, $a1				#
					#
	move $t0 $gp				#
	 				#
	# 4 x amount of columns			#
	mul $t1 $s1 4	 			#
	add $t0 $t0 $t1			#
	 				#
	# 4 x 32 columns = 1 row			#
	mul $t1 $s0 128 			#
	add $t0 $t0 $t1			#
    					#
    	# $v0 = return				#
    	move $v0, $t0				#
					#
	lw	$s1, -12($fp)			#
	lw	$s0, -8($fp)			#
	lw	$ra, -4($fp)			#
	move	$sp, $fp			#
	lw	$fp, ($sp)			#
	jr	$ra			#
					#
############################################################################
changewall: # change (row,col) into blue 			#
	sw	$fp, 0($sp)			#
	move	$fp, $sp			#
	subu	$sp, $sp, 16			#
	sw	$ra, -4($fp)			#
	sw	$s0, -8($fp)			#
	sw	$s1, -12($fp)			#
					#
	move $s0, $a0				#
	move $s1, $a1				#
					#		
	jal translatecoordinates			#
	 				#
	# wallColor: 0x004286F4			#
	# Color used for walls (blue)			#
	lw $t0, wallColor			#
	sw $t0, ($v0)				#
					#
	lw	$s1, -12($fp)			#
	lw	$s0, -8($fp)			#
	lw	$ra, -4($fp)			#
	move	$sp, $fp			#
	lw	$fp, ($sp)			#
	jr	$ra			#
					#
############################################################################
changepassage: # change (row,col) into black			#
	sw	$fp, 0($sp)			#
	move	$fp, $sp			#
	subu	$sp, $sp, 16			#
	sw	$ra, -4($fp)			#
	sw	$s0, -8($fp)			#
	sw	$s1, -12($fp)			#
					#
	move $s0, $a0				#
	move $s1, $a1				#
					#
	jal translatecoordinates			#
	 				#
	# passageColor:0x00000000			#
	# Color used for passage (black)		#
	lw $t0, passageColor			#
	sw $t0, ($v0)				#
					#
	lw	$s1, -12($fp)			#
	lw	$s0, -8($fp)			#
	lw	$ra, -4($fp)			#
	move	$sp, $fp			#
	lw	$fp, ($sp)			#
	jr	$ra			#
############################################################################
changeplayer: # change (row,col) into yellow			#
	sw	$fp, 0($sp)			#
	move	$fp, $sp			#
	subu	$sp, $sp, 16			#
	sw	$ra, -4($fp)			#
	sw	$s0, -8($fp)			#
	sw	$s1, -12($fp)			#
					#
	move $s0, $a0				#
	move $s1, $a1				#
					#
	jal translatecoordinates			#
					#
	# playerColor: 0x00FFFF00			#
	# Color used for player (yellow)		#
	lw $t0, playerColor			#
	sw $t0, ($v0)				#
					#
	lw	$s1, -12($fp)			#
	lw	$s0, -8($fp)			#
	lw	$ra, -4($fp)			#
	move	$sp, $fp			#
	lw	$fp, ($sp)			#
	jr	$ra			#
############################################################################
changeexit: # change (row,col) into green			#
	sw	$fp, 0($sp)			#
	move	$fp, $sp			#
	subu	$sp, $sp, 16			#
	sw	$ra, -4($fp)			#
	sw	$s0, -8($fp)			#
	sw	$s1, -12($fp)			#
					#
	move $s0, $a0				#
	move $s1, $a1				#
					#
	jal translatecoordinates			#
					#
	# exitColor: 0x0000FF00			#
	# Color used for exit (green)			#
	lw $t0, exitColor			#
	sw $t0, ($v0)				#
					#
	lw	$s1, -12($fp)			#
	lw	$s0, -8($fp)			#
	lw	$ra, -4($fp)			#
	move	$sp, $fp			#
	lw	$fp, ($sp)			#
	jr	$ra			#
############################################################################
moveposition:					#
	sw	$fp, 0($sp)			#
	move	$fp, $sp			#
	subu	$sp, $sp, 24			#
	sw	$ra, -4($fp)			#
	sw	$s0, -8($fp)			#
	sw	$s1, -12($fp)			#
	sw	$s2, -16($fp)			#
	sw	$s3, -20($fp)			#
					#
	# (row,col) start pos			#
	move $s0, $a0				#
	move $s1, $a1				#
					#
	# (row,col) end pos			#
	move $s2, $a2				#
	move $s3, $a3				#
					#
################# ERROR CHECK ##########################		#
			          #		#
 # check if end position is out of bounds              #		#
 bgt $s2, 15, error		          #		#
 bgt $s2, 31, error		          #		#
			          #		#
 # translate coordinate into position relative to      #		#
 # total amount of characters 	          #		#
 # e.g. (1,0) = 33th character ( /n is 32nd character) #		#
 mul $t1, $s2, 33		          #		#
 add $t1, $t1, $s3		          #		#
			          #		#
 # store n-th character in $a0	          #		#
 la $t0, buffer		          #		#
 add $t0, $t0, $t1		          #		#
 lb $a0, ($t0)			          #		#
			          #		#
 # check if n-th character (end position) = 'w'        #		#
 # if wall end function		          #		#
 beq $a0, 119, error #w		          #		#
			          #		#
 # if not out of bounds and not wall:                  #		#
 # continue with the function	          	          #		#
 j noterror			          #		#
			          #		#
beq $v0, $s2, check_finish_position
j endmoveposition

check_finish_position:
beq $v1, $s3, finish
j endmoveposition


 error:			          #		#
 # return same position and end function	          #		#
 move $v0, $s0			          #		#
 move $v1, $s1			          #		#
 j endmoveposition		          #		#
			          #		#
########################################################		#
noterror:					#
					#
	# change player into passage			#
	move $a0, $s0				#
	move $a1, $s1				#
	jal changepassage			#
					#
	# change end position into player		#
	move $a0, $s2				#
	move $a1, $s3				#
	jal changeplayer			#
					#
	# return ($v0 = row, $v1 = col) of end position	#
	move $v0, $s2				#
	move $v1, $s3				#
					#
	endmoveposition:			#
	lw	$s3, -20($fp)			#
	lw	$s2, -16($fp)			#
	lw	$s1, -12($fp)			#
	lw	$s0, -8($fp)			#
	lw	$ra, -4($fp)			#
	move	$sp, $fp			#
	lw	$fp, ($sp)			#
	jr	$ra			#
	j exit
					#
############################################################################
