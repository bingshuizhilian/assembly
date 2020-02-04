; 第9章 - jmp转移指令的原理

; 关于jmp更详尽的实现原理，请参考《p330-附注3 汇编编译器(masm.exe)对jmp的相关处理》

; 注：jmp指令机器码：EB xx->短转移(jmp short addr)；E9 xx xx->近转移(jmp near ptr addr)；EA xx xx xx xx->远转移(jmp far ptr addr)

; 一、向前转移
;   向前转移时因为前面的转移标号已经被编译器记录过，故在后面转移时能直接计算出转移距离disp(下同)，disp = 后偏移地址 - 前偏移地址
; 1、disp能用1个字节表示(-128~127)
;   此时jmp addr、jmp short addr、jmp near ptr addr、jmp far ptr addr均转变为jmp short addr的机器码：EB xx (即：EB 一字节偏移地址)
; 2、disp超出8bit范围要用2个字节(near)或4个字节(far)表示(-32768~32767)
;   (1)此时jmp short addr编译出错，因为短转移只能寻址-128~127个指令字节
;   (2)此时jmp addr、jmp near ptr addr均产生jmp near ptr addr的机器码：E9 xx xx (即：E9 两字节偏移地址)
;   (3)此时jmp far ptr addr产生自身的的机器码：EA xx xx xx xx (即：EA 两字节偏移地址 两字节段地址)
; 
; 二、向后转移
;   向后转移时因为编译器还没读到后面的转移标号位置，所以这个时刻还不能计算disp，但需要根据jmp指令的类型预留偏移地址存储
; 空间(1、2或4字节的nop指令，nop指令的机器码为0x90)：
;    a. jmp short addr           : EB 90
;    b. jmp s、jmp near ptr addr : EB 90 90
;    c. jmp far ptr addr         : EB 90 90 90 90
; 1、向后读到转移标号时，若disp能用1个字节表示(-128~127)
;   此时jmp addr、jmp short addr、jmp near ptr addr、jmp far ptr addr均在jmp指令处填写jmp short addr的机器码：EB xx，
; 即前面所述的a、b、c均将指令码开头的EB 90替换为EB xx，注意此时b中还会有一条nop指令位于第3个字节，同理c中3-5字节也为nop指令
; 2、向后读到转移标号时，若disp超出8bit范围要用2个字节(near)或4个字节(far)表示(-32768~32767)
;   (1)此时jmp short addr编译出错，因为短转移只能寻址-128~127个指令字节
;   (2)此时jmp addr、jmp near ptr addr均产生jmp near ptr addr的机器码：E9 xx xx，即前面所述的b中EB 90 90替换为E9 xx xx
;   (3)此时jmp far ptr addr产生自身的的机器码：EA xx xx xx xx，即前面所述的c中EB 90 90 90 90替换为EA xx xx xx xx


; p329-附注2 补码：
; 正数的补码是自身
; 负数的补码是对应的正数按位取反后加1
; 推论：负数的补码按位取反加1后，为其绝对值。如F6为内存中某负数的补码，则其值为"-(~0xf6+1) = -0x0aH = -10D"

assume cs:code, ds:data, ss:stack

data segment
db 16 dup (0)
data ends

stack segment
db 16 dup (0)
stack ends

code segment
start:
inc ax
jmp s0
; 向前转移，下面4句均按jmp short xx处理，机器码占两字节，即EB xx
jmp start
jmp short start
jmp near ptr start
jmp far ptr start
mov bx, 3

s0:
inc bx
;下面几句是向后转移
;jmp short s1     ; 开启下面的tmp后，此句短转移编译不通过，因为短转移只能寻址-128~127个指令字节
jmp near ptr s1  ; debug观察开启、关闭下面的tmp后的机器码，它是以下个指令的起始字节为起点计算偏移
jmp far ptr s1   ; debug观察开启、关闭下面的tmp后的机器码，它是以cs代码段起始字节为起点计算偏移

tmp:
db 256 dup (0)

s1:
mov ax, 4c00h
int 21h
code ends

end start