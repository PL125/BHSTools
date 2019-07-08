# Load header files
< addrdefs.psc

@ head
	< macros.inc

< lib.psc

# Skip firmware integrity check (required for mods to work)
@ 5DBDE
	nop
	nop
@ 5DBE8
	nop
	nop
@ 5DBEE
	nop

# Allow the user to press a key to skip the 2 second delay after entering the installer code
# (Technically this NOPs a jump to force it to always use the SIA mode behavior here, which
#  is to wait for a key with a 60 second timeout. It also changes this timeout to 2 seconds.)
@ D4C8
	nop
	mov r8, #2

# Make hidden items selectable
@ 323EE
	db 0Dh
@ 3241A
	nop
@ 32462
	db 0Dh
@ 32490
	nop

# Make hidden parameters visible
@ 3297A
	nop
@ 3299A
	db 0Dh

# Use custom table for diagnostics menu
@ 80000
- Str_DiagItem4
	db '4 Exec Function ', 0
- Str_DiagItem5
	db '5 Write Memory  ', 0
- Str_DiagItem6
	db '6 Execute Code  ', 0
- Str_DiagItem7
	db '7 Run Quick Code', 0
- Str_DiagItem8
	db '8 System Reset  ', 0
- Str_DiagItem9
	db '9 Memory Browser', 0
- MnuTbl_Diag
	dw 481Fh, 6
	dw 480Eh, 6
	dw 47FDh, 6
	dw &:Str_DiagItem4, &^Str_DiagItem4
	dw &:Str_DiagItem5, &^Str_DiagItem5
	dw &:Str_DiagItem6, &^Str_DiagItem6
	dw &:Str_DiagItem7, &^Str_DiagItem7
	dw &:Str_DiagItem8, &^Str_DiagItem8
	dw &:Str_DiagItem9, &^Str_DiagItem9
	dw 5E61h, 0

@ 383E0
	mov r10, #&:MnuTbl_Diag
	mov r11, #&^MnuTbl_Diag  ; The original instruction here is 4 bytes for some reason, but this one assembles to 2.
	nop                      ; So we need to compensate by putting a NOP here.

# Hook diagnostic menu selection
@ 80100
- Str_EnterNewByte
	db 'New byte (0-255)', 0
- Str_ArbCodeExec
	db 'Enter up to 16 B', 0
- Code_DiagMenuHook
	< diaghook.asm

@ 38404
	jmps &+Code_DiagMenuHook

# Hook "Call statistic" screen
@ 80400
- Str_ModemCommand
	db 'Modem command   ', 0
- Code_CallStatHook
	< callstathook.asm

@ 3853E
	jmps &+Code_CallStatHook

@ 6431E
	db 0C4h, ':Cmd'

# Include "TIME" in LCD keypad POST
@ 68B5D
	db 15
