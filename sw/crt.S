/* C runtime */

	/* error handler */
	.text
	.org 0x1c0
trap_entry:
	li a1, 0x40001000	# LED base address
	li t3, 0x79505000
	sw t3, 0x00(a1)		# HEX = 'Err '
1:      j 1b


	/* start of program */
	.globl _start
	.org 0x200 -4
        nop                     # prevent exception       
_start:	li sp,  0x20000400
	j main
