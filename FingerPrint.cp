#line 1 "C:/Users/infcomp1/Desktop/FingerPrint/FingerPrint.c"
#line 1 "c:/users/infcomp1/desktop/fingerprint/dy50.h"
#line 1 "f:/portable programs/mikroelektronika/mikroc pro for pic/include/stdint.h"




typedef signed char int8_t;
typedef signed int int16_t;
typedef signed long int int32_t;


typedef unsigned char uint8_t;
typedef unsigned int uint16_t;
typedef unsigned long int uint32_t;


typedef signed char int_least8_t;
typedef signed int int_least16_t;
typedef signed long int int_least32_t;


typedef unsigned char uint_least8_t;
typedef unsigned int uint_least16_t;
typedef unsigned long int uint_least32_t;



typedef signed char int_fast8_t;
typedef signed int int_fast16_t;
typedef signed long int int_fast32_t;


typedef unsigned char uint_fast8_t;
typedef unsigned int uint_fast16_t;
typedef unsigned long int uint_fast32_t;


typedef signed int intptr_t;
typedef unsigned int uintptr_t;


typedef signed long int intmax_t;
typedef unsigned long int uintmax_t;
#line 1 "f:/portable programs/mikroelektronika/mikroc pro for pic/include/string.h"





void * memchr(void *p, char n, unsigned int v);
int memcmp(void *s1, void *s2, int n);
void * memcpy(void * d1, void * s1, int n);
void * memmove(void * to, void * from, int n);
void * memset(void * p1, char character, int n);
char * strcat(char * to, char * from);
char * strchr(char * ptr, char chr);
int strcmp(char * s1, char * s2);
char * strcpy(char * to, char * from);
int strlen(char * s);
char * strncat(char * to, char * from, int size);
char * strncpy(char * to, char * from, int size);
int strspn(char * str1, char * str2);
char strcspn(char * s1, char * s2);
int strncmp(char * s1, char * s2, char len);
char * strpbrk(char * s1, char * s2);
char * strrchr(char *ptr, char chr);
char * strstr(char * s1, char * s2);
char * strtok(char * s1, char * s2);
#line 1 "f:/portable programs/mikroelektronika/mikroc pro for pic/include/stdbool.h"



 typedef char _Bool;
#line 55 "c:/users/infcomp1/desktop/fingerprint/dy50.h"
typedef struct Adafruit_Fingerprint_Packet {
#line 67 "c:/users/infcomp1/desktop/fingerprint/dy50.h"
 uint16_t start_code;
 uint8_t address[4];
 uint8_t type;
 uint16_t length;
 uint8_t dataraw[];
}Adafruit_Fingerprint_Packet;

 Adafruit_Fingerprint_Packet packet;



 uint16_t fingerID;

 uint16_t confidence;

 uint16_t templateCount;
 uint8_t checkPassword(void);
 uint32_t thePassword;
 uint32_t theAddress;
 uint8_t recvPacket[20];

 void begin();
  _Bool  verifyPassword(void);
 uint8_t getImage(void);
 uint8_t image2Tz(uint8_t );
 uint8_t createModel(void);
 uint8_t emptyDatabase(void);
 uint8_t storeModel(uint16_t );
 uint8_t loadModel(uint16_t );
 uint8_t getModel(void);
 uint8_t deleteModel(uint16_t );
 uint8_t fingerFastSearch(void);
 uint8_t getTemplateCount(void);
 uint8_t setPassword(uint32_t );
 void writeStructuredPacket( Adafruit_Fingerprint_Packet*);
 uint8_t getStructuredPacket( Adafruit_Fingerprint_Packet*,uint16_t);
 uint8_t GET_CMD_PACKET(uint8_t,Adafruit_Fingerprint_Packet);


uint8_t SERIAL_WRITE (uint8_t variable)
{
 UART1_Write(variable);


}

uint16_t SERIAL_WRITE_U16(uint16_t variable)
{UART1_Write(variable>>8);

UART1_Write(variable&0XFF);


}
uint8_t GET_CMD_PACKET(uint8_t datacmd)
{

 packet.type= 0x1 ;
 packet.length=sizeof(datacmd);
 packet.dataraw[64]=datacmd;
 writeStructuredPacket( &packet );
 if (getStructuredPacket(&packet,1000) !=  0x00 )
 return  0x01 ;
 if (packet.type !=  0x7 ) return  0x01 ;

}

uint8_t SEND_CMD_PACKET(uint8_t datacmd)
{

 GET_CMD_PACKET(datacmd);
 return packet.dataraw[0];



}





 void begin() {
 delay_ms(1000);

 UART1_Init(57600);
}
#line 158 "c:/users/infcomp1/desktop/fingerprint/dy50.h"
 _Bool  verifyPassword(void) {
 return checkPassword() ==  0x00 ;
}

uint8_t checkPassword(void) {

 GET_CMD_PACKET( 0x13 );
 GET_CMD_PACKET((uint8_t)(thePassword >> 24));
 GET_CMD_PACKET((uint8_t)(thePassword >> 16));
 GET_CMD_PACKET((uint8_t)(thePassword >> 8));
 GET_CMD_PACKET((uint8_t)(thePassword & 0xFF));

 if (packet.dataraw[0] ==  0x00 )
 return  0x00 ;
 else
 return  0x01 ;
}
#line 185 "c:/users/infcomp1/desktop/fingerprint/dy50.h"
uint8_t getImage(void) {
 SEND_CMD_PACKET( 0x01 );
}
#line 199 "c:/users/infcomp1/desktop/fingerprint/dy50.h"
uint8_t image2Tz(uint8_t slot) {
 slot =1;
 SEND_CMD_PACKET( 0x02 );
 SEND_CMD_PACKET(slot);
}
#line 212 "c:/users/infcomp1/desktop/fingerprint/dy50.h"
uint8_t createModel(void) {

 SEND_CMD_PACKET( 0x05 );
}
#line 227 "c:/users/infcomp1/desktop/fingerprint/dy50.h"
uint8_t storeModel(uint16_t location) {


 SEND_CMD_PACKET( 0x06 );
 SEND_CMD_PACKET(0x01);
 SEND_CMD_PACKET((uint8_t)(location >> 8));
 SEND_CMD_PACKET( (uint8_t)(location & 0xFF));

}
#line 245 "c:/users/infcomp1/desktop/fingerprint/dy50.h"
uint8_t loadModel(uint16_t location) {

 SEND_CMD_PACKET( 0x07 );
 SEND_CMD_PACKET(0x01);
 SEND_CMD_PACKET((uint8_t)(location >> 8));
 SEND_CMD_PACKET((uint8_t)(location & 0xFF));
}
#line 259 "c:/users/infcomp1/desktop/fingerprint/dy50.h"
uint8_t getModel(void) {
 SEND_CMD_PACKET( 0x08 );
 SEND_CMD_PACKET( 0x01);
}
#line 273 "c:/users/infcomp1/desktop/fingerprint/dy50.h"
uint8_t deleteModel(uint16_t location) {
 SEND_CMD_PACKET( 0x0C );
 SEND_CMD_PACKET((uint8_t)(location >> 8));
 SEND_CMD_PACKET((uint8_t)(location & 0xFF));
 SEND_CMD_PACKET( 0x00);
 SEND_CMD_PACKET( 0x01);
}
#line 289 "c:/users/infcomp1/desktop/fingerprint/dy50.h"
uint8_t emptyDatabase(void) {
 SEND_CMD_PACKET( 0x0D );
}
#line 301 "c:/users/infcomp1/desktop/fingerprint/dy50.h"
uint8_t fingerFastSearch(void) {

 GET_CMD_PACKET( 0x1B );
 SEND_CMD_PACKET(0x01);
 SEND_CMD_PACKET(0x00);
 SEND_CMD_PACKET(0x00);
 SEND_CMD_PACKET(0x00);
 SEND_CMD_PACKET(0xA3);
 fingerID = 0xFFFF;
 confidence = 0xFFFF;

 fingerID = packet.dataraw[1];
 fingerID <<= 8;
 fingerID |= packet.dataraw[2];

 confidence = packet.dataraw[3];
 confidence <<= 8;
 confidence |= packet.dataraw[4];

 return packet.dataraw[0];
}
#line 330 "c:/users/infcomp1/desktop/fingerprint/dy50.h"
uint8_t getTemplateCount(void) {
 GET_CMD_PACKET( 0x1D );

 templateCount = packet.dataraw[1];
 templateCount <<= 8;
 templateCount |= packet.dataraw[2];

 return packet.dataraw[0];
}
#line 348 "c:/users/infcomp1/desktop/fingerprint/dy50.h"
uint8_t setPassword(uint32_t password) {
SEND_CMD_PACKET( 0x12 );
SEND_CMD_PACKET((password >> 24));
SEND_CMD_PACKET((password >> 16));
SEND_CMD_PACKET((password >> 8));

 SEND_CMD_PACKET( password);
}
#line 364 "c:/users/infcomp1/desktop/fingerprint/dy50.h"
void writeStructuredPacket(Adafruit_Fingerprint_Packet * packet) {
uint16_t wire_length;
uint16_t sum;
uint8_t i;
 SERIAL_WRITE_U16(packet->start_code);
 SERIAL_WRITE(packet->address[0]);
 SERIAL_WRITE(packet->address[1]);
 SERIAL_WRITE(packet->address[2]);
 SERIAL_WRITE(packet->address[3]);
 SERIAL_WRITE(packet->type);

 wire_length = packet->length + 2;

 SERIAL_WRITE_U16(wire_length);

 sum = ((wire_length)>>8) + ((wire_length)&0xFF) + packet->type;
 for ( i=0; i< packet->length; i++) {
 SERIAL_WRITE(packet->dataraw[i]);
 sum += packet->dataraw[i];
 }

 SERIAL_WRITE_U16(sum);
 return;

}
#line 399 "c:/users/infcomp1/desktop/fingerprint/dy50.h"
uint8_t getStructuredPacket(Adafruit_Fingerprint_Packet * packet, uint16_t timeout) {
 uint8_t byte;
 uint16_t idx=0, timer=0;

 while( 1 ) {

 switch (idx) {
 case 0:
 if (byte != ( 0xEF01  >> 8))
 continue;
 packet->start_code = (uint16_t)byte << 8;
 break;
 case 1:
 packet->start_code |= byte;
 if (packet->start_code !=  0xEF01 )
 return  0xFE ;
 break;
 case 2:
 case 3:
 case 4:
 case 5:
 packet->address[idx-2] = byte;
 break;
 case 6:
 packet->type = byte;
 break;
 case 7:
 packet->length = (uint16_t)byte << 8;
 break;
 case 8:
 packet->length |= byte;
 break;
 default:
 packet->dataraw[idx-9] = byte;
 if((idx-8) == packet->length)
 return  0x00 ;
 break;
 }
 idx++;
 }

 return  0xFE ;
}
#line 3 "C:/Users/infcomp1/Desktop/FingerPrint/FingerPrint.c"
void setup()
{

 begin();

 if (verifyPassword()) {

 UART1_Write_Text("Found fingerprint sensor!");
 } else {

 UART1_Write_Text("Did not find fingerprint sensor :(");
 while (1) { delay_ms(500); }
 }

 getTemplateCount();

 UART1_Write("Sensor contains ");
 UART1_Write(templateCount);
 UART1_Write(" templates\n");
}
int getFingerprintIDez() {
 uint8_t p = getImage();
 if (p !=  0x00 ) return -1;

 p = image2Tz(1);
 if (p !=  0x00 ) return -1;

 p = fingerFastSearch();
 if (p !=  0x00 ) return -1;


 UART1_Write("Found ID #"); UART1_Write(fingerID);
 UART1_Write(" with confidence of "); UART1_Write(confidence);
 return fingerID;
}


uint8_t getFingerprintID() {
 uint8_t p = getImage();
 switch (p) {
 case  0x00 :
 UART1_Write("Image taken");
 break;
 case  0x02 :
 UART1_Write("No finger detected");
 return p;
 case  0x01 :
 UART1_Write("Communication error");
 return p;
 case  0x03 :
 UART1_Write("Imaging error");
 return p;
 default:
 UART1_Write("Unknown error");
 return p;
 }



 p = image2Tz(1);
 switch (p) {
 case  0x00 :
 UART1_Write("Image converted");
 break;
 case  0x06 :
 UART1_Write("Image too messy");
 return p;
 case  0x01 :
 UART1_Write("Communication error");
 return p;
 case  0x07 :
 UART1_Write("Could not find fingerprint features");
 return p;
 case  0x15 :
 UART1_Write("Could not find fingerprint features");
 return p;
 default:
 UART1_Write("Unknown error");
 return p;
 }


 p =fingerFastSearch();
 if (p ==  0x00 ) {
 UART1_Write("Found a print match!");
 } else if (p ==  0x01 ) {
 UART1_Write("Communication error");
 return p;
 } else if (p ==  0x09 ) {
 UART1_Write("Did not find a match");
 return p;
 } else {
 UART1_Write("Unknown error");
 return p;
 }


 UART1_Write("Found ID #"); UART1_Write(fingerID);
 UART1_Write(" with confidence of ");UART1_Write(confidence);

 return fingerID;
}
void main()
{
 while(1){
 getFingerprintIDez();
 delay_ms(50);
} }
