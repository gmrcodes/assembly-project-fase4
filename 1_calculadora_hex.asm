; Programa 1: Calculadora de Aritmetica Hexadecimal (Con Bucle)
; Arquitectura: x86 (Modo de 16 bits)
; Descripcion: Solicita dos numeros hex de 8 bits (00h-FFh) y
;              un operador (+ o -), ejecuta nativamente en los
;              registros de la CPU e imprime el resultado
; =========================================================

.MODEL SMALL
.STACK 100h

.DATA
    ; Mensajes de interfaz terminados en '$'
    divider   DB 0Dh, 0Ah, '----------------------------------------$'
    instruc   DB 0Dh, 0Ah, 'Usa distribucion de teclado US $'
    prompt1   DB 0Dh, 0Ah, 'Enter first hex byte (00h-FFh): $'
    promptOp  DB 0Dh, 0Ah, 'Enter operator (+ or -): $'
    prompt2   DB 0Dh, 0Ah, 'Enter second hex byte (00h-FFh): $'
    resultMsg DB 0Dh, 0Ah, 'Result (Hex): $'
    againMsg  DB 0Dh, 0Ah, 0Dh, 0Ah, 'Another operation? (Y/N): $'

    ; Variables de almacenamiento en memoria
    val1      DB 00h
    val2      DB 00h
    operator  DB 00h

.CODE
MAIN PROC
    ; -----------------------------------------------------
    ; Inicializar el Segmento de Datos
    ; -----------------------------------------------------
    MOV AX, @DATA
    MOV DS, AX

CALC_LOOP:
    ; Limpiar registros de trabajo al iniciar cada iteracion
    XOR AX, AX
    XOR BX, BX

    ; Imprimir separador visual de iteracion
    LEA DX, divider
    MOV AH, 09h
    INT 21h

    ; Imprimir mensaje de instruccion
    LEA DX, instruc
    MOV AH, 09h
    INT 21h

    ; -----------------------------------------------------
    ; Leer el primer byte hexadecimal (val1)
    ; -----------------------------------------------------
    LEA DX, prompt1
    MOV AH, 09h
    INT 21h

    CALL READ_HEX_BYTE
    MOV val1, AL

    ; -----------------------------------------------------
    ; Leer el operador aritmetico (+ o -)
    ; -----------------------------------------------------
    LEA DX, promptOp
    MOV AH, 09h
    INT 21h

    MOV AH, 01h
    INT 21h
    MOV operator, AL

    ; -----------------------------------------------------
    ; Leer el segundo byte hexadecimal (val2)
    ; -----------------------------------------------------
    LEA DX, prompt2
    MOV AH, 09h
    INT 21h

    CALL READ_HEX_BYTE
    MOV val2, AL

    ; -----------------------------------------------------
    ; Ejecutar operacion (ADD / SUB) en la ALU
    ; -----------------------------------------------------
    MOV AL, val1            ; Cargar primer operando en AL
    MOV BL, val2            ; Cargar segundo operando en BL
    XOR AH, AH              ; Limpiar AH (00h) para recibir acarreo

    CMP operator, '+'
    JNE EXEC_SUB

    ; Suma con captura de acarreo (Carry Flag)
    ADD AL, BL
    ADC AH, 00h             ; Si CF=1, AH toma el valor 01h
    JMP SHOW_RESULT

EXEC_SUB:
    ; Resta con captura de prestamo (Borrow / Carry Flag)
    SUB AL, BL
    SBB AH, 00h             ; Si CF=1, AH toma el valor FFh

SHOW_RESULT:
    PUSH AX                 ; Respaldar resultado de 16 bits en la pila

    LEA DX, resultMsg
    MOV AH, 09h
    INT 21h

    POP AX                  ; Recuperar resultado hacia AX
    CALL PRINT_HEX16        ; Mostrar los 4 digitos hexadecimales

    ; -----------------------------------------------------
    ; Control de bucle (Preguntar si continua)
    ; -----------------------------------------------------
    LEA DX, againMsg
    MOV AH, 09h
    INT 21h

    MOV AH, 01h             ; Leer 1 caracter de respuesta (Y/y/N/n)
    INT 21h

    AND AL, 11011111b       ; Mascara binaria: convierte minuscula a mayuscula
    CMP AL, 'Y'             ; Compara si la tecla presionada fue 'Y' (activa ZF=1)
    JE CALC_LOOP            ; Si ZF=1 (Jump if Equal), salta al inicio del ciclo

    ; -----------------------------------------------------
    ; Terminar programa y devolver control al SO
    ; -----------------------------------------------------
    MOV AH, 4Ch             ; Funcion 4Ch de MS-DOS: finalizar proceso
    INT 21h
MAIN ENDP


; =========================================================
; Procedimiento: READ_HEX_BYTE
; Descripcion: Lee 2 caracteres hexadecimales y los empaqueta
;              en un solo byte dentro de AL.
; =========================================================
READ_HEX_BYTE PROC
    PUSH BX

    ; Leer nibble alto (4 bits superiores)
    MOV AH, 01h
    INT 21h
    CALL CHAR_TO_HEX
    SHL AL, 4               ; Desplazar 4 bits a la izquierda
    MOV BL, AL

    ; Leer nibble bajo (4 bits inferiores)
    MOV AH, 01h
    INT 21h
    CALL CHAR_TO_HEX
    OR BL, AL               ; Combinar ambos nibbles en BL

    MOV AL, BL
    POP BX
    RET
READ_HEX_BYTE ENDP


; =========================================================
; Procedimiento: CHAR_TO_HEX
; Descripcion: Convierte caracter ASCII en AL a valor de 4 bits.
; =========================================================
CHAR_TO_HEX PROC
    CMP AL, '9'
    JLE IS_DIGIT

    AND AL, 11011111b       ; Mascara binaria para forzar mayuscula ('a' -> 'A')
    SUB AL, 'A'
    ADD AL, 0Ah             ; Ajustar rango A-F a valores 10-15 (0Ah-0Fh)
    RET

IS_DIGIT:
    SUB AL, '0'             ; Ajustar rango ASCII '0'-'9' a 0-9
    RET
CHAR_TO_HEX ENDP


; =========================================================
; Procedimiento: PRINT_HEX16
; Descripcion: Imprime el contenido de AX (16 bits) en hex.
; =========================================================
PRINT_HEX16 PROC
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX

    MOV CX, 0404h           ; CH = 4 digitos a imprimir, CL = 4 bits por rotacion
    MOV BX, AX

PRINT_LOOP:
    MOV AX, BX
    ROL AX, 4               ; Rotar nibble mas significativo a la posicion baja
    MOV BX, AX

    AND AL, 00001111b       ; Mascara binaria para aislar los 4 bits inferiores
    CMP AL, 09h
    JLE DIGIT_OUT

    ADD AL, 'A' - 0Ah       ; Convertir 10-15 a ASCII 'A'-'F'
    JMP DO_PRINT

DIGIT_OUT:
    ADD AL, '0'             ; Convertir 0-9 a ASCII '0'-'9'

DO_PRINT:
    MOV DL, AL
    MOV AH, 02h             ; Servicio 02h: imprimir un caracter en pantalla
    INT 21h

    DEC CH
    JNZ PRINT_LOOP

    ; Imprimir sufijo 'h'
    MOV DL, 'h'
    MOV AH, 02h
    INT 21h

    POP DX
    POP CX
    POP BX
    POP AX
    RET
PRINT_HEX16 ENDP

END MAIN