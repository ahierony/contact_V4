interface PlayerAreaState {

  void update();

  public boolean getReadyToSetState();
  public void setReadyToSetState(boolean rtss);
}

class PlayerArea {

  PlayerAreaState state;

  PlayerAreaState holdState;
  PlayerAreaState emptyState;
  PlayerAreaState fullState;
  PlayerAreaState inhaleState;
  PlayerAreaState exhaleState;
  PlayerAreaState notBreathingState; // revise

  Player player;

  // ***************************
  // originally player variables
  // ***************************

  float radius;
  float radiusMax, radiusMin;
  float distanceRadius;
  float tempDistanceRadius;
  float originalDistanceRadius;

  boolean initialGrowth;
  boolean againstZones;

  // to display area and breathing circles
  boolean isVisible;
  boolean isBreathing;
  boolean resetRadius;

  boolean switchFromExhaleToInhale;

  //--------------------------------------------------------------

  PlayerArea(Player p) {

    player = p;

    holdState = new HoldAreaState();
    emptyState = new EmptyAreaState();
    fullState = new FullAreaState();
    exhaleState = new ExhaleAreaState();
    inhaleState = new InhaleAreaState();
    notBreathingState = new NotBreathingAreaState();

    isVisible = false;
    isBreathing = false;

    initialGrowth = false;
    againstZones = true;

    resetRadius = false;

    setState(notBreathingState);

    radiusMax = player.unitHalf_w;
    radiusMin = player.blobRadius;
    distanceRadius = radiusMax; 
    originalDistanceRadius = radiusMax;

    switchFromExhaleToInhale = false;
    
  }

  //--------------------------------------------------------------

  void setState(PlayerAreaState state) {
    this.state = state;
  }

  //--------------------------------------------------------------

  PlayerAreaState getState() {
    return state;
  }

  //--------------------------------------------------------------

  void update() {

    if (getState() != emptyState) {
      player.readyToUpdateDistanceArea = true;
    }

    state.update();

    if (getState() == notBreathingState) {

      isVisible = false;
      isBreathing = false;
    }

    resetStates();
  }
  //--------------------------------------------------------------

  void resetStates() {
      
    /*
    if (getState() == exhaleState) {

      emptyState.setReadyToSetState(true);
    } else if (getState() == inhaleState) {

      fullState.setReadyToSetState(true);
    } else if(getState()
    */
    
    if(getState() != emptyState){
      emptyState.setReadyToSetState(true);
    } 
  }

  //--------------------------------------------------------------

  void display() {
    
    Vec2 pos = box2d.getBodyPixelCoord(player.centerSphere.body);
    color darkGrey = color(0, 0, 19, 90);

    ellipseMode(RADIUS);

    pushMatrix();

    translate(pos.x, pos.y);


    if (showDistance) {
      // outer circle for checking distance

      stroke(0);
      /*if (vehicleOverlap) {
       strokeWeight(3);
       } else {*/
      strokeWeight(1);
      //}
      fill(darkGrey);
      noStroke();
      circle(0, 0, distanceRadius);
    }

    strokeWeight(1);
    fill(player.colorWheelAngle, 100, 100, 100);
    stroke(darkGrey);
    circle(0, 0, radius);

    popMatrix();
  }


  //--------------------------------------------------------------

  void setAreaState() {
    
    radius = map(player.breath.radius, player.breath.radiusMin, player.breath.radiusMax, radiusMin, distanceRadius);
    
    // breathing radius

    switch(player.breath.movement) {

    case "empty":
      setState(emptyState);
      break;
    case "breathing":

      if (player.breath.direction == "inhale") {

        setState(inhaleState);

        switchFromExhaleToInhale = true;
      } else if (player.breath.direction == "exhale") {

        setState(exhaleState);

        if (player.vehicleInDistanceArea) {

          if (switchFromExhaleToInhale) {

            player.breath.aVelocity *= -1;
            switchFromExhaleToInhale = false;
          }
        }
      }

      break;

    case "full":
      setState(fullState);

      if (player.vehicleInBreathingArea) {

        isBreathing = false;
      } else { // no vehicle in area

        isBreathing = true;
      }
      break;
    default:
      break;
    }
  }
} // playerArea class


// ********************************************************
// STATE CLASSES
// ********************************************************

class HoldAreaState implements PlayerAreaState {


  boolean readyToSetState;

  HoldAreaState() {

    readyToSetState = true;
  }

  //--------------------------------------------------------------

  void update() {
  }

  public boolean getReadyToSetState() {
    return readyToSetState;
  }

  public void setReadyToSetState(boolean rtss) {
    readyToSetState = rtss;
  }
}

// ********************************************************

class EmptyAreaState implements PlayerAreaState {

  boolean readyToSetState;

  EmptyAreaState() {

    readyToSetState = true;
  }

  //--------------------------------------------------------------

  void update() {
    
    if (readyToSetState) {
      readyToSetState = false;
      
      player.breath.setEmpty();
      player.area.radius = map(player.breath.radius, player.breath.radiusMin, player.breath.radiusMax, player.area.radiusMin, player.area.distanceRadius);
      player.area.isBreathing = true;
        
      
      //player.lung.radius = map(player.lung.breath.radius, player.lung.breath.radiusMin, player.lung.breath.radiusMax, player.lung.radiusMin, player.lung.radiusMax);

    }
  }
  /*
  void checkDistanceAreaAgainstVehiclesDistanceZone() {

    float tempDistanceRadius = player.area.originalDistanceRadius;

    int offset = 10;

    for (int i = 0; i < vehicles.size()-1; i++) {

      Vehicle v = vehicles.get(i);

      Vec2 vehiclePosPix = box2d.getBodyPixelCoord(v.centerBoid.body);
      Vec2 playerPosPix = box2d.getBodyPixelCoord(player.centerSphere.body);

      float d_pix = dist(vehiclePosPix.x, vehiclePosPix.y, playerPosPix.x, playerPosPix.y);

      if (d_pix < v.zone.distanceRadius + tempDistanceRadius) {

        tempDistanceRadius = (d_pix / 2) - offset;
        v.zone.distanceRadius = (d_pix / 2) - offset;
      }
    }

    player.area.distanceRadius = tempDistanceRadius;
  }
  */

  public boolean getReadyToSetState() {
    return readyToSetState;
  }

  public void setReadyToSetState(boolean rtss) {
    readyToSetState = rtss;
  }
}

// ********************************************************

class FullAreaState implements PlayerAreaState {

  boolean readyToSetState;

  FullAreaState() {

    readyToSetState = true;
  }

  //--------------------------------------------------------------

  void update() {

    if (readyToSetState) {
      readyToSetState = false;
    }
  }

  public boolean getReadyToSetState() {
    return readyToSetState;
  }

  public void setReadyToSetState(boolean rtss) {
    readyToSetState = rtss;
  }
}

// ********************************************************

class ExhaleAreaState implements PlayerAreaState {

  boolean readyToSetState;

  ExhaleAreaState() {

    readyToSetState = true;
  }

  //--------------------------------------------------------------

  void update() {
  }

  public boolean getReadyToSetState() {
    return readyToSetState;
  }

  public void setReadyToSetState(boolean rtss) {
    readyToSetState = rtss;
  }
}
// ********************************************************

class InhaleAreaState implements PlayerAreaState {

  boolean readyToSetState;

  InhaleAreaState() {

    readyToSetState = true;
  }

  //--------------------------------------------------------------

  void update() {
  }

  public boolean getReadyToSetState() {
    return readyToSetState;
  }

  public void setReadyToSetState(boolean rtss) {
    readyToSetState = rtss;
  }
}

// ********************************************************

class NotBreathingAreaState implements PlayerAreaState {

  boolean readyToSetState;

  NotBreathingAreaState() {

    readyToSetState = true;
  }

  //--------------------------------------------------------------

  void update() {
  }

  public boolean getReadyToSetState() {
    return readyToSetState;
  }

  public void setReadyToSetState(boolean rtss) {
    readyToSetState = rtss;
  }
}
