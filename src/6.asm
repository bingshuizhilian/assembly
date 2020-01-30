; p128 程序6.3

assume cs:code

code segment

dw 0123h, 0456h, 0789h, 0abch, 0defh, 0fedh, 0cbah, 0987h
dw 16 dup (0)  ; debug程序也有操作栈的行为，因此要把栈设置的稍大些

start:
mov ax, cs
mov ss, ax
mov sp, 30h

mov cx, 8
sub bx, bx

lb:
push cs:[bx]
add bx, 2
loop lb

mov cx, 8  ;g 44
sub bx, bx

lb2:
pop cs:[bx]
add bx, 2
loop lb2

mov ax, 4c00h  ;g 51
int 21h
code ends

end start  ; 1.通知编译器程序结束; 2.通知编译器程序的入口地址