

lisp.s19 lisp.txt: lisp.asm
	../motorola-6800-assembler/bin/as0 lisp.asm -l >lisp.txt
