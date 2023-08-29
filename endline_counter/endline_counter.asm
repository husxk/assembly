

section .data

file db 'file.txt', 0
error_mes db 'Unexpected error', 0
error_mes_len equ $ - error_mes
arg_error db 'Bad arg number, must input exactly 1 file', 0
arg_error_len equ $ - arg_error

file_text db 'File: ', 0
file_text_len equ $ - file_text
endl db 'lines: ', 0
endl_len equ $ - endl
ENDLINE db 0xa, 0

section .bss

buffer resb 0x1


section .text

global _start

check_args:
  pop r15   ; pop return 
  pop rbx
  
  mov r8, [rsp + 0x8]   ; skip argv[0]
  dec rbx

  cmp rbx, 0x1
  jne ARG_ERROR

  mov r13, 0x0    ; r13 contains size of filename

  get_file_len:
    mov al, [r8 + r13]
    cmp rax, 0x0
    je save_file_len
    inc r13
    jmp get_file_len

save_file_len:
  push r15
  ret

ARG_ERROR:
  mov rax, 0x1
  mov rdi, 0x1
  mov rsi, arg_error
  mov rdx, arg_error_len
  syscall

  mov rax, 0x3c
  mov rdi, 0x1
  syscall

open_file:
  mov rax, 0x2
  mov rdi, r8
  mov rsi, 0x0    ; read only
  mov rdx, 400o   ; user read mode
  syscall

  ret

close_file:
  mov rax, 0x3    ; rdi is still set as fd
  syscall

  ret

read_file:
  mov rax, 0x0
  mov rsi, buffer
  mov rdx, 0x1
  syscall

  cmp rax, 0x0    ; if rax has 0x0, it read 0 bytes -> eof
  je RETURN

  cmp rax, 0x1    ; if rax > 0x1, means error, rax's only proper value is 0x0 or 0x1
  ja ERROR

  cmp byte[buffer], 0xa
  je found_endline

  jmp read_file

RETURN:
  ret

ERROR:
  call close_file

  mov rax, 0x1
  mov rdi, 0x1
  mov rsi, error_mes
  mov rdx, error_mes_len
  syscall
  
  mov rax, 0x3c
  mov rdi, 0x1
  syscall

found_endline:
  inc r9
  jmp read_file

print_file_name:
  mov rax, 0x1
  mov rdi, 0x1
  mov rsi, file_text
  mov rdx, file_text_len
  syscall

  mov rax, 0x1
  mov rdi, 0x1
  mov rsi, r8
  mov rdx, r13
  syscall

  ret

print_ascii_line_count:
  cmp r8, 0
  je RETURN
  mov rax, 0x1
  mov rdi, 0x1
  mov rdx, 0x1
  pop rsi
  mov [buffer], rsi
  mov rsi, buffer
  syscall
  dec r8
  jmp print_ascii_line_count


to_ascii:
  cmp rax, 0
  je print_ascii_line_count

  mov rcx, 10
  mov rdx, 0
  div rcx
  add rdx, 0x30
  push rdx
  inc r8
  jmp to_ascii


print_results:
  
  call print_file_name

  mov rax, 0x1
  mov rdi, 0x1
  mov rsi, ENDLINE
  mov rdx, 0x1
  syscall

  mov rax, 0x1
  mov rdi, 0x1
  mov rsi, endl
  mov rdx, endl_len
  syscall

  mov rax, r9
  mov r8, 0     ; counter
  call to_ascii

  mov rax, 0x1
  mov rdi, 0x1
  mov rdx, 0x1
  mov rsi, ENDLINE
  syscall

  ret
  

_start:
  call check_args

  call open_file

  mov rdi, rax
  mov r9, 0x0     ; for number of lines

  call read_file

  call close_file

  call print_results


  mov rax, 0x3c
  mov rdi, 0x0
  syscall
