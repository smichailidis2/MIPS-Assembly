###DATA SEGMENT###
.data

enter_character: .asciiz "\nPlease Enter your character: \n"
string_is: .asciiz "\nThe string is "

buf_str: .space 100                 #Buffer string that saves all characters
out_str: .space 100                 #Output string that has replaces non-alphanumerics with space

###CODE SEGMENT###
.text


main: 

addi $t0, $0, 0                    #init temp value i used in loop1

loop1:
    li $v0, 4                      #Load system call code [4] (print a string)
    la $a0, enter_character        #Load adress of string
    syscall                        #print string

    li $v0, 12                     #Load system call code [12] (read character)
    syscall                        #read char (new char saved in $v0)

    beq $v0,'@',newline            #Check if char is @, jump to newline if true
    sb $v0, buf_str($t0)           #If not store char in the end of output string
    addi $t0,$t0,1                 #i++
    beq $t0,99,newline             #Loop condition i < 99 (maximum bytes of out_str)
    j loop1                        


newline:
    addi $t9, $0, 10               #10 ASCII code for <NEW LINE>
    sb $t9,buf_str($t0)            #store \n in the end of string


#Load adresses of both strings
la $s0, buf_str
la $s1, out_str

#Loop 2 filters input chars by comparing ASCII code values
loop2:
    addi $t9, $0, 10              #init terminating character

    lb $t1, 0($s0)                #load byte of buffer string
    addi $s0,$s0,1                #increase array iterator by 1
    
    beq $t1,$t9,exit              #If byte loaded is terminating character, goto exit

    beq $t1,' ',storebyte         #if loaded byte is <SP> goto storebyte

#condition 1 checks if byte is element of (47,58) (ASCII codes for <DECIMAL NUMBERS>)
condition1 :
    addi $t4,$0,58                #init ASCII code 58  
    slt $t2, $t1, $t4             #compare buffer byte to ASCII code 58 (buffer_byte < 58)
    bne $t2, $0, isNumber         #if true goto isNumber

#condition 2 checks if byte is element of (64,91) (ASCII codes for <CAPITAL LETTERS>)
condition2 :
    addi $t5,$0,91                #init ASCII code 91
    slt $t2, $t1, $t5             #compare buffer byte to ASCII code 91 (buffer_byte < 91)
    bne $t2, $0, isCapital        #if true goto isCapital

#condition 3 checks if byte is element of (96,123) (ASCII codes for <LOWERCASE LETTERS>)
condition3 :
    addi $t6,$0,123               #init ASCII code 123
    slt $t2, $t1, $t6             #compare buffer byte to ASCII code 123 (buffer_byte < 123)
    bne $t2, $0, isLowercase      #if true goto isLowercase


#no conditions met, goto start of loop 2
endCondition :
  
    j loop2
  

#if byte is number or letter, store it in out_str
storebyte:
    sb $t1, 0($s1)
    addi $s1,$s1,1
    j loop2


#checks for number
isNumber:
        addi $t7,$0, 47                 #48 ASCII code representing <0>
        slt $t3, $t7, $t1               #(buffer_byte > 47)
        bne $t3, $0, storebyte          #if true, goto storebyte

        j condition2                    #if false check next condition

#checks for capital letter
isCapital:
        addi $t7,$0, 64                 #65 ASCII code representing <A>
        slt $t3, $t7, $t1               #(buffer_byte > 64)
        bne $t3, $0, storebyte          #if true, goto storebyte

        j condition3                    #if false check next condition

#checks for lowercase letter
isLowercase:
        addi $t7,$0, 96                 #97 ASCII code representing <a>
        slt $t3, $t7, $t1               #(buffer_byte > 96)
        bne $t3, $0, storebyte          #if true, goto storebyte

        j endCondition                  #if false check next condition

    
#JUMP TO LABEL : exit 
#1) when user inputs termination character <@>
#2) when input characters reach max number of bytes of allocated space (100 bytes -> 99 bytes <input chars> + 1 byte <reserved for \n>)


exit:
    li $v0,4                       #Load system call code [4] (print a string)
    la $a0, string_is              #load adress of prompt
    syscall                        #print prompt

    li $v0,4                       #Load system call code [4] (print a string)
    la $a0, out_str                #load adress of output string
    syscall                        #print output string

    li $v0, 10                     #Load system call code [10] (EXIT)
    syscall                        #EXIT PROGRAM SUCCESSFULLY
