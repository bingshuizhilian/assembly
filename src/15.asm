; p171  问题8.1 - div及db、dw、dd

assume cs:code, ds:data

; db->     1字节、8位     ;define byte
; dw->1字、2字节、16位    ;define word
; dd->2字、4字节、32位    ;define double word
; dq->4字、8字节、64位    ;define quad word
; dt->    10字节、80位    ;define ten bytes
data segment
a dd 100001
b dw 100
c dt 2 dup (112233445566778899aah) ; 观察内存布局
d dw 4 dup (0aa55h) ; 观察内存布局，此处会产生字节对齐
data ends

code segment
start:
mov ax, data
mov ds, ax

; mov ax, ds:[0] ; mov ax, [0000]
; mov dx, ds:[2] ; mov ax, [0002]
; mov bx, ds:[4]
; div bx
; mov ds:[6], ax ; ds:[6]=0x03e8


; 和上面注释的代码含义一致
mov si, offset a
mov ax, ds:[si]     ; 寄存器间接寻址：只有bx、si、di、bp可以用作index或base register
mov si, offset a[2] ; a+2
mov dx, [si]        ; 省略段前缀则默认使用ds，bp省略段前缀时默认使用ss
div b               ; = div word ptr ds:[4]
mov d+3*2, ax       ; c=0x03e8


mov ax, 4c00h
int 21h
code ends

end start