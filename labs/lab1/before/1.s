EXIT = 1
STDIN = 0
STDOUT = 1
READ = 3
WRITE = 4

BUF_SIZE = 0x3

.data
  error_input_text: .string "Incorrect number of input\n"
  error_input_len: .byte . - error_input_text

  error_incorrect_byte: .string "Incorrect byte!\n"
  error_incorrect_byte_len: .byte . - error_incorrect_byte

.text
.globl _start

error_input:
  movl $WRITE, %eax
  movl $STDOUT, %ebx
  movl $error_input_text, %ecx
  movb error_input_len, %dl
  int $0x80

 jmp exit

error:
  xor %edx, %edx
  movl $WRITE, %eax
  movl $STDOUT, %ebx
  movl $error_incorrect_byte, %ecx
  movb error_incorrect_byte_len, %dl
  int $0x80

 jmp exit

_start:
  movl $-1, %eax

read_stdin:
  sub $BUF_SIZE, %esp # reserve buffer

  movl $READ, %eax
  movl $STDIN, %ebx
  movl $BUF_SIZE, %edx
  movl %esp, %ecx
  int $0x80

print:
  inc %eax # inc for \n
  movl %eax, %edx
  movl $WRITE, %eax
  movl $STDOUT, %ebx
  movl %esp, %ecx
  int $0x80

exit:
  movl $EXIT, %eax
  movl $0, %ebx
  int $0x80
