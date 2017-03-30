boolean transmitData(int data, int type ){
  int n;
  digitalWrite(LED_BUILTIN, HIGH);
  char radiopacket[RH_RF95_MAX_MESSAGE_LEN];
  switch (type){
    case TEMP_DATA: //temperature
      n = sprintf (radiopacket, "$TMP %d", data);
      break;
    case PRES_DIFF_DATA: //pressure differential
      n = sprintf (radiopacket, "$PRD %d", data);
      break;
    case TANK_PRES_DATA: //Estimated tank pressure
      n = sprintf (radiopacket, "$TPR %d", data);
      break;
    case DEPTH_DATA: // calculated depth
       n = sprintf (radiopacket, "$DEP %d", data);
       break;
    case ROLL_DATA: // calculated depth
       n = sprintf (radiopacket, "$ROL %d", data);
       break;
    case PITCH_DATA: // calculated depth
       n = sprintf (radiopacket, "$PIT %d", data);
       break;
    case YAW_DATA: // calculated depth
       n = sprintf (radiopacket, "$YAW %d", data);
       break;
    
  }
  Serial.println(radiopacket);
  
  rf95.send((uint8_t *)radiopacket, 20); // transmit the data
  delay(10);
  digitalWrite(LED_BUILTIN, LOW);
  if( n > RH_RF95_MAX_MESSAGE_LEN || n < 0){//make sure message is correct length (or if n<0 error occured)
    return false;
  }
  else{  
    return true;
  }
    
  
}

