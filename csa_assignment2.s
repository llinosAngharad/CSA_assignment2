	.data
	.align 2

msg:    .asciiz "\nProvide an integer for the Fibonacci computation:\n"
comma:  .asciiz ","
error_msg:	.asciiz "\nInput error - must be a positive integer.\n"
	
    .text
main:
    li $t9, 4

INPUT:
# Print message:
    la $a0, msg     # Load address of message into $a0     
	li $v0, 4       # System call code 4: print string
    syscall			
# Read input N:
    li $v0,5        # System call code 5: read integer		 
    syscall
# Validate input
    move $a0, $v0   # Move input N into argument $a0
    bgtz $a0, JFIB  # If input N > 0, then proceed to fibonacci
# If input is invalid
    la $a0, error_msg   # Load address of error message into $a0 to be printed
    li $v0, 4           # System call code 4: print string
    syscall
    j INPUT             # Ask for input again

JFIB:
    addi $a1, $a0, 1    # n+1
    
    addi $sp, $sp, -4   # Adjust stack pointer
    sw $a0, 0($sp)      # Store input N on the stack
    
    jal make_heap       # Make array on the heap, returns base address of memo on heap
    
    lw $a0, 0($sp)      # Load input N from the heap into parameter $a0
    move $a1, $v0       # Move base address of memo on heap into parameter $a1
    mul $t1, $a0, $t9   # n*4
    add $a1, $a1, $t1   # Move address to end address of memo on heap
    jal fib             # Input is valid. Call fib subroutine
    
PRINT:
    move $a0, $v0
    li $v0, 1
    syscall
    
EXIT:
    li $v0, 10      # System call code 10: exit
    syscall

##
# Allocates space on the heap for the memo
#
# @param $a0: user input N
# @param $a1: N+1 i.e the amount of memo entries needed
#
# @return $v0: base address of memo on heap 
##
make_heap:
    # Allocate heap space for memo:
    li $v0, 9           # System call code 9: allocate heap space
    mul $a0, $a1, $t9   # Calculate the amount of heap space needed (n+1)*4
    syscall
    move $s1, $v0       # Save base address of heap memo
    jr $ra


##
# Returns all fibonacci numbers from 0 to n
#
# @param $a0: user input N
# @param $a1: end address of array on heap
#
# @return $v0: fibonacci number
##
fib:
    addi $sp, $sp, -12
    sw $ra, 8($sp)
    sw $a0, 4($sp)      # Parameter $a0
    sw $a1, 0($sp)      # Parameter $a1
    move $v0, $a0
    jr $ra