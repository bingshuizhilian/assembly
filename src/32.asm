; p262 实验13 - 编写、应用中断例程 - (2)a 安装程序

; 题目：编写并安装int 7ch中断例程，功能为完成loop指令的功能，在屏幕上中间显示80个"!"，中断例程安装在0:200处



assume cs:code

code segment
start:
mov ax, cs
mov ds, ax
mov si, offset irhnd7ch
mov ax, 0
mov es, ax
mov di, 200h

; 安装中断程序
mov cx, offset irhnd7chend - offset irhnd7ch
cld
rep movsb

; 设置中断向量
mov ax, 0
mov ds, ax
mov ds:[7ch*4], word ptr 200h  ; 偏移地址
mov ds:[7ch*4+2], word ptr 0h  ; 段地址

; 测试
int 0

; 主程序退出
mov ax, 4c00h
int 21h


; 名称：irhnd7ch
; 功能：7ch号中断处理程序，完成loop指令的功能，扩展了loop指令转移位移的范围(8位有符号数扩展到16位有符号数)
; 参数：(cx)=循环次数，(bx)=转移位移，转移位移是相对于进入中断例程前入栈的IP而言的
; 返回：无
irhnd7ch:
push bp
mov bp, sp

dec cx
jcxz irhnd7chloopend
add ss:[bp+2], bx

irhnd7chloopend:
pop bp
iret
irhnd7chend:
nop

code ends
end start