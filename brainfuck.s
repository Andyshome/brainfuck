
.global brainfuck

format_str: .asciz "We should be executing the following code:\n%s"
charToPrint: .asciz "%c"
charToRead: .asciz "%lc"
end_str:		.asciz "\nThis program is terminating\n"
# Your brainfuck subroutine will receive one argument:
# a zero termianted string containing the code to execute.
brainfuck:
	pushq %rbp
	movq %rsp, %rbp			# stack frame

	# save callee saved register!
	pushq	%r12
	pushq	%r13
	movq %rdi, %rbx				# Save brainfuck string

	movq $999999, %rdi
	movq $1 , %rsi      # The size of each cell is 1 byte (8bit)
  call calloc         # create enough space for the array

	movq	%rax,	%r12		#save the space in register r12

	movq	$0,		%r13		# temp counter to count the loop

	subq  $1,    %rbx				# Subtract one from string to prepare for the first scan.
#%rbx is the register for the string address
#r10 is the stack to save data
#r11 is the place to put my counter
main_loop:
	addq	$1,		%rbx			# find the next symbol

	cmpb	$0,	  (%rbx) # empty
	je		end
	cmpb	$43,	(%rbx) # + function
	je		plus
	cmpb	$45,	(%rbx) # - minus function
	je		minus
	cmpb	$44,	(%rbx) # , fucntion
	je		coma
	cmpb	$46,	(%rbx) # . function
	je		point

	cmpb	$60,	(%rbx) # < function
	je		less
	cmpb	$62,	(%rbx) # > function
	je		more
	cmpb  $91,	(%rbx) # [ start loop
	je		loop_begin
	cmpb	$93,	(%rbx)
	je		loop_end
	jmp		main_loop


plus:
	incb	(%r12)				# add value 1
	jmp		main_loop			# go back

minus:
	decb	(%r12)				# minus value 1
	jmp   main_loop			# go back

less:
	dec		%r12					# move to previous stack
	jmp   main_loop			# go back

more:
	inc		%r12					# move to next stack
	jmp   main_loop			# go back

coma:
	call 	getchar				# use get char function
	movb	%al,	(%r12)	# move the return value back to value of stack %r12
	jmp   main_loop

point:
	movq	$charToPrint,	%rdi	# move the print format to rdi register
	movq	(%r12),	%rsi	# move the print value to rsi register
	movq	$0,		%rax		# 0 vectors
	call 	printf				# call printf function
	jmp   main_loop			# go back

loop_begin:

	cmpb 	$0,		(%r12)	# check we should end the loop now or not
	je		immediately_end	# if it's 0, that means we need to stop the loop
	pushq	%rbx						# save the current space then we can go back
	jmp		main_loop				# go back


immediately_end:
	incq  %rbx					# check next char
	cmpb  $91,	(%rbx)	# prevent there is another loop in the array
	je		increase_counter_to_skip	# if there is  increase counter to skip it

	cmpb	$93,	(%rbx)	# check if it's an end of the inside loop
	je		decrease_counter_to_skip	# decrease counter to skip

	jmp   immediately_end	#go back and check next char


increase_counter_to_skip:
	incq	%r13		# increase counter
	jmp   immediately_end	# go back
decrease_counter_to_skip:
	cmpq	$0,	%r13	#compare the counter, if it's 0 means this is the correct end
	je		main_loop	# go back main loop
	decq  %r13	# if it's not 0 means there is a loop in the loop, so decreate the loop to skip it
	jmp   immediately_end	# go back immediately end

loop_end:

	popq	%rbx #get the position of the loop starts
	decq	%rbx # decrease one because in the main loop we increase one
	jmp   main_loop # go back main loop



end:
	movq $end_str, %rdi	# the end of the whole fucntion , we print string to represent end
	movq $0,	%rax	# clean the vectors
	call printf	# print the string to tell user we have finish executing this program



#clean the stack frame!
	popq %r13
	popq %r12


# return
	movq %rbp, %rsp
	popq %rbp
	ret
