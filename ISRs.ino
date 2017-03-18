void ISR_vMot(){
  stateVmot = !stateVmot;
  //Could direcly change the port if digital write is too slow
  if(stateVmot == LOW){
    // falling edge: find pulswidth
    vMotPW = micros() - prevTimeVMot;  
    // Write PWM signal to motor drivers
    // these lines of code must be executed at least once
    // every 20ms
    V_MotPWM.write(vMotPW);
  }
  else{
    // rising edge: start timing
    prevTimeVMot = micros();
  }
}



void ISR_lrMot(){
  stateLRmot = !stateLRmot;
  //Could direcly change the port if digital write is too slow
  if(stateLRmot == LOW){
    // falling edge: find pulswidth
    lrMotPW = micros() - prevTimeLRMot;  
    // Write PWM signal to motor drivers
    // these lines of code must be executed at least once
    // every 20ms
    LR_MotPWM.write(lrMotPW);
  }
  else{
    // rising edge: start timing
    prevTimeLRMot = micros();
  }
}

void ISR_frMot(){
   stateFRmot = !stateFRmot;
  //Could direcly change the port if digital write is too slow
  if(stateFRmot == LOW){
    // falling edge: find pulswidth
    frMotPW = micros() - prevTimeFRMot;  
    // Write PWM signal to motor drivers
    // these lines of code must be executed at least once
    // every 20ms
    FR_MotPWM.write(frMotPW);
  }
  else{
    // rising edge: start timing
    prevTimeFRMot = micros();
  }
}
