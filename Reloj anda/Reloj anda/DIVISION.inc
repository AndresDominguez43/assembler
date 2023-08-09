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



DESARMAR_ENVIAR_SEG:
      LDS  R24,SEGUNDOS
	  LDI  R23,0
	  LDI  R22,10
	  CALL DIVISION16
	  MOV  R20,R24
	  CALL ENVIO_UART			;envia la decena
	  MOVW R20,R26
	  CALL ENVIO_UART			;envia la unidad
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
RET

ENVIO_UART:
	  LDI  R16,48
	  ADD  R20,R16
ESPERAR_TX:
	  LDS  R16,UCSR0A
	  SBRS R16,UDRE0
	  RJMP ESPERAR_TX
	  STS  UDR0,R20
	  RET