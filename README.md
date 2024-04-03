# Assembly
## labs/
It is dir for university projects. It is done in 
- GNU As compiler
- AT&T syntax
- x86

## endline_counter
Program that is counting lines in given file.
Done with:
- Intel syntax
- x64


$ nasm -f elf64 endline_counter.asm -o endline_counter.o

$ ld -o endline_counter endline_counter.o 

$ ./endline_counter  a.txt

a.txt is an example input file

