interface VehicleZoneState {

  void update();

  public boolean getReadyToSetState();
  public void setReadyToSetState(boolean rtss);
}

class VehicleZone {

  VehicleZoneState state;

  VehicleZoneState holdState;
  VehicleZoneState emptyState;
  VehicleZoneState fullState;
  VehicleZoneState inhaleState;
  VehicleZoneState exhaleState;
  VehicleZoneState inMotionNoZoneState;
  VehicleZoneState collisionState;

  Vehicle vehicle;

  float radius;
  float radiusMax, radiusMin;
  float distanceRadius;
  float originalRadiusMax;
  float tempDistanceRadius;

  boolean isBreathing;
  boolean switchFromExhaleToInhale;
  boolean switchFromInhaleToExhale;

  //--------------------------------------------------------------

  VehicleZone(Vehicle v) {

    vehicle = v;

    //radiusMax = vehicle.unitHalfSize;
    radiusMax = unit_w * 0.75; //unit_w * 0.35;
    //radiusMax = bgTrailBox.rectSize * 0.5;
    //println("radiusMax ", radiusMax);
    radiusMin = vehicle.blobRadius+5;
    distanceRadius = radiusMax;
    originalRadiusMax = radiusMax;

    radius = radiusMin;

    holdState = new HoldZoneState();
    emptyState = new EmptyZoneState(vehicle);
    fullState = new FullZoneState(vehicle);
    exhaleState = new ExhaleZoneState(vehicle);
    inhaleState = new InhaleZoneState(vehicle);
    inMotionNoZoneState = new InMotionNoZoneState();
    collisionState = new CollisionState(vehicle);



    switchFromExhaleToInhale = true;
    switchFromInhaleToExhale = true;
  }

  //--------------------------------------------------------------

  void setState(VehicleZoneState state) {
    this.state = state;
  }

  //--------------------------------------------------------------

  VehicleZoneState getState() {
    return state;
  }

  //--------------------------------------------------------------

  void update() {

    if (getState() != emptyState) {
      vehicle.readyToUpdateDistanceZone = true;
    }

    if (getState() != collisionState) { // test

      setZoneState();
    }

    state.update();

    resetStates();
  }

  void resetStates() {

    if (getState() == exhaleState) {
      emptyState.setReadyToSetState(true);
    } else if (getState() == inhaleState) {
      fullState.setReadyToSetState(true);
      //collisionState.setReadyToSetState(true);//test
    } else if (getState() == fullState) {
      collisionState.setReadyToSetState(true);
    }
  }

  //--------------------------------------------------------------

  void display() {

    ellipseMode(RADIUS);

    pushMatrix();

    translate(vehicle.posVecPixels.x, vehicle.posVecPixels.y);

    if (showDistance) {
      // outer circle for checking distance

      strokeWeight(3);
      stroke(vehicle.darkGrey);
      fill(vehicle.darkGrey);
      circle(0, 0, distanceRadius);
    }

    // repel / attract zone (breathing)

    strokeWeight(1);
    stroke(vehicle.colorBreathing);

    fill(vehicle.colorBreathing); // TEST
    circle(0, 0, radius);

    popMatrix();
  }


  //--------------------------------------------------------------
  void setZoneState() {

    radius = map(vehicle.breath.radius, vehicle.breath.radiusMin, vehicle.breath.radiusMax, radiusMin, radiusMax); //distanceRadius);

    // breathing radius

    isBreathing = true;

    switch(vehicle.breath.movement) {

    case "empty":
      setState(emptyState);
      break;
    case "breathing":

      if (vehicle.breath.direction == "inhale") {
        
        setState(inhaleState);

        switchFromExhaleToInhale = true;

        if (vehicle.otherBreathingVehicleComingClose) {

          if (switchFromInhaleToExhale) {

            vehicle.breath.aVelocity *= -1;
            switchFromInhaleToExhale = false;
          }
        }
      } else if (vehicle.breath.direction == "exhale") {
        
        setState(exhaleState);

        switchFromInhaleToExhale = true;

        if (vehicle.playerInDistanceZone ) { //&& !vehicle.otherBreathingVehicleComingClose) { // || vehicle.otherVehicleInDistanceZone) {

          if (switchFromExhaleToInhale) {

            vehicle.breath.aVelocity *= -1;
            switchFromExhaleToInhale = false;
          }
        }
      }

      break;

    case "full":
      setState(fullState);

      if (vehicle.playerInBreathingZone || vehicle.otherVehicleInBreathingZone) {

        isBreathing = false;
      } else { // no vehicle in area

        isBreathing = true;
      }
      break;
    default:
      break;
    }
  }

  //--------------------------------------------------------------

  void resetRadius() { // called in Bg_Unit when vehicles wrap

    vehicle.zoneAgainstZones = true;
    distanceRadius = originalRadiusMax;
    radiusMax = originalRadiusMax;
  }


  //--------------------------------------------------------------
} // VehicleZone class

// ********************************************************
// STATE CLASSES
// ********************************************************

class HoldZoneState implements VehicleZoneState {


  boolean readyToSetState;

  HoldZoneState() {

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

class EmptyZoneState implements VehicleZoneState {

  boolean readyToSetState;
  Vehicle vehicle;

  boolean isChangingCoorAngle;

  //boolean zoneResize;

  EmptyZoneState(Vehicle v) {

    vehicle = v;

    readyToSetState = true;

    //zoneResize = true;
  }

  //--------------------------------------------------------------

  void update() {

    if (readyToSetState) {

      setReadyToSetState(false);

      vehicle.updateColorNum();

      /*
      if (zoneResize) {
       checkDistanceZoneAgainstVehiclesDistanceZone();
       }
       */
    }
  }

  /*
  void checkDistanceZoneAgainstVehiclesDistanceZone() {
   
   int offset = 10;
   float tempDistanceRadius = vehicle.zone.originalDistanceRadius;
   
   for (int i = 0; i < vehicles.size()-1; i++) {
   
   Vehicle v = vehicles.get(i);
   
   if (v != vehicle) {
   
   Vec2 thisPosPix = box2d.getBodyPixelCoord(vehicle.centerBoid.body);
   Vec2 otherPosPix = box2d.getBodyPixelCoord(v.centerBoid.body);
   
   float d_pix = dist(thisPosPix.x, thisPosPix.y, otherPosPix.x, otherPosPix.y);
   
   if (d_pix < v.zone.distanceRadius + tempDistanceRadius + offset) {
   
   tempDistanceRadius = (d_pix - offset) / 2;
   v.zone.distanceRadius = (d_pix - offset) / 2;
   }
   }
   }
   
   
   vehicle.zone.distanceRadius = tempDistanceRadius;
   
   zoneResize = false;
   
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

class FullZoneState implements VehicleZoneState {

  boolean readyToSetState;
  Vehicle vehicle;

  FullZoneState(Vehicle v) {

    vehicle = v;

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

class ExhaleZoneState implements VehicleZoneState {

  boolean readyToSetState;

  Vehicle vehicle;

  ExhaleZoneState(Vehicle v) {

    readyToSetState = true;

    vehicle = v;
  }

  //--------------------------------------------------------------

  void update() {

    vehicle.otherBreathingVehicleComingClose = false;
  }

  public boolean getReadyToSetState() {
    return readyToSetState;
  }

  public void setReadyToSetState(boolean rtss) {
    readyToSetState = rtss;
  }
}
// ********************************************************

class InhaleZoneState implements VehicleZoneState {

  boolean readyToSetState;

  boolean zoneResize;

  Vehicle vehicle;

  InhaleZoneState(Vehicle v) {

    readyToSetState = true;

    zoneResize = true;

    vehicle = v;
  }

  //--------------------------------------------------------------

  void update() {


    if (readyToSetState) {

      setReadyToSetState(false);

      if (zoneResize) {
        //checkDistanceZoneAgainstVehiclesDistanceZone();
      }
    }
  }

  void checkDistanceZoneAgainstVehiclesDistanceZone() {

    int offset = 10;
    float tempDistanceRadius = vehicle.zone.originalRadiusMax;

    for (int i = 0; i < vehicles.size()-1; i++) {

      Vehicle v = vehicles.get(i);

      if (v != vehicle) {

        Vec2 thisPosPix = box2d.getBodyPixelCoord(vehicle.centerBoid.body);
        Vec2 otherPosPix = box2d.getBodyPixelCoord(v.centerBoid.body);

        float d_pix = dist(thisPosPix.x, thisPosPix.y, otherPosPix.x, otherPosPix.y);

        if (d_pix < v.zone.distanceRadius + tempDistanceRadius + offset) {

          tempDistanceRadius = (d_pix - offset) / 2;
          v.zone.distanceRadius = (d_pix - offset) / 2;
        }
      }
    }


    vehicle.zone.distanceRadius = tempDistanceRadius;

    zoneResize = false;
  }


  public boolean getReadyToSetState() {
    return readyToSetState;
  }

  public void setReadyToSetState(boolean rtss) {
    readyToSetState = rtss;
  }
}

// ********************************************************

class InMotionNoZoneState implements VehicleZoneState {

  boolean readyToSetState;

  InMotionNoZoneState() {

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


class CollisionState implements VehicleZoneState {

  boolean readyToSetState;
  Vehicle vehicle;

  CollisionState(Vehicle v) {

    vehicle = v;

    readyToSetState = true;
  }

  //--------------------------------------------------------------

  void update() {

    if (readyToSetState) {

      vehicle.breath.setEmpty();

      readyToSetState = false;

      vehicle.zone.setState(vehicle.zone.emptyState);

      vehicle.updateColorNum();
    }
  }



  public boolean getReadyToSetState() {
    return readyToSetState;
  }

  public void setReadyToSetState(boolean rtss) {
    readyToSetState = rtss;
  }
}
