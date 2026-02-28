	.globl __start__stack
	.globl _xstack
;--------------------------------------------------------
; Stack segment in internal ram
;--------------------------------------------------------
	.area	SSEG	(DATA)
__start__stack:
	.ds	1

 	.area VECTOR    (CODE)
	.globl __interrupt_vect
__interrupt_vect:
 	ljmp	__sdcc_gsinit_startup
 	ljmp	_isr_ext0	; 0x03
	.ds     5
	ljmp	_isr_timer0	; 0x0b
	.ds     5
	ljmp	_isr_ext1	; 0x13
	.ds     5
	reti			; 0x1b TIMER 1 IRQ
	.ds     7
 	ljmp    _isr_serial	; 0x23
	.ds     5
	ljmp	_isr_timer2	; 0x2b TIMER 2 IRQ
	.ds     5
	reti			; 0x33 NOT used by DW8051
	.ds     7
	reti			; 0x3b Serial port 1 RX/TX IRQ
	.ds     7
 	ljmp    _isr_ext2	; 0x43
	.ds     5
 	ljmp    _isr_ext3	; 0x4b

	.globl __start__stack

	.area GSINIT0 (CODE)

__sdcc_gsinit_startup::
	mov     a, #__start__stack
	mov     r0, #0x5a
__mark_istack:
	xch     a, r0
	mov     @r0, a
	inc     r0
	xch     a, r0
	jnz     __mark_istack

	mov     dptr, #_xstack
	mov     r2,#0
__mark_xstack:
	movx    @dptr, a
	inc     dptr
	inc     r0
	djnz    r2, __mark_xstack
	mov     sp,#__start__stack - 1

	.area GSFINAL (CODE)
        ljmp	_bootloader

__sdcc_banked_call::
	; Copy return address into XRAM stack
	mov	_XSTACK_DATA, _PSBANK  ; Save code bank
	pop	_XSTACK_DATA  ; Copy high byte IRAM -> XRAM
	pop	_XSTACK_DATA  ; Copy low byte IRAM -> XRAM
	; This assumes all banked calls use register bank 0
	push	0  ; Push R0 (address low byte)
	push	1  ; Push R1 (address high byte)
	mov _PSBANK, 2 ; Switch to bank R2
	ret

__sdcc_banked_ret::
	; Get return address from XRAM stack
	push _XSTACK_DATA  ; Copy low byte XRAM -> IRAM
	push _XSTACK_DATA  ; Copy high byte XRAM -> IRAM
	mov	_PSBANK, _XSTACK_DATA ; Restore code bank
	ret
