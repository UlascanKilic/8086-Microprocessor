CODE SEGMENT  PUBLIC    'CODE'
		ASSUME CS:  CODE , DS: DATA,   SS:STAK
	
STAK SEGMENT PARA STACK   'STACK'
        DW 20 DUP(?)
STAK  ENDS

DATA    SEGMENT PARA   'DATA'

DATA    ENDS
START:
	
	;Frekans 4hz ve CLK 2Mhz olacak
	
	;Clock / Frekans = 2.10^6 / 4 > 65536 oldu�u i�in iki CLK kullanarak bu problemi ��zece�iz.
	;Elde etmek istedi�imiz de�er 2.10^6 / 4 = 500 000 
	;Her biri 2^16 dan b�y�k olmayacak �ekilde �arp�mlar� 500 000 verecek iki adet de�er belirliyorum
	;2500 ve 200  de�erlerini belirledim. 2500 de�erini Counter 0 da sayd�raca��m ve bu sayma i�lemi bitince 200 de�erini atad���m Counter 1 e ge�ece�im.
	
	;Counter 0 Ayarlamas�
        MOV AL, 00110111b ;BCD okuma, LSB->MSB okuma ve Mod 3
	OUT 7EH, AL		
	
	;Counter 1 Ayarlamas�
	MOV AL, 01110111b;BCD okuma, LSB->MSB okuma ve Mod 3
	OUT 7EH, AL
	
	XOR AL,AL
	OUT 78H, AL
	OUT 7AH, AL
	
	;Counter 0'a 2500 de�erini BCD olarak g�nderiyorum
	MOV AL,00H
	OUT 78H, AL ; LSB to MSB okuma yapaca��m i�in �nce AL ile LSB(00)'yi al�yorum
	
	MOV AL, 25H ; S�rada MSB var ve AH'den de�eri al�yorum(25)
	OUT 78H, AL
	
	
	;Counter 1'e 200 de�erini BCD olarak g�nderiyorum
	MOV AL,00H
	OUT 7AH, AL ; LSB to MSB okuma yapaca��m i�in �nce AL ile LSB(00)'yi al�yorum	
	MOV AL,02H
	OUT 7AH, AL

ENDLESS:
        JMP ENDLESS
CODE    ENDS
        END START