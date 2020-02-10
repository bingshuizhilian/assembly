; p251 实验12 - 编写0号中断的处理程序

; 题目：编写0号中断的处理程序，使得在除法溢出发生时，在屏幕中间显示字符串“divide error!”，然后返回到DOS


assume cs:code

code segment
start:
mov ax, cs
mov ds, ax
mov si, offset irdata
mov ax, 0
mov es, ax
mov di, 200h

; 安装中断程序
mov cx, offset irend - offset irdata
cld
rep movsb

; 设置中断向量
mov ax, 0
mov ds, ax
mov ds:[4*0], word ptr 200h  ; 偏移地址
mov ds:[4*0+2], word ptr 0h  ; 段地址

; 测试
mov ax, 0
div ax

; 主程序退出
mov ax, 4c00h
int 21h


; 0号中断处理程序
irdata:
jmp irpayload       ; EB xx 90，3字节; jmp short xx 是两个字节
db 'divide error!'
irpayload:
mov ax, cs          ; 注意这个cs的值，它是CPU在中断过程中设置的，预先存储在中断向量表的，也就是上面源代码中设置中断向量的那个cs
mov ds, ax
mov ax, 0b800h
mov es, ax

mov si, 203h
mov di, 12*160+35*2
mov ah, 02h
mov cx, offset irpayload - offset irdata - 3
irdisp:
mov al, [si]
mov es:[di], ax
inc si
add di, 2
loop irdisp


; 0号中断处理程序退出
mov ax, 4c00h
int 21h

irend:
nop

code ends
end start