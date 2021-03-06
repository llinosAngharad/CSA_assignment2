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
    bgtz $a0, JFIB  # If input N > 0, then proceed to fibonacci
# If input is invalid
    la $a0, error_msg   # Load address of error message into $a0 to be printed
    li $v0, 4           # System call code 4: print string
    syscall
    j INPUT             # Ask for input again

JFIB:
    addi $sp, $sp, -4   # Adjust stack pointer
    sw $a0, 0($sp)      # Store input N on the stack
    addi $a1, $a0, 1    # n+1
    
    jal make_heap       # Make array on the heap, returns base address of memo on heap
    
    move $a1, $v0       # Move base address of memo on heap into parameter $a1
    move $s1, $v0
    lw $a0, 0($sp)      # Load input N from the heap into parameter $a0
    addi $sp, $sp, 4    # Restore stack pointer
    
    mul $t1, $a0, $t9   # N*4 = number of elements in memo
    add $a1, $a1, $t1   # Move address to end address of memo on heap
    jal fib             # Input is valid. Call fib subroutine
  
PRINT_MSG:
    move $t0, $v0
    la $a0, final_msg   # Load address of final message into $a0 to be printed
    li $v0, 4           # System call code 4: print string
    syscall

# print_fib_sequence:
#     lb $a0, 0($s1)
#     li $v0, 1       # Print integer
#     syscall
    
#     lb $a0, 4($s1)
#     li $v0, 1       # Print integer
#     syscall
    
#     lb $a0, 8($s1)
#     li $v0, 1       # Print integer
#     syscall 

PRINT_FIB:
    move $a0, $t0   # Load integer returned from fib into $a0 to be printed
    li $v0, 1       # Print integer
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
    addi $sp, $sp, -4
    sw $a0, 0($sp)      # Store user input N on the heap
    
    # Allocate heap space for memo:
    li $v0, 9           # System call code 9: allocate heap space
    mul $a0, $a1, $t9   # Calculate the amount of heap space needed (n+1)*4
    syscall
    
    move $s1, $v0       # Save base address of heap memo
    move $t1, $v0       # Put base address of heap memo into temporary $t1
    lw $a0, 0($sp)      # Load input N into temporary $t2
    addi $sp, $sp, 4    # Restore stack pointer

MAKE_HEAP_EXIT:
    jr $ra


##
# Returns all fibonacci numbers from 0 to n
#
# @param $a0: user input N
# @param $a1: end address of array on heap i.e address of memo[n]
#
# @return $v0: fibonacci number
##
fib:
    addi $sp, $sp, -12
    sw $ra, 0($sp)      # Store return address on the stack
    sw $a0, 4($sp)      # Store user input N
    sw $s0, 8($sp)      # 
    
    beq $a0, $0, ZERO   # If N==0, jump to ZERO
    li $t0, 0
    slti $t0, $a0, 2    # Shift by N*4
    beq $t0, $t7, FIB1  # If N==1, jump to FIB1
    
    sll $t0, $s0, 2     # Convert n to offset
    add $t0, $t0, $a1   # Add offset to base address
    lw $v0, 0($t0)      
    bne $v0, $0, MEMO
    
    addi $a0, $a0, -1
    jal fib
    
    move $s0, $v0
    lw $a0, 4($sp)
    addi $a0, $a0, -2
    jal fib
    add $v0, $v0, $s0
    
    lw $a0, 4($sp)
    sll $t0, $a0, 2
    add $t0, $t0, $a1
    sw $v0, 0($t0)
    
    lw $s0, 8($sp)
    lw $ra, 0($sp)
    addi $sp, $sp, 12
    jr $ra

ZERO:
    lw $s0, 8($sp)
    lw $ra, 0($sp)
    addi $sp, $sp, 12
    li $v0, 0
    jr $ra

FIB1:
    lw $s0, 8($sp)
    lw $ra, 0($sp)
    addi $sp, $sp, 12
    li $v0, 1
    jr $ra

MEMO:
    lw $s0, 8($sp)
    lw $ra, 0($sp)
    addi $sp, $sp, 12
    jr $ra

    
