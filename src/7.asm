; p135 实验5-(3)

assume cs:code, ds:data, ss:stack

code segment
start:
mov ax, stack
mov ss, ax
mov sp, 10h

mov ax, data
mov ds, ax

push ds:[0]
push ds:[2]
pop ds:[2]
pop ds:[0]

mov ax, 4c00h
int 21h
code ends

data segment
dw 0123h, 0456h  ;, 0789h, 0abch, 0defh, 0fedh, 0cbah, 0987h
data ends

stack segment
dw 2 dup (0)  ; 自动扩展为16个byte，或者说是8个word
stack ends

end start  ; 1.通知编译器程序结束; 2.通知编译器程序的入口地址