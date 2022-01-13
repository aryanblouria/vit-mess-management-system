DATA SEGMENT
;DEFINING THE IMPORTANT STRINGS
THANKS db "Thank you for using  VIT Mess Management System$" 
WELCOME db '============= Welcome to VIT Mess Management System ================',0DH,0AH,'$' 
NOTICE  DB 'Please input your choice:',0DH,0AH,'$'
NOTICEa DB '1. Enter Data',0DH,0AH,'$' 
NOTICEb DB '2. Sort and View',0DH,0AH,'$' 
NOTICEc  DB '3. View Time Slots',0DH,0AH,'$'
NOTICEd  DB '4. Exit',0DH,0AH,'$'
ERR	DB 'ERROR!',0DH,0AH,'$'
NOTICE1 DB 'Enter name of the VITian: ',0DH,0AH,'$'
NOTICE2 DB 'Academic Year (1/2/3/4/5): ',0DH,0AH,'$'
NOTICE3 DB 'Hostel Room Number:',0DH,0AH,'$'
NOTICE4 DB 'Preferred Time Slot:',0DH,0AH,'$'
NOTICE5 DB 'Do you want to add another record? (Y/N) ',0DH,0AH,'$'
NOTICE6 DB 'Sorting by Hostel Room Number',0DH,0AH,'$'
NOTICE7 DB '18:00~19:00:',0DH,0AH,'$'
NOTICE8 DB '19:00~20:00:',0DH,0AH,'$'
NOTICE9 DB '20:00~21:00:',0DH,0AH,'$'
NOTICE10 DB '21:00~22:00:',0DH,0AH,'$'
NOTICE11 DB 'Shift students who missed their slots to last slot (Y/N)','$'

;DEFINING THE IMPORTANT VARIABLES
TABLE	DW CASE1,CASE2,CASE3,CASE4,DEFAULT
NUMBER 	DW ?;The number of students

COUNT0	DW 0  
COUNT1	DW 0
COUNT2	DW 0
COUNT3	DW 0
COUNT4	DW 0
COUNTMAX DW 70  
DIFFERENCE DW 0
RANDOM DW 0

;DEFINING THE IMPORTANT ARRAYS
NAME_ARR	DB 100 DUP (100 DUP (?));All names are expected to shorter than 10 bytes
NAME_BEGIN	EQU OFFSET NAME_ARR
TIME_ARR	DW 100 DUP (?)
ROOM_ARR		DW 100 DUP (?)
YEAR_ARR	DW 100 DUP (?)
SORTED		DW 100 DUP (?)
BUFFER		DB 10  DUP (0),'$'
BUFREAR		EQU OFFSET BUFFER+10
TYPE_NAME	DB 10
DATA ENDS

STACK SEGMENT STACK
	DW 100 DUP (?)
STACK ENDS

CODE SEGMENT
		ASSUME CS:CODE,DS:DATA,SS:STACK

;START OF THE MAIN CODE
START:
		;SETTING RANDOM VALUES FOR COUNT0, COUNT1, COUNT2 AND RANDOM
		MOV AX,DATA
    	MOV DS,AX   
    	;GENERATING RANDOM NUMBER BW 0-9
    	MOV AH, 00h  ; interrupts to get system time        
    	INT 1AH      ; CX:DX now hold number of clock ticks since midnight      
    	mov ax, dx
    	xor dx, dx
    	mov cx, 70   ;0-70 students for the first slot  
    	div cx       ; here dx contains the remainder of the division - from 0 to 9       
    	MOV CX,DX                                                                         

    	MOV COUNT0, CX

		MOV AX,DATA
    	MOV DS,AX   
    	;GENERATING RANDOM NUMBER BW 0-9
    	MOV AH, 00h  ; interrupts to get system time        
    	INT 1AH      ; CX:DX now hold number of clock ticks since midnight      
    	mov ax, dx
    	xor dx, dx
    	mov cx, 60   ;0-60 students for second slot 
    	div cx       ; here dx contains the remainder of the division - from 0 to 9       
    	MOV CX,DX                                                                         

    	MOV COUNT1, CX

		MOV AX,DATA
    	MOV DS,AX   
    	;GENERATING RANDOM NUMBER BW 0-9
    	MOV AH, 00h  ; interrupts to get system time        
    	INT 1AH      ; CX:DX now hold number of clock ticks since midnight      
    	mov ax, dx
    	xor dx, dx
    	mov cx, 50   ;0-50 students for second slot  
    	div cx       ; here dx contains the remainder of the division - from 0 to 9       
    	MOV CX,DX                                                                         

    	MOV COUNT2, CX                                                                       

MENU:	
		;PRINTING THE MENU OPTIONS
		MOV AX, DATA
		MOV DS, AX
		MOV AH, 9
		MOV DX, OFFSET WELCOME
		INT 21H;Print WELCOME
		MOV DX, OFFSET NOTICE
		INT 21H;Print NOTICE  
		MOV DX, OFFSET NOTICEa
		INT 21H;Print NOTICEa 
		MOV DX, OFFSET NOTICEb
		INT 21H;Print NOTICEb
		MOV DX, OFFSET NOTICEc
		INT 21H;Print NOTICEc
		MOV DX, OFFSET NOTICEd
		INT 21H;Print NOTICEd

		;GETTING USER INPUT CHOICE
		MOV AH, 1
		INT 21H;Get users choice in AL
		CALL CRLF
		SUB AL, '0'
		MOV BL, AL
		CMP BL, 5
		JBE CASE1TO5
		MOV BL, 6
		;SWITCH CASE
CASE1TO5:
		DEC BL;from 0 to 5
		MOV BH, 0
		SHL BX, 1
		JMP TABLE[BX]

CASE1:
		;ENTER DATA
		CALL LOGDATA
		JMP MENU

CASE2:
		;SORT THE DATA
		CALL SORT
		JMP MENU

CASE3:
		;VIEW TIME SLOTS
		CALL STATISTIC
		JMP MENU

CASE4:
		;EXIT BACK TO THE OS
		MOV AX, 4C00H
		INT 21H

DEFAULT:
		MOV AH, 9
		MOV DX, OFFSET ERR
		INT 21H
		JMP MENU

;ENTER DATA
LOGDATA PROC NEAR
		PUSH AX
		PUSH DX
LOG:
		MOV AH, 9
		MOV DX, OFFSET NOTICE1 ; NAME
		INT 21H
		CALL LOGNAME
		CALL CRLF
		MOV AH, 9
		MOV DX, OFFSET NOTICE2 ;ACADEMIC YEAR 
		INT 21H
		CALL LOGYEAR
		CALL CRLF
		MOV AH, 9
		MOV DX, OFFSET NOTICE3 ;HOSTEL ROOM NUMBER 
		INT 21H
        CALL LOGROOM
		CALL CRLF
		MOV AH, 9
		MOV DX, OFFSET NOTICE4 ;TIME 
		INT 21H
		CALL LOGTIME
		CALL CRLF
		INC NUMBER
CHOICE:
		MOV AH, 9
		MOV DX, OFFSET NOTICE5
		INT 21H
		MOV AH, 1
		INT 21H
		CALL CRLF
		CMP AL, 'Y'
		JE LOG
		CMP AL, 'y'
		JE LOG
		CMP AL, 'N'
		JE LOGEND
		CMP AL, 'n'
		JE LOGEND
		MOV AH, 9;Wrong input
		MOV DX, OFFSET ERR
		INT 21H
		JMP CHOICE
LOGEND:
		POP DX
		POP AX
		RET
LOGDATA ENDP

;GET NAME
LOGNAME PROC NEAR
		PUSH AX
		PUSH BX
		PUSH DX
		PUSH SI
		MOV AX, NUMBER
		MOV CL, TYPE_NAME
		MUL CL
		MOV BX, AX
		XOR SI, SI
		LEA BX, NAME_ARR[BX]
		;MOV AH, 0AH
		;INT 21H;The MENU address of string is stored in DX
INLOOP0:
		MOV AH, 1
		INT 21H
		CMP AL, 0DH
		JE INLOOP0END
		MOV [BX+SI], AL
		INC SI
		JMP INLOOP0

INLOOP0END:
		MOV AL, '$'
		MOV [BX+SI], AL
		POP SI
		POP DX
		POP BX
		POP AX
		RET
LOGNAME ENDP

;GET TIMESLOTS
LOGTIME PROC NEAR
		PUSH AX
		PUSH BX
		PUSH CX
		PUSH DX
		PUSH SI
		MOV BX, 0
INLOOP:
		MOV AH, 8
		INT 21H
		XOR AH, AH
		CMP AL, 0DH
		JE INLOOPEND
		CMP AL, '0'
		JB INLOOP; abandon
		CMP AL, '9'
		JA INLOOP; abandon
		PUSH AX
		MOV AX, BX
		MOV CX, 10
		MUL CX
		MOV CX, AX; (CX) = (BX)*10
		POP AX
		JO INLOOP;overflow
		MOV DL, AL ;to show
		SUB AL, '0'
		ADD CX, AX
		JO INLOOP
		MOV BX, CX; (BX) = (BX)*10+(AX)
		MOV AH, 2
		INT 21H
		JMP INLOOP

INLOOPEND:
		MOV SI, NUMBER
		SHL SI, 1 
		MOV TIME_ARR[SI], BX
		
		POP SI
		POP DX
		POP CX
		POP BX
		POP AX
		RET
LOGTIME ENDP

;GET ROOOM NUMBERS
LOGROOM PROC NEAR
		PUSH AX
		PUSH BX
		PUSH CX
		PUSH DX
		PUSH SI
		MOV BX, 0
INLOOP1:
		MOV AH, 8
		INT 21H
		XOR AH, AH
		CMP AL, 0DH
		JE INLOOPEND1
		CMP AL, '0'
		JB INLOOP1; abandon
		CMP AL, '9'
		JA INLOOP1; abandon
		PUSH AX
		MOV AX, BX
		MOV CX, 10
		MUL CX
		MOV CX, AX; (CX) = (BX)*10
		POP AX
		JO INLOOP1;overflow
		MOV DL, AL ;to show
		SUB AL, '0'
		ADD CX, AX
		JO INLOOP1
		MOV BX, CX; (BX) = (BX)*10+(AX)
		MOV AH, 2
		INT 21H
		JMP INLOOP1

INLOOPEND1:
		MOV SI, NUMBER
		SHL SI, 1
		MOV ROOM_ARR[SI], BX
	
		POP SI
		POP DX
		POP CX
		POP BX
		POP AX
		RET
LOGROOM ENDP

;GET ACADEMIC YEAR
LOGYEAR PROC NEAR
		PUSH AX
		PUSH BX
		PUSH CX
		PUSH DX
		PUSH SI
		PUSH DI
		MOV BX, 0
		MOV SI, 0;a flag for '.'
		MOV DI, 100
INLOOP2:
		MOV AH, 8
		INT 21H
		XOR AH, AH
		CMP AL, 0DH
		JE INLOOPEND2
		CMP AL, '.'
		JE CHANGE
		CMP AL, '0'; integer part
		JB INLOOP2; abandon
		CMP AL, '9'
		JA INLOOP2; abandon
		PUSH AX
		MOV AX, BX
		MOV CX, 10
		MUL CX
		MOV CX, AX; (CX) = (BX)*10
		POP AX
		CMP CX, DI
		JA INLOOP2;overflow
		MOV DL, AL ;to show
		SUB AL, '0'
		ADD CX, AX
		CMP CX, DI
		JA INLOOP2
		MOV BX, CX; (BX) = (BX)*10+(AL)
		MOV AH, 2
		INT 21H
		JMP INLOOP2

CHANGE:
		CMP SI, 1
		JE INLOOP2
		MOV SI, 1
		MOV DI, 1000
		MOV DL, AL
		MOV AH, 2
		INT 21H
		JMP INLOOP2
MUL10:
		PUSH AX
		MOV AX, BX
		MOV CL, 10
		MUL CL
		MOV BX, AX; (BX) = (BX)*10
		MOV SI, 1
		POP AX
INLOOPEND2:
		CMP SI, 0
		JZ  MUL10
		MOV SI, NUMBER
		SHL SI, 1
		MOV YEAR_ARR[SI], BX
		
		POP DI
		POP SI
		POP DX
		POP CX
		POP BX
		POP AX
		RET

LOGYEAR ENDP

;SORT THE ARRAYS USING BUBBLE SORT
SORT PROC NEAR
		PUSH AX
		PUSH DX
		MOV AH, 9
		MOV DX, OFFSET NOTICE6
		INT 21H
		CALL CRLF
		CALL SORTSLOT
		CALL SORTROOMS

SHOW:
		CALL SHOWSORTED

		POP DX
		POP AX
		RET 
SORT ENDP

;GROUPING BASED ON TIMESLOTS
SORTSLOT PROC NEAR
		PUSH AX
		PUSH BX
		PUSH CX
		PUSH DX
		PUSH SI
		PUSH DI
		MOV CX, NUMBER
		PUSH CX; protect CX
		LEA BX, SORTED
		XOR SI, SI
		XOR DX, DX
LOOP0:
		MOV [BX+SI], DX
		INC DX
		ADD SI, 2
		LOOP LOOP0

		POP CX
		DEC CX
		
LOOP1:
		MOV  DI, CX
		XOR SI, SI
		;LEA BX, TIME_ARR
		;LEA SI, SORTED
		;CALL TAG
LOOP2:
		;CALL TAG
		;MOV DX, SI
		MOV BX, SORTED[SI]
		SHL BX, 1
		MOV AX, TIME_ARR[BX]
		;CALL DECOUT
		;CALL CRLF
		;MOV SI, DX
		MOV BX, SORTED[SI+2]
		SHL BX, 1
		CMP AX, TIME_ARR[BX]
		;MOV SI, DX
		JGE CONTI
		MOV DX, SORTED[SI]
		XCHG DX, SORTED[SI+2]
		MOV SORTED[SI], DX
CONTI:
		ADD SI, 2
		LOOP LOOP2
		MOV CX, DI
		LOOP LOOP1

;		MOV CX, NUMBER
;		MOV BX, OFFSET SORTED
;SORTEDLP:
;		CALL TAG
;		MOV AX, [BX]
;		CALL DECOUT
;		ADD BX, 2
;		LOOP SORTEDLP
;		CALL TAG

		POP DI
		POP SI
		POP DX
		POP CX
		POP BX
		POP AX
		RET

SORTSLOT ENDP

;SORTING BASED ON ROOM NUMBERS WITHIN A GIVEN TIME SLOT
SORTROOMS	PROC NEAR
		PUSH AX
		PUSH BX
		PUSH CX
		PUSH DX
		PUSH SI
		PUSH DI
		MOV CX, NUMBER
		PUSH CX; protect CX
		LEA BX, SORTED
		XOR SI, SI
		XOR DX, DX
LP0:
		MOV [BX+SI], DX
		INC DX
		ADD SI,2
		LOOP LP0

		POP CX
		DEC CX
		
LP1:
		MOV  DI, CX
		LEA BX, ROOM_ARR
		LEA SI, SORTED
LP2:
		MOV AX, [BX]
		CMP AX, [BX+2]
		JLE CONTINUE
		MOV DX, [SI]
		XCHG DX, [SI+2]
		MOV [SI], DX
CONTINUE:
		ADD BX, 2
		ADD SI, 2
		LOOP LP2
		MOV CX, DI
		LOOP LP1

		POP DI
		POP SI
		POP DX
		POP CX
		POP BX
		POP AX
		RET
SORTROOMS 	ENDP

;DISPLAY THE SORTED ARRAY WITH ALL THE NECESSARY DETAILS
SHOWSORTED PROC NEAR
		PUSH AX
		PUSH BX
		PUSH CX
		PUSH DX
		PUSH SI

		LEA BX, SORTED
		MOV CX, NUMBER
		XOR SI, SI
SHOWLOOP:
		PUSH CX
;		CALL TAG
		MOV SI, [BX]
		PUSH SI 
		MOV AX, SI
		MOV CL, TYPE_NAME
		MUL CL
		MOV SI, AX
		LEA DX, NAME_ARR[SI]
		CALL NAMEOUT
		CALL SPACE
		POP SI
		SHL SI,1
		MOV AX, TIME_ARR[SI]
		CALL DECOUT
		CALL SPACE
		MOV AX, ROOM_ARR[SI]
		CALL DECOUT
		CALL SPACE
		MOV AX, YEAR_ARR[SI]
		CALL YEAROUT
		CALL SPACE

		CALL CRLF
		INC BX
		INC BX
		POP CX
		LOOP SHOWLOOP

		POP SI
		POP DX
		POP CX
		POP BX
		POP AX
		RET
SHOWSORTED ENDP

;PRINTING SORTED NAME
NAMEOUT PROC NEAR;first address is in DX
		PUSH AX

		MOV AH, 9
		INT 21H

		POP AX
		RET
NAMEOUT ENDP
DECOUT PROC NEAR
		PUSH AX
		PUSH BX
		PUSH CX
		PUSH DX
		MOV BX, BUFREAR
		CMP AX, 0
		JZ ZERO
OUTLOOP:
		XOR AH, AH
		OR  AL, AL; number is in AX
		JZ	OUTLOOPFIN
		MOV CL, 10
		DIV CL;(AL)=(AX)/10,???AH
		ADD AH, '0'
		DEC BX
		MOV [BX], AH
		JMP OUTLOOP
ZERO:	
		MOV DL, '0'
		MOV AH, 2
		INT 21H
		POP DX
		POP CX
		POP BX
		POP AX
		RET

OUTLOOPFIN:
		MOV DX, BX
		MOV AH, 9
		INT 21H

		POP DX
		POP CX
		POP BX
		POP AX
		RET
DECOUT ENDP

;PRINTING SORTED ACADEMIC YEARS
YEAROUT PROC NEAR
		PUSH AX
		PUSH BX
		PUSH CX
		PUSH DX
		MOV BX, BUFREAR

		OR  AX, AX; number is in AX
		JZ	OUTLOOPFIN1
		MOV CL, 10
		DIV CL;(AL)=(AX)/10,???AH
		CMP AH, 0
		JZ OUTLOOP1;??

		ADD AH, '0';????
		DEC BX
		MOV [BX], AH
		MOV DL, '.'
		DEC BX
		MOV [BX], DL
		
OUTLOOP1:
		XOR AH, AH
		OR  AL, AL; number is in AX
		JZ	OUTLOOPFIN1
		MOV CL, 10
		DIV CL;(AL)=(AX)/10,???AH
		ADD AH, '0'
		DEC BX
		MOV [BX], AH
		JMP OUTLOOP1

OUTLOOPFIN1:
		
		MOV DX, BX
		MOV AH, 9
		INT 21H	

		POP DX
		POP CX
		POP BX
		POP AX
		RET
YEAROUT ENDP

;VIEWING TIME SLOT FUNCTION
STATISTIC PROC NEAR
		PUSH AX
		PUSH BX
		PUSH CX
		PUSH DX
		PUSH SI
		LEA BX, TIME_ARR
		XOR SI, SI
		MOV CX, NUMBER
		XOR AX, AX
STATISLOOP:
		;INCREMENTING THE NUMBER OF PEOPLE IN EACH TIME SLOT
		MOV AX, [BX+SI]
		CMP AX, 19
		JB  ADDCOUNT0
		CMP AX, 20
		JB  ADDCOUNT1
		CMP AX, 21
		JB  ADDCOUNT2
		CMP AX, 22
		JB  ADDCOUNT3
		INC COUNT4
		JMP NEXT
ADDCOUNT0:
		INC COUNT0
		JMP NEXT 
ADDCOUNT1:
		INC COUNT1
		JMP NEXT
ADDCOUNT2:
		INC COUNT2
		JMP NEXT
ADDCOUNT3:
		INC COUNT3
NEXT:
		INC SI
		INC SI
		;LOOP STATISLOOP
		MOV DX, OFFSET NOTICE7
		MOV AH, 9
		INT 21H
		MOV AX, WORD PTR COUNT0
		CALL DECOUT 
		CALL CRLF
		MOV DX, OFFSET NOTICE8
		MOV AH, 9
		INT 21H
		MOV AX, WORD PTR COUNT1
		CALL DECOUT 
		CALL CRLF
		MOV DX, OFFSET NOTICE9
		MOV AH, 9
		INT 21H
		MOV AX, WORD PTR COUNT2
		CALL DECOUT 
		CALL CRLF
        MOV DX, OFFSET NOTICE10
		MOV AH, 9
		INT 21H
		MOV AX, WORD PTR COUNT3
		CALL DECOUT 
		CALL CRLF
	;ASK WHETHER THE USER WANTS TO SHIFT STUDENTS WHO MISSED THEIR SLOTS
    ASKLAST:
		MOV DX, OFFSET NOTICE11
		MOV AH, 9
		INT 21H
        MOV AH, 1
		INT 21H
		CALL CRLF
		CMP AL, 'Y'
		JE LASTSLOT
		CMP AL, 'y'
		JE LASTSLOT
		CMP AL, 'N'
		JE DONTSHOWLAST
		CMP AL, 'n'
		JE DONTSHOWLAST
        MOV AH, 9;Wrong input
		MOV DX, OFFSET ERR
		INT 21H
		JMP ASKLAST

    LASTSLOT:
        CALL SHOWLAST
    DONTSHOWLAST:
		POP SI
		POP DX
		POP CX
		POP BX
		POP AX
		RET
STATISTIC ENDP

;TRANSFERRING TO LAST SLOT
SHOWLAST PROC NEAR
        PUSH AX
		PUSH BX
		PUSH CX
		PUSH DX
		PUSH SI

		;ASSIGNING A RANDOM VALURE TO RANDOM AND PRINTING IT FOR REFERNECE
        MOV AX,DATA
    	MOV DS,AX   
    	;GENERATING RANDOM NUMBER BW 0-9
    	MOV AH, 00h  ; interrupts to get system time        
    	INT 1AH      ; CX:DX now hold number of clock ticks since midnight      
    	mov ax, dx
    	xor dx, dx
    	mov cx, 30    
    	div cx       ; here dx contains the remainder of the division - from 0 to 9       
    	MOV CX,DX         

        MOV RANDOM, CX
        XOR CX, CX

        MOV AX, DATA
        MOV DS, AX 

        MOV AX, RANDOM
        MOV BX, COUNT0
        CMP BX, AX
        JB CMP2 
        SUB BX, AX 
        MOV DIFFERENCE, BX
        ADD CX, DIFFERENCE

    CMP2:
        MOV AX, RANDOM
        MOV BX, COUNT1
        CMP BX, AX
        JB CMP3
        SUB BX, AX 
        MOV DIFFERENCE, BX
        ADD CX, DIFFERENCE

    CMP3:
        MOV AX, RANDOM
        MOV BX, COUNT2
        CMP BX, AX
        JB PR
        SUB BX, AX 
        MOV DIFFERENCE, BX
        ADD CX, DIFFERENCE

    PR:
        MOV COUNT3, CX
        MOV AX, WORD PTR RANDOM
		CALL DECOUT 
		CALL CRLF

        MOV DX, OFFSET NOTICE10
		MOV AH, 9
		INT 21H
		MOV AX, WORD PTR COUNT3
		CALL DECOUT 
		CALL CRLF

        POP SI
		POP DX
		POP CX
		POP BX
		POP AX
		RET
SHOWLAST ENDP

;FUNCTION TO PRINT FORM THE STARTING OF THE NEXT LINE
CRLF PROC NEAR
	PUSH AX
	PUSH DX
	MOV DL, 0DH
	MOV AH, 2
	INT 21H
	MOV DL, 0AH
	MOV AH, 2
	INT 21H
	POP DX
	POP AX
	RET
CRLF ENDP

SPACE PROC NEAR
	PUSH AX
	PUSH DX
	MOV DL, ' '
	MOV AH, 2
	INT 21H
	POP DX
	POP AX
	RET
SPACE ENDP

CODE ENDS
	 END START
