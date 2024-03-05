EXIT = 1
STDIN = 0
STDOUT = 1
READ = 3
WRITE = 4

.data
buff: .space 1


.text
.globl _start
_start:
  # read char from stdin
  movl $READ, %eax
  movl $STDIN, %ebx
  movl $buff, %ecx
  movl $0x1, %edx
  int $0x80

  #echo back
  movl $WRITE, %eax
  movl $STDOUT, %ebx
  movl $buff, %ecx
  movl $0x1, %edx
  int $0x80

  #exit
  movl $EXIT, %eax
  movl $0x1, %ebx
  int $0x80
