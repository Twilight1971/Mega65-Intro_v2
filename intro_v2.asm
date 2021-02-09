//--------------------------------------------------------------------------------------
//  Mega65 Intro coded by Twilight 2021
//	Kick Assembler v5.16
//  tested only on Mega65 Emulator Xemu
//
//--------------------------------------------------------------------------------------

.cpu _45gs02                
#import "m65macros.s"
//--------------------------------------------------------------------------------------

.pc = $6000 "sid"
.import binary "Lets_do_it_Figge_Style.dat",2      

.pc = $4800 "1x2char"
.import binary "1x2charok.bin"      

.pc = $4000 "logocharset"
.import binary "logocharset.bin"

.pc = $5000
.fill 440,$00
.fill 600,$20

//--------------------------------------------------------------------------------------

BasicUpstart65(Entry)

* = $2020

Entry:

						lda #$00
						tax 
						tay 
						taz 
						map
						eom				
								
						lda #$00		
						sta $d021		
						lda #$00		
						sta $d020		
							
						jsr scrinit


						lda #$00
						jsr $6000
						
						
						ldx #$00
				!:		
						lda #$00
						sta $d900+101,x
						sta $da00,x
						sta $db00,x
						inx
						bne !-
				
						ldx #$00
			!:			lda logo1,x
						sta $5000,x
						lda logo2,x
						sta $5000+40,x
						lda logo3,x
						sta $5000+40*2,x
						lda logo4,x
						sta $5000+40*3,x
						lda logo5,x
						sta $5000+40*4,x
						lda logo6,x
						sta $5000+40*5,x
						lda logo7,x
						sta $5000+40*6,x
						lda logo8,x
						sta $5000+40*7,x
						lda logo9,x
						sta $5000+40*8,x
						lda #$20
						sta $5000+40*10,x 
						lda text1,x
						sta $5000+40*11,x
						adc #$80
						sta $5000+40*12,x
						
						lda #$0a
						sta $d800,x
						sta $d800+40*1,x
						sta $d800+40*2,x
						sta $d800+40*3,x
						sta $d800+40*4,x
						sta $d800+40*5,x
						sta $d800+40*6,x
						sta $d800+40*7,x
						sta $d800+40*8,x
						lda #$01
						sta $d800+40*11,x
						sta $d800+40*12,x
						inx
						cpx #$28
						bne !-
				

//--------------------------------------------------------------------------------------

						sei
						lda #$35
						sta $01
						
						mapMemory($ffd2000, $c000)
						
						lda #$7f
						sta $dc0d
						sta $dd0d
						
						lda #$00
						sta $d012
						
						
						ldx #<irq1
						ldy #>irq1
						stx $fffe
						sty $ffff
						lda $d01a
						ora #$01
						sta $d01a
						lda #$1b
						sta $d011
						asl $d019
						cli
						
						
						jmp *
				
//--------------------------------------------------------------------------------------
			irq1:		pha
						txa
						pha
						tya
						pha
						asl $d019
						
						
						
						lda #$50			//ScreenRam
						sta $d061
						
						lda #$d8
						sta $d016
						
						lda #$0f
						sta $d022
						lda #$0a
						sta $d023
						
						lda #$40
						sta $d069
						
						lda #$00
						sta $d05c
						
						lda $D031
						and #%01111111
						sta $d031				
										
						lda $D030
						and #%01111111
						sta $d030				
								
				
						lda #$00
						sta $d04d				// Text X Pos
					//	sty $d04c				// Text X Pos
						
						
			bo1:		ldx #$00
			!:			lda techsinus,x
						sta $d04c
						ldy #$60
				lop3:	dey
						bne lop3
						inx
						cpx #$70
						bne !-
				
				
						
				//		lda bo1+1
				//		clc
				//		adc #01
				//		sta bo1+1
						
						lda bo2+1
						clc
						adc #01
						sta bo2+1
						
						
						lda #$6b
						sta $d012
						ldx #<irq2
						ldy #>irq2
						stx $fffe
						sty $ffff
						pla
						tay
						pla
						tax
						pla
						rti

//--------------------------------------------------------------------------------------
			irq2:		pha
						txa
						pha
						tya
						pha
						asl $d019
						
						
						lda #$48		// charset
						sta $d069
						
			bo2:		ldx #$80
						ldy bounce,x
						lda #$00
						sta $d04d				// Text X Pos
						sty $d04c				// Text X Pos
						
						lda #$8a
			!:			cmp $d012
						bne !-
						
						lda buffer2
						sta $d04c
						
						ldx #$00
			!:			lda colortab,x
						sta $d021
						ldy #$60
				lop1:	dey
						bne lop1
						inx
						cpx #$60
						bne !-
						
						jsr scroll
						jsr scroll
						
						
						
						lda #$00
						sta $d012
						ldx #<irq1
						ldy #>irq1
						stx $fffe
						sty $ffff
						jsr rastereffekt
						jsr fixit
						jsr techtech
						pla
						tay
						pla
						tax
						pla
						rti

//--------------------------------------------------------------------------------------

fixit:

						lda #$06
						beq reset
						dec fixit+$01
		ntscfix:		jmp $6003 //(play music)
		
		reset:
		
						lda #$06
						sta fixit+$01
						rts

//--------------------------------------------------------------------------------------


techtech:								// left Rasterrotation
						lda techsinus+$ff
						sta techsinus+$00
						ldx #$ff
		!:		   
						lda techsinus-$01,x
						sta techsinus+$00,x
						dex
						bne !-
						rts

//--------------------------------------------------------------------------------------

scroll:
						dec buffer2
						lda buffer2
						cmp #$0f+55
						beq !+
						rts
		!:				lda #$1f+55
						sta buffer2
						ldx #$00
		!:				lda $5169+240,x			
						sta $5168+240,x			
						lda $5169+40+240,x			
						sta $5168+40+240,x			
						inx			
						cpx #$27			
						bne !-			
		textp:			lda scrolltext						
						bne !+					
		scrinit:		lda #<scrolltext					
						sta textp+1					
						lda #>scrolltext					
						sta textp+2					
						rts					
		!:								
						sta $518e+240					
						adc #$7f			
						sta $518e+40+240					
						inc textp+1					
						lda textp+1					
						bne !+					
						inc textp+2					
		!:				rts					

buffer2: .byte $00

//--------------------------------------------------------------------------------------

scrolltext:							
.text "   welcome to my little mega65 intro !   music is an c64 SID  ! it doesn't sound like on a c64 but it is quiet nice ! "
.text " i only have to slow it down a bit         "							
							
.byte $00							


//-------------------------------------------------------------------------------------------------------------------------						


rastereffekt:
						ldx #$00
			!:			lda rastercopy,x
						sta colortab,x
						inx
						cpx #$60
						bne !-
				
	mov1:				ldx #$00
						ldy barsinus,x
						ldx #$00
			!:			
						lda bar1,x
						sta colortab,y
						
						iny
						inx
						cpx #11
						bne !-
						
						lda mov1+1
						clc
						adc #$01
						sta mov1+1
				
	mov2:				ldx #30
						ldy barsinus,x
						ldx #$00
			!:			
						lda bar2,x
						sta colortab,y
						
						iny
						inx
						cpx #11
						bne !-
						
						lda mov2+1
						clc
						adc #$01
						sta mov2+1
						
	mov3:				ldx #60
						ldy barsinus,x
						ldx #$00
			!:			
						lda bar3,x
						sta colortab,y
						
						iny
						inx
						cpx #11
						bne !-
						
						lda mov3+1
						clc
						adc #$01
						sta mov3+1
						
						rts
						
//--------------------------------------------------------------------------------------
				
bar1: .text "@klogagolk@"				
bar2: .text "@fncgagcnf@"				
bar3: .text "@ibhjajhbi@"				
				
colortab:                                  //
.text "@@@ibhjgaaaaaaaaaaaaaaaaaaaaaaagcndf@@"
.text "@ibbh bhhj hjjg jgga gaag aggj gjjo jool ollk "		
.text "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@qqq "			

rastercopy:
.text "@@@@ibhjgaaaaaaaaaaaaaaaaaaaagcndf@@"
.text "@ibbh bhhj hjjg jgga gaaaaaaaag aggj gjjo jool ollk "		
.text "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@qqq "			


text1:				
//     1234567890123456789012345678901234567890				
.text "      MEGA65 Intro by Twilight                "		
				
bounce:				
.fill 256, 120 + 120*sin(toRadians(i*360/256))

techsinus:				
.fill 256, 78 + 78*sin(toRadians(i*360/256))
      
      
      
barsinus:
 .byte 38,36,34,33,31,29
      .byte 28,26,25,23,22,20
      .byte 19,17,16,15,13,12
      .byte 11,10,9,8,7,6
      .byte 5,4,4,3,2,2
      .byte 1,1,1,0,0,0
      .byte 0,0,0,0,0,1
      .byte 1,1,2,2,3,3
      .byte 4,4,5,6,7,8
      .byte 8,9,10,11,12,13
      .byte 14,16,17,18,19,20
      .byte 21,22,23,25,26,27
      .byte 28,29,30,31,32,33
      .byte 34,35,36,37,38,39
      .byte 40,41,42,42,43,44
      .byte 44,45,45,46,46,47
      .byte 47,47,48,48,48,48
      .byte 48,48,48,48,48,48
      .byte 48,48,48,47,47,47
      .byte 46,46,45,45,45,44
      .byte 44,43,43,42,41,41
      .byte 40,40,39,39,38,38
      .byte 37,37,36,36,35,35
      .byte 34,34,33,33,33,33
      .byte 32,32,32,32,32,32
      .byte 32,32,32,32,32,32
      .byte 32,33,33,34,34,34
      .byte 35,36,36,37,37,38
      .byte 39,40,41,42,42,43
      .byte 44,45,46,47,48,50
      .byte 51,52,53,54,55,56
      .byte 58,59,60,61,62,63
      .byte 64,65,66,67,69,69
      .byte 70,71,72,73,74,75
      .byte 75,76,77,77,78,78
      .byte 79,79,79,80,80,80
      .byte 80,80,80,80,80,79
      .byte 79,79,78,78,77,76
      .byte 76,75,74,73,72,71
      .byte 70,69,68,67,66,64
      .byte 63,61,60,59,57,56
      .byte 54,52,51,49,48,46
      .byte 44,43,41,39      
      
.pc = $3800 "Logo Map"


logo1:
.byte $00, $00, $01, $02, $03, $04, $05, $06, $07, $08, $09, $07, $08, $09, $01, $02, $03, $04, $05, $06, $01, $02, $03, $04, $05, $06, $01, $02, $03, $04, $05, $06, $01, $02, $03, $04, $05, $06, $00, $00
logo2:
.byte $00, $00, $0a, $0b, $0c, $00, $00, $00, $0a, $0b, $0d, $0a, $0b, $0d, $0a, $0b, $0c, $00, $00, $00, $0a, $0b, $0c, $00, $00, $00, $0a, $0b, $0c, $00, $00, $00, $0a, $0b, $0c, $00, $00, $00, $00, $00
logo3:
.byte $00, $00, $0e, $0f, $10, $00, $00, $00, $0e, $0f, $10, $0e, $0f, $10, $0e, $0f, $10, $00, $00, $00, $0e, $0f, $10, $00, $00, $00, $0e, $0f, $10, $00, $00, $00, $0e, $0f, $10, $00, $00, $00, $00, $00
logo4:
.byte $00, $00, $11, $12, $13, $00, $00, $00, $14, $15, $16, $11, $12, $17, $11, $12, $13, $00, $00, $00, $11, $12, $13, $00, $00, $00, $11, $12, $13, $00, $00, $00, $11, $12, $13, $00, $00, $00, $00, $00
logo5:
.byte $00, $00, $18, $19, $1a, $1b, $1c, $00, $1d, $1e, $1f, $20, $21, $22, $18, $19, $23, $00, $00, $00, $18, $19, $1a, $1b, $1c, $00, $24, $25, $26, $1b, $27, $28, $24, $25, $26, $1b, $27, $28, $00, $00
logo6:
.byte $00, $00, $29, $2a, $2b, $2c, $2d, $2e, $2f, $30, $31, $32, $2a, $33, $29, $2a, $2b, $2c, $2d, $2e, $29, $2a, $2b, $2c, $2d, $2e, $34, $35, $36, $37, $38, $39, $34, $35, $36, $37, $38, $39, $00, $00
logo7:
.byte $00, $00, $3a, $3b, $3c, $3a, $3b, $3d, $3a, $3b, $3c, $3a, $3b, $3c, $3a, $3b, $3c, $3a, $3b, $3d, $3a, $3b, $3c, $3a, $3b, $3d, $3a, $3b, $3c, $3a, $3b, $3d, $3a, $3b, $3c, $3a, $3b, $3d, $00, $00
logo8:
.byte $00, $00, $3e, $3f, $40, $3e, $3f, $40, $3e, $3f, $40, $3e, $3f, $40, $3e, $3f, $40, $3e, $3f, $40, $3e, $3f, $40, $3e, $3f, $40, $3e, $3f, $40, $3e, $3f, $40, $3e, $3f, $40, $3e, $3f, $40, $00, $00
logo9:
.byte $00, $00, $41, $42, $43, $44, $45, $46, $41, $42, $47, $41, $42, $47, $41, $42, $43, $44, $45, $46, $41, $42, $43, $44, $45, $46, $41, $42, $43, $44, $45, $46, $41, $42, $43, $44, $45, $46, $00, $00

buffer1: