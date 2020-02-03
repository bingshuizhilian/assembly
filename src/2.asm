; 段前缀
assume cs:a1

a1 segment
mov ax, 0a100h ;不能以字母开头
mov bx, [100h]
mov cx, [bx]
mov dx, ds:[2]
mov si, ds:[bx]




mov dl, 'y'
mov ah, 2
int 21h

mov ax, 4c00h
int 21h
a1 ends

end