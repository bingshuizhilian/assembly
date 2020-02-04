; p183 检测点9.1-(1)

; 1.1 前面提到过的jmp short addr和jmp near ptr addr的功能为通过段内计算指令偏移地址来实现间接修改IP
; 1.2 前面提到过的jmp far ptr addr的功能为通过直接修改CS:IP来实现段间转移

; 2.1 jmp word ptr [bx]直接修改(IP)=(ds:[bx])实现段内转移
; 2.1 jmp dword ptr [bx]直接修改(IP)=(ds:[bx])、(CS)=(ds:[bx+2])实现段间转移

assume cs:code, ds:data

data segment
;db 0, 0, 0 ; 跳到start
;db 0, 3, 0 ; 跳到tag
db 0, 5, 0 ; 跳到tag2
data ends

code segment
start:
mov ax, data  ; 3 bytes
tag:
mov ds, ax    ; 2 bytes
tag2:
mov bx, 0     ; 3 bytes

jmp word ptr [bx+1]

mov ax, 4c00h
int 21h
code ends

end start