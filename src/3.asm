; loop指令；使用非ds段寄存器时要加段前缀
assume cs:code

code segment
mov ax, 0
mov bx, 0
mov cx, 12
mov dx, 0

lb:
mov al, cs:[bx] ;ds:[bx]
mov ah, 0
add dx, ax
inc bx
loop lb

mov dl, 'y'
mov ah, 2
int 21h

mov ax, 4c00h
int 21h
code ends

end