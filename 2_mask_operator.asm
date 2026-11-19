; Programa 2: Operador de Mascaras Logicas (AND / OR / XOR)
; Arquitectura: x86 (Modo de 16 bits)
; Descripcion: Lee un byte en formato hexadecimal, aplica una mascara
;              interna de bits mediante compuertas logicas en la ALU
;              e imprime el resultado en binario de 8 bits.
; =========================================================================

.MODEL SMALL
.STACK 100h

; Declaracion de constante binaria interna
MASK_BYTE EQU 00001111b      ; Mascara: nibble alto = 0000, nibble bajo = 1111

.DATA
    ; Mensajes de interfaz de usuario (delimitados por '$')
    headerMsg DB 0Dh, 0Ah, '============================================$'
    promptHex DB 0Dh, 0Ah, 'Ingrese byte hexadecimal (00h-FFh): $'
    menuMsg   DB 0Dh, 0Ah, 'Mascara interna fija: 00001111b', 0Dh, 0Ah
              DB 'Seleccione compuerta: [1] AND  [2] OR  [3] XOR : $'
    invalidOp DB 0Dh, 0Ah, 'Opcion invalida. Use 1, 2 o 3.$'
    resultMsg DB 0Dh, 0Ah, 'Resultado binario (8 bits): $'
    againMsg  DB 0Dh, 0Ah, 0Dh, 0Ah, 'Realizar otra operacion? (S/N): $'

    ; Variable para almacenar el byte capturado
    inputByte DB 00h

.CODE
MAIN PROC
    ; ---------------------------------------------------------------------
    ; Inicializar el Segmento de Datos (DS)
    ; ---------------------------------------------------------------------
    MOV AX, @DATA            ; Cargar direccion base del segmento de datos
    MOV DS, AX               ; Transferir a DS mediante el registro AX

LOGIC_LOOP:
    ; Imprimir linea separadora
    LEA DX, headerMsg
    MOV AH, 09h
    INT 21h

    ; ---------------------------------------------------------------------
    ; Solicitar y leer el byte en formato hexadecimal (00h - FFh)
    ; ---------------------------------------------------------------------
    LEA DX, promptHex
    MOV AH, 09h
    INT 21h

    CALL READ_HEX_BYTE       ; Retorna el byte empaquetado en AL
    MOV inputByte, AL        ; Respaldar el dato en memoria

    ; ---------------------------------------------------------------------
    ; Mostrar mascara interna y seleccionar operacion booleana
    ; ---------------------------------------------------------------------
SELECT_GATE:
    LEA DX, menuMsg
    MOV AH, 09h
    INT 21h

    MOV AH, 01h              ; Leer 1 caracter del teclado con eco en pantalla
    INT 21h

    ; Recuperar el byte original en AL antes de operar en la ALU
    MOV BL, AL               ; Guardar la opcion elegida ('1', '2' o '3') en BL
    MOV AL, inputByte        ; Cargar el dato del usuario en el acumulador AL

    CMP BL, '1'              ; Comparar opcion con '1' (AND)
    JE APPLY_AND

    CMP BL, '2'              ; Comparar opcion con '2' (OR)
    JE APPLY_OR

    CMP BL, '3'              ; Comparar opcion con '3' (XOR)
    JE APPLY_XOR

    ; Si presiono otra tecla, notificar y volver a pedir opcion
    LEA DX, invalidOp
    MOV AH, 09h
    INT 21h
    JMP SELECT_GATE

    ; ---------------------------------------------------------------------
    ; Ejecutar instruccion logica nativa en la ALU del 8086
    ; ---------------------------------------------------------------------
APPLY_AND:
    AND AL, MASK_BYTE        ; Apaga bits superiores (AND con 0) y conserva bajos
    JMP SHOW_BINARY

APPLY_OR:
    OR AL, MASK_BYTE         ; Enciende bits inferiores (OR con 1) y conserva altos
    JMP SHOW_BINARY

APPLY_XOR:
    XOR AL, MASK_BYTE        ; Invierte bits inferiores (XOR con 1) y conserva altos

    ; ---------------------------------------------------------------------
    ; Imprimir el resultado transformado en binario de 8 bits
    ; ---------------------------------------------------------------------
SHOW_BINARY:
    PUSH AX                  ; Respaldar resultado de AL en la pila

    LEA DX, resultMsg
    MOV AH, 09h
    INT 21h

    POP AX                   ; Recuperar el byte transformado en AL
    CALL PRINT_BIN8          ; Desplegar los 8 bits uno a uno en pantalla

    ; ---------------------------------------------------------------------
    ; Control de repeticion del programa
    ; ---------------------------------------------------------------------
    LEA DX, againMsg
    MOV AH, 09h
    INT 21h

    MOV AH, 01h              ; Leer respuesta del usuario
    INT 21h

    AND AL, 11011111b        ; Convertir minuscula ('s') a mayuscula ('S')
    CMP AL, 'S'
    JE LOGIC_LOOP            ; Si es 'S', reiniciar ciclo

    ; ---------------------------------------------------------------------
    ;  Devolver control al sistema operativo de forma rigurosa
    ; ---------------------------------------------------------------------
    MOV AH, 4Ch              ; Funcion 4Ch de MS-DOS: terminar proceso
    INT 21h                  ; Ejecutar interrupcion del sistema
MAIN ENDP


; =========================================================================
; Procedimiento: READ_HEX_BYTE
; Descripcion: Captura 2 caracteres hexadecimales del teclado y los une
;              en un unico byte dentro del registro AL.
; =========================================================================
READ_HEX_BYTE PROC
    PUSH BX
    PUSH CX

    ; Leer nibble superior (4 bits mas significativos)
    MOV AH, 01h
    INT 21h
    CALL CHAR_TO_HEX         ; Convertir ASCII a valor 00h-0Fh
    MOV CL, 04h              ; Cargar desplazamiento de 4 bits (regla 8086)
    SHL AL, CL               ; Mover nibble a los bits 7..4
    MOV BL, AL               ; Guardar temporalmente en BL

    ; Leer nibble inferior (4 bits menos significativos)
    MOV AH, 01h
    INT 21h
    CALL CHAR_TO_HEX         ; Convertir ASCII a valor 00h-0Fh
    OR BL, AL                ; Fusionar ambos nibbles mediante OR bit a bit

    MOV AL, BL               ; Devolver byte completo en AL
    POP CX
    POP BX
    RET
READ_HEX_BYTE ENDP


; =========================================================================
; Procedimiento: CHAR_TO_HEX
; Descripcion: Traduce un caracter ASCII ('0'-'9', 'A'-'F') a su valor
;              numerico binario de 4 bits en AL.
; =========================================================================
CHAR_TO_HEX PROC
    CMP AL, '9'              ; Verificar si esta en el rango numerico ASCII
    JLE IS_DIGIT

    AND AL, 11011111b        ; Mascara binaria para convertir 'a'-'f' en 'A'-'F'
    SUB AL, 'A'              ; Restar base ASCII de 'A' (41h)
    ADD AL, 0Ah              ; Sumar 10 decimal (0Ah) para obtener 10..15
    RET

IS_DIGIT:
    SUB AL, '0'              ; Restar base ASCII de '0' (30h) para obtener 0..9
    RET
CHAR_TO_HEX ENDP


; =========================================================================
; Procedimiento: PRINT_BIN8
; Descripcion: Recorre los 8 bits del registro AL de izquierda a derecha
;              extrayendolos hacia el Carry Flag (CF) para imprimirlos.
; =========================================================================
PRINT_BIN8 PROC
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX

    MOV BL, AL               ; Copiar byte a imprimir en BL para protegerlo
    MOV CX, 0008h            ; Configurar contador para exactamente 8 bits

BIN_LOOP:
    SHL BL, 1                ; Desplazar 1 bit a la izquierda; el bit 7 cae en CF
    JC PRINT_ONE             ; Si CF = 1 (Jump if Carry), saltar a imprimir '1'

    MOV DL, '0'              ; Si CF = 0, preparar caracter ASCII '0'
    JMP OUTPUT_BIT

PRINT_ONE:
    MOV DL, '1'              ; Preparar caracter ASCII '1'

OUTPUT_BIT:
    MOV AH, 02h              ; Servicio 02h de DOS: imprimir caracter en DL
    INT 21h

    LOOP BIN_LOOP            ; Decrementar CX y repetir hasta procesar 8 bits

    ; Imprimir sufijo 'b' para indicar formato binario
    MOV DL, 'b'
    MOV AH, 02h
    INT 21h

    POP DX
    POP CX
    POP BX
    POP AX
    RET
PRINT_BIN8 ENDP

END MAIN