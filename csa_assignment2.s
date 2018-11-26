	.data
	.align 2

init_msg:   .asciiz "\nProvide an integer for the Fibonacci computation:\n"
final_msg:  .asciiz "\nThe Fibonacci numbers are:\n"
comma:      .asciiz ","
error_msg:	.asciiz "\nInput error - must be a positive integer.\n"

    .text
main:
    li $t9, 4
    li $t8, 0
    li $t7, 1

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

    move $a1, $v0       # Move base address of memo on heap into parameter $a1
    lw $a0, 0($sp)      # Load input N from the heap into parameter $a0
    addi $sp, $sp, 4    # Restore stack pointer

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
# @param $a0: user input N
# @param $a1: start address of array on heap
#
# @return $v0: fibonacci number
##
fib:
    addi $sp, $sp, -4
    sw $ra, 0($sp)

    beq $a0, $0, ZERO   # if N == 0, fib(0)=0, jump to ZERO
    beq $a0, $t7, FIB1  # else if N == 1, fib(1)=1, jump to FIB1
    
    move $t1, $a1       # Move base address of memo array into temporary $t1
    sll $t2, $a0, 2     # n*4
	add $t1, $t1, $t2   # address of memo[n] = base address + offset
	
	lw $t3, 0($t1)      # load data at memo[n] address into $t3
    bgtz $t3, FIB_MEMO  # if (memo[n] > 0) return memo[n]

CALC:
    addi $sp, $sp, -4
    sw $ra, 0($sp)

    jal REC
    
    lw $ra, 0($sp)
    addi $sp, $sp, 4
    
    move $t1, $a1       # Move base address of memo array into temporary $t1
    sll $t2, $a0, 2     # n*4
	add $t1, $t1, $t2   # address of memo[n]
    
    sw $v0, 0($t1)      # store result of REC in the memo array
    jr $ra

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

    move $v0, $t3  # Return data memo[n]
    jr $ra

REC:
# Fib(N-1):
# store state:
	addi $sp,$sp,-12
	sw $ra,8($sp)
	sw $a0,4($sp)
	sw $a1,0($sp)

# calculate $a0 = N-1, then call Fib(N-1):
	addi $a0,$a0,-1
	jal fib

# preserve state
	lw $ra,8($sp)
	lw $a0,4($sp)
	lw $a1,0($sp)
	addi $sp,$sp,12

## Enter Fib(N-2)
# store state
    addi $sp,$sp,-16
    sw $ra, 12($sp)
    sw $a0, 8($sp)
    sw $a1, 4($sp)
	sw $v0, 0($sp) # Store value of fib(n-1) on the stack

# calculate $a0 = N-2, then call Fib(N-2):
	addi $a0,$a0,-2
	jal fib

# preserve state: Fib(N-1)
    lw $ra,12($sp)
	lw $a0,8($sp)
	lw $a1,4($sp)
    lw $v1,0($sp)
    addi $sp,$sp,16


## operation: memo[n] = Fib(N-2)+Fib(N-1)
    add $t5, $v0, $v1
    move $v0,$t5
	jr $ra