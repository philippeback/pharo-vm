printing
printRegisterStateExceptPC: registerStateVector on: aStream
	self printFields: #(	r0 r1 r2 r3 cr
						r4 r5 r6 r7 cr
						r8 r9 r10 r11 cr
						r12 sp lr eflags cr)
		inRegisterState: registerStateVector
		on: aStream