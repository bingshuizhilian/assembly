; p184 检测点9.2 - 找到ds中第一个值为0的字节，将它的偏移地址存入dx中

; 1.1 所有的条件转移指令都是短转移，机器码中包含转移的位移而非地址，对IP的修改范围都是-128~127
; 1.2 jcxz label : 只有当cx为0时，跳转至标号label，否则去执行下一条指令

assume cs:code, ds:data

data segment
dd 12340078h
data ends

code segment
start:
mov ax, data
mov ds, ax
mov bx, 0
s:
mov cl, [bx]
mov ch, 0
jcxz ok
inc bx
jmp short s

ok:
mov dx, bx


mov ax, 4c00h
int 21h
code ends

end start