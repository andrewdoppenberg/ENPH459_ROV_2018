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
int attitude[] ={0,0,0};

int count = 0,lastCount;
int lastTime =0;

void loop() {
  
  if(count == 0){
    lcd.setCursor(0,0);
    lcd.print("Waiting to Recieve data...");
    
  }
  if(millis() - lastTime > 1000){
    if((millis() - lastTime)%100 == 0){lcd.clear();}//clear every 100ms        
    lcd.setCursor(0,2);
    lcd.print("Time last:");
    lcd.print(millis()-lastTime);    
   }
  
  if (rf95.available())//true if message availble for us
  {
    lastTime = millis();
    count++;
    // Should be a message for us now   
    uint8_t buf[RH_RF95_MAX_MESSAGE_LEN];
    uint8_t len = sizeof(buf);
    uint8_t dataCode[3], data[len-3];
    
    //Print tab delimited Attitude data for reading by computer
    if(Serial){
      Serial.print(attitude[0]);Serial.print("  ");Serial.print(attitude[1]);Serial.print(" ");Serial.println(attitude[2]);
    }
    
    if (rf95.recv(buf, &len))
    {
      digitalWrite(LED_BUILTIN, HIGH);
      //RH_RF95::printBuffer("Received: ", buf, len);
      lcd.setCursor(11,4);
      lcd.print("RSSI:");
      lcd.setCursor(17,4);
      lcd.print(rf95.lastRssi(), DEC); //display signal strength
          
      
      
      
      for(int i = 0;i <= 3;i++){
        dataCode[i] = buf[i];
      }
      dataCode[4] = '\0'; //we need to manually terminate the string
      for(int i = 5; i<= len; i++){ //skip buf[4] since that should be a space
        data[i-5] = buf[i];
      }
            
      
      if(strcmp((char*)dataCode,"$TMP")==0){
        if((int)data != lastTmp){
          lcd.setCursor(0, 1);
          lcd.print("Temp:");
          lcd.setCursor(5, 1);
          lcd.print((char*)data);
          lastTmp = (int)data;  
        }      
        
      }
      else if(strcmp( (char*)dataCode,"$PRD" ) == 0){
        if((int)data != lastPrd){
          lcd.setCursor(8, 1);
          lcd.print("PrsDif:");
          lcd.setCursor(15, 1);
          lcd.print((char*)data);
          lastPrd  = (int)data; 
        }
        
      }
      else if(strcmp( (char*)dataCode, "$TPR" ) == 0){
        if((int)data != lastTpr){
          lcd.setCursor(0, 2);
          lcd.print("TnkPres:");
          lcd.setCursor(8, 2);
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

       else if(strcmp( (char*)dataCode,"$ROL" ) == 0){
        lcd.setCursor(0, 0);
        lcd.print("R:     ");
        attitude[0] = (int) data;
        lcd.setCursor(2, 0);

        }
        
      
      else if(strcmp( (char*)dataCode,"$PIT" ) == 0){
        lcd.setCursor(7, 0);
        lcd.print("P:    ");
        attitude[1] = (int) data;
        lcd.setCursor(9, 0);

        
      }
      else if(strcmp( (char*)dataCode,"$YAW" ) == 0){        
        lcd.setCursor(13, 0);
        lcd.print("Y:     ");
        attitude[2] = (int) data;
        lcd.setCursor(15, 0);
        lcd.print((char*)data);           
                
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
        
      
    
    
    
    digitalWrite(LED_BUILTIN, LOW);
  }
 
  
  

  
  

