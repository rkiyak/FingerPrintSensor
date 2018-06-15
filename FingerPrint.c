#include "DY50.h"

void setup()
{

     begin();//57600 baud rate de uart baslat

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
  if (p != FINGERPRINT_OK)  return -1;

  p = image2Tz(1);
  if (p != FINGERPRINT_OK)  return -1;

  p = fingerFastSearch();
  if (p != FINGERPRINT_OK)  return -1;

  // found a match!
  UART1_Write("Found ID #"); UART1_Write(fingerID);
  UART1_Write(" with confidence of "); UART1_Write(confidence);
  return fingerID;
}


uint8_t getFingerprintID() {
  uint8_t p = getImage();
  switch (p) {
    case FINGERPRINT_OK:
      UART1_Write("Image taken");
      break;
    case FINGERPRINT_NOFINGER:
      UART1_Write("No finger detected");
      return p;
    case FINGERPRINT_PACKETRECIEVEERR:
      UART1_Write("Communication error");
      return p;
    case FINGERPRINT_IMAGEFAIL:
      UART1_Write("Imaging error");
      return p;
    default:
      UART1_Write("Unknown error");
      return p;
  }

  // OK success!

  p = image2Tz(1);
  switch (p) {
    case FINGERPRINT_OK:
      UART1_Write("Image converted");
      break;
    case FINGERPRINT_IMAGEMESS:
      UART1_Write("Image too messy");
      return p;
    case FINGERPRINT_PACKETRECIEVEERR:
      UART1_Write("Communication error");
      return p;
    case FINGERPRINT_FEATUREFAIL:
      UART1_Write("Could not find fingerprint features");
      return p;
    case FINGERPRINT_INVALIDIMAGE:
      UART1_Write("Could not find fingerprint features");
      return p;
    default:
      UART1_Write("Unknown error");
      return p;
  }

  // OK converted!
  p =fingerFastSearch();
  if (p == FINGERPRINT_OK) {
    UART1_Write("Found a print match!");
  } else if (p == FINGERPRINT_PACKETRECIEVEERR) {
    UART1_Write("Communication error");
    return p;
  } else if (p == FINGERPRINT_NOTFOUND) {
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
  delay_ms(50);            //don't ned to run this at full speed.
}                      }