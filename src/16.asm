; p172  实验7 - 寻址方式在结构化数据中的应用

assume cs:code, ds:data, ss:stack

; db->     1字节、8位     ;define byte
; dw->1字、2字节、16位    ;define word
; dd->2字、4字节、32位    ;define double word
; dq->4字、8字节、64位    ;define quad word
; dt->    10字节、80位    ;define ten bytes

data segment
year     db '1975','1976','1977','1978','1979','1980','1981'
		 db '1982','1983','1984','1985','1986','1987','1988'
		 db '1989','1990','1991','1992','1993','1994','1995'
income   dd 16,22,382,1356,2390,8000,16000,24486,50065,97479,140417,197514
		 dd 345980,590827,803530,1183000,1843000,2759000,3753000,4649000,5937000
employee dw 3,7,9,13,28,38,130,220,476,778,1001,1442,2258,2793,4037,5635,8226
         dw 11542,14430,15257,17800
data ends

table segment
tbl db 23 dup ('year sumn ne ?? ')
table ends

stack segment
db 16 dup (0)
stack ends

code segment
start:
mov ax, data
mov ds, ax
mov ax, table
mov es, ax
mov ax, stack
mov ss, ax
mov sp, 10h

xor bx, bx
xor si, si
mov di, offset tbl+10h
mov cx, 21
s:
; year
; mov al, year[bx][0]
; mov es:[di], al
; mov al, year[bx][1]
; mov es:[di+1], al
; mov al, year[bx][2]
; mov es:[di+2], al
; mov al, year[bx][3]
; mov es:[di+3], al

mov ax, word ptr year[bx][0]
mov es:[di], ax
mov ax, word ptr year[bx][2]
mov es:[di+2], ax

; income
mov ax, word ptr income[bx][0]
mov es:[di+5], ax
mov ax, word ptr income[bx][2]
mov es:[di+7], ax

; employee
mov ax, employee[si]
mov es:[di+0ah], ax

; average
mov ax, word ptr income[bx][0]
mov dx, word ptr income[bx][2]
div word ptr employee[si]
mov es:[di+0dh], ax

; end flag
mov al, '#'
mov es:[di+0fh], al

add bx, 4
add si, 2
add di, 10h
loop s


mov ax, 4c00h
int 21h
code ends

end start