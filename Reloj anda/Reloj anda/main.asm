El ivo es puto
.DSEG
		     PULSOS:        .DB 0
		     SEGUNDOS:      .DB 0
		     MINUTOS:       .DB 0
		     HORAS:         .DB 0
     	contador_de_pulsos: .DB 0
	  .CSEG	
	
      .ORG  0x0000
	   JMP  INICIO
//	  .ORG  0x0002
	//   JMP  ISR_INT0

//  .INCLUDE "DIVISION.INC"
INICIO:
       LDI  R16,HIGH(RAMEND)
	   OUT  SPH,R16
	   LDI  R16,LOW(RAMEND)
	   OUT  SPL,R16 

	   ;CONFIGURACION DE LA INTERRUPCION EXTERNA (cruce por cero) 
	
	   LDI R16,(1<<ISC01)
	   STS  EICRA,R16						
	   LDI  R16,(1<<INT0)
	   OUT  EIMSK,R16						;activo la INT0 
	   SEI									;habilitacion general de interrupciones

	   //Config de la UART 
        LDI     R16,0               ;VELOCIDAD , PARIDAD, BIT STOP, CANTIDAD DE DATOS
        STS     UCSR0A,R16           ;9600,8,N,1
        LDI     R16,(1<<TXEN0)
        STS     UCSR0B, R16
        LDI     R16,(1<<UCSZ01)|(1<<UCSZ00)
        STS     UCSR0C,R16
        LDI     R16,103
        STS     UBRR0L,R16
        LDI     R16,0
        STS     UBRR0H,R16
        RET

VOLVER:   //BUCLE PRINCIPAL (like a loop in IDE arduino)
	LDS R16, contador_de_pulsos
	CPI R16, 100
	BRNE VOLVER
 
 //   CALL ENVIO_RELOJ_UART ; Enviar segundos

    

	LDS R30, SEGUNDOS
    INC R30
	STS SEGUNDOS, R30

	RJMP VOLVER
	
/*SEGUNDOS_SR:
    LDI R31, 0 ;reiniciamos la cuenta del contador de cruces por 0
	STS contador_de_pulsos, R31


	LDS R30, SEGUNDOS
    INC R30
	STS SEGUNDOS, R30

	CPI R30, 60
	BREQ MINUTOS_SR
	RET

MINUTOS_SR:
    LDI R30, 0 ;reiniciamos la cuenta del contador de segundos
	STS	SEGUNDOS, R30

	LDS R29, MINUTOS
    INC R29
	STS	MINUTOS, R29

	CPI R29, 60
	BREQ HORAS_SR
	RET

HORAS_SR: 
    LDI R29, 0 ;reiniciamos la cuenta del contador de cruces por 0
	STS MINUTOS, R29

	LDS R28, HORAS
    INC R28
	STS HORAS, R28

	LDI R27, 24

	CPSE R29, R27
	CLR R28
	STS HORAS, R28

	RET
*/


	//Interrupcion del cruce por cero

/*ISR_INT0:
      
      LDS  R16, contador_de_pulsos
	  INC  R16
	  STS  contador_de_pulsos,R16
	  
	  RETI

*/
//SUBRUTINAS DE DIVISION

DIVISION16:   //OK
        SUB     R26,R26     
        SUB     R27,R27     
        LDI     R21,0x11     
        RJMP    SEGUIR16     
VOLVER16:       
        ROL     R26         
        ROL     R27         
        CP      R26,R22     
        CPC     R27,R23     
        BRCS    SEGUIR16    
        SUB     R26,R22     
        SBC     R27,R23     
SEGUIR16:
        ROL     R24         
        ROL     R25         
        DEC     R21         
        BRNE    VOLVER16     
        COM     R24         
        COM     R25         
        RET 

DIVISION8:  //OK
        SUB     R25,R25     
        LDI     R23,0x09    
        RJMP    SEGUIR8     
VOLVER8:ROL     R25         
        CP      R25,R22      
        BRCS    SEGUIR8     
        SUB     R25,R22     
SEGUIR8:ROL     R24         
        DEC     R23         
        BRNE    VOLVER8     
        COM     R24
        RET


//SUBRUTINAS PARA ENVIAR A LA UART


/*
DESARMAR_ENVIAR_SEG:
      LDS  R24,SEGUNDOS
	  LDI  R23,0
	  LDI  R22,10
	  CALL DIVISION16
	  MOV  R20,R24
	  CALL ENVIO_UART			;envia la decena
	  MOVW R20,R26
	  CALL ENVIO_UART			;envia la unidad
	  CALL DESARMAR_ENVIAR_MIN
	  CALL DESARMAR_ENVIAR_HS
	  RJMP FIN1
FIN1:
	  LDI  R20,13
	  CALL ESPERAR_TX
	  RET

DESARMAR_ENVIAR_MIN:
      LDS  R24,MINUTOS
	  LDI  R23,0
	  LDI  R22,10
	  CALL DIVISION16
	  MOV  R20,R24
	  CALL ENVIO_UART;envia la decena
	  MOVW R20,R26
	  CALL ENVIO_UART;envia la unidad
	  LDI  R20,':'
	  CALL ESPERAR_TX 
	  RET
	  
DESARMAR_ENVIAR_HS:
      LDS  R24,HORAS
	  LDI  R23,0
	  LDI  R22,10
	  CALL DIVISION16
	  MOV  R20,R24
	  CALL ENVIO_UART;envia la decena
	  MOVW R20,R26
	  CALL ENVIO_UART;envia la unidad
	  LDI  R20,':'
	  CALL ESPERAR_TX 
	  RET
*/
/*ENVIO_RELOJ_UART:
    ; Enviar horas
    LDS  R24,HORAS
    LDI  R23,0
    LDI  R22,10
    CALL DIVISION16
    MOV  R20,R24
    CALL ENVIO_UART ; envía la decena
    MOVW R20,R26
    CALL ENVIO_UART ; envía la unidad
    LDI  R20,':'    ; envía el separador :
    CALL ESPERAR_TX 

    ; Enviar minutos
    LDS  R24,MINUTOS
    LDI  R23,0
    LDI  R22,10
    CALL DIVISION16
    MOV  R20,R24
    CALL ENVIO_UART ; envía la decena
    MOVW R20,R26
    CALL ENVIO_UART ; envía la unidad
    LDI  R20,':'    ; envía el separador :
    CALL ESPERAR_TX 

    ; Enviar segundos
    LDS  R24,SEGUNDOS
    LDI  R23,0
    LDI  R22,10
    CALL DIVISION16
    MOV  R20,R24
    CALL ENVIO_UART ; envía la decena
    MOVW R20,R26
    CALL ENVIO_UART ; envía la unidad

    LDI  R20,13     ; envía retorno de carro
    CALL ESPERAR_TX 

    RET*/


ENVIO_UART:
	  LDI  R16,48
	  ADD  R20,R16
ESPERAR_TX:
	  LDS  R16,UCSR0A
	  SBRS R16,UDRE0
	  RJMP ESPERAR_TX
	  STS  UDR0,R20
	  RET
