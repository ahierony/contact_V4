interface VehicleLungState {

  public boolean getReadyToSetState();
  public void setReadyToSetState(boolean rtss);


  void update();
}

class VehicleLung {

  VehicleLungState state;

  VehicleLungState exhaleState;
  VehicleLungState inhaleState;
  VehicleLungState emptyState;
  VehicleLungState holdState;
  VehicleLungState fullState;

  //Agent agent;
  Agent agent;

  VehicleLungBreathe breath;

  boolean startExhale;
  boolean startInhale;

  // ***************************
  // originally vehicle variables
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

  VehicleLung(Agent a) {

    startInhale = false;
    startExhale = false;

    //agent = a;
    agent = a;

    radiusMin  = 32;
    radiusMax  = 105;

    radius = radiusMax;

    isBreathing = true;
    setMovingRadius = true;

    breath = new VehicleLungBreathe();

    inhaleState = new InhaleStateVehicle(agent);
    holdState = new HoldStateVehicle(agent);
    exhaleState = new ExhaleStateVehicle(agent);
    emptyState = new EmptyStateVehicle(agent);
    fullState = new FullStateVehicle(agent);


    setState(fullState);
  }

  //--------------------------------------------------------------

  void setState(VehicleLungState state) {
    this.state = state;
  }

  //--------------------------------------------------------------

  VehicleLungState getState() {
    return state;
  }

  //--------------------------------------------------------------

  void update() {

    state.update();

    if (getState() == exhaleState) {
      //updateColorAngle();
    }

    resetStates();
  }

  //--------------------------------------------------------------

  void resetStates() {

    if (getState() != emptyState) {

      emptyState.setReadyToSetState(true);
    } 
    
    if (getState() == inhaleState) {
      exhaleState.setReadyToSetState(true);
    } 
    
    if (getState() == exhaleState) {
      inhaleState.setReadyToSetState(true);
    }
  }


  //--------------------------------------------------------------

  //--------------------------------------------------------------
  /*
  void updateColorAngle() {
   
   colorAngle = agent.v.colorWheelAngle;
   
   colorAngle = agent.v.colorWheelAngle;
   colorAngle += 180;
   colorAngle %= 360;
   
   agent.v.colorWheelAngle = colorAngle;
   }
   */
  //--------------------------------------------------------------

  void display() {

    Vec2 pos = box2d.getBodyPixelCoord(agent.v.centerBoid.body);

    // Get its angle of rotation
    //float a = agent.v.centerBoid.body.getAngle();
    pushMatrix();
    translate(pos.x, pos.y);

    ellipseMode(RADIUS);

    colorAngle = agent.v.colorWheelAngle;

    /*
    if (getState() == exhaleState) {
     
     colorAngle = agent.v.colorWheelAngle;
     colorAngle += 180;
     colorAngle %= 360;
     
     agent.v.colorWheelAngle = colorAngle;
     }
     */

    stroke(colorAngle, 100, 50);
    fill(colorAngle, 100, 50);

    circle(0, 0, radiusMax-15 );


    stroke(colorAngle, agent.v.saturation, agent.v.brightness);

    if (getState() == emptyState) {

      strokeWeight(2);
      noFill();
    } else {


      fill(colorAngle, agent.v.saturation, agent.v.brightness);
    }

    circle(0, 0, agent.lungSize);

    popMatrix();

    strokeWeight(1);
  }



  //--------------------------------------------------------------
} // vehicleLung class

// ********************************************************
// STATE CLASSES
// ********************************************************

class ExhaleStateVehicle implements VehicleLungState {

  boolean readyToSetState;
  //boolean updateExhale;

  Agent agent;


  ExhaleStateVehicle(Agent a) {

    readyToSetState = true;
    agent = a;
    //updateExhale = false;
  }

  //--------------------------------------------------------------

  void update() {

    //if (!agent.v.lung.startExhale) {
    if(readyToSetState) {
      agent.v.lung.breath.setExhale();
      //agent.v.lung.startExhale  = true;
      readyToSetState = false;
      //updateExhale = true;
    }

    //if (updateExhale) {

    agent.v.lung.breath.breathe();
    agent.v.lung.radius = map(agent.v.lung.breath.radius, agent.v.lung.breath.radiusMin, agent.v.lung.breath.radiusMax, agent.v.lung.radiusMin, agent.v.lung.radiusMax);
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

class InhaleStateVehicle implements VehicleLungState {

  boolean readyToSetState;
  //boolean updateInhale;

  Agent agent;


  InhaleStateVehicle(Agent a) {

    readyToSetState = true;
    agent = a;
    //updateInhale = false;
  }

  //--------------------------------------------------------------

  void update() {

    //if (!agent.v.lung.startInhale) {
    if(readyToSetState) {
      agent.v.lung.breath.setInhale();
      //agent.v.lung.startInhale  = true;
      readyToSetState = false;
      // updateInhale = true;
    }

    //if (updateInhale) {

    agent.v.lung.breath.breathe();
    agent.v.lung.radius = map(agent.v.lung.breath.radius, agent.v.lung.breath.radiusMin, agent.v.lung.breath.radiusMax, agent.v.lung.radiusMin, agent.v.lung.radiusMax);
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

class FullStateVehicle implements VehicleLungState {

  Agent agent;

  boolean readyToSetState;


  FullStateVehicle(Agent a) {

    agent = a;
  }



  //--------------------------------------------------------------

  void update() {

    agent.v.lung.breath.movement = "full";
  }

  public boolean getReadyToSetState() {
    return readyToSetState;
  }

  public void setReadyToSetState(boolean rtss) {
    readyToSetState = rtss;
  }
}

//--------------------------------------------------------------

class EmptyStateVehicle implements VehicleLungState {

  Agent agent;

  boolean readyToSetState;


  EmptyStateVehicle(Agent a) {

    agent = a;
  }

  //--------------------------------------------------------------

  void update() {

    if (readyToSetState) {
      readyToSetState = false;

      agent.v.lung.breath.setEmpty();
      agent.v.lung.radius = map(agent.v.lung.breath.radius, agent.v.lung.breath.radiusMin, agent.v.lung.breath.radiusMax, agent.v.lung.radiusMin, agent.v.lung.radiusMax);

      /*
      if (agent.v.jointSphere.body.getType() == BodyType.DYNAMIC) {
       agent.v.jointSphere.body.setType(BodyType.STATIC);
       }
       */
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

class HoldStateVehicle implements VehicleLungState {

  Agent agent;

  boolean readyToSetState;

  HoldStateVehicle(Agent a) {

    agent = a;
  }

  //--------------------------------------------------------------

  void update() {

    agent.v.lung.startExhale = false;
    agent.v.lung.startInhale = false;

    agent.v.lung.breath.movement = "hold";
  }

  public boolean getReadyToSetState() {
    return readyToSetState;
  }

  public void setReadyToSetState(boolean rtss) {
    readyToSetState = rtss;
  }
}
