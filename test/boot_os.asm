;========================================
;			Start						;
[BITS 16]
entry:
	mov ax,(gdtr-gdt)
	mov word [gdtr],ax
	mov dword [gdtr+2],0x000007c00+gdt
	lgdt [gdtr]
	lidt [idtr]
	cli
	in al,92h
	or al,02h
	out 92h,al
	or eax,1
	mov cr0,eax
	jmp dword 0x08:0

;========================================
;			GDT							;
gdt:	dw 0,0,0,0
		dw 0x1000,0x7c00+start,0x9a00,0x00c0
		dw 0x1000,0x7c00+data,0x9200,0x00c0
		dw 0x1000,0x8000,0x920b,0x00c0
		
gdtr:	dw 0x0000,0x0000,0x0000
idtr:	dw 0x0000,0x0000,0x0000

;========================================
;			Start						;
[BITS 32]
start:
set_env:
	mov ax,0x10
	mov ds,ax
	mov ax,0x18
	mov gs,ax
clr_scr:
	mov ah,00h
	mov al,' '
	mov edi,(80*0+0)*2
	mov ecx,2000
rp_clr:
	mov word [gs:edi],ax
	inc edi
	inc edi
	dec ecx
	jne rp_clr
	
ok:
	mov ah,0ch
	mov al,'O'
	mov [gs:(80*3+39)*2],ax
	mov al,'K'
	mov [gs:(80*3+40)*2],ax
	
	jmp $
	
;========================================
data:	db 0
str_welcome:	db "Welcome! You are in protected mode!",0
;========================================


times 510-($-$$)	db		0
					dw 		0xaa55