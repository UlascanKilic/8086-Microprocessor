CODE SEGMENT  PUBLIC    'CODE'
		ASSUME CS:  CODE , DS: DATA,   SS:STAK
	
STAK SEGMENT PARA STACK   'STACK'
        DW 20 DUP(?)
STAK  ENDS

DATA    SEGMENT PARA   'DATA'

DATA    ENDS
START:
	
	;Frekans 4hz ve CLK 2Mhz olacak
	
	;Clock / Frekans = 2.10^6 / 4 > 65536 olduðu için iki CLK kullanarak bu problemi çözeceðiz.
	;Elde etmek istediðimiz deðer 2.10^6 / 4 = 500 000 
	;Her biri 2^16 dan büyük olmayacak þekilde çarpýmlarý 500 000 verecek iki adet deðer belirliyorum
	;2500 ve 200  deðerlerini belirledim. 2500 deðerini Counter 0 da saydýracaðým ve bu sayma iþlemi bitince 200 deðerini atadýðým Counter 1 e geçeceðim.
	
	;Counter 0 Ayarlamasý
        MOV AL, 00110111b ;BCD okuma, LSB->MSB okuma ve Mod 3
	OUT 7EH, AL		
	
	;Counter 1 Ayarlamasý
	MOV AL, 01110111b;BCD okuma, LSB->MSB okuma ve Mod 3
	OUT 7EH, AL
	
	XOR AL,AL
	OUT 78H, AL
	OUT 7AH, AL
	
	;Counter 0'a 2500 deðerini BCD olarak gönderiyorum
	MOV AL,00H
	OUT 78H, AL ; LSB to MSB okuma yapacaðým için önce AL ile LSB(00)'yi alýyorum
	
	MOV AL, 25H ; Sýrada MSB var ve AH'den deðeri alýyorum(25)
	OUT 78H, AL
	
	
	;Counter 1'e 200 deðerini BCD olarak gönderiyorum
	MOV AL,00H
	OUT 7AH, AL ; LSB to MSB okuma yapacaðým için önce AL ile LSB(00)'yi alýyorum	
	MOV AL,02H
	OUT 7AH, AL

ENDLESS:
        JMP ENDLESS
CODE    ENDS
        END START