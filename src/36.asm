; p285 实验15 - 安装新的int 9中断例程

; 题目：安装一个新的int 9中断例程，功能：在DOS下，按下“A”键后，除非不再松开，如果松开，就显示满屏幕的“A”，其他的键照常处理。
; 扩展：此为自己添加的内容，在题目的基础上，把15.5的功能也整合进来，即实现在DOS下，按下F1键改变当前屏幕的显示颜色，其他的键照常处理。

; 注意：【断码 = 通码 + 80h】，按下一个键时产生的扫描码称为通码，松开一个键时产生的扫描码称为断码。

; 提示：键“A”的通码为0x1E，断码为0x9E；键F1的通码为3Bh，断码为0BBh。


assume cs:code

stack segment
db 128 dup (0)
stack ends

code segment
start:
; 设置栈
mov ax, stack
mov ss, ax
mov sp, 128

; 设置ds:si指向要安装的新的int9中断例程
push cs
pop ds
lea si, int9start

; 设置es:di指向新中断例程的安装位置0:204h
mov ax, 0
mov es, ax
mov di, 204h

; 安装新的中断例程
mov cx, offset int9end - offset int9start
cld
rep movsb

; 将原int9中断例程的ip、cs分别备份到0:200h、0:202h
push es:[9*4]
pop es:[200h]
push es:[9*4+2]
pop es:[202h]

; 用刚安装过的新的int9中断例程的ip、cs替换原来的ip、cs
cli
mov word ptr es:[9*4], 204h ; 注意：若执行完此设置ip语句，恰好发生了键盘中断事件，因为下条语句的cs还未设置，所以CPU将跳转到【旧cs:新ip】去执行，将发生错误，所以这里要关中断
mov word ptr es:[9*4+2], 0
sti


; 主程序退出
mov ax, 4c00h
int 21h

int9start:
push ax
push es
push cx
push di

in al, 60h

; 模拟中断过程，调用原int9中断例程，pushf是为了抵消原int9中断例程中的iret，IF、TF已经在系统产生int9中断时清0过了
pushf
call dword ptr cs:[200h] ; 注意此时的cs就是上面安装中断程序时设置的cs，即0

; 功能1：按下“A”键后，除非不再松开，如果松开，就显示满屏幕的“A”
cmp al, 9eh
jne int9sub2

mov ax, 0b800h
mov es, ax
xor di, di

mov cx, 2000
int9s1:
mov ah, 'A'
mov es:[di], ah
add di, 2
loop int9s1
jmp int9ret

; 功能2：按下F1键改变当前屏幕的显示颜色
int9sub2:
cmp al, 3bh
jne int9ret

mov ax, 0b800h
mov es, ax
mov di, 1

mov cx, 2000
int9s2:
inc byte ptr es:[di]
add di, 2
loop int9s2

int9ret:
pop di
pop cx
pop es
pop ax
iret
int9end:
nop

code ends
end start