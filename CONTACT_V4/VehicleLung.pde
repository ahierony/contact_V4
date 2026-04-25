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

  Vehicle vehicle;

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

  VehicleLung(Vehicle v) {

    startInhale = false;
    startExhale = false;

    vehicle = v;

    radiusMin  = 32;
    radiusMax  = 105;
    
    radius = radiusMax;

    isBreathing = true;
    setMovingRadius = true;

    breath = new VehicleLungBreathe();

    inhaleState = new InhaleStateVehicle(vehicle);
    holdState = new HoldStateVehicle(vehicle);
    exhaleState = new ExhaleStateVehicle(vehicle);
    emptyState = new EmptyStateVehicle(vehicle);
    fullState = new FullStateVehicle(vehicle);


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
  }


  //--------------------------------------------------------------

  //--------------------------------------------------------------
/*
  void updateColorAngle() {

    colorAngle = vehicle.colorWheelAngle;

    colorAngle = vehicle.colorWheelAngle;
    colorAngle += 180;
    colorAngle %= 360;

    vehicle.colorWheelAngle = colorAngle;
  }
*/
  //--------------------------------------------------------------

  void display() {

    Vec2 pos = box2d.getBodyPixelCoord(vehicle.centerBoid.body);

    // Get its angle of rotation
    //float a = vehicle.centerBoid.body.getAngle();
    pushMatrix();
    translate(pos.x, pos.y);

    ellipseMode(RADIUS);

    colorAngle = vehicle.colorWheelAngle;
    
    /*
    if (getState() == exhaleState) {

      colorAngle = vehicle.colorWheelAngle;
      colorAngle += 180;
      colorAngle %= 360;

      vehicle.colorWheelAngle = colorAngle;
    }
    */
    
    stroke(colorAngle, 100, 50);
    fill(colorAngle, 100, 50);

    circle(0, 0, radiusMax-15 );


    stroke(colorAngle, vehicle.saturation, vehicle.brightness);

    if (getState() == emptyState) {

      strokeWeight(2);
      noFill();
      
    } else {
      
      
      fill(colorAngle, vehicle.saturation, vehicle.brightness);
    }

    circle(0, 0, radius);

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

  Vehicle vehicle;


  ExhaleStateVehicle(Vehicle v) {

    readyToSetState = true;
    vehicle = v;
    //updateExhale = false;
  }

  //--------------------------------------------------------------

  void update() {

    if (!vehicle.lung.startExhale) {
      vehicle.lung.breath.setExhale();
      vehicle.lung.startExhale  = true;
      //updateExhale = true;
    }

    //if (updateExhale) {

    vehicle.lung.breath.breathe();
    vehicle.lung.radius = map(vehicle.lung.breath.radius, vehicle.lung.breath.radiusMin, vehicle.lung.breath.radiusMax, vehicle.lung.radiusMin, vehicle.lung.radiusMax);
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

  Vehicle vehicle;


  InhaleStateVehicle(Vehicle v) {

    readyToSetState = true;
    vehicle = v;
    //updateInhale = false;
  }

  //--------------------------------------------------------------

  void update() {

    if (!vehicle.lung.startInhale) {

      vehicle.lung.breath.setInhale();
      vehicle.lung.startInhale  = true;
      // updateInhale = true;
    }

    //if (updateInhale) {

    vehicle.lung.breath.breathe();
    vehicle.lung.radius = map(vehicle.lung.breath.radius, vehicle.lung.breath.radiusMin, vehicle.lung.breath.radiusMax, vehicle.lung.radiusMin, vehicle.lung.radiusMax);
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

  Vehicle vehicle;

  boolean readyToSetState;


  FullStateVehicle(Vehicle v) {

    vehicle = v;
  }



  //--------------------------------------------------------------

  void update() {

    vehicle.lung.breath.movement = "full";
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

  Vehicle vehicle;

  boolean readyToSetState;


  EmptyStateVehicle(Vehicle v) {

    vehicle = v;
  }

  //--------------------------------------------------------------

  void update() {

    if (readyToSetState) {
      readyToSetState = false;

      vehicle.lung.breath.setEmpty();
      vehicle.lung.radius = map(vehicle.lung.breath.radius, vehicle.lung.breath.radiusMin, vehicle.lung.breath.radiusMax, vehicle.lung.radiusMin, vehicle.lung.radiusMax);
      
      /*
      if (vehicle.jointSphere.body.getType() == BodyType.DYNAMIC) {
        vehicle.jointSphere.body.setType(BodyType.STATIC);
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

  Vehicle vehicle;

  boolean readyToSetState;

  HoldStateVehicle(Vehicle v) {

    vehicle = v;
  }

  //--------------------------------------------------------------

  void update() {

    vehicle.lung.startExhale = false;
    vehicle.lung.startInhale = false;

    vehicle.lung.breath.movement = "hold";
  }

  public boolean getReadyToSetState() {
    return readyToSetState;
  }

  public void setReadyToSetState(boolean rtss) {
    readyToSetState = rtss;
  }
}
