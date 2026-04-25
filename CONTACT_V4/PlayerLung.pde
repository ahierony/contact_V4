interface PlayerLungState {

  public boolean getReadyToSetState();
  public void setReadyToSetState(boolean rtss);


  void update();
}

class PlayerLung {

  PlayerLungState state;

  PlayerLungState exhaleState;
  PlayerLungState inhaleState;
  PlayerLungState emptyState;
  PlayerLungState holdState;
  PlayerLungState fullState;

  Player player;

  PlayerLungBreathe breath;

  boolean startExhale;
  boolean startInhale;

  // ***************************
  // originally player variables
  // ***************************
  //Breath breath;
  float radius;
  float radiusMin;
  float radiusMax;

  float currentRadius;
  float movingRadius;
  float previousRadius;

  boolean isBreathing;
  boolean setMovingRadius;

  int colorAngle;

  PlayerLung(Player p) {

    startInhale = false;
    startExhale = false;

    player = p;

    radiusMin  = 45;
    radiusMax  = 150;

    radius = radiusMax;

    isBreathing = true;
    setMovingRadius = true;

    breath = new PlayerLungBreathe();

    inhaleState = new InhaleStatePlayer(player);
    holdState = new HoldStatePlayer(player);
    exhaleState = new ExhaleStatePlayer(player);
    emptyState = new EmptyStatePlayer(player);
    fullState = new FullStatePlayer(player);


    setState(fullState);
  }

  //--------------------------------------------------------------

  void setState(PlayerLungState state) {
    this.state = state;
  }

  //--------------------------------------------------------------

  PlayerLungState getState() {
    return state;
  }

  //--------------------------------------------------------------

  void update() {

    state.update();
    
    println("colorangle update before ", player.colorWheelAngle);

    if (getState() == exhaleState) {
      //updateColorAngle();
    }
    
    println("colorangle update after ", player.colorWheelAngle);

    resetStates();
  }

  //--------------------------------------------------------------

  void resetStates() {

    if (getState() != emptyState) {

      emptyState.setReadyToSetState(true);
    }
  }


  //--------------------------------------------------------------

  //--------------------------------------------------------------

  void updateColorAngle() {

    colorAngle = player.colorWheelAngle;

    colorAngle = player.colorWheelAngle;
    colorAngle += 180;
    colorAngle %= 360;

    player.colorWheelAngle = colorAngle;
  }

  //--------------------------------------------------------------

  void display() {

    Vec2 pos = box2d.getBodyPixelCoord(player.centerSphere.body);

    // Get its angle of rotation
    float a = player.centerSphere.body.getAngle();
    pushMatrix();
    translate(pos.x, pos.y);

    ellipseMode(RADIUS);

    colorAngle = player.colorWheelAngle;
    
    println("colorangle display before ", player.colorWheelAngle);
    /*
    if (getState() == exhaleState) {

      colorAngle = player.colorWheelAngle;
      colorAngle += 180;
      colorAngle %= 360;

      player.colorWheelAngle = colorAngle;
    }
    */
    
    println("colorangle display after ", player.colorWheelAngle);
    
    println("colorAngle ", colorAngle);

    stroke(colorAngle, 100, 50);
    fill(colorAngle, 100, 50);

    circle(0, 0, radiusMax-15 );


    stroke(colorAngle, player.saturation, player.blobBrightness);

    if (getState() == emptyState) {

      strokeWeight(2);
      noFill();
      
    } else {
      
      
      fill(colorAngle, player.saturation, player.blobBrightness);
    }

    circle(0, 0, radius);

    popMatrix();
    
    strokeWeight(1);
  }



  //--------------------------------------------------------------
} // playerLung class

// ********************************************************
// STATE CLASSES
// ********************************************************

class ExhaleStatePlayer implements PlayerLungState {

  boolean readyToSetState;
  //boolean updateExhale;

  Player player;


  ExhaleStatePlayer(Player p) {

    readyToSetState = true;
    player = p;
    //updateExhale = false;
  }

  //--------------------------------------------------------------

  void update() {

    if (!player.lung.startExhale) {
      player.lung.breath.setExhale();
      player.lung.startExhale  = true;
      //updateExhale = true;
    }

    //if (updateExhale) {

    player.lung.breath.breathe();
    player.lung.radius = map(player.lung.breath.radius, player.lung.breath.radiusMin, player.lung.breath.radiusMax, player.lung.radiusMin, player.lung.radiusMax);
    // }
  }

  public boolean getReadyToSetState() {
    return readyToSetState;
  }

  public void setReadyToSetState(boolean rtss) {
    readyToSetState = rtss;
  }
}

//--------------------------------------------------------------

class InhaleStatePlayer implements PlayerLungState {

  boolean readyToSetState;
  //boolean updateInhale;

  Player player;


  InhaleStatePlayer(Player p) {

    readyToSetState = true;
    player = p;
    //updateInhale = false;
  }

  //--------------------------------------------------------------

  void update() {

    if (!player.lung.startInhale) {

      player.lung.breath.setInhale();
      player.lung.startInhale  = true;
      // updateInhale = true;
    }

    //if (updateInhale) {

    player.lung.breath.breathe();
    player.lung.radius = map(player.lung.breath.radius, player.lung.breath.radiusMin, player.lung.breath.radiusMax, player.lung.radiusMin, player.lung.radiusMax);
    // }
  }

  public boolean getReadyToSetState() {
    return readyToSetState;
  }

  public void setReadyToSetState(boolean rtss) {
    readyToSetState = rtss;
  }
}


//--------------------------------------------------------------

class FullStatePlayer implements PlayerLungState {

  Player player;

  boolean readyToSetState;


  FullStatePlayer(Player p) {

    player = p;
  }



  //--------------------------------------------------------------

  void update() {

    player.lung.breath.movement = "full";
  }

  public boolean getReadyToSetState() {
    return readyToSetState;
  }

  public void setReadyToSetState(boolean rtss) {
    readyToSetState = rtss;
  }
}

//--------------------------------------------------------------

class EmptyStatePlayer implements PlayerLungState {

  Player player;

  boolean readyToSetState;


  EmptyStatePlayer(Player p) {

    player = p;
  }

  //--------------------------------------------------------------

  void update() {

    if (readyToSetState) {
      readyToSetState = false;

      player.lung.breath.setEmpty();
      player.lung.radius = map(player.lung.breath.radius, player.lung.breath.radiusMin, player.lung.breath.radiusMax, player.lung.radiusMin, player.lung.radiusMax);

      if (player.jointSphere.body.getType() == BodyType.DYNAMIC) {
        player.jointSphere.body.setType(BodyType.STATIC);
      }
    }
  }

  public boolean getReadyToSetState() {
    return readyToSetState;
  }

  public void setReadyToSetState(boolean rtss) {
    readyToSetState = rtss;
  }
}


//--------------------------------------------------------------

class HoldStatePlayer implements PlayerLungState {

  Player player;

  boolean readyToSetState;

  HoldStatePlayer(Player p) {

    player = p;
  }

  //--------------------------------------------------------------

  void update() {

    player.lung.startExhale = false;
    player.lung.startInhale = false;

    player.lung.breath.movement = "hold";
  }

  public boolean getReadyToSetState() {
    return readyToSetState;
  }

  public void setReadyToSetState(boolean rtss) {
    readyToSetState = rtss;
  }
}
