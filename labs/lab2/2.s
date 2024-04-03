# Numbers of kernel functions.
EXIT_NR  = 1
READ_NR  = 3
WRITE_NR = 4

STDOUT = 1
STDIN = 0
EXIT_CODE_SUCCESS = 0

BUF_SIZE = 0x1


.data
  error_incorrect_byte: .string "Incorrect byte!\n"
  error_incorrect_byte_len: .byte . - error_incorrect_byte

.text

error:
  xor %edx, %edx
  movl $WRITE_NR, %eax
  movl $STDOUT              , %ebx
  movl $error_incorrect_byte, %ecx
  movb error_incorrect_byte_len, %dl
  int $0x80

 jmp exit

letter:
  add $0x7, %al
  jmp letter_back

compare:
  cmp $0x09, %al
  ja letter
letter_back:
  add $0x30, %eax
  ret

.global _start

_start:

  movl %esp, %ebp
  sub $BUF_SIZE, %esp # reserve buffer
read:

  mov $READ_NR , %eax
  mov $STDIN   , %ebx
  mov %esp     , %ecx
  mov $BUF_SIZE, %edx
  int $0x80

  test %eax, %eax   # check eax MSB for sign, if eax < 0 -> error
  js error

  cmp $0x0, %eax
  je exit

  mov %esp, %edx
  xor %eax, %eax

  # output buffer
  push $0xA # \n
  sub $0x2, %esp
  
  movb (%edx), %al # copy to eax
  and $0x0F, %al # mask lower

  call compare

  leal 0x1(%esp), %ebx
  mov %al, (%ebx)
  
  movb (%edx), %al # copy to eax
  and $0xF0, %al # mask
  shr $0x4, %al # shift to lower

  call compare
  mov %al, (%esp)

print:
  mov $WRITE_NR, %eax 
  mov $STDOUT  , %ebx 
  mov %esp     , %ecx
  mov $3, %edx
  int $0x80

  jmp read

exit:
  mov $EXIT_NR          , %eax
  mov $EXIT_CODE_SUCCESS, %ebx 
  int $0x80
