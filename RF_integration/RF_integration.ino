

// Date: Jan. 24
// Purpose: incorporating RF95 COMMS with other ROV functions

#include <SPI.h>
#include <RH_RF95.h>
#include <ServoTimer2.h>



#define RFM95_CS 53 // Chip Select pin
#define RFM95_RST 47 // Reset Pin
#define RFM95_INT 19 // interrupt pin (data ready) NOTE: We need pins 20 and 21 for the IMU, so use pin 19 on the onboard MCU at least

// Change to 434.0 or other frequency, must match RX's freq!
#define RF95_FREQ 915.0

// Singleton instance of the radio driver
RH_RF95 rf95(RFM95_CS, RFM95_INT);

//Motor Interrupts, must be an interrupt pin (2, 3, 18, 19, 20, 21)
#define V_MOTOR_IN 2 // vertical motor channel
#define LR_MOTOR_IN 3 // left/right control channel
#define FR_MOTOR_IN 18 // Foreward/Reverse control channel

// Motor PWM pins, output to drivers, must be of pins 2-13 or 44-46
#define V_MOTOR_OUT 4  // vertical motor channel
#define LR_MOTOR_OUT 5 // left/right control channel
#define FR_MOTOR_OUT 6 // Foreward/Reverse control channel

//Telemetry Data types
#define COMM_INTERVAL 20 //loop interval at which data is sent up
<<<<<<< HEAD:RF_integration/RF_integration.ino
#define IMU_COMM_INTERVAL 1 //loop interval at which IMU data is sent up
=======
#define IMU_COMM_INTERVAL 1
>>>>>>> refs/remotes/origin/rollpitchyawdisp:RF_integration.ino
#define TEMP_DATA 1
#define PRES_DIFF_DATA 2
#define TANK_PRES_DATA 3
#define DEPTH_DATA 4
#define ROLL_DATA 5
#define PITCH_DATA 6
#define YAW_DATA 7
<<<<<<< HEAD:RF_integration/RF_integration.ino

=======
>>>>>>> refs/remotes/origin/rollpitchyawdisp:RF_integration.ino

#define DEPTH_FACTOR 1 //rho*g



//State of input pin of interrupts
volatile byte stateVmot, stateLRmot, stateFRmot;
//Pulsewidth for motor commands
volatile long int vMotPW, lrMotPW, frMotPW;
// previous times in microseconds for measuring pulsewidth
volatile long int prevTimeVMot, prevTimeLRMot, prevTimeFRMot;


// Sensor Pins
#define EXT_PRES A0 //external pressure sensor
#define INT_PRES A1 // Internal pressure sensor
#define TEMP A2 //Temperature

//Constants
#define MAX_PRES_DIF 1 //Maximum pressure differential between inside/outside
#define INIT_PRES 20000 // Initial Tank Pressure (kPa)
#define FILT_PARAM 4 //MA filter parameter, make power of 2 for efficiency
long  extPres, intPres, temp, curPres, prevPres, roll, pitch, yaw;
long  tankPres = INIT_PRES;

ServoTimer2 V_MotPWM, LR_MotPWM, FR_MotPWM;


void setup() {
  
  // put your setup code here, to run once:
  RF95_setup();

  pinMode(LED_BUILTIN, OUTPUT);
  
  //setup sensor pins
  pinMode(EXT_PRES, INPUT);
  pinMode(INT_PRES, INPUT);
  pinMode(TEMP, INPUT);
  
  // Set up interrupts for motor control
  attachInterrupt(digitalPinToInterrupt(V_MOTOR_IN), ISR_vMot, CHANGE);
  attachInterrupt(digitalPinToInterrupt(LR_MOTOR_IN), ISR_lrMot, CHANGE);
  attachInterrupt(digitalPinToInterrupt(FR_MOTOR_IN), ISR_frMot, CHANGE);
  pinMode(V_MOTOR_IN,INPUT);
  pinMode(LR_MOTOR_IN,INPUT);
  pinMode(FR_MOTOR_IN,INPUT);
  
  // Attach motor output ports as servos to use PWM
  V_MotPWM.attach(V_MOTOR_OUT);
  LR_MotPWM.attach(LR_MOTOR_OUT);
  FR_MotPWM.attach(FR_MOTOR_OUT);
  
  //set initial states of interrupt pins. MUST be at the very end of setup() (otherwise could change without interrupt)
  stateVmot = digitalRead(V_MOTOR_IN);
  stateLRmot = digitalRead(LR_MOTOR_IN);
  stateFRmot = digitalRead(FR_MOTOR_IN);
}
int count = 0;
void loop() {

  count++; // loop counter
/*
  //Poll sensors
  extPres = analogRead(EXT_PRES); //need to add scaling factors
  intPres = analogRead(INT_PRES);
  
  if(extPres - intPres > MAX_PRES_DIF){ //may need to replace this since we may only have an internal sensor + differential sensor
    tankPres = intPres; // well at least we know how much air is left in the tank now!
    pesFailureABORT();
  }
  curPres = prevPres + (intPres - prevPres)/FILT_PARAM; // Calculate the new MA filter value
  tankPres -= ( (curPres - prevPres) - abs(curPres - prevPres) )/2; // calculate new tank pressure on dive (no change on ascent)
  prevPres = curPres;
  */
  temp = (5.0*analogRead(TEMP)/1023.0 - 1.25)/.005;
  
  tankPres = 1000;
 
  extPres = 69+50;
  intPres = 50;


  if (count%COMM_INTERVAL == 0){  
    if(!transmitData(temp,TEMP_DATA)){
      //data did not transmit correctly for some reason
      transmitData(temp,TEMP_DATA); // try one more time
    }
  }
  else if (count%COMM_INTERVAL == COMM_INTERVAL/4){
    if(!transmitData(extPres*DEPTH_FACTOR,DEPTH_DATA)){
      //data did not transmit correctly for some reason
      transmitData(extPres*DEPTH_FACTOR,DEPTH_DATA); // try one more time
    }
  }
  else if (count%COMM_INTERVAL == COMM_INTERVAL/2){
    if(!transmitData(tankPres,TANK_PRES_DATA)){
      //data did not transmit correctly for some reason
      transmitData(tankPres,TANK_PRES_DATA); // try one more time
    }
  }
  else if (count%COMM_INTERVAL == 3*COMM_INTERVAL/4){
    if(!transmitData(intPres-extPres,PRES_DIFF_DATA)){
      //data did not transmit correctly for some reason
      transmitData(intPres-extPres,PRES_DIFF_DATA); // try one more time
    }    
  }


  //we should send IMU data much more frequently than other data
  if(count%IMU_COMM_INTERVAL == 0){
    if(!transmitData(roll,ROLL_DATA)){
      //data did not transmit correctly for some reason
      transmitData(roll,ROLL_DATA); // try one more time
    }
    if(!transmitData(pitch,PITCH_DATA)){
      //data did not transmit correctly for some reason
      transmitData(pitch,PITCH_DATA); // try one more time
    }
    if(!transmitData(yaw,YAW_DATA)){
      //data did not transmit correctly for some reason
      transmitData(yaw,YAW_DATA); // try one more time
    }

  }
  

  }
    
  






}


