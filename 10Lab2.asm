;Дано описание: A DB 60 DUP(?) 
;числа со знаком B DB 101 DUP(?) 
;Описать дальнюю процедуру OUTARR8, 
;которой передается начальный адрес 
;знакового байтового массива и число 
;элементов в нем и которая печатает этот 
;массив. Используя эту процедуру, выписать 
;фрагмент основной программы для решения следующей задачи: 
;если последний элемент массива A равен среднему элементу 
;массива B, тогда напечатать массив A, иначе — массив B. 
;Выполнить это упражнение при условии, что параметры передаются процедуре через регистры.

format ELF64 executable 3
entry start

segment readable executable
start:	
	mov AL, [A + 59]; помещаю значения в AL
	mov BL, [B + 50]; помещаю значения в BL
	cmp RAX, RBX
	jne @f

	mov RCX, A
	mov RDX, 60
	call OUTARR8
	jmp exit

@@:	mov RCX, B
	mov RDX, 101
	call OUTARR8

exit:	
    xor RCX, RCX
	xor EDI, EDI ; Exit
	mov EAX, 60
	syscall

OUTARR8:
	mov R9, RCX; addr
	mov R10, RDX; length
	dec R10

	mov RCX, R10
printByte:
	push R9
	push R10
	push RCX
	add RCX, R9
	;
	call Byte2String
	mov EDX, 4 ; string lenth
	mov RCI, temp
	mov EDI, 1
	mov EAX, 1
	syscall ; WriteConsole
	;
	pop RCX
	pop R10
	pop R9
	loop printByte
	ret;возврат из подпрограммы

Byte2String:
	mov R8, RCX
	mov RCX, 2
	mov AL, '0'
	mov RDI, temp + 1
	cld;очищает флаг направления в регистре флагов
	rep stosb;Заполнить блок из (E)CX байт по адресу ES:(E)DI содержимым AL

	mov AL, [R8]
	test AL, 128
	je @f
	mov [temp], '-'
	neg byte [R8]
	inc byte [R8]
	and byte [R8], 0x7f
	jmp print_
@@:	mov [temp], ' '

print_: mov RBX, table;регистр, где неходится таблица для xlatb
	xor RAX, RAX
	mov RDI, temp+2; регистр для записи 16-ных значений
	std
	mov AL, [R8]
	and RAX, 0xff
	mov RBP, RAX
 .loop1:
	mov RAX, RBP
	shr RBP, 4
	and RAX, 0xf
	xlatb; достаю байт из таблицы
	stosb; сохраняю его в буффер
	test RBP,RBP; если обработалось не все, то начать заново
	jne .loop1; начать цикл заново

	mov RAX, temp
	ret;возврат из подпрограммы

segment readable writable

	temp db 3 dup ?, 10, 0
	A db 60 dup (31)
	B db 101 dup (32)
	table db '0123456789ABCDEF'
