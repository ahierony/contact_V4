interface PlayerMotionState {

  void update();
}

class PlayerMotion {

  PlayerMotionState state;

  PlayerMotionState pMotionAccelState;
  PlayerMotionState pMotionRotateState;
  PlayerMotionState pMotionStillState;
 
  Player player;

  PlayerMotion(Player p) {

    player = p;

    pMotionAccelState = new PMotionAccelState(player);
    pMotionRotateState = new PMotionRotateState(player);
    pMotionStillState = new PMotionStillState(player);
   
    setState(pMotionStillState);
  }

  //--------------------------------------------------------------

  void setState(PlayerMotionState state) {
    this.state = state;
  }

  //--------------------------------------------------------------

  PlayerMotionState getState() {
    return state;
  }

  //--------------------------------------------------------------

  void update() {
    
    state.update();
   
  }

  
  //--------------------------------------------------------------
} // PlayerMotion class

// ********************************************************
// STATE CLASSES
// ********************************************************

class PMotionAccelState implements PlayerMotionState {

  boolean readyToSetState;
  Player player;


  PMotionAccelState(Player p) {

    readyToSetState = true;
    player = p;
   
  }

  //--------------------------------------------------------------

  void update() {

    player.updateAccelBoth();
    
    //println("player accel ");
    
    //println("player linear velocity ", player.getLinearVelocity());
  
  }
}

//--------------------------------------------------------------

class PMotionRotateState implements PlayerMotionState {

  Player player;

  PMotionRotateState(Player p) {

    player = p;
  }

  //--------------------------------------------------------------

  void update() {
    
    if (player.lockedEye == "left") {
      player.updateAccel(player.leftEye);
      
      //println("player rotate left ");
      
    } else if (player.lockedEye == "right") {
      player.updateAccel(player.rightEye);
      
      //println("player rotate right ");
    }
    
    //println("player linear velocity ", player.getLinearVelocity());
    
  }
}


//--------------------------------------------------------------

class PMotionStillState implements PlayerMotionState {

  boolean readyToSetState;
  Player player;


  PMotionStillState(Player p) {

    readyToSetState = true;
    player = p;
   
  }

  //--------------------------------------------------------------

  void update() {
    
    //println("player still ");
  
  }
}
