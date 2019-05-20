;Дано описание: A DB 60 DUP(?) 
; числа со знаком B DB 101 DUP(?) 
;Описать дальнюю процедуру OUTARR8, 
;которой передается начальный адрес 
;знакового байтового массива и число 
;элементов в нем и которая печатает этот 
;массив. Используя эту процедуру, выписать 
;фрагмент основной программы для решения следующей задачи: 
;если последний элемент массива A равен среднему элементу 
;массива B, тогда напечатать массив A, иначе — массив B. 
;Выполнить это упражнение при условии, что параметры передаются процедуре через регистры.

format pe64 console 5.0
entry start
include 'win64a.inc'

section 'sec1' readable executable
start:	sub rsp, 8

	mov rcx, STD_OUTPUT_HANDLE; Нужно для вывода в консоль
	call [GetStdHandle]
	mov [hOutput], rax
	
;////////////////////////////// Тут происходит вся магия

	mov rbx, table; указываю где неходится таблица для xlatb
	mov rdi, temp+3; указываю куда записывать 16-ные значения
	std; запись будет происходить в обратную сторону (от больших адресов к меньшим)
	mov rax, [number]; запихиваю число в RAX
	and rax, 0xffff; оставляю только последние 4 байта
	mov rbp, rax; теперь это число будет храниться в RBP
 .loop1:
	mov rax, rbp; Считываю число
	shr rbp, 4; сдвигаю его вправо на 4 бита
	and rax, 0xf; очищаю все биты кроме первых 4-х (значение в AL является индексом в таблице по адресу в RBX. см. строку 13)
	xlatb; Достаю байт из таблицы
	stosb; сохраняю его в буффер
	test rbp,rbp; Если я обработал не все, то начать заново
	jne .loop1; начать цикл заново
	
;//////////////////////////////

.exit:
	;PRINT
	mov rcx, [hOutput]
	mov rdx, temp
	mov r8, 5
	mov r9, useless
	call [WriteConsole] ; Вывод в консоль

	mov rcx, 0x8fffffff; чтобы окно не сразу закрылось 
	loop $

	mov rcx, 0
	call [ExitProcess]

section 'sec2' readable writable
	newLine db 10
	hOutput dq ?
	number dq 0xdeadbeef ; то самое число которе мы хотим представить в 16-м виде
	temp db '0','0','0','0',0 ; Инициализирую строку нулями, чтобы числа < 0x1000 отображались корректно
	useless dq ?

	table db '0123456789ABCDEF' ; таблица символов, которую будет использовать XLATB

section 'import' import data readable writable
	library kernel32, 'kernel32.dll',\
		user32, 'user32.dll'

	include 'api\kernel32.inc'
	include 'api\user32.inc'
