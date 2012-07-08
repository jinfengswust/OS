[bits 32]
start_32:
	mov ax,0x10
	mov ds,ax
	mov word [gdtr],gdt_end-gdt
	mov dword [gdtr+2],gdt
	mov word [idtr],idt_end-idt
	mov dword [idtr+2],idt
	lgdt [gdtr]
	lidt [idtr]
	mov ax,0x10
	mov ds,ax
	mov es,ax
	mov ss,ax		; stack segment = data segment = code seg
	mov sp,stack_top
	mov ax,0x18
	mov gs,ax
	
	call setup_idt_timer
	call timer_init

	
	;call clr_scr
	;call welcome
	
	jmp $
	
welcome:
	mov esi,str_welcome
	sub edi,edi
	mov ah,0ch
rp_welcome:
	mov al,[esi]
	test al,al		; al & al = 0 ?
	jz end_welcome
	mov [gs:edi],ax
	inc esi
	add edi,2
	jmp rp_welcome
end_welcome:
	ret

clr_scr:
	xor ah,ah
	mov al,' '
	mov ecx,2000
	sub edi,edi
rp_clr:
	mov [gs:edi],ax
	add edi,2
	dec ecx
	jne rp_clr
	ret

setup_idt_timer:
	lea edx,[timer]
	mov eax,0x00080000
	mov ax,dx
	mov dx,0x8e00
	mov ecx,32	; int 40h, int 32
	lea edi,[idt+ecx*8]
	mov [edi],eax
	mov [edi+4],edx
	ret
	
timer_init:
	mov al,0x36
	mov dx,0x43
	out dx,al
	mov ax,11930	; 10ms
	mov dx,0x40
	out dx,al
	mov al,ah
	out dx,al
	ret
	
timer:
	mov ah,0ch
	mov al,'T'
	mov [gs:edi],ax
	iretd
	
;---------------------------------------------------------------------
;	data segment, ds:esi, r/w
;	��Ϊ���ݶκʹ�����ص�����ǰ��һ�����Ѿ�������θ��ǣ�����
;	���ݶ�str_welcome�ĵ�ַ���� 0�����Ǵ���ε�ַ��β����
;	��ջ�ΰ��������ݶ��У���16MB��ĩβ���֡�
;	ʵ�ʷֲ��������->���ݶ�->��ջ��

str_welcome:	db	"Hello, OS! Welcome to protected mode!",0

align 2
gdt:	dw 0,0,0,0						; 256*4*2bytes = 2KB
		dw 0x1000,0x0000,0x9a00,0x00c0	; 16MB
		dw 0x1000,0x0000,0x9200,0x00c0
		dw 0x0002,0x8000,0x920b,0x00c0
		times (256-4) dw 0,0,0,0
gdt_end:

idt:	times 256 dw 0,0,0,0			; 256 interrupts
idt_end:

gdtr:	dw 0,0,0
align 2
idtr:	dw 0,0,0

;---------------------------------------------------------------------
;	stack segment

stack_buttom:	times 512 dw 0	;1KB
stack_top: