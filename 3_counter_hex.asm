; Programa 3: Contador Progresivo Automatico en Base 16 (0h a Fh)
; Arquitectura: x86 (Modo de 16 bits)
; Descripcion: Genera un conteo automatico desde 0h hasta Fh empleando
;              estructuras de bucle (LOOP) y saltos condicionales
;              (CMP, JLE, JNZ), mostrando los 16 simbolos hex en pantalla.
; =========================================================================

.MODEL SMALL
.STACK 100h

.DATA
    ; Mensajes informativos delimitados por '$' para DOS
    titleMsg  DB 0Dh, 0Ah, '=== Automatic Hexadecimal Counter (0h - Fh) ===', 0Dh, 0Ah, '$'
    doneMsg   DB 0Dh, 0Ah, 0Dh, 0Ah, 'Count completed successfully.$'

.CODE
MAIN PROC
    ; ---------------------------------------------------------------------
    ; Inicializar el Segmento de Datos (DS)
    ; ---------------------------------------------------------------------
    MOV AX, @DATA            ; Cargar direccion base del segmento de datos en AX
    MOV DS, AX               ; Transferir direccion hacia el registro DS

    ; ---------------------------------------------------------------------
    ; Mostrar encabezado inicial en pantalla
    ; ---------------------------------------------------------------------
    LEA DX, titleMsg         ; Cargar desplazamiento (offset) de titleMsg en DX
    MOV AH, 09h              ; Servicio 09h de MS-DOS: imprimir cadena de texto
    INT 21h                  ; Ejecutar interrupcion del sistema

    ; ---------------------------------------------------------------------
    ; Configurar registros de control del contador progresivo
    ; ---------------------------------------------------------------------
    MOV CX, 10h              ; Contador de bucle: 10h = 16 iteraciones exactas
    MOV BL, 00h              ; Valor inicial del contador progresivo: 00h (0h)

COUNT_LOOP:
    ; ---------------------------------------------------------------------
    ; Convertir el valor numerico de BL (00h-0Fh) a caracter ASCII
    ; ---------------------------------------------------------------------
    MOV AL, BL               ; Copiar valor actual de BL hacia AL para operarlo
    CMP AL, 09h              ; Comparar el valor con 09h (actualiza banderas)
    JLE CONVERT_DIGIT        ; Si AL <= 09h, saltar a conversion numerica ('0'-'9')

    ; Conversion para letras hexadecimales ('A' - 'F', valores 0Ah - 0Fh)
    ADD AL, 37h              ; Sumar 37h (0Ah + 37h = 41h -> 'A' en ASCII)
    JMP PRINT_SYMBOL         ; Saltar incondicionalmente a impresion

CONVERT_DIGIT:
    ; Conversion para digitos decimales ('0' - '9', valores 00h - 09h)
    ADD AL, 30h              ; Sumar 30h (00h + 30h = 30h -> '0' en ASCII)

PRINT_SYMBOL:
    ; ---------------------------------------------------------------------
    ; Imprimir el digito hexadecimal y su sufijo 'h'
    ; ---------------------------------------------------------------------
    MOV DL, AL               ; Pasar caracter ASCII convertido al registro DL
    MOV AH, 02h              ; Servicio 02h de MS-DOS: imprimir un caracter
    INT 21h                  ; Mostrar digito en consola

    MOV DL, 'h'              ; Cargar sufijo 'h' para notacion hexadecimal
    MOV AH, 02h              ; Servicio 02h de MS-DOS: imprimir un caracter
    INT 21h                  ; Mostrar 'h' junto al digito (ej. 0h, 1h... Fh)

    ; ---------------------------------------------------------------------
    ; Evaluar fin de secuencia con CMP y JNZ para formato limpio
    ; ---------------------------------------------------------------------
    CMP BL, 0Fh              ; Verificar si el contador alcanzo el limite 0Fh
    JNZ PRINT_SEPARATOR      ; Si BL != 0Fh (ZF = 0), imprimir espacio separador
    JMP NEXT_ITERATION       ; Si BL == 0Fh (ZF = 1), omitir espacio final

PRINT_SEPARATOR:
    MOV DL, 20h              ; 20h = caracter ASCII de espacio en blanco (' ')
    MOV AH, 02h              ; Servicio 02h de MS-DOS: imprimir un caracter
    INT 21h                  ; Separar visualmente los elementos en pantalla

NEXT_ITERATION:
    INC BL                   ; Incrementar el valor hexadecimal (BL = BL + 1)
    LOOP COUNT_LOOP          ; Decrementar CX; si CX != 0, saltar a COUNT_LOOP

    ; ---------------------------------------------------------------------
    ; Mostrar mensaje de cierre y devolver el control al SO
    ; ---------------------------------------------------------------------
    LEA DX, doneMsg          ; Cargar direccion del mensaje de finalizacion
    MOV AH, 09h              ; Servicio 09h de MS-DOS: imprimir cadena
    INT 21h

    MOV AH, 4Ch              ; Funcion 4Ch de MS-DOS: terminar proceso
    INT 21h                  ; Devolver control rigurosamente al sistema operativo
MAIN ENDP
END MAIN