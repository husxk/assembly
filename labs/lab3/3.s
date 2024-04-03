# Numbers of kernel functions.
EXIT_NR  = 1
READ_NR  = 3
WRITE_NR = 4

STDOUT = 1
STDIN = 0
EXIT_CODE_SUCCESS = 0

# 16
#BUF_SIZE = 0x10

#256
BUF_SIZE = 0x100

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

.global _start

_start:

  movl %esp, %ebp
  sub $(BUF_SIZE * 3), %esp # reserve buffer
read:

  mov $READ_NR , %eax
  mov $STDIN   , %ebx
  leal BUF_SIZE(%esp), %ecx
  mov $(BUF_SIZE * 2), %edx
  int $0x80

  test %eax, %eax   # check eax MSB for sign, if eax < 0 -> error
  js error

  cmp $0x0, %eax
  je exit

  xor %ecx, %ecx    # counter
  xor %edx, %edx
  xor %eax, %eax
#  jmp print

  mov $(BUF_SIZE - 1), %cl

calc:
  sahf              # copy eflags from ax to eflags
  mov BUF_SIZE(%esp, %ecx, 1), %al
  mov BUF_SIZE * 2(%esp, %ecx, 1), %bl

  adc %bl, %al

  movb %al, (%esp, %ecx, 1)

  lahf              # save eflags to ax

  cmp $0x0, %ecx
  je print

  dec %ecx
  jmp calc

print:
  mov $WRITE_NR, %eax
  mov $STDOUT  , %ebx
  movl %esp, %ecx
  mov $BUF_SIZE, %edx
  int $0x80

  jmp read

exit:
  mov $EXIT_NR          , %eax
  mov $EXIT_CODE_SUCCESS, %ebx
  int $0x80
