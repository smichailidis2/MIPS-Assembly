#================================================== LAB 5 ==========================================================
#   REGISTER MAP
#
# $s0 <------ adress of g_tempByte
# $s1 <------ adress of tel_catalogue
# $s2 <------ structure pointer
#
#
#


#   NOTE: ENTRY NUMBER RANGE IS FROM 0 TO 9 AND NOT FROM 1 TO 10 (practically no difference)


.data

    # array of "bytes" used in word processing
    g_tempByte: .word 0 0 0 0

    # catalogue
    tel_catalogue:
    .space 600

    space_char: .asciiz " "

    prompt1: .asciiz "Please enter a name:\n"
    prompt2: .asciiz "\nEcho print:\n"
    prompt3: .asciiz "\nEcho print (Without <NEW LINE>):\n"

    op_entry_prompt: .asciiz "\nPlease determine operation, entry (E), inquiry (I) or quit (Q):\n"
    entry_number_prompt: .asciiz "\nPlease enter entry number:\n"
    last_name_prompt: .asciiz "\nPlease enter last name:\n"
    first_name_prompt: .asciiz "\nPlease enter first name:\n"
    phone_number_prompt: .asciiz "\nPlease enter phone number:\n"
    thankYou4entry_prompt: .asciiz "\nThank you, the new entry is the following:\n"
    retrieval_prompt: .asciiz "\nPlease enter the entry number you wish to retrieve:\n"
    entry_is_prompt: .asciiz "\nThe entry is:\n"

    error_msg_0: .asciiz "\nERROR: Invalid entry number, please try again...\n"
    error_msg_1: .asciiz "\nThere is no such entry in the phonebook\n"
    error_msg_2: .asciiz "\nThere is no such operation code. Please try again...\n"

    exit_msg: .asciiz "\nBye Bye..."


.text

################################################
#         main()                               #
################################################
main:

    jal initialize

    jal open_menu


j sys_exit
################################################
#        end of main()                         #
################################################


#-----------------------------------------------------------------------
# FUNCTION : initialize
# No Arguments
# No return values
# Return adress is stored in $ra (put there by jal instruction)
# FUNCTION OPERATION:
# Initialize $s0-$s2 registers ( "global" variables )
#----------------------------------------------------------------------- 
initialize:

    la $s0, g_tempByte
    la $s1, tel_catalogue

    # structure pointer (at first , points at the beggining of the catalogue)
    la $s2, tel_catalogue


jr $ra


#--------------
# SYSTEM EXIT
#--------------
sys_exit:

li $v0, 4           # print exit message
la $a0, exit_msg
syscall

li $v0, 10          # load system call code [10] --> EXIT
syscall             # Bye bye...
#---------------------------------------------------------

#-----------------------------------------------------------------------
# FUNCTION : bytes_to_word (int array_adress, int word_adress)
# Arguments stored in $a1, $a2
# no return values
# Return adress is stored in $ra (put there by jal instruction)
# TYPICAL FUNCTION OPERATION:
# 1) load 4 words stored in an array of adress $a1
# 2) parse all bytes into one word ( in adress $a0)
# 3) Return to previous location
#
# || FUNCTION REGISTER USAGE ||
#
# $t0-t4 ----> temporaries
#
# $a0 ---> arg 1
# $a1 ---> arg 2
#
#-------------------------------------------------------------------------
bytes_to_word:
    
    #store $ra in stack
    addi $sp, $sp, -4
    sw $ra, 0($sp)


    lw $t0, 0($a1)
    lw $t1, 4($a1)
    lw $t2, 8($a1)
    lw $t3, 12($a1)

    #parse last byte
    move $t4, $t3

    #parse third byte
    sll $t4, $t4, 8
    or $t4, $t4, $t2

    #parse second byte
    sll $t4, $t4, 8
    or $t4, $t4, $t1

    #parse first byte
    sll $t4, $t4, 8
    or $t4, $t4, $t0

    #store
    sw $t4, 0($a0)


    #restore stack
    lw $ra, 0($sp)
    addi $sp, $sp, 4


jr $ra

#-------------------------------------------------------------
# FUNCTION :  word_to_bytes()
# opossite of bytes_to_word()
# argument $a0 is the adress of word to be parsed to 4 bytes.
# argument $a1 is the adress of array of bytes
# Returns 0xFFFFFFFF (in $v0) if "\n" found ;
# returns 0x00000001 (in $v0) if "0" found
# Bytes stored in g_tempByte
#-------------------------------------------------------------
word_to_bytes:

    #save arguments in stack
    addi $sp, $sp, -12
    sw $a0, 0($sp)
    sw $a1, 4($sp)
    sw $ra, 8($sp)

    lw $t0, 0($a0)      #store value of WORD in $t0

    #=====START=====
    # get first byte:
    move $t1, $t0
    andi $t1, $t1, 0x000000FF
    sw $t1, 0($a1)

    # get second byte:
    move $t2, $t0
    srl $t2, $t2, 8
    andi $t2, $t2, 0x000000FF
    sw $t2, 4($a1)

    # get third byte:
    move $t3, $t0
    srl $t3, $t3, 16
    andi $t3, $t3, 0x000000FF
    sw $t3, 8($a1)

    # get fourth byte:
    move $t4, $t0
    srl $t4, $t4, 24
    andi $t4, $t4, 0x000000FF
    sw $t4, 12($a1)
    #=====END=====

    #CHECK FOR "\n" or "0"
    move $a0, $t1
    move $a1, $t2
    move $a2, $t3
    move $a3, $t4
    jal check_zero_newLine
    # $v0 changed in function check_zero_newLine

    move $v1, $v0

word_to_byte_exit:
    #restore stack
    lw $a0, 0($sp)
    lw $a1, 4($sp)
    lw $ra, 8($sp)
    addi $sp, $sp, 12


jr $ra








# ------------------------------------------------------------
# FUNCTION : check_zero_newLine()
# arguments $a0, $a1, $a2, $a3 are the bytes we want to check.
# returns 0xFFFFFFFF (in $v0) if "\n" found ;
# returns 0x00000001 (in $v0) if "0" found
# ------------------------------------------------------------
check_zero_newLine:
    
    li $v0, 0x0

    # first, check for  /n:
    # 0x0000000A --> (10)dec ascii code for <new line> character
    bne $a0, 0x0000000A, newLine_notfound
    li $v0, 0xFFFFFFFF
    j check_zero_newLine_exit

    newLine_notfound:
    bne $a1, 0x0000000A, newLine_notfound2
    li $v0, 0xFFFFFFFF
    j check_zero_newLine_exit

    newLine_notfound2:
    bne $a2, 0x0000000A, newLine_notfound3
    li $v0, 0xFFFFFFFF
    j check_zero_newLine_exit

    newLine_notfound3:
    bne $a3, 0x0000000A, newLine_notfound4
    li $v0, 0xFFFFFFFF
    j check_zero_newLine_exit

    newLine_notfound4:


   #check for  0:
    bne $a0, 0x0, zero_notfound0
    li $v0, 0x00000001
    j check_zero_newLine_exit

    zero_notfound0:
    bne $a1, 0x0, zero_notfound02
    li $v0, 0x00000001
    j check_zero_newLine_exit

    zero_notfound02:
    bne $a2, 0x0, zero_notfound03
    li $v0, 0x00000001
    j check_zero_newLine_exit

    zero_notfound03:
    bne $a3, 0x0, zero_notfound04
    li $v0, 0x00000001
    j check_zero_newLine_exit

    #continue
    zero_notfound04:

    check_zero_newLine_exit:

jr $ra





#-----------------------------------------------------------------------
# FUNCTION : remove_newLine (int String1)
# Arguments stored in $a0
# $a0 is the adress of buffer that contains <NEW LINE>
# return nothing
# Return adress is stored in $ra (put there by jal instruction)
# TYPICAL FUNCTION OPERATION:
# 1) access all words of buffer $a0 until \n found
# 2) all words are split into bytes
# 3) search byte by byte for <new line>
# 4) when <new line> is found, remove it
# 5) repackage bytes into word
# 6) store edited words into buffer
#
# || FUNCTION REGISTER USAGE ||
#
# $t0 ---> temp reg containing each byte to be asserted
#
# $v0 ---> out of word_to_bytes()
#
# $a0 --> arg 1 of this function && arg 1 of nested procedure: word_to_bytes
# $a1 --> arg 2 of nested procedure: word_to_bytes
#
#
#-------------------------------------------------------------------------
remove_newLine:

    #save return adress and $a0 in stack
    addi $sp, $sp, -8
    sw $ra, 0($sp)
    sw $a0, 4($sp)

    la $a1, g_tempByte

    loop_nl:
        # nested call of word_to_bytes with arguments $a0 & $a1

        jal word_to_bytes
        beq $v0, 0x00000000, next_word              # goto next word
        beq $v0, 0x00000001, remove_NL_exit         # 0 [string end] terminator found
        bne $v0, 0xFFFFFFFF, remove_NL_exit         # no <NEW LINE> found
    
        # check 4 bytes for new line and replace it with 0 terminator 
        lw $t0, 0($a1)
        beq $t0, '\n', replace_nl1

        lw $t0, 4($a1)
        beq $t0, '\n', replace_nl2

        lw $t0, 8($a1)
        beq $t0, '\n', replace_nl3

        lw $t0, 12($a1)
        beq $t0, '\n', replace_nl4


        next_word:
        addi $a0, $a0, 4        #next quad of bytes

    j loop_nl

    # FIRST byte is \n, replace it with zero;
    # then, repackage using bytes_to_word, inserting it into buffer
    replace_nl1:
    sw $zero, 0($a1)
    jal bytes_to_word
    j remove_NL_exit

    # SECOND byte is \n, replace it with zero;
    # then, repackage using bytes_to_word, inserting it into buffer
    replace_nl2:
    sw $zero, 4($a1)
    jal bytes_to_word
    j remove_NL_exit

    # THIRD byte is \n, replace it with zero;
    # then, repackage using bytes_to_word, inserting it into buffer
    replace_nl3:
    sw $zero, 8($a1)
    jal bytes_to_word
    j remove_NL_exit

    # FOURTH byte is \n, replace it with zero;
    # then, repackage using bytes_to_word, inserting it into buffer
    replace_nl4:
    sw $zero, 12($a1)
    jal bytes_to_word
    
    remove_NL_exit:
    #restore stack
    lw $a0, 4($sp)
    lw $ra, 0($sp)
    addi $sp, $sp, 8

jr $ra


# ----------------------------
# FNCTION: open_menu()
# no arguments and no return values
# TYPICAL FUNCTION OPERATION:
# get operation code by calling get_op_code() subroutine
# The op code has to be <E> , <I> or <Q> . NOT case sensitive!
# If it is <E> or <e> , execute new_entry() subroutine.
# If it is <I> or <i> , execute inquiry() subroutine.
# If it is <Q> or <q> , exit from this function.
# if it is none of the above , print error message and repeat until user inputs <Q>.
# || FUNCTION REGISTER USAGE ||
#
# $v0 ----> output of subroutine get_op_code() , also used for syscalls
#
# $a0 ---> adress of error prompt
#
# ----------------------------
open_menu:

    # init stack
    addi $sp, $sp, -4
    sw $ra, 0($sp)

    main_loop:

        jal get_op_code
        beq $v0, 'Q',menu_exit
        beq $v0, 'q',menu_exit

        beq $v0, 'E',menu_new_entry
        beq $v0, 'e',menu_new_entry

        beq $v0, 'I',menu_inquiry
        beq $v0, 'i',menu_inquiry

        # uknown operation code
        li $v0, 4               # syscall code [4] -> print string
        la $a0, error_msg_2     # laod adress of prompt to be printed
        syscall                 # print error prompt

    j main_loop

    menu_new_entry:
    jal new_entry
    j main_loop

    menu_inquiry:
    jal inquiry
    j main_loop

    menu_exit:
    # restore stack
    lw $ra, 0($sp)
    addi $sp, $sp, 4

jr $ra


#------------------------------
# GET OP CODE
# char read in  $v0
# return value: $v0
#------------------------------
get_op_code:

    li $v0, 4                   # system call code [4] -> print string
    la $a0, op_entry_prompt     # load adress of sprompt to be printed
    syscall                     # print

    li $v0, 12  # read char     # system call code [12] -> read character
    syscall                     # await char from std input, then store in $v0

jr $ra

# ------------------------------------------------
# FUNCTION: new_entry()
# no argments and no return values
# TYPICAL FUNCTION OPERATION:
# Handle a new entry in the catalogue:
# 1) Read entry number from std input
# 2) Entry number must be from 0 - 9 .
# 3) Check if its non-negative and not larger than 9.
# 4) If it is negative or larger than 9, print error msg and exit.
# 5) If it is compatible, proceed.
# 6) Pinpoint memory adress of wanted structure by calling procedure calc_struct_pointer()
# 7) Clear any previous data contained in said adress by calling procedure clear_struct()
# 8) Then execute the following, in order:
#     (i)   read last name
#     (ii)  read first name
#     (iii) read phone number
#   and remove any <new line> characters present in each case.
# 9) Lastly , print the entry using procedure print_entry().
#
# || FUNCTION REGISTER USAGE ||
#
# $v0 ----> entry number from std in , also used for syscalls
#
# $a0 ---> arg 1 for all nested procedure calls, also used as adress of error prompts
#
# $t7-t9 ---> temporaries, used in entry number range assertions
#
# ---------------------------------------------------
new_entry:

    # allocate stack 
    addi $sp, $sp, -4
    sw $ra, 0($sp)  # store return adress into stack


    li $v0, 4   # print entry number prompt
    la $a0, entry_number_prompt
    syscall

    # READ ENTRY NUMBER from std input, stored in $v0
    li $v0, 5   
    syscall

    beq $v0, $zero, continue_entry
    # if input number greater than 9 or less than 0, error msg
    li $t7, 10
    slt $t8, $zero, $v0     # if $v0 > 0  then $t9 = 1 ; if not, $t9 = 0
    slt $t9, $v0, $t7       # if $v0 < 10 then $t9 = 1 ; if not, $t9 = 0
    and $t9, $t9, $t8       # both statements above must be true in order to proceed normaly.
    beq $t9, $zero, error_occured_in_entry

    continue_entry:
    
    # NESTED CALL OF calc_struct_pointer
    move $a0, $v0
    jal calc_struct_pointer
    # now $s2 points to the beggining of the structure

    # NESTED CALL OF clear_struct
    move $a0, $s2
    jal clear_struct


    #-------------------------
    #---- read last name -----
    #-------------------------
    li $v0, 4       # print prompt
    la $a0, last_name_prompt
    syscall

    li $v0, 8       # syscall code for reading a string
    move $a0, $s2   # buffer
    li $a1, 20      # size (nax -> 20 characters)
    syscall

    # remove \n
    jal remove_newLine
    #-------------------------



    #-------------------------
    #---- read first name ----
    #-------------------------
    addi $s2, $s2, 20     # $s2 <--- next item pointer 

    li $v0, 4   # print prompt
    la $a0, first_name_prompt
    syscall

    li $v0, 8   # syscall code for reading a string
    move $a0, $s2   # buffer
    li $a1, 20      # size (nax -> 20 characters)
    syscall

    # remove \n
    jal remove_newLine
    #-------------------------



    #-------------------------------
    #---- read telephone number ----
    #-------------------------------
    addi $s2, $s2, 20     # $s2 <--- next item pointer 

    li $v0, 4   # print prompt
    la $a0, phone_number_prompt
    syscall

    li $v0, 8   # syscall code for reading a string
    move $a0, $s2   # buffer
    li $a1, 20      # size (nax -> 20 characters)
    syscall

    # remove \n
    jal remove_newLine
    #-------------------------------



    li $v0, 4   # print prompt
    la $a0, thankYou4entry_prompt
    syscall

    # NESTED CALL OF PRINT ENTRY
    addi $s2, $s2, -40  # first restore structure pointer
    move $a0, $s2
    jal print_entry
    j end_of_entry

    error_occured_in_entry:
    li $v0, 4   # print error_prompt
    la $a0, error_msg_0
    syscall
    end_of_entry:

    # restore stack
    lw $ra, 0($sp)
    addi $sp, $sp, 4

jr $ra

# ------------------------------------------------
# FUNCTION: inquiry ()
# no argments and no return values
# TYPICAL FUNCTION OPERATION:
# Handle an inquiry from the catalogue:
# 1) Read entry number from std input
# 2) Entry number must be from 0 - 9 .
# 3) Check if its non-negative and not larger than 9.
# 4) If it is negative or larger than 9, print error msg and exit.
# 5) If it is compatible, proceed.
# 6) Pinpoint memory adress of wanted structure by calling procedure calc_struct_pointer()
# 7) If the first word of said mem adress is 0, all 60 bytes will be 0 meaning it is empty.
# 8) If it is empty, print apropriate prompt.
# 9) If not empty, print the entry using procedure print_entry()
#
#
# || FUNCTION REGISTER USAGE ||
#
# $v0 ----> entry number from std in , also used for syscalls
#
# $a0 ---> arg 1 for all nested procedure calls, also used as adress of error prompts
#
# $t7-t9 ---> temporaries, used in entry number range assertions
# $t6 ---> temporary used for empty structure check
#
# ---------------------------------------------------
inquiry:

    # save $ra ina stack
    addi $sp, $sp, -4
    sw $ra, 0($sp)

    li $v0, 4   # print prompt
    la $a0, retrieval_prompt
    syscall

    li $v0, 5   # syscall code 5 --> read integer in $v0
    syscall

    beq $v0, $zero, continue_inq
    # # if input number greater than 9 or less than 0 print error msg and goto exit
    li $t7, 10
    slt $t8, $zero, $v0       # if $v0 > 0  then $t9 = 1 ; if not, $t9 = 0
    slt $t9, $v0, $t7         # if $v0 < 10 then $t9 = 1 ; if not, $t9 = 0
    and $t9, $t9, $t8         # both statements above must be true in order to proceed normaly.
    beq $t9, $zero, error_occured_in_inquiry 

    continue_inq:

    # calculate structure adress
    move $a0, $v0
    jal calc_struct_pointer

    # if first word of adress is 0, then structure is empty
    lw $t6, 0($s2)
    beq $t6, $zero, empty_struct
    # -------------------------------------------------------

    li $v0, 4   # print prompt
    la $a0, entry_is_prompt
    syscall

    # print structure
    move $a0, $s2
    jal print_entry
    j end_of_inq

    error_occured_in_inquiry:
    li $v0, 4   # print error_prompt
    la $a0, error_msg_0
    syscall
    j end_of_inq

    empty_struct:
    li $v0, 4   # print error_prompt
    la $a0, error_msg_1
    syscall

    end_of_inq:
    # restore stack
    lw $ra, 0($sp)
    addi $sp, $sp, 4

jr $ra

#----------------------------------------
# Calculate struct_pointer
# arg 1: entry_number in $a0
# no return value
# changes $s2 according to entry number.
#----------------------------------------
calc_struct_pointer:
    move $t0, $a0
    li $t1, 60

    #  $t2  <---- struct_offset = 60 * entry_number
    mul $t2, $t1, $t0

    add $s2, $s1, $t2

jr $ra



#-----------------------------------------------
# FUNCTION : print_entry()
# arg 1 : $a0 ,adress of structure to be printed
# no return value
# prints all elements of structure entry
#-----------------------------------------------
print_entry:

    # stack init
    addi $sp, $sp, -12
    sw $ra, 0($sp)
    sw $a0, 4($sp)
    
    move $t0, $a0

    # ---- Print entry number ----
    sw $t0, 8($sp)                 # first save temporary register $t0 in stack
    jal get_entry_num_from_addr    # nested call of get_entry_num_from_addr
    lw $t0, 8($sp)                 # restore $t0 from stack
    move $a0, $v0
    li $v0, 1       # system call code for printing integer value
    syscall
    # ----------------------------

    # SYSTEM CALL CODE FOR PRINTING STRING
    li $v0, 4

    # PRITN SPACE ======
    la $a0, space_char
    syscall
    # ==================

    # ***************
    # print last name
    # ***************
    move $a0, $t0
    syscall


    # PRITN SPACE ======
    la $a0, space_char
    syscall
    # ==================


    # ****************
    # print first name
    # ****************
    addi $t0, $t0, 20
    move $a0, $t0
    syscall


    # PRITN SPACE ======
    la $a0, space_char
    syscall
    # ==================


    # ***************
    # print number
    # ***************
    addi $t0, $t0, 20
    move $a0, $t0
    syscall



    # free stack
    lw $ra, 0($sp)
    lw $a0, 4($sp)
    addi $sp, $sp, 12

jr $ra


# ========================
# CLEAR STRUCTURE FUNCTION
# arg 1: adress $a0
# ========================
clear_struct:
    sw $zero, 0($a0)
    sw $zero, 4($a0)
    sw $zero, 8($a0)
    sw $zero, 16($a0)
    sw $zero, 20($a0)
    sw $zero, 24($a0)
    sw $zero, 28($a0)
    sw $zero, 32($a0)
    sw $zero, 36($a0)
    sw $zero, 40($a0)
    sw $zero, 44($a0)
    sw $zero, 48($a0)
    sw $zero, 52($a0)
    sw $zero, 56($a0)
jr $ra

# ----------------------------------------------
# FUNCTION : get_entry_num_from_addr(int adress)
# $a0 ---> arg 1
# $v0 ---> out 1
#   Returns entry number of given struct with
# adress $a0.
# ----------------------------------------------
get_entry_num_from_addr:

    # entry_num = ($a0 - $s1) / 60

    sub $v0, $a0, $s1

    li $t0, 60
    div $v0, $v0, $t0

jr $ra

