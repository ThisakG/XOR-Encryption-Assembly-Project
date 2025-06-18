;Encrypt/Decrypt program created using assembly language for file encryption and decryption
;Prompts the user to enter input filename, output filename and the key
;The program reads the input file in chunks, XORs each byte with the key (the key is multi-byte) and write the result into the output file
;The same program can be used to decrypt the encrypted file using the same key


section .bss
	input_file_name resb 256 	;the buffer that stores the input filename
	output_file_name resb 256 	;the buffer that stores the output filename
	key resb 64 			;buffer to store XOR key entered by the user
	key_len resb 1 			;1 byte used to store the length of the key 
	buffer resb 512 		;the buffer that reads blocks of the file 

section .data
	prompt_input db "Enter input filename: ",0	;prompt string for input filename
	prompt_input_len equ $ - prompt_input 		;length of the input string

	prompt_output db "Enter output filename: ",0	;prmpt string for output filename
	prompt_output_len equ $ - prompt_output		;length of the output string

	prompt_key db  "Enter the XOR key: ",0 		;prompt string for the XOR key
	prompt_key_len equ $ - prompt_key 		;length of the XOR key

	newline db 10					;create a 1-byte constant to detect or remove newlines for user inputs 

section .text
	global _start

_start:

	;prompt for input filename
		mov rdi, prompt_input 		;pointer to the input filename prompt string
		mov rsi, prompt_input_len	;length of the input string
		call print_string		;prints the string "Enter input filename: "

		mov rdi, input_file_name 	;buffer to store the user input
		mov rsi, 255 			;maximum amount of bytes to read
		call read_line			;reads a line from stdin and stores in input_file_name

	;prompt for output filename
		mov rdi, prompt_output          ;pointer to the output filename prompt string
                mov rsi, prompt_output_len      ;length of the output  string
                call print_string               ;prints the string "Enter output filename: "

                mov rdi, output_file_name       ;buffer to store the user input
                mov rsi, 255                    ;maximum amount of bytes to read
                call read_line                  ;read output filename

	;prompt for XOR key
		mov rdi, prompt_key
		mov rsi, prompt_key_len 
		call print_string

		mov rdi, key
		mov rsi, 63 			;maximum key length
		call read_line 			;read XOR key string

	;calculating the key length
		mov rcx, 0 			;set counter to 0
	find_key_len: 				;label used for jumping
		mov al, [key+rcx] 		;get key character when it is at position rcx
		cmp al, 10 			;check if it is a newline character
		je .key_len_found		;if it is a newline, end of the key input
		cmp al, 0 			;check if null terminator
		je .key_len_found
		inc rcx				;increment the counter
		cmp rcx, 63 			; maximum key length limit
		jne find_key_len		;loop again if less than the maximum

	.key_len_found:
		mov [key_len], cl 		;store the key length in the key_len variable

	;opening the input file 
		mov rax, 2 			;syscall number for sys_open
		mov rdi, input_file_name 	;pointer to the filename
		mov rsi, 0			;O_RDONLY = opens the file fofr read-only access
		mov rdx, 0			; just a placeholder, only needed if O_CREAT flag is present
		syscall				;perform the syscall
		mov r12, rax			;store input file descriptor in r12 (gen-purpose registers)

	;opening the output file
		mov rax, 2			;sys_open
		mov rdi, output_file_name
		mov rsi, 0x241			;flags for O_WRONGLY (0x200) | O_CREAT (0x40) | O_TRUNC (0x1)
		mov rdx, 0644			; setting file permission to rw-r--r--
		syscall
		mov r13, rax			;store output file descriptor r13

	;starting the file processing loop
		mov r14, 0 			;counter with total processed bytes (this is optional)
	process_loop:
	;reading from the input file
		mov rax, 0			;sys_call for sys_read
		mov rdi, r12			;input file descripter
		mov rsi, buffer 		;buffer that stores read data
		mov rdx, 512			;read upto 512 bytes (max)
		syscall
		cmp rax, 0			; if no bytes are read, EOF is reached
		je done
		mov r15, rax			;save the number of bytes read in r15

	;XOR encryption- decryption process
		xor rbx, rbx 			;buffer index with the byte position
	xor_loop:
		cmp rbx, r15			;if all byte sprocessed, exit loop
		jge write_chunk

		mov al, [buffer + rbx] 		;read current byte from buffer
		movzx ecx, byte [key_len]
		test ecx, ecx
		jz .no_key			;if key length is zero, skip the XOR function 

		mov eax, ebx		 	;get key byte cyclically to mod the key length
		xor edx, edx
		div ecx

		mov dl, [key + rdx]
		xor al, dl 			;XOR data byte with the key byte

	.no_key:
		mov [buffer + rbx], al 		;store the XORed byte back to the buffer
		inc rbx
		jmp xor_loop

	write_chunk:
	;write the XORed buffer back to the output file
		mov rax, 1			;syscall for sys_write
		mov rdi, r13			;output file descripter
		mov rsi, buffer			;buffer to write
		mov rdx, r15			;number of bytes to write
		syscall

		jmp process_loop		;repeat loop to read the next block

	done:
	;closing the files
		mov rax, 3 			;sys_call for sys_close
		mov rdi, r12			;close the input file
		syscall

		mov rax, 3
		mov rdi, r13			;close the output file
		syscall

	;exiting the program
		mov rax, 60			;syscall for sys_exit
		xor rdi, rdi			;exit code 0
		syscall


	;helper function for the print_string
	;print the string at rdi with length at rsi
		print_string:
			mov rdx, rsi		;move length of string to rdx
			mov rsi, rdi		;move string pointer to rsi
			mov rdi, 1		;stdout
			mov rax, 1		;sys_write syscall
			syscall
			ret


	;helper function for the read_line
	;reads the line of input from stdin into buffer at rdi up to the max length at rsi
	;removes the trailing newline bt replacing it with a null terminator
		read_line:
			mov rax, 0			;sys_read syscall
			mov  rdx, rsi
			mov rsi, rdi
			mov rdi, 0
			syscall

			cmp rax, 0			;if no bytes to read, return immeadiately
			je .ret_read

			mov rcx, rax			;number of bytes to read
			dec rcx				;last character index
			mov al, [rsi + rcx] 		;last character read
			cmp al, 10			;check for newline
			jne .skip_null
			mov byte [rsi + rcx], 0 	;replace newline with null terminator
			jmp .ret_read
		
		.skip_null:
			mov byte [rsi + rax], 0
		.ret_read:
			ret













