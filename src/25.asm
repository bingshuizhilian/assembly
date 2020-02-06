; p209 实验10 - 3.数值显示

; 题目：将数据12666以十进制的形式在屏幕的8行3列用绿色显示出来

assume cs:code, ds:data, ss:stack

data segment
db 16 dup (0)
data ends

stack segment
dw 32 dup (0)
stack ends

code segment
start:
mov ax, data
mov ds, ax
mov ax, stack
mov ss, ax
mov sp, 40h

mov ax, 12666
mov si, 0
mov di, 0 ; dtoc需要使用di，dtoc2不使用
call dtoc2

mov dh, 8
mov dl, 3
mov cl, 8ah
call show_str


mov ax, 4c00h
int 21h

; 名称：dtoc
; 功能：将word型数据转变为表示十进制数的字符串，字符串以0为结尾符
; 参数：(ax)=word型数据，ds:si指向字符串首地址
; 返回：无
dtoc:
push bx
push cx
push dx
push si
push di

mov bx, 0aa55h
push bx
mov bx, 10

dtoc_payload:
xor dx, dx
div bx
mov cx, dx
jcxz dtoc_reverse
add dl, 30h
push dx

inc si
jmp dtoc_payload

dtoc_reverse:
pop cx
mov dx, cx
sub cx, 0aa55h
jcxz dtoc_ok

mov [di], dl
inc di
jmp dtoc_reverse

dtoc_ok:
pop di
pop si
pop dx
pop cx
pop bx
ret

; 名称：dtoc2
; 功能：同dtoc，优化算法
; 参数：(ax)=word型数据，ds:si指向字符串首地址
; 返回：无
dtoc2:
push bx
push cx
push dx
push si

mov bx, 10

dtoc2_s:
xor dx, dx
div bx
mov cx, ax   ; 方法2a: (mov cx, dx)，用余数dx监视循环结束，会比监视商ax要多一次循环，且栈顶多放了一个数据0，要使用方法2b消除这种影响
add dl, 30h
push dx

inc si
inc cx
loop dtoc2_s

; pop cx     ; 方法2b: 和方法2a配合使用，栈顶多出的数据0要出栈，且循环次数要减1。方法2的结论是：没有直接监视商ax方便
; dec si
mov cx, si
xor si, si
dtoc2_s2:
pop [si]     ; 一个字符只占1字节，而pop操作的是16bit数据，这么处理可行的原因是push dx时，dh=0，dl=字符数据，(未完，转下行注释)
inc si       ; 而si每次只加1，因此data段内存中存入的数据形式为dl dl ... dl dh，也恰好就是一个以0结尾的字符串
loop dtoc2_s2


pop si
pop dx
pop cx
pop bx
ret


; 名称：show_str
; 功能：在指定的位置，用指定的颜色，显示一个用0结束的字符串
; 参数：(dh)=行号(取值范围0~24)，(dl)=列号(取值范围0~79)，(cl)=颜色，ds:si指向字符串首地址
; 返回：无
show_str:
push ax
push bx
push es
push cx
push si
push di

; 显示缓冲区
mov ax, 0b800h
mov es, ax
xor si, si

; 行号存入bx
mov ah, 0
mov al, 0a0h
mul dh
mov bx, ax

; 列号存入di
mov ah, 0
mov al, 2
mul dl
mov di, ax

; 颜色存入ah
mov ah, cl

payload:
mov cl, [si]
xor ch, ch
jcxz ok

; 字符存入al
mov al, [si]
mov es:[bx+di], ax

inc si
add di, 2
jmp payload

ok:
pop di
pop si
pop cx
pop es
pop bx
pop ax
ret

code ends
end start