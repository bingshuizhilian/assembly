; p262 实验13 - 编写、应用中断例程 - (2)b 应用程序

; 题目：在“(2)a 安装程序”安装完成后，对下面的程序进行单步跟踪，尤其注意观察int、iret指令执行前后CS、IP和栈中的状态
; 注意/分析: 若果没有先运行32.exe，直接运行33.exe是没有效果的，因为中断向量和中断例程尚未安装

assume cs:code

code segment
start:
mov ax, 0b800h
mov es, ax
mov di, 160*12
mov bx, offset s - offset se  ; 设置从标号se到标号s的转移位移
mov cx, 80
s:
mov byte ptr es:[di], '!'
add di, 2

int 7ch                       ; 如果(cx)≠0，转移到标号s处
se:
nop

; 主程序退出
mov ax, 4c00h
int 21h

code ends
end start