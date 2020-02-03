; 段前缀
assume cs:a1

a1 segment
mov ax, 0a100h     ; 不能以字母开头
mov bx, [100h]     ; = mov bx, 100h
mov bx, ds:[100h]
mov cx, [bx]
mov dx, [2]
mov dx, [si]
mov si, ds:[bx]    ; 只有bx、si、di、bp可用作寄存器间接寻址




mov dl, 'y'
mov ah, 2
int 21h

mov ax, 4c00h
int 21h
a1 ends

end