	.data
	.align 2

init_msg:   .asciiz "\nProvide an integer for the Fibonacci computation:\n"
final_msg:  .asciiz "\nThe Fibonacci sequence is:\n"
comma:      .asciiz ","
error_msg:	.asciiz "\nInput error - must be a positive integer.\n"
new_line:   .asciiz "\n"
colon:      .asciiz ": "


    .text
main:
    li $t9, 4
    li $t8, 1

INPUT:
# Print message:
    la $a0, init_msg    # Load address of message into $a0
	li $v0, 4           # System call code 4: print string
    syscall
    
# Read input N:
    li $v0,5        # System call code 5: read integer
    syscall
    
# Validate input
    move $a0, $v0   # Move input N into argument $a0
    bgez $a0, SET_UP  # If input N > 0, then proceed to fibonacci

# If input is invalid
    la $a0, error_msg   # Load address of error message into $a0 to be printed
    li $v0, 4           # System call code 4: print string
    syscall
    
    j INPUT             # Ask for input again

SET_UP:
    li $a1, 0           # a1 = i
    addi $t0, $a0, 1    # n+1

    # Allocate heap space for memo:
    sll $a0, $t0, 2     # Calculate the amount of heap space needed (n+1)*4
    li $v0, 9           # System call code 9: allocate heap space
    syscall

    move $a2, $v0       # Move base address of memo on heap into parameter $a1

SEQ_LOOP:
    move $a3, $a1       # i
    beq $a1, $t0, exit  # when counter reaches n, exit
    
    # store state
    addi $sp, $sp, -4   # adjust stack
    sw $a1, 0($sp)      # store n on the stack
    
    move $a0, $a1       # print i
    li $v0, 1           # System call 1: print integer
    syscall
    
    la $a0, colon       # print :
    li $v0, 4           # System call 4: print string
    syscall
    
    # call fib subroutine
    jal fib             # Input is valid. Call fib subroutine
    # print return
    move $a0, $v0
    li $v0, 1           # System call 1: print integer
    syscall
    
    la $a0, new_line
    li $v0, 4
    syscall
    
    # preserve state
    lw $a1, 0($sp)
    addi $sp, $sp, 4
    
    addi $a1, $a1, 1    # i++
    
    j SEQ_LOOP

exit:
    li $v0, 10      # System call code 10: exit
    syscall

##
# Returns all fibonacci numbers from 0 to n
#
# @param $a1: user input n
# @param $a2: start address of array on heap
# @param $a3: copy of n
#
# @return $v0: fibonacci number
##
fib:
    addi $sp, $sp, -4
    sw $ra, 0($sp)

    blez $a1, ZERO      # if N <= 0, fib(0)=0, jump to ZERO
    beq $a1, $t8, FIB1  # else if N == 1, fib(1)=1, jump to FIB1
    
    sll $t1, $a1, 2     # n*4
	add $a2, $a2, $t1   # address of memo[n] = base address + offset
	lw $a0, 0($a2)      # load data at memo[n] address into $t3
	sub $a2, $a2, $t1
	
    bgtz $a0, FIB_MEMO  # if (memo[n] > 0) return memo[n]

CALC:
# Fib(N-1):
# calculate $a0 = N-1, then call Fib(N-1):
	addi $a1,$a1,-1
	jal fib
	move $t2, $v0       # Store result of fib(n-1)

## Enter Fib(N-2)
# calculate $a0 = N-2, then call Fib(N-2):
    addi $a1, $a1, -1   # PROBLEM HERE
	jal fib
	move $t3, $v0       # Store result of fib(n-2)

## operation: memo[n] = Fib(N-2)+Fib(N-1)
    add $t2, $t2, $t3   # fib(n-1) + fib(n-2)
    
    sll $t1, $a3, 2     # n*4
    add $a2, $a2, $t1   # address of memo[n]
    sw $t2, 0($a2)      # store resul in the memo array
    sub $a2, $a2, $t1   # Shift pointer back to starting position
    
    move $a0, $t2
    j FIB_MEMO

ZERO:
    lw $ra, 0($sp)
    addi $sp, $sp, 4
    
    li $v0, 0   # Return 0
    jr $ra

FIB1:
    lw $ra, 0($sp)
    addi $sp, $sp, 4

    li $v0, 1   # Return 1
    jr $ra

FIB_MEMO:
    lw $ra, 0($sp)
    addi $sp, $sp, 4

    move $v0, $a0  # Return data memo[n]
    jr $ra