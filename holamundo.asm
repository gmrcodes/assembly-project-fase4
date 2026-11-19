; =========================================================
; Program: Hello World Output
; Architecture: x86 (16-bit Real Mode)
; Assembler: TASM / MASM compatible
; =========================================================

.MODEL SMALL              ; Memory model: 64KB code, 64KB data
.STACK 100h               ; Allocate 256 bytes for stack

.DATA                     ; Data segment declaration
    message DB 'Hello World!$', 0 ; String terminated by '$'

.CODE                     ; Code segment declaration
MAIN PROC
    ; Step 1: Initialize Data Segment (DS) register
    MOV AX, @DATA         ; Load address of data segment into AX
    MOV DS, AX            ; Transfer address from AX to DS

    ; Step 2: Display string using DOS Interrupt 21h, Service 09h
    MOV AH, 09h           ; AH = 09h (Display String Function)
    LEA DX, message       ; DX = Offset address of 'message'
    INT 21h               ; Trigger MS-DOS service

    ; Step 3: Terminate program cleanly
    MOV AH, 4Ch           ; AH = 4Ch (Exit Process Function)
    INT 21h               ; Return control to Operating System
MAIN ENDP
END MAIN                  ; End of program and entry point definition