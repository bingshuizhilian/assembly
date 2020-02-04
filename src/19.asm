; p183 检测点9.1-(2)

; 1.1 前面提到过的jmp short addr和jmp near ptr addr的功能为通过段内计算指令偏移地址来实现间接修改IP
; 1.2 前面提到过的jmp far ptr addr的功能为通过直接修改CS:IP来实现段间转移

; 2.1 jmp word ptr [bx]直接修改(IP)=(ds:[bx])实现段内转移
; 2.1 jmp dword ptr [bx]直接修改(IP)=(ds:[bx])、(CS)=(ds:[bx+2])实现段间转移

assume cs:code, ds:data

data segment
dd 12345678h
data ends

code segment
start:
mov ax, data
mov ds, ax
mov bx, 0
mov [bx], bx ; IP
mov [bx+2], cs ; CS

jmp dword ptr ds:[0]

mov ax, 4c00h
int 21h
code ends

end start