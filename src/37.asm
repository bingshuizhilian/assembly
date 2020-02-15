; p289 检测点16.1

; 题目：下面的程序将code段中a处的8个数据累加，结果存储到b处的双字中，补全程序

; tip1：地址标号后面带“:”，不能表示数据尺寸，数据标号后面不带“:”，其默认数据尺寸视b后面的db、dw等而定
; tip2：无论地址标号或数据标号c后面是db、dw、dd等任何修饰符，c+1都表示c后面的第一个字节，而不是按dw、dd等移动2个字节或4个字节
;       如c dw 1,2,3,4,5,6,7,8，则c+1表示0200h(数据地址是c+1，数据长度是word)，byte ptr c+1表示00h(数据地址是c+1，数据长度是byte)


assume cs:code, ds:data1, es:data2

data1 segment
u1 db 1,2,3,4,5,6,7,8
v1 dw 0
w1 dw u1, v1    ; 和下面的w2是等效的，用dw即word长度存储标号时，存储的是标号的偏移地址(相对于标号所在的段)
x1 dd u1, v1    ; 和下面的x2是等效的，用dd即double word长度存储标号时，存储的是标号的偏移地址、段地址(偏移地址在低位，且他是相对于标号所在的段的偏移地址)
; y1 db u1, v1  ; 编译不通过，不能用db即byte长度来存储标号
data1 ends

; data1内存dump
; 1CA5:0000 01 02 03 04 05 06 07 08-00 00 00 00 08 00 00 00
; 1CA5:0010 A5 1C 08 00 A5 1C 00 00-00 00 00 00 00 00 00 00

data2 segment
u2 db 1,2,3,4,5,6,7,8
v2 dw 0
w2 dw offset u2, offset v2
x2 dw offset u2, seg u2, offset v2, seg v2
data2 ends

; data2内存dump
; 1CA5:0020 01 02 03 04 05 06 07 08-00 00 00 00 08 00 00 00
; 1CA5:0030 A7 1C 08 00 A7 1C 00 00-00 00 00 00 00 00 00 00

code segment
a:db 1,2,3,4,5,6,7,8
b db 8,7,6,5,4,3,2,1
c dw 1,2,3,4,5,6,7,8
d dd 01020304h, 05060708h
e dd 0
start:
; 测试data1、data2的设置
mov ax, data1
mov ds, ax
mov ax, data2
mov es, ax

; 加深理解标号及数据长度，以及类似c+2这种标号+步进值中的步进值含义
; mov ah, a ; 编译错误，a为地址标号，不包含数据长度信息
mov ah, byte ptr a[1]
mov ax, word ptr a[0]
mov bh, b
mov bx, word ptr b[1]
mov cx, word ptr c[1]
mov dh, byte ptr c+2
; mov dh, c ; 编译错误，c的数据长度为word，需要用16位reg来接收
mov dx, c+3
; mov ax, d ; 编译错误，d的数据长度为double word，需要用32位reg来接收，而8086处理器没有32位reg
mov ah, byte ptr d+1
mov ax, word ptr d+3


; 书中的题目，由于上面有些许变化，固题目变为c中8个数据相加，结果存到e中
xor si, si
mov cx, 8
s:
mov ax, c[si]
add word ptr e[0], ax
adc word ptr e[2], 0
add si, 2
loop s


; 主程序退出
mov ax, 4c00h
int 21h

code ends
end start