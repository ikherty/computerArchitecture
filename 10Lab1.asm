; Используя только операцию OUTCH, -Макрокоманда вывода символа на экран
; вывести содержимое регистра AX 
; в виде беззнакового 16-ричного числа («буквенные» цифры — от A до F).

format ELF64 executable 3
entry start

segment readable executable
start:
	mov RBX, table; регистр, где неходится таблица для xlatb
	mov RDI, temp+3; регистр для записи 16-ных значений
	std; запись будет происходить в обратную сторону (от больших адресов к меньшим)
	mov RAX, [number]; помещаю число в RAX
	and RAX, 0xffff; оставляю только последние 4 байта
	mov RBP, RAX; теперь это число будет храниться в RBP
 .loop1:
	mov RAX, RBP; считываю число
	shr RBP, 4; сдвигаю его вправо на 4 бита
	and RAX, 0xf; очищаю все биты кроме первых 4-х (значение в AL является индексом в таблице по адресу в RBX. см. строку 13)
	xlatb; достаю байт из таблицы
	stosb; сохраняю его в буффер
	test RBP,RBP; если обработалось не все, то начать заново
	jne .loop1; начать цикл заново
.exit:
	;PRINT
	mov EDX, 5 ; string lenth
	mov RSI, temp
	mov EDI, 1
	mov EAX, 1
	syscall ; WriteConsole

	xor EDI, EDI ; Exit
	mov EAX, 60
	syscall

segment readable writable
	number dq 0xdeadbeef; то самое число которе мы хотим представить в 16-м виде
	temp db '0','0','0','0',10; инициализирую строку нулями, чтобы числа < 0x1000 отображались корректно
	table db '0123456789ABCDEF'; таблица символов, которую будем использовать XLATB
