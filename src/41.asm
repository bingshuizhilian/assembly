; p310 实验17 - 编写包含多个功能子程序的中断例程

; 题目：安装一个新的int 7ch中断例程，实现通过逻辑扇区号对软盘进行读写

; tip1：以下描述性内容均3.5英寸软盘为例，它拥有上下两面，每面有80个磁道，每个磁道分为18个扇区，每个扇区的大小为512个字节
; tip2：对位于不同的磁道、面上的所有扇区进行统一编号，编号从0开始，一直到2879，称这个编号为逻辑扇区编号
; tip3：面号和磁道号从零开始编号，扇区号从1开始编号

; 公式：逻辑扇区号 = (面号 * 80 + 磁道号) * 18 + 扇区号 - 1
; 逻辑扇区号(LBA寻址方式)转为物理编号(CHS寻址方式)的方法：
;   int()：描述性运算符，取商
;   rem()：描述性运算符，取余数
;   -> 逻辑扇区号 = (面号 * 80 + 磁道号) * 18 + 扇区号 - 1
;   -> 面号 = int(逻辑扇区号 / 1440)
;   -> 磁道号 = int(rem(逻辑扇区号 / 1440) / 18)
;   -> 扇区号 = rem(rem(逻辑扇区号 / 1440) / 18) + 1

; int 13h为BIOS提供的访问磁盘的中断例程，常用的读写功能的参数为：
; 入口参数：
;   -> (ah)=int i3h的功能号(2表示读扇区、3表示写扇区)
;   -> (al)=读取/写入的扇区数
;   -> (ch)=磁道号
;   -> (cl)=扇区号
;   -> (dh)=磁头号(对于软盘即面号，因为一个面用一个磁头来读写)
;   -> (dl)=驱动器号(软驱从0开始，0：软驱A，1：软驱B；硬盘从80h开始，80h：硬盘C，81h：硬盘D)
;   -> es:bx在读时指向接收从扇区读入数据的内存区，在写时指向将写入磁盘的数据的内存区
; 返回参数：
;   -> 操作成功：(ah)=0，(al)=读取/写入的扇区数
;   -> 操作失败：(ah)=错误码

assume cs:code, ss:stack

stack segment
db 128 dup (0)
stack ends

code segment
start:
mov ax, stack
mov ss, ax
mov sp, 128
push cs
pop ds
mov si, offset floppydiskrw
mov ax, 0
mov es, ax
mov di, 200h

; 安装中断程序
mov cx, offset floppydiskrwend - offset floppydiskrw
cld
rep movsb

; 设置中断向量
cli
mov word ptr es:[7ch*4], 200h
mov word ptr es:[7ch*4+2], 0
sti


; 主程序退出
mov ax, 4c00h
int 21h


; 名称：floppydiskrw
; 功能：7ch号中断处理程序，实现通过逻辑扇区号对软盘进行读写
; 参数：(1)用ah寄存器传递功能号：0表示读，1表示写
;       (2)用dx寄存器传递要读写的扇区的逻辑扇区号
;       (3)用es:bx指向存储读出数据或写入数据的内存区
; 返回：无
floppydiskrw:
cmp ah, 1
ja exit
push ax
push bx
push dx

push bp
mov bp, sp


; 计算(逻辑扇区号 / 1440)
; 计算结果：(ax)=int(逻辑扇区号 / 1440)，(dx)=rem(逻辑扇区号 / 1440)
mov ax, dx
xor dx, dx
mov bx, 1440
div bx
push ax         ; [bp-2]: int(逻辑扇区号 / 1440)

; 计算：rem(逻辑扇区号 / 1440) / 18
; 计算结果：(ax)=int(rem(逻辑扇区号 / 1440) / 18)，(dx)=rem(rem(逻辑扇区号 / 1440) / 18)
mov ax, dx
xor dx, dx
mov bx, 18
div bx

; int 13h参数填写
mov ch, al      ; ->磁道号(从0开始编号)
mov cl, dl      ; ->扇区号(从1开始编号)
inc cl
mov dh, [bp-2]  ; ->磁头号，即面号(从0开始编号)
mov dl, 0       ; 驱动器号(软驱从0开始，0：软驱A)
mov ah, [bp+7]  ; 功能号(int 13h的ah参数中：2为读取，3为写入，而本中断例程中0为读取，1为写入，故加2即可)
add ah, 2
mov al, 1       ; 读取/写入的扇区数
int 13h

pop ax
pop bp
pop dx
pop bx
pop ax
exit:
iret

floppydiskrwend:
nop

code ends
end start