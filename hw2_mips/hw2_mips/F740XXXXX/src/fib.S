main:
    addi $a0, $zero, 10# n = 10
    jal fib          # call fib(10)
    j exit

fib:
	beq $a0, 1, L1
	beq $a0, 0, L0
	
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	
	addi $a0, $a0, -1
	jal fib
	
	add $a0, $a0, 1
	lw $ra, 0($sp)
	#addi $sp, $sp, 4

	#addi $sp, $sp, -4
	sw $v0, 0($sp)

	addi $sp, $sp, -4
	sw $ra, 0($sp)

	addi $a0, $a0, -2
	jal fib
	
	addi $a0, $a0, 2
	lw $ra, 0($sp)
	addi $sp, $sp, 4

	lw $s0, 0($sp)
	addi $sp, $sp, 4

	add $v0,$v0,$s0
	jr $ra
	
  L1:addi  $v0, $zero, 1
    jr $ra
  L0:addi  $v0, $zero, 0
    jr $ra

exit:
