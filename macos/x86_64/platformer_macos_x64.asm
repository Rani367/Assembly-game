; 2D Platformer for macOS x86-64 (Intel) in Pure Assembly
; Uses Cocoa framework for window creation and Core Graphics for rendering
; Assembled with NASM, linked with ld

bits 64

; macOS System Call Numbers (x86-64)
%define SYS_exit        0x2000001
%define SYS_write       0x2000004

; Mach-O sections
section .data
    ; Objective-C class and selector names
    NSApp_name              db "NSApplication", 0
    NSWindow_name           db "NSWindow", 0
    NSView_name             db "NSView", 0
    NSColor_name            db "NSColor", 0
    NSBezierPath_name       db "NSBezierPath", 0
    NSTimer_name            db "NSTimer", 0
    NSEvent_name            db "NSEvent", 0
    NSString_name           db "NSString", 0
    
    ; Selector names
    sel_alloc               db "alloc", 0
    sel_init                db "init", 0
    sel_sharedApplication   db "sharedApplication", 0
    sel_setActivationPolicy db "setActivationPolicy:", 0
    sel_activateIgnoringOtherApps db "activateIgnoringOtherApps:", 0
    sel_run                 db "run", 0
    sel_initWithContentRect db "initWithContentRect:styleMask:backing:defer:", 0
    sel_setTitle            db "setTitle:", 0
    sel_makeKeyAndOrderFront db "makeKeyAndOrderFront:", 0
    sel_setContentView      db "setContentView:", 0
    sel_setNeedsDisplay     db "setNeedsDisplay:", 0
    sel_drawRect            db "drawRect:", 0
    sel_fillRect            db "fillRect:", 0
    sel_setFill             db "setFill", 0
    sel_blueColor           db "blueColor", 0
    sel_brownColor          db "brownColor", 0
    sel_whiteColor          db "whiteColor", 0
    sel_stringWithUTF8String db "stringWithUTF8String:", 0
    
    ; Window title
    window_title            db "2D Platformer - Pure Assembly (x86-64)", 0
    
    ; Game Constants
    WINDOW_WIDTH            equ 800
    WINDOW_HEIGHT           equ 600
    PLAYER_WIDTH            equ 32
    PLAYER_HEIGHT           equ 32
    TILE_SIZE               equ 32
    GRAVITY                 equ 1
    JUMP_FORCE              equ -15
    MOVE_SPEED              equ 5
    
    ; Player state
    playerX                 dq 100
    playerY                 dq 400
    velocityX               dq 0
    velocityY               dq 0
    onGround                db 0
    
    ; Input state
    leftPressed             db 0
    rightPressed            db 0
    
    ; Level data (same as other versions)
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
    
    level_width             equ 25
    level_height            equ 19
    
    ; Window style mask
    NSTitledWindowMask      equ 1
    NSClosableWindowMask    equ 2
    NSMiniaturizableWindowMask equ 4
    NSResizableWindowMask   equ 8
    NSWindowStyleMask       equ 15  ; All of the above

section .bss
    app                     resq 1
    window                  resq 1
    contentView             resq 1
    pool                    resq 1

section .text
    ; External Objective-C runtime functions
    extern _objc_getClass
    extern _objc_msgSend
    extern _sel_registerName
    extern _objc_msgSend_stret
    
    ; External C library functions
    extern _exit
    
    global _main

_main:
    ; Save stack pointer
    push rbp
    mov rbp, rsp
    
    ; Initialize Objective-C runtime
    call init_objc_runtime
    
    ; Create application
    call create_application
    
    ; Create window
    call create_window
    
    ; Run application
    mov rdi, [app]
    lea rsi, [sel_run]
    call get_selector
    mov rsi, rax
    call _objc_msgSend
    
    ; Exit
    xor rdi, rdi
    call _exit

get_selector:
    ; Input: rsi = selector string
    ; Output: rax = selector
    mov rdi, rsi
    call _sel_registerName
    ret

get_class:
    ; Input: rdi = class name string
    ; Output: rax = class object
    call _objc_getClass
    ret

init_objc_runtime:
    ; Initialize autorelease pool
    lea rdi, [NSString_name]
    call get_class
    
    ; More initialization would go here
    ret

create_application:
    ; Get NSApplication class
    lea rdi, [NSApp_name]
    call get_class
    mov r12, rax
    
    ; [NSApplication sharedApplication]
    mov rdi, r12
    lea rsi, [sel_sharedApplication]
    call get_selector
    mov rsi, rax
    call _objc_msgSend
    mov [app], rax
    
    ; Set activation policy
    mov rdi, [app]
    lea rsi, [sel_setActivationPolicy]
    call get_selector
    mov rsi, rax
    xor rdx, rdx  ; NSApplicationActivationPolicyRegular
    call _objc_msgSend
    
    ; Activate app
    mov rdi, [app]
    lea rsi, [sel_activateIgnoringOtherApps]
    call get_selector
    mov rsi, rax
    mov rdx, 1  ; YES
    call _objc_msgSend
    
    ret

create_window:
    ; Get NSWindow class
    lea rdi, [NSWindow_name]
    call get_class
    mov r12, rax
    
    ; Allocate window
    mov rdi, r12
    lea rsi, [sel_alloc]
    call get_selector
    mov rsi, rax
    call _objc_msgSend
    mov r13, rax
    
    ; Create content rect (CGRect)
    ; For simplicity, we'll create it on stack
    sub rsp, 32
    mov qword [rsp], 0          ; x
    mov qword [rsp+8], 0        ; y
    mov qword [rsp+16], WINDOW_WIDTH
    mov qword [rsp+24], WINDOW_HEIGHT
    
    ; Initialize window
    mov rdi, r13
    lea rsi, [sel_initWithContentRect]
    call get_selector
    mov rsi, rax
    
    ; Pass rect by value (x86-64 calling convention)
    movsd xmm0, [rsp]       ; x
    movsd xmm1, [rsp+8]     ; y
    movsd xmm2, [rsp+16]    ; width
    movsd xmm3, [rsp+24]    ; height
    mov rdx, NSWindowStyleMask
    mov rcx, 2              ; NSBackingStoreBuffered
    xor r8, r8              ; defer = NO
    
    call _objc_msgSend
    mov [window], rax
    add rsp, 32
    
    ; Create NSString for title
    lea rdi, [NSString_name]
    call get_class
    mov rdi, rax
    lea rsi, [sel_stringWithUTF8String]
    call get_selector
    mov rsi, rax
    lea rdx, [window_title]
    call _objc_msgSend
    mov r14, rax
    
    ; Set window title
    mov rdi, [window]
    lea rsi, [sel_setTitle]
    call get_selector
    mov rsi, rax
    mov rdx, r14
    call _objc_msgSend
    
    ; Make window visible
    mov rdi, [window]
    lea rsi, [sel_makeKeyAndOrderFront]
    call get_selector
    mov rsi, rax
    xor rdx, rdx  ; nil
    call _objc_msgSend
    
    ret

; Game update function (same logic as ARM64 version)
update_game:
    push rbx
    push r12
    push r13
    
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
    call check_collisions
    
    pop r13
    pop r12
    pop rbx
    ret

check_collisions:
    push rbx
    push r12
    push r13
    
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
    ; Platform collision detection
    ; Similar to other versions
    
    pop r13
    pop r12
    pop rbx
    ret