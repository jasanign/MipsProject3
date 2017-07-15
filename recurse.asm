#--------------------------------------------------------------------------- =80
# Author - Gajjan Jasani
# Date   - 04/05/2016

.data
newline	:    .asciiz "\n"		# newline character
promptOne	:    .asciiz "Enter operation: 0 or 1, 2 to End\n"
promptTwo	:    .asciiz "Enter any two positive integers\n"
answer	:    .asciiz "The answer is "
space  	:    .asciiz " "		# space character
temp	:    .word	1		# int temp = 1

.text
# Procedure : main
# Purpose   : Entry point of the program. Repeatedly Prompts user for 
#	  selecting operation, entering 2 integers, perform the   
#	  selected mystery operation on the entered integers. 
#	  Make the program quit when user enters 2.
# Registers : Use
# s0	: control
# s1	: choice (user selected operation)
# a0	: loading addresses for printing
# a1	: a (first int entered by user)
# a2	: b (second int entered by the user)
# s3	: reset temp back to 1
# v0	: syscalls

main:
    addi  $s0, $zero, 0		# control = 0

while:
    bne   $s0, $zero, exit_while	# goto exit if control != 0
    
    # Prompt for selecting operation
    li    $v0, 4
    la    $a0, promptOne 
    syscall
    # Read user input Integer
    li    $v0, 5
    syscall
    move  $s1, $v0    # s1 = choice = user selected operation
    
    #----------- first if statement -----------#
    bne   $s1, $zero, exit_if_1	# goto if_2 if choice != 0
    # Prompt for entering two integers
    li    $v0, 4
    la    $a0, promptTwo 
    syscall
    # Read user input Integer 1
    li    $v0, 5
    syscall
    move  $a1, $v0		# a1 = a = int 1
    # Read user input Integer 2
    li    $v0, 5
    syscall
    move  $a2, $v0		# a2 = b = int 2
    jal   start_mystery1	# jump and link to start_mystery1
    addi  $s3, $zero, 1		# s3 = 0 + 1 = 1
    sw    $s3, temp		# temp = s3 = 1
    #----------- end of first if statement ----#
    
exit_if_1:

    #----------- second if statement -----------#
    bne   $s1, 1, exit_if_2		# goto if_3 if choice != 1
    # Prompt for entering two integers
    li    $v0, 4
    la    $a0, promptTwo 
    syscall
    # Read user input Integer 1
    li    $v0, 5
    syscall
    move  $a1, $v0		# a1 = a = int 1
    # Read user input Integer 2
    li    $v0, 5
    syscall
    move  $a2, $v0		# a2 = b = int 2
    jal   start_mystery2	# jump and link to start_mystery2
    
    #----------- end of second if statement ----#
    
exit_if_2:
    #----------- third if statement -----------#
    bne   $s1, 2, exit_if_3	# if choice != 2 exit out of if 3
    addi  $s0, $zero, 1		# control = 0 + 1
    #----------- end of first if statement ----#
exit_if_3:
    j     while		# loopback when the end of loop is reached

exit_while:			
    #-------------- End The Program -------------#
    li   $v0, 10          
    syscall
#--------------------- End of Main Function --------------------------#

#--------------------- start_mystery1 function -----------------------#
# Procedure : start_mystery1
# Purpose   : perform mystery operation 1 on given two integers
# Register	: Use
# s1	: int l
# a0	: loading addresses for printing
# a1	: a (first int entered by user)
# a2	: b (second int entered by the user)
# v0	: syscalls and return value
# s7	: using as temp/holder
# sp	: stack pointer

start_mystery1:
    # Saveing registers on stack
    add   $sp, $sp, -20		# Decrement stack pointer by 20
    sw    $ra, 16($sp)		# Save $ra to stack
    sw    $a2, 12($sp)		# Save $a2 to stack
    sw    $a1, 8($sp)		# Save $a1 to stack
    sw    $s1, 4($sp)		# Save $s1 to stack
    sw    $s0, 0($sp)		# Save $s0 to stack
    # ---------- Entering the if/else statement ---------#
    sgt   $s7, $a1, $a2		# s7 = 1 if a1 > a2
    bne   $s7, 1, mys1_else	# goto else if s7 != 1
    				# (if a1 <= a2)
    jal   mystery1		# jump and link to mystery1
    move  $s1, $v0		# l = return value of mystery1
    j     exit_mys1_if_else	# exit out of if else statement
mys1_else:
    # swap a and b
    move  $s7, $a1
    move  $a1, $a2
    move  $a2, $s7
    jal   mystery1		# jump and link to mystery1
    move  $s1, $v0		# l = return value of mystery1
    j     exit_mys1_if_else	# exit out of if else statement
    # ----------- Exiting the if/else statement ----------#
exit_mys1_if_else:
    # Printing the answer
    li    $v0, 4
    la    $a0, answer 
    syscall
    li    $v0, 1
    add   $a0, $s1, $zero
    syscall
    li    $v0, 4
    la    $a0, newline 
    syscall
    
    # Restoring registers from stack before exiting the procedure
    lw    $s0, 0($sp)		# Restore value of $s0 from stack
    lw    $s1, 4($sp)		# Restore value of $s1 from stack
    lw    $a1, 8($sp)		# Restore value of $a1 from stack
    lw    $a2, 12($sp)		# Restore value of $a2 from stack
    lw    $ra, 16($sp)		# Restore value of $ra from stack
    addi  $sp, $sp, 20		# Increment stack pointer by 20
    
    li    $v0, 0		# return 0
    jr    $ra		# returning the control back to caller
    
#--------------------- End of start_mystery1 function ---------------------#


#--------------------- mystery1 function -----------------------#
# Procedure : mystery1 (Helper procedure for start_mystery1)
# Purpose   : perform mystery operation 1 on given two integers
# Register	: Use
# s1	: int temp
# a0	: loading addresses for printing
# a1	: a (first int entered by user)
# a2	: b (second int entered by the user)
# v0	: syscalls and return value
# s6	: hold remainder of temp / b
# s7	: hold remainder of temp / a
# sp	: stack pointer

mystery1:
    # Saveing registers on stack 
    add   $sp, $sp, -8		# Decrement stack pointer by 8
    sw    $ra, 4($sp)		# Save $ra to stack
    sw    $s1, 0($sp)		# Save $s1 to stack
    
    lw    $s1, temp		# load the value of temp 1 into s1
    #------------ Enterning the if statement ------------#
    div   $s1, $a2		# temp / b
    mfhi  $s6			# s6 = temp % b
    bne   $s6, 0, exit_mys1_if	# exit if statement if s6 != 0
    div   $s1, $a1		# temp / a
    mfhi  $s7			# s7 = temp % a
    bne   $s7, 0, exit_mys1_if	# exit if statement if s7 != 0
    move  $v0, $s1		# return temp
    
    # Restoring registers from stack before exiting the procedure
    lw    $s1, 0($sp)		# Restore value of $s1 from stack
    lw    $ra, 4($sp)		# Restore value of $ra from stack	
    addi  $sp, $sp, 8		# Increment stack pointer by 8
    jr    $ra		# Return control back to the caller
    #---------------- End of IF statement -----------------#     
exit_mys1_if:
    addi  $s1, $s1, 1		# temp++
    sw    $s1, temp		# update value of temp
    move  $v0, $s1		# return temp
    jal   mystery1		# recursing back to mystery(a,b)
    # Restoring registers from stack before exiting the procedure
    lw    $s1, 0($sp)		# Restore value of $s1 from stack
    lw    $ra, 4($sp)		# Restore value of $ra from stack	
    addi  $sp, $sp, 8		# Increment stack pointer by 8
    jr    $ra		# Return control back to the caller
#--------------------- End of mystery1 function -----------------------#


#--------------------- start_mystery2 function -----------------------#
# Procedure : start_mystery2
# Purpose   : perform mystery operation 2 on given two integers
# Register	: Use
# s1	: int l
# a0	: loading addresses for printing
# a1	: a (first int entered by user)
# a2	: b (second int entered by the user)
# v0	: syscalls and return value
# sp	: stack pointer

start_mystery2:

    # Saveing registers on stack
    add   $sp, $sp, -20		# Decrement stack pointer by 20
    sw    $ra, 16($sp)		# Save $ra to stack
    sw    $a2, 12($sp)		# Save $a2 to stack
    sw    $a1, 8($sp)		# Save $a1 to stack
    sw    $s1, 4($sp)		# Save $s1 to stack
    sw    $s0, 0($sp)		# Save $s0 to stack
    
    jal   mystery2		# jump and link to mystery2
    move  $s1, $v0		# l = return value of mystery2

    # Printing the answer
    li    $v0, 4
    la    $a0, answer 
    syscall
    li    $v0, 1
    add   $a0, $s1, $zero
    syscall
    li    $v0, 4
    la    $a0, newline 
    syscall
    
    # Restoring registers from stack before exiting the procedure
    lw    $s0, 0($sp)		# Restore value of $s0 from stack
    lw    $s1, 4($sp)		# Restore value of $s1 from stack
    lw    $a1, 8($sp)		# Restore value of $a1 from stack
    lw    $a2, 12($sp)		# Restore value of $a2 from stack
    lw    $ra, 16($sp)		# Restore value of $ra from stack
    addi  $sp, $sp, 20		# Increment stack pointer by 20
    
    move  $v0, $s1		# return value = value of l
    jr    $ra		# returning the control back to caller
    
#--------------------- End of start_mystery2 function -----------------------#


#--------------------------- mystery2 function -----------------------------#
# Procedure : mystery2 (Helper procedure for start_mystery2)
# Purpose   : perform mystery operation 2 on given two integers
# Register	: Use
# a0	: loading addresses for printing
# a1	: a (first int entered by user)
# a2	: b (second int entered by the user)
# v0	: syscalls and return value
# s7	: using as temp/holder
# sp	: stack pointer

mystery2:
    # Saveing registers on stack
    add   $sp, $sp, -12		# Decrement stack pointer by 12
    sw    $ra, 8($sp)		# Save $ra to stack
    sw    $s1, 4($sp)		# Save $s1 to stack
    sw    $s0, 0($sp)		# Save $s0 to stack

mys2_while:
    beq   $a1, $a2, exit_mys2_while
    # ---------- Entering the if/else statement ---------#
    sgt   $s7, $a1, $a2		# s7 = 1 if a1 > a2
    bne   $s7, 1, mys2_else	# goto else if s7 != 1
    			# (if a1 <= a2)
    sub   $a1, $a1, $a2		# a = a-b
    jal   mystery2		# jump and link to mystery1
    move  $v0, $a1		# return value = a1
    
    # Restoring registers from stack before exiting the procedure
    lw    $s0, 0($sp)		# Restore value of $s0 from stack
    lw    $s1, 4($sp)		# Restore value of $s1 from stack
    lw    $ra, 8($sp)		# Restore value of $ra from stack
    addi  $sp, $sp, 12		# Increment stack pointer by 12
    
    jr    $ra		# exit out of if else statement
mys2_else:
    sub   $a2, $a2, $a1		# b = b-a
    jal   mystery2		# jump and link to mystery1
    move  $v0, $a1		# return value = a1
    
    # Restoring registers from stack before exiting the procedure
    lw    $s0, 0($sp)		# Restore value of $s0 from stack
    lw    $s1, 4($sp)		# Restore value of $s1 from stack
    lw    $ra, 8($sp)		# Restore value of $ra from stack
    addi  $sp, $sp, 12		# Increment stack pointer by 12
    
    jr    $ra		# exit out of if else statement
    # ----------- Exiting the if/else statement ----------#
exit_mys2_if_else:
    j     mys2_while		# loopback to while
    
exit_mys2_while:

    # Restoring registers from stack before exiting the procedure
    lw    $s0, 0($sp)		# Restore value of $s0 from stack
    lw    $s1, 4($sp)		# Restore value of $s1 from stack
    lw    $ra, 8($sp)		# Restore value of $ra from stack
    addi  $sp, $sp, 12		# Increment stack pointer by 12
    
    move  $v0, $a1		# return a1
    jr    $ra		# returning the control back to caller

#----------------------- End of mystery2 function --------------------------#
