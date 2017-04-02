// Interrupt Service Routines
// These are for reading the PWM signal from the RC reciever
// and for outputting a new PWM signal to the motor drivers.
// If automatic control of motors is desired, you'll have to 
// detach the interrupt for that motor before doing so. 
// i.e. detachInterrupt(digitalPinToInterrupt(V_MOTOR_IN));
// to detach the vertical motor interrupt. Remember to reattach
// the intterrupt afterwards, otherwise you'll lose 
// manual control!

//vertical motor control
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


//left-right motor control
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
//forward-reverse motor control
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

