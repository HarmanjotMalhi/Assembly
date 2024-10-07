# Put integers into a binary tree
# node structure will be item, left, right

	.data
head:	.word 0		# address of the first element in the binary tree

prmpt1:	.asciiz	"Enter an integer to insert: "
msge:	.asciiz	"Tree is empty\n"

	.globl main
	.text

main:
	# Prompt for an integer to add to the binary tree
	li	$v0, 4
	la	$a0, prmpt1
	syscall
	li 	$v0, 5
	syscall
	move 	$s0, $v0		# move the integer into $s0

while1:	
	beqz	$s0, end_while1	# test if the user entered 0

	move 	$a0, $s0	# pass integer in $a0
	jal	add_node
	
	# Prompt for next integer to add to the binary tree
	li	$v0, 4
	la	$a0, prmpt1
	syscall
	li 	$v0, 5
	syscall
	
	move 	$s0,$v0		# move the integer into $s0
	b 	while1		# loop back
end_while1:

	# Now that we have our binary tree, print the items
	lw	$a0, head	# load head into the first argument
	addi	$sp, $sp, -8	# make room on stack for frame pointer and return address
	sw	$fp, 4($sp)	# save current frame pointer
	addi	$fp, $sp, 8	# set frame pointer location
	move $t1, $a0
	jal	print_tree

	li $v0,10
	syscall
### main ending
#######################################################################


# This is not a nested procedure so we will use a leaf procedure call
# This procedure will take $a0 and put it in the binary tree if it is not there already
add_node:
	addi	$sp, $sp, -8
	sw	$a0, 8($sp)		# save $a0 as we will overwrite it
	sw	$s0, 4($sp)		# save contents of $s0 as we are overwriting it
	
	move	$s0, $a0		# copy input argument into $s0
	
#	$s0 - number to store
#	$t1 - address of current node
#	$t2 - item in current node
#	$t3 - last node we traversed

	lw	$t1, head		# load the address of the head node
	beqz	$t1, first		# if the tree is empty add the first node
loop1:	
	# traverse the tree until we find where we need to add the new node
	lw	$t2, ($t1)		# load current item
if1:
	beq	$s0, $t2, end_loop1	# if the item is the same, no new node is needed
	ble	$s0, $t2, go_left	# if the new item is <= move to the left 
	# else we are continuing to the right 
	lw	$t3, 8($t1)		# load pointer to right branch
	beqz	$t3, add_new_right	# if there is no right address add the node here
	move	$t1, $t3		# otherwise load the right address and loop
	b	endif1
go_left:
	lw	$t3, 4($t1)		# load pointer to left branch
	beqz	$t3, add_new_left	# if there is no left address add the node here
	move	$t1, $t3		# otherwise load the left address and loop
endif1:	
	b	loop1			# test the next portion of the tree
end_loop1:
	b	add_node_rtn
	
# add the new node to the head and return
first:
	li $a0,12	  # malloc 12 bytes from the heap
	li $v0,9
	syscall
	# address to new memory is in $v0
	la	$t1, head	# get the memory location of head
	sw	$v0, ($t1)	# save the address of the new node to head
	sw	$s0, ($v0)	# set item value
	sw	$0, 4($v0)	# empty left pointer
	sw	$0, 8($v0)	# empty right pointer
	b	add_node_rtn	

# add the new node to the left pointer and return
add_new_left:
	li $a0,12	  # malloc 12 bytes from the heap
	li $v0,9
	syscall
	# address to new memory is in $v0
	sw	$v0, 4($t1)	# link the new node into left pointer of parent
	sw	$s0, ($v0)	# set item value
	sw	$0, 4($v0)	# empty left pointer
	sw	$0, 8($v0)	# empty right pointer
	b	add_node_rtn

# add the new node to the right pointer and return
add_new_right:
	li $a0,12	  # malloc 12 bytes from the heap
	li $v0,9
	syscall
	# address to new memory is in $v0
	sw	$v0, 8($t1)	# link the new node into right pointer of parent
	sw	$s0, ($v0)	# item
	sw	$0, 4($v0)	# left
	sw	$0, 8($v0)	# right

add_node_rtn:
	lw	$a0, 8($sp)	# restore incoming value of $a0
	lw	$s0, 4($sp)	# restore value $s0 had when we were called
	addi	$sp, $sp, 8
	jr	$ra
### End of add_node
#######################################################################



###
# This will need to be a recursive procedure to print from max integer to min
# That means a depth first traversal from right to left
#
# $a0 is the address of the head node of the tree segment
print_tree:

	 #storing the return address of the last recursive call
	 sw $ra, ($fp) 
	 #base call to check if the current address is zero
	 #and if it is then branch to print_item
         beqz $a0, print_item
         
         #creating a new stack frame to store the address of the right child of the current node        
	 sw  $a0, ($sp)
	 add $sp, $sp, -12
         sw $fp, 4($sp)
         add $fp, $sp, 8
         
         #storing the right child address in the $a0
	 lw $a0, 8($a0)
	 
	 #making a recursive call to the method just like in java
	 jal print_tree
	 
	 #this code below is for printing the value when the right child
	 #of a node is empty. It is executed when the method hits the base
	 #case and then print_item jr(jump return) to this and executes the 
	 #following code to print the current item
	 lw $t2, ($sp)
	 lw $a0, ($t2)	 
	 li $v0, 1
	 syscall
	 
	 li $a0, 32 #Print a space char
	 li $v0, 11
	 syscall
	
	 #saving the address of the current node back to $a0 
	 move $a0, $t2
	 
	 #below code is like the recursive call for the left child in inorder traversal in java.
	 #it first creates space for the left child in the stack and sets $a0 to the left child
	 #then makes a recursive call to the method print_tree.
	 add $sp, $sp, -12
	 sw $fp, 4($sp)
	 add $fp, $sp, 8
	 lw $a0, 4($a0)
	 jal print_tree

print_item:

	 #this code is executed when the print_tree method hits the base case.
	 #the below code jumps to the previous stack frame because the current stack frame 
	 #is built by the caller to store the child of the current node. But the child is empty 
	 #so we go to the previous stack frame(where the parent is stored) and jump the return address. 
	 lw $ra, ($fp)
	 lw $fp, 4($sp)
	 add $sp, $fp, -8
	 jr $ra
