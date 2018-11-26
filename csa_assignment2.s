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
    
# Read input n:
    li $v0,5        # System call code 5: read integer
    syscall
    
# Validate input
    move $a0, $v0       # Move input n into argument $a0
    bgez $a0, SET_UP    # If input n > 0, then proceed to setup

# If input is invalid
    la $a0, error_msg   # Load address of error message into $a0 to be printed
    li $v0, 4           # System call code 4: print string
    syscall
    
    j INPUT             # Ask for input again

SET_UP:
    li $a1, 0           # $a1: i
    addi $t0, $a0, 1    # work out n+1

    # Allocate heap space for memo:
    sll $a0, $t0, 2     # Calculate the amount of heap space needed (n+1)*4
    li $v0, 9           # System call code 9: allocate heap space
    syscall

    move $a2, $v0       # Move base address of memo on heap into parameter $a2
    
    la $a0, final_msg   # Load address of message into $a0
	li $v0, 4           # System call code 4: print string
    syscall

SEQ_LOOP:
    move $a3, $a1       # i
    beq $a1, $t0, EXIT  # When counter reaches input, exit
    
    # Store state
    addi $sp, $sp, -4   # Adjust stack
    sw $a1, 0($sp)      # Store n on the stack
    
    move $a0, $a1       # Move i into $a0 to print i
    li $v0, 1           # System call 1: print integer
    syscall
    
    la $a0, colon       # Move colon into $a0 to print :
    li $v0, 4           # System call 4: print string
    syscall
    
    jal fib         # Call fib subroutine
    
    move $a0, $v0   # Move the return of fib intro $a0 to be printed
    li $v0, 1       # System call 1: print integer
    syscall
    
    la $a0, new_line    # Move new_line into $a0 to be printed
    li $v0, 4           # System call 4: print string
    syscall
    
    # Preserve state
    lw $a1, 0($sp)      # Load i from the stack
    addi $sp, $sp, 4    # Adjust stack pointer
    
    addi $a1, $a1, 1    # i++
    
    j SEQ_LOOP          # Loop back

EXIT:
    li $v0, 10      # System call code 10: exit
    syscall

##
# Fibonacci method with time complexity O(n)
#
# @param $a1: user input n
# @param $a2: start address of array on heap
# @param $a3: copy of n
#
# @return $v0: fibonacci number
##
fib:
    addi $sp, $sp, -4   # Adjust stack pointer
    sw $ra, 0($sp)      # Store return address on the stack

    blez $a1, ZERO      # If N <= 0, jump to ZERO
    beq $a1, $t8, FIB1  # Else if N == 1, jump to FIB1
    
    sll $t1, $a1, 2     # Calculate offset = n*4
	add $a2, $a2, $t1   # Address of memo[n] = base address + offset
	lw $a0, 0($a2)      # Load data at address of memo[n] into $t3
	sub $a2, $a2, $t1   # Move address back to base address
	
    bgtz $a0, FIB_MEMO  # If (memo[n] > 0) return memo[n]

CALC:
# Fib(n-1):
	addi $a1,$a1,-1     # $a1 = n-1
	jal fib             # Call fib(n-1)
	move $t2, $v0       # Store result of fib(n-1) in $t2

# Fib(n-2):
    addi $a1, $a1, -1   # $a1 = n-2
	jal fib             # Call fib(n-2)
	move $t3, $v0       # Store result of fib(n-2) in $t3

# Calculate memo[n] = fib(n-1) + fib(n-2)
    add $t2, $t2, $t3   # fib(n-1) + fib(n-2)
    
    sll $t1, $a3, 2     # Calculate offset = n*4
    add $a2, $a2, $t1   # Address of memo[n] = base address + offset
    sw $t2, 0($a2)      # Store overall result in memo[n]
    sub $a2, $a2, $t1   # Shift address back to starting position
    
    move $a0, $t2       # Store overall result in $a0
    j FIB_MEMO      

ZERO:
    lw $ra, 0($sp)      # Load return address
    addi $sp, $sp, 4    # Adjust stack pointer
    
    li $v0, 0   # Return 0
    jr $ra

FIB1:
    lw $ra, 0($sp)      # Load return address
    addi $sp, $sp, 4    # Adjust stack pointer

    li $v0, 1   # Return 1
    jr $ra

FIB_MEMO:
    lw $ra, 0($sp)      # Load return address
    addi $sp, $sp, 4    # Adjust stack pointer

    move $v0, $a0  # Return data contained in memo[n]
    jr $ra