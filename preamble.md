# M6800 LISP 1.5 PROGRAMMERS MANUAL
###### COPYRIGHT 1978 by:
###### FRITS VAN DER WATEREN


#### Note from the typist

This is as direct a reproduction as I could manage of the LISP 1.5 programmers manual for the [M6800 microcomputer](https://en.wikipedia.org/wiki/Motorola_6800) (In the interests of readability, I've left off the page headers, added minor bits of formatting where it seemed appropriate, and corrected minor spelling and grammar errors in the original). As of this writing, there are no other digital versions available. [Paul Tarvydas](https://github.com/guitarvydas?tab=activity) has gotten permission from the original author to digitize it for posterity.

The complete manual came on ~60 physical pages at a maximum of 64 fairly sparse lines per page, so I decided it would be easier to just re-type rather than deal with OCR issues. Also, I'm fucking bored. Let me know if you've caught an error.

On to the text.

### Getting started with LISP:

It is most likely that you have to patch the I/O part of LISP to your environment. For this purpose a listing of this section is supplied. This will be clear enough to patch the necessary changes.
Only a few notes on the device-table, which starts at `$106`.
LISP talks to a device via software I/O ports. Each port has four link-pointers in the device-table.

 - Link #1 should point to a routine that reads one character, which is returned in the A-accumulator.
 - Link #2 should point to a routine that outputs one character, which is supplied in the A-accumulator.
 - Link #3 should point to an OPEN-routine, which can be used either to initialize the handler or to open a file on file-oriented devices. In that case, a filename can be supplied. The pointer to that name is in `ARG2` (`$16`). When the filename is omitted, the contents of `ARG2` is `NIL`. The OPEN-routine must return `T` or `NIL` in the X-register. `T` in the case that the operation succeeds and `NIL` when it failed. `NIL` = `$0000` and `T` = `$0DCC`.
 - Link #4 should point to a CLOSE-routine, that closes the current file on this device. This routine must also return `T` or `NIL` in X. A special case is the close-routine for device #1, which checks if the `ETX` (ctrl/C) key is pressed. On `ETX`, it jumps back to the LISP-interpreter otherwise it continues. This routine is called several times during evaluation, but only via linked-address #4 of device #1.

### How to start LISP.

The start address of LISP is `$100`. When started it immediately allocates all contiguous RAM from the last location of LISP. It reserves the upper 1/8 part of memory for stack. One stack element takes always two bytes.
And the lower 7/8 parts of memory for cell-storage. One cell is 4 bytes.
It then initialises the OBLIST, i.e. all user entered `ATOM`s are deleted. Furthermore a garbage collection is forced, by setting the `FREE-LIST` to `NIL`. After all this work, LISP is ready for input and types a prompt ( `*` ) on the systems console (dev #1). To restart LISP, go at address `$103`. All `ATOM`s on the `OBLIST` are then maintained. Only a garbage collection is forced to clean up the cell-storage.

### Input - Output.

This LISP version is capable of handling more than one device. This is done by adding a port-number as an argument to I/O-functions. However when this argument is `NIL` or it is omitted, then I/O-port 1 is assumed.
Port-1 is the systems console (full duplex) and is interfaced by an `ACIA` located at `$FF00` and `$FF01`.
Port-2 is a high-speed reader interfaced by the A-section of a `PIA` at `$FF10` and `$FF11`.
Port-3 is a high-speed punch interfaced by the B-section of a `PIA` at `$FF12` and `$FF13`.
Port-4 and 5 are unused, but may be patched to user I/O routines.

Functions that can use I/O ports are:

    (PRIN1 X DEV)
	(PRINT X DEV)
	(TERPRI DEV)
	(READCH DEV)
	(READ1 DEV)
	(READ DEV)
	(OPEN DEV filename)
	(CLOSE DEV)

Where `DEV` is the port number.
`OPEN` or `CLOSE` performed on port 3 result in punching of about 15 inch of blank tape.
The input format is very free. You can insert spaces, tabs, commas and carriage-returns anywhere in the input string as separators to make it more readable. But an `ATOM` must be a contiguous string of characters of course, without any of these special characters. But when you want to use these separator characters and/or the special characters:left-parenthesis, right-parenthesis and a dot, then you will have to super-quote the `ATOM`. This is because the function `QUOTE` will not work on these characters. As superquotes the characters ' and " are used. The string to be quoted myst be enclosed by either of them. However, when this string is closed by a carriage-return it closes the quoting too, and the carriage-return is included as the last character in the string.
So when you want for-instance a single carriage-return, then write: "⏎
where ⏎  stands for carriage-return.

### Error recovery.

When you have typed an error, you can delete the whole line by typing CTRL/X (cancel). The system echoes a `@` and continues reading on the next line.
Previous characters can be deleted by typing a CTRL/H (back-space). The system then echoes this backspace, but only when there are characters in the buffer.
When your terminal has no back-space feature, you can use the `RUBOUT`-key. The deleted characters are then echoed in reverse order, enclosed by square brackets.
An evaluation can be aborted by pressing CTRL/C (`ETX`).

### Errors during runtime.

The following are the possible errors and their meaning.

 - **SYNTAX ERROR*** The input string is not a legal S-expression
 - **ILLEGAL NUMBER*** Illegal number structure in input string
 - **NON ATOMIC ARG:<list>** This error occurs when a function wants an atomic argument. Value is `NIL` and evaluation continues.
 - **ATOMIC ARG:<atom>** Atomic argument for `CAR`. Value is `NIL` and evaluation continues.
 - **ILLEGAL FUNCTION:<list>*** This function is not available in the `OBLIST`.
 - **ILLEGAL GO:<atom>*** This label is not inside the current `PROG`. Only local labels are allowed.
 - **ILLEGAL DEVICE:<dev>*** This device is not available in the `DEVICE-TABLE`
 - **OVERFLOW** An arithmetic overflow has occured. The value is taken modulo 2^15, and evaluation continues.
 - **TOO MANY ARGS** There are too many arguments supplied with a `SUBR` or `FSUBR` type of function. The remaining arguments are ignored and evaluation continues.
 - **TOO LITTLE ARGS** There are too little arguments supplied wih a `FSUBR`-type of function. The missing arguments are taken to be `NIL` and evaluation continues.
 - **TOO MANY ARGS FOR:<list>** There are too many arguments supplied with an `EXPR` or `FEXPR`-type of function.
 - **TOO LITTLE ARGS FOR:<LIST>** There are too little arguments supplied with an `EXPR` or `FEXPR`-type of function.
 - **NON NUMERIC ARG:<list>*** The argument must be a number for: `PLUS`, `MINUS`, `TIMES`, `QUOTIENT` and `GREATERP`.
 - **STACK OVERFLOW*** The stack has been used up. The system restarts at `$103`.
 - **MEMORY FULL*** All cells have been used up. The system restart at `$103`

NOTE: All errors marked with a `*` are fatal errors, that is: the current evaluation is aborted and a prompt is typed.

### A brief description of the cell structures.

The basic element in LISP is the cell, which requires four bytes in this implementation. The first two bytes represent the `CAR`-address, and the last two bytes the `CDR`-address. All addressing of the cells is even-word, that is: bits-0 and 1 are always zero. However bit-0 of the `CAR`-part is used as an `ATOM`mark and bit-0  of the `CDR`-part is used as a mark by the garbage collector.

Now an ATOM looks like:

[pic1]

When the print-name consists of an odd number of characters, a filler (negative byte) is used.
A numeric `ATOM` always consists of two cells and looks like:

[pic2]

Numbers in LISP are represented as a 16-bit signed integer. And are recognized as such when an Atom begins with a numeric character or a + or - sign.
The internal number representation in LISP is an `ATOM` with a print-name of `NIL`.

### Elementary functions.

 - `(CAR X)` value is the `CAR-part` of `X`. The `CAR` of an `ATOM` is illegal and will result in an error message. Never access the property of a `SUBR` or `FSUBR` indicator because it contains the pointer to a machine language routine.
 - `(CDR X)` value is the `CDR-part` of `X`.
 - `(CONS X Y)` values is the list: `(X . Y)`
 - `(QUOTE __X__)` value is `X` literally.
 - `(RPLACA X Y)` replace the `CAR-part` of `X` by `Y`; value is `X`
 - `(RPLACD X Y)` replace the `CDR-part` of `X` by `Y`; value is `X`

### I/O functions.

 - `(READCH DEV)` read one single character from `DEV`. The value is an `ATOM` of this single character.
 - `(READ1 DEV)` read an atom; the value is this atom.
 - `(READ DEV)` read an S-expression; value is this expression.
 - `(TEREAD)` flush the input buffer; value is `NIL`
 - `(PRIN1 DEV)` print atom X; value is `NIL`
 - `(PRINT X DEV)` print S-expression X; value is `NIL`. When there are more than 55 characters on a line then the first occurence of a space will be replaced by a carriage-return and linefeed.
 - `(TERPRI DEV)` print a `CR` and `LF` on `DEV`; value is `NIL`
 - `(OPEN DEV NAME)` open a file on `DEV` with `NAME` as a file name. Filenames may be omitted for non file oriented devices.
 - `(CLOSE DEV)` close file on `DEV`

### Predicates.

 - `(ATOM X)` if `X` is an atom, value is `T` else `NIL`
 - `(NUMBER X)` if `X` is a number, value is `T` else `NIL`
 - `(NULL X)` if `X` is `NIL`, values is `T` else `NIL`
 - `(EQ X Y)` if `X` is the same as `Y`, value is `T` else `NIL`
 - `(GREATER X Y)` if `X` is greater than `Y`, value is `T` else `NIL`.

### Arithmetic functions

 - `(PLUS X Y)` value is `X` + `Y`
 - `(MINUS X Y)` value is `X` - `Y`
 - `(TIMES X Y)` value is `X` * `Y`
 - `(QUOTIENT X Y)` value is `X` / `Y`

### Some miscellaneous functions.

 - `(SETQ X Y)` `X` is set to the value of `Y`; this is also the value of this function.
 - `(PUTPROP X Y Z)` The property-list of atom `X` is extended by property `Y` under an indicator of `Z`. If the indicator already exists, then its property is altered; value is `Y`
 - `(GET X Y)` Get the property saved under the indicator `Y` from the property-list of atom `X`
 - `(SASSOC X Y)` Lookup `X` on the association-list `Y`, when found return its value: else `NIL`
 - `(ALIST)` return the current systems association-list
 - `(COND __(A B) (X Y) ...__)` General conditional. Each argument of `COND` is a conditional expression. The number of these expressions may be infinite. A conditional expression consists of two items; next conditional expression is taken, tec; otherwise the second item (`B`) is evaluated, which is then the final result of `COND`. When there is no second item, then the value of the first item is the result, when not `NIL`. When `COND` runs out of its argument list, then the result is `NIL`; rather than an error message.
 - `(LIST __A B C ...__)` The result is the list of all its evaluated arguments. The number of arguments may be infinite.
 - `(EVAL X Y)` Evalueate `X` with `Y` as association-list. In fact this is the LISP-interpreter itself. When a variable is evaluated, then the association-list is always looked up first (by `SASSOC`) rather than to take the permanent value from its property-list.
 - `(APPLY X Y Z)` Apply the argument `Y` to the function `X` with `Z` as initial association-list.
 - `(PROG __(A B ...) L (statement 1) (statement 2) ...__)` With this function we are capable of writing programs in LISP. The first argument of `PROG` is a list of variables used inside the `PROG`. These are the so called 'local variables' and are initially set to `NIL`. The remainder is a list of labels and statements.
 - `(GO __L__)` Goto label `L` (literally). `GO` is restricted to local labels only. A reference outside a `PROG` will result in an error.
 - `(RETURN X)` Return from a `PROG` with the value of `X`. `RETURN` is the only legal exit from a `PROG`.
 - `(FUNCTION X)` The result is the list: `(FUNARG X alist)` where `alist` is the association-list at the time `FUNCTION` is called. When this list is scanned a next time, then `X` is evaluated with `alist` as association-list rather than the current association-list.
 - `OBLIST` `OBLIST` is an `ATOM` whos permanent value is a list of all `ATOM`s known by the system so far. Some other objects are: `SUBR`, `FSUBR`, `EXPR`, `FEXPR`, `LAMBDA`, `FUNARG`, `NIL`, `T`. All these objects have their self as a value.

NOTE: All underlined arguments are taken literally. All other arguments are evaluated before they are applied to the calling function.

I hope you will enjoy LISP.

And if any problems with LISP are encountered, or when you have any suggestions for improvements, which can be implemented in a next version, please let me know.

> Frits van der Wateren
> van 't Hoffstraat 140
> NL 2014 RK Haarlem
> The Netherlands
