; p187 实验9 - 按要求显示字符

; 题目：在屏幕中间分别显示黑底绿色、绿底红色、白底蓝色的 'welcome to masm!'

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


assume cs:code, es:data, ss:stack

data segment
db 'welcome to masm!'
attr db 02h, 24h, 71h, 8ah, 0ach, 0f9h
data ends

stack segment
db 16 dup (0)
stack ends

code segment
start:
mov ax, data
mov es, ax                    ; es指向源数据data
mov ax, 0b800h
mov ds, ax                    ; ds指向显示缓冲区
mov ax, stack
mov ss, ax
mov sp, 10h

mov si, offset attr           ; si保存颜色的偏移量
mov bx, 160 * (25 / 2 - 3)    ; 从第N+1行(0为起点)开始显示
mov cx, 6                     ; 要显示的行数
s:
mov ah, es:[si]               ; ah存颜色，内循环直接操作al后将ax送入缓冲区即可
push si                       ; 内循环也要用si，将其暂存到栈中
xor si, si                    ; 字符取值步进值
xor di, di                    ; 显示缓冲区步进值

push cx
mov cx, 16                    ; 示例data共16个字符
s2:
mov al, es:[si]
mov [160/2-16*2/2+bx+di], ax
inc si
add di, 2
loop s2
pop cx

add bx, 0a0h                  ; 转到显示缓冲区下一行
pop si                        ; 从栈中取出颜色偏移量
inc si                        ; 取下一个颜色
loop s

deadloop:
jmp deadloop

mov ax, 4c00h
int 21h

code ends
end start