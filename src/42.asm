; p310 实验17 - 编写包含多个功能子程序的中断例程 - 应用程序

; 题目：安装一个新的int 7ch中断例程，实现通过逻辑扇区号对软盘进行读写

; 说明：笔者未找到/安装合适的软盘测试环境，所以源代码仅验证了逻辑，没有经过实际测试


assume cs:code, ds:data, ss:stack

data segment
string db 'This is a int 13h floppy disk read/write testcase, 20200217@harbin', 0
stringend db 0
data ends

stack segment
db 128 dup (0)
stack ends

code segment
start:
mov ax, stack
mov ss, ax
mov sp, 128
mov ax, data
mov ds, ax


; 调用的int 7ch的参数说明
; 功能：7ch号中断处理程序，实现通过逻辑扇区号对软盘进行读写
; 参数：(1)用ah寄存器传递功能号：0表示读，1表示写
;       (2)用dx寄存器传递要读写的扇区的逻辑扇区号
;       (3)用es:bx指向存储读出数据或写入数据的内存区

; int 7ch写入测试
; push ds
; pop es
; xor bx, bx
; mov ah, 1
; mov dx, 1
; int 7ch
; call delay

; int 7ch读取测试
mov ax, 2000h
mov es, ax
xor bx, bx
mov ah, 0
mov dx, 1
int 7ch


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