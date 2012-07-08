; 2012.6.30, Jinfeng @ SWUST
; nasm boot.asm -o boot.bin

	org 07c00h	; cs:ip = 07c00h
entry:
	; set env
	mov ax,cs
	mov ds,ax
	mov es,ax
	mov ss,ax
	mov sp,0x400
	
load_system:
	mov dx,0x0000
	mov cx,0x0002
	
	mov ax,0x1000
	mov es,ax
	xor bx,bx ; [es:bx]
	
	mov ax,0x0200+12		; 6KB
	int 0x13
	jnc move_system
try_again:
	jmp load_system
	
move_system:
	cli			; don't need BIOS func
				; will open just before 'ret' to task 0 in new mode
	cld
	mov ax,0x1000
	mov ds,ax
	xor ax,ax 
	mov es,ax
	mov cx,0x2000	; 1b x 8 x1024 > 1b x 6 x 1024
	sub si,si
	sub di,di
	rep movsb
	
load_gdtr:
	mov ax,0x0000
	mov ds,ax
	
	mov ax,(gdtr-gdt)
	mov word [gdtr],ax
	mov dword [gdtr+2],gdt	; not 0x7c00+gdt ?
	
	lidt [idtr]		; CPU request IDT before jump into new mode
	lgdt [gdtr]
	
	mov al,0x02 
	out 0x92,al		; open A20, enable 32-bit address
	
	mov ax,0x0001
	mov cr0,eax		; set PE flag in EFLAGS register
	
	jmp dword 0x08:0			; jmp to reset all registers in new mode

;end!!!

;-------------------------------------------------------------------------------------
;	data segment, r/w

gdt:	dw 0,0,0,0
		dw 0x1000,0x0000,0x9a00,0x00c0	; 16Mb,0x0000,r/x
		dw 0x1000,0x0000,0x9200,0x00c0	; 10MB,0x0000,r/w
		dw 0x0002,0x8000,0x920b,0x00c0	; 8kb,0xb8000, 4kb<-swap->4kb

gdtr:	dw 0x0000,0x0000,0x0000
idtr:	dw 0x0000,0x0000,0x0000

times 510-($-$$)	db		0
					dw 		0xaa55