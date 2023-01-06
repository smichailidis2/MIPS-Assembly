.data     ## Data declaration
out_string1: .asciiz "\nProccesed string \n" ## String to be printed
out_string2: .asciiz "\nPlease Enter a Char\n" ## String to be printed

teststring: .align 2 
			.space 100


.text  ## Assembly language instructions go in text segment 

main: 					## Start of code section 


						
li $v0, 4 				# system call code for printing string = 4 
la $a0, out_string2 		# load address of string to be printed into $a0 
syscall 				 

la $t5,teststring


li $v0, 12 				# system call code for reading integer
syscall
move $t0, $v0			#get char to temp register

sb $t0,0($t5)

li $v0, 12 				# system call code for reading integer
syscall
move $t1, $v0			#get char to temp register

sb $t1,1($t5)

li $v0, 12 				# system call code for reading integer
syscall
move $t2, $v0			#get char to temp register

sb $t2,2($t5)


li $v0, 12 				# system call code for reading integer
syscall
move $t3, $v0			#get char to temp register

sb $t3,3($t5)



move $t4,$t0			# copy 1st character to $t4
sll $t4,$t4,8			# shift $t4 left for one byte

or $t4,$t4,$t1			# copy 2nd character to $t4
sll $t4,$t4,8			# shift $t4 left for one byte

or $t4,$t4,$t2			# copy 3rd character to $t4
sll $t4,$t4,8			# shift $t4 left for one byte

or $t4,$t4,$t3			# copy 4th character to $t4


la $t5,teststring		#load address to store the new word from $t4

sw $t4,8($t5)			#store word from $t4 @ address pointed by $t5 + 8 


move $t4,$t3			# copy 4th character to $t4
sll $t4,$t4,8			# shift $t4 left for one byte

or $t4,$t4,$t2			# copy 3rd character to $t4
sll $t4,$t4,8			# copy 4th character to $t4

or $t4,$t4,$t1			# copy 2nd character to $t4
sll $t4,$t4,8			# shift $t4 left for one byte


or $t4,$t4,$t0			# copy 1st character to $t4



la $t5,teststring		#load address to store the new word from $t4 (mirror of the previous)

sw $t4,12($t5)			#store word from $t4 @ address pointed by $t5 + 12 




li $v0, 4 				# system call code for printing string = 4 
la $a0, out_string1 	# load address of string to be printed into $a0 
syscall 			

# print the characters saved byte by byte
move $a0, $t5			#get String from temp to print 
li $v0, 4 				# system call code for printing string
syscall


li $v0, 4 				# system call code for printing string = 4 
la $a0, out_string1 		# load address of string to be printed into $a0 
syscall 			

# print the characters saved in the same order as the input and the characters in saved in mirror

addi $t5,$t5,8

move $a0, $t5			#get String from temp to print 
li $v0, 4 				# system call code for printing string
syscall



li $v0, 10 				# terminate program 
syscall
