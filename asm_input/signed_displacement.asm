bits 16
; Signed displacements
mov ax, [bx + di + 37]
mov [si + 32767], cx
mov dx, [bx - 32]
