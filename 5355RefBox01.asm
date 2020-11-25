
    #include p16f883.inc
    __config H'2007', 0x23F4
    __config H'2008', 0X3EFF

	ERRORLEVEL -302

; CONFIG1

; 15 0 not used
; 14 0 not used
; 13 1 Debug not  implemented
; 12 0 LVP not implemented            2

; 11 0 Fail safe monitor disabled
; 10 0 IESO Disabled
;  9 1 Brown-out reset enabled
;  8 1 Brown-out reset enabled        3

; 7 1 Data code protection disabled 
; 6 1 Program code protection disabled 
; 5 1 MCLR enabled
; 4 1 Power-up timer disabled         F

; 3 0 Watchdog timer disabled
; 210 100 INTOSCIO Oscillator         4

; CONFIG2

; 15-12 not used                      3

; 11 not used
; 10 1 Flash write protection off
; 9  1 Flash write protection off
; 8  0 Brown-out Reset set to 2.1V    E

; 7 - 4 not used                      F

; 3 - 0 not used                      F


; Use 16F883 without a crystal
;
; Channel Switch connected to RC4 - RC7 and RB0 - RB7
; Channels 0 (RC4) - 11 (RB7) active low.  Weak Pull-ups will be set on RB0-7.  RC4 to 7 will need pull-up resistors.
; 
; Ref Switch on RC2 (LSB) and RC3 (MSB).  These will need pull ups. 
; 
;
; RA0 pin 2 Clock
; RA1 pin 3 Data
; RA2 pin 4 LE
;
; RC0 - RC1 not used
; RA3 - RA7 not used

; Definitions

;-------PIC Registers-------------------------

INDR	EQU	0x00	; the indirect data register
PCL	EQU	0x02	; program counter low bits
STATUS	EQU	0x03	; Used for Zero bit
FSR	EQU	0x04	; the indirect address register
PORTA	EQU	0x05	; 
PORTB	EQU	0x06	; 
PORTC	EQU	0x07	; 
PCLATH	EQU	0x0A	; Program Counter High Bits
INTCON	EQU	0x0B	; Interrupt Control
T1CON	EQU	0x10	; Counter Control
REGOPT	EQU	0x81	; Bank 01
TRISA   EQU     0x85	; Bank 01
WPUB	EQU	0x95	; Bank 01
ADCON1  EQU     0x9F
EEDAT   EQU     0x010C
EEADR   EQU     0x010D
EEDATH  EQU     0x010E
EEADRH  EQU     0x010F
EECON1  EQU     0x018C
EECON2  EQU     0x018D

;-------PIC Bits--------------------------------

W	EQU	0	; indicates result goes to working register
F	EQU	1	; indicates result goes to file (named register)
CARRY   EQU	0
ZERO	EQU	2

RP1     EQU     0x06
RP0     EQU     0x05
EEPGD   EQU     0x07
WREN    EQU     0x02
WR      EQU     0x01
RD      EQU     0x00

;-------Project Registers------------------

PTCSW	EQU	0x20   	; Port C switch state as read
PTBSW	EQU	0x21	; Port B switch state as read 
RETCH	EQU	0x22	; Channel state read from switches
PREVCH	EQU	0x23	; Last set channel - disposable
PREVCH2	EQU	0x24	; Last set channel - non-disposable
CURRCH	EQU	0x25	; The current switch state before debounce
NEWCH	EQU	0x26	; The current switch state after debounce delay
T1	EQU	0x27	; Counter in DEL1M
T2	EQU	0x28	; Counter in DELPT1
CNT8S	EQU	0x29	; Counter for bytes in 32-bit word
BITCNT	EQU	0x2A	; Counter of bits in each byte
SHIFTR	EQU	0x2B	; Shift register used for data bits in each word
BYTE1	EQU	0x2C	; Most significant 8 bits of 32-bit word
BYTE2	EQU	0x2D	; Next significant 8 bits of 32-bit word
BYTE3	EQU	0x2E	; Next significant 8 bits of 32-bit word
BYTE4	EQU	0x2F	; Least significant 8 bits of 32-bit word
LUPAGE	EQU	0x30	; Page for Lookups
;	EQU	0x31	; 
PREVREF	EQU	0x32	; Last set Ref - disposable
PREVRF2	EQU	0x33	; Last set Ref - non-disposable
CURREF	EQU	0x34	; The current Ref switch state before debounce
NEWREF	EQU	0x35	; The current Ref switch state after debounce delay
RETREF	EQU	0x36	; Used to handle Ref switch value
OFFS	EQU	0x37	; The look-up offset for the selected channel
LPCNT	EQU	0x38	; loop counter
BOFFS	EQU	0x39	; Byte offset
;	EQU	0x3A	; 
;	EQU	0x3B	; 
;	EQU	0x3C	; 
;	EQU	0x3D	; 
;	EQU	0x3E	; 
;	EQU	0x3F	; 
;	EQU	0x40	; 
;	EQU	0x41	; 
;	EQU	0x42	; 
;	EQU	0x43	; 
;	EQU	0x44	; 
;	EQU	0x45	;
;	EQU	0x46	;
;	EQU	0x47	;
;	EQU	0x48	; 
;	EQU	0x4A	; 
;	EQU	0x4B	; 
;	EQU	0x4C	; 
;	EQU	0x4D	; 
;	EQU	0x4E	; 
;	EQU	0x4F	; 
;	EQU	0x52	; 
;	EQU	0x53	; 
;	EQU	0x54	;  
;	EQU	0x55	;  
;	EQU	0x70	; 
;	EQU	0x0170	; 
;	EQU	0x71	; 
;	EQU	0x0171	; 

;-------Project Bits-------------------------

;	None

;-------START of Program--------------------

        ORG	0x00		; Load from Program Memory 00 onwards
	GOTO	INIT

;-------Interrupt Vector--------------------
; Not used
	
;------ Set up Internal Oscillator -----------------

        ORG	0x10		; Load from Program Memory 10 onwards
INIT	BSF 	3, 5		; Bank x1
	BCF	3, 6		; Bank 01 (1)

	MOVLW	0x61		; 4 MHz, 
	MOVWF	OSCCON		; and set it

	BCF	3, 5		; Go back to Register Bank x0

;------ Set up IO Ports -----------------

	CLRF	PORTA		; Clear output latches
	CLRF	PORTB   	; 
	CLRF	PORTC   	; 

	BSF 	3, 5		; Bank x1
	BCF	3, 6		; Bank 01 (1).  Now set Port directions

	MOVLW 	0x00 		; Initialize data direction
	MOVWF 	TRISA     	; Set RA0-7 as outputs

	MOVLW 	0xFF 		; Initialize data direction
	MOVWF 	TRISB     	; Set RB0-7 as inputs

	MOVLW	0x7F		; Enable Port B weak pull ups
	MOVWF	REGOPT

	MOVLW	0xFF		; Turn on Port B weak pull ups
	MOVWF	WPUB

	MOVLW 	0xFC 		; Initialize data direction
	MOVWF 	TRISC     	; Set RC0-1 as outputs (not used), RC2-7 as inputs

	BSF	3, 6		; Bank 11 (3)

	MOVLW	0x00
	MOVWF	ANSEL		; Disable analog inputs on PORT A
	
	MOVLW	0x00
	MOVWF	ANSELH		; Disable analog inputs on PORT B
	
	BCF	3, 5		; Go back to Register Bank x0
	BCF	3, 6		; Bank 00 (0).

	BSF	PORTA, 2	; Set ADF5355 LE High (static condition)

;------ Wait for lines to settle ---------------------------------

	CALL	DELPT1		; Wait 0.1 seconds

;------ Read Current channel selection for startup ----------------------------

	CALL	RDCHAN		; returns channel selection (0 - 11) in W
					
	MOVWF	PREVCH		; Record the previous channel state
	MOVWF	PREVCH2		; Record the previous channel state again
	MOVWF	CURRCH		; Record the current channel state

	CALL	RDREF		; returns the Ref selection (0 - 3) in W
					
	MOVWF	PREVREF		; Record the previous Ref state
	MOVWF	PREVRF2		; Record the previous Ref state again
	MOVWF	CURREF		; Record the current Ref state

	CALL	SENDALL		; Start the ADF5355 with the initial switch settings
	
;------ Now monitor the switches for any changes -----

MONSW	CALL 	DELPT1		; Delay 0.1 sec before next check

	CALL	RDCHAN		; Read current channel switch state
	MOVWF	CURRCH		; Record the current channel state

	SUBWF	PREVCH, F	; Returns 0 if no change
	BTFSS	STATUS, ZERO	; Skip next if no change
	GOTO	DEBCHAN		; It's changed, so go and debounce it

				; Not changed, so
	MOVF	PREVCH2, W	; Copy the previous channel state
	MOVWF	PREVCH		; back into PREVCH

	GOTO	CHKREF		; Go and check if the reference has changed

;------ Channel Switch had changed, so debounce and act if stable -------------------------

DEBCHAN	CALL	DELPT1		; Wait 100ms

	CALL	RDCHAN		; Read the latest switch state
	MOVWF	NEWCH		; Store new state
	SUBWF	CURRCH, F	; Returns 0 if state stable
	BTFSS	STATUS, ZERO	; skip next if state stable
	GOTO	MONSW		; unstable, so try again

				; it has changed and is stable, so
	MOVF	NEWCH, W	; Put the new channel in W
	MOVWF	PREVCH		; Record the channel state
	MOVWF	PREVCH2		; Record the channel state again
	MOVWF	CURRCH		; Record the channel state again

	CALL	SENDALL		; so set the new frequency (which acts on CURRCH and CURREF)
	GOTO	MONSW		; and go and check again

;------ Channel switch has not changed so check reference switch -------------------

CHKREF	NOP

	CALL	RDREF		; Read current Reference switch state
	MOVWF	CURREF		; Record the current reference state

	SUBWF	PREVREF, F	; Returns 0 if no change
	BTFSS	STATUS, ZERO	; Skip next if no change
	GOTO	DEBREF		; It's changed, so go and debounce it

				; Not changed, so
	MOVF	PREVRF2, W	; Copy the previous channel state
	MOVWF	PREVREF		; back into PREVREF

	GOTO	MONSW		; and listen for changes again

;------ Ref switch has changed, so debounce and act if stable ------------------------

DEBREF	CALL DELPT1		; Wait 100ms

	CALL	RDREF		; Read the latest switch state
	MOVWF	NEWREF		; Store new state
	SUBWF	CURREF, F	; Returns 0 if state stable
	BTFSS	STATUS, ZERO	; skip next if state stable
	GOTO	MONSW		; unstable, so try again

				; it has changed and is stable, so
	MOVF	NEWREF, W	; Put the new Reference in W
	MOVWF	PREVREF		; Record the channel state
	MOVWF	PREVRF2		; Record the channel state again
	MOVWF	CURREF		; Record the channel state again

	CALL	SENDALL		; so set the new frequency (which acts on CURRCH and CURREF)
	GOTO	MONSW		; and go and check again

;------ Main loop never gets beyond here ------------------------------------------
;----------------------------------------------------------------------------------

; ----- DEL1M - DELAY 1 MILLISECOND -------------------------------------

;	Each instruction is 1 microsecond (4 MHz/4)
;	So delay 1000 instruction steps including call and return

DEL1M	MOVLW	0xF8	; 3 LOAD 248 (times 4 = 992 cycles)
	MOVWF	T1	; 4 INTO W and then T1
DEL1ML	NOP		; 5     9         993 NOP for extra cycle (4)
	DECFSZ	T1, F	; 6     10        994 Decrement T1, is it zero?
	GOTO	DEL1ML	; 7, 8  11, 12        No, so do it again
	NOP		; Yes so return   996
	NOP		;                 997
	NOP		;                 998
	RETURN		;                 999, 1000

; ----- End of DEL1M ----------------------------------------------------


; ----- DELPT1 - DELAY 100 MILLISECOND -------------------------------------

DELPT1	MOVLW	0x64	; LOAD 100 to wait 100 ms
	MOVWF	T2	; INTO W and then T2
DELPT1L	CALL	DEL1M	; Delay 1 millisecond
	DECFSZ	T2, F	; Decrement T2, is it zero?
	GOTO	DELPT1L	; No, so do it again
	RETURN		; Yes so return

; ----- End of DEL1M ----------------------------------------------------



;------ RDCHAN ----------------- Called to read the channel ----------------

; Returns channel number (0 - 11) in W

RDCHAN	NOP			; Checks and acts on switches and buttons

	MOVF	PORTC, W	; Read switches
        MOVWF	PTCSW		; Move into Port C Switch variable

	MOVF	PORTB, W	; Read switches
        MOVWF	PTBSW		; Move into Port B Switch variable

TCH1	MOVF	PTCSW, W	; Move Port C Switches into W
	ANDLW	0x10		; Mask in RC4 = Chan 1 return 0
	BTFSS	STATUS, ZERO	; skip next if Chan 1 selected
	GOTO	TCH2		; go and test for channel 2

	MOVLW	0x00		; Move 0 into W
	MOVWF	RETCH		; and move into return channel value
	GOTO	PREPRTN		; clean up and return

TCH2	MOVF	PTCSW, W	; Move Port C Switches into W
	ANDLW	0x20		; Mask in RC5 = Chan 2 return 1
	BTFSS	STATUS, ZERO	; skip next if Chan 2 selected
	GOTO	TCH3		; go and test for channel 3

	MOVLW	0x01		; Move 1 into W
	MOVWF	RETCH		; and move into return channel value
	GOTO	PREPRTN		; clean up and return

TCH3	MOVF	PTCSW, W	; Move Port C Switches into W
	ANDLW	0x40		; Mask in RC6 = Chan 3 return 2
	BTFSS	STATUS, ZERO	; skip next if Chan 3 selected
	GOTO	TCH4		; go and test for channel 4

	MOVLW	0x02		; Move 2 into W
	MOVWF	RETCH		; and move into return channel value
	GOTO	PREPRTN		; clean up and return

TCH4	MOVF	PTCSW, W	; Move Port C Switches into W
	ANDLW	0x80		; Mask in RC7 = Chan 4 return 3
	BTFSS	STATUS, ZERO	; skip next if Chan 4 selected
	GOTO	TCH5		; go and test for channel 5

	MOVLW	0x03		; Move 3 into W
	MOVWF	RETCH		; and move into return channel value
	GOTO	PREPRTN		; clean up and return

TCH5	MOVF	PTBSW, W	; Move Port B Switches into W
	ANDLW	0x01		; Mask in RB0 = Chan 5 return 4
	BTFSS	STATUS, ZERO	; skip next if Chan 5 selected
	GOTO	TCH6		; go and test for channel 6

	MOVLW	0x04		; Move 4 into W
	MOVWF	RETCH		; and move into return channel value
	GOTO	PREPRTN		; clean up and return

TCH6	MOVF	PTBSW, W	; Move Port B Switches into W
	ANDLW	0x02		; Mask in RB1 = Chan 6 return 5
	BTFSS	STATUS, ZERO	; skip next if Chan 6 selected
	GOTO	TCH7		; go and test for channel 7

	MOVLW	0x05		; Move 5 into W
	MOVWF	RETCH		; and move into return channel value
	GOTO	PREPRTN		; clean up and return

TCH7	MOVF	PTBSW, W	; Move Port B Switches into W
	ANDLW	0x04		; Mask in RB2 = Chan 7 return 6
	BTFSS	STATUS, ZERO	; skip next if Chan 7 selected
	GOTO	TCH8		; go and test for channel 8

	MOVLW	0x06		; Move 6 into W
	MOVWF	RETCH		; and move into return channel value
	GOTO	PREPRTN		; clean up and return

TCH8	MOVF	PTBSW, W	; Move Port B Switches into W
	ANDLW	0x08		; Mask in RB3 = Chan 8 return 7
	BTFSS	STATUS, ZERO	; skip next if Chan 8 selected
	GOTO	TCH9		; go and test for channel 9

	MOVLW	0x07		; Move 7 into W
	MOVWF	RETCH		; and move into return channel value
	GOTO	PREPRTN		; clean up and return

TCH9	MOVF	PTBSW, W	; Move Port B Switches into W
	ANDLW	0x10		; Mask in RB4 = Chan 9 return 8
	BTFSS	STATUS, ZERO	; skip next if Chan 9 selected
	GOTO	TCH10		; go and test for channel 10

	MOVLW	0x08		; Move 8 into W
	MOVWF	RETCH		; and move into return channel value
	GOTO	PREPRTN		; clean up and return

TCH10	MOVF	PTBSW, W	; Move Port B Switches into W
	ANDLW	0x20		; Mask in RB5 = Chan 10 return 9
	BTFSS	STATUS, ZERO	; skip next if Chan 10 selected
	GOTO	TCH11		; go and test for channel 11

	MOVLW	0x09		; Move 9 into W
	MOVWF	RETCH		; and move into return channel value
	GOTO	PREPRTN		; clean up and return

TCH11	MOVF	PTBSW, W	; Move Port B Switches into W
	ANDLW	0x40		; Mask in RB6 = Chan 11 return 10
	BTFSS	STATUS, ZERO	; skip next if Chan 11 selected
	GOTO	TCH12		; go and test for channel 12

	MOVLW	0x0A		; Move 10 into W
	MOVWF	RETCH		; and move into return channel value
	GOTO	PREPRTN		; clean up and return

TCH12	MOVF	PTBSW, W	; Move Port B Switches into W
	ANDLW	0x80		; Mask in RB7 = Chan 12 return 11
	BTFSS	STATUS, ZERO	; skip next if Chan 12 selected
	GOTO	SET0		; No channel selected, so select 0

	MOVLW	0x0B		; Move 11 into W
	MOVWF	RETCH		; and move into return channel value
	GOTO	PREPRTN		; clean up and return
	
SET0	CLRF	RETCH		; Set Channel to zero for non-selected case
	
PREPRTN	MOVF	RETCH, W	; Move the channel into W

	RETURN			; with channel number in W

;-----------------------------------------------------------------------------

;------ RDREF ----------------- Called to read the Ref Freq Switch ----------------

; Returns Ref Freq number (0 - 2) in W

RDREF	NOP			; Checks and acts on switches and buttons

	MOVF	PORTC, W	; Read switches
        ANDLW	0x0C		; mask in RC2 and RC3
	MOVWF	RETREF		; Move to RETREF 
	BCF	STATUS, CARRY	; Clear the carry bit
	RRF	RETREF, F	; Rotate right twice
	RRF	RETREF, F	;

        MOVF	RETREF, W	; Value is 0, 1 2 or 3
	SUBLW	0x03		; Set zero bit if RETREF is 3
	BTFSC	STATUS, ZERO	; Skip next if not zero
	CLRF	RETREF		; if RETREF was 3, set it to 0

        MOVF	RETREF, W	; Return the value as 0 to 2 in W

        RETURN

; -----------------------------------------------------------------------

;------ SENDALL sends the 13 32-bit words to the ADF5355 ------------------
SENDALL	NOP

; Calculate the Page for lookup

	MOVF	CURREF, W	; 0 - 2
	MOVWF	LUPAGE		; Move into the LUPAGE
        BCF	STATUS, CARRY	; Clear the carry bit
	RLF	LUPAGE, F	; Multiply LUPAGE by 2 (now 0, 2, 4)
	MOVLW	0x04		; Put 4 into W
	ADDWF	LUPAGE		; and add to LUPAGE (now 4, 6, 8)

	BTFSC	CURRCH, 3	; Skip next if CURRCH < 8
	INCF	LUPAGE, F	; Channel is 8, 9, 10 or 11 so increment LUPAGE
				; so now 5, 7 or 9

; Now calculate the base offset for the channel within the lookup

	MOVF	CURRCH, W	; 0 - 11
	ANDLW	0x07		; now 0 - 7 and 0 - 3

	MOVWF	LPCNT		; Put the value in the loop counter
	CLRF	OFFS		; zero the offset

ADDLP	MOVLW	0x00		; Put 0 in W
	SUBWF	LPCNT, F	; subtract it from LPCNT and check if zero
	BTFSC	STATUS, ZERO	; if LPCNT is zero do not add anything
	GOTO	SENDS		; and go and send the registers

	MOVLW	0x1C		; Not zero so we need to add 28
	ADDWF	OFFS, F		; to the offset
	DECF	LPCNT, F	; and decrement the loop count
	GOTO	ADDLP

SENDS	CALL	SENDR12		; Send Register 12
	CALL	SENDR11		; Send Register 11
	CALL	SENDR10		; Send Register 10
	CALL	SENDR9		; Send Register 9
	CALL	SENDR8		; Send Register 8
	CALL	SENDR7		; Send Register 7
	CALL	SENDR6		; Send Register 6
	CALL	SENDR5		; Send Register 5
	CALL	SENDR4		; Send Register 4
	CALL	SENDR3		; Send Register 3
	CALL	SENDR2		; Send Register 2
	CALL	SENDR1		; Send Register 1
	CALL	SENDR0		; Send Register 0

	RETURN
;-------------------------------------------------------------------------

;------ LUBYTE looks up each byte of the selected 32 but word ------------

LUBYTE	NOP

TP4	MOVF	LUPAGE, W
	SUBLW	0x04		; set zero flag if Page 4
	BTFSS	STATUS, ZERO	; Skip next if page 4
	GOTO	TP5		; if not page 4, try page 5

	MOVLW	0x04		; 
	MOVWF	PCLATH		; Set page 4
	MOVF	BOFFS, W	; Load the offset
	CALL	LUREF1A		; Look up the byte
	GOTO	DUNLU		; and return

TP5	MOVF	LUPAGE, W
	SUBLW	0x05		; set zero flag if Page 5
	BTFSS	STATUS, ZERO	; Skip next if page 5
	GOTO	TP6		; if not page 5, try page 6

	MOVLW	0x05		; 
	MOVWF	PCLATH		; Set page 5
	MOVF	BOFFS, W	; Load the offset
	CALL	LUREF1B		; Look up the byte
	GOTO	DUNLU		; and return

TP6	MOVF	LUPAGE, W
	SUBLW	0x06		; set zero flag if Page 6
	BTFSS	STATUS, ZERO	; Skip next if page 6
	GOTO	TP7		; if not page 6, try page 7

	MOVLW	0x06		; 
	MOVWF	PCLATH		; Set page 6
	MOVF	BOFFS, W	; Load the offset
	CALL	LUREF2A		; Look up the byte
	GOTO	DUNLU		; and return

TP7	MOVF	LUPAGE, W
	SUBLW	0x07		; set zero flag if Page 7
	BTFSS	STATUS, ZERO	; Skip next if page 7
	GOTO	TP8		; if not page 7, try page 8

	MOVLW	0x07		; 
	MOVWF	PCLATH		; Set page 7
	MOVF	BOFFS, W	; Load the offset
	CALL	LUREF2B		; Look up the byte
	GOTO	DUNLU		; and return

TP8	MOVF	LUPAGE, W
	SUBLW	0x08		; set zero flag if Page 8
	BTFSS	STATUS, ZERO	; Skip next if page 8
	GOTO	TP9		; if not page 8, try page 9

	MOVLW	0x08		; 
	MOVWF	PCLATH		; Set page 8
	MOVF	BOFFS, W	; Load the offset
	CALL	LUREF3A		; Look up the byte
	CLRF	PCLATH		; Return from High page, so clear PCLATH
	GOTO	DUNLU		; and return

TP9	MOVF	LUPAGE, W
	SUBLW	0x09		; set zero flag if Page 9
	BTFSS	STATUS, ZERO	; Skip next if page 9
	GOTO	DUNLU		; if not page 9, return

	MOVLW	0x09		; 
	MOVWF	PCLATH		; Set page 9
	MOVF	BOFFS, W	; Load the offset
	CALL	LUREF3B		; Look up the byte
	CLRF	PCLATH		; Return from High page, so clear PCLATH

;	GOTO	DUNLU		; and return

DUNLU	INCF	BOFFS, F	; increment the offset, then
	RETURN			; return with value in W

; -----------------------------------------------------------------------

;------ SENDR0 to SENDR12 look up the values ad send each register value ---
SENDR0	NOP			; Send Register 0
				; 0x00200680

	MOVF	OFFS, W		; Put the channel offset in W
	ADDLW	0x00		; Add the byte look-up offset
	MOVWF	BOFFS		; and store in byte offset

	CALL	LUBYTE		; so populate BYTE1 - BYTE4
	MOVWF	BYTE1
	CALL	LUBYTE
	MOVWF	BYTE2
	CALL	LUBYTE
	MOVWF	BYTE3
	CALL	LUBYTE
	MOVWF	BYTE4

	CALL	SENDWD		; and send them
	RETURN

SENDR1	NOP			; Send Register 1
	MOVF	OFFS, W		; Put the channel offset in W
	ADDLW	0x04		; Add the byte look-up offset
	MOVWF	BOFFS		; and store in byte offset

	CALL	LUBYTE		; so populate BYTE1 - BYTE4
	MOVWF	BYTE1
	CALL	LUBYTE		; so populate BYTE1 - BYTE4
	MOVWF	BYTE2
	CALL	LUBYTE		; so populate BYTE1 - BYTE4
	MOVWF	BYTE3
	CALL	LUBYTE		; so populate BYTE1 - BYTE4
	MOVWF	BYTE4
	CALL	SENDWD		; and send them
	RETURN

SENDR2	NOP			; Send Register 2
	MOVF	OFFS, W		; Put the channel offset in W
	ADDLW	0x08		; Add the byte look-up offset
	MOVWF	BOFFS		; and store in byte offset

	CALL	LUBYTE		; so populate BYTE1 - BYTE4
	MOVWF	BYTE1
	CALL	LUBYTE		; so populate BYTE1 - BYTE4
	MOVWF	BYTE2
	CALL	LUBYTE		; so populate BYTE1 - BYTE4
	MOVWF	BYTE3
	CALL	LUBYTE		; so populate BYTE1 - BYTE4
	MOVWF	BYTE4
	CALL	SENDWD		; and send them
	RETURN

SENDR3	NOP			; Send Register 3
				; Always 0x00000003
	MOVLW	0x00		; so populate BYTE1 - BYTE4
	MOVWF	BYTE1
	MOVLW	0x00
	MOVWF	BYTE2
	MOVLW	0x00
	MOVWF	BYTE3
	MOVLW	0x03
	MOVWF	BYTE4
	CALL	SENDWD		; and send them
	RETURN

SENDR4	NOP			; Send Register 4
	MOVF	OFFS, W		; Put the channel offset in W
	ADDLW	0x0C		; Add the byte look-up offset
	MOVWF	BOFFS		; and store in byte offset

	CALL	LUBYTE		; so populate BYTE1 - BYTE4
	MOVWF	BYTE1
	CALL	LUBYTE		; so populate BYTE1 - BYTE4
	MOVWF	BYTE2
	CALL	LUBYTE		; so populate BYTE1 - BYTE4
	MOVWF	BYTE3
	CALL	LUBYTE		; so populate BYTE1 - BYTE4
	MOVWF	BYTE4
	CALL	SENDWD		; and send them
	RETURN

SENDR5	NOP			; Send Register 5
				; Always 0x00800025
	MOVLW	0x00		; so populate BYTE1 - BYTE4
	MOVWF	BYTE1
	MOVLW	0x80
	MOVWF	BYTE2
	MOVLW	0x00
	MOVWF	BYTE3
	MOVLW	0x25
	MOVWF	BYTE4
	CALL	SENDWD		; and send them
	RETURN

SENDR6	NOP			; Send Register 6
	MOVF	OFFS, W		; Put the channel offset in W
	ADDLW	0x10		; Add the byte look-up offset
	MOVWF	BOFFS		; and store in byte offset

	CALL	LUBYTE		; so populate BYTE1 - BYTE4
	MOVWF	BYTE1
	CALL	LUBYTE		; so populate BYTE1 - BYTE4
	MOVWF	BYTE2
	CALL	LUBYTE		; so populate BYTE1 - BYTE4
	MOVWF	BYTE3
	CALL	LUBYTE		; so populate BYTE1 - BYTE4
	MOVWF	BYTE4
	CALL	SENDWD		; and send them
	RETURN

SENDR7	NOP			; Send Register 7
				; Always 0x120000E7
	MOVLW	0x12		; so populate BYTE1 - BYTE4
	MOVWF	BYTE1
	MOVLW	0x00
	MOVWF	BYTE2
	MOVLW	0x00
	MOVWF	BYTE3
	MOVLW	0xE7
	MOVWF	BYTE4
	CALL	SENDWD		; and send them
	RETURN

SENDR8	NOP			; Send Register 8
				; Always 0x102D0428
	MOVLW	0x10		; so populate BYTE1 - BYTE4
	MOVWF	BYTE1
	MOVLW	0x2D
	MOVWF	BYTE2
	MOVLW	0x04
	MOVWF	BYTE3
	MOVLW	0x28
	MOVWF	BYTE4
	CALL	SENDWD		; and send them
	RETURN

SENDR9	NOP			; Send Register 9
	MOVF	OFFS, W		; Put the channel offset in W
	ADDLW	0x14		; Add the byte look-up offset
	MOVWF	BOFFS		; and store in byte offset

	CALL	LUBYTE		; so populate BYTE1 - BYTE4
	MOVWF	BYTE1
	CALL	LUBYTE		; so populate BYTE1 - BYTE4
	MOVWF	BYTE2
	CALL	LUBYTE		; so populate BYTE1 - BYTE4
	MOVWF	BYTE3
	CALL	LUBYTE		; so populate BYTE1 - BYTE4
	MOVWF	BYTE4
	CALL	SENDWD		; and send them
	RETURN

SENDR10	NOP			; Send Register 10
	MOVF	OFFS, W		; Put the channel offset in W
	ADDLW	0x18		; Add the byte look-up offset
	MOVWF	BOFFS		; and store in byte offset

	CALL	LUBYTE		; so populate BYTE1 - BYTE4
	MOVWF	BYTE1
	CALL	LUBYTE		; so populate BYTE1 - BYTE4
	MOVWF	BYTE2
	CALL	LUBYTE		; so populate BYTE1 - BYTE4
	MOVWF	BYTE3
	CALL	LUBYTE		; so populate BYTE1 - BYTE4
	MOVWF	BYTE4
	CALL	SENDWD		; and send them
	RETURN

SENDR11	NOP			; Send Register 11
				; Always 0x0061300B
	MOVLW	0x00		; so populate BYTE1 - BYTE4
	MOVWF	BYTE1
	MOVLW	0x61
	MOVWF	BYTE2
	MOVLW	0x30
	MOVWF	BYTE3
	MOVLW	0x0B
	MOVWF	BYTE4
	CALL	SENDWD		; and send them
	RETURN

SENDR12	NOP			; Send Register 12
				; Always 0x0001041C
	MOVLW	0x00		; so populate BYTE1 - BYTE4
	MOVWF	BYTE1
	MOVLW	0x01
	MOVWF	BYTE2
	MOVLW	0x04
	MOVWF	BYTE3
	MOVLW	0x1C
	MOVWF	BYTE4
	CALL	SENDWD		; and send them
	RETURN
;-------------------------------------------------------------------------

;------ SENDWD --------------------------------------------------------------
;       Sends BYTE1, BYT2, BYTE3 and BYTE4 as a single word to the ADF5355

SENDWD	NOP

	BCF	PORTA, 2	; Set LE low
	MOVLW	0x04		; Move 4 (for 32-bit words)
	MOVWF	CNT8S		; Into the 8s counter

	MOVF	BYTE1, W	; Move the first byte
	MOVWF	SHIFTR		; into the shift register

BYTELUP	NOP
	MOVLW	0x08		; Move 8
	MOVWF	BITCNT		; Into the bit counter

BITLOOP	NOP
	BTFSC	SHIFTR, 7	; test the MSB
	BSF	PORTA, 1	; default data is low, so if bit not clear, set high
	NOP
	NOP
	NOP
	BSF	PORTA, 0	; Set clock high
	NOP
	NOP
	NOP
	BCF	PORTA, 0	; Set clock low
	NOP
	NOP
	NOP
	BCF	PORTA, 1	; Set data low

	BCF	STATUS, CARRY	; Clear the carry bit
	RLF	SHIFTR, F	; Shift the next bit in
	
	DECFSZ	BITCNT, F	; Decrement the bit counter
	GOTO	BITLOOP		; Do another bit if non-zero, else look for the next byte

	MOVF	BYTE2, W	; Move the next byte
	MOVWF	SHIFTR		; into the shift register

	MOVF	BYTE3, W	; Move the next byte
	MOVWF	BYTE2		; ready for next time

	MOVF	BYTE4, W	; Move the next byte
	MOVWF	BYTE3		; ready for the time after

	DECFSZ	CNT8S, F	; Decrement the byte counter
	GOTO	BYTELUP		; Do another if non-zero
	
	BSF	PORTA, 2	; End of 32 bits, so Set LE high
	
	RETURN
	
;------	End of SENDWD ---------------------------------------------------

	ORG	0x0400		; Put lookups in pages 4 - 9

;------ LOOKUPS --------------------------------------------------

LUREF1A	ADDWF	PCL, F		; Reference 1, Channels 1 - 8
	RETLW	0x00		; Ref 1 Chan 1 R0 Byte 1  26 MHz Ref 100 MHz
	RETLW	0x20		; Ref 1 Chan 1 R0 Byte 2
	RETLW	0x07		; Ref 1 Chan 1 R0 Byte 3
	RETLW	0xB0		; Ref 1 Chan 1 R0 Byte 4
	RETLW	0x01		; Ref 1 Chan 1 R1 Byte 1
	RETLW	0x3B		; Ref 1 Chan 1 R1 Byte 2
	RETLW	0x13		; Ref 1 Chan 1 R1 Byte 3
	RETLW	0xB1		; Ref 1 Chan 1 R1 Byte 4
	RETLW	0x06		; Ref 1 Chan 1 R2 Byte 1
	RETLW	0x91		; Ref 1 Chan 1 R2 Byte 2
	RETLW	0x55		; Ref 1 Chan 1 R2 Byte 3
	RETLW	0x52		; Ref 1 Chan 1 R2 Byte 4
	RETLW	0x34		; Ref 1 Chan 1 R4 Byte 1
	RETLW	0x00		; Ref 1 Chan 1 R4 Byte 2
	RETLW	0xA7		; Ref 1 Chan 1 R4 Byte 3
	RETLW	0x84		; Ref 1 Chan 1 R4 Byte 4
	RETLW	0x35		; Ref 1 Chan 1 R6 Byte 1
	RETLW	0xC3		; Ref 1 Chan 1 R6 Byte 2
	RETLW	0x44		; Ref 1 Chan 1 R6 Byte 3
	RETLW	0x76		; Ref 1 Chan 1 R6 Byte 4
	RETLW	0x16		; Ref 1 Chan 1 R9 Byte 1
	RETLW	0x15		; Ref 1 Chan 1 R9 Byte 2
	RETLW	0xFC		; Ref 1 Chan 1 R9 Byte 3
	RETLW	0xC9		; Ref 1 Chan 1 R9 Byte 4
	RETLW	0x00		; Ref 1 Chan 1 R10 Byte 1
	RETLW	0xC0		; Ref 1 Chan 1 R10 Byte 2
	RETLW	0x20		; Ref 1 Chan 1 R10 Byte 3
	RETLW	0xBA		; Ref 1 Chan 1 R10 Byte 4

	RETLW	0x00		; Ref 1 Chan 2 R0 Byte 1 26 MHz Ref 144.1 MHz
	RETLW	0x20		; Ref 1 Chan 2 R0 Byte 2
	RETLW	0x05		; Ref 1 Chan 2 R0 Byte 3
	RETLW	0x80		; Ref 1 Chan 2 R0 Byte 4
	RETLW	0x0A		; Ref 1 Chan 2 R1 Byte 1
	RETLW	0xD4		; Ref 1 Chan 2 R1 Byte 2
	RETLW	0xAD		; Ref 1 Chan 2 R1 Byte 3
	RETLW	0x41		; Ref 1 Chan 2 R1 Byte 4
	RETLW	0xAD		; Ref 1 Chan 2 R2 Byte 1
	RETLW	0x4B		; Ref 1 Chan 2 R2 Byte 2
	RETLW	0xFF		; Ref 1 Chan 2 R2 Byte 3
	RETLW	0xF2		; Ref 1 Chan 2 R2 Byte 4
	RETLW	0x34		; Ref 1 Chan 2 R4 Byte 1
	RETLW	0x00		; Ref 1 Chan 2 R4 Byte 2
	RETLW	0xA7		; Ref 1 Chan 2 R4 Byte 3
	RETLW	0x84		; Ref 1 Chan 2 R4 Byte 4
	RETLW	0x35		; Ref 1 Chan 2 R6 Byte 1
	RETLW	0xA4		; Ref 1 Chan 2 R6 Byte 2
	RETLW	0x84		; Ref 1 Chan 2 R6 Byte 3
	RETLW	0x76		; Ref 1 Chan 2 R6 Byte 4
	RETLW	0x16		; Ref 1 Chan 2 R9 Byte 1
	RETLW	0x15		; Ref 1 Chan 2 R9 Byte 2
	RETLW	0xFC		; Ref 1 Chan 2 R9 Byte 3
	RETLW	0xC9		; Ref 1 Chan 2 R9 Byte 4
	RETLW	0x00		; Ref 1 Chan 2 R10 Byte 1
	RETLW	0xC0		; Ref 1 Chan 2 R10 Byte 2
	RETLW	0x20		; Ref 1 Chan 2 R10 Byte 3
	RETLW	0xBA		; Ref 1 Chan 2 R10 Byte 4

	RETLW	0x00		; Ref 1 Chan 3 R0 Byte 1 26 MHz Ref 432.1 MHz
	RETLW	0x20		; Ref 1 Chan 3 R0 Byte 2
	RETLW	0x04		; Ref 1 Chan 3 R0 Byte 3
	RETLW	0x20		; Ref 1 Chan 3 R0 Byte 4
	RETLW	0x07		; Ref 1 Chan 3 R1 Byte 1
	RETLW	0xA1		; Ref 1 Chan 3 R1 Byte 2
	RETLW	0x7A		; Ref 1 Chan 3 R1 Byte 3
	RETLW	0x11		; Ref 1 Chan 3 R1 Byte 4
	RETLW	0x7A		; Ref 1 Chan 3 R2 Byte 1
	RETLW	0x17		; Ref 1 Chan 3 R2 Byte 2
	RETLW	0xFF		; Ref 1 Chan 3 R2 Byte 3
	RETLW	0xF2		; Ref 1 Chan 3 R2 Byte 4
	RETLW	0x34		; Ref 1 Chan 3 R4 Byte 1
	RETLW	0x00		; Ref 1 Chan 3 R4 Byte 2
	RETLW	0xA7		; Ref 1 Chan 3 R4 Byte 3
	RETLW	0x84		; Ref 1 Chan 3 R4 Byte 4
	RETLW	0x35		; Ref 1 Chan 3 R6 Byte 1
	RETLW	0x66		; Ref 1 Chan 3 R6 Byte 2
	RETLW	0x04		; Ref 1 Chan 3 R6 Byte 3
	RETLW	0x76		; Ref 1 Chan 3 R6 Byte 4
	RETLW	0x16		; Ref 1 Chan 3 R9 Byte 1
	RETLW	0x15		; Ref 1 Chan 3 R9 Byte 2
	RETLW	0xFC		; Ref 1 Chan 3 R9 Byte 3
	RETLW	0xC9		; Ref 1 Chan 3 R9 Byte 4
	RETLW	0x00		; Ref 1 Chan 3 R10 Byte 1
	RETLW	0xC0		; Ref 1 Chan 3 R10 Byte 2
	RETLW	0x20		; Ref 1 Chan 3 R10 Byte 3
	RETLW	0xBA		; Ref 1 Chan 3 R10 Byte 4

	RETLW	0x00		; Ref 1 Chan 4 R0 Byte 1 26 MHz Ref 1296.1 MHz
	RETLW	0x20		; Ref 1 Chan 4 R0 Byte 2
	RETLW	0x06		; Ref 1 Chan 4 R0 Byte 3
	RETLW	0x30		; Ref 1 Chan 4 R0 Byte 4
	RETLW	0x0B		; Ref 1 Chan 4 R1 Byte 1
	RETLW	0x33		; Ref 1 Chan 4 R1 Byte 2
	RETLW	0x33		; Ref 1 Chan 4 R1 Byte 3
	RETLW	0x31		; Ref 1 Chan 4 R1 Byte 4
	RETLW	0x33		; Ref 1 Chan 4 R2 Byte 1
	RETLW	0x37		; Ref 1 Chan 4 R2 Byte 2
	RETLW	0xFF		; Ref 1 Chan 4 R2 Byte 3
	RETLW	0xF2		; Ref 1 Chan 4 R2 Byte 4
	RETLW	0x34		; Ref 1 Chan 4 R4 Byte 1
	RETLW	0x00		; Ref 1 Chan 4 R4 Byte 2
	RETLW	0xA7		; Ref 1 Chan 4 R4 Byte 3
	RETLW	0x84		; Ref 1 Chan 4 R4 Byte 4
	RETLW	0x35		; Ref 1 Chan 4 R6 Byte 1
	RETLW	0x44		; Ref 1 Chan 4 R6 Byte 2
	RETLW	0x04		; Ref 1 Chan 4 R6 Byte 3
	RETLW	0x76		; Ref 1 Chan 4 R6 Byte 4
	RETLW	0x16		; Ref 1 Chan 4 R9 Byte 1
	RETLW	0x15		; Ref 1 Chan 4 R9 Byte 2
	RETLW	0xFC		; Ref 1 Chan 4 R9 Byte 3
	RETLW	0xC9		; Ref 1 Chan 4 R9 Byte 4
	RETLW	0x00		; Ref 1 Chan 4 R10 Byte 1
	RETLW	0xC0		; Ref 1 Chan 4 R10 Byte 2
	RETLW	0x20		; Ref 1 Chan 4 R10 Byte 3
	RETLW	0xBA		; Ref 1 Chan 4 R10 Byte 4

	RETLW	0x00		; Ref 1 Chan 5 R0 Byte 1 26 MHz Ref 2320.1 MHz
	RETLW	0x20		; Ref 1 Chan 5 R0 Byte 2
	RETLW	0x05		; Ref 1 Chan 5 R0 Byte 3
	RETLW	0x90		; Ref 1 Chan 5 R0 Byte 4
	RETLW	0x03		; Ref 1 Chan 5 R1 Byte 1
	RETLW	0xC0		; Ref 1 Chan 5 R1 Byte 2
	RETLW	0xFC		; Ref 1 Chan 5 R1 Byte 3
	RETLW	0x01		; Ref 1 Chan 5 R1 Byte 4
	RETLW	0x54		; Ref 1 Chan 5 R2 Byte 1
	RETLW	0x05		; Ref 1 Chan 5 R2 Byte 2
	RETLW	0x55		; Ref 1 Chan 5 R2 Byte 3
	RETLW	0x52		; Ref 1 Chan 5 R2 Byte 4
	RETLW	0x34		; Ref 1 Chan 5 R4 Byte 1
	RETLW	0x00		; Ref 1 Chan 5 R4 Byte 2
	RETLW	0xA7		; Ref 1 Chan 5 R4 Byte 3
	RETLW	0x84		; Ref 1 Chan 5 R4 Byte 4
	RETLW	0x35		; Ref 1 Chan 5 R6 Byte 1
	RETLW	0x24		; Ref 1 Chan 5 R6 Byte 2
	RETLW	0x84		; Ref 1 Chan 5 R6 Byte 3
	RETLW	0x76		; Ref 1 Chan 5 R6 Byte 4
	RETLW	0x16		; Ref 1 Chan 5 R9 Byte 1
	RETLW	0x15		; Ref 1 Chan 5 R9 Byte 2
	RETLW	0xFC		; Ref 1 Chan 5 R9 Byte 3
	RETLW	0xC9		; Ref 1 Chan 5 R9 Byte 4
	RETLW	0x00		; Ref 1 Chan 5 R10 Byte 1
	RETLW	0xC0		; Ref 1 Chan 5 R10 Byte 2
	RETLW	0x20		; Ref 1 Chan 5 R10 Byte 3
	RETLW	0xBA		; Ref 1 Chan 5 R10 Byte 4

	RETLW	0x00		; Ref 1 Chan 6 R0 Byte 1 26 MHz Ref 2400.1 MHz
	RETLW	0x20		; Ref 1 Chan 6 R0 Byte 2
	RETLW	0x05		; Ref 1 Chan 6 R0 Byte 3
	RETLW	0xC0		; Ref 1 Chan 6 R0 Byte 4
	RETLW	0x04		; Ref 1 Chan 6 R1 Byte 1
	RETLW	0xFC		; Ref 1 Chan 6 R1 Byte 2
	RETLW	0x0F		; Ref 1 Chan 6 R1 Byte 3
	RETLW	0xC1		; Ref 1 Chan 6 R1 Byte 4
	RETLW	0x05		; Ref 1 Chan 6 R2 Byte 1
	RETLW	0x41		; Ref 1 Chan 6 R2 Byte 2
	RETLW	0x55		; Ref 1 Chan 6 R2 Byte 3
	RETLW	0x52		; Ref 1 Chan 6 R2 Byte 4
	RETLW	0x34		; Ref 1 Chan 6 R4 Byte 1
	RETLW	0x00		; Ref 1 Chan 6 R4 Byte 2
	RETLW	0xA7		; Ref 1 Chan 6 R4 Byte 3
	RETLW	0x84		; Ref 1 Chan 6 R4 Byte 4
	RETLW	0x35		; Ref 1 Chan 6 R6 Byte 1
	RETLW	0x24		; Ref 1 Chan 6 R6 Byte 2
	RETLW	0x64		; Ref 1 Chan 6 R6 Byte 3
	RETLW	0x76		; Ref 1 Chan 6 R6 Byte 4
	RETLW	0x16		; Ref 1 Chan 6 R9 Byte 1
	RETLW	0x15		; Ref 1 Chan 6 R9 Byte 2
	RETLW	0xFC		; Ref 1 Chan 6 R9 Byte 3
	RETLW	0xC9		; Ref 1 Chan 6 R9 Byte 4
	RETLW	0x00		; Ref 1 Chan 6 R10 Byte 1
	RETLW	0xC0		; Ref 1 Chan 6 R10 Byte 2
	RETLW	0x20		; Ref 1 Chan 6 R10 Byte 3
	RETLW	0xBA		; Ref 1 Chan 6 R10 Byte 4

	RETLW	0x00		; Ref 1 Chan 7 R0 Byte 1 26 MHz Ref 3400.1 MHz
	RETLW	0x20		; Ref 1 Chan 7 R0 Byte 2
	RETLW	0x04		; Ref 1 Chan 7 R0 Byte 3
	RETLW	0x10		; Ref 1 Chan 7 R0 Byte 4
	RETLW	0x06		; Ref 1 Chan 7 R1 Byte 1
	RETLW	0x2F		; Ref 1 Chan 7 R1 Byte 2
	RETLW	0x42		; Ref 1 Chan 7 R1 Byte 3
	RETLW	0xF1		; Ref 1 Chan 7 R1 Byte 4
	RETLW	0x42		; Ref 1 Chan 7 R2 Byte 1
	RETLW	0xF7		; Ref 1 Chan 7 R2 Byte 2
	RETLW	0xFF		; Ref 1 Chan 7 R2 Byte 3
	RETLW	0xF2		; Ref 1 Chan 7 R2 Byte 4
	RETLW	0x34		; Ref 1 Chan 7 R4 Byte 1
	RETLW	0x00		; Ref 1 Chan 7 R4 Byte 2
	RETLW	0xA7		; Ref 1 Chan 7 R4 Byte 3
	RETLW	0x84		; Ref 1 Chan 7 R4 Byte 4
	RETLW	0x35		; Ref 1 Chan 7 R6 Byte 1
	RETLW	0x06		; Ref 1 Chan 7 R6 Byte 2
	RETLW	0x24		; Ref 1 Chan 7 R6 Byte 3
	RETLW	0x76		; Ref 1 Chan 7 R6 Byte 4
	RETLW	0x16		; Ref 1 Chan 7 R9 Byte 1
	RETLW	0x15		; Ref 1 Chan 7 R9 Byte 2
	RETLW	0xFC		; Ref 1 Chan 7 R9 Byte 3
	RETLW	0xC9		; Ref 1 Chan 7 R9 Byte 4
	RETLW	0x00		; Ref 1 Chan 7 R10 Byte 1
	RETLW	0xC0		; Ref 1 Chan 7 R10 Byte 2
	RETLW	0x20		; Ref 1 Chan 7 R10 Byte 3
	RETLW	0xBA		; Ref 1 Chan 7 R10 Byte 4

	RETLW	0x00		; Ref 1 Chan 8 R0 Byte 1 26 MHz Ref 5760.1 MHz
	RETLW	0x20		; Ref 1 Chan 8 R0 Byte 2
	RETLW	0x06		; Ref 1 Chan 8 R0 Byte 3
	RETLW	0xE0		; Ref 1 Chan 8 R0 Byte 4
	RETLW	0x0C		; Ref 1 Chan 8 R1 Byte 1
	RETLW	0x56		; Ref 1 Chan 8 R1 Byte 2
	RETLW	0xA5		; Ref 1 Chan 8 R1 Byte 3
	RETLW	0x61		; Ref 1 Chan 8 R1 Byte 4
	RETLW	0xA5		; Ref 1 Chan 8 R2 Byte 1
	RETLW	0x6B		; Ref 1 Chan 8 R2 Byte 2
	RETLW	0xFF		; Ref 1 Chan 8 R2 Byte 3
	RETLW	0xF2		; Ref 1 Chan 8 R2 Byte 4
	RETLW	0x34		; Ref 1 Chan 8 R4 Byte 1
	RETLW	0x00		; Ref 1 Chan 8 R4 Byte 2
	RETLW	0xA7		; Ref 1 Chan 8 R4 Byte 3
	RETLW	0x84		; Ref 1 Chan 8 R4 Byte 4
	RETLW	0x35		; Ref 1 Chan 8 R6 Byte 1
	RETLW	0x03		; Ref 1 Chan 8 R6 Byte 2
	RETLW	0xA4		; Ref 1 Chan 8 R6 Byte 3
	RETLW	0x76		; Ref 1 Chan 8 R6 Byte 4
	RETLW	0x16		; Ref 1 Chan 8 R9 Byte 1
	RETLW	0x15		; Ref 1 Chan 8 R9 Byte 2
	RETLW	0xFC		; Ref 1 Chan 8 R9 Byte 3
	RETLW	0xC9		; Ref 1 Chan 8 R9 Byte 4
	RETLW	0x00		; Ref 1 Chan 8 R10 Byte 1
	RETLW	0xC0		; Ref 1 Chan 8 R10 Byte 2
	RETLW	0x20		; Ref 1 Chan 8 R10 Byte 3
	RETLW	0xBA		; Ref 1 Chan 8 R10 Byte 4

	ORG	0x0500		; 

LUREF1B	ADDWF	PCL, F		; Reference 1, Channels 9 - 12
	RETLW	0x00		; Ref 1 Chan 9 R0 Byte 1 26 MHz Ref 10368.1 MHz
	RETLW	0x20		; Ref 1 Chan 9 R0 Byte 2
	RETLW	0x06		; Ref 1 Chan 9 R0 Byte 3
	RETLW	0x30		; Ref 1 Chan 9 R0 Byte 4
	RETLW	0x0B		; Ref 1 Chan 9 R1 Byte 1
	RETLW	0x17		; Ref 1 Chan 9 R1 Byte 2
	RETLW	0xA1		; Ref 1 Chan 9 R1 Byte 3
	RETLW	0x71		; Ref 1 Chan 9 R1 Byte 4
	RETLW	0xA1		; Ref 1 Chan 9 R2 Byte 1
	RETLW	0x7B		; Ref 1 Chan 9 R2 Byte 2
	RETLW	0xFF		; Ref 1 Chan 9 R2 Byte 3
	RETLW	0xF2		; Ref 1 Chan 9 R2 Byte 4
	RETLW	0x34		; Ref 1 Chan 9 R4 Byte 1
	RETLW	0x00		; Ref 1 Chan 9 R4 Byte 2
	RETLW	0xA7		; Ref 1 Chan 9 R4 Byte 3
	RETLW	0x84		; Ref 1 Chan 9 R4 Byte 4
	RETLW	0x35		; Ref 1 Chan 9 R6 Byte 1
	RETLW	0x04		; Ref 1 Chan 9 R6 Byte 2
	RETLW	0x00		; Ref 1 Chan 9 R6 Byte 3
	RETLW	0x36		; Ref 1 Chan 9 R6 Byte 4
	RETLW	0x16		; Ref 1 Chan 9 R9 Byte 1
	RETLW	0x15		; Ref 1 Chan 9 R9 Byte 2
	RETLW	0xFC		; Ref 1 Chan 9 R9 Byte 3
	RETLW	0xC9		; Ref 1 Chan 9 R9 Byte 4
	RETLW	0x00		; Ref 1 Chan 9 R10 Byte 1
	RETLW	0xC0		; Ref 1 Chan 9 R10 Byte 2
	RETLW	0x20		; Ref 1 Chan 9 R10 Byte 3
	RETLW	0xBA		; Ref 1 Chan 9 R10 Byte 4

	RETLW	0x00		; Ref 1 Chan 10 R0 Byte 1 26 MHz Ref 24048.1 MHz (/3)
	RETLW	0x20		; Ref 1 Chan 10 R0 Byte 2
	RETLW	0x04		; Ref 1 Chan 10 R0 Byte 3
	RETLW	0xD0		; Ref 1 Chan 10 R0 Byte 4
	RETLW	0x01		; Ref 1 Chan 10 R1 Byte 1
	RETLW	0x3C		; Ref 1 Chan 10 R1 Byte 2
	RETLW	0x63		; Ref 1 Chan 10 R1 Byte 3
	RETLW	0xC1		; Ref 1 Chan 10 R1 Byte 4
	RETLW	0x00		; Ref 1 Chan 10 R2 Byte 1
	RETLW	0xC8		; Ref 1 Chan 10 R2 Byte 2
	RETLW	0x08		; Ref 1 Chan 10 R2 Byte 3
	RETLW	0x12		; Ref 1 Chan 10 R2 Byte 4
	RETLW	0x34		; Ref 1 Chan 10 R4 Byte 1
	RETLW	0x00		; Ref 1 Chan 10 R4 Byte 2
	RETLW	0xA7		; Ref 1 Chan 10 R4 Byte 3
	RETLW	0x84		; Ref 1 Chan 10 R4 Byte 4
	RETLW	0x35		; Ref 1 Chan 10 R6 Byte 1
	RETLW	0x05		; Ref 1 Chan 10 R6 Byte 2
	RETLW	0x40		; Ref 1 Chan 10 R6 Byte 3
	RETLW	0x36		; Ref 1 Chan 10 R6 Byte 4
	RETLW	0x16		; Ref 1 Chan 10 R9 Byte 1
	RETLW	0x15		; Ref 1 Chan 10 R9 Byte 2
	RETLW	0xFC		; Ref 1 Chan 10 R9 Byte 3
	RETLW	0xC9		; Ref 1 Chan 10 R9 Byte 4
	RETLW	0x00		; Ref 1 Chan 10 R10 Byte 1
	RETLW	0xC0		; Ref 1 Chan 10 R10 Byte 2
	RETLW	0x20		; Ref 1 Chan 10 R10 Byte 3
	RETLW	0xBA		; Ref 1 Chan 10 R10 Byte 4

	RETLW	0x00		; Ref 1 Chan 11 R0 Byte 1 26 MHz Ref 47088.1 MHz (/5)
	RETLW	0x20		; Ref 1 Chan 11 R0 Byte 2
	RETLW	0x05		; Ref 1 Chan 11 R0 Byte 3
	RETLW	0xA0		; Ref 1 Chan 11 R0 Byte 4
	RETLW	0x08		; Ref 1 Chan 11 R1 Byte 1
	RETLW	0xDD		; Ref 1 Chan 11 R1 Byte 2
	RETLW	0x57		; Ref 1 Chan 11 R1 Byte 3
	RETLW	0x61		; Ref 1 Chan 11 R1 Byte 4
	RETLW	0xF1		; Ref 1 Chan 11 R2 Byte 1
	RETLW	0x07		; Ref 1 Chan 11 R2 Byte 2
	RETLW	0xFF		; Ref 1 Chan 11 R2 Byte 3
	RETLW	0xF2		; Ref 1 Chan 11 R2 Byte 4
	RETLW	0x34		; Ref 1 Chan 11 R4 Byte 1
	RETLW	0x00		; Ref 1 Chan 11 R4 Byte 2
	RETLW	0xA7		; Ref 1 Chan 11 R4 Byte 3
	RETLW	0x84		; Ref 1 Chan 11 R4 Byte 4
	RETLW	0x35		; Ref 1 Chan 11 R6 Byte 1
	RETLW	0x04		; Ref 1 Chan 11 R6 Byte 2
	RETLW	0x60		; Ref 1 Chan 11 R6 Byte 3
	RETLW	0x36		; Ref 1 Chan 11 R6 Byte 4
	RETLW	0x16		; Ref 1 Chan 11 R9 Byte 1
	RETLW	0x15		; Ref 1 Chan 11 R9 Byte 2
	RETLW	0xFC		; Ref 1 Chan 11 R9 Byte 3
	RETLW	0xC9		; Ref 1 Chan 11 R9 Byte 4
	RETLW	0x00		; Ref 1 Chan 11 R10 Byte 1
	RETLW	0xC0		; Ref 1 Chan 11 R10 Byte 2
	RETLW	0x20		; Ref 1 Chan 11 R10 Byte 3
	RETLW	0xBA		; Ref 1 Chan 11 R10 Byte 4

	RETLW	0x00		; Ref 1 Chan 12 R0 Byte 1 26 MHz Ref 108537.4 MHz
	RETLW	0x20		; Ref 1 Chan 12 R0 Byte 2
	RETLW	0x06		; Ref 1 Chan 12 R0 Byte 3
	RETLW	0x80		; Ref 1 Chan 12 R0 Byte 4
	RETLW	0x05		; Ref 1 Chan 12 R1 Byte 1
	RETLW	0xCE		; Ref 1 Chan 12 R1 Byte 2
	RETLW	0x7C		; Ref 1 Chan 12 R1 Byte 3
	RETLW	0xC1		; Ref 1 Chan 12 R1 Byte 4
	RETLW	0xF2		; Ref 1 Chan 12 R2 Byte 1
	RETLW	0xE7		; Ref 1 Chan 12 R2 Byte 2
	RETLW	0xFF		; Ref 1 Chan 12 R2 Byte 3
	RETLW	0xF2		; Ref 1 Chan 12 R2 Byte 4
	RETLW	0x34		; Ref 1 Chan 12 R4 Byte 1
	RETLW	0x00		; Ref 1 Chan 12 R4 Byte 2
	RETLW	0xA7		; Ref 1 Chan 12 R4 Byte 3
	RETLW	0x84		; Ref 1 Chan 12 R4 Byte 4
	RETLW	0x35		; Ref 1 Chan 12 R6 Byte 1
	RETLW	0x03		; Ref 1 Chan 12 R6 Byte 2
	RETLW	0xE0		; Ref 1 Chan 12 R6 Byte 3
	RETLW	0x36		; Ref 1 Chan 12 R6 Byte 4
	RETLW	0x16		; Ref 1 Chan 12 R9 Byte 1
	RETLW	0x15		; Ref 1 Chan 12 R9 Byte 2
	RETLW	0xFC		; Ref 1 Chan 12 R9 Byte 3
	RETLW	0xC9		; Ref 1 Chan 12 R9 Byte 4
	RETLW	0x00		; Ref 1 Chan 12 R10 Byte 1
	RETLW	0xC0		; Ref 1 Chan 12 R10 Byte 2
	RETLW	0x20		; Ref 1 Chan 12 R10 Byte 3
	RETLW	0xBA		; Ref 1 Chan 12 R10 Byte 4

	ORG	0x600

LUREF2A	ADDWF	PCL, F		; Reference 2, Channels 1 - 8
	RETLW	0x00		; Ref 2 Chan 1 R0 Byte 1  10 MHz Ref 100 MHz
	RETLW	0x20		; Ref 2 Chan 1 R0 Byte 2
	RETLW	0x14		; Ref 2 Chan 1 R0 Byte 3
	RETLW	0x00		; Ref 2 Chan 1 R0 Byte 4
	RETLW	0x00		; Ref 2 Chan 1 R1 Byte 1
	RETLW	0x00		; Ref 2 Chan 1 R1 Byte 2
	RETLW	0x00		; Ref 2 Chan 1 R1 Byte 3
	RETLW	0x01		; Ref 2 Chan 1 R1 Byte 4
	RETLW	0x00		; Ref 2 Chan 1 R2 Byte 1
	RETLW	0x00		; Ref 2 Chan 1 R2 Byte 2
	RETLW	0x00		; Ref 2 Chan 1 R2 Byte 3
	RETLW	0x12		; Ref 2 Chan 1 R2 Byte 4
	RETLW	0x34		; Ref 2 Chan 1 R4 Byte 1
	RETLW	0x00		; Ref 2 Chan 1 R4 Byte 2
	RETLW	0xA7		; Ref 2 Chan 1 R4 Byte 3
	RETLW	0x84		; Ref 2 Chan 1 R4 Byte 4
	RETLW	0x35		; Ref 2 Chan 1 R6 Byte 1
	RETLW	0xC1		; Ref 2 Chan 1 R6 Byte 2
	RETLW	0x44		; Ref 2 Chan 1 R6 Byte 3
	RETLW	0x76		; Ref 2 Chan 1 R6 Byte 4
	RETLW	0x09		; Ref 2 Chan 1 R9 Byte 1
	RETLW	0x08		; Ref 2 Chan 1 R9 Byte 2
	RETLW	0xBC		; Ref 2 Chan 1 R9 Byte 3
	RETLW	0xC9		; Ref 2 Chan 1 R9 Byte 4
	RETLW	0x00		; Ref 2 Chan 1 R10 Byte 1
	RETLW	0xC0		; Ref 2 Chan 1 R10 Byte 2
	RETLW	0x0C		; Ref 2 Chan 1 R10 Byte 3
	RETLW	0xBA		; Ref 2 Chan 1 R10 Byte 4

	RETLW	0x00		; Ref 2 Chan 2 R0 Byte 1 10 MHz Ref 144.1 MHz
	RETLW	0x20		; Ref 2 Chan 2 R0 Byte 2
	RETLW	0x0E		; Ref 2 Chan 2 R0 Byte 3
	RETLW	0x60		; Ref 2 Chan 2 R0 Byte 4
	RETLW	0x08		; Ref 2 Chan 2 R1 Byte 1
	RETLW	0xF5		; Ref 2 Chan 2 R1 Byte 2
	RETLW	0xC2		; Ref 2 Chan 2 R1 Byte 3
	RETLW	0x81		; Ref 2 Chan 2 R1 Byte 4
	RETLW	0xF5		; Ref 2 Chan 2 R2 Byte 1
	RETLW	0xC3		; Ref 2 Chan 2 R2 Byte 2
	RETLW	0xFF		; Ref 2 Chan 2 R2 Byte 3
	RETLW	0xF2		; Ref 2 Chan 2 R2 Byte 4
	RETLW	0x34		; Ref 2 Chan 2 R4 Byte 1
	RETLW	0x00		; Ref 2 Chan 2 R4 Byte 2
	RETLW	0xA7		; Ref 2 Chan 2 R4 Byte 3
	RETLW	0x84		; Ref 2 Chan 2 R4 Byte 4
	RETLW	0x35		; Ref 2 Chan 2 R6 Byte 1
	RETLW	0xA1		; Ref 2 Chan 2 R6 Byte 2
	RETLW	0xC4		; Ref 2 Chan 2 R6 Byte 3
	RETLW	0x76		; Ref 2 Chan 2 R6 Byte 4
	RETLW	0x09		; Ref 2 Chan 2 R9 Byte 1
	RETLW	0x08		; Ref 2 Chan 2 R9 Byte 2
	RETLW	0xBC		; Ref 2 Chan 2 R9 Byte 3
	RETLW	0xC9		; Ref 2 Chan 2 R9 Byte 4
	RETLW	0x00		; Ref 2 Chan 2 R10 Byte 1
	RETLW	0xC0		; Ref 2 Chan 2 R10 Byte 2
	RETLW	0x0C		; Ref 2 Chan 2 R10 Byte 3
	RETLW	0xBA		; Ref 2 Chan 2 R10 Byte 4

	RETLW	0x00		; Ref 2 Chan 3 R0 Byte 1 10 MHz Ref 432.1 MHz
	RETLW	0x20		; Ref 2 Chan 3 R0 Byte 2
	RETLW	0x0A		; Ref 2 Chan 3 R0 Byte 3
	RETLW	0xC0		; Ref 2 Chan 3 R0 Byte 4
	RETLW	0x0D		; Ref 2 Chan 3 R1 Byte 1
	RETLW	0x70		; Ref 2 Chan 3 R1 Byte 2
	RETLW	0xA3		; Ref 2 Chan 3 R1 Byte 3
	RETLW	0xD1		; Ref 2 Chan 3 R1 Byte 4
	RETLW	0x25		; Ref 2 Chan 3 R2 Byte 1
	RETLW	0x8D		; Ref 2 Chan 3 R2 Byte 2
	RETLW	0x55		; Ref 2 Chan 3 R2 Byte 3
	RETLW	0x52		; Ref 2 Chan 3 R2 Byte 4
	RETLW	0x34		; Ref 2 Chan 3 R4 Byte 1
	RETLW	0x00		; Ref 2 Chan 3 R4 Byte 2
	RETLW	0xA7		; Ref 2 Chan 3 R4 Byte 3
	RETLW	0x84		; Ref 2 Chan 3 R4 Byte 4
	RETLW	0x35		; Ref 2 Chan 3 R6 Byte 1
	RETLW	0x62		; Ref 2 Chan 3 R6 Byte 2
	RETLW	0x64		; Ref 2 Chan 3 R6 Byte 3
	RETLW	0x76		; Ref 2 Chan 3 R6 Byte 4
	RETLW	0x09		; Ref 2 Chan 3 R9 Byte 1
	RETLW	0x08		; Ref 2 Chan 3 R9 Byte 2
	RETLW	0xBC		; Ref 2 Chan 3 R9 Byte 3
	RETLW	0xC9		; Ref 2 Chan 3 R9 Byte 4
	RETLW	0x00		; Ref 2 Chan 3 R10 Byte 1
	RETLW	0xC0		; Ref 2 Chan 3 R10 Byte 2
	RETLW	0x0C		; Ref 2 Chan 3 R10 Byte 3
	RETLW	0xBA		; Ref 2 Chan 3 R10 Byte 4

	RETLW	0x00		; Ref 2 Chan 4 R0 Byte 1 10 MHz Ref 1296.1 MHz
	RETLW	0x20		; Ref 2 Chan 4 R0 Byte 2
	RETLW	0x10		; Ref 2 Chan 4 R0 Byte 3
	RETLW	0x30		; Ref 2 Chan 4 R0 Byte 4
	RETLW	0x03		; Ref 2 Chan 4 R1 Byte 1
	RETLW	0x85		; Ref 2 Chan 4 R1 Byte 2
	RETLW	0x1E		; Ref 2 Chan 4 R1 Byte 3
	RETLW	0xB1		; Ref 2 Chan 4 R1 Byte 4
	RETLW	0x85		; Ref 2 Chan 4 R2 Byte 1
	RETLW	0x1F		; Ref 2 Chan 4 R2 Byte 2
	RETLW	0xFF		; Ref 2 Chan 4 R2 Byte 3
	RETLW	0xF2		; Ref 2 Chan 4 R2 Byte 4
	RETLW	0x34		; Ref 2 Chan 4 R4 Byte 1
	RETLW	0x00		; Ref 2 Chan 4 R4 Byte 2
	RETLW	0xA7		; Ref 2 Chan 4 R4 Byte 3
	RETLW	0x84		; Ref 2 Chan 4 R4 Byte 4
	RETLW	0x35		; Ref 2 Chan 4 R6 Byte 1
	RETLW	0x41		; Ref 2 Chan 4 R6 Byte 2
	RETLW	0x84		; Ref 2 Chan 4 R6 Byte 3
	RETLW	0x76		; Ref 2 Chan 4 R6 Byte 4
	RETLW	0x09		; Ref 2 Chan 4 R9 Byte 1
	RETLW	0x08		; Ref 2 Chan 4 R9 Byte 2
	RETLW	0xBC		; Ref 2 Chan 4 R9 Byte 3
	RETLW	0xC9		; Ref 2 Chan 4 R9 Byte 4
	RETLW	0x00		; Ref 2 Chan 4 R10 Byte 1
	RETLW	0xC0		; Ref 2 Chan 4 R10 Byte 2
	RETLW	0x0C		; Ref 2 Chan 4 R10 Byte 3
	RETLW	0xBA		; Ref 2 Chan 4 R10 Byte 4

	RETLW	0x00		; Ref 2 Chan 5 R0 Byte 1 10 MHz Ref 2320.1 MHz
	RETLW	0x20		; Ref 2 Chan 5 R0 Byte 2
	RETLW	0x0E		; Ref 2 Chan 5 R0 Byte 3
	RETLW	0x80		; Ref 2 Chan 5 R0 Byte 4
	RETLW	0x00		; Ref 2 Chan 5 R1 Byte 1
	RETLW	0x28		; Ref 2 Chan 5 R1 Byte 2
	RETLW	0xF5		; Ref 2 Chan 5 R1 Byte 3
	RETLW	0xC1		; Ref 2 Chan 5 R1 Byte 4
	RETLW	0x28		; Ref 2 Chan 5 R2 Byte 1
	RETLW	0xF7		; Ref 2 Chan 5 R2 Byte 2
	RETLW	0xFF		; Ref 2 Chan 5 R2 Byte 3
	RETLW	0xF2		; Ref 2 Chan 5 R2 Byte 4
	RETLW	0x34		; Ref 2 Chan 5 R4 Byte 1
	RETLW	0x00		; Ref 2 Chan 5 R4 Byte 2
	RETLW	0xA7		; Ref 2 Chan 5 R4 Byte 3
	RETLW	0x84		; Ref 2 Chan 5 R4 Byte 4
	RETLW	0x35		; Ref 2 Chan 5 R6 Byte 1
	RETLW	0x21		; Ref 2 Chan 5 R6 Byte 2
	RETLW	0xC4		; Ref 2 Chan 5 R6 Byte 3
	RETLW	0x76		; Ref 2 Chan 5 R6 Byte 4
	RETLW	0x09		; Ref 2 Chan 5 R9 Byte 1
	RETLW	0x08		; Ref 2 Chan 5 R9 Byte 2
	RETLW	0xBC		; Ref 2 Chan 5 R9 Byte 3
	RETLW	0xC9		; Ref 2 Chan 5 R9 Byte 4
	RETLW	0x00		; Ref 2 Chan 5 R10 Byte 1
	RETLW	0xC0		; Ref 2 Chan 5 R10 Byte 2
	RETLW	0x0C		; Ref 2 Chan 5 R10 Byte 3
	RETLW	0xBA		; Ref 2 Chan 5 R10 Byte 4

	RETLW	0x00		; Ref 2 Chan 6 R0 Byte 1 10 MHz Ref 2400.1 MHz
	RETLW	0x20		; Ref 2 Chan 6 R0 Byte 2
	RETLW	0x0F		; Ref 2 Chan 6 R0 Byte 3
	RETLW	0x00		; Ref 2 Chan 6 R0 Byte 4
	RETLW	0x00		; Ref 2 Chan 6 R1 Byte 1
	RETLW	0x28		; Ref 2 Chan 6 R1 Byte 2
	RETLW	0xF5		; Ref 2 Chan 6 R1 Byte 3
	RETLW	0xC1		; Ref 2 Chan 6 R1 Byte 4
	RETLW	0x28		; Ref 2 Chan 6 R2 Byte 1
	RETLW	0xF7		; Ref 2 Chan 6 R2 Byte 2
	RETLW	0xFF		; Ref 2 Chan 6 R2 Byte 3
	RETLW	0xF2		; Ref 2 Chan 6 R2 Byte 4
	RETLW	0x34		; Ref 2 Chan 6 R4 Byte 1
	RETLW	0x00		; Ref 2 Chan 6 R4 Byte 2
	RETLW	0xA7		; Ref 2 Chan 6 R4 Byte 3
	RETLW	0x84		; Ref 2 Chan 6 R4 Byte 4
	RETLW	0x35		; Ref 2 Chan 6 R6 Byte 1
	RETLW	0x21		; Ref 2 Chan 6 R6 Byte 2
	RETLW	0xA4		; Ref 2 Chan 6 R6 Byte 3
	RETLW	0x76		; Ref 2 Chan 6 R6 Byte 4
	RETLW	0x09		; Ref 2 Chan 6 R9 Byte 1
	RETLW	0x08		; Ref 2 Chan 6 R9 Byte 2
	RETLW	0xBC		; Ref 2 Chan 6 R9 Byte 3
	RETLW	0xC9		; Ref 2 Chan 6 R9 Byte 4
	RETLW	0x00		; Ref 2 Chan 6 R10 Byte 1
	RETLW	0xC0		; Ref 2 Chan 6 R10 Byte 2
	RETLW	0x0C		; Ref 2 Chan 6 R10 Byte 3
	RETLW	0xBA		; Ref 2 Chan 6 R10 Byte 4

	RETLW	0x00		; Ref 2 Chan 7 R0 Byte 1 10 MHz Ref 3400.1 MHz
	RETLW	0x20		; Ref 2 Chan 7 R0 Byte 2
	RETLW	0x0A		; Ref 2 Chan 7 R0 Byte 3
	RETLW	0xA0		; Ref 2 Chan 7 R0 Byte 4
	RETLW	0x00		; Ref 2 Chan 7 R1 Byte 1
	RETLW	0x14		; Ref 2 Chan 7 R1 Byte 2
	RETLW	0x7A		; Ref 2 Chan 7 R1 Byte 3
	RETLW	0xE1		; Ref 2 Chan 7 R1 Byte 4
	RETLW	0x06		; Ref 2 Chan 7 R2 Byte 1
	RETLW	0xD5		; Ref 2 Chan 7 R2 Byte 2
	RETLW	0x55		; Ref 2 Chan 7 R2 Byte 3
	RETLW	0x52		; Ref 2 Chan 7 R2 Byte 4
	RETLW	0x34		; Ref 2 Chan 7 R4 Byte 1
	RETLW	0x00		; Ref 2 Chan 7 R4 Byte 2
	RETLW	0xA7		; Ref 2 Chan 7 R4 Byte 3
	RETLW	0x84		; Ref 2 Chan 7 R4 Byte 4
	RETLW	0x35		; Ref 2 Chan 7 R6 Byte 1
	RETLW	0x02		; Ref 2 Chan 7 R6 Byte 2
	RETLW	0x64		; Ref 2 Chan 7 R6 Byte 3
	RETLW	0x76		; Ref 2 Chan 7 R6 Byte 4
	RETLW	0x09		; Ref 2 Chan 7 R9 Byte 1
	RETLW	0x08		; Ref 2 Chan 7 R9 Byte 2
	RETLW	0xBC		; Ref 2 Chan 7 R9 Byte 3
	RETLW	0xC9		; Ref 2 Chan 7 R9 Byte 4
	RETLW	0x00		; Ref 2 Chan 7 R10 Byte 1
	RETLW	0xC0		; Ref 2 Chan 7 R10 Byte 2
	RETLW	0x0C		; Ref 2 Chan 7 R10 Byte 3
	RETLW	0xBA		; Ref 2 Chan 7 R10 Byte 4

	RETLW	0x00		; Ref 2 Chan 8 R0 Byte 1 10 MHz Ref 5760.1 MHz
	RETLW	0x20		; Ref 2 Chan 8 R0 Byte 2
	RETLW	0x12		; Ref 2 Chan 8 R0 Byte 3
	RETLW	0x00		; Ref 2 Chan 8 R0 Byte 4
	RETLW	0x00		; Ref 2 Chan 8 R1 Byte 1
	RETLW	0x14		; Ref 2 Chan 8 R1 Byte 2
	RETLW	0x7A		; Ref 2 Chan 8 R1 Byte 3
	RETLW	0xE1		; Ref 2 Chan 8 R1 Byte 4
	RETLW	0x06		; Ref 2 Chan 8 R2 Byte 1
	RETLW	0xD5		; Ref 2 Chan 8 R2 Byte 2
	RETLW	0x55		; Ref 2 Chan 8 R2 Byte 3
	RETLW	0x52		; Ref 2 Chan 8 R2 Byte 4
	RETLW	0x34		; Ref 2 Chan 8 R4 Byte 1
	RETLW	0x00		; Ref 2 Chan 8 R4 Byte 2
	RETLW	0xA7		; Ref 2 Chan 8 R4 Byte 3
	RETLW	0x84		; Ref 2 Chan 8 R4 Byte 4
	RETLW	0x35		; Ref 2 Chan 8 R6 Byte 1
	RETLW	0x01		; Ref 2 Chan 8 R6 Byte 2
	RETLW	0x64		; Ref 2 Chan 8 R6 Byte 3
	RETLW	0x76		; Ref 2 Chan 8 R6 Byte 4
	RETLW	0x09		; Ref 2 Chan 8 R9 Byte 1
	RETLW	0x08		; Ref 2 Chan 8 R9 Byte 2
	RETLW	0xBC		; Ref 2 Chan 8 R9 Byte 3
	RETLW	0xC9		; Ref 2 Chan 8 R9 Byte 4
	RETLW	0x00		; Ref 2 Chan 8 R10 Byte 1
	RETLW	0xC0		; Ref 2 Chan 8 R10 Byte 2
	RETLW	0x0C		; Ref 2 Chan 8 R10 Byte 3
	RETLW	0xBA		; Ref 2 Chan 8 R10 Byte 4

	ORG	0x0700		; 

LUREF2B	ADDWF	PCL, F		; Reference 2, Channels 9 - 12
	RETLW	0x00		; Ref 2 Chan 9 R0 Byte 1 10 MHz Ref 10368.1 MHz
	RETLW	0x20		; Ref 2 Chan 9 R0 Byte 2
	RETLW	0x10		; Ref 2 Chan 9 R0 Byte 3
	RETLW	0x30		; Ref 2 Chan 9 R0 Byte 4
	RETLW	0x03		; Ref 2 Chan 9 R1 Byte 1
	RETLW	0x3D		; Ref 2 Chan 9 R1 Byte 2
	RETLW	0x70		; Ref 2 Chan 9 R1 Byte 3
	RETLW	0xA1		; Ref 2 Chan 9 R1 Byte 4
	RETLW	0x3D		; Ref 2 Chan 9 R2 Byte 1
	RETLW	0x73		; Ref 2 Chan 9 R2 Byte 2
	RETLW	0xFF		; Ref 2 Chan 9 R2 Byte 3
	RETLW	0xF2		; Ref 2 Chan 9 R2 Byte 4
	RETLW	0x34		; Ref 2 Chan 9 R4 Byte 1
	RETLW	0x00		; Ref 2 Chan 9 R4 Byte 2
	RETLW	0xA7		; Ref 2 Chan 9 R4 Byte 3
	RETLW	0x84		; Ref 2 Chan 9 R4 Byte 4
	RETLW	0x35		; Ref 2 Chan 9 R6 Byte 1
	RETLW	0x01		; Ref 2 Chan 9 R6 Byte 2
	RETLW	0x80		; Ref 2 Chan 9 R6 Byte 3
	RETLW	0x36		; Ref 2 Chan 9 R6 Byte 4
	RETLW	0x09		; Ref 2 Chan 9 R9 Byte 1
	RETLW	0x08		; Ref 2 Chan 9 R9 Byte 2
	RETLW	0xBC		; Ref 2 Chan 9 R9 Byte 3
	RETLW	0xC9		; Ref 2 Chan 9 R9 Byte 4
	RETLW	0x00		; Ref 2 Chan 9 R10 Byte 1
	RETLW	0x0C		; Ref 2 Chan 9 R10 Byte 2
	RETLW	0xC0		; Ref 2 Chan 9 R10 Byte 3
	RETLW	0xBA		; Ref 2 Chan 9 R10 Byte 4

	RETLW	0x00		; Ref 2 Chan 10 R0 Byte 1 10 MHz Ref 24048.1 MHz (/3)
	RETLW	0x20		; Ref 2 Chan 10 R0 Byte 2
	RETLW	0x0C		; Ref 2 Chan 10 R0 Byte 3
	RETLW	0x80		; Ref 2 Chan 10 R0 Byte 4
	RETLW	0x06		; Ref 2 Chan 10 R1 Byte 1
	RETLW	0x69		; Ref 2 Chan 10 R1 Byte 2
	RETLW	0xD0		; Ref 2 Chan 10 R1 Byte 3
	RETLW	0x31		; Ref 2 Chan 10 R1 Byte 4
	RETLW	0x68		; Ref 2 Chan 10 R2 Byte 1
	RETLW	0x63		; Ref 2 Chan 10 R2 Byte 2
	RETLW	0xFF		; Ref 2 Chan 10 R2 Byte 3
	RETLW	0xF2		; Ref 2 Chan 10 R2 Byte 4
	RETLW	0x34		; Ref 2 Chan 10 R4 Byte 1
	RETLW	0x00		; Ref 2 Chan 10 R4 Byte 2
	RETLW	0xA7		; Ref 2 Chan 10 R4 Byte 3
	RETLW	0x84		; Ref 2 Chan 10 R4 Byte 4
	RETLW	0x35		; Ref 2 Chan 10 R6 Byte 1
	RETLW	0x02		; Ref 2 Chan 10 R6 Byte 2
	RETLW	0x00		; Ref 2 Chan 10 R6 Byte 3
	RETLW	0x36		; Ref 2 Chan 10 R6 Byte 4
	RETLW	0x09		; Ref 2 Chan 10 R9 Byte 1
	RETLW	0x08		; Ref 2 Chan 10 R9 Byte 2
	RETLW	0xBC		; Ref 2 Chan 10 R9 Byte 3
	RETLW	0xC9		; Ref 2 Chan 10 R9 Byte 4
	RETLW	0x00		; Ref 2 Chan 10 R10 Byte 1
	RETLW	0xC0		; Ref 2 Chan 10 R10 Byte 2
	RETLW	0x0C		; Ref 2 Chan 10 R10 Byte 3
	RETLW	0xBA		; Ref 2 Chan 10 R10 Byte 4

	RETLW	0x00		; Ref 2 Chan 11 R0 Byte 1 10 MHz Ref 47088.1 MHz (/5)
	RETLW	0x20		; Ref 2 Chan 11 R0 Byte 2
	RETLW	0x0E		; Ref 2 Chan 11 R0 Byte 3
	RETLW	0xB0		; Ref 2 Chan 11 R0 Byte 4
	RETLW	0x07		; Ref 2 Chan 11 R1 Byte 1
	RETLW	0x0C		; Ref 2 Chan 11 R1 Byte 2
	RETLW	0x49		; Ref 2 Chan 11 R1 Byte 3
	RETLW	0xB1		; Ref 2 Chan 11 R1 Byte 4
	RETLW	0xA5		; Ref 2 Chan 11 R2 Byte 1
	RETLW	0xE3		; Ref 2 Chan 11 R2 Byte 2
	RETLW	0xFF		; Ref 2 Chan 11 R2 Byte 3
	RETLW	0xF2		; Ref 2 Chan 11 R2 Byte 4
	RETLW	0x34		; Ref 2 Chan 11 R4 Byte 1
	RETLW	0x00		; Ref 2 Chan 11 R4 Byte 2
	RETLW	0xA7		; Ref 2 Chan 11 R4 Byte 3
	RETLW	0x84		; Ref 2 Chan 11 R4 Byte 4
	RETLW	0x35		; Ref 2 Chan 11 R6 Byte 1
	RETLW	0x01		; Ref 2 Chan 11 R6 Byte 2
	RETLW	0xC0		; Ref 2 Chan 11 R6 Byte 3
	RETLW	0x36		; Ref 2 Chan 11 R6 Byte 4
	RETLW	0x09		; Ref 2 Chan 11 R9 Byte 1
	RETLW	0x08		; Ref 2 Chan 11 R9 Byte 2
	RETLW	0xBC		; Ref 2 Chan 11 R9 Byte 3
	RETLW	0xC9		; Ref 2 Chan 11 R9 Byte 4
	RETLW	0x00		; Ref 2 Chan 11 R10 Byte 1
	RETLW	0xC0		; Ref 2 Chan 11 R10 Byte 2
	RETLW	0x0C		; Ref 2 Chan 11 R10 Byte 3
	RETLW	0xBA		; Ref 2 Chan 11 R10 Byte 4

	RETLW	0x00		; Ref 2 Chan 12 R0 Byte 1 10 MHz Ref 108537.4 MHz
	RETLW	0x20		; Ref 2 Chan 12 R0 Byte 2
	RETLW	0x10		; Ref 2 Chan 12 R0 Byte 3
	RETLW	0xF0		; Ref 2 Chan 12 R0 Byte 4
	RETLW	0x05		; Ref 2 Chan 12 R1 Byte 1
	RETLW	0x7F		; Ref 2 Chan 12 R1 Byte 2
	RETLW	0x44		; Ref 2 Chan 12 R1 Byte 3
	RETLW	0xD1		; Ref 2 Chan 12 R1 Byte 4
	RETLW	0x44		; Ref 2 Chan 12 R2 Byte 1
	RETLW	0x57		; Ref 2 Chan 12 R2 Byte 2
	RETLW	0xFF		; Ref 2 Chan 12 R2 Byte 3
	RETLW	0xF2		; Ref 2 Chan 12 R2 Byte 4
	RETLW	0x34		; Ref 2 Chan 12 R4 Byte 1
	RETLW	0x00		; Ref 2 Chan 12 R4 Byte 2
	RETLW	0xA7		; Ref 2 Chan 12 R4 Byte 3
	RETLW	0x84		; Ref 2 Chan 12 R4 Byte 4
	RETLW	0x35		; Ref 2 Chan 12 R6 Byte 1
	RETLW	0x01		; Ref 2 Chan 12 R6 Byte 2
	RETLW	0x80		; Ref 2 Chan 12 R6 Byte 3
	RETLW	0x36		; Ref 2 Chan 12 R6 Byte 4
	RETLW	0x09		; Ref 2 Chan 12 R9 Byte 1
	RETLW	0x08		; Ref 2 Chan 12 R9 Byte 2
	RETLW	0xBC		; Ref 2 Chan 12 R9 Byte 3
	RETLW	0xC9		; Ref 2 Chan 12 R9 Byte 4
	RETLW	0x00		; Ref 2 Chan 12 R10 Byte 1
	RETLW	0xC0		; Ref 2 Chan 12 R10 Byte 2
	RETLW	0x0C		; Ref 2 Chan 12 R10 Byte 3
	RETLW	0xBA		; Ref 2 Chan 12 R10 Byte 4

	ORG	0x0800

LUREF3A	ADDWF	PCL, F		; Reference 3, Channels 1 - 8
	RETLW	0x00		; Ref 3 Chan 1 R0 Byte 1  25 MHz Ref 100 MHz
	RETLW	0x20		; Ref 3 Chan 1 R0 Byte 2
	RETLW	0x08		; Ref 3 Chan 1 R0 Byte 3
	RETLW	0x00		; Ref 3 Chan 1 R0 Byte 4
	RETLW	0x00		; Ref 3 Chan 1 R1 Byte 1
	RETLW	0x00		; Ref 3 Chan 1 R1 Byte 2
	RETLW	0x00		; Ref 3 Chan 1 R1 Byte 3
	RETLW	0x01		; Ref 3 Chan 1 R1 Byte 4
	RETLW	0x00		; Ref 3 Chan 1 R2 Byte 1
	RETLW	0x00		; Ref 3 Chan 1 R2 Byte 2
	RETLW	0x00		; Ref 3 Chan 1 R2 Byte 3
	RETLW	0x12		; Ref 3 Chan 1 R2 Byte 4
	RETLW	0x34		; Ref 3 Chan 1 R4 Byte 1
	RETLW	0x00		; Ref 3 Chan 1 R4 Byte 2
	RETLW	0xA7		; Ref 3 Chan 1 R4 Byte 3
	RETLW	0x84		; Ref 3 Chan 1 R4 Byte 4
	RETLW	0x35		; Ref 3 Chan 1 R6 Byte 1
	RETLW	0xC3		; Ref 3 Chan 1 R6 Byte 2
	RETLW	0x24		; Ref 3 Chan 1 R6 Byte 3
	RETLW	0x76		; Ref 3 Chan 1 R6 Byte 4
	RETLW	0x15		; Ref 3 Chan 1 R9 Byte 1
	RETLW	0x15		; Ref 3 Chan 1 R9 Byte 2
	RETLW	0x3C		; Ref 3 Chan 1 R9 Byte 3
	RETLW	0xC9		; Ref 3 Chan 1 R9 Byte 4
	RETLW	0x00		; Ref 3 Chan 1 R10 Byte 1
	RETLW	0xC0		; Ref 3 Chan 1 R10 Byte 2
	RETLW	0x1F		; Ref 3 Chan 1 R10 Byte 3
	RETLW	0x7A		; Ref 3 Chan 1 R10 Byte 4

	RETLW	0x00		; Ref 3 Chan 2 R0 Byte 1 25 MHz Ref 144.1 MHz
	RETLW	0x20		; Ref 3 Chan 2 R0 Byte 2
	RETLW	0x05		; Ref 3 Chan 2 R0 Byte 3
	RETLW	0xC0		; Ref 3 Chan 2 R0 Byte 4
	RETLW	0x03		; Ref 3 Chan 2 R1 Byte 1
	RETLW	0x95		; Ref 3 Chan 2 R1 Byte 2
	RETLW	0x81		; Ref 3 Chan 2 R1 Byte 3
	RETLW	0x01		; Ref 3 Chan 2 R1 Byte 4
	RETLW	0x20		; Ref 3 Chan 2 R2 Byte 1
	RETLW	0xC5		; Ref 3 Chan 2 R2 Byte 2
	RETLW	0x55		; Ref 3 Chan 2 R2 Byte 3
	RETLW	0x52		; Ref 3 Chan 2 R2 Byte 4
	RETLW	0x34		; Ref 3 Chan 2 R4 Byte 1
	RETLW	0x00		; Ref 3 Chan 2 R4 Byte 2
	RETLW	0xA7		; Ref 3 Chan 2 R4 Byte 3
	RETLW	0x84		; Ref 3 Chan 2 R4 Byte 4
	RETLW	0x35		; Ref 3 Chan 2 R6 Byte 1
	RETLW	0xA4		; Ref 3 Chan 2 R6 Byte 2
	RETLW	0x64		; Ref 3 Chan 2 R6 Byte 3
	RETLW	0x76		; Ref 3 Chan 2 R6 Byte 4
	RETLW	0x15		; Ref 3 Chan 2 R9 Byte 1
	RETLW	0x15		; Ref 3 Chan 2 R9 Byte 2
	RETLW	0x3C		; Ref 3 Chan 2 R9 Byte 3
	RETLW	0xC9		; Ref 3 Chan 2 R9 Byte 4
	RETLW	0x00		; Ref 3 Chan 2 R10 Byte 1
	RETLW	0xC0		; Ref 3 Chan 2 R10 Byte 2
	RETLW	0x1F		; Ref 3 Chan 2 R10 Byte 3
	RETLW	0x7A		; Ref 3 Chan 2 R10 Byte 4

	RETLW	0x00		; Ref 3 Chan 3 R0 Byte 1 25 MHz Ref 432.1 MHz
	RETLW	0x20		; Ref 3 Chan 3 R0 Byte 2
	RETLW	0x04		; Ref 3 Chan 3 R0 Byte 3
	RETLW	0x50		; Ref 3 Chan 3 R0 Byte 4
	RETLW	0x02		; Ref 3 Chan 3 R1 Byte 1
	RETLW	0x2D		; Ref 3 Chan 3 R1 Byte 2
	RETLW	0x0E		; Ref 3 Chan 3 R1 Byte 3
	RETLW	0x51		; Ref 3 Chan 3 R1 Byte 4
	RETLW	0x60		; Ref 3 Chan 3 R2 Byte 1
	RETLW	0x43		; Ref 3 Chan 3 R2 Byte 2
	RETLW	0xFF		; Ref 3 Chan 3 R2 Byte 3
	RETLW	0xF2		; Ref 3 Chan 3 R2 Byte 4
	RETLW	0x34		; Ref 3 Chan 3 R4 Byte 1
	RETLW	0x00		; Ref 3 Chan 3 R4 Byte 2
	RETLW	0xA7		; Ref 3 Chan 3 R4 Byte 3
	RETLW	0x84		; Ref 3 Chan 3 R4 Byte 4
	RETLW	0x35		; Ref 3 Chan 3 R6 Byte 1
	RETLW	0x65		; Ref 3 Chan 3 R6 Byte 2
	RETLW	0xC4		; Ref 3 Chan 3 R6 Byte 3
	RETLW	0x76		; Ref 3 Chan 3 R6 Byte 4
	RETLW	0x15		; Ref 3 Chan 3 R9 Byte 1
	RETLW	0x15		; Ref 3 Chan 3 R9 Byte 2
	RETLW	0x3C		; Ref 3 Chan 3 R9 Byte 3
	RETLW	0xC9		; Ref 3 Chan 3 R9 Byte 4
	RETLW	0x00		; Ref 3 Chan 3 R10 Byte 1
	RETLW	0xC0		; Ref 3 Chan 3 R10 Byte 2
	RETLW	0x1F		; Ref 3 Chan 3 R10 Byte 3
	RETLW	0x7A		; Ref 3 Chan 3 R10 Byte 4

	RETLW	0x00		; Ref 3 Chan 4 R0 Byte 1 25 MHz Ref 1296.1 MHz
	RETLW	0x20		; Ref 3 Chan 4 R0 Byte 2
	RETLW	0x06		; Ref 3 Chan 4 R0 Byte 3
	RETLW	0x70		; Ref 3 Chan 4 R0 Byte 4
	RETLW	0x0B		; Ref 3 Chan 4 R1 Byte 1
	RETLW	0x02		; Ref 3 Chan 4 R1 Byte 2
	RETLW	0x0C		; Ref 3 Chan 4 R1 Byte 3
	RETLW	0x41		; Ref 3 Chan 4 R1 Byte 4
	RETLW	0x9B		; Ref 3 Chan 4 R2 Byte 1
	RETLW	0xA7		; Ref 3 Chan 4 R2 Byte 2
	RETLW	0xFF		; Ref 3 Chan 4 R2 Byte 3
	RETLW	0xF2		; Ref 3 Chan 4 R2 Byte 4
	RETLW	0x34		; Ref 3 Chan 4 R4 Byte 1
	RETLW	0x00		; Ref 3 Chan 4 R4 Byte 2
	RETLW	0xA7		; Ref 3 Chan 4 R4 Byte 3
	RETLW	0x84		; Ref 3 Chan 4 R4 Byte 4
	RETLW	0x35		; Ref 3 Chan 4 R6 Byte 1
	RETLW	0x43		; Ref 3 Chan 4 R6 Byte 2
	RETLW	0xE4		; Ref 3 Chan 4 R6 Byte 3
	RETLW	0x76		; Ref 3 Chan 4 R6 Byte 4
	RETLW	0x15		; Ref 3 Chan 4 R9 Byte 1
	RETLW	0x15		; Ref 3 Chan 4 R9 Byte 2
	RETLW	0x3C		; Ref 3 Chan 4 R9 Byte 3
	RETLW	0xC9		; Ref 3 Chan 4 R9 Byte 4
	RETLW	0x00		; Ref 3 Chan 4 R10 Byte 1
	RETLW	0xC0		; Ref 3 Chan 4 R10 Byte 2
	RETLW	0x1F		; Ref 3 Chan 4 R10 Byte 3
	RETLW	0x7A		; Ref 3 Chan 4 R10 Byte 4

	RETLW	0x00		; Ref 3 Chan 5 R0 Byte 1 25 MHz Ref 2320.1 MHz
	RETLW	0x20		; Ref 3 Chan 5 R0 Byte 2
	RETLW	0x05		; Ref 3 Chan 5 R0 Byte 3
	RETLW	0xC0		; Ref 3 Chan 5 R0 Byte 4
	RETLW	0x0C		; Ref 3 Chan 5 R1 Byte 1
	RETLW	0xDD		; Ref 3 Chan 5 R1 Byte 2
	RETLW	0x2F		; Ref 3 Chan 5 R1 Byte 3
	RETLW	0x11		; Ref 3 Chan 5 R1 Byte 4
	RETLW	0x38		; Ref 3 Chan 5 R2 Byte 1
	RETLW	0xA9		; Ref 3 Chan 5 R2 Byte 2
	RETLW	0x55		; Ref 3 Chan 5 R2 Byte 3
	RETLW	0x52		; Ref 3 Chan 5 R2 Byte 4
	RETLW	0x34		; Ref 3 Chan 5 R4 Byte 1
	RETLW	0x00		; Ref 3 Chan 5 R4 Byte 2
	RETLW	0xA7		; Ref 3 Chan 5 R4 Byte 3
	RETLW	0x84		; Ref 3 Chan 5 R4 Byte 4
	RETLW	0x35		; Ref 3 Chan 5 R6 Byte 1
	RETLW	0x24		; Ref 3 Chan 5 R6 Byte 2
	RETLW	0x44		; Ref 3 Chan 5 R6 Byte 3
	RETLW	0x76		; Ref 3 Chan 5 R6 Byte 4
	RETLW	0x15		; Ref 3 Chan 5 R9 Byte 1
	RETLW	0x15		; Ref 3 Chan 5 R9 Byte 2
	RETLW	0x3C		; Ref 3 Chan 5 R9 Byte 3
	RETLW	0xC9		; Ref 3 Chan 5 R9 Byte 4
	RETLW	0x00		; Ref 3 Chan 5 R10 Byte 1
	RETLW	0xC0		; Ref 3 Chan 5 R10 Byte 2
	RETLW	0x1F		; Ref 3 Chan 5 R10 Byte 3
	RETLW	0x7A		; Ref 3 Chan 5 R10 Byte 4

	RETLW	0x00		; Ref 3 Chan 6 R0 Byte 1 25 MHz Ref 2400.1 MHz
	RETLW	0x20		; Ref 3 Chan 6 R0 Byte 2
	RETLW	0x06		; Ref 3 Chan 6 R0 Byte 3
	RETLW	0x00		; Ref 3 Chan 6 R0 Byte 4
	RETLW	0x00		; Ref 3 Chan 6 R1 Byte 1
	RETLW	0x10		; Ref 3 Chan 6 R1 Byte 2
	RETLW	0x62		; Ref 3 Chan 6 R1 Byte 3
	RETLW	0x41		; Ref 3 Chan 6 R1 Byte 4
	RETLW	0xDD		; Ref 3 Chan 6 R2 Byte 1
	RETLW	0x2F		; Ref 3 Chan 6 R2 Byte 2
	RETLW	0xFF		; Ref 3 Chan 6 R2 Byte 3
	RETLW	0xF2		; Ref 3 Chan 6 R2 Byte 4
	RETLW	0x34		; Ref 3 Chan 6 R4 Byte 1
	RETLW	0x00		; Ref 3 Chan 6 R4 Byte 2
	RETLW	0xA7		; Ref 3 Chan 6 R4 Byte 3
	RETLW	0x84		; Ref 3 Chan 6 R4 Byte 4
	RETLW	0x35		; Ref 3 Chan 6 R6 Byte 1
	RETLW	0x24		; Ref 3 Chan 6 R6 Byte 2
	RETLW	0x24		; Ref 3 Chan 6 R6 Byte 3
	RETLW	0x76		; Ref 3 Chan 6 R6 Byte 4
	RETLW	0x15		; Ref 3 Chan 6 R9 Byte 1
	RETLW	0x15		; Ref 3 Chan 6 R9 Byte 2
	RETLW	0x3C		; Ref 3 Chan 6 R9 Byte 3
	RETLW	0xC9		; Ref 3 Chan 6 R9 Byte 4
	RETLW	0x00		; Ref 3 Chan 6 R10 Byte 1
	RETLW	0xC0		; Ref 3 Chan 6 R10 Byte 2
	RETLW	0x1F		; Ref 3 Chan 6 R10 Byte 3
	RETLW	0x7A		; Ref 3 Chan 6 R10 Byte 4

	RETLW	0x00		; Ref 3 Chan 7 R0 Byte 1 25 MHz Ref 3400.1 MHz
	RETLW	0x20		; Ref 3 Chan 7 R0 Byte 2
	RETLW	0x04		; Ref 3 Chan 7 R0 Byte 3
	RETLW	0x40		; Ref 3 Chan 7 R0 Byte 4
	RETLW	0x00		; Ref 3 Chan 7 R1 Byte 1
	RETLW	0x08		; Ref 3 Chan 7 R1 Byte 2
	RETLW	0x31		; Ref 3 Chan 7 R1 Byte 3
	RETLW	0x21		; Ref 3 Chan 7 R1 Byte 4
	RETLW	0x24		; Ref 3 Chan 7 R2 Byte 1
	RETLW	0xDD		; Ref 3 Chan 7 R2 Byte 2
	RETLW	0x55		; Ref 3 Chan 7 R2 Byte 3
	RETLW	0x52		; Ref 3 Chan 7 R2 Byte 4
	RETLW	0x34		; Ref 3 Chan 7 R4 Byte 1
	RETLW	0x00		; Ref 3 Chan 7 R4 Byte 2
	RETLW	0xA7		; Ref 3 Chan 7 R4 Byte 3
	RETLW	0x84		; Ref 3 Chan 7 R4 Byte 4
	RETLW	0x35		; Ref 3 Chan 7 R6 Byte 1
	RETLW	0x05		; Ref 3 Chan 7 R6 Byte 2
	RETLW	0xE4		; Ref 3 Chan 7 R6 Byte 3
	RETLW	0x76		; Ref 3 Chan 7 R6 Byte 4
	RETLW	0x15		; Ref 3 Chan 7 R9 Byte 1
	RETLW	0x15		; Ref 3 Chan 7 R9 Byte 2
	RETLW	0x3C		; Ref 3 Chan 7 R9 Byte 3
	RETLW	0xC9		; Ref 3 Chan 7 R9 Byte 4
	RETLW	0x00		; Ref 3 Chan 7 R10 Byte 1
	RETLW	0xC0		; Ref 3 Chan 7 R10 Byte 2
	RETLW	0x1F		; Ref 3 Chan 7 R10 Byte 3
	RETLW	0x7A		; Ref 3 Chan 7 R10 Byte 4

	RETLW	0x00		; Ref 3 Chan 8 R0 Byte 1 25 MHz Ref 5760.1 MHz
	RETLW	0x20		; Ref 3 Chan 8 R0 Byte 2
	RETLW	0x07		; Ref 3 Chan 8 R0 Byte 3
	RETLW	0x30		; Ref 3 Chan 8 R0 Byte 4
	RETLW	0x03		; Ref 3 Chan 8 R1 Byte 1
	RETLW	0x3B		; Ref 3 Chan 8 R1 Byte 2
	RETLW	0x64		; Ref 3 Chan 8 R1 Byte 3
	RETLW	0x51		; Ref 3 Chan 8 R1 Byte 4
	RETLW	0xA1		; Ref 3 Chan 8 R2 Byte 1
	RETLW	0xCB		; Ref 3 Chan 8 R2 Byte 2
	RETLW	0xFF		; Ref 3 Chan 8 R2 Byte 3
	RETLW	0xF2		; Ref 3 Chan 8 R2 Byte 4
	RETLW	0x34		; Ref 3 Chan 8 R4 Byte 1
	RETLW	0x00		; Ref 3 Chan 8 R4 Byte 2
	RETLW	0xA7		; Ref 3 Chan 8 R4 Byte 3
	RETLW	0x84		; Ref 3 Chan 8 R4 Byte 4
	RETLW	0x35		; Ref 3 Chan 8 R6 Byte 1
	RETLW	0x03		; Ref 3 Chan 8 R6 Byte 2
	RETLW	0x84		; Ref 3 Chan 8 R6 Byte 3
	RETLW	0x76		; Ref 3 Chan 8 R6 Byte 4
	RETLW	0x15		; Ref 3 Chan 8 R9 Byte 1
	RETLW	0x15		; Ref 3 Chan 8 R9 Byte 2
	RETLW	0x3C		; Ref 3 Chan 8 R9 Byte 3
	RETLW	0xC9		; Ref 3 Chan 8 R9 Byte 4
	RETLW	0x00		; Ref 3 Chan 8 R10 Byte 1
	RETLW	0xC0		; Ref 3 Chan 8 R10 Byte 2
	RETLW	0x1F		; Ref 3 Chan 8 R10 Byte 3
	RETLW	0x7A		; Ref 3 Chan 8 R10 Byte 4

	ORG	0x0900		; 

LUREF3B	ADDWF	PCL, F		; Reference 3, Channels 9 - 12
	RETLW	0x00		; Ref 3 Chan 9 R0 Byte 1 25 MHz Ref 10368.1 MHz
	RETLW	0x20		; Ref 3 Chan 9 R0 Byte 2
	RETLW	0x06		; Ref 3 Chan 9 R0 Byte 3
	RETLW	0x70		; Ref 3 Chan 9 R0 Byte 4
	RETLW	0x0A		; Ref 3 Chan 9 R1 Byte 1
	RETLW	0xE5		; Ref 3 Chan 9 R1 Byte 2
	RETLW	0x60		; Ref 3 Chan 9 R1 Byte 3
	RETLW	0x41		; Ref 3 Chan 9 R1 Byte 4
	RETLW	0x18		; Ref 3 Chan 9 R2 Byte 1
	RETLW	0x97		; Ref 3 Chan 9 R2 Byte 2
	RETLW	0xFF		; Ref 3 Chan 9 R2 Byte 3
	RETLW	0xF2		; Ref 3 Chan 9 R2 Byte 4
	RETLW	0x34		; Ref 3 Chan 9 R4 Byte 1
	RETLW	0x00		; Ref 3 Chan 9 R4 Byte 2
	RETLW	0xA7		; Ref 3 Chan 9 R4 Byte 3
	RETLW	0x84		; Ref 3 Chan 9 R4 Byte 4
	RETLW	0x35		; Ref 3 Chan 9 R6 Byte 1
	RETLW	0x03		; Ref 3 Chan 9 R6 Byte 2
	RETLW	0xE0		; Ref 3 Chan 9 R6 Byte 3
	RETLW	0x36		; Ref 3 Chan 9 R6 Byte 4
	RETLW	0x15		; Ref 3 Chan 9 R9 Byte 1
	RETLW	0x15		; Ref 3 Chan 9 R9 Byte 2
	RETLW	0x3C		; Ref 3 Chan 9 R9 Byte 3
	RETLW	0xC9		; Ref 3 Chan 9 R9 Byte 4
	RETLW	0x00		; Ref 3 Chan 9 R10 Byte 1
	RETLW	0xC0		; Ref 3 Chan 9 R10 Byte 2
	RETLW	0x1F		; Ref 3 Chan 9 R10 Byte 3
	RETLW	0x7A		; Ref 3 Chan 9 R10 Byte 4

	RETLW	0x00		; Ref 3 Chan 10 R0 Byte 1 25 MHz Ref 24048.1 MHz (/3)
	RETLW	0x20		; Ref 3 Chan 10 R0 Byte 2
	RETLW	0x05		; Ref 3 Chan 10 R0 Byte 3
	RETLW	0x00		; Ref 3 Chan 10 R0 Byte 4
	RETLW	0x02		; Ref 3 Chan 10 R1 Byte 1
	RETLW	0x90		; Ref 3 Chan 10 R1 Byte 2
	RETLW	0xB9		; Ref 3 Chan 10 R1 Byte 3
	RETLW	0xA1		; Ref 3 Chan 10 R1 Byte 4
	RETLW	0xF6		; Ref 3 Chan 10 R2 Byte 1
	RETLW	0x8B		; Ref 3 Chan 10 R2 Byte 2
	RETLW	0xFF		; Ref 3 Chan 10 R2 Byte 3
	RETLW	0xF2		; Ref 3 Chan 10 R2 Byte 4
	RETLW	0x34		; Ref 3 Chan 10 R4 Byte 1
	RETLW	0x00		; Ref 3 Chan 10 R4 Byte 2
	RETLW	0xA7		; Ref 3 Chan 10 R4 Byte 3
	RETLW	0x84		; Ref 3 Chan 10 R4 Byte 4
	RETLW	0x35		; Ref 3 Chan 10 R6 Byte 1
	RETLW	0x05		; Ref 3 Chan 10 R6 Byte 2
	RETLW	0x00		; Ref 3 Chan 10 R6 Byte 3
	RETLW	0x36		; Ref 3 Chan 10 R6 Byte 4
	RETLW	0x15		; Ref 3 Chan 10 R9 Byte 1
	RETLW	0x15		; Ref 3 Chan 10 R9 Byte 2
	RETLW	0x3C		; Ref 3 Chan 10 R9 Byte 3
	RETLW	0xC9		; Ref 3 Chan 10 R9 Byte 4
	RETLW	0x00		; Ref 3 Chan 10 R10 Byte 1
	RETLW	0xC0		; Ref 3 Chan 10 R10 Byte 2
	RETLW	0x1F		; Ref 3 Chan 10 R10 Byte 3
	RETLW	0x7A		; Ref 3 Chan 10 R10 Byte 4

	RETLW	0x00		; Ref 3 Chan 11 R0 Byte 1 25 MHz Ref 47088.1 MHz (/5)
	RETLW	0x20		; Ref 3 Chan 11 R0 Byte 2
	RETLW	0x05		; Ref 3 Chan 11 R0 Byte 3
	RETLW	0xE0		; Ref 3 Chan 11 R0 Byte 4
	RETLW	0x02		; Ref 3 Chan 11 R1 Byte 1
	RETLW	0xD1		; Ref 3 Chan 11 R1 Byte 2
	RETLW	0xB7		; Ref 3 Chan 11 R1 Byte 3
	RETLW	0x11		; Ref 3 Chan 11 R1 Byte 4
	RETLW	0x75		; Ref 3 Chan 11 R2 Byte 1
	RETLW	0x8F		; Ref 3 Chan 11 R2 Byte 2
	RETLW	0xFF		; Ref 3 Chan 11 R2 Byte 3
	RETLW	0xF2		; Ref 3 Chan 11 R2 Byte 4
	RETLW	0x34		; Ref 3 Chan 11 R4 Byte 1
	RETLW	0x00		; Ref 3 Chan 11 R4 Byte 2
	RETLW	0xA7		; Ref 3 Chan 11 R4 Byte 3
	RETLW	0x84		; Ref 3 Chan 11 R4 Byte 4
	RETLW	0x35		; Ref 3 Chan 11 R6 Byte 1
	RETLW	0x04		; Ref 3 Chan 11 R6 Byte 2
	RETLW	0x40		; Ref 3 Chan 11 R6 Byte 3
	RETLW	0x36		; Ref 3 Chan 11 R6 Byte 4
	RETLW	0x15		; Ref 3 Chan 11 R9 Byte 1
	RETLW	0x15		; Ref 3 Chan 11 R9 Byte 2
	RETLW	0x3C		; Ref 3 Chan 11 R9 Byte 3
	RETLW	0xC9		; Ref 3 Chan 11 R9 Byte 4
	RETLW	0x00		; Ref 3 Chan 11 R10 Byte 1
	RETLW	0xC0		; Ref 3 Chan 11 R10 Byte 2
	RETLW	0x1F		; Ref 3 Chan 11 R10 Byte 3
	RETLW	0x7A		; Ref 3 Chan 11 R10 Byte 4

	RETLW	0x00		; Ref 3 Chan 12 R0 Byte 1 25 MHz Ref 108537.4 MHz
	RETLW	0x20		; Ref 3 Chan 12 R0 Byte 2
	RETLW	0x06		; Ref 3 Chan 12 R0 Byte 3
	RETLW	0xC0		; Ref 3 Chan 12 R0 Byte 4
	RETLW	0x08		; Ref 3 Chan 12 R1 Byte 1
	RETLW	0x99		; Ref 3 Chan 12 R1 Byte 2
	RETLW	0x4E		; Ref 3 Chan 12 R1 Byte 3
	RETLW	0xB1		; Ref 3 Chan 12 R1 Byte 4
	RETLW	0xB4		; Ref 3 Chan 12 R2 Byte 1
	RETLW	0xEF		; Ref 3 Chan 12 R2 Byte 2
	RETLW	0xFF		; Ref 3 Chan 12 R2 Byte 3
	RETLW	0xF2		; Ref 3 Chan 12 R2 Byte 4
	RETLW	0x34		; Ref 3 Chan 12 R4 Byte 1
	RETLW	0x00		; Ref 3 Chan 12 R4 Byte 2
	RETLW	0xA7		; Ref 3 Chan 12 R4 Byte 3
	RETLW	0x84		; Ref 3 Chan 12 R4 Byte 4
	RETLW	0x35		; Ref 3 Chan 12 R6 Byte 1
	RETLW	0x03		; Ref 3 Chan 12 R6 Byte 2
	RETLW	0xA0		; Ref 3 Chan 12 R6 Byte 3
	RETLW	0x36		; Ref 3 Chan 12 R6 Byte 4
	RETLW	0x15		; Ref 3 Chan 12 R9 Byte 1
	RETLW	0x15		; Ref 3 Chan 12 R9 Byte 2
	RETLW	0x3C		; Ref 3 Chan 12 R9 Byte 3
	RETLW	0xC9		; Ref 3 Chan 12 R9 Byte 4
	RETLW	0x00		; Ref 3 Chan 12 R10 Byte 1
	RETLW	0xC0		; Ref 3 Chan 12 R10 Byte 2
	RETLW	0x1F		; Ref 3 Chan 12 R10 Byte 3
	RETLW	0x7A		; Ref 3 Chan 12 R10 Byte 4

;------ End of LOOKUP TABLES -----------------------------------------
	
	END
 