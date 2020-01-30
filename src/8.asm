; p135 实验5-(5)

assume cs:code

; 每个段若不足16个byte，则自动扩展为16个byte，或者说是8个word
; 考虑字节对齐，最终分配的内存需要满足能存放下设定的字节数的最小的16*N个字节

a segment
db 1,2,3,4,5,6,7,8
a ends

b segment
db 1,2,3,4,5,6,7,8
b ends

c segment
db 8 dup (0)
c ends

code segment
start:
mov ax, c
mov ds, ax
mov ax, a
mov es, ax
mov ax, b
mov ss, ax

mov cx, 8
xor bx, bx
s:
mov al, es:[bx]
add al, ss:[bx]
mov ds:[bx], al
inc bx
loop s

mov ax, 4c00h
int 21h
code ends

end start  ; 1.通知编译器程序结束; 2.通知编译器程序的入口地址