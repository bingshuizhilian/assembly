; p136 实验5-(6)

assume cs:code

; 每个段若不足16个byte，则自动扩展为16个byte，或者说是8个word
; 考虑字节对齐，最终分配的内存需要满足能存放下设定的字节数的最小的16*N个字节

a segment
dw 1,2,3,4,5,6,7,8,9,0ah,0bh,0ch,0dh,0eh,0fh,0ffh
a ends

b segment
dw 8 dup (0)  ; 8个word型的0
b ends

code segment
start:
mov ax, a
mov ds, ax
mov ax, b
mov ss, ax
mov sp, 10h

mov cx, 8
xor bx, bx
s:
push ds:[bx]
add bx, 2
loop s

mov ax, 4c00h
int 21h
code ends

end start  ; 1.通知编译器程序结束; 2.通知编译器程序的入口地址