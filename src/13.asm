; p150  7.9 - [bx+si+idata]的几种表示方法

assume cs:code

a segment
dw 8 dup (0)
db 'BaSiC'
db 'iNfOrMaTiOn'
a ends


code segment
start:
mov ax, a
mov ds, ax
mov bx, 10h
mov si, 0


; 不管以下何种书写形式，最终都是[bx+si+2]的含义
; 不同的写法对理解数据在内存中的布局有帮助
mov ah, ds:[2+bx+si]
inc si
mov al, ds:2[bx][si]
inc si
mov dh, ds:[bx].2[si]
inc si
mov dl, ds:[bx][si].2
inc si
mov ch, ds:[2+bx][si]
inc si
mov cl, ds:[bx].[si].2
inc si
mov ah, ds:0[bx].[si].2
inc si
mov al, ds:0[bx].2[si].0

mov ax, 4c00h
int 21h
code ends

end start