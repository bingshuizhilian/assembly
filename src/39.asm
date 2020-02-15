; p299 实验16 - 编写包含多个功能子程序的中断例程 - 安装程序

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
push cs
pop ds
mov si, offset setscreen
mov ax, 0
mov es, ax
mov di, 200h

; 安装中断程序
mov cx, offset setscreenend - offset setscreen
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


; 名称：setscreen
; 功能：7ch号中断处理程序，完成题目要求的四个功能
; 参数：(1)用ah寄存器传递功能号：0表示清屏，1表示设置前景色，2表示设置背景色，3表示向上滚动一行
;       (2)对于1、2号功能，用al传送颜色值，(al)∈{0,1,2,3,4,5,6,7}
; 返回：无
setscreen:
jmp short set  ; 机器码为EB xx, 两个字节
; 调用方式一
table dw sub1, sub2, sub3, sub4  ; 由于在安装程序里写了assume cs:code，所以table[X]本质上是 cs:N[X]

; 调用方式二、三
; table dw offset sub1 - offset setscreen + 200h  ; 21dh-200h+200h
      ; dw offset sub2 - offset setscreen + 200h  ; 237h-200h+200h
      ; dw offset sub3 - offset setscreen + 200h  ; 255h-200h+200h
      ; dw offset sub4 - offset setscreen + 200h  ; 277h-200h+200h

set:
push bx  ; 方式一、二、三均使用
push cx  ; 仅方式一使用
push si  ; 仅方式一、二使用
cmp ah, 3
ja setret
xor bh, bh
mov bl, ah
add bx, bx  ; 偏移地址为word型

; 调用方式一
  ; 在安装程序中，标签都是相对于start计算的，而实际中断例程中要根据setscreen计算相对于200h的偏移量，所以先计算start - setscreen，是个负值
mov si, offset start - offset setscreen
  ; 由于在安装程序里写了assume cs:code，table会自动和cs关联，所以可以省略段前缀cs
  ; table+si其实就是table-setscreen，这里根据bx值取出子程序标号sub1，存入cx
mov cx, [200h+table+si+bx]
  ; 因为标号sub1等表示的偏移量也是相对于start计算的，所以也要减去start到setscreen的距离，即加上si，这时cx的值就是sub1相对于setscreen的偏移量
add cx, si
  ; 最后，因为中断例程安装在0:200h中，所以还要加上200h的偏移量
add cx, 200h
call cx

; 调用方式二
; mov si, offset start - offset setscreen  ; 这里的原理和方式一相同，table+si将原本的table是相对于start计算的，转化为table是相对于setscreen计算的了
; call word ptr [200h+table+si+bx]         ; 方式二的table中直接存储了sub1等相对于安装起始地址200h的偏移地址

; 调用方式三
; call word ptr cs:[202h+bx]  ; 注意必须加段前缀cs，否则默认为ds:[202h+bx]; 实际上，202h=200h+table+si=200h+table-setscreen=200h+2h

setret:
pop si
pop cx
pop bx
iret


; 子功能(1)/功能号0：清屏
sub1:
push di
push es
push cx
mov di, 0b800h
mov es, di
xor di, di

mov cx, 2000
sub1s:
mov byte ptr es:[di], ' '
add di, 2
loop sub1s

pop cx
pop es
pop di
ret


; 子功能(2)/功能号1：设置前景色
sub2:
push di
push es
push cx
mov di, 0b800h
mov es, di
mov di, 1

mov cx, 2000
sub2s:
and byte ptr es:[di], 11111000b
or es:[di], al
add di, 2
loop sub2s

pop cx
pop es
pop di
ret


; 子功能(3)/功能号2：设置背景色
sub3:
push di
push es
push cx
mov di, 0b800h
mov es, di
mov di, 1

mov cl, 4
shl al, cl

mov cx, 2000
sub3s:
and byte ptr es:[di], 10001111b
or es:[di], al
add di, 2
loop sub3s

pop cx
pop es
pop di
ret


; 子功能(4)/功能号3：向上滚动一行
sub4:
push di
push es
push cx
push ds
push si

mov di, 0b800h
mov es, di
mov ds, di

xor di, di
mov si, 160
cld

mov cx, 24
sub4s:
push cx
mov cx, 160
rep movsb
pop cx
loop sub4s

mov di, 160*24
mov cx, 80
sub4s2:
mov byte ptr es:[di], ' '
add di, 2
loop sub4s2

pop si
pop ds
pop cx
pop es
pop di
ret

setscreenend:
nop

code ends
end start