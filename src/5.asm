;p35 实验4-(3)

assume cs:code

code segment
mov ax, 20h
mov ds, ax
mov bx, 0
mov cx, 13h

lb:
mov al, cs:[bx]
mov [bx], al
inc bx
loop lb

mov ax, 4c00h
int 21h
code ends

end