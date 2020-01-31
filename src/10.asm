; p140 7.4-大小写转换算法

assume cs:code

a segment
db 'BaSiC'
db 'iNfOrMaTiOn'
a ends

b segment
db 16 dup (0)
b ends

c segment
db 16 dup (0)
c ends

code segment
start:
mov ax, a
mov ds, ax
mov ax, b
mov es, ax
mov ax, c
mov ss, ax

;前5个转大写
mov cx, 5
xor bx, bx
s:
mov al, ds:[bx]
and al, 11011111b
mov es:[bx], al
inc bx
loop s

;后11个转小写
mov cx, 11
s2:
mov al, ds:[bx]
or al, 00100000b
mov es:[bx], al
inc bx
loop s2

;全部大小写翻转
mov cx, 16
xor bx, bx
s3:
mov al, ds:[bx]
xor al, 00100000b
mov ss:[bx], al
inc bx
loop s3

mov ax, 4c00h
int 21h
code ends

end start  ; 1.通知编译器程序结束; 2.通知编译器程序的入口地址