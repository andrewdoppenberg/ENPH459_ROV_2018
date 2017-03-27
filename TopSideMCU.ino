#include <SPI.h>
#include <RH_RF95.h>

#define RFM95_CS 53 // Chip Select pin
#define RFM95_RST 47 // Reset Pin
#define RFM95_INT 19 // interrupt pin (data ready)

// Change to 434.0 or other frequency, must match RX's freq!
#define RF95_FREQ 915.0

// Singleton instance of the radio driver
RH_RF95 rf95(RFM95_CS, RFM95_INT);



#include <LiquidCrystal.h>
 
// initialize the library with the numbers of the interface pins
LiquidCrystal lcd(12, 11, 5, 4, 3, 2);
void setup() {
  // put your setup code here, to run once:
  RF95_setup();
  pinMode(LED_BUILTIN, OUTPUT);
  lcd.begin(20,4);

}
uint8_t lastTmp, lastPrd, lastTpr, lastDep;
int count = 0;
void loop() {
  
  if (rf95.available())
  {
    count++;
    // Should be a message for us now   
    uint8_t buf[RH_RF95_MAX_MESSAGE_LEN];
    uint8_t len = sizeof(buf);
    uint8_t dataCode[3], data[len-3];
    
    
    
    if (rf95.recv(buf, &len))
    {
      digitalWrite(LED_BUILTIN, HIGH);
      RH_RF95::printBuffer("Received: ", buf, len);
      //lcd.print("Got: ");
      //lcd.println((char*)buf);
      lcd.setCursor(11,4);
      lcd.print("RSSI:");
      lcd.setCursor(17,4);
      lcd.print(rf95.lastRssi(), DEC);
      
      //lcd.println(count);

      
      
      
      
      for(int i = 0;i <= 3;i++){
        dataCode[i] = buf[i];
      }
      dataCode[4] = '\0'; //we need to manually terminate the string
      for(int i = 5; i<= len; i++){ //skip buf[4] since that should be a space
        data[i-5] = buf[i];
      }
            
      
      if(strcmp((char*)dataCode,"$TMP")==0){
        if((int)data != lastTmp){
          lcd.setCursor(0, 0);
          lcd.print("Temp: ");
          lcd.setCursor(6, 0);
          lcd.print((char*)data);
          lastTmp = (int)data;  
        }      
        
      }
      else if(strcmp( (char*)dataCode,"$PRD" ) == 0){
        if((int)data != lastPrd){
          lcd.setCursor(0, 1);
          lcd.print("Pres Diff:");
          lcd.setCursor(11, 1);
          lcd.print((char*)data);
          lastPrd  = (int)data; 
        }
        
      }
      else if(strcmp( (char*)dataCode, "$TPR" ) == 0){
        if((int)data != lastTpr){
          lcd.setCursor(0, 2);
          lcd.print("Tank Pres: ");
          lcd.setCursor(11, 2);
          lcd.print((char*)data);
          lastTpr = (int)data; 
        }
      }
      else if(strcmp( (char*)dataCode , "$DEP" ) == 0){
        if((int)data != lastDep){
          lcd.setCursor(0, 3);
          lcd.print("DEPTH:");
          lcd.setCursor(7, 3);
          lcd.print((char*)data);
          lastDep = (int)data; 
        }
      }
      else{
        //unable to parse properly
        lcd.print("Unable to Parse Data: ");
        lcd.print((char*)data);
        lcd.print("DataCode: ");
        lcd.print((char*)dataCode);
        lcd.print((char*)buf);
      }
        
      
    }
    else
    {
      lcd.print("Receive failed");
    }
    //lcd.print();//line between messages
    digitalWrite(LED_BUILTIN, LOW);
  }
 
  
  

  
  
}
