* EsoLang Interpreter
This is a tiny app for iOS written in swift, that allows you to program BF on your favourite iOS device.

** How to use
It only has one screen with the 2 text views. The top text view you type in the code, while you see the output in the bottom view. If you tap the bottom text view you can enter input to your program. Tapping 'Done' after typing in code runs the code.

** The language
The instructions for the BF this app understands are as follows:
	+	increment by one the char at position of pointer
	-	decrease by one the char at position of pointer
	>	increase pointer by one
	<	decrease pointer by one
	,	read character from input
	.	print character to output
	[	open of while loop, loops until char at position of pointer is 0
	]	close of while loop

My own added instructions for easier programming and debugging:
	;	everything after semicolon up to end of line is ignore ie. comment
	$	print the number at position of pointer to output
	^	print the position of the pointer to output

** Contributing
	Any ideas, issues or pull requests are welcome. 
