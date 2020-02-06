; p211 课程设计1

; 题目：将实验7中的Power idea公司的数据按指定格式在屏幕显示出来


; 宏定义
BUFFER_SIZE           equ 16  ; 字符串缓存空间大小
ROW_START             equ 2   ; 要显示的第一个字符的起始行，调整此值后显示内容整体偏移
COLUMN_START          equ 15  ; 要显示的第一个字符的起始列，调整此值后显示内容整体偏移
COLUMN_INTERVAL       equ 15  ; 列间距
COLUMN_YEAR_COLOR     equ 0ah ; 年份列的显示颜色
COLUMN_INCOME_COLOR   equ 8ch ; 收入列的显示颜色
COLUMN_EMPLOYEE_COLOR equ 89h ; 员工数量列的显示颜色
COLUMN_AVERAGE_COLOR  equ 8ah ; 人均收入列的显示颜色


assume cs:code, ds:data, ss:stack

data segment
year     db '1975','1976','1977','1978','1979','1980','1981'
		 db '1982','1983','1984','1985','1986','1987','1988'
		 db '1989','1990','1991','1992','1993','1994','1995'
income   dd 16,22,382,1356,2390,8000,16000,24486,50065,97479,140417,197514
		 dd 345980,590827,803530,1183000,1843000,2759000,3753000,4649000,5937000
employee dw 3,7,9,13,28,38,130,220,476,778,1001,1442,2258,2793,4037,5635,8226
         dw 11542,14430,15257,17800 ; 可将17800替换为10验证大数值除以小数值
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

xor bx, bx
xor si, si
mov dh, ROW_START
mov dl, COLUMN_START
mov cx, 21
s:
; year
mov ax, word ptr year[bx][0]
mov es:[0], ax
mov ax, word ptr year[bx][2]
mov es:[2], ax
push cx
mov cl, COLUMN_YEAR_COLOR
call show_str
pop cx
call clear_buf

; income
push dx
mov ax, word ptr income[bx][0]
mov dx, word ptr income[bx][2]
call dtocw
pop dx
push cx
push dx
add dl, COLUMN_INTERVAL
mov cl, COLUMN_INCOME_COLOR
call show_str
pop dx
pop cx
call clear_buf

; employee
push dx
mov ax, employee[si]
xor dx, dx
call dtocw
pop dx
push cx
push dx
add dl, COLUMN_INTERVAL * 2
mov cl, COLUMN_EMPLOYEE_COLOR
call show_str
pop dx
pop cx
call clear_buf

; average
push bx
push dx
mov ax, word ptr income[bx][0]
mov dx, word ptr income[bx][2]
mov bx, word ptr employee[si]
call divdw  ; 能够处理计算平均值时大数除以小数的情况，不会产生溢出
call dtocw                    
pop dx
pop bx
push cx
push dx
add dl, COLUMN_INTERVAL * 3
mov cl, COLUMN_AVERAGE_COLOR
call show_str
pop dx
pop cx
call clear_buf


inc dh
add bx, 4
add si, 2
loop s

; 程序退出
mov ax, 4c00h
int 21h


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


; 名称：dtocw
; 功能：将dword型数据转变为表示十进制数的字符串，字符串以0为结尾符
; 参数：(ax)=dword型数据的低16位，(dx)=dword型数据的高16位，ds:si指向字符串首地址
; 返回：无
dtocw:
push ax
push bx
push cx
push dx
push si
push di
push ds

mov si, buffer
mov ds, si

mov bx, 10    ; divdw的除数
xor si, si

dtocw_s:
mov di, bx
call divdw
mov cx, dx
cmp cx, 0
jnz dtocw_s_1
mov cx, ax    ; 控制循环次数
dtocw_s_1:
add bl, 30h   ; 除以10后余数只能是0-9，所以bh一定已经是0了
push bx

inc si
inc cx
mov bx, di
loop dtocw_s

mov cx, si
xor si, si
dtocw_s2:
pop [si]     ; 一个字符只占1字节，而pop操作的是16bit数据，这么处理可行的原因是push dx时，dh=0，dl=字符数据，(未完，转下行注释)
inc si       ; 而si每次只加1，因此data段内存中存入的数据形式为dl dl ... dl dh，也恰好就是一个以0结尾的字符串
loop dtocw_s2

pop ds
pop di
pop si
pop dx
pop cx
pop bx
pop ax
ret


; 名称：divdw
; 功能：进行不会产生溢出的除法运算，被除数为dword型，除数为word型，结果为dword型
; 参数：(ax)=dword型数据的低16位，(dx)=dword型数据的高16位，(bx)=除数
; 返回：(dx)=结果的高16位，(ax)=结果的低16位，(bx)=余数
divdw:
push si            ; ax, bx, dx是返回结果，既不需要也不能保护起来

mov si, ax         ; L是X的低16位
mov ax, dx         ; H送入ax
xor dx, dx         ; 清空dx，否则被除数不正确
div bx

push ax            ; int(H/N)，此值就是最终应送入dx的结果
mov ax, si         ; 此时dx中已是rem(H/N), 把L送入ax即可
div bx

mov bx, dx         ; 余数送入bx
pop dx             ; 此时ax中已是int([rem(H/N)*65536+L]/N), 把int(H/N)送入dx即可

pop si
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

code ends
end start