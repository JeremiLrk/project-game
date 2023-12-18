 .globl main

.data
mazeFilename:    .asciiz "/home/jeremi/Desktop/MIPS GAME/input_1.txt"   #Hier moet path naar de input file zich bevinden
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
    jal mazeprinter      # Roept de functie aan om het doolhof in te laden en te printen.
    jal findPositions    # Zoekt de start- en eindpositie in het doolhof.
    move $s0, $s4        # Stelt de startpositie van de speler in.
    move $s1, $s5        # Stelt de startpositie van de speler in.
    move $s2, $s6        # Stelt de eindpositie in het doolhof in.
    move $s3, $s7        # Stelt de eindpositie in het doolhof in.

gameplay:
    li $v0, 12           # Systeemaanroep voor het lezen van een teken.
    syscall
    move $t0, $v0
    
    # Hieronder volgen de instructies voor de verschillende bewegingen.
    li $t1, 122          # ASCII voor 'z'.
    beq $t0, $t1, up
    li $t1, 113          # ASCII voor 'q'.
    beq $t0, $t1, left
    li $t1, 115          # ASCII voor 's'.
    beq $t0, $t1, down
    li $t1, 100          # ASCII voor 'd'.
    beq $t0, $t1, right
    li $t1, 120          # ASCII voor 'x'.
    beq $t0, $t1, exit
    j gameplay

exit:
    li $v0, 10           # Syscall om het programma te beëindigen.
    syscall

# Hieronder volgen de functiedefinities voor het vinden van posities, inlezen van het doolhof, 
# kleuren toewijzen en de bewegingslogica.




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
    	# Stack frame opzetten
    	subu $sp, $sp, 32     # Reserveer ruimte op de stack voor opgeslagen registers en lokale variabelen
    	sw $ra, 28($sp)       # Sla het return address op
    	sw $fp, 24($sp)       # Sla het frame pointer op
    	sw $s0, 20($sp)       # Sla $s0 op (voor file descriptor)
    	sw $s1, 16($sp)       # Sla $s1 op (voor rij-index)

    	# Bestand openen met het doolhof
    	li $v0, 13            # Systeemaanroep code voor openen bestand
    	la $a0, mazeFilename  # Pad naar het doolhofbestand
    	li $a1, 0             
    	li $a2, 0             
    	syscall               # Voer systeemaanroep uit
    	move $s0, $v0         # Bewaar file descriptor in $s0
	
    	# Bestand lezen
    	li $v0, 14            # Systeemaanroep code voor lezen bestand
    	move $a0, $s0         # File descriptor
    	la $a1, buffer        # Locatie om gelezen data op te slaan
    	li $a2, 4096          # Aantal bytes om te lezen
    	syscall               # Voer systeemaanroep uit

    	# Initialisatie van rij- en kolomtellers
    	li $s1, 0             # Rij-index
    	li $s2, 0             # Kolom-index
    	la $s3, buffer        # Pointer naar het begin van de buffer

	Colorpicker:
    	# Lees een karakter uit de buffer en bepaal het type
    	lb $a0, ($s3)         # Load een byte (karakter) uit de buffer
    	addi $s3, $s3, 1      # buffer pointer hoger
    	beq $a0, 119, wall    # Ga naar 'wall' als het karakter 'w' is (ASCII 119)
    	beq $a0, 112, passage # Ga naar 'passage' als het karakter 'p' is (ASCII 112)
    	beq $a0, 115, playerposition # Ga naar 'playerposition' als het 's' is
    	beq $a0, 117, ending  # Ga naar 'ending' als het 'u' is

	volgendepixel:
    	# Volgende pixel in dezelfde rij
    	beq $s2, 32, volgenderij # Ga naar volgende rij als einde rij bereikt
    	addi $s2, $s2, 1      # Verhoog kolomteller
    	beq $s1, 15, laatste  # Controleer of dit de laatste rij is
    	j Colorpicker         # Herhaal voor de volgende pixel

	volgenderij:
    	# Ga naar de volgende rij
    	li $s2, 0             # Reset kolomteller
    	addi $s1, $s1, 1      # Verhoog rijteller
    	j Colorpicker         # Herhaal voor de volgende pixel

	laatste:
    	# Controleer of de laatste rij is bereikt
    	beq $s2, 32, printmaze_end # Eindig als alle pixels verwerkt zijn
    	j Colorpicker         # Herhaal voor de volgende pixel

	# Hieronder volgen de functies 'wall', 'passage', 'playerposition', 'ending'
	# Elke functie verwerkt een type 'tegeltje' in het doolhof

	wall:
    	#een muur ('w') in het doolhof
    	move $a0, $s1         # Zet de rijpositie van de muur
    	move $a1, $s2         # Zet de kolompositie van de muur
    	jal wallkleur         # Roep de functie aan die de kleur van de muur instelt
    	j volgendepixel       # Ga naar de volgende pixel voor verdere verwerking

	passage:
    	#een doorgang ('p') in het doolhof
    	move $a0, $s1         # Zet de rijpositie van de doorgang
    	move $a1, $s2         # Zet de kolompositie van de doorgang
    	jal passagekleur      # Roep de functie aan die de kleur van de doorgang instelt
    	j volgendepixel       # Ga naar de volgende pixel voor verdere verwerking

	playerposition:
    	#de player ('s') in het doolhof
    	move $a0, $s1         # Zet de rijpositie van de speler
    	move $a1, $s2         # Zet de kolompositie van de speler
    	jal playerpositionkleur # Roep de functie aan die de kleur van de spelerpositie instelt
    	j volgendepixel       # Ga naar de volgende pixel voor verdere verwerking

	ending:
	#het einde ('u') van het doolhof
    	move $a0, $s1         # Zet de rijpositie van het einde
    	move $a1, $s2         # Zet de kolompositie van het einde
    	jal endingkleur       # Roep de functie aan die de kleur van het einde instelt
    	j volgendepixel       # Ga naar de volgende pixel voor verdere verwerking


	printmaze_end:
    	# Sluit het bestand en herstel het stack frame
    	li $v0, 16            # Systeemaanroep code voor het sluiten van een bestand
    	move $a0, $s0         # File descriptor
    	syscall               # Voer systeemaanroep uit

    	# Herstel de originele waarden van geregistreerde registers
    	lw $s1, 16($sp)
    	lw $s0, 20($sp)
    	lw $fp, 24($sp)
    	lw $ra, 28($sp)
    	addu $sp, $sp, 32     # Geef de gereserveerde stack ruimte vrij
    	jr $ra
	

	translate_coordinates:
	subu $sp, $sp, 32
    	sw $ra, 28($sp)
    	sw $fp, 24($sp)
    	sw $s0, 20($sp)
    	sw $s1, 16($sp)

    	# Bewaar de argumenten in s0 en s1
    	move $s0, $a0
    	move $s1, $a1

    	# Roep bereken_adres aan
    	jal bereken_adres

    	# Herstel de originele waarden van s0 en s1
    	lw $s1, 16($sp)
    	lw $s0, 20($sp)

    	# Herstel het frame pointer en return address
    	lw $fp, 24($sp)
    	lw $ra, 28($sp)
    	addu $sp, $sp, 32
    	jr $ra

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
    	# Verwerk de muurkleur.
    	subu $sp, $sp, 32     # Maak ruimte op de stack voor opgeslagen registers.
    	sw $ra, 28($sp)       # Bewaar het return address.
    	sw $fp, 24($sp)       # Bewaar het frame pointer.
    	sw $s0, 20($sp)       # Bewaar s0.
    	sw $s1, 16($sp)       # Bewaar s1.
    	move $s0, $a1         # Zet kolom in s0.
    	move $s1, $a0         # Zet rij in s1.
    	jal translate_coordinates # Roep functie aan om pixeladres te berekenen.
    	lw $t4, wallColor     # Laad de muurkleur.
    	sw $t4, ($v0)         # Stel de kleur in op het berekende adres.
    	# Herstel de oorspronkelijke waarden van de registers en keer terug.
    	lw $s1, 16($sp)
    	lw $s0, 20($sp)
    	lw $fp, 24($sp)
    	lw $ra, 28($sp)
    	addu $sp, $sp, 32
    	jr $ra

	passagekleur:
    	# Verwerk de passagekleur.
    	subu $sp, $sp, 32     # Maak ruimte op de stack voor opgeslagen registers.
    	sw $ra, 28($sp)       # Bewaar het return address.
    	sw $fp, 24($sp)       # Bewaar het frame pointer.
    	sw $s0, 20($sp)       # Bewaar s0.
    	sw $s1, 16($sp)       # Bewaar s1.
    	move $s0, $a1         # Zet kolom in s0.
    	move $s1, $a0         # Zet rij in s1.
    	jal translate_coordinates # Roep functie aan om pixeladres te berekenen.
    	lw $t4, passageColor  # Laad de passagekleur.
    	sw $t4, ($v0)         # Stel de kleur in op het berekende adres.
    	# Herstel de oorspronkelijke waarden van de registers en keer terug.
    	lw $s1, 16($sp)
    	lw $s0, 20($sp)
    	lw $fp, 24($sp)
    	lw $ra, 28($sp)
    	addu $sp, $sp, 32
    	jr $ra

	playerpositionkleur:
    	# Verwerk de kleur van de spelerpositie.
    	subu $sp, $sp, 32     # Maak ruimte op de stack voor opgeslagen registers.
    	sw $ra, 28($sp)       # Bewaar het return address.
    	sw $fp, 24($sp)       # Bewaar het frame pointer.
    	sw $s0, 20($sp)       # Bewaar s0.
    	sw $s1, 16($sp)       # Bewaar s1.
    	move $s0, $a1         # Zet kolom in s0.
    	move $s1, $a0         # Zet rij in s1.
    	jal translate_coordinates # Roep functie aan om pixeladres te berekenen.
    	lw $t4, playerColor   # Laad de spelerkleur.
    	sw $t4, ($v0)         # Stel de kleur in op het berekende adres.
    	# Herstel de oorspronkelijke waarden van de registers en keer terug.
    	lw $s1, 16($sp)
    	lw $s0, 20($sp)
    	lw $fp, 24($sp)
    	lw $ra, 28($sp)
    	addu $sp, $sp, 32
    	jr $ra

	endingkleur:
    	# Verwerk de kleur van het einde van het doolhof.
    	subu $sp, $sp, 32     # Maak ruimte op de stack voor opgeslagen registers.
    	sw $ra, 28($sp)       # Bewaar het return address.
    	sw $fp, 24($sp)       # Bewaar het frame pointer.
    	sw $s0, 20($sp)       # Bewaar s0.
    	sw $s1, 16($sp)       # Bewaar s1.
    	move $s0, $a1         # Zet kolom in s0.
    	move $s1, $a0         # Zet rij in s1.
    	jal translate_coordinates # Roep functie aan om pixeladres te berekenen.
    	lw $t4, exitColor     # Laad de kleur van het einde.
    	sw $t4, ($v0)         # Stel de kleur in op het berekende adres.
    	# Herstel de oorspronkelijke waarden van de registers en keer terug.
    	lw $s1, 16($sp)
    	lw $s0, 20($sp)
    	lw $fp, 24($sp)
    	lw $ra, 28($sp)
    	addu $sp, $sp, 32
    	jr $ra


#DE FUNCTIES VOOR DE BEWEGINGEN DIE MOETEN UITGEVOERD KUNNEN WORDEN
	up:
    	# Verplaats de speler één rij omhoog in het doolhof. 
    	subi $a2, $s0, 1       # Bereken de nieuwe rijpositie (huidige rij - 1).
    	move $a0, $s0          # Stel de huidige rij in als de startpositie voor de beweging.
    	move $a1, $s1          # Stel de huidige kolom in als de startkolom.
    	move $a3, $s1          # De kolompositie verandert niet, dus blijft hetzelfde.
    	jal updateplayerposition # Roep de functie aan om de speler te verplaatsen naar de nieuwe positie.
    	move $s0, $v0          # Update de rijpositie van de speler met de nieuwe waarde.
    	move $s1, $v1          # Update de kolompositie van de speler (blijft hetzelfde).
    	beq $s0, $s2, checkColumn # Controleer of de speler de eindpositie bereikt heeft.
    	j gameplay            # Ga terug naar de hoofdgameplay-lus.

	down:
    	# Verplaats de speler één rij omlaag in het doolhof.
    	addi $a2, $s0, 1       # Bereken de nieuwe rijpositie (huidige rij + 1).
    	move $a0, $s0          # Stel de huidige rij in als de startpositie voor de beweging.
    	move $a1, $s1          # Stel de huidige kolom in als de startkolom.
    	move $a3, $s1          # De kolompositie verandert niet, dus blijft hetzelfde.
    	jal updateplayerposition # Roep de functie aan om de speler te verplaatsen naar de nieuwe positie.
    	move $s0, $v0          # Update de rijpositie van de speler met de nieuwe waarde.
    	move $s1, $v1          # Update de kolompositie van de speler (blijft hetzelfde).
    	beq $s0, $s2, checkColumn # Controleer of de speler de eindpositie bereikt heeft.
    	j gameplay            # Ga terug naar de hoofdgameplay-lus.

	left:
    	# Verplaats de speler één kolom naar links in het doolhof.
    	subi $a3, $s1, 1       # Bereken de nieuwe kolompositie (huidige kolom - 1).
    	move $a0, $s0          # Stel de huidige rij in als de startrij voor de beweging.
    	move $a2, $s0          # De rijpositie verandert niet, dus blijft hetzelfde.
    	move $a1, $s1          # Stel de huidige kolom in als de startkolom voor de beweging.
    	jal updateplayerposition # Roep de functie aan om de speler te verplaatsen naar de nieuwe positie.
    	move $s0, $v0          # Update de rijpositie van de speler (blijft hetzelfde).
    	move $s1, $v1          # Update de kolompositie van de speler met de nieuwe waarde.
    	beq $s0, $s2, checkColumn # Controleer of de speler de eindpositie bereikt heeft.
    	j gameplay            # Ga terug naar de hoofdgameplay-lus.

	right:
    	# Verplaats de speler één kolom naar rechts in het doolhof.
    	addi $a3, $s1, 1       # Bereken de nieuwe kolompositie (huidige kolom + 1).
    	move $a0, $s0          # Stel de huidige rij in als de startrij voor de beweging.
    	move $a2, $s0          # De rijpositie verandert niet, dus blijft hetzelfde.
    	move $a1, $s1          # Stel de huidige kolom in als de startkolom voor de beweging.
    	jal updateplayerposition # Roep de functie aan om de speler te verplaatsen naar de nieuwe positie.
    	move $s0, $v0          # Update de rijpositie van de speler (blijft het


#DIT ZIJN DE FUNCTIES DIE WE GENRUIKEN OM DE SPELER VAN PLAATS TE WISSELEN
	updateplayerposition:
    	# Reserveer ruimte voor de opgeslagen registers
    	subu $sp, $sp, 32
    	sw $ra, 28($sp)
    	sw $fp, 24($sp)
    	sw $s0, 20($sp)
    	sw $s1, 16($sp)
    	sw $s2, 12($sp)
    	sw $s3, 8($sp)


    	#Zet de beginwaarden en eindwaarden in $a0 - $a3 (zoals gevraagd in opgave)
    	move $s0, $a0  # Huidige rijpositie van de speler
    	move $s1, $a1  # Huidige kolompositie van de speler
    	move $s2, $a2  # Nieuwe rijpositie na beweging
    	move $s3, $a3  # Nieuwe kolompositie na beweging

    	bgt $s2, 15, invalidMove  # Controleer of de nieuwe rij buiten het doolhof valt
    	bgt $s3, 31, invalidMove  # Controleer of de nieuwe kolom buiten het doolhof valt
    	mul $t1, $s2, 33          # Bereken positie in de buffer
    	add $t1, $t1, $s3
    	la $t0, buffer
    	add $t0, $t0, $t1
    	lb $a0, ($t0)             # Laad karakter op nieuwe positie
    	beq $a0, 119, invalidMove # Controleer of het een muur is (ASCII waarde van 'w')

    	j validMove               # Ga naar validMove als beweging geldig is

	invalidMove:
    	# Als de beweging ongeldig is, behoud de huidige positie
    	move $v0, $s0
    	move $v1, $s1
    	j returnFromFunction

	validMove:
    	# Als de beweging geldig is, verwerk deze
    	move $a0, $s0
    	move $a1, $s1
    	jal passagekleur          # Verander de oude positie naar een passage
	
    	move $a0, $s2
    	move $a1, $s3
    	jal playerpositionkleur   # Verander de nieuwe positie naar de speler

    	move $v0, $s2
    	move $v1, $s3

	returnFromFunction:
    	# Herstel de oorspronkelijke waarden van de registers en keer terug
    	lw $s3, 8($sp)
    	lw $s2, 12($sp)
    	lw $s1, 16($sp)
    	lw $s0, 20($sp)
    	lw $fp, 24($sp)
    	lw $ra, 28($sp)
    	addu $sp, $sp, 32
    	jr $ra

    	
#DIT IS DE FUNCTIE DIE WE GEBRUIKEN OM TE CONTROLEREN OF WE HET EINDPUNT HEBBEN BEREIKT
	checkColumn:
	beq $s1, $s3, exit
	j gameplay
