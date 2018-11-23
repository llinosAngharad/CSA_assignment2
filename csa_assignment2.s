	.data
	.align 2

msg:    .asciiz "\nProvide an integer for the Fibonacci computation:\n"
comma:  .asciiz ","
error_msg:	.asciiz "\nInput error - must be a positive integer.\n"
	
    .text
main:

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
    jal make_heap       # make array on the heap, returns end address of array on heap    
    move $a1, $v0       # move end address of array on heap into parameter $a1
    jal fib     # Input is valid. Call fib subroutine
    
PRINT:
    move $a0, $v0
    li $v0, 1
    syscall
    
EXIT:
    li $v0, 10      # System call code 10: exit
    syscall

make_heap:
    
    jr $ra

fib:
    addi $sp, $sp, -8
    sw $ra, 0($sp)
    sw $a0, 4($sp)
    move $v0, $a0
    jr $ra