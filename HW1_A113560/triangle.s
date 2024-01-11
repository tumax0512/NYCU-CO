

.data
msg1: .asciiz "Please enter option (1: triangle, 2: inverted triangle):"
msg2: .asciiz "Please input a triangle size:"
space: .asciiz " "
newline: .asciiz "\n"
star: .asciiz "*"

.text

main:
	# user input
	li $v0, 4
	la $a0, msg1
	syscall
	li $v0, 5                # Read user input for option
    	syscall
    	move $t3, $v0            # Store option in $t3
    	
	li $v0, 4
	la $a0, msg2
	syscall
	li $v0, 5
	syscall
     
	move $s0, $v0 # height of pyramid
	move $s1, $v0
	addi $s1, $s1, -1 # number of spaces required before each line
	li $t0, 1
	li $t1, 0
	li $t4, 2         #t4初始為2
	mul $s0, $s0, $t4 
	addi $s0, $s0, -1 #s0=2*高度-1
	beq $t3, $t0, print_row
	bne $t3, $t0, invert_print_row
print_row:
		
	bgt $t0, $s0, exit	#大於2*高度-1就跳出
		# print spaces
	move $a1, $s1
	jal print_spaces
	addi $s1, $s1, -1
		# print stars
	move $a1, $t0
	jal print_stars
	addi $t0, $t0, 2
	j print_row

exit:  
	li $v0, 10
	syscall

print_stars:
	# print $a1 number of stars
	addi $sp, $sp, -12
	sw $ra, ($sp)
	sw $v0, 4($sp)
	sw $a0, 8($sp)
	li $v0, 4
	star_loop:
		beq $a1, $zero, return_stars
		la $a0, star
		syscall
		addi $a1, $a1, -1
		j star_loop
	return_stars: la $a0, newline
	syscall
	lw $ra, ($sp)
	lw $v0, 4($sp)
	lw $a0, 8($sp)
	addi $sp, $sp, 12
	jr $ra

print_spaces:
	# print $a1 number of spaces
	addi $sp, $sp, -12
	sw $ra, ($sp)
	sw $v0, 4($sp)
	sw $a0, 8($sp)
	li $v0, 4
	la $a0, space
	print_one_more:
		beq $a1, $zero, return_spaces
		syscall
		addi $a1, $a1, -1
		j print_one_more
	return_spaces: lw $ra, ($sp)
	lw $v0, 4($sp)
	lw $a0, 8($sp)
	addi $sp, $sp, 12
	jr $ra
	
invert_print_row:
		
	bgt $t0, $s0, exit	 #小於1就跳出
		# print spaces
	move $a1, $t1
	jal invert_print_spaces
	addi $t1, $t1, 1
		# print stars
	move $a1, $s0	
	jal invert_print_stars
	addi $s0, $s0, -2
	j invert_print_row

invert_print_spaces:
	# print $a1 number of spaces
	addi $sp, $sp, -12
	sw $ra, ($sp)
	sw $v0, 4($sp)
	sw $a0, 8($sp)
	li $v0, 4
	la $a0, space
	invert_print_one_more:
		beq $a1, $zero, invert_return_spaces
		syscall
		addi $a1, $a1, -1
		j invert_print_one_more
	invert_return_spaces: lw $ra, ($sp)
	lw $v0, 4($sp)
	lw $a0, 8($sp)
	addi $sp, $sp, 12
	jr $ra

invert_print_stars:
	# print $a1 number of stars
	addi $sp, $sp, -12
	sw $ra, ($sp)
	sw $v0, 4($sp)
	sw $a0, 8($sp)
	li $v0, 4
	invert_star_loop:
		beq $a1, $zero, invert_return_stars
		la $a0, star
		syscall
		addi $a1, $a1, -1
		j invert_star_loop
	invert_return_stars: la $a0, newline
	syscall
	lw $ra, ($sp)
	lw $v0, 4($sp)
	lw $a0, 8($sp)
	addi $sp, $sp, 12
	jr $ra
