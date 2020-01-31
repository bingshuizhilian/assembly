; p147  7.7 - 问题7.2

assume cs:code

a segment
db 'welcome to masm!'
db 16 dup (0)
db 16 dup (0)
a ends

code segment
start:
mov ax, a
mov ds, ax

mov si, 0
mov cx, 16

; 和下面的循环实现相同的功能，但是不使用di
; mov di, 10h
; s:
; mov al, ds:0[si]
; mov ds:0[di], al
; xor al, 20h
; mov ds:10h[di], al
; inc si
; inc di
; loop s

; 使用16位寄存器传送，减少了循环次数
mov cx, 8
s:
mov ax, ds:0[si]
mov ds:10h[si], ax
xor ax, 2020h
mov ds:20h[si], ax
add si, 2
loop s

mov ax, 4c00h
int 21h
code ends

end start