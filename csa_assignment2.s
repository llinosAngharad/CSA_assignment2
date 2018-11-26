	.data
	.align 2

init_msg:   .asciiz "\nProvide an integer for the Fibonacci computation:\n"
final_msg:  .asciiz "\nThe Fibonacci numbers are:\n"
comma:      .asciiz ","
error_msg:	.asciiz "\nInput error - must be a positive integer.\n"

    .text
main:
    li $t9, 4
    li $t8, 1

INPUT:
# Print message:
    la $a0, init_msg     # Load address of message into $a0
	li $v0, 4       # System call code 4: print string
    syscall
# Read input N:
    li $v0,5        # System call code 5: read integer
    syscall
# Validate input
    move $a0, $v0   # Move input N into argument $a0
    bgez $a0, JFIB  # If input N > 0, then proceed to fibonacci
# If input is invalid
    la $a0, error_msg   # Load address of error message into $a0 to be printed
    li $v0, 4           # System call code 4: print string
    syscall
    j INPUT             # Ask for input again

JFIB:
    addi $sp, $sp, -4   # Adjust stack pointer
    sw $a0, 0($sp)      # Store input N on the stack
    addi $a1, $a0, 1    # n+1

    # Allocate heap space for memo:
    li $v0, 9           # System call code 9: allocate heap space
    sll $a0, $a1, 2     # Calculate the amount of heap space needed (n+1)*4
    syscall

    lw $a1, 0($sp)      # Load input n from the heap into parameter $a0
    addi $sp, $sp, 4    # Restore stack pointer
    
    move $a2, $v0       # Move base address of memo on heap into parameter $a1
    move $a3, $a1       # copy of n

    jal fib             # Input is valid. Call fib subroutine

PRINT_MSG:
    move $t0, $v0
    la $a0, final_msg   # Load address of final message into $a0 to be printed
    li $v0, 4           # System call code 4: print string
    syscall

PRINT_FIB:
    move $a0, $t0   # Load integer returned from fib into $a0 to be printed
    li $v0, 1       # Print integer
    syscall

#     add $t3, $zero, $s5     # N
#     lw $a0, ($a1)           # base address of heap
    
#  PRINT_HEAP:
#     # n -> -1
#     bltz $t3, EXIT
    
#     li $v0, 1
#     syscall
    
#     addi $t3, $t3, -1
#     addi $a1,$a1, 4
#     lw $a0, ($a1)
#     j PRINT_HEAP

EXIT:
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