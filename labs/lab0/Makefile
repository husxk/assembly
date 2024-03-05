
FILE := echo

all: compile

compile:
	as -g --32 -o ${FILE}.o ${FILE}.s && ld -m elf_i386 -o ${FILE} ${FILE}.o

gdb:
	gdb ${FILE}

run:
	./${FILE}

clean:
	rm ${FILE}.o ${FILE}

.PHONY: clean gdb compile run
