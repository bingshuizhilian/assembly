assume cs:a1

a1 segment
mov ax, 2000
mov bx, 2000h
add bx, ax

mov dl, 'y'
mov ah, 2
int 21h

mov ax, 4c00h
int 21h
a1 ends

end