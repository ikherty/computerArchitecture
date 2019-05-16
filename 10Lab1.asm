; Используя только операцию OUTCH, -Макрокоманда вывода символа на экран
; вывести содержимое регистра AX 
; в виде беззнакового 16-ричного числа («буквенные» цифры — от A до F).

HexTabl  db     '0123456789abcdef'
asHex    db     '00', '$'

;mov di, OFFSET asHex; запишет адрес конца строки
lea di, asHex;осуществляет загрузку в регистр адреса
@@Repeat: ;начало цикла
mov cx, ax 
and ax, 000fh; логическое умножение всех пар бит операндов
;mov bx, OFFSET HexTabl 
lea bx, HexTabl
;xlat ; применяется для перекодирования байта по таблице
;вывод с outch
mov [di+1], al 
mov ax, cx 
and ax, 00f0h 
mov cl, 4 
shr ax, cl ; логический сдвиг вправо на сл бит
;xlat 
mov [di], al 
mov ah, 09h 
jnc    @@Repeat  ;конец цикла
;mov dx, OFFSET asHex ; запишет адрес начала строки 
lea dx, asHex
int 21h 
