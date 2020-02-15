; p299 实验16 - 编写包含多个功能子程序的中断例程 - 应用程序

; 题目：安装一个新的int 7ch中断例程，为显示输出提供如下功能子程序：(1)清屏;(2)设置前景色;(3)设置背景色;(4)向上滚动一行


assume cs:code, ss:stack

stack segment
db 128 dup (0)
stack ends

code segment
start:
mov ax, stack
mov ss, ax
mov sp, 128

; 测试前景色
mov ah, 1
mov al, 2
int 7ch
call delay

; 测试背景色
mov ah, 2
mov al, 4
int 7ch
call delay

; 测试向上滚动一行
mov ah, 3
int 7ch
call delay

; 测试清屏
mov ah, 0
int 7ch
call delay


; 主程序退出
mov ax, 4c00h
int 21h

delay:
push ax
push dx
mov dx, 20h  ; 大概3秒左右           
mov ax, 0
delays:
sub ax, 1
sbb dx, 0
cmp ax, 0
jne delays
cmp dx, 0
jne delays
pop dx
pop ax
ret

code ends
end start