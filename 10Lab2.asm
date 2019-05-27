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

format ELF64 executable 3
entry start

segment readable executable
start:	
	mov al, [A + 59]
	mov bl, [B + 50]
	cmp rax, rbx
	jne @f

	mov rcx, A
	mov rdx, 60
	call OUTARR8
	jmp exit

@@:	mov rcx, B
	mov rdx, 101
	call OUTARR8

exit:	
    xor rcx, rcx
	;call [ExitProcess]
	xor edi, edi ; Exit
	mov eax, 60
	syscall

OUTARR8:
	mov r9, rcx; addr
	mov r10, rdx; length
	dec r10

	mov rcx, r10
printByte:
	push r9
	push r10
	push rcx
	add rcx, r9
	;
	call Byte2String; rcx - signed byte addr
	mov edx, 4 ; string lenth
	mov rsi, temp
	mov edi, 1
	mov eax, 1
	syscall ; WriteConsole
	;
	pop rcx
	pop r10
	pop r9
	loop printByte
	ret

Byte2String:
	mov r8, rcx
	mov rcx, 2
	mov al, '0'
	mov rdi, temp + 1
	cld
	rep stosb

	mov al, [r8]
	test al, 128
	je @f
	mov [temp], '-'
	neg byte [r8]
	inc byte [r8]
	and byte [r8], 0x7f
	jmp print_
@@:	mov [temp], ' '

print_: mov rbx, table
	xor rax, rax
	mov rdi, temp+2
	std
	mov al, [r8]
	and rax, 0xff
	mov rbp, rax
 .loop1:
	mov rax, rbp
	shr rbp, 4
	and rax, 0xf
	xlatb
	stosb
	test rbp,rbp
	jne .loop1

	mov rax, temp
	ret

segment readable writable

	title db 'Pause',0
	message db 'Press OK to continue...',0
	message_ends:
	number_string db 'Signed byte:',0
	temp db 3 dup ?, 10, 0
	trash dq ?

	hOutput dq ?

	A db 60 dup (31)
	B db 101 dup (32)
	table db '0123456789ABCDEF'
