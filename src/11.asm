; p143  7.5 - [bx+idata]的几种表示方法

assume cs:code

a segment
db 'BaSiC'
db 'iNfOrMaTiOn'
a ends


code segment
start:
mov ax, a
mov ds, ax


mov ah, ds:0[bx]     ;方法1
mov al, ds:0eh[bx]   ;方法1
mov bh, ds:[bx+2]    ;方法2
mov bl, ds:[bx].0ah  ;方法3


mov ax, 4c00h
int 21h
code ends

end start