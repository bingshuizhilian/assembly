; p262 实验13 - 编写、应用中断例程 - (1)b 应用程序

; 题目：在“(1)a 安装程序”安装完成后，对下面的程序进行单步跟踪，尤其注意观察int、iret指令执行前后CS、IP和栈中的状态
; 注意/分析: 若果没有先运行30.exe，直接运行31.exe是没有效果的，因为中断向量和中断例程尚未安装

assume cs:code

data segment
db "welcome to masm! ", 0
data ends

code segment
start:
mov dh, 10
mov dl, 10
mov cl, 2
mov ax, data
mov ds, ax
mov si, 0

int 7ch

; 主程序退出
mov ax, 4c00h
int 21h

code ends
end start