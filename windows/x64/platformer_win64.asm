; 2D Platformer for Windows x64 in Pure Assembly
; Uses Win32 API for window creation and GDI for graphics
; Assembled with NASM, linked with GoLink or MS Link

bits 64
default rel

; Windows Constants
%define WS_OVERLAPPEDWINDOW 0x00CF0000
%define WM_DESTROY 0x0002
%define WM_PAINT 0x000F
%define WM_KEYDOWN 0x0100
%define WM_KEYUP 0x0101
%define WM_TIMER 0x0113
%define WM_CREATE 0x0001
%define VK_LEFT 0x25
%define VK_RIGHT 0x27
%define VK_SPACE 0x20
%define VK_ESCAPE 0x1B
%define CS_HREDRAW 0x0002
%define CS_VREDRAW 0x0001
%define IDC_ARROW 32512
%define WHITE_BRUSH 0
%define PS_SOLID 0
%define SRCCOPY 0x00CC0020

; Game Constants
%define WINDOW_WIDTH 800
%define WINDOW_HEIGHT 600
%define PLAYER_WIDTH 32
%define PLAYER_HEIGHT 32
%define TILE_SIZE 32
%define GRAVITY 1
%define JUMP_FORCE -15
%define MOVE_SPEED 5
%define TIMER_ID 1
%define TIMER_INTERVAL 16  ; ~60 FPS

section .data
    className db 'PlatformerWindowClass', 0
    windowTitle db '2D Platformer - Pure Assembly', 0
    
    ; Player state
    playerX dq 100
    playerY dq 400
    velocityX dq 0
    velocityY dq 0
    onGround db 0
    
    ; Input state
    leftPressed db 0
    rightPressed db 0
    
    ; Level data (20x19 grid)
    level:
        db 1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1
        db 1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1
        db 1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1
        db 1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1
        db 1,0,0,0,0,0,0,0,1,1,1,1,1,0,0,0,0,0,0,0,0,0,0,0,1
        db 1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1
        db 1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1
        db 1,0,0,0,0,1,1,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1
        db 1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1
        db 1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1
        db 1,0,0,1,1,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1
        db 1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1
        db 1,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,1,0,0,0,0,0,0,1
        db 1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1
        db 1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1
        db 1,0,0,0,0,0,0,1,1,1,1,1,1,1,1,1,0,0,0,0,0,0,0,0,1
        db 1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1
        db 1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1
        db 1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1
    
    level_width equ 25
    level_height equ 19

section .bss
    hInstance resq 1
    hwnd resq 1
    msg resb 48  ; MSG structure
    wc resb 80   ; WNDCLASSEX structure
    ps resb 72   ; PAINTSTRUCT
    rect resb 16 ; RECT
    hdc resq 1
    hdcMem resq 1
    hbmMem resq 1
    hOldBitmap resq 1
    hBrushPlayer resq 1
    hBrushPlatform resq 1
    hBrushBackground resq 1

section .text
    extern GetModuleHandleA
    extern LoadCursorA
    extern RegisterClassExA
    extern CreateWindowExA
    extern ShowWindow
    extern UpdateWindow
    extern GetMessageA
    extern TranslateMessage
    extern DispatchMessageA
    extern PostQuitMessage
    extern DefWindowProcA
    extern ExitProcess
    extern BeginPaint
    extern EndPaint
    extern GetClientRect
    extern FillRect
    extern CreateSolidBrush
    extern SelectObject
    extern Rectangle
    extern DeleteObject
    extern SetTimer
    extern CreateCompatibleDC
    extern CreateCompatibleBitmap
    extern DeleteDC
    extern BitBlt
    extern GetStockObject

global main
main:
    ; Get instance handle
    xor rcx, rcx
    call GetModuleHandleA
    mov [hInstance], rax
    
    ; Register window class
    call RegisterWindowClass
    
    ; Create window
    call CreateMainWindow
    
    ; Message loop
    .message_loop:
        lea rcx, [msg]
        xor rdx, rdx
        xor r8, r8
        xor r9, r9
        call GetMessageA
        
        test rax, rax
        jz .exit
        
        lea rcx, [msg]
        call TranslateMessage
        
        lea rcx, [msg]
        call DispatchMessageA
        
        jmp .message_loop
    
    .exit:
        xor rcx, rcx
        call ExitProcess

RegisterWindowClass:
    ; Fill WNDCLASSEX structure
    mov dword [wc], 80          ; cbSize
    mov dword [wc+4], CS_HREDRAW | CS_VREDRAW  ; style
    lea rax, [WindowProc]
    mov [wc+8], rax             ; lpfnWndProc
    mov dword [wc+16], 0        ; cbClsExtra
    mov dword [wc+20], 0        ; cbWndExtra
    mov rax, [hInstance]
    mov [wc+24], rax            ; hInstance
    mov qword [wc+32], 0        ; hIcon
    
    ; Load cursor
    xor rcx, rcx
    mov rdx, IDC_ARROW
    call LoadCursorA
    mov [wc+40], rax            ; hCursor
    
    ; Background brush
    mov rcx, WHITE_BRUSH
    call GetStockObject
    mov [wc+48], rax            ; hbrBackground
    
    mov qword [wc+56], 0        ; lpszMenuName
    lea rax, [className]
    mov [wc+64], rax            ; lpszClassName
    mov qword [wc+72], 0        ; hIconSm
    
    ; Register class
    lea rcx, [wc]
    call RegisterClassExA
    ret

CreateMainWindow:
    ; CreateWindowEx parameters
    push 0                      ; lpParam
    push qword [hInstance]      ; hInstance
    push 0                      ; hMenu
    push 0                      ; hWndParent
    push WINDOW_HEIGHT          ; nHeight
    push WINDOW_WIDTH           ; nWidth
    push 100                    ; Y
    push 100                    ; X
    sub rsp, 32                 ; Shadow space
    
    mov r9d, WS_OVERLAPPEDWINDOW
    lea r8, [windowTitle]
    lea rdx, [className]
    xor rcx, rcx
    call CreateWindowExA
    add rsp, 72
    
    mov [hwnd], rax
    
    ; Show window
    mov rcx, rax
    mov rdx, 1  ; SW_SHOWNORMAL
    call ShowWindow
    
    mov rcx, [hwnd]
    call UpdateWindow
    ret

WindowProc:
    ; Parameters: rcx=hwnd, rdx=msg, r8=wParam, r9=lParam
    push rbp
    mov rbp, rsp
    sub rsp, 64
    
    ; Save parameters
    mov [rbp+16], rcx   ; hwnd
    mov [rbp+24], rdx   ; msg
    mov [rbp+32], r8    ; wParam
    mov [rbp+40], r9    ; lParam
    
    ; Handle messages
    cmp rdx, WM_CREATE
    je .wm_create
    cmp rdx, WM_DESTROY
    je .wm_destroy
    cmp rdx, WM_PAINT
    je .wm_paint
    cmp rdx, WM_KEYDOWN
    je .wm_keydown
    cmp rdx, WM_KEYUP
    je .wm_keyup
    cmp rdx, WM_TIMER
    je .wm_timer
    
    ; Default processing
    .default:
        mov rcx, [rbp+16]
        mov rdx, [rbp+24]
        mov r8, [rbp+32]
        mov r9, [rbp+40]
        call DefWindowProcA
        jmp .return
    
    .wm_create:
        ; Create brushes
        mov rcx, 0x0064FF  ; Blue for player
        call CreateSolidBrush
        mov [hBrushPlayer], rax
        
        mov rcx, 0x1E3C64  ; Brown for platforms
        call CreateSolidBrush
        mov [hBrushPlatform], rax
        
        mov rcx, 0xEBCE87  ; Sky blue for background
        call CreateSolidBrush
        mov [hBrushBackground], rax
        
        ; Set timer for game loop
        mov rcx, [rbp+16]
        mov rdx, TIMER_ID
        mov r8, TIMER_INTERVAL
        xor r9, r9
        call SetTimer
        
        xor rax, rax
        jmp .return
    
    .wm_destroy:
        ; Clean up brushes
        mov rcx, [hBrushPlayer]
        call DeleteObject
        mov rcx, [hBrushPlatform]
        call DeleteObject
        mov rcx, [hBrushBackground]
        call DeleteObject
        
        xor rcx, rcx
        call PostQuitMessage
        xor rax, rax
        jmp .return
    
    .wm_paint:
        mov rcx, [rbp+16]
        lea rdx, [ps]
        call BeginPaint
        mov [hdc], rax
        
        ; Get client rect
        mov rcx, [rbp+16]
        lea rdx, [rect]
        call GetClientRect
        
        ; Create memory DC for double buffering
        mov rcx, [hdc]
        call CreateCompatibleDC
        mov [hdcMem], rax
        
        mov rcx, [hdc]
        mov rdx, WINDOW_WIDTH
        mov r8, WINDOW_HEIGHT
        call CreateCompatibleBitmap
        mov [hbmMem], rax
        
        mov rcx, [hdcMem]
        mov rdx, rax
        call SelectObject
        mov [hOldBitmap], rax
        
        ; Clear background
        mov rcx, [hdcMem]
        lea rdx, [rect]
        mov r8, [hBrushBackground]
        call FillRect
        
        ; Draw level
        call DrawLevel
        
        ; Draw player
        call DrawPlayer
        
        ; Copy to screen
        mov rcx, [hdc]
        xor rdx, rdx
        xor r8, r8
        mov r9, WINDOW_WIDTH
        push SRCCOPY
        push WINDOW_HEIGHT
        push 0
        push 0
        push qword [hdcMem]
        sub rsp, 32
        call BitBlt
        add rsp, 72
        
        ; Clean up
        mov rcx, [hdcMem]
        mov rdx, [hOldBitmap]
        call SelectObject
        
        mov rcx, [hbmMem]
        call DeleteObject
        
        mov rcx, [hdcMem]
        call DeleteDC
        
        mov rcx, [rbp+16]
        lea rdx, [ps]
        call EndPaint
        
        xor rax, rax
        jmp .return
    
    .wm_keydown:
        mov rax, [rbp+32]  ; wParam (key code)
        cmp rax, VK_LEFT
        je .key_left_down
        cmp rax, VK_RIGHT
        je .key_right_down
        cmp rax, VK_SPACE
        je .key_space_down
        cmp rax, VK_ESCAPE
        je .key_escape
        jmp .default
        
        .key_left_down:
            mov byte [leftPressed], 1
            xor rax, rax
            jmp .return
        
        .key_right_down:
            mov byte [rightPressed], 1
            xor rax, rax
            jmp .return
        
        .key_space_down:
            cmp byte [onGround], 1
            jne .default
            mov qword [velocityY], JUMP_FORCE
            xor rax, rax
            jmp .return
        
        .key_escape:
            mov rcx, [rbp+16]
            mov rdx, WM_DESTROY
            xor r8, r8
            xor r9, r9
            call PostQuitMessage
            xor rax, rax
            jmp .return
    
    .wm_keyup:
        mov rax, [rbp+32]  ; wParam (key code)
        cmp rax, VK_LEFT
        je .key_left_up
        cmp rax, VK_RIGHT
        je .key_right_up
        jmp .default
        
        .key_left_up:
            mov byte [leftPressed], 0
            xor rax, rax
            jmp .return
        
        .key_right_up:
            mov byte [rightPressed], 0
            xor rax, rax
            jmp .return
    
    .wm_timer:
        call UpdateGame
        
        ; Force redraw
        push 0
        push 0
        push 0
        mov rcx, [rbp+16]
        sub rsp, 32
        call InvalidateRect
        add rsp, 56
        
        xor rax, rax
        jmp .return
    
    .return:
        add rsp, 64
        pop rbp
        ret

UpdateGame:
    push rbx
    push rsi
    push rdi
    
    ; Update horizontal velocity based on input
    xor rax, rax
    cmp byte [leftPressed], 1
    jne .check_right
    mov rax, -MOVE_SPEED
    jmp .set_vx
    
    .check_right:
    cmp byte [rightPressed], 1
    jne .set_vx
    mov rax, MOVE_SPEED
    
    .set_vx:
    mov [velocityX], rax
    
    ; Apply gravity
    mov rax, [velocityY]
    add rax, GRAVITY
    mov [velocityY], rax
    
    ; Update position
    mov rax, [playerX]
    add rax, [velocityX]
    mov [playerX], rax
    
    mov rax, [playerY]
    add rax, [velocityY]
    mov [playerY], rax
    
    ; Check collisions
    call CheckCollisions
    
    pop rdi
    pop rsi
    pop rbx
    ret

CheckCollisions:
    push rbx
    push rsi
    push rdi
    
    ; Reset on ground
    mov byte [onGround], 0
    
    ; Check boundaries
    mov rax, [playerX]
    cmp rax, 0
    jge .check_right_bound
    mov qword [playerX], 0
    mov qword [velocityX], 0
    
    .check_right_bound:
    mov rax, [playerX]
    add rax, PLAYER_WIDTH
    cmp rax, WINDOW_WIDTH
    jle .check_vertical
    mov rax, WINDOW_WIDTH
    sub rax, PLAYER_WIDTH
    mov [playerX], rax
    mov qword [velocityX], 0
    
    .check_vertical:
    ; Check ground collision
    mov rax, [playerY]
    add rax, PLAYER_HEIGHT
    cmp rax, WINDOW_HEIGHT - 50
    jl .check_platforms
    
    ; Hit ground
    mov rax, WINDOW_HEIGHT - 50
    sub rax, PLAYER_HEIGHT
    mov [playerY], rax
    mov qword [velocityY], 0
    mov byte [onGround], 1
    
    .check_platforms:
    ; Check collision with level tiles
    ; Calculate grid position
    mov rax, [playerX]
    xor rdx, rdx
    mov rbx, TILE_SIZE
    div rbx
    mov rsi, rax  ; Grid X
    
    mov rax, [playerY]
    xor rdx, rdx
    div rbx
    mov rdi, rax  ; Grid Y
    
    ; Check if standing on a platform
    mov rax, [playerY]
    add rax, PLAYER_HEIGHT
    xor rdx, rdx
    div rbx
    
    ; Check tile below player
    cmp rax, level_height
    jge .done
    
    ; Calculate level array index
    mov rbx, rax
    imul rbx, level_width
    add rbx, rsi
    
    cmp byte [level + rbx], 1
    jne .done
    
    ; Standing on platform
    mov rax, rdi
    inc rax
    imul rax, TILE_SIZE
    sub rax, PLAYER_HEIGHT
    mov [playerY], rax
    mov qword [velocityY], 0
    mov byte [onGround], 1
    
    .done:
    pop rdi
    pop rsi
    pop rbx
    ret

DrawLevel:
    push rbx
    push rsi
    push rdi
    push r12
    push r13
    
    ; Select platform brush
    mov rcx, [hdcMem]
    mov rdx, [hBrushPlatform]
    call SelectObject
    
    xor rsi, rsi  ; Y counter
    .y_loop:
        xor rdi, rdi  ; X counter
        .x_loop:
            ; Calculate array index
            mov rax, rsi
            imul rax, level_width
            add rax, rdi
            
            ; Check if tile is solid
            cmp byte [level + rax], 1
            jne .next_tile
            
            ; Draw tile
            mov r12, rdi
            imul r12, TILE_SIZE
            mov r13, rsi
            imul r13, TILE_SIZE
            
            push 0
            push r13
            add r13, TILE_SIZE
            push r13
            push r12
            add r12, TILE_SIZE
            push r12
            mov rcx, [hdcMem]
            sub rsp, 32
            call Rectangle
            add rsp, 72
            
            .next_tile:
            inc rdi
            cmp rdi, level_width
            jl .x_loop
        
        inc rsi
        cmp rsi, level_height
        jl .y_loop
    
    pop r13
    pop r12
    pop rdi
    pop rsi
    pop rbx
    ret

DrawPlayer:
    push rbx
    
    ; Select player brush
    mov rcx, [hdcMem]
    mov rdx, [hBrushPlayer]
    call SelectObject
    
    ; Draw player rectangle
    mov rbx, [playerY]
    push 0
    push rbx
    add rbx, PLAYER_HEIGHT
    push rbx
    mov rbx, [playerX]
    push rbx
    add rbx, PLAYER_WIDTH
    push rbx
    mov rcx, [hdcMem]
    sub rsp, 32
    call Rectangle
    add rsp, 72
    
    pop rbx
    ret

; Import Win32 functions
extern InvalidateRect