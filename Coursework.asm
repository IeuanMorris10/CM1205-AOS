.586
.model flat, stdcall
option casemap :none
.stack 4096
ExitProcess proto,dwExitCode:dword

GetStdHandle proto :dword
ReadConsoleA  proto :dword, :dword, :dword, :dword, :dword
WriteConsoleA proto :dword, :dword, :dword, :dword, :dword

.data	

		STD_INPUT_HANDLE equ -10
		STD_OUTPUT_HANDLE equ -11

		
		asciiBuf db 4 dup (0)
		bufSize = 80
		buffer db bufSize dup(?)
		bytes_written dd ?
		bytes_read dd ?

		choiceTxt db "Centigrade to Farenheit(1), Farenheit to Centigrade(2)",13,10
		sum_string db "Converted degrees:",13,10
		invalid db "Invalid, please enter correct value",13,10
		userInput db "Enter value:",13,10

		outputHandle DWORD ?
		inputHandle DWORD ?
		
		actualNumber dw 0
		


		
		
.code


main	proc

		mov eax,0
		mov ebx,0
		mov ecx,0
		mov edx,0

		invoke GetStdHandle, STD_OUTPUT_HANDLE
		mov outputHandle, eax

		invoke GetStdHandle, STD_INPUT_HANDLE
 	    mov inputHandle, eax

		invoke WriteConsoleA, outputHandle, addr choiceTxt, LENGTHOF choiceTxt, addr bytes_written, 0

WhileLoop: 

invoke ReadConsoleA, inputHandle, addr buffer, bufSize, addr bytes_read, 0

		mov al, buffer
		cmp al, 31h
		jz centigrade
		cmp al, 32h
		jz farenheit
		

		invoke WriteConsoleA, outputHandle, addr invalid, LENGTHOF invalid, addr bytes_written, 0

		jmp WhileLoop

centigrade:

		call readString
		call ctof
		call writeString
		invoke ExitProcess,0

farenheit:

		call readString
		call ftoc
		call writeString
		invoke ExitProcess,0

main	endp


ctof			proc

		mov ax, actualNumber
		
		mov bx, 9
		mul bx
		mov bx, 5
		div bx
		add ax, 32
		mov actualNumber, ax

		ret

ctof			endp

ftoc			proc

		mov ax, actualNumber
		
		sub ax, 32
		mov bx, 5
		mul bx
		mov bx, 9
		div bx
		mov actualNumber, ax

		ret
	
ftoc			endp



readString 	proc

		invoke WriteConsoleA, outputHandle, addr userInput, LENGTHOF userInput, addr bytes_written, 0

		invoke ReadConsoleA, inputHandle, addr buffer, bufSize, addr bytes_read,0
		sub bytes_read, 2	; -2 to remove cr,lf
 		mov ebx,0
	
		mov al, byte ptr buffer+[ebx] 
		sub al,30h
		add	[actualNumber],ax

	getNext:

		inc	bx
		cmp ebx,bytes_read
		jz cont
		mov	ax,10
		mul	[actualNumber]
		mov actualNumber,ax
		mov al, byte ptr buffer+[ebx] 
		sub	al,30h
		add actualNumber,ax
		
		jmp getNext

	cont:

		ret

readString 	endp

writeString  proc

		invoke GetStdHandle, STD_OUTPUT_HANDLE
 	    mov outputHandle, eax
		mov	eax,LENGTHOF sum_string	;length of sum_string
		invoke WriteConsoleA, outputHandle, addr sum_string, eax, addr bytes_written, 0
		mov ax,[actualNumber]
		mov cl,10
		mov	bl,3

	nextNum:
		div	cl
		add	ah,30h
		mov byte ptr asciiBuf+[ebx],ah
		dec	ebx
		mov	ah,0
		cmp al,0
		ja nextNum
		
		mov	eax,4

 	    invoke WriteConsoleA, outputHandle, addr asciiBuf, eax, addr bytes_written, 0

		ret

writeString 	endp


end main