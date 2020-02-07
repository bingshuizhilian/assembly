; p233 检测点11.4

; 题目：程序执行后，(ax)=?


; pushf : 将标志寄存器的值压栈
; popf  : 从栈中弹出数据，送入标志寄存器中

; 8086CPU的16bit标志(flag)寄存器的结构图，其中的7个空白位不具有任何含义
; flag : __ __ __ __ OF DF IF TF | SF ZF __ AF __ PF __ CF
; bit  : 15 14 13 12 11 10  9  8 |  7  6  5  4  3  2  1  0

; DEBUG中常用标志位的表示方法
; 标志  : of df if sf zf pf cf
; 值为1 : OV DN EI NG ZR PE CY
; 值为0 : NV UP DI PL NZ PO NC

; AF : 辅助进位标志位，运算过程中看最后四位，不论长度为多少。最后四位向前有进位或者借位，AF=1,否则AF=0，多见于bcd码运算
; TF : 跟踪标志位
;   --> TF=1，机器进入单步工作方式，每条机器指令执行后，显示结果及寄存器状态
;   --> TF=0，机器处在连续工作方式，此标志为调试机器或调试程序发现故障而设置


assume cs:code
code segment
start:
mov ax, 0
push ax
popf               ; flag = 0

mov ax, 0fff0h
add ax, 0010h      ; of=0, sf=0, zf=1, pf=1, cf=1
pushf              ; flag = 45h

pop ax             ; ax=45h
and al, 11000101b  ; al=01000101b=45h，of=0
and ah, 00001000b  ; ah=0
				   ; 最终: ax=0045h

; 程序退出
mov ax, 4c00h
int 21h

code ends
end start