; Simple 2D Platformer in x86-64 Assembly for Linux
; Uses terminal-based graphics with ANSI escape codes

section .data
    ; ANSI escape codes
    clear_screen    db 27, '[2J', 27, '[H', 0
    hide_cursor     db 27, '[?25l', 0
    show_cursor     db 27, '[?25h', 0
    
    ; Game world (20x10 grid)
    world_width     equ 40
    world_height    equ 20
    
    ; Player character
    player_char     db '@'
    player_x        dq 5
    player_y        dq 15
    player_vx       dq 0
    player_vy       dq 0
    on_ground       db 0
    
    ; Physics constants
    gravity         equ 1
    jump_force      equ -3
    move_speed      equ 1
    
    ; Level data (# = platform, . = empty)
    level:
        db '########################################'
        db '#......................................#'
        db '#......................................#'
        db '#......................................#'
        db '#...............#####..................#'
        db '#......................................#'
        db '#......................................#'
        db '#.........####.........................#'
        db '#......................................#'
        db '#......................................#'
        db '#..####................................#'
        db '#......................................#'
        db '#..................####................#'
        db '#......................................#'
        db '#......................................#'
        db '#...........#########..................#'
        db '#......................................#'
        db '#......................................#'
        db '#......................................#'
        db '########################################'
    
    ; Terminal settings
    termios_old:    times 60 db 0
    termios_new:    times 60 db 0
    
    ; Messages
    game_over_msg   db 'Game Over! Press any key to exit...', 10, 0
    
section .bss
    input_buffer    resb 4
    
section .text
    global _start

_start:
    ; Initialize terminal
    call init_terminal
    
    ; Hide cursor
    mov rax, 1
    mov rdi, 1
    mov rsi, hide_cursor
    mov rdx, 6
    syscall
    
    ; Main game loop
game_loop:
    ; Clear screen
    call clear_terminal
    
    ; Draw level
    call draw_level
    
    ; Draw player
    call draw_player
    
    ; Handle input
    call handle_input
    
    ; Update physics
    call update_physics
    
    ; Check collisions
    call check_collisions
    
    ; Small delay (approximately 60 FPS)
    mov rax, 35         ; nanosleep
    mov rdi, timespec
    xor rsi, rsi
    syscall
    
    jmp game_loop

; Initialize terminal for raw input
init_terminal:
    ; Get current terminal settings
    mov rax, 16         ; ioctl
    xor rdi, rdi        ; stdin
    mov rsi, 0x5401     ; TCGETS
    mov rdx, termios_old
    syscall
    
    ; Copy to new settings
    mov rcx, 60
    mov rsi, termios_old
    mov rdi, termios_new
    rep movsb
    
    ; Modify flags for raw mode
    mov eax, [termios_new + 12]    ; c_lflag
    and eax, ~(0x0002 | 0x0008)    ; ~(ICANON | ECHO)
    mov [termios_new + 12], eax
    
    ; Set new terminal settings
    mov rax, 16         ; ioctl
    xor rdi, rdi        ; stdin
    mov rsi, 0x5402     ; TCSETS
    mov rdx, termios_new
    syscall
    
    ; Set non-blocking input
    mov rax, 72         ; fcntl
    xor rdi, rdi        ; stdin
    mov rsi, 3          ; F_GETFL
    syscall
    
    or rax, 0x800       ; O_NONBLOCK
    mov rdx, rax
    mov rax, 72         ; fcntl
    xor rdi, rdi        ; stdin
    mov rsi, 4          ; F_SETFL
    syscall
    
    ret

; Restore terminal settings
restore_terminal:
    ; Show cursor
    mov rax, 1
    mov rdi, 1
    mov rsi, show_cursor
    mov rdx, 6
    syscall
    
    ; Restore terminal settings
    mov rax, 16         ; ioctl
    xor rdi, rdi        ; stdin
    mov rsi, 0x5402     ; TCSETS
    mov rdx, termios_old
    syscall
    ret

; Clear terminal screen
clear_terminal:
    mov rax, 1
    mov rdi, 1
    mov rsi, clear_screen
    mov rdx, 7
    syscall
    ret

; Draw the level
draw_level:
    xor r8, r8          ; y = 0
.y_loop:
    xor r9, r9          ; x = 0
.x_loop:
    ; Calculate offset in level data
    mov rax, r8
    mov rbx, world_width
    mul rbx
    add rax, r9
    
    ; Get character from level
    mov bl, [level + rax]
    mov [input_buffer], bl
    
    ; Print character
    push r8
    push r9
    mov rax, 1
    mov rdi, 1
    mov rsi, input_buffer
    mov rdx, 1
    syscall
    pop r9
    pop r8
    
    ; Next x
    inc r9
    cmp r9, world_width
    jl .x_loop
    
    ; Newline
    push r8
    mov byte [input_buffer], 10
    mov rax, 1
    mov rdi, 1
    mov rsi, input_buffer
    mov rdx, 1
    syscall
    pop r8
    
    ; Next y
    inc r8
    cmp r8, world_height
    jl .y_loop
    
    ret

; Draw player at current position
draw_player:
    ; Move cursor to player position
    mov byte [input_buffer], 27
    mov byte [input_buffer+1], '['
    mov rax, 1
    mov rdi, 1
    mov rsi, input_buffer
    mov rdx, 2
    syscall
    
    ; Print Y position + 1 (1-indexed)
    mov rax, [player_y]
    inc rax
    call print_number
    
    ; Semicolon
    mov byte [input_buffer], ';'
    mov rax, 1
    mov rdi, 1
    mov rsi, input_buffer
    mov rdx, 1
    syscall
    
    ; Print X position + 1 (1-indexed)
    mov rax, [player_x]
    inc rax
    call print_number
    
    ; H command
    mov byte [input_buffer], 'H'
    mov rax, 1
    mov rdi, 1
    mov rsi, input_buffer
    mov rdx, 1
    syscall
    
    ; Draw player character
    mov al, [player_char]
    mov [input_buffer], al
    mov rax, 1
    mov rdi, 1
    mov rsi, input_buffer
    mov rdx, 1
    syscall
    
    ret

; Print a number (in rax) to stdout
print_number:
    push rbx
    push rcx
    push rdx
    
    mov rcx, 0
    mov rbx, 10
    
.divide_loop:
    xor rdx, rdx
    div rbx
    push rdx
    inc rcx
    test rax, rax
    jnz .divide_loop
    
.print_loop:
    pop rax
    add al, '0'
    mov [input_buffer], al
    push rcx
    mov rax, 1
    mov rdi, 1
    mov rsi, input_buffer
    mov rdx, 1
    syscall
    pop rcx
    loop .print_loop
    
    pop rdx
    pop rcx
    pop rbx
    ret

; Handle keyboard input
handle_input:
    ; Read input (non-blocking)
    mov rax, 0          ; read
    xor rdi, rdi        ; stdin
    mov rsi, input_buffer
    mov rdx, 1
    syscall
    
    ; Check if we got input
    cmp rax, 0
    jle .no_input
    
    mov al, [input_buffer]
    
    ; Check for quit (q)
    cmp al, 'q'
    je exit_game
    
    ; Check for left arrow or 'a'
    cmp al, 'a'
    je .move_left
    cmp al, 'A'
    je .move_left
    
    ; Check for right arrow or 'd'
    cmp al, 'd'
    je .move_right
    cmp al, 'D'
    je .move_right
    
    ; Check for jump (space or 'w')
    cmp al, ' '
    je .jump
    cmp al, 'w'
    je .jump
    cmp al, 'W'
    je .jump
    
    jmp .no_input
    
.move_left:
    mov qword [player_vx], -move_speed
    jmp .no_input
    
.move_right:
    mov qword [player_vx], move_speed
    jmp .no_input
    
.jump:
    ; Only jump if on ground
    cmp byte [on_ground], 1
    jne .no_input
    mov qword [player_vy], jump_force
    
.no_input:
    ret

; Update physics (gravity, movement)
update_physics:
    ; Apply gravity
    mov rax, [player_vy]
    add rax, gravity
    mov [player_vy], rax
    
    ; Update Y position
    mov rax, [player_y]
    add rax, [player_vy]
    mov [player_y], rax
    
    ; Update X position
    mov rax, [player_x]
    add rax, [player_vx]
    mov [player_x], rax
    
    ; Friction (stop horizontal movement)
    mov qword [player_vx], 0
    
    ret

; Check collisions with platforms
check_collisions:
    ; Reset on_ground flag
    mov byte [on_ground], 0
    
    ; Check bounds
    mov rax, [player_x]
    cmp rax, 1
    jl .fix_left
    cmp rax, world_width-2
    jge .fix_right
    jmp .check_vertical
    
.fix_left:
    mov qword [player_x], 1
    jmp .check_vertical
    
.fix_right:
    mov qword [player_x], world_width-2
    
.check_vertical:
    mov rax, [player_y]
    cmp rax, 0
    jl .fix_top
    cmp rax, world_height-1
    jge .fix_bottom
    
    ; Check collision with platform below
    mov r8, [player_y]
    inc r8              ; Check one position below
    mov r9, [player_x]
    
    ; Calculate offset in level data
    mov rax, r8
    mov rbx, world_width
    mul rbx
    add rax, r9
    
    ; Check if there's a platform
    mov bl, [level + rax]
    cmp bl, '#'
    jne .check_platform_at_pos
    
    ; Landing on platform
    mov byte [on_ground], 1
    mov qword [player_vy], 0
    jmp .done
    
.check_platform_at_pos:
    ; Check collision at current position
    mov r8, [player_y]
    mov r9, [player_x]
    
    ; Calculate offset in level data
    mov rax, r8
    mov rbx, world_width
    mul rbx
    add rax, r9
    
    ; Check if we're inside a platform
    mov bl, [level + rax]
    cmp bl, '#'
    jne .done
    
    ; Push player up if inside platform
    dec qword [player_y]
    mov byte [on_ground], 1
    mov qword [player_vy], 0
    jmp .done
    
.fix_top:
    mov qword [player_y], 0
    mov qword [player_vy], 0
    jmp .done
    
.fix_bottom:
    mov qword [player_y], world_height-1
    mov byte [on_ground], 1
    mov qword [player_vy], 0
    
.done:
    ret

; Exit game
exit_game:
    call restore_terminal
    
    ; Exit program
    mov rax, 60         ; exit
    xor rdi, rdi        ; status 0
    syscall

; Time specification for delay
section .data
timespec:
    dq 0                ; seconds
    dq 16666666         ; nanoseconds (approximately 60 FPS)