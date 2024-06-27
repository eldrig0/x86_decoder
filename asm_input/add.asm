bits 16

add bx, [bx+si]
add bx, [bp]
; add si, 2
; add bp, 2
; add cx, 8
; add bx, [bp + 0]
; add cx, [bx + 2]
; add bh, [bp + si + 4]
; add di, [bp + di + 6]
; add [bx+si], bx
; add [bp], bx
; add [bp + 0], bx
; add [bx + 2], cx
; add [bp + si + 4], bh
; add [bp + di + 6], di
add byte [bx], 34
add word [bp + si + 1000], 29
; add ax, [bp]
; add al, [bx + si]
; add ax, bx
; add al, ah
; add ax, 1000
; add al, -30
; add al, 9
