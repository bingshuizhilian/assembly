; p271 实验14 - 访问CMOS RAM

; 题目：编程，以“年/月/日 时:分:秒”的格式，显示当前的日期、时间

; 注意：CMOS RAM中存储着系统的配置信息，除了保存时间信息的单元外，不要像其他的单元中写入内容，否则将引起一些系统错误

; 端口信息：70h为地址端口，71h为数据端口
; 存储位置：秒：0  分：2  时：4  日：7  月：8  年：9

assume cs:code

data segment
datetime db 'YY/MM/DD hh:mm:ss', '$'
memindex   db 9,8,7,4,2,0
data ends

stack segment
db 16 dup (0)
stack ends

code segment
start:
mov ax, data
mov ds, ax
mov ax, stack
mov ss, ax
mov sp, 10h

; 从CMOS RAM中读取时间信息，存储至datetime
mov bx, offset datetime
mov di, offset memindex
mov cx, 6
s:
mov al, [di]
out 70h, al
in al, 71h

push cx
mov ch, al
mov cl, 4
shr ch, cl
add ch, 30h
mov [bx], ch
and al, 0fh
add al, 30h
mov [bx+1], al
pop cx

add bx, 3
inc di
loop s

; int 10h @ #2，设置光标，10号中断类型码：bios中断例程->2号子程序
mov ah, 2          ; 设置光标，ah为子程序号
mov bh, 0          ; 显示第0页
mov dh, 12         ; 行号
mov dl, 32         ; 列号
int 10h

; int 21h @ #9，显示以'$'结尾的字符串，21号中断类型码：dos中断例程->9号子程序
mov dx, 0          ; ds:dx指向字符串
mov ah, 9          ; 在光标位置显示字符串，ah为子程序号
int 21h


; 主程序退出
mov ax, 4c00h
int 21h

code ends
end start