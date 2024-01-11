.data

string1: .asciiz "Please enter option (1: add, 2: sub, 3: mul): "
string2: .asciiz "Please enter the first number: "
string3: .asciiz "Please enter the second number: "
res: .asciiz "The calculation result is: "


.text
main:

	li $v0,4
	la $a0,string1
	syscall
	
	li $v0,5
	syscall
	move $t0,$v0
	
	li $v0,4
	la $a0,string2
	syscall
	
	li $v0,5
	syscall
	move $t1,$v0
	
	li $v0,4
	la $a0,string3
	syscall

	li $v0,5
	syscall
	move $t2,$v0
	
	beq $t0,1,Addition
	beq $t0,2,Subtraction
	beq $t0,3,Multplication
		
	
Addition:

	li $v0, 4
	la $a0, res
	syscall
	
	add $t3,$t1,$t2
	move $a0,$t3
	
	li $v0,1
	syscall
	j Exit
	
Subtraction:

	li $v0, 4
	la $a0, res
	syscall
			
	sub $t3,$t1,$t2
	move $a0,$t3
	
	li $v0,1
	syscall
	j Exit	

	
Multplication:

	li $v0, 4
	la $a0, res
	syscall
	
	mul $t3,$t1,$t2
	move $a0,$t3
	
	li $v0,1
	syscall
	j Exit	



Exit:

	li $v0,10
	syscall
	