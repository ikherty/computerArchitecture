format ELF64 executable 3
entry start

segment readable executable
start:
	finit ;
	fldln2;st(0):=ln(2)
	fild [X];st(0):=X, st(1):=ln(2)
	fyl2x;st(0):=st(1)*log2(st(0))=ln(2)*log2(x)
	fimul dword ptr Y;st(0):=ln(2)*log2(x)*Y
	FLDL2E;st(0):=log2(e) st(1):=ln(2)*log2(x)*Y
	FMULP ST(1),ST(0);st(0):=ln(2)*log2(x)*Y*log2(e)
	FLD ST(0);copy the logarithm; st(1):=st(0):=ln(2)*log2(x)*Y*log2(e)
	FRNDINT;keep only the characteristic
	FSUB ST(1),ST(0);keeps only the mantissa
	FXCH ST(1);get the mantissa on top
	F2XM1;->2^(mantissa)-1
	FLD1;st(0)=1.0
	FADDP ST(1),ST(0);add 1 back
;the number must now be readjusted for the characteristic of the logarithm
	FSCALE;scale it with the characteristic
	mov edi, buffer
	fbstp Data_BCD		;извлечь число в коде BCD
	mov ecx,9               ;в десятом байте информация о знаке числа
b2: cmp byte ptr [ecx-1+Data_BCD],0
	jnz b3         
	loop b2      		;пропускаем незначащие (нулевые) разряды слева
b3:	mov al,byte ptr [ecx-1+Data_BCD];загружаем первую значащую пару разрядов
    cmp al,9  ;если в старшей тетраде 0 - пропустить старшую тетраду
	ja b4
	add al,30h		;младшую тетраду переводим в ASCII
	stosb
	dec ecx
b4:     xor ax,ax		;распаковываем остальные разряды числа
	mov al,byte ptr [ecx-1+Data_BCD]
	shl ax,4    		;выделяем старшую и младшую тетрады
	shr al,4
	add ax,3030h		;переводим в ASCII-код
	xchg ah,al;обмен значениями между операндами
	stosw
	loop b4
a2:	mov ax,3;очищаю экран
	int 10h
	mov ah,9; вывожу результат
	mov edx, buffer
	int 21h
	mov ah,0; жду нажатия на любую клавишу
	int 16h	
	ret; выхожу из программы
segment readable writable
buffer	db 25 dup ('$')
X dd 81
Y dd 9;81^9=22876792454961=14CE6B167F31h
;Data_BCD dt 0;число в BCD-формате
;end start
