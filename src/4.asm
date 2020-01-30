assume cs:code

code segment
mov ax, 20h
mov ds, ax
mov cx, 40h

lb:
mov [bx], bx
inc bx
loop lb

mov ax, 4c00h
int 21h
code ends

end