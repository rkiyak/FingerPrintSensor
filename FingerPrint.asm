
_SERIAL_WRITE:

;dy50.h,106 :: 		uint8_t SERIAL_WRITE (uint8_t variable)
;dy50.h,108 :: 		UART1_Write(variable);
	MOVF        FARG_SERIAL_WRITE_variable+0, 0 
	MOVWF       FARG_UART1_Write_data_+0 
	CALL        _UART1_Write+0, 0
;dy50.h,111 :: 		}
L_end_SERIAL_WRITE:
	RETURN      0
; end of _SERIAL_WRITE

_SERIAL_WRITE_U16:

;dy50.h,113 :: 		uint16_t SERIAL_WRITE_U16(uint16_t variable)
;dy50.h,114 :: 		{UART1_Write(variable>>8);
	MOVF        FARG_SERIAL_WRITE_U16_variable+1, 0 
	MOVWF       R0 
	CLRF        R1 
	MOVF        R0, 0 
	MOVWF       FARG_UART1_Write_data_+0 
	CALL        _UART1_Write+0, 0
;dy50.h,116 :: 		UART1_Write(variable&0XFF);
	MOVLW       255
	ANDWF       FARG_SERIAL_WRITE_U16_variable+0, 0 
	MOVWF       FARG_UART1_Write_data_+0 
	CALL        _UART1_Write+0, 0
;dy50.h,119 :: 		}
L_end_SERIAL_WRITE_U16:
	RETURN      0
; end of _SERIAL_WRITE_U16

_GET_CMD_PACKET:

;dy50.h,120 :: 		uint8_t GET_CMD_PACKET(uint8_t datacmd)
;dy50.h,123 :: 		packet.type=FINGERPRINT_COMMANDPACKET;
	MOVLW       1
	MOVWF       _packet+6 
;dy50.h,124 :: 		packet.length=sizeof(datacmd);
	MOVLW       1
	MOVWF       _packet+7 
	MOVLW       0
	MOVWF       _packet+8 
;dy50.h,125 :: 		packet.dataraw[64]=datacmd;
	MOVF        FARG_GET_CMD_PACKET_datacmd+0, 0 
	MOVWF       _packet+73 
;dy50.h,126 :: 		writeStructuredPacket( &packet );
	MOVLW       _packet+0
	MOVWF       FARG_writeStructuredPacket+0 
	MOVLW       hi_addr(_packet+0)
	MOVWF       FARG_writeStructuredPacket+1 
	CALL        _writeStructuredPacket+0, 0
;dy50.h,127 :: 		if (getStructuredPacket(&packet,1000) != FINGERPRINT_OK)
	MOVLW       _packet+0
	MOVWF       FARG_getStructuredPacket+0 
	MOVLW       hi_addr(_packet+0)
	MOVWF       FARG_getStructuredPacket+1 
	MOVLW       232
	MOVWF       FARG_getStructuredPacket+0 
	MOVLW       3
	MOVWF       FARG_getStructuredPacket+1 
	CALL        _getStructuredPacket+0, 0
	MOVF        R0, 0 
	XORLW       0
	BTFSC       STATUS+0, 2 
	GOTO        L_GET_CMD_PACKET0
;dy50.h,128 :: 		return FINGERPRINT_PACKETRECIEVEERR;
	MOVLW       1
	MOVWF       R0 
	GOTO        L_end_GET_CMD_PACKET
L_GET_CMD_PACKET0:
;dy50.h,129 :: 		if (packet.type != FINGERPRINT_ACKPACKET) return FINGERPRINT_PACKETRECIEVEERR;
	MOVF        _packet+6, 0 
	XORLW       7
	BTFSC       STATUS+0, 2 
	GOTO        L_GET_CMD_PACKET1
	MOVLW       1
	MOVWF       R0 
	GOTO        L_end_GET_CMD_PACKET
L_GET_CMD_PACKET1:
;dy50.h,131 :: 		}
L_end_GET_CMD_PACKET:
	RETURN      0
; end of _GET_CMD_PACKET

_SEND_CMD_PACKET:

;dy50.h,133 :: 		uint8_t SEND_CMD_PACKET(uint8_t datacmd)
;dy50.h,136 :: 		GET_CMD_PACKET(datacmd);
	MOVF        FARG_SEND_CMD_PACKET_datacmd+0, 0 
	MOVWF       FARG_GET_CMD_PACKET_datacmd+0 
	CALL        _GET_CMD_PACKET+0, 0
;dy50.h,137 :: 		return packet.dataraw[0];
	MOVF        _packet+9, 0 
	MOVWF       R0 
;dy50.h,141 :: 		}
L_end_SEND_CMD_PACKET:
	RETURN      0
; end of _SEND_CMD_PACKET

_begin:

;dy50.h,147 :: 		void begin() {
;dy50.h,148 :: 		delay_ms(1000);  // one second delay to let the sensor 'boot up'
	MOVLW       11
	MOVWF       R11, 0
	MOVLW       38
	MOVWF       R12, 0
	MOVLW       93
	MOVWF       R13, 0
L_begin2:
	DECFSZ      R13, 1, 1
	BRA         L_begin2
	DECFSZ      R12, 1, 1
	BRA         L_begin2
	DECFSZ      R11, 1, 1
	BRA         L_begin2
	NOP
	NOP
;dy50.h,150 :: 		UART1_Init(57600);
	BSF         BAUDCON+0, 3, 0
	CLRF        SPBRGH+0 
	MOVLW       34
	MOVWF       SPBRG+0 
	BSF         TXSTA+0, 2, 0
	CALL        _UART1_Init+0, 0
;dy50.h,151 :: 		}
L_end_begin:
	RETURN      0
; end of _begin

_verifyPassword:

;dy50.h,158 :: 		bool verifyPassword(void) {
;dy50.h,159 :: 		return checkPassword() == FINGERPRINT_OK;
	CALL        _checkPassword+0, 0
	MOVF        R0, 0 
	XORLW       0
	MOVLW       1
	BTFSS       STATUS+0, 2 
	MOVLW       0
	MOVWF       R1 
	MOVF        R1, 0 
	MOVWF       R0 
;dy50.h,160 :: 		}
L_end_verifyPassword:
	RETURN      0
; end of _verifyPassword

_checkPassword:

;dy50.h,162 :: 		uint8_t checkPassword(void) {
;dy50.h,164 :: 		GET_CMD_PACKET(FINGERPRINT_VERIFYPASSWORD);
	MOVLW       19
	MOVWF       FARG_GET_CMD_PACKET_datacmd+0 
	CALL        _GET_CMD_PACKET+0, 0
;dy50.h,165 :: 		GET_CMD_PACKET((uint8_t)(thePassword >> 24));
	MOVF        _thePassword+3, 0 
	MOVWF       R0 
	CLRF        R1 
	CLRF        R2 
	CLRF        R3 
	MOVF        R0, 0 
	MOVWF       FARG_GET_CMD_PACKET_datacmd+0 
	CALL        _GET_CMD_PACKET+0, 0
;dy50.h,166 :: 		GET_CMD_PACKET((uint8_t)(thePassword >> 16));
	MOVF        _thePassword+2, 0 
	MOVWF       R0 
	MOVF        _thePassword+3, 0 
	MOVWF       R1 
	CLRF        R2 
	CLRF        R3 
	MOVF        R0, 0 
	MOVWF       FARG_GET_CMD_PACKET_datacmd+0 
	CALL        _GET_CMD_PACKET+0, 0
;dy50.h,167 :: 		GET_CMD_PACKET((uint8_t)(thePassword >> 8));
	MOVF        _thePassword+1, 0 
	MOVWF       R0 
	MOVF        _thePassword+2, 0 
	MOVWF       R1 
	MOVF        _thePassword+3, 0 
	MOVWF       R2 
	CLRF        R3 
	MOVF        R0, 0 
	MOVWF       FARG_GET_CMD_PACKET_datacmd+0 
	CALL        _GET_CMD_PACKET+0, 0
;dy50.h,168 :: 		GET_CMD_PACKET((uint8_t)(thePassword & 0xFF));
	MOVLW       255
	ANDWF       _thePassword+0, 0 
	MOVWF       FARG_GET_CMD_PACKET_datacmd+0 
	CALL        _GET_CMD_PACKET+0, 0
;dy50.h,170 :: 		if (packet.dataraw[0] == FINGERPRINT_OK)
	MOVF        _packet+9, 0 
	XORLW       0
	BTFSS       STATUS+0, 2 
	GOTO        L_checkPassword3
;dy50.h,171 :: 		return FINGERPRINT_OK;
	CLRF        R0 
	GOTO        L_end_checkPassword
L_checkPassword3:
;dy50.h,173 :: 		return FINGERPRINT_PACKETRECIEVEERR;
	MOVLW       1
	MOVWF       R0 
;dy50.h,174 :: 		}
L_end_checkPassword:
	RETURN      0
; end of _checkPassword

_getImage:

;dy50.h,185 :: 		uint8_t getImage(void) {
;dy50.h,186 :: 		SEND_CMD_PACKET(FINGERPRINT_GETIMAGE);
	MOVLW       1
	MOVWF       FARG_SEND_CMD_PACKET_datacmd+0 
	CALL        _SEND_CMD_PACKET+0, 0
;dy50.h,187 :: 		}
L_end_getImage:
	RETURN      0
; end of _getImage

_image2Tz:

;dy50.h,199 :: 		uint8_t image2Tz(uint8_t slot) {
;dy50.h,200 :: 		slot =1;
	MOVLW       1
	MOVWF       FARG_image2Tz_slot+0 
;dy50.h,201 :: 		SEND_CMD_PACKET(FINGERPRINT_IMAGE2TZ);
	MOVLW       2
	MOVWF       FARG_SEND_CMD_PACKET_datacmd+0 
	CALL        _SEND_CMD_PACKET+0, 0
;dy50.h,202 :: 		SEND_CMD_PACKET(slot);
	MOVF        FARG_image2Tz_slot+0, 0 
	MOVWF       FARG_SEND_CMD_PACKET_datacmd+0 
	CALL        _SEND_CMD_PACKET+0, 0
;dy50.h,203 :: 		}
L_end_image2Tz:
	RETURN      0
; end of _image2Tz

_createModel:

;dy50.h,212 :: 		uint8_t createModel(void) {
;dy50.h,214 :: 		SEND_CMD_PACKET(FINGERPRINT_REGMODEL);
	MOVLW       5
	MOVWF       FARG_SEND_CMD_PACKET_datacmd+0 
	CALL        _SEND_CMD_PACKET+0, 0
;dy50.h,215 :: 		}
L_end_createModel:
	RETURN      0
; end of _createModel

_storeModel:

;dy50.h,227 :: 		uint8_t storeModel(uint16_t location) {
;dy50.h,230 :: 		SEND_CMD_PACKET(FINGERPRINT_STORE);
	MOVLW       6
	MOVWF       FARG_SEND_CMD_PACKET_datacmd+0 
	CALL        _SEND_CMD_PACKET+0, 0
;dy50.h,231 :: 		SEND_CMD_PACKET(0x01);
	MOVLW       1
	MOVWF       FARG_SEND_CMD_PACKET_datacmd+0 
	CALL        _SEND_CMD_PACKET+0, 0
;dy50.h,232 :: 		SEND_CMD_PACKET((uint8_t)(location >> 8));
	MOVF        FARG_storeModel_location+1, 0 
	MOVWF       R0 
	CLRF        R1 
	MOVF        R0, 0 
	MOVWF       FARG_SEND_CMD_PACKET_datacmd+0 
	CALL        _SEND_CMD_PACKET+0, 0
;dy50.h,233 :: 		SEND_CMD_PACKET( (uint8_t)(location & 0xFF));
	MOVLW       255
	ANDWF       FARG_storeModel_location+0, 0 
	MOVWF       FARG_SEND_CMD_PACKET_datacmd+0 
	CALL        _SEND_CMD_PACKET+0, 0
;dy50.h,235 :: 		}
L_end_storeModel:
	RETURN      0
; end of _storeModel

_loadModel:

;dy50.h,245 :: 		uint8_t loadModel(uint16_t location) {
;dy50.h,247 :: 		SEND_CMD_PACKET(FINGERPRINT_LOAD);
	MOVLW       7
	MOVWF       FARG_SEND_CMD_PACKET_datacmd+0 
	CALL        _SEND_CMD_PACKET+0, 0
;dy50.h,248 :: 		SEND_CMD_PACKET(0x01);
	MOVLW       1
	MOVWF       FARG_SEND_CMD_PACKET_datacmd+0 
	CALL        _SEND_CMD_PACKET+0, 0
;dy50.h,249 :: 		SEND_CMD_PACKET((uint8_t)(location >> 8));
	MOVF        FARG_loadModel_location+1, 0 
	MOVWF       R0 
	CLRF        R1 
	MOVF        R0, 0 
	MOVWF       FARG_SEND_CMD_PACKET_datacmd+0 
	CALL        _SEND_CMD_PACKET+0, 0
;dy50.h,250 :: 		SEND_CMD_PACKET((uint8_t)(location & 0xFF));
	MOVLW       255
	ANDWF       FARG_loadModel_location+0, 0 
	MOVWF       FARG_SEND_CMD_PACKET_datacmd+0 
	CALL        _SEND_CMD_PACKET+0, 0
;dy50.h,251 :: 		}
L_end_loadModel:
	RETURN      0
; end of _loadModel

_getModel:

;dy50.h,259 :: 		uint8_t getModel(void) {
;dy50.h,260 :: 		SEND_CMD_PACKET(FINGERPRINT_UPLOAD);
	MOVLW       8
	MOVWF       FARG_SEND_CMD_PACKET_datacmd+0 
	CALL        _SEND_CMD_PACKET+0, 0
;dy50.h,261 :: 		SEND_CMD_PACKET( 0x01);
	MOVLW       1
	MOVWF       FARG_SEND_CMD_PACKET_datacmd+0 
	CALL        _SEND_CMD_PACKET+0, 0
;dy50.h,262 :: 		}
L_end_getModel:
	RETURN      0
; end of _getModel

_deleteModel:

;dy50.h,273 :: 		uint8_t deleteModel(uint16_t location) {
;dy50.h,274 :: 		SEND_CMD_PACKET(FINGERPRINT_DELETE);
	MOVLW       12
	MOVWF       FARG_SEND_CMD_PACKET_datacmd+0 
	CALL        _SEND_CMD_PACKET+0, 0
;dy50.h,275 :: 		SEND_CMD_PACKET((uint8_t)(location >> 8));
	MOVF        FARG_deleteModel_location+1, 0 
	MOVWF       R0 
	CLRF        R1 
	MOVF        R0, 0 
	MOVWF       FARG_SEND_CMD_PACKET_datacmd+0 
	CALL        _SEND_CMD_PACKET+0, 0
;dy50.h,276 :: 		SEND_CMD_PACKET((uint8_t)(location & 0xFF));
	MOVLW       255
	ANDWF       FARG_deleteModel_location+0, 0 
	MOVWF       FARG_SEND_CMD_PACKET_datacmd+0 
	CALL        _SEND_CMD_PACKET+0, 0
;dy50.h,277 :: 		SEND_CMD_PACKET( 0x00);
	CLRF        FARG_SEND_CMD_PACKET_datacmd+0 
	CALL        _SEND_CMD_PACKET+0, 0
;dy50.h,278 :: 		SEND_CMD_PACKET( 0x01);
	MOVLW       1
	MOVWF       FARG_SEND_CMD_PACKET_datacmd+0 
	CALL        _SEND_CMD_PACKET+0, 0
;dy50.h,279 :: 		}
L_end_deleteModel:
	RETURN      0
; end of _deleteModel

_emptyDatabase:

;dy50.h,289 :: 		uint8_t emptyDatabase(void) {
;dy50.h,290 :: 		SEND_CMD_PACKET(FINGERPRINT_EMPTY);
	MOVLW       13
	MOVWF       FARG_SEND_CMD_PACKET_datacmd+0 
	CALL        _SEND_CMD_PACKET+0, 0
;dy50.h,291 :: 		}
L_end_emptyDatabase:
	RETURN      0
; end of _emptyDatabase

_fingerFastSearch:

;dy50.h,301 :: 		uint8_t fingerFastSearch(void) {
;dy50.h,303 :: 		GET_CMD_PACKET(FINGERPRINT_HISPEEDSEARCH);
	MOVLW       27
	MOVWF       FARG_GET_CMD_PACKET_datacmd+0 
	CALL        _GET_CMD_PACKET+0, 0
;dy50.h,304 :: 		SEND_CMD_PACKET(0x01);
	MOVLW       1
	MOVWF       FARG_SEND_CMD_PACKET_datacmd+0 
	CALL        _SEND_CMD_PACKET+0, 0
;dy50.h,305 :: 		SEND_CMD_PACKET(0x00);
	CLRF        FARG_SEND_CMD_PACKET_datacmd+0 
	CALL        _SEND_CMD_PACKET+0, 0
;dy50.h,306 :: 		SEND_CMD_PACKET(0x00);
	CLRF        FARG_SEND_CMD_PACKET_datacmd+0 
	CALL        _SEND_CMD_PACKET+0, 0
;dy50.h,307 :: 		SEND_CMD_PACKET(0x00);
	CLRF        FARG_SEND_CMD_PACKET_datacmd+0 
	CALL        _SEND_CMD_PACKET+0, 0
;dy50.h,308 :: 		SEND_CMD_PACKET(0xA3);
	MOVLW       163
	MOVWF       FARG_SEND_CMD_PACKET_datacmd+0 
	CALL        _SEND_CMD_PACKET+0, 0
;dy50.h,309 :: 		fingerID = 0xFFFF;
	MOVLW       255
	MOVWF       _fingerID+0 
	MOVLW       255
	MOVWF       _fingerID+1 
;dy50.h,310 :: 		confidence = 0xFFFF;
	MOVLW       255
	MOVWF       _confidence+0 
	MOVLW       255
	MOVWF       _confidence+1 
;dy50.h,312 :: 		fingerID = packet.dataraw[1];
	MOVF        _packet+10, 0 
	MOVWF       _fingerID+0 
	MOVLW       0
	MOVWF       _fingerID+1 
;dy50.h,313 :: 		fingerID <<= 8;
	MOVF        _fingerID+0, 0 
	MOVWF       _fingerID+1 
	CLRF        _fingerID+0 
;dy50.h,314 :: 		fingerID |= packet.dataraw[2];
	MOVF        _packet+11, 0 
	IORWF       _fingerID+0, 1 
	MOVLW       0
	IORWF       _fingerID+1, 1 
;dy50.h,316 :: 		confidence = packet.dataraw[3];
	MOVF        _packet+12, 0 
	MOVWF       _confidence+0 
	MOVLW       0
	MOVWF       _confidence+1 
;dy50.h,317 :: 		confidence <<= 8;
	MOVF        _confidence+0, 0 
	MOVWF       _confidence+1 
	CLRF        _confidence+0 
;dy50.h,318 :: 		confidence |= packet.dataraw[4];
	MOVF        _packet+13, 0 
	IORWF       _confidence+0, 1 
	MOVLW       0
	IORWF       _confidence+1, 1 
;dy50.h,320 :: 		return packet.dataraw[0];
	MOVF        _packet+9, 0 
	MOVWF       R0 
;dy50.h,321 :: 		}
L_end_fingerFastSearch:
	RETURN      0
; end of _fingerFastSearch

_getTemplateCount:

;dy50.h,330 :: 		uint8_t getTemplateCount(void) {
;dy50.h,331 :: 		GET_CMD_PACKET(FINGERPRINT_TEMPLATECOUNT);
	MOVLW       29
	MOVWF       FARG_GET_CMD_PACKET_datacmd+0 
	CALL        _GET_CMD_PACKET+0, 0
;dy50.h,333 :: 		templateCount = packet.dataraw[1];
	MOVF        _packet+10, 0 
	MOVWF       _templateCount+0 
	MOVLW       0
	MOVWF       _templateCount+1 
;dy50.h,334 :: 		templateCount <<= 8;
	MOVF        _templateCount+0, 0 
	MOVWF       _templateCount+1 
	CLRF        _templateCount+0 
;dy50.h,335 :: 		templateCount |= packet.dataraw[2];
	MOVF        _packet+11, 0 
	IORWF       _templateCount+0, 1 
	MOVLW       0
	IORWF       _templateCount+1, 1 
;dy50.h,337 :: 		return packet.dataraw[0];
	MOVF        _packet+9, 0 
	MOVWF       R0 
;dy50.h,338 :: 		}
L_end_getTemplateCount:
	RETURN      0
; end of _getTemplateCount

_setPassword:

;dy50.h,348 :: 		uint8_t setPassword(uint32_t password) {
;dy50.h,349 :: 		SEND_CMD_PACKET(FINGERPRINT_SETPASSWORD);
	MOVLW       18
	MOVWF       FARG_SEND_CMD_PACKET_datacmd+0 
	CALL        _SEND_CMD_PACKET+0, 0
;dy50.h,350 :: 		SEND_CMD_PACKET((password >> 24));
	MOVF        FARG_setPassword_password+3, 0 
	MOVWF       R0 
	CLRF        R1 
	CLRF        R2 
	CLRF        R3 
	MOVF        R0, 0 
	MOVWF       FARG_SEND_CMD_PACKET_datacmd+0 
	CALL        _SEND_CMD_PACKET+0, 0
;dy50.h,351 :: 		SEND_CMD_PACKET((password >> 16));
	MOVF        FARG_setPassword_password+2, 0 
	MOVWF       R0 
	MOVF        FARG_setPassword_password+3, 0 
	MOVWF       R1 
	CLRF        R2 
	CLRF        R3 
	MOVF        R0, 0 
	MOVWF       FARG_SEND_CMD_PACKET_datacmd+0 
	CALL        _SEND_CMD_PACKET+0, 0
;dy50.h,352 :: 		SEND_CMD_PACKET((password >> 8));
	MOVF        FARG_setPassword_password+1, 0 
	MOVWF       R0 
	MOVF        FARG_setPassword_password+2, 0 
	MOVWF       R1 
	MOVF        FARG_setPassword_password+3, 0 
	MOVWF       R2 
	CLRF        R3 
	MOVF        R0, 0 
	MOVWF       FARG_SEND_CMD_PACKET_datacmd+0 
	CALL        _SEND_CMD_PACKET+0, 0
;dy50.h,354 :: 		SEND_CMD_PACKET( password);
	MOVF        FARG_setPassword_password+0, 0 
	MOVWF       FARG_SEND_CMD_PACKET_datacmd+0 
	CALL        _SEND_CMD_PACKET+0, 0
;dy50.h,355 :: 		}
L_end_setPassword:
	RETURN      0
; end of _setPassword

_writeStructuredPacket:

;dy50.h,364 :: 		void writeStructuredPacket(Adafruit_Fingerprint_Packet * packet) {
;dy50.h,368 :: 		SERIAL_WRITE_U16(packet->start_code);
	MOVFF       FARG_writeStructuredPacket_packet+0, FSR0
	MOVFF       FARG_writeStructuredPacket_packet+1, FSR0H
	MOVF        POSTINC0+0, 0 
	MOVWF       FARG_SERIAL_WRITE_U16_variable+0 
	MOVF        POSTINC0+0, 0 
	MOVWF       FARG_SERIAL_WRITE_U16_variable+1 
	CALL        _SERIAL_WRITE_U16+0, 0
;dy50.h,369 :: 		SERIAL_WRITE(packet->address[0]);
	MOVLW       2
	ADDWF       FARG_writeStructuredPacket_packet+0, 0 
	MOVWF       FSR0 
	MOVLW       0
	ADDWFC      FARG_writeStructuredPacket_packet+1, 0 
	MOVWF       FSR0H 
	MOVF        POSTINC0+0, 0 
	MOVWF       FARG_SERIAL_WRITE_variable+0 
	CALL        _SERIAL_WRITE+0, 0
;dy50.h,370 :: 		SERIAL_WRITE(packet->address[1]);
	MOVLW       2
	ADDWF       FARG_writeStructuredPacket_packet+0, 0 
	MOVWF       R0 
	MOVLW       0
	ADDWFC      FARG_writeStructuredPacket_packet+1, 0 
	MOVWF       R1 
	MOVLW       1
	ADDWF       R0, 0 
	MOVWF       FSR0 
	MOVLW       0
	ADDWFC      R1, 0 
	MOVWF       FSR0H 
	MOVF        POSTINC0+0, 0 
	MOVWF       FARG_SERIAL_WRITE_variable+0 
	CALL        _SERIAL_WRITE+0, 0
;dy50.h,371 :: 		SERIAL_WRITE(packet->address[2]);
	MOVLW       2
	ADDWF       FARG_writeStructuredPacket_packet+0, 0 
	MOVWF       R0 
	MOVLW       0
	ADDWFC      FARG_writeStructuredPacket_packet+1, 0 
	MOVWF       R1 
	MOVLW       2
	ADDWF       R0, 0 
	MOVWF       FSR0 
	MOVLW       0
	ADDWFC      R1, 0 
	MOVWF       FSR0H 
	MOVF        POSTINC0+0, 0 
	MOVWF       FARG_SERIAL_WRITE_variable+0 
	CALL        _SERIAL_WRITE+0, 0
;dy50.h,372 :: 		SERIAL_WRITE(packet->address[3]);
	MOVLW       2
	ADDWF       FARG_writeStructuredPacket_packet+0, 0 
	MOVWF       R0 
	MOVLW       0
	ADDWFC      FARG_writeStructuredPacket_packet+1, 0 
	MOVWF       R1 
	MOVLW       3
	ADDWF       R0, 0 
	MOVWF       FSR0 
	MOVLW       0
	ADDWFC      R1, 0 
	MOVWF       FSR0H 
	MOVF        POSTINC0+0, 0 
	MOVWF       FARG_SERIAL_WRITE_variable+0 
	CALL        _SERIAL_WRITE+0, 0
;dy50.h,373 :: 		SERIAL_WRITE(packet->type);
	MOVLW       6
	ADDWF       FARG_writeStructuredPacket_packet+0, 0 
	MOVWF       FSR0 
	MOVLW       0
	ADDWFC      FARG_writeStructuredPacket_packet+1, 0 
	MOVWF       FSR0H 
	MOVF        POSTINC0+0, 0 
	MOVWF       FARG_SERIAL_WRITE_variable+0 
	CALL        _SERIAL_WRITE+0, 0
;dy50.h,375 :: 		wire_length = packet->length + 2;
	MOVLW       7
	ADDWF       FARG_writeStructuredPacket_packet+0, 0 
	MOVWF       FSR0 
	MOVLW       0
	ADDWFC      FARG_writeStructuredPacket_packet+1, 0 
	MOVWF       FSR0H 
	MOVLW       2
	ADDWF       POSTINC0+0, 0 
	MOVWF       R0 
	MOVLW       0
	ADDWFC      POSTINC0+0, 0 
	MOVWF       R1 
	MOVF        R0, 0 
	MOVWF       writeStructuredPacket_wire_length_L0+0 
	MOVF        R1, 0 
	MOVWF       writeStructuredPacket_wire_length_L0+1 
;dy50.h,377 :: 		SERIAL_WRITE_U16(wire_length);
	MOVF        R0, 0 
	MOVWF       FARG_SERIAL_WRITE_U16_variable+0 
	MOVF        R1, 0 
	MOVWF       FARG_SERIAL_WRITE_U16_variable+1 
	CALL        _SERIAL_WRITE_U16+0, 0
;dy50.h,379 :: 		sum = ((wire_length)>>8) + ((wire_length)&0xFF) + packet->type;
	MOVF        writeStructuredPacket_wire_length_L0+1, 0 
	MOVWF       writeStructuredPacket_sum_L0+0 
	CLRF        writeStructuredPacket_sum_L0+1 
	MOVLW       255
	ANDWF       writeStructuredPacket_wire_length_L0+0, 0 
	MOVWF       R0 
	MOVF        writeStructuredPacket_wire_length_L0+1, 0 
	MOVWF       R1 
	MOVLW       0
	ANDWF       R1, 1 
	MOVF        R0, 0 
	ADDWF       writeStructuredPacket_sum_L0+0, 1 
	MOVF        R1, 0 
	ADDWFC      writeStructuredPacket_sum_L0+1, 1 
	MOVLW       6
	ADDWF       FARG_writeStructuredPacket_packet+0, 0 
	MOVWF       FSR2 
	MOVLW       0
	ADDWFC      FARG_writeStructuredPacket_packet+1, 0 
	MOVWF       FSR2H 
	MOVF        POSTINC2+0, 0 
	ADDWF       writeStructuredPacket_sum_L0+0, 1 
	MOVLW       0
	ADDWFC      writeStructuredPacket_sum_L0+1, 1 
;dy50.h,380 :: 		for ( i=0; i< packet->length; i++) {
	CLRF        writeStructuredPacket_i_L0+0 
L_writeStructuredPacket5:
	MOVLW       7
	ADDWF       FARG_writeStructuredPacket_packet+0, 0 
	MOVWF       FSR2 
	MOVLW       0
	ADDWFC      FARG_writeStructuredPacket_packet+1, 0 
	MOVWF       FSR2H 
	MOVF        POSTINC2+0, 0 
	MOVWF       R1 
	MOVF        POSTINC2+0, 0 
	MOVWF       R2 
	MOVLW       0
	MOVWF       R0 
	MOVF        R2, 0 
	SUBWF       R0, 0 
	BTFSS       STATUS+0, 2 
	GOTO        L__writeStructuredPacket76
	MOVF        R1, 0 
	SUBWF       writeStructuredPacket_i_L0+0, 0 
L__writeStructuredPacket76:
	BTFSC       STATUS+0, 0 
	GOTO        L_writeStructuredPacket6
;dy50.h,381 :: 		SERIAL_WRITE(packet->dataraw[i]);
	MOVLW       9
	ADDWF       FARG_writeStructuredPacket_packet+0, 0 
	MOVWF       R0 
	MOVLW       0
	ADDWFC      FARG_writeStructuredPacket_packet+1, 0 
	MOVWF       R1 
	MOVF        writeStructuredPacket_i_L0+0, 0 
	ADDWF       R0, 0 
	MOVWF       FSR0 
	MOVLW       0
	ADDWFC      R1, 0 
	MOVWF       FSR0H 
	MOVF        POSTINC0+0, 0 
	MOVWF       FARG_SERIAL_WRITE_variable+0 
	CALL        _SERIAL_WRITE+0, 0
;dy50.h,382 :: 		sum += packet->dataraw[i];
	MOVLW       9
	ADDWF       FARG_writeStructuredPacket_packet+0, 0 
	MOVWF       R0 
	MOVLW       0
	ADDWFC      FARG_writeStructuredPacket_packet+1, 0 
	MOVWF       R1 
	MOVF        writeStructuredPacket_i_L0+0, 0 
	ADDWF       R0, 0 
	MOVWF       FSR2 
	MOVLW       0
	ADDWFC      R1, 0 
	MOVWF       FSR2H 
	MOVF        POSTINC2+0, 0 
	ADDWF       writeStructuredPacket_sum_L0+0, 1 
	MOVLW       0
	ADDWFC      writeStructuredPacket_sum_L0+1, 1 
;dy50.h,380 :: 		for ( i=0; i< packet->length; i++) {
	INCF        writeStructuredPacket_i_L0+0, 1 
;dy50.h,383 :: 		}
	GOTO        L_writeStructuredPacket5
L_writeStructuredPacket6:
;dy50.h,385 :: 		SERIAL_WRITE_U16(sum);
	MOVF        writeStructuredPacket_sum_L0+0, 0 
	MOVWF       FARG_SERIAL_WRITE_U16_variable+0 
	MOVF        writeStructuredPacket_sum_L0+1, 0 
	MOVWF       FARG_SERIAL_WRITE_U16_variable+1 
	CALL        _SERIAL_WRITE_U16+0, 0
;dy50.h,386 :: 		return;
;dy50.h,388 :: 		}
L_end_writeStructuredPacket:
	RETURN      0
; end of _writeStructuredPacket

_getStructuredPacket:

;dy50.h,399 :: 		uint8_t getStructuredPacket(Adafruit_Fingerprint_Packet * packet, uint16_t timeout) {
;dy50.h,401 :: 		uint16_t idx=0, timer=0;
	CLRF        getStructuredPacket_idx_L0+0 
	CLRF        getStructuredPacket_idx_L0+1 
;dy50.h,403 :: 		while(true) {
L_getStructuredPacket8:
;dy50.h,405 :: 		switch (idx) {
	GOTO        L_getStructuredPacket10
;dy50.h,406 :: 		case 0:
L_getStructuredPacket12:
;dy50.h,407 :: 		if (byte != (FINGERPRINT_STARTCODE >> 8))
	MOVLW       0
	XORLW       0
	BTFSS       STATUS+0, 2 
	GOTO        L__getStructuredPacket78
	MOVLW       239
	XORWF       R5, 0 
L__getStructuredPacket78:
	BTFSC       STATUS+0, 2 
	GOTO        L_getStructuredPacket13
;dy50.h,408 :: 		continue;
	GOTO        L_getStructuredPacket8
L_getStructuredPacket13:
;dy50.h,409 :: 		packet->start_code = (uint16_t)byte << 8;
	MOVF        R5, 0 
	MOVWF       R3 
	MOVLW       0
	MOVWF       R4 
	MOVF        R3, 0 
	MOVWF       R1 
	CLRF        R0 
	MOVFF       FARG_getStructuredPacket_packet+0, FSR1
	MOVFF       FARG_getStructuredPacket_packet+1, FSR1H
	MOVF        R0, 0 
	MOVWF       POSTINC1+0 
	MOVF        R1, 0 
	MOVWF       POSTINC1+0 
;dy50.h,410 :: 		break;
	GOTO        L_getStructuredPacket11
;dy50.h,411 :: 		case 1:
L_getStructuredPacket14:
;dy50.h,412 :: 		packet->start_code |= byte;
	MOVFF       FARG_getStructuredPacket_packet+0, FSR0
	MOVFF       FARG_getStructuredPacket_packet+1, FSR0H
	MOVF        POSTINC0+0, 0 
	MOVWF       R0 
	MOVF        POSTINC0+0, 0 
	MOVWF       R1 
	MOVF        R5, 0 
	IORWF       R0, 1 
	MOVLW       0
	IORWF       R1, 1 
	MOVFF       FARG_getStructuredPacket_packet+0, FSR1
	MOVFF       FARG_getStructuredPacket_packet+1, FSR1H
	MOVF        R0, 0 
	MOVWF       POSTINC1+0 
	MOVF        R1, 0 
	MOVWF       POSTINC1+0 
;dy50.h,413 :: 		if (packet->start_code != FINGERPRINT_STARTCODE)
	MOVFF       FARG_getStructuredPacket_packet+0, FSR0
	MOVFF       FARG_getStructuredPacket_packet+1, FSR0H
	MOVF        POSTINC0+0, 0 
	MOVWF       R1 
	MOVF        POSTINC0+0, 0 
	MOVWF       R2 
	MOVF        R2, 0 
	XORLW       239
	BTFSS       STATUS+0, 2 
	GOTO        L__getStructuredPacket79
	MOVLW       1
	XORWF       R1, 0 
L__getStructuredPacket79:
	BTFSC       STATUS+0, 2 
	GOTO        L_getStructuredPacket15
;dy50.h,414 :: 		return FINGERPRINT_BADPACKET;
	MOVLW       254
	MOVWF       R0 
	GOTO        L_end_getStructuredPacket
L_getStructuredPacket15:
;dy50.h,415 :: 		break;
	GOTO        L_getStructuredPacket11
;dy50.h,416 :: 		case 2:
L_getStructuredPacket16:
;dy50.h,417 :: 		case 3:
L_getStructuredPacket17:
;dy50.h,418 :: 		case 4:
L_getStructuredPacket18:
;dy50.h,419 :: 		case 5:
L_getStructuredPacket19:
;dy50.h,420 :: 		packet->address[idx-2] = byte;
	MOVLW       2
	ADDWF       FARG_getStructuredPacket_packet+0, 0 
	MOVWF       R2 
	MOVLW       0
	ADDWFC      FARG_getStructuredPacket_packet+1, 0 
	MOVWF       R3 
	MOVLW       2
	SUBWF       getStructuredPacket_idx_L0+0, 0 
	MOVWF       R0 
	MOVLW       0
	SUBWFB      getStructuredPacket_idx_L0+1, 0 
	MOVWF       R1 
	MOVF        R0, 0 
	ADDWF       R2, 0 
	MOVWF       FSR1 
	MOVF        R1, 0 
	ADDWFC      R3, 0 
	MOVWF       FSR1H 
	MOVF        R5, 0 
	MOVWF       POSTINC1+0 
;dy50.h,421 :: 		break;
	GOTO        L_getStructuredPacket11
;dy50.h,422 :: 		case 6:
L_getStructuredPacket20:
;dy50.h,423 :: 		packet->type = byte;
	MOVLW       6
	ADDWF       FARG_getStructuredPacket_packet+0, 0 
	MOVWF       FSR1 
	MOVLW       0
	ADDWFC      FARG_getStructuredPacket_packet+1, 0 
	MOVWF       FSR1H 
	MOVF        R5, 0 
	MOVWF       POSTINC1+0 
;dy50.h,424 :: 		break;
	GOTO        L_getStructuredPacket11
;dy50.h,425 :: 		case 7:
L_getStructuredPacket21:
;dy50.h,426 :: 		packet->length = (uint16_t)byte << 8;
	MOVLW       7
	ADDWF       FARG_getStructuredPacket_packet+0, 0 
	MOVWF       FSR1 
	MOVLW       0
	ADDWFC      FARG_getStructuredPacket_packet+1, 0 
	MOVWF       FSR1H 
	MOVF        R5, 0 
	MOVWF       R3 
	MOVLW       0
	MOVWF       R4 
	MOVF        R3, 0 
	MOVWF       R1 
	CLRF        R0 
	MOVF        R0, 0 
	MOVWF       POSTINC1+0 
	MOVF        R1, 0 
	MOVWF       POSTINC1+0 
;dy50.h,427 :: 		break;
	GOTO        L_getStructuredPacket11
;dy50.h,428 :: 		case 8:
L_getStructuredPacket22:
;dy50.h,429 :: 		packet->length |= byte;
	MOVLW       7
	ADDWF       FARG_getStructuredPacket_packet+0, 0 
	MOVWF       R2 
	MOVLW       0
	ADDWFC      FARG_getStructuredPacket_packet+1, 0 
	MOVWF       R3 
	MOVFF       R2, FSR0
	MOVFF       R3, FSR0H
	MOVF        R5, 0 
	IORWF       POSTINC0+0, 0 
	MOVWF       R0 
	MOVF        POSTINC0+0, 0 
	MOVWF       R1 
	MOVLW       0
	IORWF       R1, 1 
	MOVFF       R2, FSR1
	MOVFF       R3, FSR1H
	MOVF        R0, 0 
	MOVWF       POSTINC1+0 
	MOVF        R1, 0 
	MOVWF       POSTINC1+0 
;dy50.h,430 :: 		break;
	GOTO        L_getStructuredPacket11
;dy50.h,431 :: 		default:
L_getStructuredPacket23:
;dy50.h,432 :: 		packet->dataraw[idx-9] = byte;
	MOVLW       9
	ADDWF       FARG_getStructuredPacket_packet+0, 0 
	MOVWF       R2 
	MOVLW       0
	ADDWFC      FARG_getStructuredPacket_packet+1, 0 
	MOVWF       R3 
	MOVLW       9
	SUBWF       getStructuredPacket_idx_L0+0, 0 
	MOVWF       R0 
	MOVLW       0
	SUBWFB      getStructuredPacket_idx_L0+1, 0 
	MOVWF       R1 
	MOVF        R0, 0 
	ADDWF       R2, 0 
	MOVWF       FSR1 
	MOVF        R1, 0 
	ADDWFC      R3, 0 
	MOVWF       FSR1H 
	MOVF        R5, 0 
	MOVWF       POSTINC1+0 
;dy50.h,433 :: 		if((idx-8) == packet->length)
	MOVLW       8
	SUBWF       getStructuredPacket_idx_L0+0, 0 
	MOVWF       R3 
	MOVLW       0
	SUBWFB      getStructuredPacket_idx_L0+1, 0 
	MOVWF       R4 
	MOVLW       7
	ADDWF       FARG_getStructuredPacket_packet+0, 0 
	MOVWF       FSR2 
	MOVLW       0
	ADDWFC      FARG_getStructuredPacket_packet+1, 0 
	MOVWF       FSR2H 
	MOVF        POSTINC2+0, 0 
	MOVWF       R1 
	MOVF        POSTINC2+0, 0 
	MOVWF       R2 
	MOVF        R4, 0 
	XORWF       R2, 0 
	BTFSS       STATUS+0, 2 
	GOTO        L__getStructuredPacket80
	MOVF        R1, 0 
	XORWF       R3, 0 
L__getStructuredPacket80:
	BTFSS       STATUS+0, 2 
	GOTO        L_getStructuredPacket24
;dy50.h,434 :: 		return FINGERPRINT_OK;
	CLRF        R0 
	GOTO        L_end_getStructuredPacket
L_getStructuredPacket24:
;dy50.h,435 :: 		break;
	GOTO        L_getStructuredPacket11
;dy50.h,436 :: 		}
L_getStructuredPacket10:
	MOVLW       0
	XORWF       getStructuredPacket_idx_L0+1, 0 
	BTFSS       STATUS+0, 2 
	GOTO        L__getStructuredPacket81
	MOVLW       0
	XORWF       getStructuredPacket_idx_L0+0, 0 
L__getStructuredPacket81:
	BTFSC       STATUS+0, 2 
	GOTO        L_getStructuredPacket12
	MOVLW       0
	XORWF       getStructuredPacket_idx_L0+1, 0 
	BTFSS       STATUS+0, 2 
	GOTO        L__getStructuredPacket82
	MOVLW       1
	XORWF       getStructuredPacket_idx_L0+0, 0 
L__getStructuredPacket82:
	BTFSC       STATUS+0, 2 
	GOTO        L_getStructuredPacket14
	MOVLW       0
	XORWF       getStructuredPacket_idx_L0+1, 0 
	BTFSS       STATUS+0, 2 
	GOTO        L__getStructuredPacket83
	MOVLW       2
	XORWF       getStructuredPacket_idx_L0+0, 0 
L__getStructuredPacket83:
	BTFSC       STATUS+0, 2 
	GOTO        L_getStructuredPacket16
	MOVLW       0
	XORWF       getStructuredPacket_idx_L0+1, 0 
	BTFSS       STATUS+0, 2 
	GOTO        L__getStructuredPacket84
	MOVLW       3
	XORWF       getStructuredPacket_idx_L0+0, 0 
L__getStructuredPacket84:
	BTFSC       STATUS+0, 2 
	GOTO        L_getStructuredPacket17
	MOVLW       0
	XORWF       getStructuredPacket_idx_L0+1, 0 
	BTFSS       STATUS+0, 2 
	GOTO        L__getStructuredPacket85
	MOVLW       4
	XORWF       getStructuredPacket_idx_L0+0, 0 
L__getStructuredPacket85:
	BTFSC       STATUS+0, 2 
	GOTO        L_getStructuredPacket18
	MOVLW       0
	XORWF       getStructuredPacket_idx_L0+1, 0 
	BTFSS       STATUS+0, 2 
	GOTO        L__getStructuredPacket86
	MOVLW       5
	XORWF       getStructuredPacket_idx_L0+0, 0 
L__getStructuredPacket86:
	BTFSC       STATUS+0, 2 
	GOTO        L_getStructuredPacket19
	MOVLW       0
	XORWF       getStructuredPacket_idx_L0+1, 0 
	BTFSS       STATUS+0, 2 
	GOTO        L__getStructuredPacket87
	MOVLW       6
	XORWF       getStructuredPacket_idx_L0+0, 0 
L__getStructuredPacket87:
	BTFSC       STATUS+0, 2 
	GOTO        L_getStructuredPacket20
	MOVLW       0
	XORWF       getStructuredPacket_idx_L0+1, 0 
	BTFSS       STATUS+0, 2 
	GOTO        L__getStructuredPacket88
	MOVLW       7
	XORWF       getStructuredPacket_idx_L0+0, 0 
L__getStructuredPacket88:
	BTFSC       STATUS+0, 2 
	GOTO        L_getStructuredPacket21
	MOVLW       0
	XORWF       getStructuredPacket_idx_L0+1, 0 
	BTFSS       STATUS+0, 2 
	GOTO        L__getStructuredPacket89
	MOVLW       8
	XORWF       getStructuredPacket_idx_L0+0, 0 
L__getStructuredPacket89:
	BTFSC       STATUS+0, 2 
	GOTO        L_getStructuredPacket22
	GOTO        L_getStructuredPacket23
L_getStructuredPacket11:
;dy50.h,437 :: 		idx++;
	INFSNZ      getStructuredPacket_idx_L0+0, 1 
	INCF        getStructuredPacket_idx_L0+1, 1 
;dy50.h,438 :: 		}
	GOTO        L_getStructuredPacket8
;dy50.h,441 :: 		}
L_end_getStructuredPacket:
	RETURN      0
; end of _getStructuredPacket

_setup:

;FingerPrint.c,3 :: 		void setup()
;FingerPrint.c,6 :: 		begin();//57600 baud rate de uart baslat
	CALL        _begin+0, 0
;FingerPrint.c,8 :: 		if (verifyPassword()) {
	CALL        _verifyPassword+0, 0
	MOVF        R0, 1 
	BTFSC       STATUS+0, 2 
	GOTO        L_setup25
;FingerPrint.c,10 :: 		UART1_Write_Text("Found fingerprint sensor!");
	MOVLW       ?lstr1_FingerPrint+0
	MOVWF       FARG_UART1_Write_Text_uart_text+0 
	MOVLW       hi_addr(?lstr1_FingerPrint+0)
	MOVWF       FARG_UART1_Write_Text_uart_text+1 
	CALL        _UART1_Write_Text+0, 0
;FingerPrint.c,11 :: 		} else {
	GOTO        L_setup26
L_setup25:
;FingerPrint.c,13 :: 		UART1_Write_Text("Did not find fingerprint sensor :(");
	MOVLW       ?lstr2_FingerPrint+0
	MOVWF       FARG_UART1_Write_Text_uart_text+0 
	MOVLW       hi_addr(?lstr2_FingerPrint+0)
	MOVWF       FARG_UART1_Write_Text_uart_text+1 
	CALL        _UART1_Write_Text+0, 0
;FingerPrint.c,14 :: 		while (1) { delay_ms(500); }
L_setup27:
	MOVLW       6
	MOVWF       R11, 0
	MOVLW       19
	MOVWF       R12, 0
	MOVLW       173
	MOVWF       R13, 0
L_setup29:
	DECFSZ      R13, 1, 1
	BRA         L_setup29
	DECFSZ      R12, 1, 1
	BRA         L_setup29
	DECFSZ      R11, 1, 1
	BRA         L_setup29
	NOP
	NOP
	GOTO        L_setup27
;FingerPrint.c,15 :: 		}
L_setup26:
;FingerPrint.c,17 :: 		getTemplateCount();
	CALL        _getTemplateCount+0, 0
;FingerPrint.c,19 :: 		UART1_Write("Sensor contains ");
	MOVLW       ?lstr_3_FingerPrint+0
	MOVWF       FARG_UART1_Write_data_+0 
	CALL        _UART1_Write+0, 0
;FingerPrint.c,20 :: 		UART1_Write(templateCount);
	MOVF        _templateCount+0, 0 
	MOVWF       FARG_UART1_Write_data_+0 
	CALL        _UART1_Write+0, 0
;FingerPrint.c,21 :: 		UART1_Write(" templates\n");
	MOVLW       ?lstr_4_FingerPrint+0
	MOVWF       FARG_UART1_Write_data_+0 
	CALL        _UART1_Write+0, 0
;FingerPrint.c,22 :: 		}
L_end_setup:
	RETURN      0
; end of _setup

_getFingerprintIDez:

;FingerPrint.c,23 :: 		int getFingerprintIDez() {
;FingerPrint.c,24 :: 		uint8_t p = getImage();
	CALL        _getImage+0, 0
;FingerPrint.c,25 :: 		if (p != FINGERPRINT_OK)  return -1;
	MOVF        R0, 0 
	XORLW       0
	BTFSC       STATUS+0, 2 
	GOTO        L_getFingerprintIDez30
	MOVLW       255
	MOVWF       R0 
	MOVLW       255
	MOVWF       R1 
	GOTO        L_end_getFingerprintIDez
L_getFingerprintIDez30:
;FingerPrint.c,27 :: 		p = image2Tz(1);
	MOVLW       1
	MOVWF       FARG_image2Tz_slot+0 
	CALL        _image2Tz+0, 0
;FingerPrint.c,28 :: 		if (p != FINGERPRINT_OK)  return -1;
	MOVF        R0, 0 
	XORLW       0
	BTFSC       STATUS+0, 2 
	GOTO        L_getFingerprintIDez31
	MOVLW       255
	MOVWF       R0 
	MOVLW       255
	MOVWF       R1 
	GOTO        L_end_getFingerprintIDez
L_getFingerprintIDez31:
;FingerPrint.c,30 :: 		p = fingerFastSearch();
	CALL        _fingerFastSearch+0, 0
;FingerPrint.c,31 :: 		if (p != FINGERPRINT_OK)  return -1;
	MOVF        R0, 0 
	XORLW       0
	BTFSC       STATUS+0, 2 
	GOTO        L_getFingerprintIDez32
	MOVLW       255
	MOVWF       R0 
	MOVLW       255
	MOVWF       R1 
	GOTO        L_end_getFingerprintIDez
L_getFingerprintIDez32:
;FingerPrint.c,34 :: 		UART1_Write("Found ID #"); UART1_Write(fingerID);
	MOVLW       ?lstr_5_FingerPrint+0
	MOVWF       FARG_UART1_Write_data_+0 
	CALL        _UART1_Write+0, 0
	MOVF        _fingerID+0, 0 
	MOVWF       FARG_UART1_Write_data_+0 
	CALL        _UART1_Write+0, 0
;FingerPrint.c,35 :: 		UART1_Write(" with confidence of "); UART1_Write(confidence);
	MOVLW       ?lstr_6_FingerPrint+0
	MOVWF       FARG_UART1_Write_data_+0 
	CALL        _UART1_Write+0, 0
	MOVF        _confidence+0, 0 
	MOVWF       FARG_UART1_Write_data_+0 
	CALL        _UART1_Write+0, 0
;FingerPrint.c,36 :: 		return fingerID;
	MOVF        _fingerID+0, 0 
	MOVWF       R0 
	MOVF        _fingerID+1, 0 
	MOVWF       R1 
;FingerPrint.c,37 :: 		}
L_end_getFingerprintIDez:
	RETURN      0
; end of _getFingerprintIDez

_getFingerprintID:

;FingerPrint.c,40 :: 		uint8_t getFingerprintID() {
;FingerPrint.c,41 :: 		uint8_t p = getImage();
	CALL        _getImage+0, 0
	MOVF        R0, 0 
	MOVWF       getFingerprintID_p_L0+0 
;FingerPrint.c,42 :: 		switch (p) {
	GOTO        L_getFingerprintID33
;FingerPrint.c,43 :: 		case FINGERPRINT_OK:
L_getFingerprintID35:
;FingerPrint.c,44 :: 		UART1_Write("Image taken");
	MOVLW       ?lstr_7_FingerPrint+0
	MOVWF       FARG_UART1_Write_data_+0 
	CALL        _UART1_Write+0, 0
;FingerPrint.c,45 :: 		break;
	GOTO        L_getFingerprintID34
;FingerPrint.c,46 :: 		case FINGERPRINT_NOFINGER:
L_getFingerprintID36:
;FingerPrint.c,47 :: 		UART1_Write("No finger detected");
	MOVLW       ?lstr_8_FingerPrint+0
	MOVWF       FARG_UART1_Write_data_+0 
	CALL        _UART1_Write+0, 0
;FingerPrint.c,48 :: 		return p;
	MOVF        getFingerprintID_p_L0+0, 0 
	MOVWF       R0 
	GOTO        L_end_getFingerprintID
;FingerPrint.c,49 :: 		case FINGERPRINT_PACKETRECIEVEERR:
L_getFingerprintID37:
;FingerPrint.c,50 :: 		UART1_Write("Communication error");
	MOVLW       ?lstr_9_FingerPrint+0
	MOVWF       FARG_UART1_Write_data_+0 
	CALL        _UART1_Write+0, 0
;FingerPrint.c,51 :: 		return p;
	MOVF        getFingerprintID_p_L0+0, 0 
	MOVWF       R0 
	GOTO        L_end_getFingerprintID
;FingerPrint.c,52 :: 		case FINGERPRINT_IMAGEFAIL:
L_getFingerprintID38:
;FingerPrint.c,53 :: 		UART1_Write("Imaging error");
	MOVLW       ?lstr_10_FingerPrint+0
	MOVWF       FARG_UART1_Write_data_+0 
	CALL        _UART1_Write+0, 0
;FingerPrint.c,54 :: 		return p;
	MOVF        getFingerprintID_p_L0+0, 0 
	MOVWF       R0 
	GOTO        L_end_getFingerprintID
;FingerPrint.c,55 :: 		default:
L_getFingerprintID39:
;FingerPrint.c,56 :: 		UART1_Write("Unknown error");
	MOVLW       ?lstr_11_FingerPrint+0
	MOVWF       FARG_UART1_Write_data_+0 
	CALL        _UART1_Write+0, 0
;FingerPrint.c,57 :: 		return p;
	MOVF        getFingerprintID_p_L0+0, 0 
	MOVWF       R0 
	GOTO        L_end_getFingerprintID
;FingerPrint.c,58 :: 		}
L_getFingerprintID33:
	MOVF        getFingerprintID_p_L0+0, 0 
	XORLW       0
	BTFSC       STATUS+0, 2 
	GOTO        L_getFingerprintID35
	MOVF        getFingerprintID_p_L0+0, 0 
	XORLW       2
	BTFSC       STATUS+0, 2 
	GOTO        L_getFingerprintID36
	MOVF        getFingerprintID_p_L0+0, 0 
	XORLW       1
	BTFSC       STATUS+0, 2 
	GOTO        L_getFingerprintID37
	MOVF        getFingerprintID_p_L0+0, 0 
	XORLW       3
	BTFSC       STATUS+0, 2 
	GOTO        L_getFingerprintID38
	GOTO        L_getFingerprintID39
L_getFingerprintID34:
;FingerPrint.c,62 :: 		p = image2Tz(1);
	MOVLW       1
	MOVWF       FARG_image2Tz_slot+0 
	CALL        _image2Tz+0, 0
	MOVF        R0, 0 
	MOVWF       getFingerprintID_p_L0+0 
;FingerPrint.c,63 :: 		switch (p) {
	GOTO        L_getFingerprintID40
;FingerPrint.c,64 :: 		case FINGERPRINT_OK:
L_getFingerprintID42:
;FingerPrint.c,65 :: 		UART1_Write("Image converted");
	MOVLW       ?lstr_12_FingerPrint+0
	MOVWF       FARG_UART1_Write_data_+0 
	CALL        _UART1_Write+0, 0
;FingerPrint.c,66 :: 		break;
	GOTO        L_getFingerprintID41
;FingerPrint.c,67 :: 		case FINGERPRINT_IMAGEMESS:
L_getFingerprintID43:
;FingerPrint.c,68 :: 		UART1_Write("Image too messy");
	MOVLW       ?lstr_13_FingerPrint+0
	MOVWF       FARG_UART1_Write_data_+0 
	CALL        _UART1_Write+0, 0
;FingerPrint.c,69 :: 		return p;
	MOVF        getFingerprintID_p_L0+0, 0 
	MOVWF       R0 
	GOTO        L_end_getFingerprintID
;FingerPrint.c,70 :: 		case FINGERPRINT_PACKETRECIEVEERR:
L_getFingerprintID44:
;FingerPrint.c,71 :: 		UART1_Write("Communication error");
	MOVLW       ?lstr_14_FingerPrint+0
	MOVWF       FARG_UART1_Write_data_+0 
	CALL        _UART1_Write+0, 0
;FingerPrint.c,72 :: 		return p;
	MOVF        getFingerprintID_p_L0+0, 0 
	MOVWF       R0 
	GOTO        L_end_getFingerprintID
;FingerPrint.c,73 :: 		case FINGERPRINT_FEATUREFAIL:
L_getFingerprintID45:
;FingerPrint.c,74 :: 		UART1_Write("Could not find fingerprint features");
	MOVLW       ?lstr_15_FingerPrint+0
	MOVWF       FARG_UART1_Write_data_+0 
	CALL        _UART1_Write+0, 0
;FingerPrint.c,75 :: 		return p;
	MOVF        getFingerprintID_p_L0+0, 0 
	MOVWF       R0 
	GOTO        L_end_getFingerprintID
;FingerPrint.c,76 :: 		case FINGERPRINT_INVALIDIMAGE:
L_getFingerprintID46:
;FingerPrint.c,77 :: 		UART1_Write("Could not find fingerprint features");
	MOVLW       ?lstr_16_FingerPrint+0
	MOVWF       FARG_UART1_Write_data_+0 
	CALL        _UART1_Write+0, 0
;FingerPrint.c,78 :: 		return p;
	MOVF        getFingerprintID_p_L0+0, 0 
	MOVWF       R0 
	GOTO        L_end_getFingerprintID
;FingerPrint.c,79 :: 		default:
L_getFingerprintID47:
;FingerPrint.c,80 :: 		UART1_Write("Unknown error");
	MOVLW       ?lstr_17_FingerPrint+0
	MOVWF       FARG_UART1_Write_data_+0 
	CALL        _UART1_Write+0, 0
;FingerPrint.c,81 :: 		return p;
	MOVF        getFingerprintID_p_L0+0, 0 
	MOVWF       R0 
	GOTO        L_end_getFingerprintID
;FingerPrint.c,82 :: 		}
L_getFingerprintID40:
	MOVF        getFingerprintID_p_L0+0, 0 
	XORLW       0
	BTFSC       STATUS+0, 2 
	GOTO        L_getFingerprintID42
	MOVF        getFingerprintID_p_L0+0, 0 
	XORLW       6
	BTFSC       STATUS+0, 2 
	GOTO        L_getFingerprintID43
	MOVF        getFingerprintID_p_L0+0, 0 
	XORLW       1
	BTFSC       STATUS+0, 2 
	GOTO        L_getFingerprintID44
	MOVF        getFingerprintID_p_L0+0, 0 
	XORLW       7
	BTFSC       STATUS+0, 2 
	GOTO        L_getFingerprintID45
	MOVF        getFingerprintID_p_L0+0, 0 
	XORLW       21
	BTFSC       STATUS+0, 2 
	GOTO        L_getFingerprintID46
	GOTO        L_getFingerprintID47
L_getFingerprintID41:
;FingerPrint.c,85 :: 		p =fingerFastSearch();
	CALL        _fingerFastSearch+0, 0
	MOVF        R0, 0 
	MOVWF       getFingerprintID_p_L0+0 
;FingerPrint.c,86 :: 		if (p == FINGERPRINT_OK) {
	MOVF        R0, 0 
	XORLW       0
	BTFSS       STATUS+0, 2 
	GOTO        L_getFingerprintID48
;FingerPrint.c,87 :: 		UART1_Write("Found a print match!");
	MOVLW       ?lstr_18_FingerPrint+0
	MOVWF       FARG_UART1_Write_data_+0 
	CALL        _UART1_Write+0, 0
;FingerPrint.c,88 :: 		} else if (p == FINGERPRINT_PACKETRECIEVEERR) {
	GOTO        L_getFingerprintID49
L_getFingerprintID48:
	MOVF        getFingerprintID_p_L0+0, 0 
	XORLW       1
	BTFSS       STATUS+0, 2 
	GOTO        L_getFingerprintID50
;FingerPrint.c,89 :: 		UART1_Write("Communication error");
	MOVLW       ?lstr_19_FingerPrint+0
	MOVWF       FARG_UART1_Write_data_+0 
	CALL        _UART1_Write+0, 0
;FingerPrint.c,90 :: 		return p;
	MOVF        getFingerprintID_p_L0+0, 0 
	MOVWF       R0 
	GOTO        L_end_getFingerprintID
;FingerPrint.c,91 :: 		} else if (p == FINGERPRINT_NOTFOUND) {
L_getFingerprintID50:
	MOVF        getFingerprintID_p_L0+0, 0 
	XORLW       9
	BTFSS       STATUS+0, 2 
	GOTO        L_getFingerprintID52
;FingerPrint.c,92 :: 		UART1_Write("Did not find a match");
	MOVLW       ?lstr_20_FingerPrint+0
	MOVWF       FARG_UART1_Write_data_+0 
	CALL        _UART1_Write+0, 0
;FingerPrint.c,93 :: 		return p;
	MOVF        getFingerprintID_p_L0+0, 0 
	MOVWF       R0 
	GOTO        L_end_getFingerprintID
;FingerPrint.c,94 :: 		} else {
L_getFingerprintID52:
;FingerPrint.c,95 :: 		UART1_Write("Unknown error");
	MOVLW       ?lstr_21_FingerPrint+0
	MOVWF       FARG_UART1_Write_data_+0 
	CALL        _UART1_Write+0, 0
;FingerPrint.c,96 :: 		return p;
	MOVF        getFingerprintID_p_L0+0, 0 
	MOVWF       R0 
	GOTO        L_end_getFingerprintID
;FingerPrint.c,97 :: 		}
L_getFingerprintID49:
;FingerPrint.c,100 :: 		UART1_Write("Found ID #"); UART1_Write(fingerID);
	MOVLW       ?lstr_22_FingerPrint+0
	MOVWF       FARG_UART1_Write_data_+0 
	CALL        _UART1_Write+0, 0
	MOVF        _fingerID+0, 0 
	MOVWF       FARG_UART1_Write_data_+0 
	CALL        _UART1_Write+0, 0
;FingerPrint.c,101 :: 		UART1_Write(" with confidence of ");UART1_Write(confidence);
	MOVLW       ?lstr_23_FingerPrint+0
	MOVWF       FARG_UART1_Write_data_+0 
	CALL        _UART1_Write+0, 0
	MOVF        _confidence+0, 0 
	MOVWF       FARG_UART1_Write_data_+0 
	CALL        _UART1_Write+0, 0
;FingerPrint.c,103 :: 		return fingerID;
	MOVF        _fingerID+0, 0 
	MOVWF       R0 
;FingerPrint.c,104 :: 		}
L_end_getFingerprintID:
	RETURN      0
; end of _getFingerprintID

_main:

;FingerPrint.c,105 :: 		void main()
;FingerPrint.c,107 :: 		while(1){
L_main54:
;FingerPrint.c,108 :: 		getFingerprintIDez();
	CALL        _getFingerprintIDez+0, 0
;FingerPrint.c,109 :: 		delay_ms(50);            //don't ned to run this at full speed.
	MOVLW       130
	MOVWF       R12, 0
	MOVLW       221
	MOVWF       R13, 0
L_main56:
	DECFSZ      R13, 1, 1
	BRA         L_main56
	DECFSZ      R12, 1, 1
	BRA         L_main56
	NOP
	NOP
;FingerPrint.c,110 :: 		}                      }
	GOTO        L_main54
L_end_main:
	GOTO        $+0
; end of _main
