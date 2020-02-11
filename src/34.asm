; p263 实验13 - 编写、应用中断例程 - (3)

; 题目：下面的程序，分别在屏幕的第2、4、6、8行显示4句英文诗，补全程序

assume cs:code

code segment
s1 :  db 'Good,better,best,', '$'
s2 :  db 'Never let it rest,', '$'
s3 :  db 'Till good is better,', '$'
s4 :  db 'And better,best.', '$'
s  :  dw offset s1, offset s2, offset s3, offset s4
row:  db 2,4,6,8,20
start:
mov ax, cs
mov ds, ax
mov bx, offset s
mov si, offset row

mov cx, 4
ok:
; int 10h @ #2，设置光标，10号中断类型码：bios中断例程->2号子程序
mov ah, 2          ; 设置光标，ah为子程序号
mov bh, 0          ; 显示第0页
mov dh, [si]       ; 行号
mov dl, 30         ; 列号
int 10h

; int 21h @ #9，显示以'$'结尾的字符串，21号中断类型码：dos中断例程->9号子程序
mov dx, [bx]       ; ds:dx指向字符串
mov ah, 9          ; 在光标位置显示字符串，ah为子程序号
int 21h

add bx, 2
inc si
loop ok

; 下面是自己添加的内容
; (1)int 10h @ #2，功能上面已经介绍了
mov ah, 2
mov bh, 0
mov dh, [si]
mov dl, 30
int 10h
; (2)int 10h @ #9，在光标位置显示字符，10号中断类型码：bios中断例程->9号子程序
mov ah, 9          ; 在光标位置显示字符，ah为子程序号
mov al, 'a'        ; 字符
mov bl, 11001010b  ; 颜色属性
mov bh, 0          ; 显示第0页
mov cx, 3          ; 字符重复个数
int 10h

; 主程序退出
mov ax, 4c00h
int 21h

code ends
end start