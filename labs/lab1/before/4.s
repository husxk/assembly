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

to_letter:
  add $0x7, %edx
  jmp to_letter_back

_start:

read_stdin:
  sub $BUF_SIZE, %esp # reserve buffer

  movl $READ, %eax
  movl $STDIN, %ebx
  movl $BUF_SIZE, %edx
  movl %esp, %ecx
  int $0x80

  movl %esp, %ecx # ecx -> ptr

  push %ax
  movl %esp, %ebp # ebp -> ptr on number of read bytes

  movl %eax, %ebx # eax -> value ebx -> iterator

  push $0xA
  xor %eax, %eax

from_ascii_to_number:
  cmp $0x0, %ebx
  je from_ascii_to_number_back

  subb $0x30, (%ecx)
  mull (%esp)# eax *= 10

  xor %edx, %edx
  movb (%ecx), %dl
  add %edx, %eax

  inc %ecx
  dec %ebx
  jmp from_ascii_to_number

from_ascii_to_number_back:
  add $0x2 + BUF_SIZE, %esp # pop 0xA + reserved buffer

  movl %esp, %ebp
  sub $0x1, %esp
  movb $0xA, (%esp)
  sub $0x1, %esp
  xor %ecx, %ecx
  movb $0x10, %cl

transform:
  sub $0x1, %esp
  xor %edx, %edx # we expect nothing in edx
  div %ecx # div by 16

  cmp $0x0, %edx
  je check_quotient # reminder is 0

  cmp $0x9, %edx
  ja to_letter
to_letter_back:
  add $0x30, %edx
  movb %dl, (%esp)

check_quotient:
  cmp $0x0, %eax
  jne transform

print:
  xor %edx, %edx

  movl %ebp, %edx
  sub %esp, %edx

  movl $WRITE, %eax
  movl $STDOUT, %ebx
  movl %esp, %ecx
  int $0x80

exit:
  movl $EXIT, %eax
  movl $0, %ebx
  int $0x80
