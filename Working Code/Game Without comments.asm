 .globl main

.data
mazeFilename:    .asciiz "C:/Users/Jeremi/Downloads/test/input_1.txt"
buffer:          .space 4096
victoryMessage:  .asciiz "You have won the game!"

amountOfRows:    .word 16  # The mount of rows of pixels
amountOfColumns: .word 32  # The mount of columns of pixels

wallColor:      .word 0x004286F4    # Color used for walls (blue)
passageColor:   .word 0x00000000    # Color used for passages (black)
playerColor:    .word 0x00FFFF00    # Color used for player (yellow)
exitColor:      .word 0x0000FF00    # Color used for exit (green)

.text

main:

jal mazeprinter

jal findPositions

move $s0, $s4  # Start rijpositie van de speler
move $s1, $s5  # Start kolompositie van de speler

move $s2, $s6  # Start rijpositie van de speler
move $s3, $s7  # Start eindpositie van de speler

gameplay:
li $v0, 12    # Systeemaanroep voor het lezen van een teken
syscall
move $t0, $v0
    
li $t1, 122 # ASCII voor 'z'
beq $t0, $t1, up
li $t1, 113 # ASCII voor 'q'
beq $t0, $t1, left
li $t1, 115 # ASCII voor 's'
beq $t0, $t1, down
li $t1, 100 # ASCII voor 'd'
beq $t0, $t1, right
li $t1, 120 # ASCII voor 'x'
beq $t0, $t1, exit
j gameplay


exit:
    # syscall to end the program
    li $v0, 10    
    syscall




#FUNCTIES

#HIERMEE VINDEN WE HET STARTPUNT EN HET EINDPUNT IN ONS DOOLHOF
	findPositions:
	li $s1, 0  # Rijteller
	li $s2, 0  # Kolomteller
	la $s3, buffer  # Begin van de buffer
	findLoop:
	lb $t0, 0($s3)  # Huidig karakter
	addi $s3, $s3, 1
	# Check voor einde van de buffer
	beqz $t0, endFindLoop
	# Check voor nieuwe regel
	li $t1, 10  # ASCII voor '\n'
	beq $t0, $t1, nextRow
	# Check voor startpositie 's'
	li $t1, 's'
	beq $t0, $t1, foundStart
	# Check voor eindpositie 'u'
	li $t1, 'u'
	beq $t0, $t1, foundEnd
	addi $s2, $s2, 1  # Verhoog kolomteller
	j findLoop
	nextRow:
	addi $s1, $s1, 1  # Verhoog rijteller
	li $s2, 0  # Reset kolomteller
	j findLoop
	foundStart:
	move $s4, $s1  # Sla start rij op
	move $s5, $s2  # Sla start kolom op
	j findLoop
	foundEnd:
	move $s6, $s1  # Sla eind rij op
	move $s7, $s2  # Sla eind kolom op
	j findLoop
	endFindLoop:
	jr $ra  # Terug naar hoofdfunctie



#HIERMEE LEZEN WE HET DOOLHOF IN
	mazeprinter:
	sw $fp, 0($sp)
	move $fp, $sp
	subu $sp, $sp, 24
	sw $ra, -4($fp)
	sw $s0, -8($fp)
	sw $s1, -12($fp)
	sw $s2, -16($fp)
	sw $s3, -20($fp)
	li $v0, 13
	la $a0, mazeFilename
	li $a1, 0
	li $a2, 0
	syscall
	move $s0, $v0
	li $v0, 14
	move $a0, $s0
	la $a1, buffer
	li $a2, 4096
	syscall
	li $s1, 0
	li $s2, 0
	la $s3, buffer

	Colorpicker:
	lb $a0, ($s3)			
	addi $s3, $s3, 1
	beq $a0, 119, wall
	beq $a0, 112, passage
	beq $a0, 115, playerposition
	beq $a0, 117, ending

	volgendepixel:
	beq $s2, 32, volgenderij
	addi $s2, $s2, 1
	beq $s1, 15, laatste
	j Colorpicker 

	volgenderij:
	li $s2, 0
	addi $s1, $s1, 1
	j Colorpicker

	laatste:
	beq $s2, 32, printmaze_end
	j Colorpicker

	wall:
	move $a0, $s1
	move $a1, $s2
	jal wallkleur
	j volgendepixel

	passage:
	move $a0, $s1
	move $a1, $s2
	jal passagekleur
	j volgendepixel

	playerposition:
	move $a0, $s1
	move $a1, $s2
	jal playerpositionkleur	
	j volgendepixel

	ending:
	move $a0, $s1
	move $a1, $s2				
	jal endingkleur			
	j volgendepixel

	printmaze_end:
	li $v0, 16
	move $a0,$s0
	syscall
	lw	$s3, -20($fp)
	lw	$s2, -16($fp)
	lw	$s1, -12($fp)
	lw	$s0, -8($fp)
	lw	$ra, -4($fp)
	move 	$sp, $fp
	lw	$fp, ($sp)
	jr	$ra	

	translate_coordinates:
	sw $fp, 0($sp)      
	move $fp, $sp         
	subu $sp, $sp, 16     
	sw $ra, -4($fp)     
	sw $s0, -8($fp)     
	sw $s1, -12($fp)    

	move $a0, $a0
	move $a1, $a1

	jal  bereken_adres

	lw   $s1, -12($fp)    
	lw   $s0, -8($fp)     
	lw   $ra, -4($fp)     
	move $sp, $fp         
	lw   $fp, ($sp)       
	jr   $ra

	bereken_adres:
	move $s0, $a0
	move $s1, $a1
	move $t0, $gp
	mul $t1, $s1, 4
	add $t0, $t0, $t1
	mul $t1, $s0, 128
	add $t0, $t0, $t1
	move $v0, $t0
	jr $ra

	wallkleur:
	sw $fp, 0($sp)
	move $fp, $sp
	subu $sp, $sp, 16
	sw $ra, -4($fp)
	sw $s0, -8($fp)
	sw $s1, -12($fp)
	move $s0, $a1
	move $s1, $a0
	jal translate_coordinates
	lw $t4, wallColor
	sw $t4, ($v0)
	lw $s1, -12($fp)
	lw $s0, -8($fp)
	lw $ra, -4($fp)
	move $sp, $fp
	lw $fp, ($sp)
	jr $ra

	passagekleur:
	sw $fp, 0($sp)
	move $fp, $sp
	subu $sp, $sp, 16
	sw $ra, -4($fp)
	sw $s0, -8($fp)
	sw $s1, -12($fp)
	move $s0, $a1
	move $s1, $a0
	jal translate_coordinates
	lw $t4, passageColor
	sw $t4, ($v0)
	lw $s1, -12($fp)
	lw $s0, -8($fp)
	lw $ra, -4($fp)
	move $sp, $fp
	lw $fp, ($sp)
	jr $ra

	playerpositionkleur:
	sw $fp, 0($sp)
	move $fp, $sp
	subu $sp, $sp, 16
	sw $ra, -4($fp)
	sw $s0, -8($fp)
	sw $s1, -12($fp)
	move $s0, $a1
	move $s1, $a0
	jal translate_coordinates
	lw $t4, playerColor
	sw $t4, ($v0)
	lw $s1, -12($fp)
	lw $s0, -8($fp)
	lw $ra, -4($fp)
	move $sp, $fp
	lw $fp, ($sp)
	jr $ra

	endingkleur:
	sw $fp, 0($sp)
	move $fp, $sp
	subu $sp, $sp, 16
	sw $ra, -4($fp)
	sw $s0, -8($fp)
	sw $s1, -12($fp)
	move $s0, $a1
	move $s1, $a0
	jal translate_coordinates
	lw $t4, exitColor
	sw $t4, ($v0)
	lw $s1, -12($fp)
	lw $s0, -8($fp)
	lw $ra, -4($fp)
	move $sp, $fp
	lw $fp, ($sp)
	jr $ra

#DE FUNCTIES VOOR DE BEWEGINGEN DIE MOETEN UITGEVOERD KUNNEN WORDEN
	up:
	move $a0, $s0
	subi $a2, $s0, 1
	move $a1, $s1
	move $a3, $s1
	jal updateplayerposition
	move $s0, $v0
	move $s1, $v1
	beq $s0, $s2, checkColumn
	j gameplay

	down:
	move $a0, $s0
	addi $a2, $s0, 1
	move $a1, $s1
	move $a3, $s1
	jal updateplayerposition
	move $s0, $v0
	move $s1, $v1
	beq $s0, $s2, checkColumn
	j gameplay

	left:
	move $a0, $s0
	move $a2, $s0 
	move $a1, $s1
	subi $a3, $s1, 1
	jal updateplayerposition
	move $s0, $v0
	move $s1, $v1
	beq $s0, $s2, checkColumn
	j gameplay

	right:
	move $a0, $s0
	move $a2, $s0
	move $a1, $s1
	addi $a3, $s1, 1
	jal updateplayerposition
	move $s0, $v0
	move $s1, $v1
	beq $s1, $s3, exit
	j gameplay

#DIT ZIJN DE FUNCTIES DIE WE GENRUIKEN OM DE SPELER VAN PLAATS TE WISSELEN
	updateplayerposition:
	sw	$fp, 0($sp)
	move	$fp, $sp
	subu	$sp, $sp, 24
	sw	$ra, -4($fp)
	sw	$s0, -8($fp)
	sw	$s1, -12($fp)
	sw	$s2, -16($fp)
	sw	$s3, -20($fp)
	move $s0, $a0				#Zet de beginwaarden en eindwaarden in $a0 - $a3 (zoals gevraagd in opgave)
	move $s1, $a1
	move $s2, $a2
	move $s3, $a3            
    
    bgt $s2, 15, invalidMove     
    bgt $s3, 31, invalidMove     
    mul $t1, $s2, 33           
    add $t1, $t1, $s3           
    la $t0, buffer             
    add $t0, $t0, $t1           
    lb $a0, ($t0)               
    beq $a0, 119, invalidMove #w

    j validMove                 
    
	invalidMove:                   
    move $v0, $s0              
    move $v1, $s1              
    j returnFromFunction       
    
	validMove:                    
    move $a0, $s0              
    move $a1, $s1              
    jal passagekleur          
    
    move $a0, $s2              
    move $a1, $s3              
    jal playerpositionkleur           
    
    move $v0, $s2              
    move $v1, $s3              
    
	returnFromFunction:            
    lw    $s3, -20($fp)        
    lw    $s2, -16($fp)        
    lw    $s1, -12($fp)
    lw    $s0, -8($fp)         
    lw    $ra, -4($fp)         
    move  $sp, $fp            
    lw    $fp, ($sp)           
    jr    $ra 

#DIT IS DE FUNCTIE DIE WE GEBRUIKEN OM TE CONTROLEREN OF WE HET EINDPUNT HEBBEN BEREIKT
	checkColumn:
	beq $s1, $s3, exit
	j gameplay
