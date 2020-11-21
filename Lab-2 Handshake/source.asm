CODE SEGMENT  PUBLIC    'CODE'
		ASSUME CS:  CODE , DS: DATA,   SS:STAK
	
STAK SEGMENT PARA STACK   'STACK'
        DW 20 DUP(?)
STAK  ENDS

DATA    SEGMENT PARA   'DATA'
HESAP_MAKINESI DB  0AH,  0EH, 00H, 0FH, 0BH, 03H, 02H, 01H, 0CH, 06H, 05H, 04H, 0DH, 09H, 08H, 07H; KEYPAD TUŞ DEĞERLERİM
; + -> A, -  -> B, x -> C, / -> D, = -> E, C\ON -> F
DIGITS DB 00H, 00H, 00H ; ARİTMETİK İŞLEM YAPACAĞIM ELEMANLARIM

SAYILAR   DB 00H, 00H,00H
ISLEM     DB 00H


PORTA DB 00H, 33H, 30H, 0FFH, 33H, 30H, 0FCH, 30H
PORTB DB 0FFH, 0EEH, 77H, 0DAH, 77H, 77H, 0DDH, 77H	

BASAMAK_ONLUK DB 0
BASAMAK_BIRLIK DB 0
DATA    ENDS

START:
	MOV AX, DATA
	MOV DS, AX
	
	MOV DX, 206h
	MOV AL, 09h ; BSR Moduna girerek INTEA'yı SET yapıyorum 
	OUT DX, AL
	MOV AL, 05h ; BSR Moduna girerek INTEB'yi SET yapıyorum 
	OUT DX, AL
	MOV AL, 0BCh ; 1. 8255 için Control Word ataması yapıyorum : 10111100 ile Port A ve Port B yi mod1 olarak ayarlıyorum
	OUT DX, AL
			
	XOR SI, SI
		
ENDLESS:
	XOR AX,AX
	XOR DX,DX
	
BIRINCI_ASAMA:
	MOV DX, 204h
        IN AL, DX ; C3 pinindeki INTRA bilgisini tutuyorum
	AND AL, 08h ;4 biti maskeliyorum
	CMP AL, 00 ;Interrupt oluşup oluşmamasının kontrolünü yapıyorum
	JE BIRINCI_ASAMA

	MOV DX, 200h ; IntrA 1 oldu ise veriyi okuyorum
	IN AX, DX ; Basılan tuşu okuyorum
	SUB AX, 0F0H
	
	MOV DI, AX
	MOV AL, HESAP_MAKINESI[DI] ; Basılan tuşun sayı değerini alıyorum
	CMP SI, 00H ;Sayıya mı basıldı
	JE DIGIT_SAYI
	CMP SI, 01H ; Operatöre mi basıldı
	JE DIGIT_OP
	
DIGIT_SAYI:	
	CMP AL, 09H
	JA ENDLESS
	
	MOV SAYILAR[SI], AL ;Girilen sayı değerini alıyorum
	JMP SEG_YAK

DIGIT_OP:	
	CMP AL, 09H
	JBE ENDLESS
	
	MOV SAYILAR[SI], AL ;Girilen operatörü alıyorum
	JMP SEG_YAK

SEG_YAK:
	CMP SI, 00H ;7 segmentte 0 gösteriyorum
	JNE OPERATOR 
	PUSH AX
	
IKINCI_ASAMA:
	MOV DX, 204h
	IN AL, DX ; C0 pinindeki INTRB yi alıyorum
	AND AL, 01h ; 
	CMP AL, 00 ; INTRB değişti mi kontrolü
	JE IKINCI_ASAMA
	POP AX
	
	MOV DX, 0202H ; INTRB 1 olursa veriyi yazdırıyorum
	OUT DX, AL 
	INC SI	
	JMP ENDLESS

OPERATOR:
	CMP SI, 001H
	JNE SONUC_GOSTER
	
	XOR AL, AL
	MOV BL, 00100000B
	ADD AL, BL
	PUSH AX
	
UCUNCU_ASAMA:
	MOV DX, 204h
	IN AL, DX ; pc0 INtrb tutar
	AND AL, 01h ; pc0 maskelenir
	CMP AL, 00 ; INtrb kontrolü
	JE UCUNCU_ASAMA	
	
	POP AX
	MOV DX, 0202H
	OUT DX, AL
	INC SI
	JMP ENDLESS

SONUC_GOSTER:
	MOV CL, SAYILAR[1] ; Basılan işaret
	MOV AL, SAYILAR[0] ; 1. sayı
	MOV BL, SAYILAR[2] ; 2. sayı
	
	CMP CL, 0AH ; +
	JE TOPLA	
	CMP CL, 0BH ; -
	JE CIKART	
	CMP CL, 0DH ; /
	JE BOL
	CMP CL, 0CH ; x
	JE CARP	
	
TOPLA:	
	ADD AL, BL
	JMP SON
CIKART:
	SUB AL, BL
	JS HATA
	JMP SON
BOL:
	DIV BL
	CMP AH, 00H
	JNE HATA ;Kalanlı bölme varsa hata
	JMP SON
CARP:
	MUL BL
	JMP SON
	
SON: 
	
	MOV CL, 10
	DIV CL ; AL -> BOLUM AH -> KALAN
	MOV BASAMAK_ONLUK, AL
	MOV BASAMAK_BIRLIK, AH
	CMP AL, 00H ; BOLUM 0 ISE TEK BASAMAK
	JNE HATA

TEK_BASAMAK:
	
YAZ:
	MOV AL, BASAMAK_BIRLIK	
	MOV DX, 202H
	OUT DX, AL
		
ONAY:		
	 XOR SI,SI
	 JMP SIXTEEN_SEG
	 
HATA: 
	 MOV SI,4
	 JMP SIXTEEN_SEG
	  
SIXTEEN_SEG:
	 
	  MOV AL,80H ; 2. 8255'e geçiş yapıyorum ve Control Word değerimi veriyorum
	  OUT 66H,AL	;Belirlediğim Control Word değerini 66H adresine yani Control Word adresine gömüyorum
	  
	  MOV CL,4	 
L2:
	 CALL DELAY
	 MOV AL, PORTA[SI] ;ONAY veya HATA harflerini yazdırıyorum
	 OUT 60H, AL
	 MOV AL, PORTB[SI]
	 OUT 62H, AL
	 INC SI
	 DEC CL
	 JNZ	L2
	  
	 JMP ENDLESS
	 
DELAY PROC NEAR
	 PUSH CX
	 MOV CX, 05FFFh
	 COUNT:
	 LOOP COUNT
	 POP CX
	 RET
 DELAY ENDP
	

CODE    ENDS
        END START