EXIT = 1
STDIN = 0
STDOUT = 1
READ = 3
WRITE = 4

BUF_SIZE = 0x1
BUF_SIZE_OUT = BUF_SIZE * 5

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

set_to_one:
  bts $0x0, (%edx)    # set least significant bit to 1
  jmp set_to_one_back

from_lower_case:
  cmpb $0x31, (%esp) # below lower case
  jb error
  cmpb $0x36, (%esp) # above f
  ja error

  subb $0x20, (%esp)
  jmp from_lower_case_back

letter_to_number:
  cmpb $0x11, (%esp) # below upper case (A is at 0x11 + 0x30)
  jb error
  cmpb $0x16, (%esp) # above F
  ja from_lower_case
from_lower_case_back:
  subb $0x7, (%esp)

  jmp letter_to_number_back

_start:

read_stdin:
  sub $BUF_SIZE, %esp # reserve buffer

  movl $READ, %eax
  movl $STDIN, %ebx
  movl $BUF_SIZE, %edx
  movl %esp, %ecx
  int $0x80

  cmpb $0xA, (%esp)
  je exit

  cmpb $0x0, (%esp)
  je exit

  subb $0x30, (%esp)   # ASCII -> number

  cmpb $0x9, (%esp)
  ja letter_to_number

letter_to_number_back:

  xor %eax, %eax
  xor %edx, %edx
  xor %ecx, %ecx

  mov %esp, %edx
  push %eax # push zeros on the stack
  movb (%edx), %al

  movb $0x3, %cl

parse:
  dec %edx
  bt %ecx, %eax # sets CF as bit at ecx in eax
  jb set_to_one # jmp if CF = 1

set_to_one_back:
  addb $0x30, (%edx)
  dec %ecx

  cmp %edx, %esp
  jne parse


print:
  movl $BUF_SIZE_OUT, %edx
  movl $WRITE, %eax
  movl $STDOUT, %ebx
  movl %esp, %ecx
  int $0x80

jmp read_stdin

exit:
  movl $EXIT, %eax
  movl $0, %ebx
  int $0x80
