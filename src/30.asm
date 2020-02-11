; p262 实验13 - 编写、应用中断例程 - (1)a 安装程序

; 题目：编写并安装int 7ch中断例程，功能为显示一个用0结束的字符串，中断例程安装在0:200处



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
; 功能：7ch号中断处理程序，显示一个用0结束的字符串
; 参数：(dh)=行号，(dl)=列号，(cl)=颜色，ds:si指向字符串首地址
; 返回：无
irhnd7ch:
mov ax, 0b800h
mov es, ax

xor si, si
xor ax, ax
mov al, dh
mov ah, 160
mul ah
xor dh, dh
add dl, dl
add ax, dx
mov di, ax
mov ah, cl
irhnd7chdisp:
mov al, [si]
mov es:[di], ax
xor ch, ch
mov cl, [si]
inc si
add di, 2
inc cx
loop irhnd7chdisp

iret
irhnd7chend:
nop

code ends
end start