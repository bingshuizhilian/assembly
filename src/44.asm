; p312 课程设计2 - payload

; 题目：编写一个可以自行启动计算机，不需要在现有操作系统环境中运行的程序，功能如下
;   (1) 列出功能选项，让用户通过键盘进行选择，界面如下
;       1) reset pc        ;重新启动计算机
;       2) start system    ;引导现有的操作系统
;       3) clock           ;进入时钟程序
;       4) set clock       ;设置时间
;   (2) 用户输入“1”后重新启动计算机(提示：考虑ffff:0单元)
;   (3) 用户输入“2”后引导现有的操作系统(提示：考虑硬盘C的0道0面1扇区)
;   (4) 用户输入“3”后，执行动态显示当前日期、时间的程序，显示格式如下：年/月/日 时:分:秒，进入此
;       项功能后，一直动态显示当前的时间，在屏幕上将出现时间按秒变化的效果(提示：循环读取CMOS)，
;       当按下F1键后，改变显示颜色，按下Esc键后，返回到主菜单(提示：利用键盘中断)
;   (5) 用户输入“4”后可更改当前日期、时间，更改后返回到主菜单(提示：输入字符串)

; 题目建议
; (1) 在DOS下编写安装程序，在安装程序中包含任务程序
; (2) 运行安装程序，将任务程序写到软盘上
; (3) 若要任务程序可以在开机后自动执行，要将它写到软盘的0道0面1扇区上。如果程序长度大于512字节，则需
;     要用多个扇区存放，这种情况下，处于软盘0道0面1扇区中的程序就必须负责将其他扇区中的内容读入内存


; 基础知识点
; (1) 开机后CPU自动进入到FFFF:0单元处执行，此处有一条跳转指令，CPU执行该指令后，转去执行BIOS中的硬件系统检测和初始化程序
; (2) 初始化程序将建立BIOS所支持的中断向量，即将BIOS提供的中断例程的入口地址登记在中断向量表中
; (3) 硬件系统检测和初始化完成后，调用int 19h进行操作系统的引导
;     1) 如果设为从软盘启动操作系统，则int 19h将主要完成以下工作：
;        a. 控制0号软驱，读取软盘0道0面1扇区的内容到0:7c00
;        b. 将CS:IP指向0:7c00
;     2) 软盘的0道0面1扇区中装有操作系统引导程序，int 19h将其装到0:7c00处后，设置CPU从0:7c00开始执行此处的引导程序，操作
;        系统被激活，控制计算机
;     3) 如果在0号软驱中没有软盘，或发生软盘I/O错误，则int 19h将主要完成以下工作：
;        a. 读取硬盘C的0道0面1扇区的内容到0:7c00
;        b. 将CS:IP指向0:7c00


; 说明 ：笔者已经在vmware15.5.1下安装msdos7.1和虚拟软盘测试环境进行了实际测试，可以正常使用


assume cs:code, ss:stack
stack segment
db 128 dup (0)
stack ends

code segment
start:
mov ax, stack
mov ss, ax
mov sp, 128

call payloadwriter

; 主程序退出
mov ax, 4c00h
int 21h


;-------------------------------------------------------------------
; payloadwriter
;-------------------------------------------------------------------
payloadwriter:
push cs
pop es
mov bx, offset payload
mov al, 3 ; 读/写的扇区数量
mov ch, 0 ; 磁道号
mov cl, 2 ; 扇区号
mov dl, 0 ; 驱动器号
mov dh, 0 ; 磁头号(面号)
mov ah, 3 ; 功能号：3写入、2读取
int 13h
ret


payload:
jmp mainmenu
db 'payload by bingshuizhilian @ 20200303 : start'
;-------------------------------------------------------------------
; mainmenu
;-------------------------------------------------------------------
mainmenu:
call showoptions
call dealwithkey
loop mainmenu
ret


;-------------------------------------------------------------------
; showoptions
;-------------------------------------------------------------------
showoptions:
jmp show
string db 'Please input your choice:', 0
db '1) reset pc', 0
db '2) start system', 0
db '3) clock', 0
db '4) set clock', 0
stringend db 0
disppos dw 160*9+50, 160*10+50-2, 160*11+50-2, 160*12+50-2, 160*13+50-2
show:
push ax
push ds
push si
push es
push bx
push di
push cx

call clearscreen

mov ax, 0b800h
mov es, ax
xor bx, bx
mov si, offset start - offset payload ; 安装程序中标号位置都是相对于start的，而安装后的程序的标号都是相对于payload的
mov di, [7e00h+disppos+si+bx]         ; 程序最终要安装到7e00h位置，因地址使用了标号disppos，它位于cs段，故使用的是cs段而非默认的ds段
mov cx, offset stringend - offset string
shows:
mov al, [7e00h+string+si]
cmp al, 0
jne shows2
push si
mov si, offset start - offset payload
add bx, 2
mov di, [7e00h+disppos+si+bx]
pop si
shows2:
mov es:[di], al
inc si
add di, 2
loop shows

pop cx
pop di
pop bx
pop es
pop si
pop ds
pop ax
ret


;-------------------------------------------------------------------
; dealwithkey
;-------------------------------------------------------------------
dealwithkey:
jmp dealwithkeystart
functbl dw reboot, loados, clock, setclock
dealwithkeystart:
push ax
push bx
push cx
push dx
push si
; 设置光标
dealwithkeycursor:
mov ah, 2
mov bh, 0
mov dh, 15
mov dl, 25
int 10h
; 获取输入
mov ah, 0
int 16h
cmp al, '1'
jb dealwithkeycursor
cmp al, '4'
ja dealwithkeycursor
; 显示字符
mov ah, 9
mov bl, 0fh
mov bh, 0
mov cx, 1
int 10h
; 子功能调用
sub al, 31h
xor bx, bx
mov bl, al
add bx, bx
mov si, offset start - offset payload
mov cx, [7e00h+functbl+si+bx]
add cx, si
add cx, 7e00h
call delay
call delay
call cx
dealwithkeyret:
pop si
pop dx
pop cx
pop bx
pop ax
ret


;-------------------------------------------------------------------
; reboot
;-------------------------------------------------------------------
reboot:
mov ax, 0ffffh
push ax
mov ax, 0
push ax
retf


;-------------------------------------------------------------------
; loados
;-------------------------------------------------------------------
loados:
mov ax, 0
mov es, ax
mov bx, 7c00h

mov al, 1
mov ch, 0
mov cl, 1
mov dl, 80h ; C盘
mov dh, 0
mov ah, 2
int 13h

; 设置cs:ip为0:7c00
push es
push bx
retf


;-------------------------------------------------------------------
; clock
;-------------------------------------------------------------------
clock:
jmp clockstart
origint9addr dw 0, 0 ; 这里存储原来的int9中断向量
datetime db 'YY/MM/DD hh:mm:ss'
memindex db 9,8,7,4,2,0
oprttip1 db 'F1:change color, ESC:back to main menu'
clockstart:
push si
push bx
push di
push cx
push ax
push es

; 清屏
call clearscreen
; 备份旧的int9中断、安装新的int9中断
mov ax, 0
mov es, ax
mov si, offset start - offset payload
push es:[9*4]
pop [7e00h+origint9addr+si]
push es:[9*4+2]
pop [7e00h+origint9addr+si+2]
cli
add si, offset newint9
add si, 7e00h
mov word ptr es:[9*4], si
push cs
pop es:[9*4+2]
sti
; 从CMOS RAM中读取时间信息，存储至datetime
clockdisp:
mov si, offset start - offset payload
mov bx, 7e00h + offset datetime
add bx, si
mov di, 7e00h + offset memindex
add di, si
mov cx, 6
clocks:
mov al, cs:[di]
out 70h, al
in al, 71h
push cx
mov ch, al
mov cl, 4
shr ch, cl
add ch, 30h
mov cs:[bx], ch
and al, 0fh
add al, 30h
mov cs:[bx+1], al
pop cx
add bx, 3
inc di
loop clocks
; 显示时间
mov ax, 0b800h
mov es, ax
mov si, 7e00h + offset datetime - offset payload
mov di, 160*11+30*2
mov cx, offset memindex - offset datetime
clocks2:
mov al, cs:[si]
mov es:[di], al
inc si
add di, 2
loop clocks2
; 显示操作提示信息
mov ax, 0b800h
mov es, ax
mov si, 7e00h + offset oprttip1 - offset payload
mov di, 160*13+20*2
mov cx, offset clockstart - offset oprttip1
clocks3:
mov al, cs:[si]
mov es:[di], al
inc si
add di, 2
loop clocks3
; 循环显示
call delay
jmp clockdisp

pop es
pop ax
pop cx
pop di
pop bx
pop si
ret


;-------------------------------------------------------------------
; setclock
;-------------------------------------------------------------------
setclock:
jmp setclockstart
datetime2 db 'YY/MM/DD hh:mm:ss'
datetime3 db '__/__/__ __:__:__'
memindex2 db 9,8,7,4,2,0
newtime   db offset datetime3 - offset datetime2 dup (0)
oprttip2  db 'BACKSPACE:clear input, ENTER:set clock, ESC:back to main menu'
setclockstart:
push si
push bx
push di
push cx
push ax
push es
push dx

setclockbackspace:
; 清屏
call clearscreen
; 显示时间格式信息
mov ax, 0b800h
mov es, ax
mov si, 7e00h + offset datetime2 - offset payload
mov di, 160*10+30*2
mov cx, offset datetime3 - offset datetime2
setclocks:
mov al, cs:[si]
mov es:[di], al
inc si
add di, 2
loop setclocks
; 显示操作提示信息
mov ax, 0b800h
mov es, ax
mov si, 7e00h + offset oprttip2 - offset payload
mov di, 160*14+10*2
mov cx, offset setclockstart - offset oprttip2
setclocks2:
mov al, cs:[si]
mov es:[di], al
inc si
add di, 2
loop setclocks2
; 显示输入栏
mov ax, 0b800h
mov es, ax
mov si, 7e00h + offset datetime3 - offset payload
mov di, 160*11+30*2
mov cx, offset memindex2 - offset datetime3
setclocks3:
mov al, cs:[si]
mov es:[di], al
inc si
add di, 2
loop setclocks3

; 获取输入信息
mov dl, 30
setclocks4:
; 设置光标
mov ah, 2
mov bh, 0
mov dh, 11
int 10h
; 获取输入，返回值：(ah)=扫描码，(al)=ASCII码
mov ah, 0
int 16h
cmp ah, 0eh ; backspace的扫描码为0eh
je setclockbackspace
cmp ah, 1ch ; enter的扫描码为1ch
je setclockenter
cmp ah, 1h  ; esc的扫描码为1h
je setclockend
; 将输入的字符转换为相应的数字，并存储于newtime处
cmp dl, 30 + offset memindex2 - offset datetime3
jnb setclockskipsave ; 防止输入超长时覆盖newtime后面的内存
push ax
push bx
sub al, 30h
xor bx, bx
mov bl, dl
sub bl, 30
mov si, 7e00h + offset newtime - offset payload
mov cs:[si+bx], al
pop bx
pop ax
setclockskipsave:
; 显示字符
mov ah, 9
mov bl, 7h
mov bh, 0
mov cx, 1
int 10h
inc dl
jmp setclocks4

setclockenter:
cmp dl, 30 + offset memindex2 - offset datetime3
je setclockenternext
jmp near ptr setclockbackspace ; 转移距离超限，不能使用jne条件转移指令
setclockenternext:
; 设置时间
mov bx, 7e00h + offset newtime - offset payload
mov di, 7e00h + offset memindex2 - offset payload
mov cx, 6
setclocks5:
push cx
mov al, cs:[di]
out 70h, al
mov al, cs:[bx]
mov cl, 4
shl al, cl
add al, cs:[bx+1]
out 71h, al
add bx, 3
inc di
pop cx
loop setclocks5

setclockend:
pop dx
pop es
pop ax
pop cx
pop di
pop bx
pop si
ret


;-------------------------------------------------------------------
; delay
;-------------------------------------------------------------------
delay:
push ax
push dx
mov dx, 2000h  ; 大概0.5秒左右，因处理器不同而不同，需找到适合自己机器的值
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


;-------------------------------------------------------------------
; clearscreen
;-------------------------------------------------------------------
clearscreen:
push di
push es
push cx
mov di, 0b800h
mov es, di
xor di, di
mov cx, 2000
clearscreens:
mov byte ptr es:[di], ' '
add di, 2
loop clearscreens
pop cx
pop es
pop di
ret


;-------------------------------------------------------------------
; newint9
;-------------------------------------------------------------------
newint9:
push ax
push es
push cx
push di
in al, 60h
; 模拟中断过程，调用原int9中断例程，pushf是为了抵消原int9中断例程中的iret，IF、TF已经在系统产生int9中断时清0过了
pushf
mov di, 7e00h + offset origint9addr - offset payload
call dword ptr cs:[di]
; 功能1：按下“ESC”键后，返回到主菜单
cmp al, 1
jne newint9sub2
; 功能1-1 恢复原来的int9中断
mov ax, 0
mov es, ax
mov di, 7e00h + offset origint9addr - offset payload
cli
push cs:[di]
pop es:[9*4]
push cs:[di+2]
pop es:[9*4+2]
sti
; 功能1-2 恢复屏幕颜色
mov ax, 0b800h
mov es, ax
mov di, 1
mov cx, 2000
newint9s2:
mov byte ptr es:[di], 7
add di, 2
loop newint9s2
; 功能1-3 返回主菜单
popf
pop di
pop cx
pop es
pop ax
jmp mainmenu
; 功能2：按下F1键改变当前屏幕的显示颜色
newint9sub2:
cmp al, 3bh
jne newint9ret
mov ax, 0b800h
mov es, ax
mov di, 1
mov cx, 2000
newint9s3:
inc byte ptr es:[di]
add di, 2
loop newint9s3
newint9ret:
pop di
pop cx
pop es
pop ax
iret


;-------------------------------------------------------------------
; end of the payload program
;-------------------------------------------------------------------
db 'payload by bingshuizhilian @ 20200303 : end'
payloadend:
nop

code ends
end start