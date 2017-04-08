//Incase of a failure of the Pressure equalization system (e.g. tank runs out of air)
// We disable manual control and ascend until pressure equalizes and then relinquish
// command to the pilot.
void pesFailureABORT(){
  // ascend until pressure equalizes
  timeout = millis();
  while(analogRead(EXT_PRES)- analogRead(INT_PRES) > MAX_PRES_DIF || millis() - timeout > 3000){
    //disable interrupts from RC handset
     detachInterrupt(digitalPinToInterrupt(V_MOTOR_IN));
    // Run vertical motor in reverse 
    V_MotPWM.write(2000); // set full power to ascend (2000 micros), may have to change to 1000us instead depending on wiring
  }
  //relinquish command to user
  attachInterrupt(digitalPinToInterrupt(V_MOTOR_IN), ISR_vMot, CHANGE);
  
  
}


