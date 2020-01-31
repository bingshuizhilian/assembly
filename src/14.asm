; p158  问题7.9 - 每行前四个纯字母变为大写



; 为了运用所有的内存空间，8086设定了四个段寄存器，专门用来保存段地址：
; CS（Code Segment）：代码段寄存器；
; DS（Data Segment）：数据段寄存器；
; SS（Stack Segment）：堆栈段寄存器；
; ES（Extra Segment）：附加段寄存器。
; 当一个程序要执行时，就要决定程序代码、数据和堆栈各要用到内存的哪些位置，通过设定段寄存器 CS，DS，SS 来指向这些起始位置。
;通常是将DS固定，而根据需要修改CS。所以，程序可以在可寻址空间小于64K的情况下被写成任意大小。

; 要用assume把段跟段寄存器对应起来的原因是原来的DOS找到的空闲内存的地址不是固定的，无法找到一个地址在任何时候都是空闲的。于是DOS需要可以重定位的程序，
; 而当时的定位方式就是设置段寄存器的值使该程序能在可分配（空闲）的内存中可用。那就需要知道某个段被重定位时候需要修改哪个段寄存器的值才能正确执行。
; assume提供这种段和重定位代码时需要对应修改的寄存器的关系给编译器，编译器再这个信息写到二进制文件中去。比如DOS下的exe程序记录在文件头中。

; 任何段寄存器都不能直接赋值 这是规定 不要管他有没有意义 你理解成C的函数声明就OK 作用就是找到它的地址

assume cs:code, ds:data, ss:stack  ; 这里只是为了汇编编译器建立一个联系，实际还要在代码中设置才影响运行时的状态

stack segment
dw 16 dup (0)
stack ends

data segment
db '1. display      '
db '2. brows        '
db '3. replace      '
db '4. modify       '
data ends

code segment
start:
mov ax, data
mov ds, ax
mov ax, stack
mov ss, ax     ; 为什么ds、ss需要设置而cs不需要：因为编译器把CS:IP写入了dos头的描述信息中
mov sp, 10h
mov bx, 0
mov si, 0

mov cx, 4
s:
push cx
mov si, 0

mov cx, 4
s2:
mov al, 3[bx][si]
and al, 11011111b
mov 3[bx][si], al
inc si
loop s2

pop cx
add bx, 10h
loop s

mov ax, 4c00h
int 21h
code ends

end start