#ifndef dy50_C
#define dy50_C
#include "dy50.h"

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
      //Adafruit_Fingerprint_Packet packet;
        packet.type=FINGERPRINT_COMMANDPACKET;
        packet.length=sizeof(datacmd);
        packet.dataraw[64]=datacmd;
    writeStructuredPacket(&packet);
    if (getStructuredPacket(&packet,1000) != FINGERPRINT_OK)
       return FINGERPRINT_PACKETRECIEVEERR;
    if (packet.type != FINGERPRINT_ACKPACKET) return FINGERPRINT_PACKETRECIEVEERR;

}

uint8_t SEND_CMD_PACKET(uint8_t datacmd)
{

    GET_CMD_PACKET(datacmd);
    return packet.dataraw[0];



}





 void begin() {
  delay_ms(1000);  // one second delay to let the sensor 'boot up'

  UART1_Init(57600);
}
/**************************************************************************/
/*!
    @brief  Verifies the sensors' access password (default password is 0x0000000). A good way to also check if the sensors is active and responding
    @returns True if password is correct
*/
/**************************************************************************/
bool verifyPassword(void) {
  return checkPassword() == FINGERPRINT_OK;
}

uint8_t checkPassword(void) {

  GET_CMD_PACKET(FINGERPRINT_VERIFYPASSWORD);
  GET_CMD_PACKET((uint8_t)(thePassword >> 24));
  GET_CMD_PACKET((uint8_t)(thePassword >> 16));
  GET_CMD_PACKET((uint8_t)(thePassword >> 8));
  GET_CMD_PACKET((uint8_t)(thePassword & 0xFF));

  if (packet.dataraw[0] == FINGERPRINT_OK)
    return FINGERPRINT_OK;
  else
    return FINGERPRINT_PACKETRECIEVEERR;
}

/**************************************************************************/
/*!
    @brief   Ask the sensor to take an image of the finger pressed on surface
    @returns <code>FINGERPRINT_OK</code> on success
    @returns <code>FINGERPRINT_NOFINGER</code> if no finger detected
    @returns <code>FINGERPRINT_PACKETRECIEVEERR</code> on communication error
    @returns <code>FINGERPRINT_IMAGEFAIL</code> on imaging error
*/
/**************************************************************************/
uint8_t getImage(void) {
  SEND_CMD_PACKET(FINGERPRINT_GETIMAGE);
}

/**************************************************************************/
/*!
    @brief   Ask the sensor to convert image to feature template
    @param slot Location to place feature template (put one in 1 and another in 2 for verification to create model)
    @returns <code>FINGERPRINT_OK</code> on success
    @returns <code>FINGERPRINT_IMAGEMESS</code> if image is too messy
    @returns <code>FINGERPRINT_PACKETRECIEVEERR</code> on communication error
    @returns <code>FINGERPRINT_FEATUREFAIL</code> on failure to identify fingerprint features
    @returns <code>FINGERPRINT_INVALIDIMAGE</code> on failure to identify fingerprint features
*/
uint8_t image2Tz(uint8_t slot) {
  slot =1;
  SEND_CMD_PACKET(FINGERPRINT_IMAGE2TZ);
  SEND_CMD_PACKET(slot);
}

/**************************************************************************/
/*!
    @brief   Ask the sensor to take two print feature template and create a model
    @returns <code>FINGERPRINT_OK</code> on success
    @returns <code>FINGERPRINT_PACKETRECIEVEERR</code> on communication error
    @returns <code>FINGERPRINT_ENROLLMISMATCH</code> on mismatch of fingerprints
*/
uint8_t createModel(void) {

  SEND_CMD_PACKET(FINGERPRINT_REGMODEL);
}


/**************************************************************************/
/*!
    @brief   Ask the sensor to store the calculated model for later matching
    @param   location The model location #
    @returns <code>FINGERPRINT_OK</code> on success
    @returns <code>FINGERPRINT_BADLOCATION</code> if the location is invalid
    @returns <code>FINGERPRINT_FLASHERR</code> if the model couldn't be written to flash memory
    @returns <code>FINGERPRINT_PACKETRECIEVEERR</code> on communication error
*/
uint8_t storeModel(uint16_t location) {


  SEND_CMD_PACKET(FINGERPRINT_STORE);
  SEND_CMD_PACKET(0x01);
  SEND_CMD_PACKET((uint8_t)(location >> 8));
  SEND_CMD_PACKET( (uint8_t)(location & 0xFF));

}

/**************************************************************************/
/*!
    @brief   Ask the sensor to load a fingerprint model from flash into buffer 1
    @param   location The model location #
    @returns <code>FINGERPRINT_OK</code> on success
    @returns <code>FINGERPRINT_BADLOCATION</code> if the location is invalid
    @returns <code>FINGERPRINT_PACKETRECIEVEERR</code> on communication error
*/
uint8_t loadModel(uint16_t location) {

  SEND_CMD_PACKET(FINGERPRINT_LOAD);
  SEND_CMD_PACKET(0x01);
  SEND_CMD_PACKET((uint8_t)(location >> 8));
  SEND_CMD_PACKET((uint8_t)(location & 0xFF));
}

/**************************************************************************/
/*!
    @brief   Ask the sensor to transfer 256-byte fingerprint template from the buffer to the UART
    @returns <code>FINGERPRINT_OK</code> on success
    @returns <code>FINGERPRINT_PACKETRECIEVEERR</code> on communication error
*/
uint8_t getModel(void) {
  SEND_CMD_PACKET(FINGERPRINT_UPLOAD);
  SEND_CMD_PACKET( 0x01);
}

/**************************************************************************/
/*!
    @brief   Ask the sensor to delete a model in memory
    @param   location The model location #
    @returns <code>FINGERPRINT_OK</code> on success
    @returns <code>FINGERPRINT_BADLOCATION</code> if the location is invalid
    @returns <code>FINGERPRINT_FLASHERR</code> if the model couldn't be written to flash memory
    @returns <code>FINGERPRINT_PACKETRECIEVEERR</code> on communication error
*/
uint8_t deleteModel(uint16_t location) {
  SEND_CMD_PACKET(FINGERPRINT_DELETE);
  SEND_CMD_PACKET((uint8_t)(location >> 8));
  SEND_CMD_PACKET((uint8_t)(location & 0xFF));
  SEND_CMD_PACKET( 0x00);
  SEND_CMD_PACKET( 0x01);
}

/**************************************************************************/
/*!
    @brief   Ask the sensor to delete ALL models in memory
    @returns <code>FINGERPRINT_OK</code> on success
    @returns <code>FINGERPRINT_BADLOCATION</code> if the location is invalid
    @returns <code>FINGERPRINT_FLASHERR</code> if the model couldn't be written to flash memory
    @returns <code>FINGERPRINT_PACKETRECIEVEERR</code> on communication error
*/
uint8_t emptyDatabase(void) {
  SEND_CMD_PACKET(FINGERPRINT_EMPTY);
}

/**************************************************************************/
/*!
    @brief   Ask the sensor to search the current slot 1 fingerprint features to match saved templates. The matching location is stored in <b>fingerID</b> and the matching confidence in <b>confidence</b>
    @returns <code>FINGERPRINT_OK</code> on fingerprint match success
    @returns <code>FINGERPRINT_NOTFOUND</code> no match made
    @returns <code>FINGERPRINT_PACKETRECIEVEERR</code> on communication error
*/
/**************************************************************************/
uint8_t fingerFastSearch(void) {
  // high speed search of slot #1 starting at page 0x0000 and page #0x00A3
  GET_CMD_PACKET(FINGERPRINT_HISPEEDSEARCH);
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

/**************************************************************************/
/*!
    @brief   Ask the sensor for the number of templates stored in memory. The number is stored in <b>templateCount</b> on success.
    @returns <code>FINGERPRINT_OK</code> on success
    @returns <code>FINGERPRINT_PACKETRECIEVEERR</code> on communication error
*/
/**************************************************************************/
uint8_t getTemplateCount(void) {
  GET_CMD_PACKET(FINGERPRINT_TEMPLATECOUNT);

  templateCount = packet.dataraw[1];
  templateCount <<= 8;
  templateCount |= packet.dataraw[2];

  return packet.dataraw[0];
}

/**************************************************************************/
/*!
    @brief   Set the password on the sensor (future communication will require password verification so don't forget it!!!)
    @param   password 32-bit password code
    @returns <code>FINGERPRINT_OK</code> on success
    @returns <code>FINGERPRINT_PACKETRECIEVEERR</code> on communication error
*/
/**************************************************************************/
uint8_t setPassword(uint32_t password) {
SEND_CMD_PACKET(FINGERPRINT_SETPASSWORD);
SEND_CMD_PACKET((password >> 24));
SEND_CMD_PACKET((password >> 16));
SEND_CMD_PACKET((password >> 8));

  SEND_CMD_PACKET( password);
}

/**************************************************************************/
/*!
    @brief   Helper function to process a packet and send it over UART to the sensor
    @param   packet A structure containing the bytes to transmit
*/
/**************************************************************************/

void writeStructuredPacket( Adafruit_Fingerprint_Packet packet) {
uint16_t wire_length;
uint16_t sum;
uint8_t i;
  SERIAL_WRITE_U16(packet.start_code);
  SERIAL_WRITE(packet.address[0]);
  SERIAL_WRITE(packet.address[1]);
  SERIAL_WRITE(packet.address[2]);
  SERIAL_WRITE(packet.address[3]);
  SERIAL_WRITE(packet.type);

  wire_length = packet.length + 2;

  SERIAL_WRITE_U16(wire_length);

   sum = ((wire_length)>>8) + ((wire_length)&0xFF) + packet.type;
  for ( i=0; i< packet.length; i++) {
    SERIAL_WRITE(packet.dataraw[i]);
    sum += packet.dataraw[i];
  }

  SERIAL_WRITE_U16(sum);
  return;
}

/**************************************************************************/
/*!
    @brief   Helper function to receive data over UART from the sensor and process it into a packet
    @param   packet A structure containing the bytes received
    @param   timeout how many milliseconds we're willing to wait
    @returns <code>FINGERPRINT_OK</code> on success
    @returns <code>FINGERPRINT_TIMEOUT</code> or <code>FINGERPRINT_BADPACKET</code> on failure
*/
/**************************************************************************/
uint8_t getStructuredPacket(Adafruit_Fingerprint_Packet * packet, uint16_t timeout) {
  uint8_t byte;
  uint16_t idx=0, timer=0;

  while(true) {

    switch (idx) {
      case 0:
        if (byte != (FINGERPRINT_STARTCODE >> 8))
          continue;
        packet->start_code = (uint16_t)byte << 8;
        break;
      case 1:
        packet->start_code |= byte;
        if (packet->start_code != FINGERPRINT_STARTCODE)
          return FINGERPRINT_BADPACKET;
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
          return FINGERPRINT_OK;
        break;
    }
    idx++;
  }
  // Shouldn't get here so...
  return FINGERPRINT_BADPACKET;
}
#endif