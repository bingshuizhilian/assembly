; p185 检测点9.3 - 找到ds中第一个值为0的字节，将它的偏移地址存入dx中

; 1.1 所有的loop循环指令都是短转移，机器码中包含转移的位移而非地址，对IP的修改范围都是-128~127
; 1.2 loop label : 先执行(cx)=(cx)-1，之后如果(cx)不为0，则跳转至标号label，否则去执行下一条指令

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
inc cx
inc bx
loop s

ok:
dec bx
mov dx, bx


mov ax, 4c00h
int 21h
code ends

end start