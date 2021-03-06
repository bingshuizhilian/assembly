; p312 课程设计2 - boot

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


; 说明：笔者已经在vmware15.5.1下安装msdos7.1和虚拟软盘测试环境进行了实际测试，可以正常使用


assume cs:code, ss:stack

stack segment
db 128 dup (0)
stack ends

code segment
start:
mov ax, stack
mov ss, ax
mov sp, 128

call bootwriter

; 主程序退出
mov ax, 4c00h
int 21h

;-------------------------------------------------------------------
; bootwriter
; 把bootloader写到0面0道1扇区
;-------------------------------------------------------------------
bootwriter:
push cs
pop es
mov bx, offset bootloader

mov al, 1 ; 读/写的扇区数量
mov ch, 0 ; 磁道号
mov cl, 1 ; 扇区号
mov dl, 0 ; 驱动器号
mov dh, 0 ; 磁头号(面号)
mov ah, 3 ; 功能号：3写入、2读取
int 13h

ret

;-------------------------------------------------------------------
; bootloader
; (1) 把位于0面0道2~N扇区的payload写到0:7c00+200，即0:7e00
; (2) 设置cs:ip为0:7e00
; 注意，2~N应和payload中占用的扇区定义的2~N一致
;-------------------------------------------------------------------
bootloader:
jmp bootloaderstart
db 'bootloader by bingshuizhilian @ 20200301 : start'
bootloaderstart:
mov ax, 0
mov es, ax
mov bx, 7e00h

mov al, 3 ; N-1
mov ch, 0
mov cl, 2
mov dl, 0
mov dh, 0
mov ah, 2
int 13h

; 设置cs:ip为0:7e00
push es
push bx
retf

db 'bootloader by bingshuizhilian @ 20200301 : end'
bootloaderend:
nop

code ends
end start