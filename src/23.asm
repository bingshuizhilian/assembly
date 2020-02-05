; p206 实验10 - 1.显示字符串

; 准备知识 - 80x25彩色字符模式显示缓冲区(每行80个字符，25行)
; 1. 显示缓冲区地址：B8000H~BFFFFH共32KB空间，向这个地址空间写入数据将立即出现在显示器上
; 2. 一个字符在显示缓冲区占2个字节，低地址(必是偶数)存在字符的accii码，高地址(必是奇数)存在字符的属性码
; 3. 显示缓冲区分8页，每页4KB，显示器可显示任意一页，一般显示第0页，即B8000H~B8F9FH中的4000个字节
; 4. 一行 = 80个字符 = 160个字节 = 0xA0个字节，第N行起始地址ADDR的偏移量为 ADDR = 160 * (N - 1)
; 5. 属性字节的格式
;   7      6 5 4    3     2 1 0    (bit)
;   BL     R G B    I     R G B    (属性)
;   闪烁   背景色   高亮  前景色   (释义)
;   -->注：rgb均为0时表示黑色，全为1时表示白色


; 题目：在屏幕第8行第3列，用绿色显示data段中的字符串

assume cs:code, ds:data, ss:stack

data segment
db 'Welcome to masm!', 0
data ends

stack segment
dw 16 dup (0)
stack ends

code segment
start:
mov dh, 8 ; 24
mov dl, 3 ; 60
mov cl, 2 ; 0ach
mov ax, data
mov ds, ax
mov ax, stack
mov ss, ax
mov sp, 20h
mov si, 0
call show_str


mov ax, 4c00h
int 21h

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