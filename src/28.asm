; p234 实验11 - 编写子程序

; 题目：将包含任意字符，以0结尾的字符串中的小写字母转变成大写字母(额外功能：显示在屏幕上)


; 宏定义
BUFFER_SIZE           equ 256 ; 字符串缓存空间大小
ROW_START             equ 12  ; 要显示的第一个字符的起始行，调整此值后显示内容整体偏移
COLUMN_START          equ 0eh ; 要显示的第一个字符的起始列，调整此值后显示内容整体偏移
DISP_COLOR            equ 0ah ; 年份列的显示颜色


assume cs:code, ds:data, ss:stack

data segment
db "Beginner's All-purpose Symbolic Instruction Code.", 0
data ends

buffer segment
db BUFFER_SIZE dup (0)
buffer ends

stack segment
dw 32 dup (0)
stack ends

code segment
start:
mov ax, data
mov ds, ax
mov ax, buffer
mov es, ax
mov ax, stack
mov ss, ax
mov sp, 40h

call copynbytes
call letterc
mov dh, ROW_START
mov dl, COLUMN_START
mov cl, DISP_COLOR
call show_str
call clear_buf


; 程序退出
mov ax, 4c00h
int 21h


; 名称：copynbytes
; 功能：将源地址处以0结尾的字符串拷贝至目标地址处
; 参数：ds:si指向字符串首地址，es:di指向目标字符串首地址，拷贝长度是宏定义BUFFER_SIZE
; 返回：无
; 说明：实际拷贝了BUFFER_SIZE个字节，所以源字符串结尾0后面的字节也被拷贝至缓冲区了，但不影响本实验的显示
copynbytes:
push ax
push cx
push ds
push si
push es
push di

mov ax, data
mov ds, ax
mov ax, buffer
mov es, ax

xor si, si
xor di, di

mov cx, BUFFER_SIZE
cld
rep movsb

pop di
pop es
pop si
pop ds
pop cx
pop ax
ret


; 名称：letterc
; 功能：将以0结尾的字符串中的小写字母变成大写字母
; 参数：ds:si指向字符串首地址
; 返回：无
letterc:
push cx
push ds
push si

mov cx, buffer
mov ds, cx
xor si, si

letterc_s:
xor ch, ch
mov cl, [si]
cmp cl, 0
je letterc_over
cmp cl, 61h
jb letterc_next
cmp cl, 61h+19h
ja letterc_next

and byte ptr [si], 11011111b

letterc_next:
inc si
loop letterc_s

letterc_over:
pop si
pop ds
pop cx
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
push ds

mov ax, buffer
mov ds, ax

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
pop ds
pop di
pop si
pop cx
pop es
pop bx
pop ax
ret


; 名称：clear_buf
; 功能：清空显示buffer区
; 参数：无
; 返回：无
clear_buf:
push ax
push cx
push ds
push si

mov ax, buffer
mov ds, ax

xor si, si
mov cx, BUFFER_SIZE
clear_buf_s:
mov [si], byte ptr 0h
inc si
loop clear_buf_s

pop si
pop ds
pop cx
pop ax
ret


code ends
end start