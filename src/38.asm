; p291 检测点16.2

; 题目：下面的程序将data段中a处的8个数据累加，结果存储到b处的字中，补全程序

; tip1：后面带“:”的地址标号，只能在代码段中使用，不能在其他段中使用
; tip2：如果想在代码段中直接用数据标号访问数据，则需要用伪指令assume将标号所在的段和一个段寄存器联系起来，这是给编译器提供的信息
; tip3：体会第16章主题：“直接定指表”的使用

assume cs:code, es:data, ss:test1  ; 这句是给编译器的指示，编译器把es和data段关联起来，影响编译出来的指令

data segment
a db 1,2,3,4,5,6,7,8  ; 在下面使用mov al, a[si]时，编译器自动将a和es关联起来，实际编译出的指令为mov al, es:[si+0000]，0000实际为a的偏移量，视a的位置而变化
b dw 0
e db 0
data ends

test1 segment
c db 0
test1 ends

test2 segment
d db 0
test2 ends

code segment
start:
mov ax, data  ; 这两句是cpu要执行的指令，执行完es指向data段
mov es, ax

; 深入理解下面这几句测试指令，查看注释中的编译结果，体会assume、标号、段寄存器之间的关系
mov al, ds:a[si]  ; mov al, [si+0000]
mov al, ds:e[si]  ; mov al, [si+000a]
mov al, a[si]     ; mov al, es:[si+0000]
mov al, e[si]     ; mov al, es:[si+000a]
mov al, a         ; mov al, es:[0000]
mov al, [si]      ; mov al, [si]

mov al, c[si]     ; mov al, ss:[si+0000]
mov al, ds:d[si]  ; mov al, [si+0000]
mov al, es:c[si]  ; mov al, es:[si+0010]，这里的0010及下面的0020是段内数据的字节对齐影响的，一个段内的字节数应为16N(N≥1)
mov al, es:d[si]  ; mov al, es:[si+0020]

mov al, byte ptr c[si]     ; mov al, ss:[si+0000]
mov al, byte ptr ds:d[si]  ; mov al, [si+0000]
mov al, byte ptr es:c[si]  ; mov al, es:[si+0010]
mov al, byte ptr es:d[si]  ; mov al, es:[si+0020]
; mov al, byte ptr d[si]   ; 编译不通过，因为没有使用assume来把数据标号d和某个段寄存器关联起来

; 题目功能实现
mov ax, data
xor si, si
mov cx, 8
s:
mov al, a[si]
mov ah, 0
add b, ax
inc si
loop s


; 主程序退出
mov ax, 4c00h
int 21h

code ends
end start