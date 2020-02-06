; p206 实验10 - 2.解决除法溢出的问题

; 题目：计算1000000/10 (即F4240H/0AH)

; X: 被除数，0~FFFFFFFFH
; N: 除数，0~FFFFH
; H: X的高16位，0~FFFFH
; L: X的低16位，0~FFFFH
; int(): 描述性运算符，取商
; rem(): 描述性运算符，取余数

; 公式：X/N = int(H/N)*65536 + [rem(H/N)*65536+L]/N
;   -->注：X=M*65536+N理解为X是32位的，高16位是M(存入dx)，低16位是N(存入ax)，不涉及乘法运算

assume cs:code, ss:stack

stack segment
dw 16 dup (0)
stack ends

code segment
start:
mov ax, stack
mov ss, ax
mov sp, 20h

mov ax, 4240h
mov dx, 0fh
mov cx, 37 ; 0ah
call divdw

mov ax, 4c00h
int 21h

; 名称：divdw
; 功能：进行不会产生溢出的除法运算，被除数为dword型，除数为word型，结果为dword型
; 参数：(ax)=dword型数据的低16位，(dx)=dword型数据的高16位，(cx)=除数
; 返回：(dx)=结果的高16位，(ax)=结果的低16位
divdw:
push bp
mov bp, sp

push ax            ; L-X的低16位: bp-2
mov ax, dx         ; H送入ax
xor dx, dx         ; 清空dx，否则被除数不正确
div cx

push ax            ; int(H/N): bp-4，此值就是最终应送入dx的结果
mov ax, ss:[bp-2]  ; 此时dx中已是rem(H/N), 把L送入ax即可
div cx

mov cx, dx         ; 余数送入cx
pop dx             ; 此时ax中已是int([rem(H/N)*65536+L]/N), 把int(H/N)送入dx即可

mov sp, bp
pop bp
ret

code ends
end start